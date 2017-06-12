<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="main.js"></script>
<script src="analytics.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<title>Sales Analytics</title>
</head>
<body>
<%
	if(session.getAttribute("roleName") != null) {
		String role = session.getAttribute("roleName").toString();
		if("owner".equalsIgnoreCase(role) == true){
			Connection con = ConnectionManager.getConnection();
			CategoryDAO categoryDao = new CategoryDAO(con);
			List<CategoryModel> category_list = categoryDao.getCategories();
			con.close();

%>
			<table cellspacing="5">
				<tr>
					<td valign="top"> <jsp:include page="./menu.jsp"></jsp:include></td>
					<td></td>
					<td>
						<h3>Hello <%= session.getAttribute("personName") %></h3>
						<h3>Sales Analytics</h3>

						<% if (request.getAttribute("error")!=null && Boolean.parseBoolean(request.getAttribute("error").toString())) {%>
							<h4 style="color:red"> Error : <%= request.getAttribute("errorMsg").toString()%></h4>
						<%}%>
						<% if (request.getAttribute("message")!=null) {%>
							<h4> Message : <%= request.getAttribute("message").toString()%></h4>
						<%}%>
			<%
			String filter = request.getParameter("filter");;
			if(filter == null)
				filter = "all";
			%>
						<form action="analytics.jsp" method="post" >
								Filter By:
								<select name="filter" id="filter_id">
										<option value="<%=filter %>"><%=filter %></option>
										<%
										if(!filter.equals("all")) {%>
										<option value="all">all</option> <% }

											for (CategoryModel cat : category_list) {
										    	if(!(cat.getCategoryName().equals(filter))){
										%>
										<option value="<%=cat.getCategoryName()%>"><%=cat.getCategoryName()%></option>
										<%
												} 
										   }
										%>
								</select>
							
						</form>
            <button onClick="showCustJson();" value="Run">Run Query</button><br><br>
          <button onClick="refreshTable();" value="refresh" style="float: left;">Refresh</button>
          <button onClick="refreshTable();" value="refresh" style="float: right;">Refresh</button>
          <table border =1 align="center">
            <tbody id="tablebody">
              <!-- RESULTS PRINT HERE -->
            </tbody>
          </table>
          <button onClick="refreshTable();" value="refresh" style="float: left;">Refresh</button>
          <button onClick="refreshTable();" value="refresh" style="float: right;">Refresh</button>

				
					</td>
				</tr> 
	<% } else { %>
			<h3>This page is available to owners only</h3>
		<%
		}
	}
	else { %>
			<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
	<%} %>
</body>
</html>
