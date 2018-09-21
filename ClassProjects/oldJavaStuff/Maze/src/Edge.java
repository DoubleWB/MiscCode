import java.awt.Color;

import javalib.impworld.WorldScene;
import javalib.worldimages.*;

class Edge {
    
    Node from;
    Node to;
    int weight;
    
    Edge(Node f, Node t, int w) {
        this.from = f;
        this.to = t;
        this.weight = w;
    }
    
    // EFFECT: adds image of this edge to the given background
    void makeImage(WorldScene bkg) {
        Utility u = new Utility();
        double len = u.getCellSize() - 2; // Don't cut into the edges of the square 
        WorldImage edge = new LineImage(new Posn((int) len * (this.to.y - this.from.y), 
                (int) len * (this.to.x - this.from.x)), Color.WHITE);
        int locX = (int) ((this.from.x + .5 + ((this.to.x - this.from.x) / 2.0)) * u.getCellSize());
        int locY = (int) ((this.from.y + .5 + ((this.to.y - this.from.y) / 2.0)) * u.getCellSize());
        bkg.placeImageXY(edge, locX, locY);
        //if you want to show the paths, uncomment the following : 
        /*WorldImage path = new LineImage(new Posn((int) len * (this.to.x - this.from.x),
                (int) len * (this.to.y - this.from.y)), Color.GREEN);
        bkg.placeImageXY(path, locX, locY);*/
    }

}
