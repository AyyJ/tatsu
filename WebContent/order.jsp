<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>myShop :: Order</title>
  <!-- Bootstrap core CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <link rel="stylesheet" href="global.css">
</head>
<body>
  <%
  if(session.getAttribute("name") == null){
    session.setAttribute("homeErr", "nouser");
    session.setAttribute("role", "999");
    %>
    <script type="text/javascript">
    window.location.replace("login.jsp");
    </script>
    <%
  }
  %>
  <nav class="navbar navbar-inverse navbar-fixed-top">
    <div class="container-fluid">
      <div class="navbar-header">
        <a class="navbar-brand" href="#">myShop</a>
      </div>
      <ul class="nav navbar-nav navbar-right"><% if(session.getAttribute("role").equals("2")) { %>
      <li class="active"><a href="shoppingCart.jsp"><span class="glyphicon glyphicon-shopping-cart"></span>&nbsp; Buy My Shopping Cart</a></li>
      <% } %>
      <li class="active"><a href="logout.jsp"><span class="glyphicon glyphicon-log-out"></span>&nbsp; Logout</a></li>
      </ul>
    </div>
  </nav>
  
  <div class="container-fluid">
    <div class="row">
      <div class="col-sm-3 col-md-2 sidebar">
        <ul class="nav nav-sidebar">
          <li><a href="home.jsp">Home</a></li>
          <% if(session.getAttribute("role").equals("1")){ %>
            <li><a href="viewCategories.jsp">Categories</a></li>
            <% } else { %>
              <li><a href="error.html">Categories</a></li>
              <% } %>
              <% if(session.getAttribute("role").equals("1")){ %>
                <li><a href="manageProducts.jsp">Manage Products</a></li>
                <% } else { %>
                  <li><a href="error.html">Manage Products</a></li>
                  <% } %>
                  <li><a href="viewProducts.jsp?action=view&id=all">View Products</a></li>
                  <li class="active"><a href="order.jsp">Order  <span class="sr-only">(current)</span></a></li>
                </ul>
              </div>
              <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
                <h1 class="page-header">Welcome to myShop <% if(session.getAttribute("name") != null) { out.print(session.getAttribute("name"));} %></h1>
                
                <div class="row placeholders">
                <h2 class="sub-header">You're viewing:</h2>
                  <%-- Import the java.sql package --%>
                  <%@ page import="java.sql.*"%>
              <%-- -------- Open Connection Code -------- --%>
                  <%
                  
                  Connection conn = null;
                  PreparedStatement pstmt = null;
                  ResultSet rs = null;
                  
                  try {
                      // Registering Postgresql JDBC driver with the DriverManager
                      Class.forName("org.postgresql.Driver");

                      // Open a connection to the database using DriverManager
                      conn = DriverManager.getConnection(
                          "jdbc:postgresql://localhost/Tatsu?" +
                          "user=postgres&password=postgres1");
                      String action = request.getParameter("action");
                  if(action != null && action.equals("place") && request.getParameter("id") != null){
                	  session.setAttribute("browsedProduct", request.getParameter("id"));
                  pstmt = conn.prepareStatement("SELECT * FROM products WHERE id='"
            			  + request.getParameter("id") + "'");
                  pstmt.execute();
                  rs = pstmt.getResultSet();
                  rs.next();
                  %>
          <table class="table table-striped">
                  
       	<thead>
        <tr>
        <th>Product Name</th>
        <th>Product SKU</th>
        <th>Product Category</th>
        <th>Product Price</th>
        <th>Quantity</th>
        <th>Add to Cart</th>
        </tr>
      </thead>
      <tbody>
      <tr>
              <%-- Get the name --%>
              <td>
                <%=rs.getString("name")%>
              </td>
              
              <td>
                <%=rs.getInt("sku")%>
              </td>
              <%
                PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM categories WHERE id='" + 
                rs.getInt("category") + "'");
                pstmt2.execute();
                ResultSet rs2 = pstmt2.getResultSet();
                rs2.next(); %>
              <td><%=rs2.getString("name")%></td>
               <td>
                <%=rs.getInt("price")%>
              </td>
              
           
            <form action="viewProducts.jsp" action="post">
            <input type="hidden" name="action" value="placed">
            <input type="hidden" name="id" value="<%=rs.getInt("id")%>">
            <td><input type="number" name="quantity" required></td>
            <td><input type="submit" value="Add to Shopping Cart"></td>
            </form>
            
          </tr>
          </tbody>
          </table>
          
       <%
                  } else if(session.getAttribute("browsedProduct") != null){
                	 PreparedStatement pstmt1;
                	 ResultSet rs1;
                      pstmt1 = conn.prepareStatement("SELECT * FROM products WHERE id='"
                			  + session.getAttribute("browsedProduct") + "'");
                      pstmt1.execute();
                      rs1 = pstmt1.getResultSet();
                      rs1.next();
                      %>
              <table class="table table-striped">
                      
           	<thead>
            <tr>
            <th>Product Name</th>
            <th>Product SKU</th>
            <th>Product Category</th>
            <th>Product Price</th>
            <th>Quantity</th>
            <th>Add to Cart</th>
            </tr>
          </thead>
          <tbody>
          <tr>
                  <%-- Get the name --%>
                  <td>
                    <%=rs1.getString("name")%>
                  </td>
                  
                  <td>
                    <%=rs1.getInt("sku")%>
                  </td>
                  <%
                    PreparedStatement pstmt3 = conn.prepareStatement("SELECT * FROM categories WHERE id='" + 
                    rs1.getInt("category") + "'");
                    pstmt3.execute();
                    ResultSet rs3 = pstmt3.getResultSet();
                    rs3.next(); %>
                  <td><%=rs3.getString("name")%></td>
                   <td>
                    <%=rs1.getInt("price")%>
                  </td>
                  
               
                <form action="viewProducts.jsp" action="post">
            <input type="hidden" name="action" value="placed">
                <input type="hidden" name="id" value="<%=rs1.getInt("id")%>">
            	<td><input type="number" name="quantity" required></td>
                <td><input type="submit" value="Add to Shopping Cart"></td>
                </form>
                
              </tr>
              </tbody>
              </table>
              
           <%
              
                  
                  
                  } else {
                	  %>
                	  <div class="alert alert-warning">
        	      		<strong>Warning:</strong> You haven't requested anything to view<br>
        	      		<a href="viewProducts.jsp?action=view&id=all">Return to view available Products</a>
        	   	 	</div> <%
                  }
                  } catch (SQLException e) {
                      System.out.println(e.getSQLState());
                	  if(e.getSQLState().equals("24000") || e.getSQLState().equals("23502") || e.getSQLState().equals("23514") || e.getSQLState().equals("44000")) {
                      	%>
                      	<div class="alert alert-danger">
              	      		<strong>Error:</strong> Data view failure. <br>
              	      		<a href="viewProducts.jsp"> Please try again by clicking here.</a>
              	   	 	</div>
                      	<%
                      } else {

                      // Wrap the SQL exception in a runtime exception to propagate
                      // it upwards
                      throw new RuntimeException(e);
                      }
                  }
                  finally {
                      // Release resources in a finally block in reverse-order of
                      // their creation

                      if (rs != null) {
                          try {
                              rs.close();
                          } catch (SQLException e) { } // Ignore
                          rs = null;
                      }
                      if (pstmt != null) {
                          try {
                              pstmt.close();
                          } catch (SQLException e) { } // Ignore
                          pstmt = null;
                      }
                      if (conn != null) {
                          try {
                              conn.close();
                          } catch (SQLException e) { } // Ignore
                          conn = null;
                      }
                  }
                  %>
                </div>
              </div>
            </div>
          </div>
        </body>
        </html>