package threadsTests.javaStud.thread5ThreadPoolExecutor;

import java.util.concurrent.*;

public class Starter5 {
    static class MyCallable5 implements Callable<String> {
        @Override
        public String call() {
            try {
                System.out.println("Thread started: " + Thread.currentThread().getId());
                Thread.sleep(2000);
                System.out.println("Thread finished: " + Thread.currentThread().getId());
            } catch (Exception ex) {
                ex.printStackTrace(System.out);
            }
            return Thread.currentThread().getName();
        }
    }

    static class MyReject5 implements RejectedExecutionHandler {
        @Override
        public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
            System.out.println("REJECTED");
        }
    }

    public void test1() {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                2,      // количество рабочих потоков
                6,  // размер очереди?
                1,    // сколько живет поток
                TimeUnit.MILLISECONDS,
                new LinkedBlockingQueue<>(),   // выстраивание очереди запросов
                new MyReject5());

        for (int i = 0; i < 5; i++) {
            MyCallable5 myCallable5 = new MyCallable5();
            threadPoolExecutor.submit(myCallable5);
        }
        threadPoolExecutor.shutdown();
    }

    public void test2() {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(2, 4, 1,
                TimeUnit.MILLISECONDS, new SynchronousQueue<>(), new MyReject5());

        for (int i = 0; i < 7; i++) {
            MyCallable5 myCallable5 = new MyCallable5();
            threadPoolExecutor.submit(myCallable5);
        }
        threadPoolExecutor.shutdown();
    }

    public static void main(String[] args) {
        Starter5 starter5 = new Starter5();
        starter5.test1();
    }
}
