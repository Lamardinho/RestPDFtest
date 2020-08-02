package threadsTests.tests2;

public class SingleThreadClient {
    public static void main(String[] args) {
        Counter counter = new Counter();
        long start = System.nanoTime();

        double value = 0;
        for (int i = 0; i < 3; i++) {
            value += counter.count(i);
        }

        System.out.printf("Executed by %d s, value : %f%n", (System.nanoTime() - start) / (1000_000_000), value);
    }
}
