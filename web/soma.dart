library soma;

import 'dart:html';
import 'shapes.dart' hide Element;
import 'package:three/three.dart' hide Shape;
import 'package:vector_math/vector_math.dart' as vm;
import 'dart:math' as dm;

void main() {
  List<Shape> cubeSolution = new Cube().firstSolution();
  SomaCanvas canvas = new SomaCanvas(cubeSolution);
}

class SomaCanvas {
  Element container = new Element.tag('div');
  Renderer renderer = new WebGLRenderer();

  OrbitControls controls;

  int screenW = window.innerWidth;
  int screenH = window.innerHeight;

  SomaCanvas(List<Shape> shapes) {
    renderer.setSize(screenW, screenH);
    document.body.nodes.add(container);
    container.nodes.add(renderer.domElement);

    setupScene();
    addAxisHelper();
    addShapes(shapes);
    render(0);
  }

  Scene scene;
  Camera camera;

  setupScene() {
    scene = new Scene();

    var ambient = new AmbientLight(0x404040);
    scene.add(ambient);

    var pointLight = new DirectionalLight(0xffffff);
    pointLight.position.setValues(1.0, 1.0, 1.0).normalize();
    scene.add(pointLight);

    camera = new PerspectiveCamera(75.0, screenW / screenH);
    camera.position = new vm.Vector3(5.0, 5.0, 12.0);
    controls = new OrbitControls(camera, renderer.domElement);
  }

  addAxisHelper() {
    var axes = new AxisHelper();
    scene.add(axes);
  }

  addShapes(List<Shape> shapes) {
    shapes.forEach((s) {
      var geometry = new ShapeGeometry(s);
      scene.add(geometry);
    });
  }


  void render(num time) {
    window.requestAnimationFrame(render);
    renderer.render(scene, camera);
    controls.update();
  }
}


class ShapeGeometry extends Object3D {
  ShapeGeometry(Shape shape) {
    var geometry = new CubeGeometry(1.0, 1.0, 1.0);
    var material = new MeshLambertMaterial(color: new dm.Random().nextInt(0xffffff));
    for (Vector e in shape.elements) {
      var cube = new Mesh(geometry, material);
      cube.position.x = e.x.toDouble();
      cube.position.y = e.y.toDouble();
      cube.position.z = e.z.toDouble();
      this.add(cube);
    }
  }

}


class OrbitControls {
  Object3D object;
  Element domElement;

  OrbitControls(this.object, this.domElement) {
    domElement.onMouseDown.listen(onMouseDown);
    domElement.onMouseWheel.listen(onMouseWheel);
  }

  bool enabled = true;

  vm.Vector3 center = new vm.Vector3(0.0, 0.0, 0.0);

  bool userZoom = true;
  double userZoomSpeed = 1.0;

  bool userRotate = true;
  double userRotateSpeed = 1.0;

  bool userPan = true;
  double userPanSpeed = 2.0;

  bool autoRotate = false;
  double autoRotateSpeed = 2.0; // 30 seconds per round when fps is 60

  double minPolarAngle = 0.0; // radians
  double maxPolarAngle = dm.PI; // radians

  double minDistance = 0.0;
  double maxDistance = double.INFINITY;

  // internals

  var EPS = 0.000001;
  var PIXELS_PER_ROUND = 1800;

  var rotateStart = new vm.Vector2(0.0, 0.0);
  var rotateEnd = new vm.Vector2(0.0, 0.0);
  var rotateDelta = new vm.Vector2(0.0, 0.0);

  var zoomStart = new vm.Vector2(0.0, 0.0);
  var zoomEnd = new vm.Vector2(0.0, 0.0);
  var zoomDelta = new vm.Vector2(0.0, 0.0);

  var phiDelta = 0.0;
  var thetaDelta = 0.0;
  var scale = 1.0;

  var lastPosition = new vm.Vector3(0.0, 0.0, 0.0);

  static final int STATE_NONE = -1;
  static final int STATE_ROTATE = 0;
  static final int STATE_ZOOM = 1;
  static final int STATE_PAN = 2;

  var state = STATE_NONE;

  // events

  void rotateLeft([angle]) {
    if (angle == null) {
      angle = getAutoRotationAngle();
    }
    thetaDelta -= angle;
  }

  void rotateRight([angle]) {
    if (angle == null) {
      angle = getAutoRotationAngle();
    }
    thetaDelta += angle;
  }

  void rotateUp([angle]) {
    if (angle == null) {
      angle = getAutoRotationAngle();
    }
    phiDelta -= angle;
  }

  void rotateDown([angle]) {
    if (angle == null) {
      angle = getAutoRotationAngle();
    }
    phiDelta += angle;
  }

  void zoomIn([zoomScale]) {
    if (zoomScale == null) {
      zoomScale = getZoomScale();
    }
    scale /= zoomScale;
  }

  void zoomOut([zoomScale]) {
    if (zoomScale == null) {
      zoomScale = getZoomScale();
    }
    scale *= zoomScale;
  }

  void update() {
    var position = object.position;
    var offset = position.clone().sub(center);

    // angle from z-axis around y-axis
    var theta = dm.atan2(offset.x, offset.z);

    // angle from y-axis
    var phi = dm.atan2(dm.sqrt(offset.x * offset.x + offset.z * offset.z), offset.y);

    if (autoRotate) {
      rotateLeft( getAutoRotationAngle() );
    }

    theta += thetaDelta;
    phi += phiDelta;

    // restrict phi to be between desired limits
    phi = dm.max(minPolarAngle, dm.min(maxPolarAngle, phi));

    // restrict phi to be betwee EPS and PI-EPS
    phi = dm.max(EPS, dm.min(dm.PI - EPS, phi));

    var radius = offset.length * scale;

    // restrict radius to be between desired limits
    radius = dm.max(this.minDistance, dm.min(this.maxDistance, radius));

    offset.x = radius * dm.sin(phi) * dm.sin(theta);
    offset.y = radius * dm.cos(phi);
    offset.z = radius * dm.sin(phi) * dm.cos(theta);

    position.setFrom(center).add(offset);

    object.lookAt(this.center);

    thetaDelta = 0.0;
    phiDelta = 0.0;
    scale = 1.0;

    if (lastPosition.distanceTo(object.position) > 0) {
      lastPosition.setFrom(this.object.position);
    }
  }

  double getAutoRotationAngle() {
    return 2 * dm.PI / 60 / 60 * autoRotateSpeed;
  }

  double getZoomScale() {
    return dm.pow(0.95, userZoomSpeed);
  }

  var moveSubscription;
  var upSubscription;

  void onMouseDown(MouseEvent event) {
    if (!enabled) return;
    if (!userRotate) return;

    event.preventDefault();

    if ( state == STATE_NONE ) {
      state = STATE_ROTATE;
    }

    if (state == STATE_ROTATE) {
      rotateStart.setValues(event.client.x.toDouble(), event.client.y.toDouble());
    }

    moveSubscription = document.onMouseMove.listen(onMouseMove);
    upSubscription = document.onMouseUp.listen(onMouseUp);
  }

  void onMouseMove(MouseEvent event) {
    if (!enabled) return;
    event.preventDefault();

    if ( state == STATE_ROTATE ) {
      rotateEnd.setValues(event.client.x.toDouble(), event.client.y.toDouble());
      rotateDelta.setFrom(rotateEnd).sub(rotateStart);

      rotateLeft(2 * dm.PI * rotateDelta.x / PIXELS_PER_ROUND * userRotateSpeed);
      rotateUp(2 * dm.PI * rotateDelta.y / PIXELS_PER_ROUND * userRotateSpeed);

      rotateStart.setFrom(rotateEnd);
    }
  }

  void onMouseUp(MouseEvent event) {
    if (!enabled) return;
    if (!userRotate) return;

    moveSubscription.cancel();
    upSubscription.cancel();

    state = STATE_NONE;
  }

  void onMouseWheel(WheelEvent event) {
    if (!enabled) return;
    if (!userZoom) return;
    event.preventDefault();
    var delta = event.deltaY;
    if ( delta > 0 ) {
      zoomOut();
    } else {
      zoomIn();
    }

  }
}
