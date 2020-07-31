package ThreadsTests.javaStud.thread4;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

public class Starter4 {

    static class MyCallable4 implements Callable<Long> {
        @Override
        public Long call() {
            try {
                System.out.println("Started:" + Thread.currentThread().getId());
                Thread.sleep(1000 + (Math.round(Math.random() * 5000)));
                System.out.println("Finished:" + Thread.currentThread().getId());
            } catch (Exception e) {
                e.printStackTrace(System.out);
            }
            return Thread.currentThread().getId();
        }
    }

    public void test1() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(10);
        List<Future<Long>> tasks = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            MyCallable4 myCallable4 = new MyCallable4();
            Future<Long> submit = es.submit(myCallable4);     // позволяет запустить задачу и получить какую то инфу
            tasks.add(submit);
        }
        for (Future<Long> f : tasks) {
            f.get();
        }
        System.out.println("--------- FINISH ---------");
        es.shutdown();
    }

    public void test2() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(10);
        List<MyCallable4> tasks = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            MyCallable4 myCallable4 = new MyCallable4();
            tasks.add(myCallable4);     // наполняем список задачами
        }
        List<Future<Long>> futures = es.invokeAll(tasks);  // запустить все задачи, которые у нас есть
        for (Future<Long> f : futures) System.out.println(f.get()); // напечатать список выполненных задач
        System.out.println("--------- FINISH ---------");
        es.shutdown();
    }

    public void test3() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(10);
        List<MyCallable4> tasks = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            MyCallable4 myCallable4 = new MyCallable4();
            tasks.add(myCallable4);     // наполняем список задачами
        }
        Long aLong = es.invokeAny(tasks);
        System.out.println(aLong);
        System.out.println("--------- FINISH ---------");
        es.shutdown();
    }

    public static void main(String[] args) throws Exception {
        Starter4 starter4 = new Starter4();
        starter4.test3();
    }
}
