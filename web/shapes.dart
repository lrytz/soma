library shapes;

import 'utils.dart';

part 'solution.dart';

class Shape {
  final List<Vector> elements;

  Shape(this.elements);

  factory Shape.fromString(String s) {
    List<Vector> elems = [];
    List<String> lines = s.split('\n');
    for (int y = 0 ; y < lines.length; y++) {
      String line = lines[lines.length - 1 - y];
      for (int x = 0; x < line.length; x++) {
        String c = line[x];
        if (c == '.' || c == '|') {
          elems.add(new Vector(x, y, 0));
        }
        if (c == '|') {
          elems.add(new Vector(x, y, 1));
        }
      }
    }
    return new Shape(elems);
  }

  String toString() {
    String s = '';
    elements.forEach((e) => s = s + '\n$e');
    return s;
  }

  Vector get low => extremes((x, y) => x < y);
  Vector get high => extremes((x, y) => x > y);

  Vector extremes(BinaryPredicate pred) {
    Vector first = elements.first;
    int x = first.x;
    int y = first.y;
    int z = first.z;
    elements.getRange(1, elements.length).forEach((e) {
      if (pred(e.x, x)) x = e.x;
      if (pred(e.y, y)) y = e.y;
      if (pred(e.z, z)) z = e.z;
    });
    return new Vector(x, y, z);
  }

  Shape translate(Vector v) =>
    new Shape(elements.map((e) => e + v).toList());

  Shape moveTo(Vector v) => translate(v - low);

  Shape rotate(Rotation m) =>
    new Shape(elements.map((e) => e.rotate(m)).toList());
}

typedef bool BinaryPredicate(int x, int y);

final Shape SHAPE_V = new Shape.fromString('''
.
..''');

final Shape SHAPE_L = new Shape.fromString('''
.
...''');

final Shape SHAPE_T = new Shape.fromString('''
 .
...''');

final Shape SHAPE_Z = new Shape.fromString('''
..
 ..''');

final Shape SHAPE_A = new Shape.fromString('''
 |
..''');

final Shape SHAPE_B = new Shape.fromString('''
..
 |''');

final Shape SHAPE_P = new Shape.fromString('''
.|
 .''');

final List<Shape> ALL_SHAPES = [SHAPE_V, SHAPE_L, SHAPE_T, SHAPE_Z, SHAPE_A,
                                SHAPE_B, SHAPE_P];

class Vector {
  final int x, y, z;

  const Vector(this.x, this.y, this.z);

  bool operator==(Object o) {
    if (identical(this, o)) return true;
    if (o is Vector) {
      Vector oV = (o as Vector);
      return x == oV.x && y == oV.y && z == oV.z;
    } else {
      return false;
    }
  }

  int get hashCode => jHash([x, y, z]);

  String toString() => '[$x, $y, $z]';

  Vector operator+(Vector v) => new Vector(x+v.x, y+v.y, z+v.z);
  Vector operator-(Vector v) => new Vector(x-v.x, y-v.y, z-v.z);

  int operator*(Vector v) => x*v.x + y*v.y + z*v.z;

  Vector rotate(Rotation m) =>
    new Vector(this * m.xFactors, this * m.yFactors, this * m.zFactors);
}

final Vector ORIGIN = const Vector(0, 0, 0);
final Vector UNIT_X = const Vector(1, 0, 0);
final Vector UNIT_Y = const Vector(0, 1, 0);
final Vector UNIT_Z = const Vector(0, 0, 1);

int cosN(int n) {
  switch (n) {
    case 0: return 1;
    case 1: return 0;
    case 2: return -1;
    case 3: return 0;
  }
}

int sinN(int n) {
  switch (n) {
    case 0: return 0;
    case 1: return 1;
    case 2: return 0;
    case 3: return -1;
  }
}

class Rotation {
  final Vector xFactors;
  final Vector yFactors;
  final Vector zFactors;

  Rotation(this.xFactors, this.yFactors, this.zFactors);

  Rotation.rotateX(int steps) :
    xFactors = UNIT_X,
    yFactors = new Vector(0, cosN(steps), -sinN(steps)),
    zFactors = new Vector(0, sinN(steps), cosN(steps));

  Rotation.rotateY(int steps) :
    xFactors = new Vector(cosN(steps), 0, sinN(steps)),
    yFactors = UNIT_Y,
    zFactors = new Vector(-sinN(steps), 0, cosN(steps));

  Rotation.rotateZ(int steps) :
    xFactors = new Vector(cosN(steps), -sinN(steps), 0),
    yFactors = new Vector(sinN(steps), cosN(steps), 0),
    zFactors = UNIT_Z;

  bool operator==(Object o) {
    if (identical(this, o)) return true;
    if (o is Rotation) {
      Rotation oR = (o as Rotation);
      return xFactors == oR.xFactors && yFactors == oR.yFactors &&
          zFactors == oR.zFactors;
    } else {
      return false;
    }
  }

  int get hashCode => jHash([xFactors, yFactors, zFactors]);

  String toStirng() => '$xFactors\n$yFactors\n$zFactors';

  Rotation transpose() =>
      new Rotation(
          new Vector(xFactors.x, yFactors.x, zFactors.x),
          new Vector(xFactors.y, yFactors.y, zFactors.y),
          new Vector(xFactors.z, yFactors.z, zFactors.z));


  /**
   * Returns a rotation matrix that first performs the rotation of [m] and then
   * the rotation of [this].
   */
  Rotation operator*(Rotation m) {
    Rotation mT = m.transpose();
    return new Rotation(
        new Vector(xFactors * mT.xFactors, xFactors * mT.yFactors, xFactors * mT.zFactors),
        new Vector(yFactors * mT.xFactors, yFactors * mT.yFactors, yFactors * mT.zFactors),
        new Vector(zFactors * mT.xFactors, zFactors * mT.yFactors, zFactors * mT.zFactors));

  }

  Rotation andThen(Rotation m) => m * this;
}

// Rotate counter-clockwise around the X-axis by 90 degrees. Coutner-clockwise
// when looking from the direction of X on the Y-Z plane.
final Rotation ROTATE_ID = new Rotation(UNIT_X, UNIT_Y, UNIT_Z);
final Rotation ROTATE_X = new Rotation.rotateX(1);
final Rotation ROTATE_Y = new Rotation.rotateY(1);
final Rotation ROTATE_Z = new Rotation.rotateZ(1);
