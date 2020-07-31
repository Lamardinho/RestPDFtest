package threadsTests.ThreadPoolExTutorial.model;

import java.util.Date;

public class TestD implements DateActivity {
    private final Date date;

    public TestD(Date date) {
        this.date = date;
    }

    @Override
    public Date getDateNow() {
        return date;
    }

    @Override
    public String toString() {
        return "TestD{" +
                "date=" + date +
                '}';
    }
}
