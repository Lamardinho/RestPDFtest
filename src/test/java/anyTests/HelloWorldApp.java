package anyTests;

public class HelloWorldApp {
    /*public static void main(String []args){
        Thread currentThread = Thread.currentThread();
        ThreadGroup threadGroup = currentThread.getThreadGroup();
        System.out.println("Thread: " + currentThread.getName());
        System.out.println("Thread Group: " + threadGroup.getName());
        System.out.println("Parent Group: " + threadGroup.getParent().getName());
    }*/

    public static void main(String[] args) {
        Thread th = Thread.currentThread();
        th.setUncaughtExceptionHandler((t, e) -> System.out.println("Возникла ошибка: " + e.getMessage()));
        System.out.println(10 / 2);
        System.out.println(10 / 0);
    }
}
