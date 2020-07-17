package com.rest.app.dataBase

object MyPdfFiles {
    fun getMyReport(): String { // путь на PDF файл "одинаковый"
        return "src/main/resources/PDFoutput/myReport.pdf"
    }

    fun getMyReport2(): String { // путь на PDF файл "одинаковый"
        return "src/main/resources/PDFoutput/myReport2.pdf"
    }

    fun getMyReport3(): String { // путь на PDF файл "отличается"
        return "src/main/resources/PDFoutput/myReport3.pdf"
    }
}
