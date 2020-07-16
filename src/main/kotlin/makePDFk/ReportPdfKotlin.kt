package makePDFk

import dataBaseK.Employer
import net.sf.jasperreports.engine.*
import java.io.File
import java.util.HashMap

class ReportPdfKotlin {
    // сотрудники, для вставки данных в отчет
    val employerEng = Employer("Ilya Slezkin", "Developer", "8-963-01-65-023", "16.04.1987")
    val employerRus = Employer("Илья Слезкин", "Разработчик", "8-963-01-65-023", "16.04.1987")


    @Throws(JRException::class)
    fun makeReport(employer: Employer, name: String) {
        val parameters: MutableMap<String, Any?> = HashMap() // Parameters for report
        // Parameters for report // можно переписать параметры в методе, если переменная более в 2ух методах
        parameters["jr_name"] = employer.jrName
        parameters["jr_position"] = employer.jrPosition
        parameters["jr_phone_mobile"] = employer.jrPhoneMobile
        parameters["jr_data_birthday"] = employer.jrDataBirthday
        // DataSource. This is simple example, no database. Then using empty datasource
        val dataSource: JRDataSource = JREmptyDataSource()
        // от куда берём jrxml файл
        val jrxmlFile = JasperCompileManager.compileReport("src/main/resources/templates/myReport.jrxml")
        // JasperPrint
        val jasperPrint = JasperFillManager.fillReport(jrxmlFile, parameters, dataSource)
        // Make sure the output directory exists
        val outDir = File("src/main/resources/PDFoutput") // проверка и создание пути для экспорта PDF файла
        outDir.mkdirs()
        // Export to PDF.  "путь/имя экспортируемого PDF файла"
        JasperExportManager.exportReportToPdfFile(jasperPrint, "src/main/resources/PDFoutput/$name.pdf")
        println("Done!")
    }
}