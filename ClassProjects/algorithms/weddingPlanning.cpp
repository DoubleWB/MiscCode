#include <cstdio>
#include <vector>
#include <string>
#include <iostream>
#include <unordered_map>
#include <algorithm>
#include <cstdlib>

//classes
class Edge;
class Heap;

//utils
int childToParent(int);
int parentToLeftChild(int);
int parentToRightChild(int);
void hSwap(std::vector<Edge>&, int, int);

//globals
unsigned int numCities = 0;
unsigned int numEdges = 0;
std::unordered_map<unsigned int, std::vector<Edge>> revGraph = std::unordered_map<unsigned int, std::vector<Edge>>();
std::unordered_map<unsigned int, unsigned int> distances = std::unordered_map<unsigned int, unsigned int>();
unsigned int startCity = 0;

class Edge {
    public:
    Edge(unsigned int v, unsigned int s, unsigned int e) : value(v), start(s), end(e) {}
    unsigned int value;
    unsigned int start;
    unsigned int end;     
};

class Heap {
    public:
        Heap(): h() {};
        void add(Edge item) {
            h.insert(h.begin() + h.size(), item);
            int currentIndex = h.size();
            while (h.size() > 1 && !((h[childToParent(currentIndex) - 1].value <= h[currentIndex - 1].value))) {
                hSwap(h, currentIndex - 1, childToParent(currentIndex) - 1);
                currentIndex = childToParent(currentIndex);
            }
        }
        Edge extractMin() {
            Edge min = h[0];
            int currentIndex = 1;
            //std::cout << "Current Bottom\n";            
            //std::cout << h[h.size()-1].value;
            //std::cout << "\n";
            hSwap(h, 0, h.size() - 1);
            //std::cout << "Current Bottom\n";            
            //std::cout << h[h.size()-1].value;
            //std::cout << "\n";
            h.erase(h.begin() + (h.size() - 1));
            //std::cout << "Current Bottom\n";            
            //std::cout << h[h.size()-1].value;
            //std::cout << "\n";
            if (h.size() > 0) {
                while (!((h[currentIndex - 1].value <= h[parentToLeftChild(currentIndex) - 1].value)
                        && (h[currentIndex - 1].value <= h[parentToRightChild(currentIndex) - 1].value))) {
                    int newIndex = 0;
                    bool isBottom = false;
                    if (h[parentToLeftChild(currentIndex) - 1].value <= h[parentToRightChild(currentIndex) - 1].value) {
                        newIndex = parentToLeftChild(currentIndex);
                    }
                    else {
                        newIndex = parentToRightChild(currentIndex);
                    }
                    if (newIndex > h.size()) {
                        newIndex = h.size();
                        isBottom = true;
                    }
                    hSwap(h, currentIndex - 1, newIndex - 1);
                    currentIndex = newIndex;
                    if (isBottom) {
                        break;                
                    }
                }
            }
            return min;
        }
        int size() {
            return h.size();
        }
    private:
        std::vector<Edge> h;
};

int childToParent(int childIndex) {
    return childIndex/2;
}

int parentToLeftChild(int parentIndex) {
    return ((parentIndex) * 2);
}

int parentToRightChild(int parentIndex) {
    return (((parentIndex) * 2) + 1);
}

void hSwap(std::vector<Edge> &vector, int first, int second) {
    Edge temp = vector[first];
    vector[first] = vector[second];
    vector[second] = temp;
}

void scanData() {
    scanf("%d%d%d", &numCities, &numEdges, &startCity);
    unsigned int lineCount = 0;
    while (lineCount < numEdges) {
        unsigned int weight;
        unsigned int start;
        unsigned int end;
        scanf("%d%d%d", &start, &end, &weight);
        revGraph[end].push_back(Edge(weight, end, start));
        lineCount++;
    }
}

void djikstra() {
    //std::unordered_map<int, bool> visited = std::unordered_map<int, bool>();
    std::vector<unsigned int> visited = std::vector<unsigned int>();
    Heap priorityQueue = Heap();
    distances[startCity] = 0;// initialize distances
    //for (Edge e : revGraph[startCity]) { // add all first edges to queue
    //    priorityQueue.add(e);
    //}
    for (unsigned int i = 0; i < revGraph[startCity].size(); ++i) {
        priorityQueue.add(revGraph[startCity][i]);
    }
    while (priorityQueue.size() != 0) {
        Edge next = priorityQueue.extractMin();
        //std::cout << "edge: ";
        //std::cout << next.start;
        //std::cout << ' ';
        //std::cout << next.end;
        //std::cout << ' ';
        //std::cout << next.value;
        //std::cout << '\n';
        if(std::find(visited.begin(), visited.end(), next.end) != visited.end()) { //node we're traveling to already visited
            continue;
        }
        else {
            //visited[next.end] = true; // we've visited this node now
            visited.push_back(next.end);
            distances[next.end] = next.value; //remember the shortest path to this node
            //for (Edge e : revGraph[next.end]) { // add all the new edges from this node to the queue
            //    priorityQueue.add(Edge(distances[e.start] + e.value, e.start, e.end));
            //}
            //printf("Im over here now\n");
            for (unsigned int i = 0; i < revGraph[next.end].size(); ++i) {
                Edge e = revGraph[next.end][i];
                priorityQueue.add(Edge(distances[e.start] + e.value, e.start, e.end));
            }
        }
    }
    distances[startCity] = -1; // differentiate from 0's (no path)
}

void fakeData() {
    numCities = 50000;
    numEdges = 60000;
    startCity = std::rand() % 50000; 
    unsigned int lineCount = 0;
    while (lineCount < numEdges) {
        unsigned int weight = std::rand() % 5000;
        unsigned int start = std::rand() % 50000;
        unsigned int end = std::rand() % 50000;
        if (revGraph.count(end) == 0) {
            revGraph[end] = std::vector<Edge>();
            revGraph[end].push_back(Edge(weight, end, start));
        }
        else {
            revGraph[end].push_back(Edge(weight, end, start));
        }
        lineCount++;
    }
}

int main() {
    //scanData();
    fakeData(); //LOL
    djikstra();
    for (unsigned int i = 1; i <= numCities; ++i) {
        unsigned int dist = distances[i];
        if (dist == 0) {
            printf("%d ", -1);
        }
        else if (dist == -1) {
            printf("%d ", 0);
        }
        else {
            printf("%d ", dist);
        }
    }
}