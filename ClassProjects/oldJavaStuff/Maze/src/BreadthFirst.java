import java.awt.Color;
import java.util.*;

import javalib.impworld.WorldScene;

class BreadthFirst extends Solution {

    ArrayDeque<Node> breadthWorklist;
    ArrayList<Node> pioneers;
    
    BreadthFirst(ArrayList<Edge> t, Node s, Node g) {
        super(t, s, g);
        this.breadthWorklist = new ArrayDeque<Node>();
        this.breadthWorklist.addFirst(s);
        this.pioneers = new ArrayList<Node>();
        this.pioneers.add(s);
    }
    
    //EFFECT: Undoes all of the progress currently made by this breadth first search
    void restart(ArrayList<Edge> newTree) {
        super.restart(newTree);
        this.breadthWorklist = new ArrayDeque<Node>();
        this.breadthWorklist.addFirst(start);
        this.pioneers = new ArrayList<Node>();
        this.pioneers.add(start);
    }
    
    //EFFECT: Advances every branch of this breadth first search by one turn
    void advance() {
        ArrayList<Node> oldPioneers = this.pioneers;
        while (oldPioneers.size() > 0 && finalSolution.size() == 0) {
            this.slowAdvance();
            ArrayList<Node> stillAlive = new ArrayList<Node>();
            for (Node n : oldPioneers) {
                if (!this.visited.contains(n)) {
                    stillAlive.add(n);
                }
            }
            oldPioneers = stillAlive;
        }
    }
    
    //EFFECT: advances this breadth first search by one turn
    void slowAdvance() {
        if (breadthWorklist.size() > 0 && finalSolution.size() == 0) {
            Node next = breadthWorklist.removeFirst();
            if (visited.contains(next)) {
                pioneers.remove(next);
                return;
            }
            else if (goal == next) {
                pioneers.clear();
                this.reconstruct(next);
                return;
            }
            else {
                visited.add(next);
                pioneers.remove(next);
                ArrayList<Node> neighbors = this.getNeighbors(next);
                for (Node n : neighbors) {
                    cameFrom.putIfAbsent(n.name, next);
                    breadthWorklist.addLast(n);
                    if (!visited.contains(n)) {
                        pioneers.add(n);
                    }
                }
            }
        }
    }
    
    //EFFECT: Draws this breadth first search onto the given background
    void addImages(WorldScene bkg) {
        super.addImages(bkg);
        for (Node n : this.pioneers) {
            n.makeBackground(bkg, Color.BLUE);
        }
    }

}
