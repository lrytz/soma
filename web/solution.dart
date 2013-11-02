part of shapes;

bool conflicts(Shape a, Shape b) =>
    a.elements.any((e) => b.elements.contains(e));

abstract class Figure {
  bool contains(Vector element);
  Vector get spread;

  bool validPartialSolution(List<Shape> shapes) {
    for (int i = 0; i < shapes.length; i++) {
      for (int j = i + 1; j < shapes.length; j++) {
        if (conflicts(shapes[i], shapes[j])) return false;
      }
      for (Vector e in shapes[i].elements) {
        if (!contains(e)) return false;
      }
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
}

class Cube extends Figure {
  bool contains(Vector element) {
    return element.x >= 0 && element.y <= 2 &&
           element.y >= 0 && element.y <= 2 &&
           element.z >= 0 && element.z <= 2;
  }

  final Vector spread = const Vector(2, 2, 2);

  static Cube _instance;

  factory Cube() {
    if (_instance == null) _instance = new Cube._internal();
    return _instance;
  }

  Cube._internal();
}

List<Shape> findSolution(List<Shape> placed, List<Shape> unplaced, Figure figure) {
  if (unplaced.isEmpty) return placed;
  Shape next = unplaced.first;
  List<Shape> rest = unplaced.sublist(1, unplaced.length);

  Iterator<Shape> nextPositions = new TransformedShapeIterator(next, placed, figure);
  while (nextPositions.moveNext()) {
    List<Shape> newPlaced = <Shape>[];
    newPlaced.addAll(placed);
    newPlaced.add(nextPositions.current);
    List<Shape> solution = findSolution(newPlaced, rest, figure);
    if (solution != null) return solution;
  }
  return null;
}

class TransformedShapeIterator extends Iterator<Shape> {
  final Shape next;
  final List<Shape> placed;
  final Figure figure;

  TransformedShapeIterator(this.next, this.placed, this.figure);

  int x = -1, y = 0, z = 0, r1 = 0, r2 = 0;

  Shape current;

  bool moveNext() {
    // First return / try [next].
    if (x == -1) {
      x = 0;
    } else if (r2 < 4) {
      r2++;
    } else if (r1 < 6) {
      r1++;
      r2 = 0;
    } else if (z <= figure.spread.z) {
      z++;
      r1 = 0;
      r2 = 0;
    } else if (y <= figure.spread.y) {
      y++;
      r1 = 0;
      r2 = 0;
      z = 0;
    } else if (x <= figure.spread.x) {
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
    Shape rotated = next.rotate(rotation);
    current = rotated.moveTo(new Vector(x, y, z));

    List<Shape> sol = <Shape>[];
    sol.addAll(placed);
    sol.add(current);
    if (figure.validPartialSolution(sol)) {
      return true;
    } else {
      return moveNext();
    }
  }
}





