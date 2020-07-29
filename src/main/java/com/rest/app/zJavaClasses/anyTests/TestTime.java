package com.rest.app.zJavaClasses.anyTests;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class TestTime {
    private String myDate() {
        final DateTimeFormatter MyDate = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        LocalDateTime MyNow = LocalDateTime.now();
        return MyDate.format(MyNow);
    }

    // private static final DateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    private static final DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");

    public static void main(String[] args) {
        TestTime testTime = new TestTime();

       /* Date date = new Date();
        System.out.println(sdf.format(date));

        Calendar cal = Calendar.getInstance();
        System.out.println(sdf.format(cal.getTime()));

        LocalDateTime now = LocalDateTime.now();
        System.out.println(dtf.format(now));

        LocalDate localDate = LocalDate.now();
        System.out.println(DateTimeFormatter.ofPattern("yyy-MM-dd").format(localDate));*/


        final DateTimeFormatter MyDate = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        LocalDateTime MyNow = LocalDateTime.now();
        System.out.println(MyDate.format(MyNow));

        System.out.println("testTime.myDate() = " + testTime.myDate());
    }
}
