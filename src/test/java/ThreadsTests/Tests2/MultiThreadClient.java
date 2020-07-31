package ThreadsTests.Tests2;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

import static java.lang.String.format;

public class MultiThreadClient {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ThreadPool threadPool = new ThreadPool(100);
        Counter counter = new Counter();
        long start = System.nanoTime();

        List<Future<Double>> futures = new ArrayList<>();
        for (int i = 0; i < 4; i++) {
            final int j = i;
            futures.add(CompletableFuture.supplyAsync(() -> counter.count(j), threadPool));
        }
        double value = 0;
        for (Future<Double> future : futures) {
            value += future.get();
        }
        System.out.println(format("Executed by %d s, value : %f", (System.nanoTime() - start) / (1000_000_000), value));
        threadPool.shutdown();
    }
}
