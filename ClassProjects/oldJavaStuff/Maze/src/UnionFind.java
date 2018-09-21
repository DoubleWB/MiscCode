import java.util.*;

import tester.Tester;

class UnionFind {
    
    HashMap<String, String> representatives;
    
    UnionFind(ArrayList<ArrayList<Node>> nodes) {
        representatives = new HashMap<String, String>();
        for (ArrayList<Node> row : nodes) {
            for (Node n : row) {
                representatives.put(n.name, n.name);
            }
        }
    }
    
    //Returns the representative of the given key
    //EFFECT: Changes the representatives of the key if its path can be compressed
    String findRep(String key) {
        String curRep = representatives.get(key);
        String origKey = key;
        while (!curRep.equals(key)) {
            key = curRep;
            curRep = representatives.get(curRep);
        }
        representatives.put(origKey, curRep);
        return curRep;
    }
    
    //EFFECT: unifies two blobs under the given two representatives into one blob
    void union(String rep1, String rep2) {
        representatives.put(rep1, rep2);
    }
    
    //Returns true if this UnionFind consists of only one union
    boolean isOneBlob() {
        String onlyRep = "";
        for (String key : representatives.keySet()) {
            if (onlyRep.equals("")) {
                onlyRep = findRep(key);
            }
            else if (!onlyRep.equals(findRep(key))) {
                return false;
            }
        }
        return true;
    }
}

class ExamplesUnionFind {
    
    void testInitialize(Tester t) {
        MazeWorld w = new MazeWorld(2, 2, "s");
        UnionFind u = new UnionFind(w.nodes);
        t.checkExpect(u.representatives.size(), 4);
        for (String key : u.representatives.keySet()) {
            t.checkExpect(u.findRep(key), key);
        }
    }
    
    void testFunctions(Tester t) {
        //Tests union, findRep, and isOneBlob as the tree comes together
        MazeWorld w = new MazeWorld(2, 2, "s");
        UnionFind u = new UnionFind(w.nodes);
        u.union("0|0", "0|1");
        t.checkExpect(u.findRep("0|1"), "0|1");
        t.checkExpect(u.findRep("0|0"), "0|1");
        t.checkExpect(u.isOneBlob(), false);
        u.union("0|1", "1|0");
        // checking path compression
        t.checkExpect(u.representatives.get("0|0"), "0|1"); 
        t.checkExpect(u.findRep("0|0"), "1|0");
        t.checkExpect(u.representatives.get("0|0"), "1|0");
        t.checkExpect(u.isOneBlob(), false);
        //last connection
        u.union("1|1", "1|0");
        t.checkExpect(u.isOneBlob(), true);
    }
}
