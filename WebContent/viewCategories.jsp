<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>myShop :: Categories</title>
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
            <li class="active"><a href="viewCategories.jsp">Categories <span class="sr-only">(current)</span></a></li>
            <% } else { %>
            <li class="active"><a href="viewCategories.jsp">Categories <span class="sr-only">(current)</span></a></li>
            <% } %>
            <% if(session.getAttribute("role").equals("1")){ %>
            <li><a href="manageProducts.jsp">Manage Products</a></li>
            <% } else { %>
              <li><a href="error.html">Manage Products</a></li>
              <% } %>
              <li><a href="viewProducts.jsp?action=view&id=all">View Products</a></li>
              <li><a href="order.jsp">Order</a></li>
            </ul>
        </div>
        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
          <h1 class="page-header">Welcome to myShop <% if(session.getAttribute("name") != null) { out.print(session.getAttribute("name"));} %></h1>

      <div class="row placeholders">
      
        <h2 class="sub-header">Available Categories</h2>
        <div class="table-responsive">
        
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
			
              
              	//insert code
                  String action = request.getParameter("action");
                  // Check if an insertion is requested
                  if (action != null && action.equals("insert")) {

                      // Begin transaction
                      conn.setAutoCommit(false);

                      // Create the prepared statement and use it to
                      pstmt = conn.prepareStatement("INSERT INTO categories (name,description) VALUES (?, ?)");

                      pstmt.setString(1, request.getParameter("cname"));
                      pstmt.setString(2, request.getParameter("cdesc"));
                      pstmt.executeUpdate();

                      // Commit transaction
                      conn.commit();
                      conn.setAutoCommit(true);
                  }
		
                  if (action != null && action.equals("update")) {

                    // Begin transaction
                    conn.setAutoCommit(false);
                    // Create the prepared statement and use it to
                    // UPDATE category values in the table.
                    pstmt = conn.prepareStatement("UPDATE categories SET name = ?, description = ? WHERE id = ?");

                    pstmt.setString(1, request.getParameter("cname"));
                    pstmt.setString(2, request.getParameter("cdesc"));
                    pstmt.setInt(3, Integer.parseInt(request.getParameter("id")));
			  pstmt.executeUpdate();
                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                  }
                  
                  // Check if a delete is requested
                  if (action != null && action.equals("delete")) {
		      // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // DELETE students FROM the Students table.
                    pstmt = conn.prepareStatement("DELETE FROM categories WHERE id = ?");
		      pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
	          pstmt.executeUpdate();
                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                  }
              //Connection code
              Statement statement = conn.createStatement();
              rs = statement.executeQuery("SELECT * FROM categories");
              %>
              <!-- Add an HTML table header row to format the results -->

 	<table class="table table-striped">
        <thead>
        <tr>
        <th>Category Name</th>
        <th>Category Description</th>
        <th>Action</th>
        </tr>
      </thead>
      <tbody>
              <tr>
                <form action="viewCategories.jsp" method="POST">
                  <input type="hidden" name="action" value="insert"/>

                  <td><input value="" name="cname"/></td>
                  <td><input value="" name="cdesc"/></td>
                  <td><input type="submit" value="Insert"/></td>
                </form>
              </tr>
              
       <table class="table table-striped">
        <thead>
        <tr>
        <th>ID</th>
        <th>Category Name</th>
        <th>Category Description</th>
        <th>Update</th>
        <th>Delete</th>
        </tr>
      </thead>
      <tbody>
              <%-- -------- Iteration Code -------- --%>
          <%
              // Iterate over the ResultSet
              while (rs.next()) {
          %>

          <tr>
          
            <form action="viewCategories.jsp" method="POST">
              <input type="hidden" name="action" value="update"/> 
              <input type="hidden" value="<%=rs.getInt("id")%>" name="id"/>
              
              <td>
                <%=rs.getString("id")%>
              </td>
              <%-- Get the name --%>
              <td>
                <input value="<%=rs.getString("name")%>" name="cname"/>
              </td>
              
              <%-- Get the description --%>
              <td>
                <input value="<%=rs.getString("description")%>" name="cdesc"/>
              </td>
              <%-- Button --%>
              <td><input type="submit" value="Update"></td>
            </form>
            <form action="viewCategories.jsp" method="POST">
              <input type="hidden" name="action" value="delete"/>
              <input type="hidden" value="<%=rs.getInt("id")%>" name="id"/>
              <%-- Button --%>
              <td><input type="submit" value="Delete"/></td>
            </form>
          </tr>
          <%
              }
          
          
          %>


            <%-- -------- Close Connection Code -------- --%>
          <%
          
              // Close the ResultSet
              rs.close();

              // Close the Statement
              statement.close();

              // Close the Connection
              conn.close();
          } catch (SQLException e) {
        	  System.out.println("SQL ERROR #: " + e.getSQLState());
        	  if(e.getSQLState().equals("23505") || e.getSQLState().equals("23502") || e.getSQLState().equals("23514") || e.getSQLState().equals("44000")) {
              	%>
              	<div class="alert alert-danger">
      	      		<strong>Error:</strong> Data modification failure. <br>
      	      		<a href="viewCategories.jsp"> Please try again by clicking here.</a>
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

      </tbody>
      </table>
      </div>
      </div>
      </div>
      </div>
      </body>
      </html>