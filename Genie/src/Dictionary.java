
/*
 * Dictionary.java
 */

import java.io.*;
import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * This class implements the <code>Scrtr$</code> dictionary of valid words.
 * 
 * @author Alex Yang
 * @author 2012-2013 Winchester High School APCS class
 */
public class Dictionary {

    /////////////////////////////// FIELDS ///////////////////////////////

    private HashSet<String> dictionary = new HashSet<String>(178691);
    private HashMap<Character, Integer> unigrams = new HashMap<Character, Integer>();
    private HashMap<String, Integer> bigrams = new HashMap<String, Integer>();
    private int totalUnigrams = 0;
    private int totalBigrams = 0;
    private Random randomUnigram = new Random(47);
    private Random randomBigram = new Random(47);
    private ArrayList<Character> unigramKeys;
    private ArrayList<String> bigramKeys;
    public HashMap<Character, Integer> letterScores = new HashMap<Character, Integer>();

    //////////////////////////// CONSTRUCTORS ////////////////////////////

    /**
     * Constructs a new dictionary with the words from file named by pathname.
     * Fills unigramKeys and bigramKeys.
     * Creates the scores for unigrams.
     * On any IOException reading words, dictionary is empty.
     */
    public Dictionary(String pathname) {
        InputStream stream = getInputStream(pathname);
        if (stream != null) {
            try {
                BufferedReader br = new BufferedReader(new InputStreamReader(stream));
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.length() > 0) {
                        dictionary.add(line);   // add word to dictionary
                        for (int i = 0; i < line.length(); i++) {   // add unigrams
                            Character c = line.charAt(i);
                            if (!unigrams.containsKey(c)) {
                                unigrams.put(c, 1);
                            }
                            else {
                                unigrams.put(c, unigrams.get(c) + 1);
                            }
                            totalUnigrams++;
                        }
                        for (int j = 0; j < line.length() - 1; j++) {   // add bigrams
                            String s = line.substring(j, j + 2);
                            if (!bigrams.containsKey(s)) {
                                bigrams.put(s, 1);
                            }
                            else {
                                bigrams.put(s, bigrams.get(s) + 1);
                            }
                            totalBigrams++;
                        }
                    }
                }
                br.close();
            }
            catch (IOException e) {
                System.err.println("Dictionary: " + e);
                dictionary.clear();
            }
        }
        unigramKeys = new ArrayList<Character>(unigrams.keySet());
        Collections.sort(unigramKeys);  // set in order will help debugging
        bigramKeys = new ArrayList<String>(bigrams.keySet());
        Collections.sort(bigramKeys);  // set in order will help debugging
        
        for (Character c : getUnigrams().keySet()) {
        	letterScores.put(c, finalizeScores(c, 1, 9));
        }
    }
    /**
     * Constructs a new dictionary with the words from The Word List.
     * On any IOException reading words, dictionary is empty.
     */
    public Dictionary() {
        this("resources/TWL06.txt");
    }

    ////////////////////////////// METHODS ///////////////////////////////

    /**
     * Check several possible locations for a file named by pathname and
     * return it as an <code>InputStream</code>. Return <code>null</code> if
     * file cannot be found in JAR file or file system.
     * RED_FLAG: System.err.print stuff should be SLF4J / Logback
     *  
     * @param pathname name of path to file
     * @return <code>InputStream</code> named by pathname, or <code>null</code>
     * if file not found
     */
    private InputStream getInputStream(String pathname) {
        // pathname could be relative to project directory or class directory.
        // RED_FLAG: should use http://docs.oracle.com/javase/7/docs/api/java/nio/file/Paths.html
        String upOnePathname = 
            ".." + System.getProperty("file.separator") + pathname;

        // Check whether pathname is resource in JAR file.
        InputStream stream = getClass().getResourceAsStream(pathname);
        // Or, check whether upOnePathname is resource in JAR file.
        if (stream == null) {
            //System.err.printf("Dictionary: %s not a resource\n", pathname);
            stream = getClass().getResourceAsStream(upOnePathname);
        }
        // Or, check whether pathname is resource in file system.
        if (stream == null) {
            //System.err.printf("Dictionary: %s not a resource\n", upOnePathname);
            try {
                stream = new FileInputStream(pathname);
            }
            catch (IOException e) {
                System.err.println("Dictionary: " + e);
            }
        }
        // Or, check whether upOnePathname is resource in file system.
        if (stream == null) {
            try {
                stream = new FileInputStream(upOnePathname);
            }
            catch (IOException e) {
                System.err.println("Dictionary: " + e);
            }
        }
        return stream;
    }
    /**
     * Returns <code>true</code> if word is in dictionary, otherwise 
     * <code>false</code>.
     * 
     * @param word to look up
     * @return <code>true</code> if word is in dictionary, otherwise 
     *         <code>false</code>
     */
    public boolean isValidWord(String word) {
        return dictionary.contains(word.toUpperCase());
    }
    /**
     * Returns number of words in dictionary.
     * @return number of words in dictionary
     */
    public int size() {
        return dictionary.size();
    }
    /**
     * Return probability for a unigram (single character) in this Dictionary.
     * @param unigram unigram to find probability for
     * @return probability for unigram in this Dictionary
     */
    public double getUnigramProbability(char unigram) {
        if (unigrams.containsKey(unigram)) {
            return (double)(unigrams.get(unigram)) / totalUnigrams;
        }
        return 0;    // probability is zero, if unigram not in unigrams
    }
    /**
     * Returns probability for a bigram (twincharacter String) in this Dictionary.
     * @param bigram bigram to find probability for
     * @return the probability for bigram in this Dictionary
     */
    public double getBigramProbability(String bigram) {
        if (bigrams.containsKey(bigram)) {
            return (double)(bigrams.get(bigram)) / totalBigrams;
        }
        return 0;    // probability is zero, if bigram not in bigrams
    }
    
    public double getNGramProbability(String nGram) {
    	 nGram = nGram.toUpperCase();
    	 HashMap<String, Integer> nGrams = new HashMap<String, Integer>();
    	 InputStream stream = getInputStream("resources/TWL06.txt");
    	 int totalNGrams = 0;
         if (stream != null) {
             try {
                 BufferedReader br = new BufferedReader(new InputStreamReader(stream));
                 String line;
                 while ((line = br.readLine()) != null) {
                	 //System.out.println(line);
                     if (line.length() > 0) {
                         loop: for (int j = 0; j < line.length() - 1; j++) {   // add bigrams
                        	 if(j+nGram.length()>line.length()-1){
                        		 continue loop;
                        	 }
                        	 String s = line.substring(j, j + nGram.length());
                        	 //System.out.println(s);
                        	 //System.out.println(!nGrams.containsKey(s));
                             if (!nGrams.containsKey(s)) {
                                 nGrams.put(s, 1);
                             }
                             else {
                                 nGrams.put(s, nGrams.get(s) + 1);
                             }
                             totalNGrams++;
                         }
                     }
                 }
                 br.close();
                 //System.out.println(totalNGrams);
             }
             catch (IOException e) {
                 //System.err.println("Dictionary: " + e);
                 //dictionary.clear();
             }
         }
         
         if (nGrams.containsKey(nGram)) {
             return (double)(nGrams.get(nGram)) / totalNGrams;
         }
         return 0;
    	
    }
    
    public double getNGramBeginProbability(String nGram, int len) {
   	 nGram = nGram.toUpperCase();
   	 HashMap<String, Integer> nGrams = new HashMap<String, Integer>();
   	 InputStream stream = getInputStream("resources/TWL06.txt");
   	 int totalNGrams = 0;
        if (stream != null) {
            try {
                BufferedReader br = new BufferedReader(new InputStreamReader(stream));
                String line;
                loop: while ((line = br.readLine()) != null) {
               	 //System.out.println(line);
                    if (line.length() > 0) {
                       	 if(nGram.length()>line.length()|| line.length()!=len){
                       		 continue loop;
                       	 }
                       	 String s = line.substring(0, nGram.length());
                       	 //System.out.println(s);
                       	 //System.out.println(!nGrams.containsKey(s));
                            if (!nGrams.containsKey(s)) {
                                nGrams.put(s, 1);
                            }
                            else {
                                nGrams.put(s, nGrams.get(s) + 1);
                            }
                            totalNGrams++;
                    }
                }
                br.close();
                //System.out.println(totalNGrams);
            }
            catch (IOException e) {
                //System.err.println("Dictionary: " + e);
                //dictionary.clear();
            }
        }
        if (nGrams.containsKey(nGram)) {
            return (double)(nGrams.get(nGram)) / totalNGrams;
        }
        return 0;
   	
   }
    
    public ArrayList<String> getNGramBeginWords(String nGram, int len) {
      	 nGram = nGram.toUpperCase();
      	 ArrayList<String> words = new ArrayList<String>();
      	 HashMap<String, Integer> nGrams = new HashMap<String, Integer>();
      	 InputStream stream = getInputStream("resources/TWL06.txt");
      	 int totalNGrams = 0;
           if (stream != null) {
               try {
                   BufferedReader br = new BufferedReader(new InputStreamReader(stream));
                   String line;
                   loop: while ((line = br.readLine()) != null) {
                  	 //System.out.println(line);
                       if (line.length() > 0) {
                          	 if(nGram.length()>line.length()){
                          		 continue loop;
                          	 }
                          	 String s = line.substring(0, nGram.length());
                          	 if(s.equals(nGram) && line.length() == len){
                          		 words.add(line); 
                          	 }
                       }
                   }
                   br.close();
                   //System.out.println(totalNGrams);
               }
               catch (IOException e) {
                   //System.err.println("Dictionary: " + e);
                   //dictionary.clear();
               }
           }
           return words;
      	
      }
       
    
    public ArrayList<String> getWords(String nGram){
    	 nGram = nGram.toUpperCase();
    	 ArrayList<String> words = new ArrayList<String>();
    	 InputStream stream = getInputStream("resources/TWL06.txt");
    	 int totalNGrams = 0;
         if (stream != null) {
             try {
                 BufferedReader br = new BufferedReader(new InputStreamReader(stream));
                 String line;
                 while ((line = br.readLine()) != null) {
                	 //System.out.println(line);
                     if (line.length() > 0) {
                         loop: for (int j = 0; j < line.length() - 1; j++) {   // add bigrams
                        	 if(j+nGram.length()>line.length()-1){
                        		 continue loop;
                        	 }
                        	 String s = line.substring(j, j + nGram.length());
                             if(s.equals(nGram)){
                            	 words.add(line);
                             }
                         }
                     }
                 }
                 br.close();
             }
             catch (IOException e) {
                 //System.err.println("Dictionary: " + e);
                 //dictionary.clear();
             }
         }
         return words;
    	
    }
    /**
     * Return a random unigram (single char), or '\0' if no unigrams.
     * @return a random unigram
     */
    public char getRandomUnigram() {
        double totalProbability = 0;
        double random = randomUnigram.nextDouble();
        System.out.println(random);
        for (char next : unigramKeys) {
            totalProbability += getUnigramProbability(next);
            if (totalProbability > random) {
                return next;
            }
        }
        return '\0';
    }
    /**
     * Returns a random bigram (two-letter String), or "" if no bigrams.
     * @return a random bigram
     */
    public String getRandomBigram() {
        double totalProbability = 0;
        double random = randomBigram.nextDouble();
        for (String next : bigramKeys) {
            totalProbability += getBigramProbability(next);
            if (totalProbability > random) {
                return next;
            }
        }
        return "";
    }
    /**
     * Seeds randomUnigram with a seed
     * @param The desired seed
     */
    public void setSeedForUnigram(long seed) {
    	randomUnigram.setSeed(seed);
    }
    /**
     * Seeds randomBigram with a seed
     * @param The desired seed
     */
    public void setSeedForBigram(long seed) {
    	randomBigram.setSeed(seed);
    }
    /**
     * Returns the set of all unigrams
     * @return the set of all unigrams
     */
    public HashMap<Character, Integer> getUnigrams() {
    	return unigrams;
    }
    /**
     * Returns the set of all bigrams
     * @return the set of all bigrams
     */
    public HashMap<String, Integer> getBigrams() {
    	return bigrams;
    }
    /**
     * Returns the score for letter
     * @param letter
     * @return the score for letter
     */
    public int getScore(char letter) {
    	return letterScores.get(letter);
    }

    ////////////////// Private Methods ///////////////////
    
    private double pLetter(char letter){
    	return -1 * Math.log10(getUnigramProbability(letter));
    }
    
    private double scoreFactor(double slope) {
    	double min = 0;
    	double max = 0;
    	int i = 0;
    	for (Character c : getUnigrams().keySet()) {
    		if(i == 0){
    			min = pLetter(c);
    			max = pLetter(c);
    		}
    		else{
    			if(pLetter(c) < min){
    				min = pLetter(c);
    			}
    			if(pLetter(c) > max){
    				max = pLetter(c);
    			}	
    		}
    		i++;
    	}
    	return slope/(max - min);
    }
    
    private int roundScores(char letter, int slope){
    	return (int)(pLetter(letter) * scoreFactor(slope));
    }
    
    private int finalizeScores(char letter, int smallestScore, int slope){
    	int min = 0;
    	int i = 0;
    	for (Character c : getUnigrams().keySet()) {
    		if (i == 0){
    			min = roundScores(c,slope);
    		}
    		else{
    			if(roundScores(c,slope) < min){
    				min = roundScores(c,slope);
    			}
    		}
    		i++;
    	}
    	return roundScores(letter,slope)- min + smallestScore;
    }
}
