#include <cstdio>
#include <vector>
#include <string>
#include <iostream>
#include <unordered_map>
#include <algorithm>
#include <stack>

//classes
class Edge;

//utils
void dfsRecurseReverse(std::unordered_map<int, bool>&, int);
void dfsRecurse(std::unordered_map<int, bool>&, int, int);
void dfsSCCRecurse(std::unordered_map<int, bool>&, int);

//globals
int numCities = 0;
int numEdges = 0;
std::unordered_map<int, std::vector<Edge>> graph = std::unordered_map<int, std::vector<Edge>>();
std::unordered_map<int, std::vector<Edge>> revGraph = std::unordered_map<int, std::vector<Edge>>();
std::stack<int> finishTimes = std::stack<int>();
std::unordered_map<int, int> vertToLeader = std::unordered_map<int, int>();
std::unordered_map<int, bool> unvisited = std::unordered_map<int, bool>();
std::vector<Edge> betweenSCCS = std::vector<Edge>();
std::unordered_map<int, std::vector<Edge>> SCCgraph = std::unordered_map<int, std::vector<Edge>>();
int unvisitedCount = 0;

class Edge {
    public:
    Edge( int s, int e) : start(s), end(e) {}
    int start;
    int end;     
};

void scanData() {
    scanf("%d%d", &numCities, &numEdges);
    int lineCount = 0;
    while (lineCount < numEdges) {
        int start;
        int end;
        scanf("%d%d", &start, &end);
        if (graph.count(start) == 0) {
            graph[start] = std::vector<Edge>();
            graph[start].push_back(Edge(start, end));
        }
        else {
            graph[start].push_back(Edge(start, end));
        }
        if (revGraph.count(end) == 0) {
            revGraph[end] = std::vector<Edge>();
            revGraph[end].push_back(Edge(end, start));
        }
        else {
            revGraph[end].push_back(Edge(end, start));
        }
        lineCount++;
    }
    for (int i = 1; i <= numCities; ++i) {
        unvisited[i] = true;
    }
    unvisitedCount = numCities;
}

void dfsFirstPass() {
    std::unordered_map<int, bool> visited = std::unordered_map<int, bool>();
    while (unvisitedCount != 0) {
        for (int i = 1; i <= numCities; i++) {
            if (unvisited[i]) {
                dfsRecurseReverse(visited, i);
                break;
            }
        }
    }
}

void dfsRecurseReverse(std::unordered_map<int, bool> &visited, int thisCity) {
    visited[thisCity] = true;
    unvisited[thisCity] = false;
    unvisitedCount -= 1;
    for (Edge e : revGraph[thisCity]) {
        if (visited[e.end]) {
            continue;
        }
        //std::cout << "edge: ";
        //std::cout << e.start;
        //std::cout << ' ';
        //std::cout << e.end;
        //std::cout << '\n';
        dfsRecurseReverse(visited, e.end);
    }
    finishTimes.push(thisCity);
}

void dfsSecondPass() {
    std::unordered_map<int, bool> visited = std::unordered_map<int, bool>();
    while (unvisitedCount != 0) {
        int latestCity = finishTimes.top();
        finishTimes.pop();
        if (unvisited[latestCity]) {
            dfsRecurse(visited, latestCity, latestCity);
        }
    }
}

void dfsRecurse(std::unordered_map<int, bool> &visited, int thisCity, int leader) {
    vertToLeader[thisCity] =  leader;
    visited[thisCity] = true;
    unvisited[thisCity] = false;
    unvisitedCount -= 1;
    for (Edge e : graph[thisCity]) {
        if (visited[e.end]) {
            if (vertToLeader[e.end] != leader) {
                betweenSCCS.push_back(e);
            }
            continue;
        }
        //std::cout << "edge: ";
        //std::cout << e.start;
        //std::cout << ' ';
        //std::cout << e.end;
        //std::cout << '\n';
        dfsRecurse(visited, e.end, leader);
    }
    finishTimes.push(thisCity);
}


int dfsThirdPass(std::vector<int> allLeaders) {
    int totalVerts = 0;
    for(int l : allLeaders) {
        std::unordered_map<int, bool> visited = std::unordered_map<int, bool>();
        dfsSCCRecurse(visited, l);
        if (visited.size() == allLeaders.size()) {
            //printf("GOTTEM\n");
            for(int i = 1; i <= numCities; ++i) {
                //printf("on vertex %d, with leader %d, matching for %d\n", i, vertToLeader[i], l);
                if (vertToLeader[i] == l) {
                    totalVerts += 1;
                }
            }
            return totalVerts;
        }
    }
    return totalVerts;
}

void dfsSCCRecurse(std::unordered_map<int, bool> &visited, int thisCity) {
    visited[thisCity] = true;
    for (Edge e : graph[thisCity]) {
        if (visited[e.end]) {
            continue;
        }
        dfsSCCRecurse(visited, e.end);
    }
    finishTimes.push(thisCity);
}

int main() {
    scanData();
    dfsFirstPass();
    for (int i = 1; i <= numCities; ++i) {
        unvisited[i] = true;
    }
    unvisitedCount = numCities;
    dfsSecondPass();
    std::vector<int> allLeaders = std::vector<int>();
    std::unordered_map<int, std::unordered_map<int, bool>> connectedTo = std::unordered_map<int, std::unordered_map<int, bool>>();
    for (Edge e : betweenSCCS) {
        int start = vertToLeader[e.start];
        int end = vertToLeader[e.end];
        if (std::find(allLeaders.begin(), allLeaders.end(), start) == allLeaders.end()) {
            allLeaders.push_back(start);
        }
        if (std::find(allLeaders.begin(), allLeaders.end(), end) == allLeaders.end()) {
            allLeaders.push_back(end);
        }
        SCCgraph[end].push_back(Edge(end, start));
    }
    printf("%d", dfsThirdPass(allLeaders));
    //printf("%lu\n", betweenSCCS.size()); 
    //printf("%d\n", biggestSCC); // the answer is probably the biggest SCC most of the time
}

