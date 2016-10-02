//Represents a behavior in response to a stimulus
public abstract class Behavior {
    
    Stimulus trigger;
    
    //EFFECT : Acts and returns the stimulus after the action
    abstract Stimulus act();
    
    //Returns a string representation of this behavior
    public String toString() {
        return "";
    }  

}
