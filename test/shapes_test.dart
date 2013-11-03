import 'package:unittest/unittest.dart';
import '../web/shapes.dart';

main() {
  vectorTests();
  rotationTest();
  conflictsTest();
  solutionTest();
  dlxTest();
}

void vectorTests() {
  expect(UNIT_X + UNIT_X, equals(new Vector(2, 0, 0)));
  expect(UNIT_Y + UNIT_Z, equals(new Vector(0, 1, 1)));
  expect(UNIT_X * UNIT_X, equals(1));
  expect(UNIT_X * UNIT_Y, equals(0));
}

void rotationTest() {
  expect(UNIT_X.rotate(ROTATE_Z), equals(UNIT_Y));
  expect(UNIT_X.rotate(ROTATE_Z.andThen(ROTATE_Y)), equals(UNIT_Y));
  expect(UNIT_X.rotate(ROTATE_Z.andThen(ROTATE_X)), equals(UNIT_Z));
  expect(UNIT_X.rotate(ROTATE_Z * ROTATE_X), equals(UNIT_Y));
  expect(UNIT_Z.rotate(ROTATE_X.andThen(ROTATE_Z)), equals(UNIT_X));
  expect(UNIT_Z.rotate(ROTATE_X * ROTATE_Z), equals(new Vector(0, -1, 0)));
}

conflictsTest() {
  expect(
      SHAPE_V.conflicts(SHAPE_V.translate(UNIT_X)),
      equals(true));
  expect(
      SHAPE_V.conflicts(SHAPE_V.translate(UNIT_Z)),
      equals(false));
}

solutionTest() {
  Cube cube = new Cube();
  for (Shape s in ALL_SHAPES) {
    expect(
        cube.validPartialSolution([s]),
        equals(true));
  }
  expect(
         cube.validPartialSolution([SHAPE_Z, SHAPE_V.translate(UNIT_Z)]),
         equals(true));
  expect(
      cube.validPartialSolution([SHAPE_B, SHAPE_T.translate(UNIT_Z)]),
      equals(false));


  List<Shape> solution = cube.firstSolution();
  expect(cube.validSolution(solution), equals(true));
}

dlxTest() {
  List<List<int>> m1 =
      [[1,0],
       [1,0],
       [0,1],
       [1,1]];
  Solver s1 = new Solver.fromMatrixIndexResult(m1);
  expect(s1.findFirst(), equals([2, 0]));
  expect(s1.findAll(), equals([[2, 0], [2, 1], [3]]));

  List<List<int>> m2 =
      [[0,0,1,0,1,1,0],
       [1,0,0,1,0,0,1],
       [0,1,1,0,0,1,0],
       [1,0,0,1,0,0,0],
       [0,1,0,0,0,0,1],
       [0,0,0,1,1,0,1]];
  Solver s2 = new Solver.fromMatrixIndexResult(m2);
  expect(s2.findAll(), equals([[3, 0, 4]]));
}


