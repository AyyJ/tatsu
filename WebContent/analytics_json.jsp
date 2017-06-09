<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.lang.*, org.json.*, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="main.js"></script>
<title>Sales Analytics - JSON</title>
</head>
<body>
<%
if (session.getAttribute("roleName") != null) {
    String role = session.getAttribute("roleName").toString();
    if ("owner".equalsIgnoreCase(role) == true) {
        Connection con = ConnectionManager.getConnection();
        CategoryDAO categoryDao = new CategoryDAO(con);
        List < CategoryModel > category_list = categoryDao.getCategories();
        con.close();

        String filter = request.getParameter("filter");;
        if (filter == null)
            filter = "all";

        ArrayList < String > consumers = new ArrayList < String > ();
        ArrayList < String > products = new ArrayList < String > ();
        int sum = 0;
        int sum2 = 0;

        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmt2 = null;
        ResultSet rs3 = null;
        ResultSet rs = null;
        ResultSet rs2 = null;
        ResultSet rs4 = null;
        JSONObject jObject = new JSONObject();


        try {
            // Registering Postgresql JDBC driver with the DriverManager
            Class.forName("org.postgresql.Driver");

            // Open a connection to the database using DriverManager
            conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost/Tatsu?" +
                "user=postgres&password=postgres1");

            if (filter.equals("all")) {

                // top k state ordering, filter by all
                pstmt = conn.prepareStatement("select s.state_name, sum(s.sum) as sum from(" +
                    "select state.state_name, sum(products_in_cart.quantity * products_in_cart.price)as sum from state,person, shopping_cart,products_in_cart " +
                    "where person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and " +
                    "person.state_id = state.id group by state.state_name " +
                    "union " +
                    "select state.state_name, '0' from state)s " +
                    "group by s.state_name order by sum desc");
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    pstmt2 = conn.prepareStatement("select prod.product_name, sum(prod.sum)as total " +
                        "from(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum " +
                        "from state, product,person,shopping_cart,products_in_cart " +
                        "where state.state_name = ? and person.state_id = state.id and " +
                        "person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and " +
                        "product.id = products_in_cart.product_id group by product_name " +
                        "union " +
                        "select product_name,'0' from product)prod " +
                        "group by prod.product_name order by total desc");
                    pstmt2.setString(1, rs.getString("state_name"));
                    rs2 = pstmt2.executeQuery();
                    while (rs2.next()) {
                        products.add(rs2.getString("product_name"));
                    }
                }
                rs3 = pstmt.executeQuery();
                while (rs3.next()) {
                    consumers.add(rs3.getString("state_name"));
                }
            } else {

                // top k state ordering, filter by category
                pstmt = conn.prepareStatement("select s.state_name, sum(s.sum)as total " +
                    "from(select state.state_name, sum(products_in_cart.quantity * products_in_cart.price)as sum " +
                    "from state,person, shopping_cart,products_in_cart,product,category " +
                    "where person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and " +
                    "person.state_id = state.id and products_in_cart.product_id = product.id and " +
                    "product.category_id = category.id and category.category_name = ? group by state.state_name " +
                    "union " +
                    "select state.state_name, '0' from state)s " +
                    "group by s.state_name order by total desc");
                pstmt.setString(1, filter);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    pstmt2 = conn.prepareStatement("select prod.product_name, sum(prod.sum)as total " +
                        "from(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum " +
                        "from state, product,person,shopping_cart,products_in_cart,category " +
                        "where state.state_name = ? and person.state_id = state.id and " +
                        "person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and " +
                        "product.id = products_in_cart.product_id and product.category_id = category.id and " +
                        "category.category_name = ? group by product_name " +
                        "union " +
                        "select product_name,'0'  from product,category " +
                        "where category.id = product.category_id and category.category_name = ? )prod " +
                        "group by prod.product_name order by total desc");
                    pstmt2.setString(1, rs.getString("state_name"));
                    pstmt2.setString(2, filter);
                    pstmt2.setString(3, filter);
                    rs2 = pstmt2.executeQuery();
                    while (rs2.next()) {
                        products.add(rs2.getString("product_name"));
                    }

                }
                pstmt.setString(1, filter);
                rs3 = pstmt.executeQuery();
                while (rs3.next()) {
                    consumers.add(rs3.getString("state_name"));
                }
            }
            
            //done with columns and rows
            JSONArray jArray = new JSONArray();
            for (String prod: products) {
                pstmt = conn.prepareStatement("SELECT SUM(products_in_cart.price * products_in_cart.quantity) AS total " +
                    "FROM products_in_cart " +
                    "INNER JOIN product ON products_in_cart.product_id = product.id " +
                    "WHERE product.product_name = ?");
                pstmt.setString(1, prod);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    sum2 = (int) rs.getDouble("total");
                }
                JSONObject cJson = new JSONObject();
                cJson.put("prod_total", sum2);
                cJson.put("prod_name", prod);
                jArray.put(cJson);
            }
            jObject.put("prod_headers", jArray);

            JSONArray jArray2 = new JSONArray();

            for (String cons: consumers) {
                JSONObject cJson2 = new JSONObject();
                ////////////////////////// Table for Customers ////////////////////

                if (filter.equals("all")) {

                    // rows. top k ordering, filter by all
                    pstmt = conn.prepareStatement("select prod.product_name, 2*sum(prod.sum)/count(prod) as total, sum(prod2.sum2) as total2 " +
                        "from (select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum " +
                        "from state, product,person,shopping_cart,products_in_cart where state.state_name = ? and " +
                        "person.state_id = state.id and person.id = shopping_cart.person_id and " +
                        "shopping_cart.id = products_in_cart.cart_id and " +
                        "product.id = products_in_cart.product_id group by product_name " +
                        "union " +
                        "select product_name,'0' from product) as prod, " +
                        "(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum2 " +
                        "from state, product,person,shopping_cart,products_in_cart where state.state_name = ? and " +
                        "person.state_id = state.id and person.id = shopping_cart.person_id and " +
                        "shopping_cart.id = products_in_cart.cart_id and " +
                        "product.id = products_in_cart.product_id group by product_name " +
                        "union " +
                        "select product_name,'0' from product) as prod2 " +
                        "where prod.product_name = prod2.product_name " +
                        "group by prod.product_name order by total2 desc");
                    pstmt.setString(1, cons);
                    pstmt.setString(2, consumers.get(0));
                    rs = pstmt.executeQuery();
                    sum = 0;
                    while (rs.next())
                        sum = sum + rs.getInt("total");

                    cJson2.put("state_overall_total", sum);
                    cJson2.put("state_name", cons);


                    pstmt.setString(1, cons);
                    pstmt.setString(2, consumers.get(0));
                    rs2 = pstmt.executeQuery();

                    while (rs2.next()) {
                        cJson2.put(rs2.getString("product_name"), rs2.getInt("total"));
                    }
                    jArray2.put(cJson2);
                } else {

                    pstmt = conn.prepareStatement("select prod.product_name, 2*sum(prod.sum)/count(prod) as total, sum(prod2.sum2) as total2 " +
                        "from(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum " +
                        "from state, product,person,shopping_cart,products_in_cart,category " +
                        "where state.state_name = ? and person.state_id = state.id and " +
                        "person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and " +
                        "product.id = products_in_cart.product_id and product.category_id = category.id and " +
                        "category.category_name = ? group by product_name " +
                        "union " +
                        "select product_name,'0'  from product,category " +
                        "where category.id = product.category_id and category.category_name = ? )prod, " +
                        "(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum2 " +
                        "from state, product,person,shopping_cart,products_in_cart,category " +
                        "where state.state_name = ? and person.state_id = state.id and " +
                        "person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and " +
                        "product.id = products_in_cart.product_id and product.category_id = category.id and " +
                        "category.category_name = ? group by product_name " +
                        "union " +
                        "select product_name,'0'  from product,category " +
                        "where category.id = product.category_id and category.category_name = ? )prod2 " +
                        "where prod.product_name = prod2.product_name " +
                        "group by prod.product_name order by total2 desc");
                    pstmt.setString(1, cons);
                    pstmt.setString(2, filter);
                    pstmt.setString(3, filter);
                    pstmt.setString(4, consumers.get(0));
                    pstmt.setString(5, filter);
                    pstmt.setString(6, filter);
                    rs = pstmt.executeQuery();
                    sum = 0;
                    while (rs.next())
                        sum = sum + rs.getInt("total");

                    cJson2.put("state_overall_total", sum);
                    cJson2.put("state_name", cons);

                    pstmt.setString(1, cons);
                    pstmt.setString(2, filter);
                    pstmt.setString(3, filter);
                    pstmt.setString(4, consumers.get(0));
                    pstmt.setString(5, filter);
                    pstmt.setString(6, filter);
                    rs2 = pstmt.executeQuery();
                    while (rs2.next()) {
                        cJson2.put(rs2.getString("product_name"), rs2.getInt("total"));
                    }
                    jArray2.put(cJson2);
                }
                jObject.put("states", jArray2);
            }

            response.getWriter().print(jObject);

        } catch (SQLException e) {
            System.out.print(e + "\n");
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {} // Ignore
                rs = null;
            }
            if (rs2 != null) {
                try {
                    rs2.close();
                } catch (SQLException e) {} // Ignore
                rs2 = null;
            }
            if (rs3 != null) {
                try {
                    rs3.close();
                } catch (SQLException e) {} // Ignore
                rs3 = null;
            }
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {} // Ignore
                pstmt = null;
            }
            if (pstmt2 != null) {
                try {
                    pstmt2.close();
                } catch (SQLException e) {} // Ignore
                pstmt2 = null;
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {} // Ignore
                conn = null;
            }
        }

    } else { %>
        <h3>This page is available to owners only </h3>
        <%
    }
  }
  else { %> 
  	<h3> Please <a href="./login.jsp"> login </a> before viewing the page</h3>
<% } %>
</body>
</html>
