package com.rest.app.dataBase

object MyPdfURLs {
    fun getMyReportJrxml(): String { // путь на PDF файл "одинаковый"
        return "D:/JavaProjects/RestPDFtest/src/main/resources/templates/myReport.jrxml"
    }

    fun getDirWay(): String { // путь на PDF файл "одинаковый"
        return "D:/JavaProjects/RestPDFtest/src/main/resources/PDFoutput"
    }

    fun getExportPDF(reportName: String): String { // путь на PDF файл "отличается"
        return "D:/JavaProjects/RestPDFtest/src/main/resources/PDFoutput/$reportName.pdf"
    }
}
