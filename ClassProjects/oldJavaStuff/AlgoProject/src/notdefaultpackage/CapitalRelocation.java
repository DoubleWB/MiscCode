package notdefaultpackage;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;
import java.util.Stack;
import java.util.Scanner;

public class CapitalRelocation {

	//globals
	private static int numCities = 0;
	private static int numEdges = 0;
	private static HashMap<Integer, ArrayList<Edge>> graph = new HashMap<Integer, ArrayList<Edge>>();
	private static HashMap<Integer, ArrayList<Edge>> revGraph = new HashMap<Integer, ArrayList<Edge>>();
	private static Stack<Integer> finishTimes = new Stack<Integer>();
	private static HashMap<Integer, Integer> vertToLeader = new HashMap<Integer, Integer>();
	private static ArrayList<Integer> unvisited = new ArrayList<Integer>();
	private static HashMap<Integer, ArrayList<Edge>> SCCgraph = new HashMap<Integer, ArrayList<Edge>>();
	private static HashMap<Integer, Integer> SCCsize = new HashMap<Integer, Integer>();

	public static void scanData() {
		Scanner scan = new Scanner(System.in);
		numCities = scan.nextInt();
		numEdges = scan.nextInt();
	    int lineCount = 0;
	    while (lineCount < numEdges) {
	        int start = scan.nextInt();
	        int end = scan.nextInt();
	        if (!graph.containsKey(start)) {
	            graph.put(start, new ArrayList<Edge>());
	            graph.get(start).add(new Edge(start, end));
	        }
	        else {
	            graph.get(start).add(new Edge(start, end));
	        }
	        if (!revGraph.containsKey(end)) {
	            revGraph.put(end, new ArrayList<Edge>());
	            revGraph.get(end).add(new Edge(end, start));
	        }
	        else {
	            revGraph.get(end).add(new Edge(end, start));
	        }
	        lineCount++;
	    }
	    for (int i = 1; i <= numCities; ++i) {
	        unvisited.add(i);
	    }
	}

	public static void dfsFirstPass() {
	    ArrayList<Integer> visited = new ArrayList<Integer>();
	    ArrayList<Integer> left = new ArrayList<Integer>(unvisited);
	    while (left.size() != 0) {
            dfsRecurseReverse(visited, left.get(0), left);
	    }
	}

	public static void dfsRecurseReverse(ArrayList<Integer> visited, int thisCity, ArrayList<Integer> left) {
	    visited.add(thisCity);
	    left.remove(left.indexOf(thisCity));
	    if (revGraph.containsKey(thisCity)) {
	    	for (Edge e : revGraph.get(thisCity)) {
	        	if (visited.contains(e.end)) {
	            	continue;
	        	}
	        	dfsRecurseReverse(visited, e.end, left);
	    	}
	    }
	    finishTimes.push(thisCity);
	}

	public static void dfsSecondPass() {
	    ArrayList<Integer> visited = new ArrayList<Integer>();
	    ArrayList<Integer> left = new ArrayList<Integer>(unvisited);
	    while (finishTimes.size() != 0) {
	        int latestCity = finishTimes.pop();
	        if (!visited.contains(latestCity)) {
	            dfsRecurse(visited, latestCity, latestCity);
	        }
	    }
	}

	public static void dfsRecurse(ArrayList<Integer> visited, int thisCity, int leader) {
		vertToLeader.put(thisCity, leader);	
		if (SCCsize.containsKey(leader)) {
			SCCsize.put(leader, SCCsize.get(leader) + 1);
		}
		else {
			SCCsize.put(leader, 1);
		}
		visited.add(thisCity);
	    if (graph.containsKey(thisCity)){
	    	for (Edge e : graph.get(thisCity)) {
	        	if (visited.contains(e.end)) {
	        		int endLead = vertToLeader.get(e.end);
	            	if (endLead != leader) {
	                	//betweenSCCS.add(e); // make it so that the endpoints are leaders only
	            		if (SCCgraph.containsKey(endLead)) {
	        	        	SCCgraph.get(endLead).add(new Edge(endLead, leader));
	        	        }
	        	        else {
	        	        	SCCgraph.put(endLead, new ArrayList<Edge>());
	        	        	SCCgraph.get(endLead).add(new Edge(endLead, leader));
	        	        }
	            	}
	            	continue;
	        	}
	        	dfsRecurse(visited, e.end, leader);
	    	}
	    }
	}


	public static int dfsThirdPass(Set<Integer> allLeaders) {
	    for(int l : allLeaders) {
	        ArrayList<Integer> visited = new ArrayList<Integer>();
	        dfsSCCRecurse(visited, l);
	        if (visited.size() == allLeaders.size()) {
	            return SCCsize.get(l);
	        }
	    }
	    return 0;
	}

	public static void dfsSCCRecurse(ArrayList<Integer> visited, int thisCity) {
	    visited.add(thisCity);
	    if (SCCgraph.containsKey(thisCity)) {
	    	for (Edge e : SCCgraph.get(thisCity)) {
	        	if (visited.contains(e.end)) {
	            	continue;
	        	}
	        	dfsSCCRecurse(visited, e.end);
	    	}
	    }
	}

	public static int max(Set<Integer> k, HashMap<Integer, Integer> sizes) {
		int max = 0;
		for (int i : k) {
			if (sizes.get(i) > max) {
				max = sizes.get(i);
			}
		}
		return max;
	}
	
	public static void main(String[] args) {
	    scanData();
	    dfsFirstPass();
	    dfsSecondPass();
	    //System.out.println(dfsThirdPass(SCCsize.keySet()));
	    System.out.println(max(SCCsize.keySet(), SCCsize));
	}

}

class Edge {
	public int start;
	public int end;
	
	public Edge(int s, int e) {
		this.start = s;
		this.end = e;
	}
	@Override
	public boolean equals(Object o) {
		if (!(o instanceof Edge)) {
			return false;
		}
		else {
			Edge other = (Edge)o;
			return (this.start == other.start) 
					&& (this.end == other.end);
		}
	}
	@Override
	public int hashCode() {
		return ((Integer)this.start).hashCode() + 
				(10 * ((Integer)this.end).hashCode());
	}
	
	public String toString() {
		return this.start + " -> " + this.end + ";";
	}
}
