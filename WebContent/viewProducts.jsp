    <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>myShop :: Products</title>
        <!-- Bootstrap core CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <link rel="stylesheet" href="global.css">
        </head>
        <body>
        <nav class="navbar navbar-inverse navbar-fixed-top">
        <div class="container-fluid">
        <div class="navbar-header">
        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="#">myShop</a>
        </div>
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
				<li class="active"><a href="viewProducts.jsp">View Products  <span class="sr-only">(current)</span></a></li>
		        <li><a href="order.jsp">Order</a></li>
		        <li><a href="shoppingCart.jsp">Shopping Cart</a></li>
		      <hr />
		     	<li><a href="viewProducts.jsp?action=view&id=all">All Categories</a></li>
		        
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
                      
                  PreparedStatement pstmt3 = conn.prepareStatement("SELECT * FROM categories");
                  pstmt3.execute();
                  ResultSet rs3 = pstmt3.getResultSet();
                  while(rs3.next()){ %>
                  <li><a href="viewProducts.jsp?action=view&id=<% out.print(rs3.getInt("id")); %>"> <% out.print(rs3.getString("name")); %> </a></li> 
                  <% } %>
		      </ul>
		      
		 
		    </div>
            <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
              <h1 class="page-header">Welcome to myShop <% if(session.getAttribute("name") != null) { out.print(session.getAttribute("name"));} %></h1>
				
        <div class="row placeholders">
      
     
		<form action="viewProducts.jsp" method="get">
					<input type="hidden" name="action" value="search">
					<label>Search: &nbsp;</label>
					<input type="text" name="query">
					<input type="submit" value="Search"/>
				</form>
        <div class="table-responsive">
        
			<%

              	//insert code
                  String action = request.getParameter("action");
                  if(action != null && action.equals("view") && !request.getParameter("id").equals("all")){
                	  PreparedStatement pstmt4 = conn.prepareStatement("SELECT * FROM products WHERE category='"
                			  + request.getParameter("id") + "'");
                      pstmt4.execute();
                      ResultSet rs4 = pstmt4.getResultSet();
                      session.setAttribute("filter", request.getParameter("id"));
                	  %> 
                	  <table class="table table-striped">
        <thead>
        <tr>
        <th>Product Name</th>
        <th>Product SKU</th>
        <th>Product Category</th>
        <th>Product Price</th>
        <th>View Product</th>
        </tr>
      </thead>
      <tbody>
              <%-- -------- Iteration Code -------- --%>
          <%
              // Iterate over the ResultSet
              while (rs4.next()) {
          %>

          <tr>
          
         
              
              <%-- Get the name --%>
              <td>
                <%=rs4.getString("name")%>
              </td>
              
              <td>
                <%=rs4.getInt("sku")%>
              </td>
              <%
                PreparedStatement pstmt6 = conn.prepareStatement("SELECT * FROM categories WHERE id='" + 
                rs4.getInt("category") + "'");
                pstmt6.execute();
                ResultSet rs6 = pstmt6.getResultSet();
                rs6.next(); %>
              <td><%=rs6.getString("name")%></td>
               <td>
                <%=rs4.getInt("price")%>
              </td>
              
            <td>
            <a href="order.jsp?action=place&id=<%=rs6.getInt("id")%>">View Product</a>
            </td>
          </tr>
          <%
              }
                  }
          
        
          if(action != null && action.equals("view") && request.getParameter("id").equals("all")){
                	  PreparedStatement pstmt5 = conn.prepareStatement("SELECT * FROM products");
                      pstmt5.execute();
                      ResultSet rs5 = pstmt5.getResultSet();
                      session.setAttribute("filter", "all");
                	  %> 
                	  <table class="table table-striped">
        <thead>
        <tr>
        <th>Product Name</th>
        <th>Product SKU</th>
        <th>Product Category</th>
        <th>Product Price</th>
        <th>View Product</th>
        </tr>
      </thead>
      <tbody>
              <%-- -------- Iteration Code -------- --%>
          <%
              // Iterate over the ResultSet
              while (rs5.next()) {
          %>

          <tr>
              <%-- Get the name --%>
              <td>
                <%=rs5.getString("name")%>
              </td>
              
              <td>
                <%=rs5.getInt("sku")%>
              </td>
              <%
                PreparedStatement pstmt6 = conn.prepareStatement("SELECT * FROM categories WHERE id='" + 
                rs5.getInt("category") + "'");
                pstmt6.execute();
                ResultSet rs6 = pstmt6.getResultSet();
                rs6.next(); %>
              <td><%=rs6.getString("name")%></td>
               <td>
                <%=rs5.getInt("price")%>
              </td>
              
            <td>
            <a href="order.jsp?action=place&id=<%=rs5.getInt("id")%>">View Product</a>
            </td>
          </tr>
          <%
              }         
          }
          
          if(action != null && action.equals("search") && request.getParameter("query") != null){
        	  PreparedStatement pstmt4;
        	  if(session.getAttribute("filter") == null || session.getAttribute("filter").equals("all")){
        	  	  pstmt4 = conn.prepareStatement("SELECT * FROM products WHERE name='"
        			  + request.getParameter("query") + "'");
        	  } else {
        		  pstmt4 = conn.prepareStatement("SELECT * FROM products WHERE name='"
            			  + request.getParameter("query") + "' AND category='" +
        		  session.getAttribute("filter") + "'");
        	  }
              pstmt4.execute();
              ResultSet rs4 = pstmt4.getResultSet();
        	  %> 
        	  <table class="table table-striped">
<thead>
<tr>
<th>Product Name</th>
<th>Product SKU</th>
<th>Product Category</th>
<th>Product Price</th>
<th>View Product</th>
</tr>
</thead>
<tbody>
      <%-- -------- Iteration Code -------- --%>
  <%
      // Iterate over the ResultSet
      while (rs4.next()) {
  %>

  <tr>
  <%-- Get the name --%>
              <td>
                <%=rs4.getString("name")%>
              </td>
              
              <td>
                <%=rs4.getInt("sku")%>
              </td>
              <%
                PreparedStatement pstmt6 = conn.prepareStatement("SELECT * FROM categories WHERE id='" + 
                rs4.getInt("category") + "'");
                pstmt6.execute();
                ResultSet rs6 = pstmt6.getResultSet();
                rs6.next(); %>
              <td><%=rs6.getString("name")%></td>
               <td>
                <%=rs4.getInt("price")%>
              </td>
              
            <td>
            <a href="order.jsp?action=place&id=<%=rs6.getInt("id")%>">View Product</a>
            </td>
          </tr>
  <%
      }
          }

          } catch (SQLException e) {
          
        	  if(e.getSQLState().equals("23505") || e.getSQLState().equals("23502") || e.getSQLState().equals("23514") || e.getSQLState().equals("44000")) {
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

      </tbody>
      </table>
      </body>
      </html>