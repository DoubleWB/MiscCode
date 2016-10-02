
public class Reach100World {
    
    static int state = (int) (Math.random() * 200);
    
    //Returns (gets) the stimulus of this world
    public static Reach100Stimulus getStim() {
        return new Reach100Stimulus(state);
    }
    
    //Forces this world's state  to stay between 0 and 200
    public static void truncateBarriers() {
        if (Reach100World.state >= 200) {
            Reach100World.state = 200;
        }
        if (Reach100World.state <= 0) {
            Reach100World.state = 0;
        }
    }

}
