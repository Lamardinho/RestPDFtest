package com.rest.app.dataBase

import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

object MyDate {
    fun getNowDate(): String {
        return DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss").format(LocalDateTime.now())
    }
}
