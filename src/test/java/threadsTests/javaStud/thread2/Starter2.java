package threadsTests.javaStud.thread2;

import org.jetbrains.annotations.NotNull;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;

public class Starter2 {
    public static void main(String[] args) throws InterruptedException {
        Starter2 starter2 = new Starter2();
        /*starter2.test1();
        starter2.test2();
        starter2.test3();*/
        starter2.test4();
    }

    public void test1() {
        ExecutorService es = Executors.newCachedThreadPool();   // создает набор потоков
        for (int i = 0; i < 20; i++) {  // создаем пул задач
            es.submit(new MyRunnable2());
        }
    }

    public void test2() throws InterruptedException {
        ExecutorService es = Executors.newWorkStealingPool();   // запускает сразу количество потоков равное кол-ву ядер процессора
        for (int i = 0; i < 20; i++) {  // создаем пул задач
            es.submit(new MyRunnable2());
        }
        es.awaitTermination(30000, TimeUnit.MILLISECONDS);
    }

    public void test3() {
        ExecutorService es = Executors.newFixedThreadPool(10);  // создание определенного кол-ва потоков
        for (int i = 0; i < 20; i++) {  // создаем пул задач
            es.submit(new MyRunnable2());
        }
    }

    public void test4() { // в этом случае при создании очередного потока, будет создаваться тот поток, который нам нужен
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
                System.out.println("Start Thread: " + Thread.currentThread().getClass().getSimpleName());
                Thread.sleep(5000);
                System.out.println("ждем 5 секунд" + " -------------");
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



