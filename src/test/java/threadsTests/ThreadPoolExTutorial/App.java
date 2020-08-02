package threadsTests.ThreadPoolExTutorial;

import threadsTests.ThreadPoolExTutorial.model.DateActivity;

import java.util.concurrent.atomic.AtomicBoolean;

public class App {
    public static void main(String[] args) {
        new App().runApp();
    }

    public void runApp() {
        System.out.println("Program Started");
        AtomicBoolean processing = new AtomicBoolean(true);
        RemoteService remoteService = new RemoteService();

        remoteService.getUserRecentActivities(activities -> {
            for (DateActivity dateActivity : activities) {
                System.out.println(dateActivity);
            }
            processing.set(false);
        });

        while (processing.get()) {
            // keep running
        }
        remoteService.stop();
        System.out.println("Program Terminated");
    }
}
