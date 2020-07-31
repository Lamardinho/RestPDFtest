package threadsTests;

import org.junit.Test;
import threadsTests.tests3.TestMyTPEJava;

import java.util.concurrent.ExecutionException;

public class Test5 {
    @Test
    public void test1() throws ExecutionException, InterruptedException {
        new TestMyTPEJava().runTasks();
    }
}
