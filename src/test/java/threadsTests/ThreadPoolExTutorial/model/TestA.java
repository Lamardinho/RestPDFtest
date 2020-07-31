package threadsTests.ThreadPoolExTutorial.model;

import java.util.Date;

public class TestA implements DateActivity {
    private final Date date;

    public TestA(Date date) {
        this.date = date;
    }

    @Override
    public Date getDateNow() {
        return date;
    }

    @Override
    public String toString() {
        return "TestA{" +
                "date=" + date +
                '}';
    }
}
