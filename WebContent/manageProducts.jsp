    <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>myShop :: Manage Products</title>
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
					<li class="active"><a href="manageProducts.jsp">Manage Products <span class="sr-only">(current)</span></a></li>
				  <% } else { %>
					<li><a href="error.html">Manage Products</a></li>
				  <% } %>
				<li><a href="viewProducts.jsp?action=view&id=all">View Products</a></li>
		        <li><a href="order.jsp">Order</a></li>
		        <hr />
		     	<li><a href="manageProducts.jsp?action=view&id=all">All Categories</a></li>
		        
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
                  <li><a href="manageProducts.jsp?action=view&id=<% out.print(rs3.getInt("id")); %>"> <% out.print(rs3.getString("name")); %> </a></li> 
                  <% } %>
		      </ul>
		      
		 
		    </div>
            <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
              <h1 class="page-header">Welcome to myShop <% if(session.getAttribute("name") != null) { out.print(session.getAttribute("name"));} %></h1>
				
        <div class="row placeholders">
      
     
		<form action="manageProducts.jsp" method="get">
					<input type="hidden" name="action" value="search">
					<label>Search: &nbsp;</label>
					<input type="text" name="query">
					<input type="submit" value="Search"/>
				</form>
        <div class="table-responsive">
        
			<%
			
         
              	//insert code
                  String action = request.getParameter("action");
                  // Check if an insertion is requested
                  if (action != null && action.equals("insert")) {
					try{ 
						session.setAttribute("filter", null);
                      // Begin transaction
                      conn.setAutoCommit(false);

                      // Create the prepared statement and use it to
                      pstmt = conn.prepareStatement("INSERT INTO products (name, sku, category, price) VALUES (?, ?, ?, ?)");

                      pstmt.setString(1, request.getParameter("pname"));
  		     	 	  pstmt.setInt(2, Integer.parseInt(request.getParameter("psku")));
  		     	 	  pstmt.setInt(3, Integer.parseInt(request.getParameter("pcat")));
  		     	 	  pstmt.setInt(4, Integer.parseInt(request.getParameter("pprice")));

                      pstmt.executeUpdate();

                      // Commit transaction
                      conn.commit();
                      conn.setAutoCommit(true);
                  	%>
                  	<div class="alert alert-success">
          	      		<strong>Success:</strong> New product inserted.<br>
          	   	 	</div>
                  	<%
					} catch(NumberFormatException e1){
                    	%>
                    	<div class="alert alert-danger">
            	      		<strong>Error:</strong> Failure to insert new product <br>
            	   	 	</div>
                    	<%
                    }
                  }
		
                  if (action != null && action.equals("update")) {
					session.setAttribute("filter", null);
                	try { 
                    // Begin transaction
                    conn.setAutoCommit(false);
                    // Create the prepared statement and use it to
                    // UPDATE category values in the table.
                    pstmt = conn.prepareStatement("UPDATE products SET name = ?, sku = ?, category = ?, price = ? WHERE id = ?");
                    
                    pstmt.setString(1, request.getParameter("pname"));
		     	 	pstmt.setInt(2, Integer.parseInt(request.getParameter("psku")));
		     	 	pstmt.setInt(3, Integer.parseInt(request.getParameter("pcat")));
		     	 	pstmt.setInt(4, Integer.parseInt(request.getParameter("pprice")));
		     	 	pstmt.setInt(5, Integer.parseInt(request.getParameter("id")));

                    pstmt.executeUpdate();
                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
					response.sendRedirect("manageProducts.jsp?action=view&id=" + request.getParameter("pcat"));

                	} catch(NumberFormatException e1){
                    	%>
                    	<div class="alert alert-danger">
            	      		<strong>Error:</strong> Failure to update product <br>
            	      		<a href="manageProducts.jsp"> Click here to try again.</a>
            	   	 	</div>
                    	<%
                    }
                  }
                  
                  // Check if a delete is requested
                  if (action != null && action.equals("delete")) {
		      // Begin transaction
		      session.setAttribute("filter", null);
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // DELETE students FROM the Students table.
                    pstmt = conn.prepareStatement("DELETE FROM products WHERE id = ?");
		     	 	pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
	          		pstmt.executeUpdate();
                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                  }
                  
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
        <th>Product ID</th>
        <th>Product Name</th>
        <th>Product SKU</th>
        <th>Product Category</th>
        <th>Product Price</th>
        </tr>
      </thead>
      <tbody>
              <%-- -------- Iteration Code -------- --%>
          <%
              // Iterate over the ResultSet
              while (rs4.next()) {
          %>

          <tr>
          
            <form action="manageProducts.jsp" method="POST">
              <input type="hidden" name="action" value="update"/> 
              <input type="hidden" value="<%=rs4.getInt("id")%>" name="id"/>
              
              <td>
                <%=rs4.getString("id")%>
              </td>
              <%-- Get the name --%>
              <td>
                <input value="<%=rs4.getString("name")%>" name="pname"/>
              </td>
              
              <td>
                <input value="<%=rs4.getInt("sku")%>" name="psku"/>
              </td>
              <%
                PreparedStatement pstmt6 = conn.prepareStatement("SELECT * FROM categories WHERE id='" + 
                rs4.getInt("category") + "'");
                pstmt6.execute();
                ResultSet rs6 = pstmt6.getResultSet();
                rs6.next(); %>
              <td><select name="pcat">
                   <option value="<% out.print(rs6.getInt("id")); %>"> <% out.print(rs6.getString("name")); %> </option> 
                   <%
                  PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM categories WHERE NOT id='" + 
                          rs4.getInt("category") + "'");
                  pstmt2.execute();
                  ResultSet rs2 = pstmt2.getResultSet();
                  while(rs2.next()){ %>
                  <option value="<% out.print(rs2.getInt("id")); %>"> <% out.print(rs2.getString("name")); %> </option> 
                  <% } %>
                  </select></td>
               <td>
                <input value="<%=rs4.getInt("price")%>" name="pprice"/>
              </td>
              <%-- Button --%>
              <td><input type="submit" value="Update"></td>
            </form>
            <form action="manageProducts.jsp" method="POST">
              <input type="hidden" name="action" value="delete"/>
              <input type="hidden" value="<%=rs4.getInt("id")%>" name="id"/>
              <%-- Button --%>
              <td><input type="submit" value="Delete"/></td>
            </form>
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
        <th>Product ID</th>
        <th>Product Name</th>
        <th>Product SKU</th>
        <th>Product Category</th>
        <th>Product Price</th>
        </tr>
      </thead>
      <tbody>
              <%-- -------- Iteration Code -------- --%>
          <%
              // Iterate over the ResultSet
              while (rs5.next()) {
          %>

          <tr>
          
            <form action="manageProducts.jsp" method="POST">
              <input type="hidden" name="action" value="update"/> 
              <input type="hidden" value="<%=rs5.getInt("id")%>" name="id"/>
              
              <td>
                <%=rs5.getString("id")%>
              </td>
              <%-- Get the name --%>
              <td>
                <input value="<%=rs5.getString("name")%>" name="pname"/>
              </td>
              
              <td>
                <input value="<%=rs5.getInt("sku")%>" name="psku"/>
              </td>
  			    <%
                PreparedStatement pstmt6 = conn.prepareStatement("SELECT * FROM categories WHERE id='" + 
                rs5.getInt("category") + "'");
                pstmt6.execute();
                ResultSet rs6 = pstmt6.getResultSet();
                rs6.next(); %>
              <td><select name="pcat">
                   <option value="<% out.print(rs6.getInt("id")); %>"> <% out.print(rs6.getString("name")); %> </option> 
                   <%
                  PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM categories WHERE NOT id='" + 
                          rs5.getInt("category") + "'");
                  pstmt2.execute();
                  ResultSet rs2 = pstmt2.getResultSet();
                  while(rs2.next()){ %>
                  <option value="<% out.print(rs2.getInt("id")); %>"> <% out.print(rs2.getString("name")); %> </option> 
                  <% } %>
                  </select></td>
              
              
               <td>
                <input value="<%=rs5.getInt("price")%>" name="pprice"/>
              </td>
              <%-- Button --%>
              <td><input type="submit" value="Update"></td>
            </form>
            <form action="manageProducts.jsp" method="POST">
              <input type="hidden" name="action" value="delete"/>
              <input type="hidden" value="<%=rs5.getInt("id")%>" name="id"/>
              <%-- Button --%>
              <td><input type="submit" value="Delete"/></td>
            </form>
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
<th>Product ID</th>
<th>Product Name</th>
<th>Product SKU</th>
<th>Product Category</th>
<th>Product Price</th>
</tr>
</thead>
<tbody>
      <%-- -------- Iteration Code -------- --%>
  <%
      // Iterate over the ResultSet
      while (rs4.next()) {
  %>

  <tr>
  
    <form action="manageProducts.jsp" method="POST">
      <input type="hidden" name="action" value="update"/> 
      <input type="hidden" value="<%=rs4.getInt("id")%>" name="id"/>
      
      <td>
        <%=rs4.getString("id")%>
      </td>
      <%-- Get the name --%>
      <td>
        <input value="<%=rs4.getString("name")%>" name="pname"/>
      </td>
      
      <td>
        <input value="<%=rs4.getInt("sku")%>" name="psku"/>
      </td>
      <%
        PreparedStatement pstmt6 = conn.prepareStatement("SELECT * FROM categories WHERE id='" + 
        rs4.getInt("category") + "'");
        pstmt6.execute();
        ResultSet rs6 = pstmt6.getResultSet();
        rs6.next(); %>
      <td><select name="pcat">
           <option value="<% out.print(rs6.getInt("id")); %>"> <% out.print(rs6.getString("name")); %> </option> 
           <%
          PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM categories WHERE NOT id='" + 
                  rs4.getInt("category") + "'");
          pstmt2.execute();
          ResultSet rs2 = pstmt2.getResultSet();
          while(rs2.next()){ %>
          <option value="<% out.print(rs2.getInt("id")); %>"> <% out.print(rs2.getString("name")); %> </option> 
          <% } %>
          </select></td>
       <td>
        <input value="<%=rs4.getInt("price")%>" name="pprice"/>
      </td>
      <%-- Button --%>
      <td><input type="submit" value="Update"></td>
    </form>
    <form action="manageProducts.jsp" method="POST">
      <input type="hidden" name="action" value="delete"/>
      <input type="hidden" value="<%=rs4.getInt("id")%>" name="id"/>
      <%-- Button --%>
      <td><input type="submit" value="Delete"/></td>
    </form>
  </tr>
  <%
      }
          }
          
              //Connection code
              Statement statement = conn.createStatement();
              rs = statement.executeQuery("SELECT * FROM products");
              %>
              <!-- Add an HTML table header row to format the results -->
        <h2 class="sub-header">Manage Products</h2>
 	<table class="table table-striped">
        <thead>
        <tr>
        <th>Product Name</th>
        <th>Product SKU</th>
        <th>Product Category</th>
        <th>Product Price</th>
        </tr>
      </thead>
      <tbody>
              <tr>
                <form action="manageProducts.jsp" method="POST">
                  <input type="hidden" name="action" value="insert"/>
                  <td><input value="" name="pname"/></td>
                  <td><input value="" name="psku"/></td>
                  <td><select name="pcat">
                  <% 
                  PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM categories");
                  pstmt2.execute();
                  ResultSet rs2 = pstmt2.getResultSet();
                  while(rs2.next()){ %>
                  <option value="<% out.print(rs2.getInt("id")); %>"> <% out.print(rs2.getString("name")); %> </option> 
                  <% } %>
                  </select></td>
                  <td><input value="" name="pprice"/></td>
                  <td><input type="submit" value="Insert"/></td>
                </form>
              </tr>
              
       

            <%-- -------- Close Connection Code -------- --%>
          <%
          
              // Close the ResultSet
              rs.close();

              // Close the Statement
              statement.close();

              // Close the Connection
              conn.close();
          } catch (SQLException e) {
        	  if(e.getSQLState().equals("23505") || e.getSQLState().equals("23502") || e.getSQLState().equals("23514") || e.getSQLState().equals("44000")) {
              	%>
              	<div class="alert alert-danger">
      	      		<strong>Error:</strong> Data modification failure. <br>
      	      		<a href="manageProducts.jsp"> Please try again by clicking here.</a>
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