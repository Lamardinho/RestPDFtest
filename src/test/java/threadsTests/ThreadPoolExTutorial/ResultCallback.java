package threadsTests.ThreadPoolExTutorial;

import threadsTests.ThreadPoolExTutorial.model.DateActivity;

import java.util.List;

public interface ResultCallback {
    void onResult(List<DateActivity> dateActivityList);
}
