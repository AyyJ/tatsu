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
					</td>
					</tr>
					</table>
					<%
					PreparedStatement pstmt = null;
					ResultSet rs = null;
					
					/* The following query is from Stack Overflow @
					 * https://stackoverflow.com/questions/42310655/sql-computation-of-cosine-similarity
					 */
					
					pstmt = con.prepareStatement("with data as (select product_name as v , person.id as base, sum(products_in_cart.price * products_in_cart.quantity)as w_td " +
							"from product, person, products_in_cart, shopping_cart where shopping_cart.is_purchased = 'true' and "+
							"product.id = products_in_cart.product_id and products_in_cart.cart_id = shopping_cart.id and "+
							"shopping_cart.person_id = person.id group by product.id, person.id order by product.id), "+
							"norms as ( "+
							  "select v,sum(w_td) as w2 "+
							    "from data "+
							    "group by v) "+
							"select x.v as ego,y.v as v,nx.w2 as x2, ny.w2 as y2, "+
							    "sum(x.w_td * y.w_td) / (nx.w2 * ny.w2) as cosine, 3"+
							"from data as x join data as y on (x.base=y.base) "+
							"join norms as nx on (nx.v=x.v) join norms as ny on (ny.v=y.v) where x.v < y.v "+
							"group by 1,2,3,4 order by 5 desc limit 100");
					
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
						<td> <%=rs.getString("ego")%></td>
-						<td> <%=rs.getString("v") %></td>
-						<td> <%=rs.getFloat("cosine") %></td>
					</tr>
					<% }
					%>
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