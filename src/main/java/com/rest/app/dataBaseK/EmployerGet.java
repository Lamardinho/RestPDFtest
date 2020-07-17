package com.rest.app.dataBaseK;

public class EmployerGet {
    private final Employer employerEng = new Employer("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987");
    private final Employer employerRus = new Employer("Илья Слезкин", "Разработчик", "8-963-01-65-023", "16.04.1987");

    public Employer getEnglish() {
        return employerEng;
    }

    public Employer getRussian() {
        return employerRus;
    }
}
