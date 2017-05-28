<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>myShop :: Home</title>
  <!-- Bootstrap core CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <link rel="stylesheet" href="global.css">
  <%@ page import="java.sql.*"%>
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
          <li class="active"><a href="#">Home <span class="sr-only">(current)</span></a></li>
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
          <li><a href="order.jsp">Order</a></li>
        </ul>
      </div>
      <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
        <h1 class="page-header">Welcome to myShop <% if(session.getAttribute("name") != null) { out.print(session.getAttribute("name"));} %></h1>
        <div class="row placeholders">
			Please select an option from the navigation bar to your left.
        </div>
	  </div>
    </div> 
  </div>
</body>
</html>