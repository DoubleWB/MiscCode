# multiAgents.py
# --------------
# Licensing Information:  You are free to use or extend these projects for 
# educational purposes provided that (1) you do not distribute or publish 
# solutions, (2) you retain this notice, and (3) you provide clear 
# attribution to UC Berkeley, including a link to 
# http://inst.eecs.berkeley.edu/~cs188/pacman/pacman.html
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero 
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and 
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


from util import manhattanDistance
from game import Directions
import random, util

from game import Agent

class ReflexAgent(Agent):
    """
      A reflex agent chooses an action at each choice point by examining
      its alternatives via a state evaluation function.

      The code below is provided as a guide.  You are welcome to change
      it in any way you see fit, so long as you don't touch our method
      headers.
    """


    def getAction(self, gameState):
        """
        You do not need to change this method, but you're welcome to.

        getAction chooses among the best options according to the evaluation function.

        Just like in the previous project, getAction takes a GameState and returns
        some Directions.X for some X in the set {North, South, West, East, Stop}
        """
        # Collect legal moves and successor states
        legalMoves = gameState.getLegalActions()

        # Choose one of the best actions
        scores = [self.evaluationFunction(gameState, action) for action in legalMoves]
        bestScore = max(scores) #preferred working in costs than utilities
        bestIndices = [index for index in range(len(scores)) if scores[index] == bestScore]
        chosenIndex = random.choice(bestIndices) # Pick randomly among the best

        "Add more of your code here if you want to"

        return legalMoves[chosenIndex]

    def evaluationFunction(self, currentGameState, action):
        """
        Design a better evaluation function here.

        The evaluation function takes in the current and proposed successor
        GameStates (pacman.py) and returns a number, where higher numbers are better.

        The code below extracts some useful information from the state, like the
        remaining food (newFood) and Pacman position after moving (newPos).
        newScaredTimes holds the number of moves that each ghost will remain
        scared because of Pacman having eaten a power pellet.

        Print out these variables to see what you're getting, then combine them
        to create a masterful evaluation function.
        """
        # Useful information you can extract from a GameState (pacman.py)
        successorGameState = currentGameState.generatePacmanSuccessor(action)
        newPos = successorGameState.getPacmanPosition()
        newFood = successorGameState.getFood()
        newGhostStates = successorGameState.getGhostStates()
        newScaredTimes = [ghostState.scaredTimer for ghostState in newGhostStates]

        oldFood = currentGameState.getFood().asList()
        
        score = 0        
    
        if(action == Directions.STOP):
            score -= 9999999
        
        closest = 999999
        nextP = None
        for p in oldFood:
            dist = manhattanDistance(newPos, p)
            if (dist < closest):
                closest = dist
                nextP = p                        
        score += 1 if closest == 0 else 1.0/(closest)

        for g in newGhostStates:
            p = g.getPosition()
            s = g.scaredTimer
            if (manhattanDistance(newPos, p) == 0 and s == 0):
                score -= 9999999

        #print score
        return score


def scoreEvaluationFunction(currentGameState):
    """
      This default evaluation function just returns the score of the state.
      The score is the same one displayed in the Pacman GUI.

      This evaluation function is meant for use with adversarial search agents
      (not reflex agents).
    """
    return currentGameState.getScore()

class MultiAgentSearchAgent(Agent):
    """
      This class provides some common elements to all of your
      multi-agent searchers.  Any methods defined here will be available
      to the MinimaxPacmanAgent, AlphaBetaPacmanAgent & ExpectimaxPacmanAgent.

      You *do not* need to make any changes here, but you can if you want to
      add functionality to all your adversarial search agents.  Please do not
      remove anything, however.

      Note: this is an abstract class: one that should not be instantiated.  It's
      only partially specified, and designed to be extended.  Agent (game.py)
      is another abstract class.
    """

    def __init__(self, evalFn = 'scoreEvaluationFunction', depth = '2'):
        self.index = 0 # Pacman is always agent index 0
        self.evaluationFunction = util.lookup(evalFn, globals())
        self.depth = int(depth)

class MinimaxAgent(MultiAgentSearchAgent):
    """
      Your minimax agent (question 2)
    """

    def getMin(self, gameState, curDepth, index):
        if(curDepth == self.depth or gameState.isWin() or gameState.isLose()):
            return self.evaluationFunction(gameState)
        else:
            values = []
            if (index < gameState.getNumAgents() - 1): # go to another min layer
                for action in gameState.getLegalActions(index):
                    values.append(self.getMin(gameState.generateSuccessor(index, action), curDepth, index + 1))
                return min(values) if len(values) > 0 else 999999
            else:
                for action in gameState.getLegalActions(index):
                    values.append(self.getMax(gameState.generateSuccessor(index, action), curDepth + 1))    
                return min(values) if len(values) > 0 else 999999

    def getMax(self, gameState, curDepth):        
        if(curDepth == self.depth or gameState.isWin() or gameState.isLose()):
            return self.evaluationFunction(gameState)
        else:
            values = []
            for action in gameState.getLegalActions(0):
                values.append(self.getMin(gameState.generateSuccessor(0, action), curDepth, 1))            
        return max(values) if len(values) > 0 else -999999

    def getAction(self, gameState):
        """
          Returns the minimax action from the current gameState using self.depth
          and self.evaluationFunction.

          Here are some method calls that might be useful when implementing minimax.

          gameState.getLegalActions(agentIndex):
            Returns a list of legal actions for an agent
            agentIndex=0 means Pacman, ghosts are >= 1

          gameState.generateSuccessor(agentIndex, action):
            Returns the successor game state after an agent takes an action

          gameState.getNumAgents():
            Returns the total number of agents in the game
        """
        bestValue = -999999
        bestAction = None        
        for action in gameState.getLegalActions(0):
            v = self.getMin(gameState.generateSuccessor(0, action), 0, 1)
            if (v >= bestValue):
                bestValue = v
                bestAction = action
        return bestAction 
                
                        
        

class AlphaBetaAgent(MultiAgentSearchAgent):
    """
      Your minimax agent with alpha-beta pruning (question 3)
    """

    def getMin(self, gameState, alpha, beta, curDepth, index):
        if(curDepth == self.depth or gameState.isWin() or gameState.isLose()):
            return self.evaluationFunction(gameState)
        else:
            value = 999999
            if (index < gameState.getNumAgents() - 1): # go to another min layer
                for action in gameState.getLegalActions(index):
                    value = min(value, self.getMin(gameState.generateSuccessor(index, action), alpha, beta, curDepth, index + 1))
                    if (value < alpha):
                        return value
                    beta = min(beta, value)
                return value
            else:
                for action in gameState.getLegalActions(index):
                    value = min(value, self.getMax(gameState.generateSuccessor(index, action), alpha, beta, curDepth + 1))    
                    if (value < alpha):
                        return value
                    beta = min(beta, value)
                return value

    def getMax(self, gameState, alpha, beta, curDepth):        
        if(curDepth == self.depth or gameState.isWin() or gameState.isLose()):
            return self.evaluationFunction(gameState)
        else:
            value = -999999
            for action in gameState.getLegalActions(0):
                value = max(value, self.getMin(gameState.generateSuccessor(0, action), alpha, beta, curDepth, 1))
                if (value > beta):
                    return value
                alpha = max(alpha, value)            
        return value

    def getAction(self, gameState):
        """
          Returns the minimax action using self.depth and self.evaluationFunction
        """
        "*** YOUR CODE HERE ***"
        value = -999999
        bestAction = None
        alpha = -999999
        beta = 999999
        for action in gameState.getLegalActions(0):
            prunedScore = self.getMin(gameState.generateSuccessor(0, action), alpha, beta, 0, 1)            
            if (prunedScore > value):
                bestAction = action
                value = prunedScore
            if (value > beta):
                return bestAction
            alpha = max(alpha, value)            
        return bestAction

class ExpectimaxAgent(MultiAgentSearchAgent):
    """
      Your expectimax agent (question 4)
    """

    def getExpect(self, gameState, curDepth, index):
        if(curDepth == self.depth or gameState.isWin() or gameState.isLose()):
            return self.evaluationFunction(gameState)
        else:
            values = []
            if (index < gameState.getNumAgents() - 1): # go to another expect layer
                for action in gameState.getLegalActions(index):
                    values.append(self.getExpect(gameState.generateSuccessor(index, action), curDepth, index + 1))
                return sum(values)/len(values) if len(values) > 0 else 999999
            else:
                for action in gameState.getLegalActions(index):
                    values.append(self.getMax(gameState.generateSuccessor(index, action), curDepth + 1))    
                return sum(values)/len(values) if len(values) > 0 else 999999

    def getMax(self, gameState, curDepth):        
        if(curDepth == self.depth or gameState.isWin() or gameState.isLose()):
            return self.evaluationFunction(gameState)
        else:
            values = []
            for action in gameState.getLegalActions(0):
                values.append(self.getExpect(gameState.generateSuccessor(0, action), curDepth, 1))            
        return max(values) if len(values) > 0 else -999999

    def getAction(self, gameState):
        """
          Returns the expectimax action using self.depth and self.evaluationFunction

          All ghosts should be modeled as choosing uniformly at random from their
          legal moves.
        """
        "*** YOUR CODE HERE ***"
        bestValue = -999999
        bestAction = None        
        for action in gameState.getLegalActions(0):
            v = self.getExpect(gameState.generateSuccessor(0, action), 0, 1)
            if (v >= bestValue):
                bestValue = v
                bestAction = action
        return bestAction 

def betterEvaluationFunction(currentGameState):
    """
      Your extreme ghost-hunting, pellet-nabbing, food-gobbling, unstoppable
      evaluation function (question 5).

      DESCRIPTION
      I incur a boost to the score if pacman is closest to the greatest number of pellets (AKA the average of the distance to all of the pellets is the lowest.

      Then, to make sure that we don't die, I incur an equivalent negative cost to being close to greatest number of ghosts. This can mean that a ghost's random
      behaviors can make pac man cautious to enter a part of the map for a long time (if the ghost stays in a choke point around that area for a long time), but 
      it seems to keep Pacman safe and passes the autograder's average score threshold, so I'll consider it sufficient. There's an exceptionally high negative cost
      of coming into contact with a ghost - this is higher than any other cost (given that the map is not extremely large) so that pacman always avoids dying with 
      the highest priority. 

      Lastly, I incur a negative cost for the existence of uneaten power capsules, but no information about their location. This allows pac man to prioritize eating the
      food that it takes to win the game, but still allows him to prioritize picking up the pellets if he is near to them on his journey, allowing him to ignore the ghosts
      for a period of time
    """

    score = currentGameState.getScore()
    
    distances = []
    foods = currentGameState.getFood().asList()
    #foods += currentGameState.getCapsules()
    for p in foods:
        distances.append(manhattanDistance(currentGameState.getPacmanPosition(), p))
    score += 1 if len(distances) == 0 or sum(distances) == 0 else 1.0/(sum(distances)/len(distances))

    distances = []
    for g in currentGameState.getGhostStates():
        if (g.scaredTimer == 0):
            distances.append(manhattanDistance(currentGameState.getPacmanPosition(), g.getPosition()))
    score -= 0 if len(distances) == 0 else 150 if sum(distances) == 0 else 1.0/(sum(distances)/len(distances))

    score -= 70 * len(currentGameState.getCapsules())    

    return score

# Abbreviation
better = betterEvaluationFunction

