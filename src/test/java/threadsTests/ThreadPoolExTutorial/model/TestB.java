package threadsTests.ThreadPoolExTutorial.model;

import java.util.Date;

public class TestB implements DateActivity {
    private final Date date;

    public TestB(Date date) {
        this.date = date;
    }

    @Override
    public Date getDateNow() {
        return date;
    }

    @Override
    public String toString() {
        return "TestB{" +
                "date=" + date +
                '}';
    }
}
