import sys #Used to exit program
global inputString #Partial word as input by user or by computer by confirmation 'y'
inputString = ""
global numLetters #Number of letters as input by user
numLetters = 0
global numGuesses #Number of failed guesses taken, used to determine overall failure
numGuesses = 0
# Returns the probability of a string to appear at the beginning of a word with a certain length
# 
# nGram: String to get probability of appearing
# length: Word length to search among dictionary
#
# Used to guess the next letter in a word 
def getNGramBeginsProbability(nGram, length):
    dict = open('/home/will/workspace/Genie/src/resources/TWL06.txt', 'r') # Dictionary
    nGram = nGram.upper()
    nGrams = {'':0}
    totalNGrams = 0
    count = 0
    for line in dict:
        if(len(line)>0):
            if(len(nGram)>len(line.strip()) | len(line.strip())!= length):
                continue
            s = line.strip()[:len(nGram)]
            if(s not in nGrams):
                nGrams[s] = 1
            else:
                nGrams[s] = nGrams.get(s)+1
            totalNGrams+=1
            count+=1
    dict.close()
    if(nGram in nGrams):
        return float(nGrams.get(nGram))/totalNGrams
    return 0

# Returns an array of words of a certain length which begin with the passed string 
#
# nGram: String with which returned words will begin, if there are any
# length: Specified length of words to be returned
#
# Used to guess whole words
def getNGramBeginsWords(nGram, length):
    dict = open('/home/will/workspace/Genie/src/resources/TWL06.txt', 'r')
    nGram = nGram.upper()
    words = []
    for line in dict:
        if(len(line)>0):
            if(len(nGram)>len(line.strip()) or len(line.strip())!= length):
                continue
            s = line.strip()[:len(nGram)]
            if(s == nGram and len(line.strip()) == length):
                words.append(line.strip())
    dict.close()
    return words
# Returns, of the passed in alphabet, the most highly probabilistic letter to come next in the inputString 
#
# alphabet: Array of letters to choose from for next letter
#
# Used in guessNextLetter
def getMostProbNext(alphabet): 
    highProb = 0.0
    mostProb = "-"
    for s in alphabet:
        prob = getNGramBeginsProbability((inputString + s), numLetters)
        if(prob>highProb):
            highProb = prob
            mostProb = s
    return mostProb
# Guesses the next letter of the inputString. If found, the letter is appended to the inputString. Otherwise, the program  terminates
#
#
def guessNextLetter():
    alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",]
    guessedLetter = False
    while(not guessedLetter):
        bestGuess = getMostProbNext(alphabet)
        if(bestGuess == "-"):
            print "Either you are making up a word, or I don't know it..."
            print "Goodbye!"
            sys.exit(0)
        response = raw_input("OK! Is your next letter " + bestGuess + "... (y/n)")
        if (response == "y"):
            global inputString 
            inputString += bestGuess
            print "Your word is \"" + inputString + "\" so far..."
            guessedLetter = True
        elif (response == "n"):
            alphabet.remove(bestGuess)
    return

# Determines if a guess, s,  is correct or incorrect, and makes the proper adjustments to numGuesses, as well as terminates when it is proper to do so
#
# s: Guess string
#

def guessAffirm(s):
    response = raw_input("Could your word be " + s + "? (y/n)")
    if (response == "y"):
        print "AHAHAHAHAH! I guessed it!"
        print "Goodbye!"
        sys.exit(0)
    elif (response == "n"):
        global numGuesses 
        numGuesses+=1
        if (numGuesses == 5):
            print "Dang it! I lost."
            print "Goodbye!"
            sys.exit(0)
        print "Dang! I have " + str(5 - numGuesses) + " left!"
    
    
# Attempts to guess the whole word based off of inputString and numLetters. Will guess if there are less than or equal to 5 possibilities, or if the possibilities are 80% confirmed by the input string
#
def guessTotal():
    possible = getNGramBeginsWords(inputString, numLetters)
    if(len(possible)<=5):
        for s in possible:
            guessAffirm(s)
    else:
        for s in possible:
            if(len(inputString)/ float(len(s)) > .8):
                guessAffirm(s)

# Bundles together one round of guessing
#
def guess():
    guessNextLetter()
    guessTotal()

# Execution of the program
#
def main():
    print "Welcome to Genie! Please think of a word between 2 and 15 letters! I will try to guess it in 5 guesses!"
    global inputString 
    inputString += raw_input("Now, tell me the first letter!") # Prompt for first letter of word
    global numLetters
    numLetters = int(raw_input("Now, tell me the how many letters it is!")) # Prompt for number of letters in word
    print "Now, let the games begin!"
    while(numGuesses<5):
        guess()

main() # Executes program upon running.
