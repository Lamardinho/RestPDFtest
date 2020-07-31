package threadsTests;

import org.junit.Test;

import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;

import static org.junit.Assert.assertEquals;

public class TestMy {
    public static void main(String[] args) {
        TestMy testMy = new TestMy();
        testMy.t2();
    }

    @Test
    public void t() {
        ThreadPoolExecutor executor = (ThreadPoolExecutor) Executors.newFixedThreadPool(2);

        for (int i = 1; i <= 3; i++) {
            executor.submit(() -> {
                Thread.sleep(5000);
                return null;
            });
            System.out.println("цикл # " + i);
        }

        assertEquals(2, executor.getPoolSize());
        assertEquals(1, executor.getQueue().size());
        System.out.println();
    }

    @Test
    public void t2() {
        ThreadPoolExecutor executor = (ThreadPoolExecutor) Executors.newCachedThreadPool();
        for (int i = 1; i <= 30; i++) {
            executor.submit(() -> {
                Thread.sleep(5000);
                return null;
            });
            System.out.println("цикл # " + i);
        }

        assertEquals(30, executor.getPoolSize());
        assertEquals(0, executor.getQueue().size());
        System.out.println();
    }
}
