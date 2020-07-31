package threadsTests.ThreadPoolExTutorial;

import threadsTests.ThreadPoolExTutorial.model.*;

import java.util.*;
import java.util.concurrent.*;

public class RemoteService {
    private final int cores = Runtime.getRuntime().availableProcessors();
    private final ExecutorService executorThreadPool = Executors.newFixedThreadPool(cores + 1);

    public void getUserRecentActivities(ResultCallback resultCallback) { //void onResult(List<DateActivity> dateActivityList);
        executorThreadPool.execute(() -> {
            List<TestA> testAs = new ArrayList<>();
            List<TestB> testBs = new ArrayList<>();
            List<TestC> testCs = new ArrayList<>();
            List<TestD> testDs = new ArrayList<>();

            Future<List<TestA>> futureTestAs = executorThreadPool.submit(getTestAs());
            Future<List<TestB>> futureTestBs = executorThreadPool.submit(getTestBs());
            Future<List<TestC>> futureTestCs = executorThreadPool.submit(getTestCs());
            Future<List<TestD>> futureTestDs = executorThreadPool.submit(getTestDs());

            try {
                testAs = futureTestAs.get();
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }

            try {
                testBs = futureTestBs.get();
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }

            try {
                testCs = futureTestCs.get();
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }

            try {
                testDs = futureTestDs.get();
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }

            List<DateActivity> dateActivities = new ArrayList<>();
            dateActivities.addAll(testAs);
            dateActivities.addAll(testBs);
            dateActivities.addAll(testCs);
            dateActivities.addAll(testDs);

            dateActivities.sort(Comparator.comparing(DateActivity::getDateNow));
            resultCallback.onResult(dateActivities);
        });
    }

    public void stop() {
        executorThreadPool.shutdown();
    }

    private Callable<List<TestA>> getTestAs() {
        return () -> {
            System.out.println("getTestAs");
            Thread.sleep(500);
            return Collections.singletonList(new TestA(new Date()));
            //  return Arrays.asList(new TestA(new Date()), new TestA(new Date()));
        };
    }

    private Callable<List<TestB>> getTestBs() {
        return () -> {
            System.out.println("getTestBs");
            Thread.sleep(1500);
            return Collections.singletonList(new TestB(new Date()));
        };
    }

    private Callable<List<TestC>> getTestCs() {
        return () -> {
            System.out.println("getTestCs");
            Thread.sleep(2500);
            return Collections.singletonList(new TestC(new Date()));
        };
    }

    private Callable<List<TestD>> getTestDs() {
        return () -> {
            System.out.println("getTestDs");
            Thread.sleep(3500);
            return Collections.singletonList(new TestD(new Date()));
            //  return Arrays.asList(new TestD(new Date()), new TestD(new Date()));
        };
    }
}
