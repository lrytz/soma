import 'package:unittest/unittest.dart';
import '../web/shapes.dart';

main() {
  vectorTests();
  rotationTest();
  conflictsTest();
  solutionTest();
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
      conflicts(SHAPE_V, SHAPE_V.translate(UNIT_X)),
      equals(true));
  expect(
      conflicts(SHAPE_V, SHAPE_V.translate(UNIT_Z)),
      equals(false));
}

solutionTest() {
  for (Shape s in ALL_SHAPES) {
    expect(
        new Cube().validPartialSolution([s]),
        equals(true));
  }
  expect(
         new Cube().validPartialSolution([SHAPE_Z, SHAPE_V.translate(UNIT_Z)]),
         equals(true));
  expect(
      new Cube().validPartialSolution([SHAPE_B, SHAPE_T.translate(UNIT_Z)]),
      equals(false));
}


