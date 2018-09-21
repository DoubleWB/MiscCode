import java.util.*;
import tester.Tester;
import javalib.impworld.*;

//Represents a maze and maze solver
class MazeWorld extends World {
    
    ArrayList<Edge> paths;
    ArrayList<ArrayList<Node>> nodes;
    int boardWidth;
    int boardHeight;
    Solution s;
    
    MazeWorld(int xSize, int ySize, String solutionType) {
        //Check for legal size
        if (xSize > 100 || xSize <= 0 || ySize > 60 || ySize <= 0) {
            throw new IllegalArgumentException("Badly sized maze");
        }
        //Create nodes
        nodes = new ArrayList<ArrayList<Node>>();
        for (int row = 0; row < ySize; row += 1) {
            nodes.add(row, new ArrayList<Node>());
            for (int col = 0; col < xSize; col += 1) {
                nodes.get(row).add(col, new Node(col, row));
            }
        }
        //Create unionFind
        UnionFind u = new UnionFind(nodes);
        //Create list of edges
        ArrayList<Edge> e = getHoriEdges(nodes);
        e.addAll(getVertEdges(nodes));
        Collections.shuffle(e);
        this.paths = this.generateMaze(u, e);
        //Decide dimensions
        Utility util = new Utility();
        this.boardWidth = xSize * util.getCellSize();
        this.boardHeight = ySize * util.getCellSize();
        //Make Solution
        if (solutionType.equals("d")) {
            this.s = new DepthFirst(paths, nodes.get(0).get(0), 
                    nodes.get(ySize - 1).get(xSize - 1));
        }
        else if (solutionType.equals("b")) {
            this.s = new BreadthFirst(paths, nodes.get(0).get(0), 
                    nodes.get(ySize - 1).get(xSize - 1));
        }
        else {
            this.s = new Manual(paths, nodes.get(0).get(0), 
                    nodes.get(ySize - 1).get(xSize - 1));
        }
    }
    
    //Returns every horizontal connection in this rectangular array of nodes
    ArrayList<Edge> getHoriEdges(ArrayList<ArrayList<Node>> nodes) {
        ArrayList<Edge> edges = new ArrayList<Edge>();
        for (int row = 0; row < nodes.size(); row += 1) {
            ArrayList<Node> curCol = nodes.get(row);
            for (int col = 0; col < curCol.size() - 1; col += 1) {
                Edge e = new Edge(curCol.get(col), curCol.get(col + 1), 1);
                edges.add(e);
            }
        }
        return edges;
    }
    
    //Returns every vertical connection in this rectangular array of nodes
    ArrayList<Edge> getVertEdges(ArrayList<ArrayList<Node>> nodes) {
        ArrayList<Edge> edges = new ArrayList<Edge>();
        for (int row = 0; row < nodes.size() - 1; row += 1) {
            ArrayList<Node> curCol = nodes.get(row);
            for (int col = 0; col < curCol.size(); col += 1) {
                Edge e = new Edge(curCol.get(col), nodes.get(row + 1).get(col), 1);
                edges.add(e);
            }
        }
        return edges;
    }
    
    // Returns minimum spanning tree of given sorted list of edges in a graph
    ArrayList<Edge> generateMaze(UnionFind u, ArrayList<Edge> worklist) {
        ArrayList<Edge> paths = new ArrayList<Edge>();
        while (!u.isOneBlob()) {
            Edge curMin = worklist.remove(0);
            String repCurMinFrom = u.findRep(curMin.from.name);
            String repCurMinTo = u.findRep(curMin.to.name);
            if (!repCurMinFrom.equals(repCurMinTo)) {
                paths.add(curMin);
                u.union(repCurMinFrom, repCurMinTo);
            }
        }
        return paths;
    }
    
    //Returns the image to be displayed on each tick of this MazeWorld
    public WorldScene makeScene() {
        WorldScene bkg = this.getEmptyScene();
        for (ArrayList<Node> n1: nodes) {
            for (Node n2: n1) {
                n2.makeImage(bkg);
            }
        }
        for (Edge e: this.paths) {
            e.makeImage(bkg);
        }
        s.addImages(bkg);
        return bkg;
    }
    
    //EFFECT: Mutates the world as to advance the solver properly on each tick
    public void onTick() {
        s.advance();
    }
    
    //EFFECT: Mutates the world as to advance the solver properly for each key press
    public void onKeyEvent(String key) {
        s.advanceWithInput(key);
        Utility u = new Utility();
        //Change the solving method
        if(key.equals("d")) {
            this.s = new DepthFirst(paths, nodes.get(0).get(0), 
                    nodes.get((boardHeight / u.getCellSize()) - 1).get(
                            (boardWidth / u.getCellSize()) - 1));
        }
        if(key.equals("b")) {
            this.s = new BreadthFirst(paths, nodes.get(0).get(0), 
                    nodes.get((boardHeight / u.getCellSize()) - 1).get(
                            (boardWidth / u.getCellSize()) - 1));
        }
        if(key.equals("m")) {
            this.s = new Manual(paths, nodes.get(0).get(0), 
                    nodes.get((boardHeight / u.getCellSize()) - 1).get(
                            (boardWidth / u.getCellSize()) - 1));
        }
        //Create a new maze and restart the solving method
        if(key.equals("r")) {
            UnionFind uf = new UnionFind(nodes);
            //Create list of edges
            ArrayList<Edge> e = getHoriEdges(nodes);
            e.addAll(getVertEdges(nodes));
            Collections.shuffle(e);
            this.paths = this.generateMaze(uf, e);
            this.s.restart(this.paths);
        }
    }
}

class ExamplesMazes {
    void testBigBang(Tester t) {
        MazeWorld maze = new MazeWorld(50, 50, "s");
        maze.bigBang(maze.boardWidth, maze.boardHeight, 1/120.0);
    }
    
    void testConstructionExceptions(Tester t) {
        t.checkConstructorException(new IllegalArgumentException("Badly sized maze"),
                "MazeWorld", 0, 10, "s");
        t.checkConstructorException(new IllegalArgumentException("Badly sized maze"), 
                "MazeWorld", 101, 10, "s");
        t.checkConstructorException(new IllegalArgumentException("Badly sized maze"), 
                "MazeWorld", 10, 0, "s");
        t.checkConstructorException(new IllegalArgumentException("Badly sized maze"), 
                "MazeWorld", 10, 61, "s");
    }
    
    void testHoriVertEdges(Tester t) {
        MazeWorld maze = new MazeWorld(2, 2, "d");
        t.checkExpect(maze.nodes.size(), maze.getHoriEdges(maze.nodes).size());
        t.checkExpect(maze.nodes.size(), maze.getVertEdges(maze.nodes).size());
        ArrayList<String> horiEdges = new ArrayList<String>();
        for (Edge e : maze.getHoriEdges(maze.nodes)) {
            horiEdges.add(e.from.name + e.to.name);
        }
        t.checkExpect(horiEdges.contains("0|01|0"), true);
        t.checkExpect(horiEdges.contains("0|11|1"), true);
        ArrayList<String> vertEdges = new ArrayList<String>();
        for (Edge e : maze.getVertEdges(maze.nodes)) {
            vertEdges.add(e.from.name + e.to.name);
        }
        t.checkExpect(vertEdges.contains("0|00|1"), true);
        t.checkExpect(vertEdges.contains("1|01|1"), true);
    }
    
    void testGenerateMaze(Tester t) {
        MazeWorld maze = new MazeWorld(5, 3, "d");
        //Spanning tree edges one less than number of nodes
        t.checkExpect(maze.paths.size(), 14);
    }
}

class Utility {
    
    //Must be a multiple of two to render properly - otherwise rounding causes errors
    //Returns the side length of one graphical cell
    int getCellSize() {
        return 16;
    }
}