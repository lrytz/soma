part of shapes;

abstract class Figure {
  bool contains(Vector element);
  Vector get spread;

  bool containsShape(Shape shape) {
    for (Vector e in shape.elements) {
      if (!contains(e)) return false;
    }
    return true;
  }

  bool validPartialSolution(List<Shape> shapes) {
    for (int i = 0; i < shapes.length; i++) {
      for (int j = i + 1; j < shapes.length; j++) {
        if (shapes[i].conflicts(shapes[j])) return false;
      }
      if (!containsShape(shapes[i])) return false;
    }
    return true;
  }

  bool validSolution(List<Shape> shapes) {
    if (shapes.length != ALL_SHAPES.length) return false;
//  TODO: check that all ALL_SHAPES are in shapes. need to translate the ones
//  in shapes to the origin and rotate until they match.
//  for (Shape s in ALL_SHAPES) {
//    if (!shapes.contains(s)) return false;
//  }
    return validPartialSolution(shapes);
  }

  List<Shape> firstSolution() => findSolution(false);
  List<List<Shape>> allSolutions() => findSolution(true);

  findSolution(bool findAll) {
    List<List<int>> matrix = <List<int>>[];
    List<Shape> rowData = <Shape>[];
    int numShapes = ALL_SHAPES.length;
    List<Vector> elements = <Vector>[];
    for (int i = 0; i < spread.x; i++) {
      for (int j = 0; j < spread.y; j++) {
        for (int k = 0; k < spread.z; k++) {
          Vector v = new Vector(i, j, k);
          if (contains(v)) elements.add(v);
        }
      }
    }
    int numElements = elements.length;
    for (int i = 0; i < numShapes; i++) {
      Shape s = ALL_SHAPES[i];
      Iterator<Shape> positions = new ShapeTransformations(s, this);
      while (positions.moveNext()) {
        List<int> row = new List<int>.filled(numShapes + numElements, 0);
        row[i] = 1;
        Shape shape = positions.current;
        rowData.add(shape);
        for (int j = 0; j < numElements; j++) {
          if (shape.elements.contains(elements[j])) {
            row[numShapes + j] = 1;
          }
        }
        matrix.add(row);
      }
    }
    Solver<Shape> solver = new Solver.fromMatrix(matrix, rowData);
    if (findAll) {
      return solver.findAll();
    } else {
      return solver.findFirst();
    }
  }
}

class Cube extends Figure {
  bool contains(Vector element) {
    return element.x >= 0 && element.x <= 2 &&
           element.y >= 0 && element.y <= 2 &&
           element.z >= 0 && element.z <= 2;
  }

  final Vector spread = const Vector(3, 3, 3);

  static Cube _instance;

  factory Cube() {
    if (_instance == null) _instance = new Cube._internal();
    return _instance;
  }

  Cube._internal();
}

class Castle extends Figure {
  bool contains(Vector element) {
    int x = element.x;
    int y = element.y;
    int z = element.z;
    if (y == 0) {
      return x >= 0 && x <= 4 && z >= 0 && z <= 4 && !(x == 4 && z == 4);
    } else if (y == 1) {
      return (x == 0 && z == 0) || (x == 4 && z == 0) || (x == 0 && z == 4);
    } else {
      return false;
    }
  }

  final Vector spread = const Vector(5, 2, 5);

  static Castle _instance;

  factory Castle() {
    if (_instance == null) _instance = new Castle._internal();
    return _instance;
  }

  Castle._internal();
}

class Bathtub extends Figure {
  bool contains(Vector element) {
    int x = element.x;
    int y = element.y;
    int z = element.z;
    if (y == 0) {
      return x >= 0 && x <= 2 && z >= 0 && z <= 4;
    } else if (y == 1) {
      return ((x == 0 || x == 2) && z >= 0 && z <= 4) || (x == 1 && (z == 0 || z == 4));
    } else {
      return false;
    }
  }

  final Vector spread = const Vector(3, 2, 5);

  static Bathtub _instance;

  factory Bathtub() {
    if (_instance == null) _instance = new Bathtub._internal();
    return _instance;
  }

  Bathtub._internal();
}


class ShapeTransformations extends Iterator<Shape> {
  final Shape shape;
  final Figure figure;

  ShapeTransformations(this.shape, this.figure);

  int x = -1, y = 0, z = 0, r1 = 0, r2 = 0;

  Shape current;

  bool moveNext() {
    if (x == -1) {
      x = 0;
    } else if (r2 < 4) {
      r2++;
    } else if (r1 < 6) {
      r1++;
      r2 = 0;
    } else if (z < figure.spread.z) {
      z++;
      r1 = 0;
      r2 = 0;
    } else if (y < figure.spread.y) {
      y++;
      r1 = 0;
      r2 = 0;
      z = 0;
    } else if (x < figure.spread.x) {
      x++;
      r1 = 0;
      r2 = 0;
      z = 0;
      y = 0;
    } else {
      return false;
    }
    return tryNext();
  }


  bool tryNext() {
    Rotation rotation = ROTATE_ID;
    for (int i = 0; i < 4 && i < r1; i++) {
      rotation = rotation.andThen(ROTATE_X);
    }
    if (r1 < 5) {
      rotation = rotation.andThen(ROTATE_Y);
    }
    if (r1 == 5) {
      rotation = rotation.andThen(ROTATE_Y).andThen(ROTATE_Y);
    }
    for (int i = 0; i < r2; i++) {
      rotation = rotation.andThen(ROTATE_Z);
    }
    Shape rotated = shape.rotate(rotation);
    current = rotated.moveTo(new Vector(x, y, z));

    if (figure.containsShape(current)) {
      return true;
    } else {
      return moveNext();
    }
  }
}
