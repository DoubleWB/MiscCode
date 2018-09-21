import java.awt.Color;
import java.util.ArrayList;

import javalib.impworld.WorldScene;

class Manual extends Solution {
    
    Node pioneer;
    
    Manual(ArrayList<Edge> t, Node s, Node g) {
        super(t, s, g);
        this.pioneer = s;    
    }
    
    //EFFECT: Undoes all of the progress currently made by this Manual solution
    void restart(ArrayList<Edge> newTree) {
        super.restart(newTree);
        this.pioneer = start;
    }

    //EFFECT: Advances this manual solution properly for the given input
    void advanceWithInput(String input) {
        ArrayList<Node> options = this.getNeighbors(this.pioneer);
        if (input.equals("up")) {
            for (Node n : options) {
                if (n.y == this.pioneer.y - 1) {
                    this.visited.add(pioneer);
                    this.cameFrom.putIfAbsent(n.name, pioneer);
                    this.pioneer = n;
                }
            }
        }
        if (input.equals("right")) {
            for (Node n : options) {
                if (n.x == this.pioneer.x + 1) {
                    this.visited.add(pioneer);
                    this.cameFrom.putIfAbsent(n.name, pioneer);
                    this.pioneer = n;
                }
            }
        }
        if (input.equals("down")) {
            for (Node n : options) {
                if (n.y == this.pioneer.y + 1) {
                    this.visited.add(pioneer);
                    this.cameFrom.putIfAbsent(n.name, pioneer);
                    this.pioneer = n;
                }
            }
        }
        if (input.equals("left")) {
            for (Node n : options) {
                if (n.x == this.pioneer.x - 1) {
                    this.visited.add(pioneer);
                    this.cameFrom.putIfAbsent(n.name, pioneer);
                    this.pioneer = n;
                }
            }
        }
        if (this.pioneer == goal) {
            this.reconstruct(pioneer);
        }
    }
    
    //EFFECT: Draws this manual solution onto the given background 
    void addImages(WorldScene bkg) {
        super.addImages(bkg);
        this.pioneer.makeBackground(bkg, Color.BLUE);
    }

}
