import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;


public enum Variance {
    SIGN, INC, DEC;
    
    private static final List<Variance> VALUES =
    Collections.unmodifiableList(Arrays.asList(Variance.values()));
    private static final int SIZE = VALUES.size();
    private static final Random RANDOM = new Random();

    public static Variance randomVariance() {
        return VALUES.get(RANDOM.nextInt(SIZE));
    }
}
