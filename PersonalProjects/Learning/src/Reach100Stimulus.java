public class Reach100Stimulus implements Stimulus {
    
    int stim;
    
    public Reach100Stimulus(int stim) {
        this.stim = stim;
    }

    @Override
    //Returns a double from 0 to 100 linearly describing how close the world is to the goal (100)
    public double getEuphoria() {
        return 100.0 - Math.abs(100 - stim);
    }

    //Returns true if the given stimulus is the same as this stimulus
    public boolean sameAs(Reach100Stimulus other) {
        return other.stim == this.stim;
    }
    
}
