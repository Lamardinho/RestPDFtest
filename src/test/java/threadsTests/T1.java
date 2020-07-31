package threadsTests;

import java.util.concurrent.*;

public class T1 {

    public static void main(String[] args) throws InterruptedException {
        CountDownLatch cdl1 = new CountDownLatch(5);
        CountDownLatch cdl2 = new CountDownLatch(5);
        CountDownLatch cdl3 = new CountDownLatch(5);
        CountDownLatch cdl4 = new CountDownLatch(5);

        ExecutorService es = Executors.newFixedThreadPool(2);

        System.out.println("Запуск потоков");
        es.execute(new MyThread(cdl1, "А"));
        es.execute(new MyThread(cdl2, "В"));
        es.execute(new MyThread(cdl3, "С"));
        es.execute(new MyThread(cdl4, "D"));
        cdl1.await();
        cdl2.await();
        cdl3.await();
        cdl4.await();
        es.shutdown();
        System.out.println("Завершение потоков");
    }

    static class MyThread implements Runnable {
        String name;
        CountDownLatch latch;

        MyThread(CountDownLatch latch, String name) {
            this.latch = latch;
            this.name = name;
        }

        public void run() {
            for (int i = 0; i < 5; i++) {
                System.out.println(name + "· " + i);
                latch.countDown();
            }
        }
    }
}
