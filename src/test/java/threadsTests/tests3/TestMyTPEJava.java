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
        ThreadPoolExecutor tpExecutor = new ThreadPoolExecutor(4, 6, 1, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>(), new MyReject());

        List<Future<String>> futures = new ArrayList<>();
        MyCallable mc = new MyCallable();

        for (int i = 0; i < 10; i++) futures.add(tpExecutor.submit(mc));
        // ждем окончания таска
        for (Future<String> f : futures) System.out.println("Task finished: " + f.get());

        tpExecutor.shutdown();
    }

    static class MyCallable implements Callable<String> {
        @Override
        public String call() {
            try {
                System.out.println("Thread started: " + Thread.currentThread().getId());
                System.out.println(new TestMyTPEJava().getRandomNum());
                Thread.sleep(2000);
                // System.out.println("Thread finished: " + Thread.currentThread().getId());
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
