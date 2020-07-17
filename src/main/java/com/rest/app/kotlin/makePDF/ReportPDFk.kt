package com.rest.app.kotlin.makePDF

import com.rest.app.dataBaseK.Employer
import com.rest.app.dataBaseK.EmployerGet
import com.rest.app.dataBaseK.GetMap
import com.rest.app.dataBaseK.MyPdfURLs.getDirWay
import com.rest.app.dataBaseK.MyPdfURLs.getExportPDF
import com.rest.app.dataBaseK.MyPdfURLs.getMyReportJrxml
import net.sf.jasperreports.engine.*
import java.io.File

class ReportPDFk {
    private val employerGet = EmployerGet()
    private val getMap = GetMap()

    @Throws(JRException::class)
    fun makeReport(employer: Employer, reportName: String) {
        // DataSource. This is simple example, no database. Then using empty datasource
        val dataSource: JRDataSource = JREmptyDataSource() // обязательно использовать! без него будут пустые отчеты
        // от куда берём jrxml файл
        val jrxmlFile = JasperCompileManager.compileReport(getMyReportJrxml())
        // JasperPrint
        val jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employer), dataSource)
        // проверка и создание пути для экспорта PDF файла
        val outDir = File(getDirWay())
        outDir.mkdirs()
        // Export to PDF.  "путь/имя экспортируемого PDF файла"
        JasperExportManager.exportReportToPdfFile(jasperPrint, getExportPDF(reportName))
        //JasperExportManager.exportReportToPdfStream(jasperPrint,);
        println("method makeReport is done! New file created: $reportName")
    }

    // для RESTа
    @Throws(JRException::class)
    fun makeRestReport(userName: String) {
        val dataSource: JRDataSource = JREmptyDataSource()
        val jrxmlFile = JasperCompileManager.compileReport(getMyReportJrxml())
        val jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employerGet.getEnglish()), dataSource)
        val outDir = File(getDirWay())
        outDir.mkdirs()
        JasperExportManager.exportReportToPdfFile(jasperPrint, getExportPDF(userName))
        println("method makeTestReport is done! New file created :" + getExportPDF(userName))
    }
}