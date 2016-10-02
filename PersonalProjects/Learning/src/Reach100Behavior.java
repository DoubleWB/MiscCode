//Represents a behavior used to reach 100 - can be plus or minus any integer
public class Reach100Behavior extends Behavior {

    Boolean plus;
    int num;
    Reach100Behavior past;
    
    //Creates a Reach100Behavior with a specific parent
    public Reach100Behavior(int num, boolean plus, Stimulus start, Reach100Behavior past) {
        super();
        this.num = num;
        if (this.num < 0) {
            this.num = 0;
        }
        this.plus = plus;
        this.trigger = (start);
        this.past = past;
    }
    
    //Creates a Reach100Behavior with itself as a parent
    public Reach100Behavior(int num, boolean plus, Stimulus start) {
        super();
        this.num = num;
        this.plus = plus;
        this.trigger = (start);
        this.past = this;
    }

    @Override
    //Acts by adding or subtracting this behavior's num as appropriate (world adjusts itself here)
    public Stimulus act() {
        if (plus) {
            Reach100World.state += num;
            Reach100World.truncateBarriers();
            return Reach100World.getStim();
        }
        Reach100World.state -= num;
        Reach100World.truncateBarriers();
        return Reach100World.getStim();
    }
    
    //Returns true if this behavior's stimulus matches the other behavior's stimulus
    public boolean sameAs(Reach100Behavior other) {
        return other.shouldTrigger((Reach100Stimulus) this.trigger); 
    }
    
    //Returns true if the given stimulus matches this behavior's stimulus
    public boolean shouldTrigger(Reach100Stimulus trigger) {
        return ((Reach100Stimulus) this.trigger).sameAs(trigger);
    }
    
    public String toString() {
        if (plus) {
            return "add " + num;
        }
        return "subtract " + num;
    }
    
    
    
    
}
