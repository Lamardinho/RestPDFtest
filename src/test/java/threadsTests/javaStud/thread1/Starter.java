package threadsTests.javaStud.thread1;

// https://youtu.be/HeQZTYbQVZI?list=PLyxk-1FCKqodhV1d55ZmoAcz6aeyhLxnr

public class Starter {

    public static void main(String[] args) {

        for (int i = 0; i < 5; i++) {
            new MyThread().start();
        }

        for (int i = 0; i < 5; i++) {
            new Thread(new MyRunnable()).start();
        }

    }

    private static class MyRunnable implements Runnable {
        @Override
        public void run() {
            try {
                System.out.println("Start Runnable: " + Thread.currentThread().getId());
                Thread.sleep(5000);
                System.out.println("Finish Runnable: " + Thread.currentThread().getId());
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
