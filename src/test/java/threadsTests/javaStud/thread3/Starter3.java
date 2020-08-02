package threadsTests.javaStud.thread3;

// https://youtu.be/j9FA0C2pdkA?list=PLyxk-1FCKqodhV1d55ZmoAcz6aeyhLxnr

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class Starter3 {

    public static void main(String[] args) throws Exception {
        new Starter3().test2();
    }

    public void test1() {
        ExecutorService es = Executors.newFixedThreadPool(5);
        es.execute(new MyRunnable3());   // запускаем
        es.shutdown();
    }

    // Future = получение информации о задаче // метод: .isDone()
    public void test2() throws InterruptedException {
        ExecutorService es = Executors.newFixedThreadPool(5);
        Future<?> future = es.submit(new MyRunnable3());
        while (!future.isDone()) {
            System.out.println("Is not done");
            Thread.sleep(1000);
        }
        System.out.println("shutdown");
        es.shutdown();
    }

    // .get() - ждет пока задача не исполнится
    public void test3() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(5);
        Future<?> future = es.submit(new MyRunnable3());
        future.get();  // ждем пока задача не исполнится
        System.out.println("shutdown");
        es.shutdown();
    }

    public void test4() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(5);
        Future<String> future = es.submit(new MyCallable3());
        System.out.println(future.get());
        System.out.println("shutdown");
        es.shutdown();
    }

    // .cancel()
    public void test5() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(5);
        Future<String> future = es.submit(new MyCallable3());

        Thread.sleep(1000);
        future.cancel(true);     // попробовать остановить задачу
        System.out.println(future.isCancelled());  // результат "была ли задача отменена

        System.out.println("shutdown");
        es.shutdown();
    }


    static class MyRunnable3 implements Runnable {
        @Override
        public void run() {
            try {
                System.out.println("Started:" + Thread.currentThread().getId());
                Thread.sleep(3000);
                System.out.println("Finished:" + Thread.currentThread().getId());
            } catch (InterruptedException e) {
                e.printStackTrace(System.out);
            }
        }
    }

    static class MyCallable3 implements Callable<String> {  // позволяет возвращать некоторое значение
        @Override
        public String call() {
            try {
                System.out.println("Started:" + Thread.currentThread().getId()); // or Thread.currentThread().getClass().getSimpleName()
                Thread.sleep(3000);
                System.out.println("Finished:" + Thread.currentThread().getId());
            } catch (InterruptedException e) {
                e.printStackTrace(System.out);
            }
            return "MyCallable3 is done";
        }
    }
}
