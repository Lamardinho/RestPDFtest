package threadsTests.ThreadPoolExTutorial.model;

import java.util.Date;

public class TestC implements DateActivity {
    private final Date date;

    public TestC(Date date) {
        this.date = date;
    }

    @Override
    public Date getDateNow() {
        return date;
    }

    @Override
    public String toString() {
        return "TestC{" +
                "date=" + date +
                '}';
    }
}
