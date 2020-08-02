package threadsTests.javaStud.thread5ThreadPoolExecutor;

// https://youtu.be/nU3Yf8UVWVc?list=PLyxk-1FCKqodhV1d55ZmoAcz6aeyhLxnr

import java.util.concurrent.*;

public class Starter5 {

    public static void main(String[] args) {
        new Starter5().test4();
    }

    public void test1() {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                3,                            // кол-во рабочих потоков в нашем пуле
                6,                        // максимальное кол-во потоков
                1, TimeUnit.MILLISECONDS,   // сколько живет поток
                new LinkedBlockingQueue<>());            // выстраивание очереди запросов

        for (int i = 0; i < 7; i++) threadPoolExecutor.submit(new MyCallable5());

        threadPoolExecutor.shutdown();
    }

    public void test2() {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(3, 6,
                1, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>(2));

        for (int i = 0; i < 7; i++) threadPoolExecutor.submit(new MyCallable5());
        threadPoolExecutor.shutdown();
    }

    // RejectedExecutionHandler
    public void test3() {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(2, 4,
                1, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>(2), new MyReject5());

        for (int i = 0; i < 7; i++) threadPoolExecutor.submit(new MyCallable5());
        threadPoolExecutor.shutdown();
    }

    // SynchronousQueue<>()
    public void test4() {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(2, 4,
                1, TimeUnit.MILLISECONDS, new SynchronousQueue<>(), new MyReject5());

        for (int i = 0; i < 7; i++) threadPoolExecutor.submit(new MyCallable5());
        threadPoolExecutor.shutdown();
    }

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

    // для обработки информации по отказанным задачам
    static class MyReject5 implements RejectedExecutionHandler {
        @Override
        public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
            System.out.println("REJECTED");
        }
    }
}
