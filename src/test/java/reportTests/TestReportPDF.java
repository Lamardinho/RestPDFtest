package reportTests;

import com.rest.app.dataBase.EmployerGet;
import com.rest.app.zJava.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;
import org.junit.Test;

public class TestReportPDF {
    private final ReportPDF reportPDF = new ReportPDF();
    private final EmployerGet employerGet = new EmployerGet();

    @Test
    public void makeReportTest() throws JRException {  // создаем файлы.pdf
        reportPDF.makeReport(employerGet.getEnglish(), "myReport");
        reportPDF.makeReport(employerGet.getRussian(), "myReport3");
    }
}
