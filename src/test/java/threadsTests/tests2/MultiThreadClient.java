package threadsTests.tests2;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

public class MultiThreadClient {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ThreadPool threadPool = new ThreadPool(8);
        long start = System.nanoTime();

        List<Future<Double>> futures = new ArrayList<>();
        for (int i = 0; i < 400; i++) {
            final int j = i;
            futures.add(CompletableFuture.supplyAsync(() -> new Counter().count(j), threadPool));
        }
        double value = 0;
        for (Future<Double> future : futures) {
            value += future.get();
        }
        System.out.printf("Executed by %d s, value : %f%n", (System.nanoTime() - start) / (1000_000_000), value);
        threadPool.shutdown();
    }
}
