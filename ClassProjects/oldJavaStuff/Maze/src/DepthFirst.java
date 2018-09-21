import java.awt.Color;
import java.util.ArrayList;

import javalib.impworld.WorldScene;

class DepthFirst extends Solution {
    
    ArrayList<Node> depthWorklist;
    Node pioneer;

    DepthFirst(ArrayList<Edge> t, Node s, Node g) {
        super(t, s, g);
        this.depthWorklist = new ArrayList<Node>();
        this.depthWorklist.add(s);
        this.pioneer = new Node(-1, -1);
    }
    
    //EFFECT: Undoes all of the progress currently made by this Depth First Search
    void restart(ArrayList<Edge> newTree) {
        super.restart(newTree);
        this.depthWorklist = new ArrayList<Node>();
        this.depthWorklist.add(start);
        this.pioneer = new Node(-1, -1);
    }
    
    //EFFECT: advances the depth first search of the maze one unit
    void advance() {
        if (depthWorklist.size() > 0 && finalSolution.size() == 0) {
            Node next = depthWorklist.remove(depthWorklist.size() - 1);
            pioneer = next;
            if (visited.contains(next)) {
                return;
            }
            else if (goal == next) {
                this.reconstruct(next);
                return;
            }
            else {
                visited.add(next);
                ArrayList<Node> neighbors = this.getNeighbors(next);
                for (Node n : neighbors) {
                    cameFrom.putIfAbsent(n.name, next);
                }
                depthWorklist.addAll(neighbors);
            }
        }
    }
    
    //EFFECT: Draws this depth first solution onto the given background
    void addImages(WorldScene bkg) {
        super.addImages(bkg);
        this.pioneer.makeBackground(bkg, Color.BLUE);
    }
}
