import java.awt.Color;

import javalib.impworld.WorldScene;
import javalib.worldimages.*;

class Node {
    
    String name;
    int x;
    int y;
    
    Node(int col, int row) {
        this.name = Integer.toString(col) + "|" + Integer.toString(row);
        this.x = col;
        this.y = row;
    }
    
    // EFFECT: adds image of this node to the given background
    void makeImage(WorldScene bkg) {
        Utility u = new Utility();
        int len = u.getCellSize();
        WorldImage node = new RectangleImage(len, len, OutlineMode.OUTLINE, Color.BLACK);
        int locX = (int) ((this.x + 0.5) * len);
        int locY = (int) ((this.y + 0.5) * len);
        bkg.placeImageXY(node, locX, locY);
    }
    
    // EFFECT: adds the given color to the background of this node, and draws it
    // onto the given background
    void makeBackground(WorldScene bkg, Color fill) {
        //+1's and -1's are small adjustments to make sure we don't cover the walls of the maze
        Utility u = new Utility();
        int len = u.getCellSize() - 1;
        WorldImage node = new RectangleImage(len, len, OutlineMode.SOLID, fill);
        int locX = (int) ((this.x + 0.5) * u.getCellSize()) + 1;
        int locY = (int) ((this.y + 0.5) * u.getCellSize()) + 1;
        bkg.placeImageXY(node, locX, locY);
    }

}
