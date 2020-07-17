package reportTests;

import com.rest.app.dataBaseK.EmployerGet;
import com.rest.app.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;
import org.junit.Test;

public class TestReportPDF {
    private final ReportPDF reportPDF = new ReportPDF();
    private final EmployerGet employer = new EmployerGet();

    @Test
    public void makeReportTest() throws JRException {  // создаем файлы.pdf
        reportPDF.makeReport(employer.getEnglish(), "myReport");
        reportPDF.makeReport(employer.getRussian(), "myReport3");
    }

    @Test
    public void makeTestR() throws JRException {  // создаем файлы.pdf
        ReportPDF reportPDF = new ReportPDF();
        reportPDF.makeTestReport();
    }
}
