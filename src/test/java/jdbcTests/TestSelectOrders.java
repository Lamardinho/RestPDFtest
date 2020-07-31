package jdbcTests;

import com.rest.app.dataBase.tables.OrderTable;
import com.rest.app.webRest.java.SelectOrdersByName_Java;
import org.junit.Test;

import java.sql.*;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class TestSelectOrders {

    public Collection<OrderTable> mainHome() throws ClassNotFoundException, SQLException {
        Class.forName("org.postgresql.Driver");
        final Map<Integer, OrderTable> ordersMap = new ConcurrentHashMap<>();
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM rtk.public.select_orders()")) {
            getExecuteQuery(ordersMap, statement);
        }
        return ordersMap.values();
    }

    public Collection<OrderTable> mainHome(String userName) throws ClassNotFoundException, SQLException {
        Class.forName("org.postgresql.Driver");
        final Map<Integer, OrderTable> ordersMap = new ConcurrentHashMap<>();
        try (Connection connection = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/rtk", "postgres", "post@post23");
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM rtk.public.select_orders(?)")) {
            statement.setString(1, userName);   // Name - это (?) из запроса
            getExecuteQuery(ordersMap, statement);
        }
        return ordersMap.values();
    }

    private void getExecuteQuery(Map<Integer, OrderTable> ordersMap, PreparedStatement statement) throws SQLException {
        try (final ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                OrderTable order = new OrderTable();
                order.setOrderNumber(resultSet.getInt(1));
                order.setTimestamp(resultSet.getTimestamp(2));
                order.setCustomer(resultSet.getString(3));
                order.setService(resultSet.getString(4));
                order.setPay(resultSet.getInt(5));

                ordersMap.put(order.getOrderNumber(), order);
                System.out.println(order);
            }
        }
    }

    @Test
    public void test2() throws SQLException, ClassNotFoundException {
        SelectOrdersByName_Java selectOrdersByName = new SelectOrdersByName_Java();
        selectOrdersByName.mainHome();
    }

    @Test
    public void test1() throws SQLException, ClassNotFoundException {
        mainHome();
    }

    @Test
    public void test3() throws SQLException, ClassNotFoundException {
        mainHome("Bob");
    }
}
