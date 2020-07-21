package reportTests;

import com.rest.app.dataBase.MyPdfURLs;
import com.rest.app.zJavaClasses.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;
import org.junit.Test;

import javax.ws.rs.core.Response;
import java.io.File;

// *********  сохранение файла на ДИСК

public class TestRestReport {
    public Response createPDFReport(String gName) throws JRException {
        //String user = System.getProperty("user.name"); // определяет имя пользователя системы
        ReportPDF reportPDF = new ReportPDF();
        reportPDF.makeRestReport(gName); // генерируем
        File pdfFile = new File(MyPdfURLs.INSTANCE.getExportPDF(gName));
        return Response.ok().entity(pdfFile).header(
                "Content-disposition", "attachment; filename=\"+" + gName + ".pdf\"").build();
    }

    @Test
    public void testRest() throws JRException {
        createPDFReport("testtesttest");
    }
}
