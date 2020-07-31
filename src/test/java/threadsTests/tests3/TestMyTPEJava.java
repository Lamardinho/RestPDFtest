package threadsTests.tests3;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

public class TestMyTPEJava {

    public static void main(String[] args) throws ExecutionException, InterruptedException {
        new TestMyTPEJava().runTasks();
    }

    private String getRandomNum() {
        return "рандомное число: " + Math.random() * 100;
    }

    public void runTasks() throws ExecutionException, InterruptedException {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                4,                             // количество рабочих потоков
                6,                         // увеличение потоков
                1, TimeUnit.MILLISECONDS,    // сколько живет поток
                new LinkedBlockingQueue<>(),
                new MyReject());            // выстраивание очереди запросов

        List<Future<String>> futures = new ArrayList<>();
        MyCallable mc = new MyCallable();

        for (int i = 0; i < 10; i++) futures.add(threadPoolExecutor.submit(mc));
        // ждем окончания таска
        for (Future<String> f : futures) System.out.println("Task finished: " + f.get());

        threadPoolExecutor.shutdown();
    }

    static class MyCallable implements Callable<String> {
        @Override
        public String call() {
            try {
                System.out.println("Thread started: " + Thread.currentThread().getId());
                System.out.println(new TestMyTPEJava().getRandomNum());
                Thread.sleep(2000);                // System.out.println("Thread finished: " + Thread.currentThread().getId());
            } catch (Exception ex) {
                ex.printStackTrace(System.out);
            }
            return Thread.currentThread().getName();
        }
    }

    static class MyReject implements RejectedExecutionHandler {
        @Override
        public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
            System.out.println("REJECTED");
        }
    }
}
