<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Similar Products</title>
</head>
<body>
<%
	if(session.getAttribute("roleName") != null) {
		String role = session.getAttribute("roleName").toString();
		if("owner".equalsIgnoreCase(role) == true){
			Connection con = ConnectionManager.getConnection();	
			CategoryDAO categoryDao = new CategoryDAO(con);
			List<CategoryModel> category_list = categoryDao.getCategories();
			%>
			<table cellspacing="5">
			<tr>
				<td valign="top"> <jsp:include page="./menu.jsp"></jsp:include></td>
				<td></td>
				<td>
					<h3>Hello <%= session.getAttribute("personName") %></h3>
					<h3> Similar Products</h3>
					
					<% if (request.getAttribute("error")!=null && Boolean.parseBoolean(request.getAttribute("error").toString())) {%>
						<h4 style="color:red"> Error : <%= request.getAttribute("errorMsg").toString()%></h4> 
					<%}%>
					<% if (request.getAttribute("message")!=null) {%>
						<h4> Message : <%= request.getAttribute("message").toString()%></h4> 
					<%}%>
				
					<%
					PreparedStatement pstmt = null;
					ResultSet rs = null;
					
					pstmt = con.prepareStatement("WITH SALES AS (select pc.product_id,sc.person_id,sum(pc.price*pc.quantity) as amount " +  
						 	"from products_in_cart pc " +
						 	"inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true) " +
						 	"group by pc.product_id,sc.person_id), " +
						 "DENOM AS ( " +
							"SELECT product_id, SUM(amount) as denom_sums " +
							"FROM SALES " +
							"GROUP BY product_id) " +
						"SELECT s1.product_id, s2.product_id AS s2_prod, (SUM (s1.amount*s2.amount)/(d1.denom_sums * d2.denom_sums)) as val " +
						"FROM SALES s1 JOIN SALES s2 ON (s1.product_id < s2.product_id), DENOM d1, DENOM d2 " +
						"WHERE s1.person_id = s2.person_id AND d1.product_id = s1.product_id AND d2.product_id = s2.product_id " +
						"GROUP BY (s1.product_id, s2_prod,d1.denom_sums, d2.denom_sums) " +
						"ORDER BY val desc LIMIT 100;");
					
					rs = pstmt.executeQuery();
					%>
					<table align="center">
					<tr>
						<td>Product 1  </td>
						<td>Product 2  </td>
						<td>Similarity </td>
					</tr>
					
					<%
					while(rs.next()){ %>
					<tr>
						<td> <%=rs.getString("product_id")%></td>
-						<td> <%=rs.getString("s2_prod") %></td>
-						<td> <%=rs.getFloat("val") %></td>
					</tr>
					<% }
					%>
					</table>
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