## Soma Cube Solver in Dart

See it in action: http://lrytz.github.io/soma/build/soma.html

* Works in recent versions of [Chrome](https://www.google.com/chrome/) and [Firefox](http://www.mozilla.org/firefox/)
* Drag to rotate the shape
* Scroll to zoom

### Details

This project implements a solver for the [Soma cube](http://en.wikipedia.org/wiki/Soma_cube), an elegant
3D-Puzzle. It is implemented in [Dart](https://www.dartlang.org/). A plethora of information on the Soma cube
can be found on [Thorleif's Soma page](http://www.fam-bundgaard.dk/SOMA/SOMA.HTM).

The solver is an implementation of Donald Knuth's [Dancing Links](http://arxiv.org/pdf/cs/0011047v1.pdf). The
linked paper presents an efficient backtracking algorithm named "Algorithm X" for the
[exact cover](http://en.wikipedia.org/wiki/Exact_cover) problem, and it proposes an efficient implementation
technique called "Dancing Links".

The 3D presentation uses [three.dart](http://threedart.github.io/three.dart/), a Dart-port of the
[three.js](http://threejs.org/) Javascript library.

The [three.js examples page](http://stemkoski.github.io/Three.js/) by
[Lee Stemkoski](http://home.adelphi.edu/~stemkoski/) was tremendously helpful. The code for zooming and rotating
the camera was directly translated to dart from his examples.
