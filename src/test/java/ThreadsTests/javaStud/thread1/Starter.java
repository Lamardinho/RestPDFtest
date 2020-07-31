package ThreadsTests.javaStud.thread1;

public class Starter {
    public static void main(String[] args) {
        for (int i = 0; i < 5; i++) {
            MyThread myThread = new MyThread();
            myThread.start();
        }

        for (int i = 0; i < 5; i++) {
            MyRunnable myRunnable = new MyRunnable();
            Thread thread = new Thread(myRunnable);
            thread.start();
        }
    }

    private static class MyRunnable implements Runnable {
        @Override
        public void run() {
            try {
                System.out.println("Start Thread: " + Thread.currentThread().getId());
                Thread.sleep(5000);
                System.out.println("Finish Thread: " + Thread.currentThread().getId());
            } catch (Exception e) {
                e.printStackTrace(System.out);
            }
        }
    }

    private static class MyThread extends Thread {
        @Override
        public void run() {
            try {
                System.out.println("Start Thread: " + getId());
                Thread.sleep(5000);
                System.out.println("Finish Thread: " + getId());
            } catch (Exception e) {
                e.printStackTrace(System.out);
            }
        }
    }
}
