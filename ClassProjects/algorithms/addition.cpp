#include <cstdio>
#include <iostream>

int main() {
  int A, B;
  scanf("%d%d", &A, &B);
  printf("%d\n", A + B);
  return 0;
}

void testHeap() {
    Edge e = Edge(1, 1, 2);
    Edge e1 = Edge(2, 2, 3);
    Edge e2 = Edge(3, 3, 4);
    Edge e3 = Edge(4, 4, 5); 
    Edge e4 = Edge(2, 5, 6);
    Edge e5 = Edge(5, 6, 7);
    Edge e6 = Edge(3, 7, 8);
    Edge e7 = Edge(4, 8, 9);
    Edge e8 = Edge(6, 9, 10);
    Heap h = Heap();
    h.add(e);
    h.add(e2);
    h.add(e1);
    h.add(e3);
    h.add(e4);
    h.add(e5);
    h.add(e6);
    h.add(e7);
    h.add(e8);
    h.print();
    std::cout << h.extractMin().value;
    std::cout << '\n';
    std::cout << h.extractMin().value;
    std::cout << '\n';
    std::cout << h.extractMin().value;
    std::cout << '\n';
    std::cout << h.extractMin().value;
    std::cout << '\n';
    std::cout << h.extractMin().value;
    std::cout << '\n';
    std::cout << h.extractMin().value;
    std::cout << '\n';
    std::cout << h.extractMin().value;
    std::cout << '\n';
    std::cout << h.extractMin().value;
    std::cout << '\n';
    std::cout << h.extractMin().value;
    std::cout << '\n';
}