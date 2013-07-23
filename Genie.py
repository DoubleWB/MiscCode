import sys
global inputString 
inputString = ""
global numLetters
numLetters = 0
global numGuesses 
numGuesses = 0
def getNGramBeginsProbability(nGram, length):
    dict = open('/home/will/workspace/Genie/src/resources/TWL06.txt', 'r')
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

def getMostProbNext(alphabet):
    highProb = 0.0
    mostProb = "-"
    for s in alphabet:
        prob = getNGramBeginsProbability((inputString + s), numLetters)
        if(prob>highProb):
            highProb = prob
            mostProb = s
    return mostProb

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
    
    

def guessTotal():
    possible = getNGramBeginsWords(inputString, numLetters)
    if(len(possible)<=5):
        for s in possible:
            guessAffirm(s)
    else:
        for s in possible:
            if(len(inputString)/ float(len(s)) > .8):
                guessAffirm(s)

def guess():
    guessNextLetter()
    guessTotal()

def main():
    print "Welcome to Genie! Please think of a word between 2 and 15 letters! I will try to guess it in 5 guesses!"
    global inputString 
    inputString += raw_input("Now, tell me the first letter!")
    global numLetters
    numLetters = int(raw_input("Now, tell me the how many letters it is!"))
    print "Now, let the games begin!"
    while(numGuesses<5):
        guess()

main()
