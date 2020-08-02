package threadsTests.javaStud.thread2;

// https://youtu.be/DvkyCzEs5yQ?list=PLyxk-1FCKqodhV1d55ZmoAcz6aeyhLxnr

import org.jetbrains.annotations.NotNull;
import org.junit.Test;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;

public class Starter2 {

    public static void main(String[] args) throws InterruptedException {
        Starter2 starter2 = new Starter2();

        starter2.test4();
        // starter2.test2();
        // starter2.test3();
        // starter2.test4();
    }

    public void test1() {
        System.out.println("Start test1():\n");
        ExecutorService es = Executors.newCachedThreadPool();       // создает набор потоков
        for (int i = 0; i < 30; i++) es.submit(new MyRunnable2());  // создаем пул задач
        es.shutdown();
    }

    public void test2() throws InterruptedException {
        System.out.println("Start test2():\n");
        ExecutorService es = Executors.newWorkStealingPool();       // запускает сразу количество потоков равное кол-ву ядер процессора
        for (int i = 0; i < 12; i++) {  // создаем пул задач
            es.submit(new MyRunnable2());
        }
        es.awaitTermination(7000, TimeUnit.MILLISECONDS);
    }

    public void test3() {
        System.out.println("Start test3():\n");
        ExecutorService es = Executors.newFixedThreadPool(4);   // создание определенного кол-ва потоков
        for (int i = 0; i < 12; i++) es.submit(new MyRunnable2());      // создаем пул задач
        es.shutdown();
    }

    public void test4() { // в этом случае при создании очередного потока, будет создаваться тот поток, который нам нужен
        System.out.println("Start test4():\n");
        ExecutorService es = Executors.newFixedThreadPool(10, new MyFactory());
        for (int i = 0; i < 20; i++) {  // создаем пул задач
            es.submit(new MyRunnable2());
        }
        es.shutdown();
    }

    private static class MyRunnable2 implements Runnable {
        @Override
        public void run() {
            try {
                System.out.println("Start Thread: " + Thread.currentThread().getId());
                // System.out.println("Start Thread: " + Thread.currentThread().getClass().getSimpleName());
                Thread.sleep(3000);
                System.out.println("Finish Thread: " + Thread.currentThread().getId());
            } catch (Exception e) {
                e.printStackTrace(System.out);
            }
        }
    }

    private static class MyFactory implements ThreadFactory {
        @Override
        public Thread newThread(@NotNull Runnable r) {
            return new SimpleThread(r);
        }
    }

    private static class SimpleThread extends Thread {
        public SimpleThread(Runnable target) {
            super(target);
        }
    }
}
