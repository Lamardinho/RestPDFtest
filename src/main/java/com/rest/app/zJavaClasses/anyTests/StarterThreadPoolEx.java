package com.rest.app.zJavaClasses.anyTests;

import java.util.concurrent.*;

public class StarterThreadPoolEx {
    ThreadPoolExecutor es = new ThreadPoolExecutor(
            2, 4, 1, TimeUnit.MILLISECONDS, new LinkedBlockingDeque<>(2), new MyReject());

    ThreadPoolExecutor es2 = new ThreadPoolExecutor(
            2, 4, 1, TimeUnit.MILLISECONDS, new SynchronousQueue<>(), new MyReject());

    public void startMy(ThreadPoolExecutor th) {
        for (int i = 0; i < 7; i++) {
            MyCallable mc = new MyCallable();
            th.submit(mc);
        }
        th.shutdown();
    }

    public static void main(String[] args) {
        StarterThreadPoolEx starter = new StarterThreadPoolEx();
        starter.startMy(starter.es);
        System.out.println("\n-----------------------\n");
        starter.startMy(starter.es2);
    }
}

class MyReject implements RejectedExecutionHandler {

    @Override
    public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
        System.out.println("REJECTED");
    }
}

class MyCallable implements Callable<Long> {
    @Override
    public Long call() {
        try {
            System.out.println("Thread started: " + Thread.currentThread().getId());
            Thread.sleep(2000);
            System.out.println("Thread finished: " + Thread.currentThread().getId() + "\n");
        } catch (Exception ex) {
            ex.printStackTrace(System.out);
        }
        return Thread.currentThread().getId();
    }
}
