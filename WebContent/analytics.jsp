<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
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
						<form action="AnalyticsController" method="post" >
								Select Row View:
								<select required name="row_view">
										<option selected value="customer">Customers</option>
										<option value="state">States</option>
								</select>
								Order By:
								<select required name="ordering">
										<option selected value="alphabetical">Alphabetical</option>
										<option value="top-k">Top-K</option>
								</select>
								Filter By:
								<select required name="filter">
										<option selected value="all">All</option>
										<%
											for (CategoryModel cat : category_list) {
										%>
										<option value="<%=cat.getCategoryName()%>"><%=cat.getCategoryName()%></option>
										<%
											}
										%>
								</select>
							<h4><input type="submit" value="Run Query" /></h4>
						</form>
						<% 
						
						%>
					</td>
				</tr>
			</table>	
	<%
		} 
		else { %>
			<h3>This page is available to owners only</h3>
		<%
		}
	}
	else { %>
			<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
	<%} %>
</body>
</html>