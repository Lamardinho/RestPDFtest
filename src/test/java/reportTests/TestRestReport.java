package reportTests;

import com.rest.app.dataBaseK.MyPdfURLs;
import com.rest.app.makePDF.ReportPDF;
import com.rest.app.webRestApi.RestPDFBuffer;
import net.sf.jasperreports.engine.JRException;
import org.junit.Test;

import javax.ws.rs.core.Response;
import java.io.File;
import java.io.IOException;

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

    @Test
    public void testBuffer() throws IOException, JRException {
        RestPDFBuffer restPDFBuffer = new RestPDFBuffer();
        restPDFBuffer.createPDFReport("asd");
    }
}
