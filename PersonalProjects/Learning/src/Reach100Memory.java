import java.util.HashMap;

public class Reach100Memory {
    HashMap<Variance, Double> effectiveness;
    HashMap<Variance, Boolean> failed;
    Double projEuph;
    Variance toChange;
    
    public Reach100Memory() {
        HashMap<Variance, Double> newEff = new HashMap<Variance, Double>();
        newEff.put(Variance.INC, 0.0);
        newEff.put(Variance.DEC, 0.0);
        newEff.put(Variance.SIGN, 0.0);
        HashMap<Variance, Boolean> newFailed = new HashMap<Variance, Boolean>();
        newFailed.put(Variance.INC, false);
        newFailed.put(Variance.DEC, false);
        newFailed.put(Variance.SIGN, false);
        this.effectiveness = newEff;
        this.failed = newFailed;
        this.projEuph = 0.0;
        this.toChange = null;
    }
}
