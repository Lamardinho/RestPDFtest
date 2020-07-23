package jdbcTests

import com.rest.app.jdbc.SqlOrders
import java.sql.SQLException
import kotlin.test.Test

class TestsSqlOrders {
    private val sqlOrders = SqlOrders()

    @Test
    @Throws(SQLException::class)
    fun test() {
        sqlOrders.selectByName("Marcus")
    }
}
