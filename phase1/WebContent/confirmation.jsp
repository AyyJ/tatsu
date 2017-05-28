    <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>myShop :: Confirmation Page</title>
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
				<li><a href="viewProducts.jsp">View Products</a></li>
		        <li><a href="order.jsp">Order</a></li>
		        <li class="active"><a href="shoppingCart.jsp">Shopping Cart  <span class="sr-only">(current)</span></a></li>
		      </ul>
		    </div>
            <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
              <h1 class="page-header">Welcome to myShop <% if(session.getAttribute("name") != null) { out.print(session.getAttribute("name"));} %></h1>

        <div class="row placeholders">

        <h2 class="sub-header">Your Shopping Cart:</h2>
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
                      
                  if(action != null && action.equals("success")){
                	  conn.setAutoCommit(false);

                      // Create the prepared statement and use it to
                      pstmt = conn.prepareStatement("INSERT INTO purchases (uid, pid, quantity, price) VALUES (?, ?, ?, ?)");

                      PreparedStatement ps1 = conn.prepareStatement("SELECT id FROM users WHERE name='"
                    		  + session.getAttribute("name") + "'");
                      ps1.execute();
                      ResultSet rs1 = ps1.getResultSet();
                      rs1.next();
                      
                      pstmt.setInt(1, rs1.getInt("id"));		     	 	  
    				  pstmt.setInt(2, Integer.parseInt(request.getParameter("id")));
  		     	 	  pstmt.setInt(3, Integer.parseInt(request.getParameter("quantity")));
  		     	 	  pstmt.setInt(4, Integer.parseInt(request.getParameter("price")));

                      pstmt.executeUpdate();

                      // Commit transaction
                      conn.commit();
                      conn.setAutoCommit(true); %>
                      <div class="alert alert-success">
        	      		<strong>Success:</strong> Purchase Successful!<br>
        	      		<a href="viewProducts.jsp?action=view&id=all">Return to view available Products</a>
        	   	 	</div>
<% 
                  } else {
                	  %>
                	  <div class="alert alert-danger">
        	      		<strong>Error:</strong> You haven't adding anything to your cart<br>
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