package threadsTests.zOthers;

import java.util.concurrent.*;

public class HelloWorldApp2 {
    public static void main(String[] args) {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(1, 1,
                0L, TimeUnit.SECONDS, new SynchronousQueue<>());
        Callable<String> task = () -> Thread.currentThread().getName();
        threadPoolExecutor.setRejectedExecutionHandler((runnable, executor) -> System.out.println("Rejected"));
        for (int i = 0; i < 5; i++) {
            threadPoolExecutor.submit(task);
        }
        threadPoolExecutor.shutdown();
    }
}
