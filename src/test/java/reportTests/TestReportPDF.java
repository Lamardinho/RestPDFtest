package reportTests;

import com.rest.app.dataBase.EmployeeGet;
import com.rest.app.zJava.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;
import org.junit.Test;

public class TestReportPDF {
    private final ReportPDF reportPDF = new ReportPDF();
    private final EmployeeGet employeeGet = new EmployeeGet();

    @Test
    public void makeReportTest() throws JRException {  // создаем файлы.pdf
        reportPDF.makeReport(employeeGet.getEnglish(), "myReport");
        reportPDF.makeReport(employeeGet.getRussian(), "myReport3");
    }
}
