package ThreadsTests.Tests2;

public class Counter {

    public static void main(String[] args) {
        Counter counter = new Counter();
        counter.count(10);
    }

    public Double count(double a) {
        for (int i = 100000; i > 0; i--) {
            a = a + Math.tan(a);
            System.out.println(a + " " + i);
        }
        return a;
    }
}
