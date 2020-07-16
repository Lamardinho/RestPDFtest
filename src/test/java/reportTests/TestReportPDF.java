package reportTests;

import com.rest.app.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;
import org.junit.Test;

public class TestReportPDF {

    @Test
    public void makeReportTest() throws JRException {  // создаем файлы.pdf
        ReportPDF reportPDF = new ReportPDF();
        reportPDF.makeReport(reportPDF.getEmployerEng(), "myReport");
        reportPDF.makeReport(reportPDF.getEmployerRus(), "myReport3");
    }

    @Test
    public void makeTestR() throws JRException {  // создаем файлы.pdf
        ReportPDF reportPDF = new ReportPDF();
        reportPDF.makeTestReport();
    }
}
