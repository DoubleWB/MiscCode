import java.io.*;
import java.util.Scanner;

public class Reach100Tester {
    
    public static void driveDirect(double dist) {
        Runtime runtime = Runtime.getRuntime();
        Process process;
        try {
            process = runtime.exec("python motor.py " + dist);
            InputStream is = process.getInputStream();
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader br = new BufferedReader(isr);
            String line;

            while ((line = br.readLine()) != null) {
                System.out.println(line);
            }
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } // you might need the full path
    }
    
    public static void main(String[] args) {
        Reach100Learner l = new Reach100Learner();
        Scanner input = new Scanner(System.in);
        
        //tests artificial improvement
        
        /*while(true) {
            System.out.println("Please input next state:");
            Reach100World.state = input.nextInt();
            System.out.println("Base Euphoria " + Reach100World.getStim().getEuphoria());
            l.respond(Reach100World.getStim());
            System.out.println("Euphoria after response " + Reach100World.getStim().getEuphoria());
        }*/
        
        //tests natural improvement
        while (true) {
            System.out.println("Please input time allotted: ");
            int i = input.nextInt();
            System.out.println("Base WorldState " + Reach100World.state);
            int state1 = 0;
            int state2 = 0;
            int state12 = 1;
            int state22 = 1;
            int cycles = 0;
            while ( i > 0 ) {
                System.out.println("=============================================================================");
                System.out.println("Worldstate: " + Reach100World.state);
                state1 = Reach100World.state;
                l.respondNaturalV2(Reach100World.getStim());
                state2 = Reach100World.state;
                driveDirect((state1 - state2) / 10.0);
                System.out.println("Worldstate: " + Reach100World.state);
                if (state22 == state1 && state12 == state2 && state1 != state2) {
                    cycles += 1;
                }
                else {
                    state12 = state1;
                    state22 = state2;
                    cycles = 0;
                }
                if (cycles > 5) {
                    System.out.println("Cycling - stopping");
                    break;
                }
                i--;
            }
            System.out.println("************************************************");
            System.out.println("Behaviors recorded: " + l.behaviors.size());
            double avD = 0;
            double avg = 0;
            for (Behavior b : l.behaviors) {
                avg += l.memoriesV2.get(b).projEuph;
                avD += 1;
            }
            System.out.println("Average Euphoria: " + (avg/avD));
            System.out.println("************************************************");
        }
    }

}
