package com.rest.app.makePDF

import com.rest.app.dataBase.Employer
import com.rest.app.dataBase.EmployerGet
import com.rest.app.dataBase.GetMap
import com.rest.app.dataBase.MyPdfURLs.getDirWay
import com.rest.app.dataBase.MyPdfURLs.getExportPDF
import com.rest.app.dataBase.MyPdfURLs.getMyReportJrxml
import net.sf.jasperreports.engine.*
import java.io.File

class ReportPDF {
    private val employerGet = EmployerGet()     // ссылка на класс с сотрудниками
    private val getMap = GetMap()   // ссылка на мапу

    // генерирует PDF на сервере
    @Throws(JRException::class)
    fun makeReport(employer: Employer, reportName: String) {
        // DataSource. This is simple example, no database. Then using empty datasource
        val dataSource: JRDataSource = JREmptyDataSource() // обязательно использовать! без него будут пустые отчеты
        // от куда берём jrxml файл
        val jrxmlFile = JasperCompileManager.compileReport(getMyReportJrxml())
        // JasperPrint - заполняем шаблон
        val jasperPrint = JasperFillManager.fillReport(jrxmlFile, getMap.getFillMap(employer), dataSource)
        // проверка и создание пути для экспорта PDF файла
        val outDir = File(getDirWay())
        outDir.mkdirs()
        // Экспорт данных в PDF файл
        JasperExportManager.exportReportToPdfFile(jasperPrint, getExportPDF(reportName))    // ,(заполненный шаблон, путь(имя))
        // для отчёта
        println("method makeReport is done! New file created: $reportName")
    }

    // для RESTа - генерирует PDF на сервере
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
