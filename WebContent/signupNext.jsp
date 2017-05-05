<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>myShop :: Sign Up</title>
  <!-- Bootstrap core CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
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
	  margin-bottom: 10px;
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
            
            try {
                // Registering Postgresql JDBC driver with the DriverManager
                Class.forName("org.postgresql.Driver");

                // Open a connection to the database using DriverManager
                conn = DriverManager.getConnection(
                    "jdbc:postgresql://localhost/Tatsu?" +
                    "user=postgres&password=postgres1");
                
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // INSERT student values INTO the students table.
                    pstmt = conn
                    .prepareStatement("INSERT INTO users (name, role, age, state) VALUES (?, ?, ?, ?)");

                    try {
                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setInt(2, Integer.parseInt(request.getParameter("role")));
                    pstmt.setInt(3, Integer.parseInt(request.getParameter("age")));
                    pstmt.setString(4, request.getParameter("state"));
                    int rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                    session.setAttribute("name", request.getParameter("name"));
                    session.setAttribute("role", request.getParameter("role"));
                    %>
                    <a href="home.jsp">You have successfully logged in. Click here to proceed to the home page</a>
                    <%
                    } catch(NumberFormatException e1){
                    	%>
                    	<div class="alert alert-danger">
            	      		<strong>Error:</strong> Your sign up failed- Please try again. <br>
            	      		<a href="signup.jsp"> Return to sign up page</a>
            	   	 	</div>
                    	<%
                    }
                    
                }
            } catch (SQLException e) {

                // Wrap the SQL exception in a runtime exception to propagate
                // it upwards

        	  if(e.getSQLState().equals("23505") || e.getSQLState().equals("23502") || e.getSQLState().equals("23514") || e.getSQLState().equals("44000")) {
                	%>
                	<div class="alert alert-danger">
        	      		<strong>Error:</strong> Your sign up failed- Please try again. <br>
        	      		<a href="signup.jsp"> Return to sign up page</a>
        	   	 	</div>
                	<%
                }
                
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
            %>
</body>
</html>