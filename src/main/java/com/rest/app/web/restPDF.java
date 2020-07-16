package com.rest.app.web;

import com.rest.app.makePDF.ReportPDF;
import net.sf.jasperreports.engine.JRException;

import javax.ws.rs.GET;
import javax.ws.rs.Path;

@Path("/pdf")
public class restPDF {
    @GET
    public String makeReport() throws JRException {
        ReportPDF reportPDF = new ReportPDF();
        reportPDF.makeTestReport();
        return "Done: 'testRestReport' ";
    }
}
