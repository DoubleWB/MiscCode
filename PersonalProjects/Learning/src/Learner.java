public interface Learner {
    
    //Generates random new behavior in the proper space in response to the trigger
    Behavior generateNew(Stimulus trigger);
    
    //EFFECT: picks a behavior and acts with it according to the given stimulus
    void respond(Stimulus stim);
    
}
