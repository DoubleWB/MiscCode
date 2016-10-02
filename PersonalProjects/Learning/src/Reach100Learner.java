import java.util.*;


public class Reach100Learner implements Learner {
    
    ArrayList<Behavior> behaviors;
    HashMap<Reach100Behavior, HashMap<Variance, Double>> memories = new HashMap<Reach100Behavior, HashMap<Variance, Double>>();
    HashMap<Reach100Behavior, Reach100Memory> memoriesV2 = new HashMap<Reach100Behavior, Reach100Memory> ();
    
    
    public Reach100Learner() {
        behaviors = new ArrayList<Behavior>();
    }

    //Generates random new behavior in the proper space in response to the trigger
    public Reach100Behavior generateNew(Stimulus trigger) {
        boolean plus = Math.random() > .5;
        int num = (int) (Math.random() * 200);
        return new Reach100Behavior(num, plus, trigger);
    }

    //EFFECT: Uses forced changes to the world to take a randomly spawned behavior and make it as perfect as possible with 10 artificial rounds
    public void respond(Stimulus stim) {
        //Generate a new behavior for the given stimulus
        Behavior rand = this.generateNew(stim);
        this.behaviors.add(rand);
        
        System.out.println("Using " + rand.toString());
        //Use ten iterations on optimal changes to make a good behavior
        rand = artImpBehavior
                ((Reach100Behavior) rand, 10); //TODO
        System.out.println("Using " + rand.toString());
        rand.act();
    }
    
    //EFFECT: Uses memory to make behaviors over time that gradually better themselves
    public void respondNatural(Reach100Stimulus stim) { //TODO
        Reach100Behavior temp = this.generateNew(stim);
        Boolean foundOld = false;
        //Determine if there already exists a behavior for the given stimulus
        for (Behavior b : behaviors) {
            if (((Reach100Behavior) b).shouldTrigger(stim)) {
                System.out.println("updating old behavior: " + b.toString());
                temp = (Reach100Behavior) b;
                foundOld = true;
            }
        }
        //If there isn't, set up the memories for this behavior
        if (!foundOld) {
            System.out.println("generating new behavior: " + temp.toString());
            this.behaviors.add(temp);
            HashMap<Variance, Double> newMem = new HashMap<Variance, Double>();
            newMem.put(Variance.INC, 0.0);
            newMem.put(Variance.DEC, 0.0);
            newMem.put(Variance.SIGN, 0.0);
            this.memories.put(temp, newMem);
        }
        System.out.println("Behavior size: " + behaviors.size());
        //take the new or old behavior and improve it - and run it
        runAndImpBehavior(temp);
        System.out.println("Behavior size: " + behaviors.size());
    }
    
    public void respondNaturalV2(Reach100Stimulus stim) { //TODO
        Reach100Behavior temp = this.generateNew(stim);
        Boolean foundOld = false;
        //Determine if there already exists a behavior for the given stimulus
        for (Behavior b : behaviors) {
            if (((Reach100Behavior) b).shouldTrigger(stim)) {
                System.out.println("updating old behavior: " + b.toString());
                temp = (Reach100Behavior) b;
                foundOld = true;
            }
        }
        //If there isn't, set up the memories for this behavior
        if (!foundOld) {
            System.out.println("generating new behavior: " + temp.toString());
            this.behaviors.add(temp);
            this.memoriesV2.put(temp, new Reach100Memory());
        }
        //take the new or old behavior and improve it - and run it
        runAndImpBehaviorV2(temp, .8);
    }
    
    //Change a behavior based on memories and then record new memories
    public void runAndImpBehavior(Reach100Behavior b) {
        HashMap<Variance, Double> mems = memories.get(b);
        //to replace this memory - remove it so that even after any changes we don't overlap
        memories.remove(b);
        behaviors.remove(b);
        //default to decreasing the magnitude of the behavior
        Variance best = Variance.DEC;
        double bestEff = mems.get(Variance.DEC);
        //check which change has been most effective in the past
        for (Variance v: mems.keySet()) {
            System.out.println(v + " with reported effectiveness " + mems.get(v));
            if (bestEff < mems.get(v)) {
                System.out.println("Found that " + v + " is better than " + best + " because " + bestEff + " is less than " + mems.get(v));
                best = v;
                bestEff = mems.get(v);
            }
        }
        double startingEuph = Reach100World.getStim().getEuphoria();
        //change the behavior with the previously most effective change
       
        b = vary(b, best);
        System.out.println(b.toString());
        b.act();
        
        //record the change in satisfaction //CHECK THE PLACE YOU'RE AT TO SEE IF YOU KNOW WHAT TO DO FROM THERE
        double newEff = Reach100World.getStim().getEuphoria() - startingEuph;
        //if no change was recorded, return to the parent of this behavior, and record that this change is now less effective
        if (newEff == 0) {
            newEff = bestEff - 1; 
            b = b.past;
        }
        //set up the memories such that the new behavior is correctly remembered
        mems.replace(best, newEff);
        memories.put(b, mems);
        behaviors.add(b);
    }
    
  //Change a behavior based on memories and then record new memories
    public void runAndImpBehaviorV2(Reach100Behavior b, double tolerance) {
        Reach100Memory mem = memoriesV2.get(b);
        behaviors.remove(b);
        memoriesV2.remove(b);
        if (mem.toChange != null) {
            b = vary(b, mem.toChange);
            System.out.println("Changing behavior to " + b.toString());
        }
        
        double startingEuph = Reach100World.getStim().getEuphoria();
        b.act();
        double newEff = Reach100World.getStim().getEuphoria() - startingEuph;
        if (Reach100World.getStim().getEuphoria() > mem.projEuph) {
            mem.projEuph = Reach100World.getStim().getEuphoria();
        }
        if (Reach100World.getStim().getEuphoria() > tolerance * 100) {
            if (estimatedEff() > tolerance * 100) {
                System.out.println("I'm happy with the following behavior");
                behaviors.add(b);
                mem.toChange = null;
                memoriesV2.put(b, mem);
                return;
            }
            System.out.println("I'm happy with this behavior");
            behaviors.add(b);
            mem.toChange = null;
            memoriesV2.put(b, mem);
            return;
        }
        
        ArrayList<Variance> options = new ArrayList<Variance>();
        
        if (newEff <= 0) {
            if (mem.toChange != null) {
                b = b.past;
                mem.failed.replace(mem.toChange, true);
            }
            for (Variance v : mem.failed.keySet()) {
                if (! mem.failed.get(v)) {
                    options.add(v);
                }
            }
        }
        else {
            options.addAll(mem.effectiveness.keySet());
            for (Variance v : mem.failed.keySet()) {
                if (mem.failed.get(v)) {
                    mem.failed.replace(v, false);
                }
            }
        }
        
        Variance best = Variance.randomVariance();
        Double bestEff = 0.0;
        for (Variance v : options) {
            if (mem.effectiveness.get(v) > bestEff) {
                best = v;
                bestEff = mem.effectiveness.get(v);
            }
        }
        mem.toChange = best;
        mem.effectiveness.replace(best, newEff);
        behaviors.add(b);
        memoriesV2.put(b, mem);
    }
    
    //Return a new behavior which is the result of the given behavior being varied in the given category
    public Reach100Behavior vary(Reach100Behavior b, Variance v) {
        //Although its random - the magnitude changes tend to decrease as we get closer to the goal
        int magnitude = (int) (Math.random() * (100 - Reach100World.getStim().getEuphoria()));
        switch (v) {
        case SIGN:
            return new Reach100Behavior(b.num, !b.plus, b.trigger, b);
        case INC:
            return new Reach100Behavior(b.num + magnitude, b.plus, b.trigger, b);
        case DEC:
            return new Reach100Behavior(b.num - magnitude, b.plus, b.trigger, b);
        default:
            return b;
        }
    }
    
    public double estimatedEff() {
        double ret = 0.0;
        for (Behavior b : behaviors) {
            if (((Reach100Behavior) b).shouldTrigger(Reach100World.getStim())) {
                ret = memoriesV2.get(b).projEuph;
            }
        }
        return ret;
    }
    
    //REturn a new behavior which is prefectly improved for the given number of rounds
    public Reach100Behavior artImpBehavior(Reach100Behavior b, int timeAlloted) {
        int i = 0;
        while (i < timeAlloted) {
            int baseState = ((Reach100Stimulus) (b.trigger)).stim; //TODO
            HashMap<Variance, Reach100Behavior> effectiveness = new HashMap<Variance, Reach100Behavior>();
            Variance best = Variance.DEC;
            double bestEff = 0;
            for (Variance v : Variance.values()) {
                //see where the behavior gets you
                b.act();
                
                Reach100Behavior temp = vary(b, v);
                Reach100World.state = baseState;
                //see where it gets you after changing
                temp.act();
                if (Reach100World.getStim().getEuphoria() > bestEff) {
                    bestEff = Reach100World.getStim().getEuphoria();
                    best = v;
                }
                //put that change in temporary memory
                effectiveness.put(v, temp);
                Reach100World.state = baseState;
            }
            //pick the most effective variance and do another round
            b = effectiveness.get(best);
            System.out.println("Varying to " + b.toString());
            i++;
        }
        return b;
    }
}
