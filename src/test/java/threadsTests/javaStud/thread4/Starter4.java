package threadsTests.javaStud.thread4;

//https://youtu.be/GtHe_wzJsWo?list=PLyxk-1FCKqodhV1d55ZmoAcz6aeyhLxnr

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

public class Starter4 {

    public static void main(String[] args) throws Exception {
        new Starter4().test1();
        new Starter4().test2();
        new Starter4().test3();
    }

    // .submit()
    public void test1() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(10);
        List<Future<Long>> tasks = new ArrayList<>();   // Массив<Ответов<Лонгов>>

        for (int i = 0; i < 3; i++) {
            MyCallable4 myCallable4 = new MyCallable4();
            Future<Long> submit = es.submit(myCallable4);     // позволяет запустить задачу и получить какую то инфу в отличии от execute
            tasks.add(submit);
        }

        for (Future<Long> f : tasks) f.get();   // для вывода состояния (ответа)

        es.shutdown();
        System.out.println("--------- FINISH ---------");
    }

    // .invokeAll()
    public void test2() throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(10);
        List<MyCallable4> tasks = new ArrayList<>();    // создаем задачи и помещаем их в единый список (ниже через tasks.add(myCallable4))
        for (int i = 0; i < 3; i++) {
            MyCallable4 myCallable4 = new MyCallable4();
            tasks.add(myCallable4);                     // наполняем список задачами
        }

        List<Future<Long>> futures = es.invokeAll(tasks);               // запустить все задачи, которые у нас есть
        for (Future<Long> f : futures) System.out.println(f.get());     // напечатать список выполненных задач

        System.out.println("--------- FINISH ---------");
        es.shutdown();
    }

    // .invokeAny()
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

    static class MyCallable4 implements Callable<Long> {
        @Override
        public Long call() {
            try {
                System.out.println("Started:" + Thread.currentThread().getId());
                Thread.sleep(3000 + Math.round(Math.random() * 5000));
                System.out.println("Finished:" + Thread.currentThread().getId());
            } catch (Exception e) {
                e.printStackTrace(System.out);
            }
            return Thread.currentThread().getId();
        }
    }
}
