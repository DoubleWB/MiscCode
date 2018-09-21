import java.awt.Color;
import java.util.*;
import javalib.impworld.WorldScene;

//Represents a maze solver
abstract class Solution {
    
    ArrayList<Edge> tree;
    ArrayList<Node> visited;
    ArrayList<Node> finalSolution;
    HashMap<String, Node> cameFrom;
    Node start;
    Node goal;
    
    Solution(ArrayList<Edge> t, Node s, Node g) {
        this.tree = t;
        this.visited = new ArrayList<Node>();
        this.finalSolution = new ArrayList<Node>();
        this.start = s;
        this.goal = g;
        this.cameFrom = new HashMap<String, Node>();
    }
    
    //EFFECT: Undoes all of the progress made currently by this solver
    void restart(ArrayList<Edge> newTree) {
        this.tree = newTree;
        this.visited = new ArrayList<Node>();
        this.finalSolution = new ArrayList<Node>();
        this.cameFrom = new HashMap<String, Node>();
    }
    
    //Returns the list of neighbors of the given node n in the tree
    ArrayList<Node> getNeighbors(Node n) {
        ArrayList<Node> output = new ArrayList<Node>();
        for (Edge e : tree) {
            if (n == e.from) {
                output.add(e.to);
            }
            if (n == e.to) {
                output.add(e.from);
            }
        }
        return output;
    }
    
    //Returns the edge in the tree connecting the two given nodes if it exists
    Edge getEdge(Node from, Node to) {
        for (Edge e : tree) {
            if ((from == e.from && to == e.to) || (to == e.from && from == e.to)) {
                return new Edge(from, to, 1);
            }
        }
        return null;
    }
    
    //EFFECT: advances searching of the maze one unit
    void advance() {
        //DEFAULT: Do nothing on Tick
    }
    
    //EFFECT: advances searching of the maze according to the given input
    void advanceWithInput(String input) {
        //DEFAULT: Do nothing on Key
    }
    
    //EFFECT: change finalSolution to be the path from the given node to the start (backwards)
    void reconstruct(Node goal) {
        finalSolution.add(goal);
        Node cur = goal;
        while (finalSolution.get(0) != start){
            cur = cameFrom.get(cur.name);
            finalSolution.add(0, cur);
        }
    }
    
    //EFFECT: Changes the given worldscene to have the images that represent this search;
    void addImages(WorldScene bkg) {
        //Draws the visited nodes
        for (Node n : this.visited) {
            n.makeBackground(bkg, Color.CYAN);
        }
        //Draw the most recent pioneer
        
        //Draws the finalSolution 
        for (Node n : this.finalSolution) {
            n.makeBackground(bkg, Color.RED);
        }
        
        //Draw each goal
        this.start.makeBackground(bkg, Color.GREEN);
        this.goal.makeBackground(bkg, Color.MAGENTA);
    }
    
    

}
