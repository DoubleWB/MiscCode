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
  return  [s, s, w, s, w, w, s, w]

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
  # util.raiseNotDefined()

  stack = []
  visited = []
  stack.append((problem.getStartState(), '', 0))
  visited.append(problem.getStartState())

  return recursiveDepthFirst(stack, visited, problem)

def recursiveDepthFirst(stack, visited, problem):
  currentNode = stack.pop()
  if(problem.isGoalState(currentNode[0])):
     return []
  else:
     successors = problem.getSuccessors(currentNode[0])
     for node in successors:
       if(node[0] not in visited):
         stack.append(node)
         visited.append(node[0])
         bestPath = recursiveDepthFirst(stack, visited, problem)
         if(bestPath != None):
           bestPath.insert(0, node[1])
           return bestPath


def breadthFirstSearch(problem):
  "Search the shallowest nodes in the search tree first. [p 81]"
  "*** YOUR CODE HERE ***"
  # util.raiseNotDefined()
  from collections import deque
  queue = deque([(problem.getStartState(), '', 0)])
  visited = []
  visited.append(problem.getStartState())
  sequence = []

  return recursiveBreadthFirst(queue, visited, problem)
  
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
         bestPath.insert(0, node[1])
         return bestPath
    
def uniformCostSearch(problem):
    currentNode = (problem.getStartState(), [])
    frontier = {}
    frontier[0] = currentNode
    visited = []
    while(frontier):
        print len(frontier)
        print 'element(s) left'
        lowest = min(frontier.keys())
        print 'lowest directly below'
        print frontier[lowest] 
        print ' =================='
        currentNode = frontier.pop(lowest)
        if(problem.isGoalState(currentNode[0])):
            print "Goal Reached"
            print ' =================='
            return currentNode[1]
        visited.append(currentNode[0])
        print "working with node:"
        print currentNode[0]
        print 'with children:'
        print problem.getSuccessors(currentNode[0])
        print ' =================='
        for child in problem.getSuccessors(currentNode[0]):
            node = (child[0], [child [1]])
            if(node[0] in visited):
                print 'Failed with node:'
                print node
                print 'and duplicate'
                print visited[visited.index(node[0])]
            if(node[0] not in visited):
                path = currentNode[1]
                path = path + node[1]
                # print 'path directly below'
                # print currentNode[1]
                # print path
                # print ' =================='
                if(any(problem.getCostOfActions(path) == k for k in frontier.iterkeys())):
                    frontier[problem.getCostOfActions(path) + .0000001] = (node[0], path)
                    print "*** FOUND SAME COST, ARTIFICIALLY ALTERING COST"
                else:
                    frontier[problem.getCostOfActions(path)] = (node[0], path)
                print 'path cost directly below'
                print problem.getCostOfActions(path)
                print ' =================='
                print 'added to frontier, directly below'
                print node
                print ' =================='
            '''if((any(node[0] == v[0] for v in frontier.itervalues())) and next((k for k, v in frontier.iteritems() if node[0] == v[0]), None) > problem.getCostOfActions(currentNode[1] + (node[1]))):
                print "REPLACING"
                print frontier[next((k for k, v in frontier.iteritems() if node[0] == v[0]), None)]
                print "with"
                print node
                del frontier[next((k for k, v in frontier.iteritems() if node[0] == v[0]), None)]
                path = currentNode[1] + (node[1])
                #print 'path directly below'
                #print path
                #print ' =================='
                print 'path cost directly below'
                print problem.getCostOfActions(path)
                print ' =================='
                frontier[problem.getCostOfActions(path)] = (node[0], path)
                print 'replaced in frontier, directly below'
                print node
                print ' ==================' '''
        print frontier
    print 'FAIL returning best guess'
    return currentNode[1] 

def orderByCost(stack, paths):
  while(paths):
    highest = 0
    for key in paths.keys():
       if(key > highest):
         highest = key
    stack.append(paths[highest])
    del paths[key]

def nullHeuristic(state, problem=None):
  """
  A heuristic function estimates the cost from the current state to the nearest
  goal in the provided SearchProblem.  This heuristic is trivial.
  """
  return 0

'''def aStarSearch(problem, heuristic=nullHeuristic):
  "Search the node that has the lowest combined cost and heuristic first."
  "*** YOUR CODE HERE ***"
  currentNode = (problem.getStartState(), [])
  frontier = {}
  frontier[0 + heuristic(currentNode[0], problem)] = currentNode
  visited = []
  while(frontier):
        print len(frontier)
        print 'element(s) left'
        lowest = min(frontier.keys())
        print 'lowest directly below'
        print frontier[lowest] 
        print ' =================='
        currentNode = frontier.pop(lowest)
        if(problem.isGoalState(currentNode[0])):
            print "Goal Reached"
            print ' =================='
            return currentNode[1]
        visited.append(currentNode[0])
        print "working with node:"
        print currentNode[0]
        print 'with children:'
        print problem.getSuccessors(currentNode[0])
        print ' =================='
        for child in problem.getSuccessors(currentNode[0]):
            node = (child[0], [child [1]])
            path = currentNode[1]
            path = path + node[1]
            score = problem.getCostOfActions(path)
            if(node[0] in visited):
                print 'Failed with node:'
                print node[0]
                print 'and duplicate'
                print visited[visited.index(node[0])]
            if(node[0] in visited and score >= next((k for k, v in frontier.iteritems() if node[0] == v[0]), None)):
                continue
            if(not(any(node[0] == v[0] for v in frontier.itervalues()))):
                if(any(problem.getCostOfActions(path) + heuristic(node[0], problem) == k for k in frontier.iterkeys())):
                    frontier[problem.getCostOfActions(path) + heuristic(node[0], problem) + .0000001] = (node[0], path)
                    print "*** FOUND SAME COST, ARTIFICIALLY ALTERING COST"
                print 'added to frontier, directly below'
                print node[0]
                print ' =================='
                frontier[score + heuristic(node[0], problem)] = (node[0], path)
            """if((any(node[0] == v[0] for v in frontier.itervalues())) and score < next((k for k, v in frontier.iteritems() if node[0] == v[0]), None)):
                print "REPLACING"
                print frontier[next((k for k, v in frontier.iteritems() if node[0] == v[0]), None)]
                print "with"
                print node[0]
                print ' =================='
                del frontier[next((k for k, v in frontier.iteritems() if node[0] == v[0]), None)]
                path = currentNode[1] + (node[1])
                frontier[score + heuristic(node[0], problem)] = (node[0], path)"""
        print 'Current Frontier'
        print frontier
        print ' =================='
  print 'FAILURE'
  return currentNode[1]'''

def aStarSearch(problem, heuristic=nullHeuristic):
    "Search the node that has the lowest combined cost and heuristic first."
    "*** YOUR CODE HERE ***"
    current = (problem.getStartState(), '',0)
    closedSet = []
    openSet = [current]
    cameFrom = {}
    g_score = {}
    f_score = {}
    g_score[current[0]] = 0
    f_score[current[0]] = g_score[current[0]]+heuristic(current[0], problem)
    while(openSet):
        print 'OPEN SET SIZE'
        print len(openSet)
        lowestIndex = getLowestElement(openSet, f_score)
        current = openSet.pop(lowestIndex)
        print 'Working with'
        print current
        print "=============="
        if(problem.isGoalState(current[0])):
            print 'goal reached'
            return pathify(reconstructPath(cameFrom, current))
        closedSet.append(current[0])
        for node in problem.getSuccessors(current[0]):
            tentativeGScore = g_score[current[0]] + problem.getCostOfActions([node[1]])
            if(node[0] in closedSet and tentativeGScore>= g_score[node[0]]):
                print 'not Added:'
                print node
                print '=============='
                continue
            if(node not in openSet or tentativeGScore < g_score[node[0]]):
                print 'Added'
                print node
                print '=============='
                cameFrom[node] = current
                g_score[node[0]] = tentativeGScore
                f_score[node[0]] = g_score[node[0]]+heuristic(node[0],problem)
                if(node not in openSet):
                    openSet.append(node)
    print 'failure'
    return pathify(reconstructPath(cameFrom, current))

def reconstructPath(came_from, current):
    if(current in came_from):
        p = reconstructPath(came_from, came_from[current])
        return p + current
    else:
        return current
    
def pathify(list):
    newList = []
    for node in list:
        if(node == 'East' or node == 'West' or node == 'North' or node == 'South'):
            newList.append(node)
    print "NEW LIST"
    print newList
    print "===================="
    return newList
    """newList = newList+[node[1]]
    return filter(lambda a: a != '', newList)"""

def getLowestElement(list, f_score):
    lowest = f_score[(list[0])[0]]
    lowestK = 0
    for v in list:
        if(f_score[v[0]]<lowest):
            lowest = f_score[v[0]]
            lowestK = list.index(v)
    print lowest
    return lowestK
# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch
