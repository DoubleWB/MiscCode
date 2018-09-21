import java.util.ArrayList;
import java.util.HashMap;
import java.util.PriorityQueue;
import java.util.Scanner;


public class WeddingPlanning {
	
	private static int numCities = 0;
	private static int numEdges = 0;
	private static HashMap<Integer, ArrayList<Edge>> revGraph = new HashMap <Integer, ArrayList<Edge>>();
	private static HashMap<Integer, Integer> distances = new HashMap<Integer, Integer>();
	private static int startCity = 0;

	public static void scanData() {
		Scanner scan = new Scanner(System.in);
		numCities = scan.nextInt();
		numEdges = scan.nextInt();
		startCity = scan.nextInt();
	    int lineCount = 0;
	    while (lineCount < numEdges) {
	        int start = scan.nextInt();
	        int end = scan.nextInt();
	        int weight = scan.nextInt();
        	if (!(revGraph.containsKey(end))) {
        		revGraph.put(end, new ArrayList<Edge>());
        		revGraph.get(end).add(new Edge(end, start, weight));
        	}
        	else {
        		revGraph.get(end).add(new Edge(end, start, weight));
        	}
	        lineCount++;
	    }
	}

	public static void djikstra() {
	    ArrayList<Integer> visited = new ArrayList<Integer>();
	    Heap priorityQueue = new Heap();
	    distances.put(startCity, 0);// initialize distances
	    visited.add(startCity);
	    if (revGraph.containsKey(startCity)) {
	    	for (Edge e : revGraph.get(startCity)) {
	        	priorityQueue.add(e, e.weight);
	    	}
	    }
	    while (priorityQueue.size() != 0) {
	        Edge next = priorityQueue.extractMin();
	        if (visited.contains(next.end)) { //node we're traveling to already visited
	            continue;
	        }
	        else {
	            visited.add(next.end);
	            distances.put(next.end, distances.get(next.start) + next.weight); //remember the shortest path to this node
	            if (revGraph.containsKey(next.end)){
	            	for (Edge e : revGraph.get(next.end)) {
	                	priorityQueue.add(e, distances.get(next.end) + e.weight);
	            	}
	            }
	        }
	    }
	}
	
	public static void cheatDjikstra() {
	    ArrayList<Integer> visited = new ArrayList<Integer>();
	    PriorityQueue<Edge> priorityQueue= new PriorityQueue<Edge>();
	    distances.put(startCity, 0);// initialize distances
	    visited.add(startCity);
	    if (revGraph.containsKey(startCity)) {
	    	for (Edge e : revGraph.get(startCity)) {
	        	priorityQueue.add(e);
	    	}
	    }
	    while (priorityQueue.size() != 0) {
	        Edge next = priorityQueue.poll();
	        if (visited.contains(next.end)) { //node we're traveling to already visited
	            continue;
	        }
	        else {
	            visited.add(next.end);
	            distances.put(next.end, next.weight); //remember the shortest path to this node
	            if (revGraph.containsKey(next.end)){
	            	for (Edge e : revGraph.get(next.end)) {
	                	priorityQueue.add(new Edge(e.start, e.end, distances.get(e.start) + e.weight));
	            	}
	            }
	        }
	    }
	}
	
	public static void pDjikstra() {
	    ArrayList<Integer> visited = new ArrayList<Integer>();
	    PointHeap priorityQueue = new PointHeap();
	    distances.put(startCity, 0);// initialize distances
	    visited.add(startCity);
	    if (revGraph.containsKey(startCity)) {
	    	for (Edge e : revGraph.get(startCity)) {
	    		distances.put(e.end, e.weight);
	        	priorityQueue.add(e.end, e.weight);
	    	}
	    }
	    while (priorityQueue.size() != 0) {
	        int next = priorityQueue.extractMin();
            //visited[next.end] = true; // we've visited this node now
            visited.add(next);
            //distances.put(next.end, distances.get(next.start) + next.weight); //remember the shortest path to this node
            if (revGraph.containsKey(next)){
            	for (Edge e : revGraph.get(next)) {
            		if (!visited.contains(e.end)) {
            			distances.put(e.end, distances.get(next) + e.weight);
                		priorityQueue.add(e.end, distances.get(next) + e.weight);
            		}
            	}
            }
	    }
	}
	
	public static void allDjikstra() {
	    ArrayList<Integer> visited = new ArrayList<Integer>();
	    PointHeap priorityQueue = new PointHeap();
	    for (int i = 1; i <= numCities; ++i){
	    	distances.put(i, 999999);
	    }
	    distances.put(startCity, 0);
	    visited.add(startCity);
	    if (revGraph.containsKey(startCity)) {
	    	for (Edge e : revGraph.get(startCity)) {
	    		distances.put(e.end, e.weight);
	        	priorityQueue.add(e.end, e.weight);
	    	}
	    }
	    while (priorityQueue.size() != 0) {
	        int next = priorityQueue.extractMin();
            visited.add(next);
            if (revGraph.containsKey(next)){
            	for (Edge e : revGraph.get(next)) {
            		if (!visited.contains(e.end)) {
            			distances.put(e.end, distances.get(next) + e.weight);
                		priorityQueue.add(e.end, distances.get(next) + e.weight);
            		}
            	}
            }
	    }
	}

	public static void fakeData() {
	    numCities = 50000;
	    numEdges = 60000;
	    startCity = (int)(Math.random() *  50000) + 1; 
	    int lineCount = 0;
	    while (lineCount < numEdges) {
	        int weight = (int)(Math.random() * 5000) + 1;
	        //System.out.println(weight);
	        int start = (int)(Math.random() * 50000) + 1;
	        //System.out.println(start);
	        int end = (int)(Math.random() * 50000) + 1;
 			//System.out.println(end);
        	if (!(revGraph.containsKey(end))) {
        		revGraph.put(end, new ArrayList<Edge>());
        		revGraph.get(end).add(new Edge(end, start, weight));
        	}
        	else {
        		revGraph.get(end).add(new Edge(end, start, weight));
        	}
	        lineCount++;
	    }
	} 

	public static void main(String[] args) {
		scanData();
	    //fakeData(); //LOL
	    //cheatDjikstra();
		allDjikstra();
	    for (int i = 1; i <= numCities; ++i) {
	    	if (distances.get(i) != 999999) {
	        	System.out.print(distances.get(i) + " ");
	        }
	        else {
	        	System.out.print("-1 ");
	        }
	    }
	}
	
	public static void testHeap() {
	    Edge e = new Edge(1, 2, 1);
	    Edge e1 = new Edge(2, 3, 2);
	    Edge e2 = new Edge(3, 4, 3);
	    Edge e3 = new Edge(4, 5, 4); 
	    Edge e4 = new Edge(5, 6, 2);
	    Edge e5 = new Edge(6, 7, 5);
	    Edge e6 = new Edge(7, 8, 3);
	    Edge e7 = new Edge(8, 9, 4);
	    Edge e8 = new Edge(9, 10, 6);
	    Heap h = new Heap();
	    h.add(e1, e1.weight);
	    h.add(e2, e2.weight);
	    h.add(e3, e3.weight);
	    h.add(e4, e4.weight);
	    h.add(e5, e5.weight);
	    h.add(e6, e6.weight);
	    h.add(e7, e7.weight);
	    h.add(e8, e8.weight);
	    while (h.size() > 0) {
	    	System.out.println(h.extractMin().weight);
	    }
	}
}
 
class Edge implements Comparable<Edge>{
	public int start;
	public int end;
	public int weight;
	
	public Edge(int s, int e, int w) {
		this.start = s;
		this.end = e;
		this.weight = w;
	}
	@Override
	public boolean equals(Object o) {
		if (!(o instanceof Edge)) {
			return false;
		}
		else {
			Edge other = (Edge)o;
			return (this.start == other.start) 
					&& (this.end == other.end) 
					&& (this.weight == other.weight);
		}
	}
	@Override
	public int hashCode() {
		return ((Integer)this.start).hashCode() + 
				(10 * ((Integer)this.end).hashCode()) + 
				(100 * ((Integer)this.weight).hashCode());
	}
	
	@Override
	public String toString() {
		return this.start + " -> " + this.end + ": " + this.weight + ";";
	}
	
	@Override
	public int compareTo(Edge e) {
		return this.weight - e.weight;
	}
	
}

class PointHeap {
	private ArrayList<Integer> h;
	private HashMap<Integer, Integer> values;
	
	public PointHeap() {
		h = new ArrayList<Integer>();
		values = new HashMap<Integer, Integer>();
	}
	
	public void add(int item, int v) {
		if (values.containsKey(item)) {
			if (values.get(item) < v) {
				return;
			}
			else {
				values.put(item, v);
				int currentIndex = h.indexOf(item);
	        	while (h.size() > 1 && !((values.get(h.get(childToParent(currentIndex) - 1))
	        			<= values.get(h.get(currentIndex - 1))))) {
	            	hSwap(currentIndex - 1, childToParent(currentIndex) - 1);
	            	currentIndex = childToParent(currentIndex);
	        	}
			}
		}
		else {
			h.add(item);
			values.put(item, v);
        	int currentIndex = h.size();
        	//System.out.println(currentIndex);
        	//System.out.println(childToParent(currentIndex) - 1);
        	while (h.size() > 1 && !((values.get(h.get(childToParent(currentIndex) - 1))
        			<= values.get(h.get(currentIndex - 1))))) {
            	hSwap(currentIndex - 1, childToParent(currentIndex) - 1);
            	currentIndex = childToParent(currentIndex);
        	}
		}
    }
	
	public int extractMin() {
		//System.out.println(this);
        int min = h.get(0);
        //System.out.println("Current min: " + min + " with size " + h.size());
        int currentIndex = 1;
        hSwap(0, h.size() - 1);
        h.remove(h.size() - 1);
        //System.out.println(this);
        values.remove(min);
        if (h.size() > 2) {
            while (!((values.get(h.get(currentIndex - 1)) <= values.get(h.get(parentToLeftChild(currentIndex) - 1)))
                    && (values.get(h.get(currentIndex - 1)) <= values.get(h.get(parentToRightChild(currentIndex) - 1))))) {
                int newIndex = 0;
            	if (values.get(h.get(parentToLeftChild(currentIndex) - 1)) <= values.get(h.get(parentToRightChild(currentIndex) - 1))) {
                	newIndex = parentToLeftChild(currentIndex);
            	}
            	else {
                	newIndex = parentToRightChild(currentIndex);
            	}
            	hSwap(currentIndex - 1, newIndex - 1);
            	currentIndex = newIndex;
            	if (parentToLeftChild(currentIndex) - 1 >= h.size()) { // Cannot swap any lower
            		//System.out.println("Both too big");
                	break; 
                }
                else if (parentToRightChild(newIndex) - 1 >= h.size()) { // may be able to swap with left only
                	//System.out.println("Right too big");
                	if (!(values.get(h.get(currentIndex - 1)) <= values.get(h.get(parentToLeftChild(currentIndex) - 1)))) {
                		hSwap(currentIndex - 1, parentToLeftChild(currentIndex) - 1);
                		break;
                	}
                	break;
                }
        	}
        }
        else if (h.size() == 2) {
        	if (!(values.get(h.get(0)) <= values.get(h.get(1)))) {
        		hSwap(0, 1);
        	}
        }
        return min;
    }
	
    public int size() {
        return h.size();
    }
	
	private int childToParent(int childIndex) {
	    return (childIndex + 1)/2;
	}

	private int parentToLeftChild(int parentIndex) {
	    return ((parentIndex) * 2);
	}

	private int parentToRightChild(int parentIndex) {
	    return (((parentIndex) * 2) + 1);
	}
	
	private void hSwap(int first, int second) {
	    int temp = h.get(first);
	    h.set(first, h.get(second));
	    h.set(second, temp);
	}
}

class Heap {
	private ArrayList<Edge> h;
	private HashMap<Edge, Integer> values;
	
	public Heap() {
		h = new ArrayList<Edge>();
		values = new HashMap<Edge, Integer>();
	}
	
	public void add(Edge item, int v) {
		h.add(item);
		values.put(item, v);
        int currentIndex = h.size();
        //System.out.println(currentIndex);
        //System.out.println(childToParent(currentIndex) - 1);
        while (h.size() > 1 && !((values.get(h.get(childToParent(currentIndex) - 1))
        		<= values.get(h.get(currentIndex - 1))))) {
            hSwap(currentIndex - 1, childToParent(currentIndex) - 1);
            currentIndex = childToParent(currentIndex);
        }
    }
	
	public Edge extractMin() {
		//System.out.println(this);
        Edge min = h.get(0);
        //System.out.println("Current min: " + min + " with size " + h.size());
        int currentIndex = 1;
        hSwap(0, h.size() - 1);
        h.remove(h.size() - 1);
        //System.out.println(this);
        values.remove(min);
        if (h.size() > 2) {
            while (!((values.get(h.get(currentIndex - 1)) <= values.get(h.get(parentToLeftChild(currentIndex) - 1)))
                    && (values.get(h.get(currentIndex - 1)) <= values.get(h.get(parentToRightChild(currentIndex) - 1))))) {
                int newIndex = 0;
            	if (values.get(h.get(parentToLeftChild(currentIndex) - 1)) <= values.get(h.get(parentToRightChild(currentIndex) - 1))) {
                	newIndex = parentToLeftChild(currentIndex);
            	}
            	else {
                	newIndex = parentToRightChild(currentIndex);
            	}
            	hSwap(currentIndex - 1, newIndex - 1);
            	currentIndex = newIndex;
            	if (parentToLeftChild(currentIndex) - 1 >= h.size()) { // Cannot swap any lower
            		//System.out.println("Both too big");
                	break; 
                }
                else if (parentToRightChild(newIndex) - 1 >= h.size()) { // may be able to swap with left only
                	//System.out.println("Right too big");
                	if (!(values.get(h.get(currentIndex - 1)) <= values.get(h.get(parentToLeftChild(currentIndex) - 1)))) {
                		hSwap(currentIndex - 1, parentToLeftChild(currentIndex) - 1);
                		break;
                	}
                	break;
                }
        	}
        }
        else if (h.size() == 2) {
        	if (!(values.get(h.get(0)) <= values.get(h.get(1)))) {
        		hSwap(0, 1);
        	}
        }
        return min;
    }
	
	public String toString() {
		String output = "(";
		for (Edge e : h) {
			output += e + " ";
		}
		return output+")";
	}
	
    public int size() {
        return h.size();
    }
	
	private int childToParent(int childIndex) {
	    return (childIndex + 1)/2;
	}

	private int parentToLeftChild(int parentIndex) {
	    return ((parentIndex) * 2);
	}

	private int parentToRightChild(int parentIndex) {
	    return (((parentIndex) * 2) + 1);
	}
	
	private void hSwap(int first, int second) {
	    Edge temp = h.get(first);
	    h.set(first, h.get(second));
	    h.set(second, temp);
	}
}