package jdbcTests.anyTests;

import threadsTests.tests3.TestMyTPEJava;
import org.junit.Test;

import java.util.concurrent.ExecutionException;

public class Test1 {
    @Test
    public void test1() throws ExecutionException, InterruptedException {
        TestMyTPEJava test123 = new TestMyTPEJava();
        test123.runTasks();
    }
}
