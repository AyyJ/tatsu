<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>myShop :: Log in</title>
  <!-- Bootstrap core CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <link rel="stylesheet" href="login.css">
  <!-- Custom styles for this template -->
</head>

<body>
<%
if(session.getAttribute("name") != null){
	%>
	<script type="text/javascript">
		window.location.replace("home.jsp");
    </script>
	<%
}
%>
  <style type="text/css">
	body {
	  padding-top: 40px;
	  padding-bottom: 40px;
	  background-color: #eee;
	}
	
	.form-signin {
	  max-width: 330px;
	  padding: 15px;
	  margin: 0 auto;
	}
	.form-signin .form-signin-heading,
	.form-signin .checkbox {
	  margin-bottom: 10px;
	}
	.form-signin .checkbox {
	  font-weight: normal;
	}
	.form-signin .form-control {
	  position: relative;
	  height: auto;
	  -webkit-box-sizing: border-box;
	     -moz-box-sizing: border-box;
	          box-sizing: border-box;
	  padding: 10px;
	  font-size: 16px;
	}
	.form-signin .form-control:focus {
	  z-index: 2;
	}
  </style>

<div class="container">
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
                
                // Check if an insertion is requested
                if (action != null && action.equals("login")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // INSERT student values INTO the students table.
                    pstmt = conn
                    .prepareStatement("SELECT * FROM users WHERE name='" +
                    request.getParameter("name") + "'");
                    pstmt.execute();
                    
                    rs = pstmt.getResultSet();
                    if(rs.next() == false){
                    	%>
                    	<div class="alert alert-danger">
            	      		<strong>Error:</strong> The provided name <strong><em><% if(request.getParameter("name") != null) { out.print(request.getParameter("name"));} %></em></strong> is not known. <br>
            	      		Please re-complete the form.
            	   	 	</div>
                    	<%
                    } else {
                    	session.setAttribute("name", request.getParameter("name"));
                    	session.setAttribute("role", rs.getString("role"));
                    	%>
                    	<script type="text/javascript">
                    		window.location.replace("home.jsp");
                        </script>
                    	<%
                    	
                    }
                }
            } catch (SQLException e) {
                // Wrap the SQL exception in a runtime exception to propagate
                // it upwards
                throw new RuntimeException(e);
            }
            finally {
                // Release resources in a finally block in reverse-order of
                // their creation

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
            
            if(session.getAttribute("homeErr") == "nouser"){
            	  %> 
            	    <div class="alert alert-danger">
            	      <strong>Error:</strong> No user logged in.
            	    </div>
            	  <%
            	}
           %>
           
      <form class="form-signin" action="login.jsp">
        <h2 class="form-signin-heading">Please log in</h2>
        <input type="hidden" name="action" value="login">
        <label for="name" class="sr-only">Name</label>
        <input type="text" id="name" name="name" class="form-control" placeholder="Name" required autofocus>
        <button class="btn btn-lg btn-primary btn-block" style="margin-top: 5px;" type="submit">Sign in</button>
      </form>
        <button class="btn btn-lg btn-primary btn-block" style="width: 300px; margin: auto;" onclick="window.location.href='signup.jsp';">Sign Up</button>
</body>
</html>