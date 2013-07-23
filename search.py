# search.py
# ---------
# Licensing Information: Please do not distribute or publish solutions to this
# project. You are free to use and extend these projects for educational
# purposes. The Pacman AI projects were developed at UC Berkeley, primarily by
# John DeNero (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# For more info, see http://inst.eecs.berkeley.edu/~cs188/sp09/pacman.html

"""
In search.py, you will implement generic search algorithms which are called 
by Pacman agents (in searchAgents.py).
"""

import util

global sequenceBF
sequenceBF = []

class SearchProblem:
  """
  This class outlines the structure of a search problem, but doesn't implement
  any of the methods (in object-oriented terminology: an abstract class).
  
  You do not need to change anything in this class, ever.
  """
  
  def getStartState(self):
	 """
	 Returns the start state for the search problem 
	 """
	 util.raiseNotDefined()
	
  def isGoalState(self, state):
	 """
	   state: Search state
	
	 Returns True if and only if the state is a valid goal state
	 """
	 util.raiseNotDefined()

  def getSuccessors(self, state):
	 """
	   state: Search state
	 
	 For a given state, this should return a list of triples, 
	 (successor, action, stepCost), where 'successor' is a 
	 successor to the current state, 'action' is the action
	 required to get there, and 'stepCost' is the incremental 
	 cost of expanding to that successor
	 """
	 util.raiseNotDefined()

  def getCostOfActions(self, actions):
	 """
	  actions: A list of actions to take
 
	 This method returns the total cost of a particular sequence of actions.  The sequence must
	 be composed of legal moves
	 """
	 util.raiseNotDefined()
		   

def tinyMazeSearch(problem):
  """
  Returns a sequence of moves that solves tinyMaze.  For any other
  maze, the sequence of moves will be incorrect, so only use this for tinyMaze
  """
  from game import Directions
  s = Directions.SOUTH
  w = Directions.WEST
  return  [s,s,w,s,w,w,s,w]

def depthFirstSearch(problem):
  """
  Search the deepest nodes in the search tree first [p 85].
  
  Your search algorithm needs to return a list of actions that reaches
  the goal.  Make sure to implement a graph search algorithm [Fig. 3.7].
  
  To get started, you might want to try some of these simple commands to
  understand the search problem that is being passed in:
  
  print "Start:", problem.getStartState()
  print "Is the start a goal?", problem.isGoalState(problem.getStartState())
  print "Start's successors:", problem.getSuccessors(problem.getStartState())
  """
  #util.raiseNotDefined()

  stack = [] # initialize stack
  visited = [] # initialize visited
  stack.append((problem.getStartState(),'',0)) # Starts both visited and stack with start node
  visited.append(problem.getStartState())

  return recursiveDepthFirst(stack, visited,problem) 

def recursiveDepthFirst(stack, visited, problem):
  currentNode = stack.pop() #gets node off of stack
  if(problem.isGoalState(currentNode[0])):
     return [] # goal reached
  else:
     successors = problem.getSuccessors(currentNode[0])
     for node in successors:
       if(node[0] not in visited):
         stack.append(node)
         visited.append(node[0])
         bestPath = recursiveDepthFirst(stack, visited, problem) # If a node is adjacent and unvisited, add to visited and stack, as well as set a variable, bestPath, to the next recursion
         if(bestPath != None): # If the goal is not reached, bestPath will be none, and no action will be taken. Otherwise, starts a backtrace of the calls to the goal node, thus building the path required
           bestPath.insert(0,node[1]) #Backtrace
           return bestPath


def breadthFirstSearch(problem):
  "Search the shallowest nodes in the search tree first. [p 81]"
  "*** YOUR CODE HERE ***"
  #util.raiseNotDefined()
  from collections import deque
  queue = deque([(problem.getStartState(),'',0)])
  visited = []
  visited.append(problem.getStartState())
  sequence = []

  return recursiveBreadthFirst(queue, visited, problem)
  
  #both BreadthFirst and DepthFirst produce the same output, because the stack is the same as the queue, because they only have one item in them at a time. The below is my failed attempt to fix it, ignore for the meantime
  """pathDirs = []
  comparisonNode = path.pop
  pathDirs.insert(0,(comparisonNode[1]))
  while(path):
    lowestIndex = len(path)
    nextNode = []
    successors = problem.getSuccessors(comparisonNode[0])
    for node in path:
      if(path.index(node)<lowestIndex and (node in successors)):
        lowestIndex = path.index(node)
        nextNode = node
    for i in range (lowestIndex, path.index(comparisonNode)+1):
      path.pop(i)
    comparisonNode = nextNode
    pathDirs.insert(0, comparisonNode[1])
  return pathDirs"""

def recursiveBreadthFirst(queue, visited, problem):
  currentNode = queue.popleft()
  if(problem.isGoalState(currentNode[0])):
    return []
  else:
    successors = problem.getSuccessors(currentNode[0])
    for node in successors:
      if(node[0] not in visited):
        queue.append(node)
        visited.append(node[0])
        bestPath = recursiveBreadthFirst(queue, visited, problem)
        if(bestPath != None):
         bestPath.insert(0,node[1])
         return bestPath
    
	  
def uniformCostSearch(problem):
  "Search the node of least total cost first. "
  visited = []
  stack = []
  stack.append((problem.getStartState(),'',0))
  visited.append(problem.getStartState())

  return recursiveUniformCost(stack, visited, append

def nullHeuristic(state, problem=None):
  """
  A heuristic function estimates the cost from the current state to the nearest
  goal in the provided SearchProblem.  This heuristic is trivial.
  """
  return 0

def aStarSearch(problem, heuristic=nullHeuristic):
  "Search the node that has the lowest combined cost and heuristic first."
  "*** YOUR CODE HERE ***"
  util.raiseNotDefined()
	
  
# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch
