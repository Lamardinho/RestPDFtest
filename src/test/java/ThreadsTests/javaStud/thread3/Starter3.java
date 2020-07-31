package ThreadsTests.javaStud.thread3;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class Starter3 {
    static class MyRunnable3 implements Runnable {
        @Override
        public void run() {
            try {
                System.out.println("Started:" + Thread.currentThread().getId());
                Thread.sleep(5000);
                System.out.println("Finished:" + Thread.currentThread().getId());
            } catch (InterruptedException e) {
                e.printStackTrace(System.out);
            }
        }
    }

    static class MyCallable3 implements Callable<String> {
        @Override
        public String call() {
            try {
                System.out.println("Started:" + Thread.currentThread().getId());
                Thread.sleep(5000);
                System.out.println("Finished:" + Thread.currentThread().getId());
            } catch (InterruptedException e) {
                e.printStackTrace(System.out);
            }
            return "MyCallable3 is done";
        }
    }

    public void test1() {
        ExecutorService es = Executors.newFixedThreadPool(5);
        es.execute(new MyRunnable3());   // запускаем
        es.shutdown();
    }

    public void test2() throws InterruptedException {
        ExecutorService es = Executors.newFixedThreadPool(5);
        Future<?> sub = es.submit(new MyRunnable3());
        while (!sub.isDone()) {
            System.out.println("Is not done");
            Thread.sleep(1000);
        }
        System.out.println("shutdown");
        es.shutdown();
    }

    public void test3() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(5);
        Future<?> sub = es.submit(new MyRunnable3());
        sub.get();  // ждем
        System.out.println("shutdown");
        es.shutdown();
    }

    public void test4() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(5);
        Future<String> sub = es.submit(new MyCallable3());
        String id = sub.get();  // ждем
        System.out.println(id);
        System.out.println("shutdown");
        es.shutdown();
    }

    public void test5() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(5);
        Future<String> sub = es.submit(new MyCallable3());

        Thread.sleep(1000);
        sub.cancel(true);     // попробовать остановить задачу
        System.out.println(sub.isCancelled());  // результат "была ли задача отменена

        System.out.println("shutdown");
        es.shutdown();
    }

    public static void main(String[] args) throws Exception {
        Starter3 starter3 = new Starter3();
        //starter3.test1();
        //starter3.test2();
        //starter3.test3();
        //starter3.test4();
        starter3.test5();
    }
}
