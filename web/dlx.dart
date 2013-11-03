part of shapes;

class Element {
  Element left;
  Element right;
  Element up;
  Element down;
  HeaderElement header;
  Element(this.left, this.right, this.up, this.down, this.header);
}

class RowElement<T> extends Element {
  T elem;
  RowElement(RowElement left, RowElement right, Element up, Element down,
      HeaderElement header, this.elem) : super(left, right, up, down, header) {
    left.right = this;
    right.left = this;
    up.down = this;
    down.up = this;
  }

  RowElement.initial(Element up, Element down, HeaderElement header, this.elem)
      : super(null, null, up, down, header) {
    left = this;
    right = this;
    up.down = this;
    down.up = this;
  }
}

class HeaderElement extends Element {
  int size = 0;

  HeaderElement(HeaderElement left, HeaderElement right)
      : super(left, right, null, null, null) {
    up = this;
    down = this;
    header = this;
    left.right = this;
    right.left = this;
  }

  HeaderElement.initial() : super(null, null, null, null, null) {
    left = this;
    right = this;
  }
}

// list of rows or null
class Solver<T> {
  HeaderElement h;

  List<List<T>> solutions = <List<T>>[];

  Solver.fromMatrixIndexResult(List<List<int>> m) {
    int numRows = m.length;
    List<int> indices = new List<int>(numRows);
    for (int i = 0; i < numRows; i++) {
      indices[i] = i;
    }
    buildLinks(m, indices);
  }

  Solver.fromMatrix(List<List<int>> m, List<T> rowData) {
    buildLinks(m, rowData);
  }

  void buildLinks(List<List<int>> m, List<T> rowData) {
    h = new HeaderElement.initial();
    bool headerDone = false;
    HeaderElement currentHeader = h;
    RowElement<T> lastInRow = null;

    for (int i = 0; i < m.length; i++) {
      List<int> row = m[i];
      for (int j = 0; j < row.length; j++) {
        if (!headerDone) {
          currentHeader = new HeaderElement(currentHeader, h);
        } else {
          currentHeader = currentHeader.right;
        }
        if (row[j] == 1) {
          if (lastInRow == null) {
            lastInRow = new RowElement.initial(
                currentHeader.up, currentHeader, currentHeader, rowData[i]);
          } else {
            lastInRow = new RowElement(lastInRow, lastInRow.right,
                currentHeader.up, currentHeader, currentHeader, rowData[i]);
          }
          currentHeader.size++;
        }
      }
      headerDone = true;
      currentHeader = h;
      lastInRow = null;
    }
  }

  List<RowElement<T>> o = <RowElement<T>>[];
  HeaderElement c;
  Element r;
  Element j;

  List<T> findFirst() {
    solutions = <List<T>>[];
    search(0, false);
    if (solutions.isEmpty) return null;
    return solutions.first;
  }

  List<List<T>> findAll() {
    solutions = <List<T>>[];
    search(0, true);
    return solutions;
  }

  void search(int k, bool findAll) {
    if (h.right == h) {
      appendSolution(o);
      return;
    }
    c = chooseColumn();
    coverColumn(c);
    r = c;
    while (r.down != c) {
      r = r.down;
      if (k == o.length) o.add(r);
      else o[k] = r;
      j = r;
      while (j.right != r) {
        j = j.right;
        coverColumn(j.header);
      }
      if (findAll || solutions.isEmpty)
        search(k + 1, findAll);
      o.length = k + 1;
      r = o[k];
      c = r.header;
      j = r;
      while (j.left != r) {
        j = j.left;
        uncoverColumn(j.header);
      }
    }
    uncoverColumn(c);
  }

  HeaderElement chooseColumn() {
    HeaderElement next = h.right;
    HeaderElement minElement = next;
    int min = next.size;
    while (next.right != h) {
      next = next.right;
      if (next.size < min) {
        minElement = next;
        min = next.size;
      }
    }
    return minElement;
  }

  void appendSolution(List<RowElement<T>> o) {
    List<T> r = <T>[];
    o.forEach((e) => r.add(e.elem));
    solutions.add(r);
  }

  void coverColumn(Element c) {
    c.right.left = c.left;
    c.left.right = c.right;
    Element i = c;
    while (i.down != c) {
      i = i.down;
      Element j = i;
      while (j.right != i) {
        j = j.right;
        j.down.up = j.up;
        j.up.down = j.down;
        j.header.size--;
      }
    }
  }

  void uncoverColumn(Element c) {
    Element i = c;
    while (i.up != c) {
      i = i.up;
      Element j = i;
      while (j.left != i) {
        j = j.left;
        j.header.size++;
        j.down.up = j;
        j.up.down = j;
      }
    }
    c.right.left = c;
    c.left.right = c;
  }

}
