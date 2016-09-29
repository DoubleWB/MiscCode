

import java.util.ArrayList;
import java.util.Scanner;

public class Genie { // Because I am lazy I do not want to re-comment this code, it is the same, basically, as the Genie.py, which is commented. Look at that for clarification.

	private static Dictionary dict = new Dictionary();

	private static ArrayList<String> alphabet = new ArrayList<String>();

	private static ArrayList<String> possible = new ArrayList<String>();

	private static String input = "";

	private static boolean guessed = false;

	private static int numLetters = 0;

	private static int numGuesses = 0;

	private static String getMostProbNext(ArrayList<String> alphabet) {
		double highProb = 0;
		String mostProb = "-";
		for (String c : alphabet) {
			double prob = dict.getNGramBeginProbability(input + c, numLetters);
			if (prob > highProb) {
				highProb = prob;
				mostProb = c;
			}
		}
		return mostProb;
	}

	private static void initializeAlphabet() { // UGUUHUHGUGHUGHUGHUHGUGH
		alphabet.add("a");
		alphabet.add("b");
		alphabet.add("c");
		alphabet.add("d");
		alphabet.add("e");
		alphabet.add("f");
		alphabet.add("g");
		alphabet.add("h");
		alphabet.add("i");
		alphabet.add("j");
		alphabet.add("k");
		alphabet.add("l");
		alphabet.add("m");
		alphabet.add("n");
		alphabet.add("o");
		alphabet.add("p");
		alphabet.add("q");
		alphabet.add("r");
		alphabet.add("s");
		alphabet.add("t");
		alphabet.add("u");
		alphabet.add("v");
		alphabet.add("w");
		alphabet.add("x");
		alphabet.add("y");
		alphabet.add("z");
	}

	private static void guessNextLetter() {
		ArrayList<String> alphaB = new ArrayList<String>(alphabet);
		Scanner kb = new Scanner(System.in);
		boolean guessedLetter = false;
		while (!guessedLetter) {
			String bestGuess = getMostProbNext(alphaB);
			if(bestGuess.equals("-")){
				System.out.println("Either you are making up a word, or I don't know it...");
				System.out.println("Goodbye!");
				System.exit(0);
			}
			System.out.println("OK! Is your next letter " + bestGuess
					+ "... (y/n)");
			String response = kb.nextLine();
			if (response.equalsIgnoreCase("y")) {
				input += bestGuess;
				System.out.println("Your word is \"" + input + "\" so far...");
				guessedLetter = true;
			} else if (response.equalsIgnoreCase("n")) {
				alphaB.remove(bestGuess);
			}
		}
		return;

	}

	private static void guessTotal() {
		possible = dict.getNGramBeginWords(input, numLetters);
		Scanner kb = new Scanner(System.in);
		if (possible.size() <= 5) {
			for (String word : possible) {
				System.out.println("Could your word be " + word + "? (y/n)");
				String response = kb.nextLine();
				if (response.equalsIgnoreCase("y")) {
					System.out.println("AHAHAHAHAH! I guessed it!");
					System.out.println("Goodbye!");
					System.exit(0);
				} else if (response.equalsIgnoreCase("n")) {
					numGuesses++;
					if (numGuesses == 5) {
						System.out.println("Dang it! I lost.");
						System.out.println("Goodbye!");
						System.exit(0);
					}
					System.out.println("Dang! I have " + (5 - numGuesses)
							+ " left!");
				}
			}
		} else {
			for (int i = 0; i < possible.size(); i++) {
				if (input.length() / (double) possible.get(i).length() > .8) {
					System.out.println("Could your word be " + possible.get(i)
							+ "? (y/n)");
					String response = kb.nextLine();
					if (response.equalsIgnoreCase("y")) {
						System.out.println("AHAHAHAHAH! I guessed it!");
						System.out.println("Goodbye!");
						System.exit(0);
					} else if (response.equalsIgnoreCase("n")) {
						numGuesses++;
						if (numGuesses == 5) {
							System.out.println("Dang it! I lost.");
							System.out.println("Goodbye!");
							System.exit(0);
						}
						System.out.println("Dang! I have " + (5 - numGuesses)
								+ " left!");
					}
				}
			}
		}
	}

	private static void guess() {
		guessNextLetter();
		guessTotal();
	}

	public static void main(String[] args) {
		Scanner kb = new Scanner(System.in);
		System.out
				.println("Welcome to Genie! Please think of a word between 2 and 15 letters! I will try to guess it in 5 guesses!");
		System.out.println("Now, tell me the first letter!");
		String startLetter = kb.nextLine();
		input += startLetter;
		System.out.println("Now, tell me the how many letters it is!");
		numLetters = kb.nextInt();
		System.out.println("Now, let the games begin!");
		initializeAlphabet();
		while (numGuesses < 5) {
			guess();
		}
	}
}
