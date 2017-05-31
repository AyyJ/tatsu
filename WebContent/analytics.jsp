<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
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
						
						
			<%
			String rowView = request.getParameter("rowView");
			if(rowView == null)
				rowView="customers";
			String ordering = request.getParameter("ordering");
			if(ordering == null)
				ordering="alphabetical";
			String filter = request.getParameter("filter");;
			if(filter == null)
				filter = "all";
			String pageRow = request.getParameter("pageRow");
			if(pageRow == null)
				pageRow = "0";
			String pageColumn = request.getParameter("pageColumn");
			if(pageColumn == null)
				pageColumn = "0";
					
			

			boolean firstPage = true;
			  if(Integer.parseInt(pageRow) != 0)
			  	firstPage = false;
			  if(Integer.parseInt(pageColumn) != 0)
				firstPage = false;
			   
			   
			if(firstPage){
			%>			
						<form action="analytics.jsp" method="post" >
								Select Row View:
								<select name="rowView">
										<option value="<%=rowView %>"><%=rowView %></option>
										<%
										if(rowView.equals("customers")) {%>
										<option value="states">states</option> <% } 
										else{ %>
										<option value="customers">customers</option> <% } %>
										
								</select>
								Order By:
								<select name="ordering">
										<option value="<%=ordering %>"><%=ordering %></option>
										<%
										if(ordering.equals("alphabetical")) {%>
										<option value="top-K">top-K</option> <% } 
										else{ %>
										<option value="alphabetical">alphabetical</option> <% } %>
								</select>
								Filter By:
								<select name="filter">
										<option value="<%=filter %>"><%=filter %></option>
										<%
										if(!filter.equals("all")) {%>
										<option value="all">all</option> <% }
										
											for (CategoryModel cat : category_list) {
										    if(!(cat.getCategoryName().equals(filter))){
										%>
										<option value="<%=cat.getCategoryName()%>"><%=cat.getCategoryName()%></option>
										<%
											} }
										%>
								</select>
							<h4><input type="submit" value="Run Query" /></h4>
						</form>
						<% 
			   }
						%>
					</td>
				</tr>
			</table>	
			<%
			ArrayList<String> consumers = new ArrayList<String>();
			ArrayList<String> products = new ArrayList<String>();
			int sum = 0;
			%>
			
		<%-- -------- Open Connection Code -------- --%>
    	<%
          
    		Connection conn = null;
    		PreparedStatement pstmt = null;
    		PreparedStatement pstmt2 = null;
    		ResultSet rs3 = null;
    		ResultSet rs = null;
    		ResultSet rs2 = null;
        
    		try {
    			// Registering Postgresql JDBC driver with the DriverManager
    			Class.forName("org.postgresql.Driver");

    			// Open a connection to the database using DriverManager
    			conn = DriverManager.getConnection(
    			"jdbc:postgresql://localhost/Tatsu?" +
    			"user=postgres&password=postgres1");
    			
    			if(rowView.equals("customers")){
    				if(filter.equals("all")){
    					if(ordering.equals("alphabetical")){
    						pstmt = conn.prepareStatement("select product_name from product order by product_name limit 10 offset ?");
    						pstmt.setInt(1,Integer.parseInt(pageColumn));
    						rs = pstmt.executeQuery();
    						while(rs.next())
    							products.add(rs.getString("product_name"));
    						pstmt2 = conn.prepareStatement("select person_name from person order by person_name limit 20 offset ?");
    						pstmt2.setInt(1,Integer.parseInt(pageRow));
    						rs3 = pstmt2.executeQuery();
    						while(rs3.next())
    							consumers.add(rs3.getString("person_name"));
    					}
    					else{
    						pstmt = conn.prepareStatement("select p.person_name, sum(p.sum) as total from("
    								+"select person_name, sum(products_in_cart.quantity * products_in_cart.price)as sum from person, shopping_cart,products_in_cart "
    								+"where person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id "
    								+"group by person.person_name "
    								+"union "
    								+"select person.person_name, '0'from person)p group by p.person_name "
    								+"order by total desc limit 20 offset ?");
    						pstmt.setInt(1,0);
    						rs = pstmt.executeQuery();
    						if(rs.next()){
    							pstmt2 = conn.prepareStatement("select p.product_name, sum(p.sum)as total from"
    									 + "(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
    									 + "from product,person,shopping_cart,products_in_cart where person.person_name = ? and "
    									 + "person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
    									 + "product.id = products_in_cart.product_id group by product_name "
    									 + "union "
    									 + "select product_name,'0' from product)p "
    									 + "group by p.product_name order by total desc limit 10 offset ?");
    							pstmt2.setString(1,rs.getString("person_name"));
    							pstmt2.setInt(2,Integer.parseInt(pageColumn));
    							rs2 = pstmt2.executeQuery();
    							while(rs2.next())
    								products.add(rs2.getString("product_name"));
    						}
 							pstmt.setInt(1,Integer.parseInt(pageRow));
							rs3 = pstmt.executeQuery();
							while(rs3.next())
								consumers.add(rs3.getString("person_name"));
    					}
    				}
    				else{
    					if(ordering.equals("alphabetical")){
    						pstmt = conn.prepareStatement("select p.person_name, sum(p.sum) as total from("
    								+"select person.person_name, 1 as sum from person, shopping_cart,products_in_cart,category,product "
    								+"where person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
    								+"products_in_cart.product_id = product.id and product.category_id = category.id and "
    								+"category_name = ? group by person.person_name "
    								+"union "
    								+"select person.person_name ,'0' as sum from person)p "
    								+"group by person_name order  by total desc, person_name asc limit 20 offset ?");
    						pstmt.setString(1,filter);
    						pstmt.setInt(2,0);
    						rs = pstmt.executeQuery();
    						if(rs.next()){
	    						pstmt2 = conn.prepareStatement("select prod.product_name, sum(prod.sum) as total from (select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
	    								+"from product,person,shopping_cart,products_in_cart,category where person.person_name = ? and "
	    								+"person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
	    								+"product.id = products_in_cart.product_id and product.category_id = category.id and "
	    								+"category.category_name = ? group by product_name "
	    								+"union "
	    								+"select product.product_name,'0' from product,category where product.category_id = category.id and "
	    								+"category.category_name = ? )prod group by prod.product_name "
	    								+"order by total desc, product_name asc limit 10 offset ?");
	    						pstmt2.setString(1,rs.getString("person_name"));
	    						pstmt2.setString(2, filter);
	    						pstmt2.setString(3,filter);
	    						pstmt2.setInt(4,Integer.parseInt(pageColumn));
	    						rs2 = pstmt2.executeQuery();
	    						while(rs2.next())
	    							products.add(rs2.getString("product_name"));
    						}
    						pstmt.setString(1,filter);
    						pstmt.setInt(2,Integer.parseInt(pageRow));
    						rs3 = pstmt.executeQuery();
    						while(rs3.next())
    							consumers.add(rs3.getString("person_name"));
    					}
    					else{
    						pstmt = conn.prepareStatement("select p.person_name, sum(p.sum) as total "
    								+"from(select person.person_name, sum(products_in_cart.quantity * products_in_cart.price)as sum "
    								+"from person, shopping_cart,products_in_cart,category,product where person.id = shopping_cart.person_id and "
    								+"shopping_cart.id = products_in_cart.cart_id and products_in_cart.product_id = product.id and "
    								+"product.category_id = category.id and category_name = ? "
    								+"group by person.person_name "
    								+"union "
    								+"select person.person_name ,'0' as sum from person)p "
    								+"group by person_name order by total desc limit 20 offset ?");
    						pstmt.setString(1,filter);
    						pstmt.setInt(2,0);
    						rs = pstmt.executeQuery();
    						if(rs.next()){
	    						pstmt2 = conn.prepareStatement("select prod.product_name, sum(prod.sum) as total "
	    								+"from (select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
	    								+"from product,person,shopping_cart,products_in_cart,category where person.person_name = ? and "
	    								+"person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
	    								+"product.id = products_in_cart.product_id and product.category_id = category.id and "
	    								+"category.category_name = ? group by product_name "
	    								+"union "
	    								+"select product.product_name,'0' from product,category "
	    								+"where product.category_id = category.id and category.category_name = ? )prod "
	    								+"group by prod.product_name order by total desc limit 10 offset ?");
	    						pstmt2.setString(1,rs.getString("person_name"));
	    						pstmt2.setString(2, filter);
	    						pstmt2.setString(3,filter);
	    						pstmt2.setInt(4,Integer.parseInt(pageColumn));
	    						rs2 = pstmt2.executeQuery();
	    						while(rs2.next())
	    							products.add(rs2.getString("product_name"));
    						}
    						pstmt.setString(1,filter);
    						pstmt.setInt(2,Integer.parseInt(pageRow));
    						rs3 = pstmt.executeQuery();
    						while(rs3.next())
    							consumers.add(rs3.getString("person_name"));
    					}
    				}
    			}
    			else{
    				if(filter.equals("all")){
    					if(ordering.equals("alphabetical")){
    						pstmt = conn.prepareStatement("select product_name from product order by product_name limit 10 offset ?");
    						pstmt.setInt(1,Integer.parseInt(pageColumn));
    						rs = pstmt.executeQuery();
    						while(rs.next())
    							products.add(rs.getString("product_name"));
    						pstmt2 = conn.prepareStatement("select state_name from state order by state_name limit 20 offset ?");
    						pstmt2.setInt(1, Integer.parseInt(pageRow));
    						rs3 = pstmt2.executeQuery();
    						while(rs3.next())
    							consumers.add(rs3.getString("state_name"));
    					}
    					else{
    						pstmt = conn.prepareStatement("select s.state_name, sum(s.sum) as sum from("
    								+"select state.state_name, sum(products_in_cart.quantity * products_in_cart.price)as sum from state,person, shopping_cart,products_in_cart "
    								+"where person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and " 
    								+"person.state_id = state.id group by state.state_name " 
    								+"union "
    								+"select state.state_name, '0' from state)s "
    								+"group by s.state_name order  by sum desc limit 20 offset ?");
    						pstmt.setInt(1,0);
    						rs = pstmt.executeQuery();
    						if(rs.next()){
    							pstmt2 = conn.prepareStatement("select prod.product_name, sum(prod.sum)as total "
    									+ "from(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
    									+ "from state, product,person,shopping_cart,products_in_cart "
    									+ "where state.state_name = ? and person.state_id = state.id and "
    									+ "person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
    									+ "product.id = products_in_cart.product_id group by product_name "
    									+ "union "
    									+ "select product_name,'0' from product)prod "
    									+ "group by prod.product_name order by total desc limit 10 offset ?");
    							pstmt2.setString(1,rs.getString("state_name"));
    							pstmt2.setInt(2,Integer.parseInt(pageColumn));
    							rs2 = pstmt2.executeQuery();
    							while(rs2.next())
    								products.add(rs2.getString("product_name"));
    						}
    						pstmt.setInt(1,Integer.parseInt(pageRow));
    						rs3 = pstmt.executeQuery();
    						while(rs3.next())
    							consumers.add(rs3.getString("state_name"));
    					}
    				}
    				else{
    					if(ordering.equals("alphabetical")){
    						pstmt = conn.prepareStatement("select s.state_name, sum(s.sum)as total from(select state.state_name, 1 as sum "
    								+"from state,person, shopping_cart,products_in_cart,product,category where person.id = shopping_cart.person_id and "
    								+"shopping_cart.id = products_in_cart.cart_id and person.state_id = state.id and "
    								+"products_in_cart.product_id = product.id and product.category_id = category.id and "
    								+"category.category_name = ? group by state.state_name "
    								+"union "
    								+"select state.state_name, '0' from state)s "
    								+"group by s.state_name order by total desc, state_name asc limit 20 offset ?");
    						pstmt.setString(1,filter);
    						pstmt.setInt(2,0);
    						rs = pstmt.executeQuery();
    						if(rs.next()){
	    						pstmt2 = conn.prepareStatement("select prod.product_name, sum(prod.sum)as total from("
	    								+"select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
	    								+"from state, product,person,shopping_cart,products_in_cart,category "
	    								+"where state.state_name = ? and person.state_id = state.id and "
	    								+"person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
	    								+"product.id = products_in_cart.product_id and product.category_id = category.id and "
	    								+"category.category_name = ? group by product_name "
	    								+"union "
	    								+"select product_name,'0'  from product,category "
	    								+"where category.id = product.category_id and category.category_name = ?)prod "
	    								+"group by prod.product_name order by total desc, product_name asc limit 10 offset ?");
	    						pstmt2.setString(1,rs.getString("state_name"));
	    						pstmt2.setString(2, filter);
	    						pstmt2.setString(3,filter);
	    						pstmt2.setInt(4,Integer.parseInt(pageColumn));
	    						rs2 = pstmt2.executeQuery();
	    						while(rs2.next())
	    							products.add(rs2.getString("product_name"));
    						}
    						pstmt.setString(1,filter);
    						pstmt.setInt(2,Integer.parseInt(pageRow));
    						rs3 = pstmt.executeQuery();
    						while(rs3.next())
    							consumers.add(rs3.getString("state_name"));
    					}
    					else{
    						pstmt = conn.prepareStatement("select s.state_name, sum(s.sum)as total "
    								+"from(select state.state_name, sum(products_in_cart.quantity * products_in_cart.price)as sum "
    								+"from state,person, shopping_cart,products_in_cart,product,category "
    								+"where person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and " 
    								+"person.state_id = state.id and products_in_cart.product_id = product.id and "
    								+"product.category_id = category.id and category.category_name = ? group by state.state_name "
    								+"union "
    								+"select state.state_name, '0' from state)s "
    								+"group by s.state_name order by total desc limit 20 offset ?");
    						pstmt.setString(1,filter);
    						pstmt.setInt(2,0);
    						rs = pstmt.executeQuery();
    						if(rs.next()){
	    						pstmt2 = conn.prepareStatement("select prod.product_name, sum(prod.sum)as total "
	    								+ "from(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
	    								+"from state, product,person,shopping_cart,products_in_cart,category "
	    								+"where state.state_name = ? and person.state_id = state.id and "
	    								+"person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
	    								+"product.id = products_in_cart.product_id and product.category_id = category.id and "
	    								+"category.category_name = ? group by product_name "
	    								+"union "
	    								+"select product_name,'0'  from product,category "
	    								+"where category.id = product.category_id and category.category_name = ? )prod "
	    								+"group by prod.product_name order by total desc limit 10 offset ?");
	    						pstmt2.setString(1,rs.getString("state_name"));
	    						pstmt2.setString(2, filter);
	    						pstmt2.setString(3,filter);
	    						pstmt2.setInt(4,Integer.parseInt(pageColumn));
	    						rs2 = pstmt2.executeQuery();
	    						while(rs2.next())
	    							products.add(rs2.getString("product_name"));
    						}
    						pstmt.setString(1,filter);
    						pstmt.setInt(2,Integer.parseInt(pageRow));
    						rs3 = pstmt.executeQuery();
    						while(rs3.next())
    							consumers.add(rs3.getString("state_name"));
    					}
    				}
    			}
    			//done with columns and rows
    			%>
    			<table border =1 align="center">
    			
    			<tr>
    			<td></td>
    			<%
    				for(String prod:products){
    					%>
    					<td><%=prod %></td>
    					<%
    				}
    			%>
    			</tr>
    			<%
    				for(String cons:consumers){
    		////////////////////////// Table for Customers ////////////////////
    					if(rowView.equals("customers")){
    						if(filter.equals("all")){
	    						if(ordering.equals("alphabetical")){
	    							pstmt = conn.prepareStatement("select prod.product_name, sum(sum) as total "
	    									+"from(select product.product_name,product.id, sum(products_in_cart.price * products_in_cart.quantity) as sum "
	    									+"from product, products_in_cart,shopping_cart,person where person.person_name = ? and "
	    									+"person.id = shopping_cart.person_id and shopping_cart.is_purchased = 'true' and "
	    									+"shopping_cart.id = products_in_cart.cart_id and "
	    									+"products_in_cart.product_id = product.id group by product.product_name,product.id "
	    									+"union "
	    									+"select product.product_name, product.id,'0' from product) prod "
	    									+"group by prod.product_name, prod.id order by prod.product_name limit 10 offset ?");
	    							pstmt.setString(1,cons);
	    							pstmt.setInt(2,Integer.parseInt(pageColumn));
	    							rs = pstmt.executeQuery();
	    							sum = 0;
	    							while(rs.next())
	    								sum = sum + rs.getInt("total");
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							pstmt.setString(1,cons);
	    							pstmt.setInt(2,Integer.parseInt(pageColumn));
	    							rs2 = pstmt.executeQuery();
	    							while(rs2.next()){ %>
	    								<td>$<%= rs2.getInt("total") %></td>
	    							<% } %>
	    							</tr> <%
	    						}
	    						else{
	    							pstmt = conn.prepareStatement("select prod.product_name, sum(sum) as total "
	    									+"from(select product.product_name,product.id, sum(products_in_cart.price * products_in_cart.quantity) as sum "
	    									+"from product, products_in_cart,shopping_cart,person "
	    									+"where person.person_name = ? and person.id = shopping_cart.person_id and "
	    									+"shopping_cart.is_purchased = 'true' and shopping_cart.id = products_in_cart.cart_id and "
	    									+"products_in_cart.product_id = product.id group by product.product_name,product.id "
	    									+"union "
	    									+"select product.product_name, product.id,'0' from product) prod "
	    									+"group by prod.product_name, prod.id order by prod.id limit 10 offset ?");
	    							pstmt.setString(1,cons);
	    							pstmt.setInt(2,Integer.parseInt(pageColumn));
	    							rs = pstmt.executeQuery();
	    							sum = 0;
	    							while(rs.next())
	    								sum = sum + rs.getInt("total");	
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							pstmt.setString(1,cons);
	    							pstmt.setInt(2,Integer.parseInt(pageColumn));
	    							rs2 = pstmt.executeQuery();
	    							while(rs2.next()){ %>
	    								<td>$<%= rs2.getInt("total") %></td>
	    							<% } %>
	    							</tr> <%
	    						}
    						}
    						else{
    							if(ordering.equals("alphabetical")){
    								pstmt = conn.prepareStatement("select prod.product_name, sum(prod.sum) as total from ("
    										+"select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
    										+"from product,person,shopping_cart,products_in_cart,category "
    										+"where person.person_name = ? and person.id = shopping_cart.person_id and "
    										+"shopping_cart.id = products_in_cart.cart_id and product.id = products_in_cart.product_id and "
    										+"product.category_id = category.id and category.category_name = ? group by product_name "
    										+"union "
    										+"select product.product_name,'0' from product,category "
    										+"where product.category_id = category.id and category.category_name = ? )prod "
    										+"group by prod.product_name order by total desc, product_name asc limit 10 offset ?");
    								pstmt.setString(1,cons);
    								pstmt.setString(2,filter);
    								pstmt.setString(3,filter);
	    							pstmt.setInt(4,Integer.parseInt(pageColumn));
	    							rs = pstmt.executeQuery();
	    							sum = 0;
	    							while(rs.next())
	    								sum = sum + rs.getInt("total");
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							pstmt.setString(1,cons);
    								pstmt.setString(2,filter);
    								pstmt.setString(3,filter);
	    							pstmt.setInt(4,Integer.parseInt(pageColumn));
	    							rs2 = pstmt.executeQuery();
	    							while(rs2.next()){ %>
	    								<td>$<%= rs2.getInt("total") %></td>
	    							<% } %>
	    							</tr> <%
    							}
    							else{
    								pstmt = conn.prepareStatement("select prod.product_name, sum(prod.sum) as total "
    										+"from (select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
    										+"from product,person,shopping_cart,products_in_cart,category where person.person_name = ? and person.id = shopping_cart.person_id and "
    										+"shopping_cart.id = products_in_cart.cart_id and product.id = products_in_cart.product_id and "
    										+"product.category_id = category.id and "
    										+"category.category_name = ? group by product_name "
    										+"union "
    										+"select product.product_name,'0' from product,category "
    										+"where product.category_id = category.id and category.category_name = ? )prod "
    										+"group by prod.product_name order by total desc limit 10 offset ?");
    								pstmt.setString(1,cons);
    								pstmt.setString(2,filter);
    								pstmt.setString(3,filter);
	    							pstmt.setInt(4,Integer.parseInt(pageColumn));
	    							rs = pstmt.executeQuery();
	    							sum = 0;
	    							while(rs.next())
	    								sum = sum + rs.getInt("total");	
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							pstmt.setString(1,cons);
    								pstmt.setString(2,filter);
    								pstmt.setString(3,filter);
	    							pstmt.setInt(4,Integer.parseInt(pageColumn));
	    							rs2 = pstmt.executeQuery();
	    							while(rs2.next()){ %>
	    								<td>$<%= rs2.getInt("total") %></td>
	    							<% } %>
	    							</tr> <%
    							}
    						}
    					}
    					
    	////////////////////// Table for States ////////////////////////
    					else{
    						if(filter.equals("all")){
	    						if(ordering.equals("alphabetical")){
	    							pstmt = conn.prepareStatement("select prod.product_name, prod.price, sum(prod.total), sum (prod.price * prod.total) as total  from "  
	    									+"(select product_name, product.price ,sum(products_in_cart.quantity) as total " 
	    									+"from product , products_in_cart, shopping_cart,state, person " 
	    									+"where product.id = products_in_cart.product_id and " 
	    									+"products_in_cart.cart_id = shopping_cart.id and shopping_cart.is_purchased = 'true' and " 
	    									+"shopping_cart.person_id = person.id and person.state_id = state.id and " 
	    									+"state.state_name = ? group by product_name, product.price " 
	    									+"union " 
	    									+"select product_name, product.price ,'0' as total from product) prod " 
	    									+"group by prod.product_name, prod.price order by prod.product_name limit 10 offset ?");
	    							pstmt.setString(1,cons);
	    							pstmt.setInt(2,Integer.parseInt(pageColumn));
	    							rs = pstmt.executeQuery();
	    							sum = 0;
	    							while(rs.next())
	    								sum = sum + rs.getInt("total");
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							pstmt.setString(1,cons);
	    							pstmt.setInt(2,Integer.parseInt(pageColumn));
	    							rs2 = pstmt.executeQuery();
	    							while(rs2.next()){ %>
	    								<td>$<%= rs2.getInt("total") %></td>
	    							<% } %>
	    							</tr> <%
	    						}
	    						else{
	    							pstmt = conn.prepareStatement("select prod.product_name, sum(prod.total)as total "
	    									+ "from(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as total "
	    									+ "from state, product,person,shopping_cart,products_in_cart where state.state_name = ? and "
	    									+ "person.state_id = state.id and person.id = shopping_cart.person_id and "
	    									+ "shopping_cart.id = products_in_cart.cart_id and "
	    									+ "product.id = products_in_cart.product_id group by product_name "
	    									+ "union "
	    									+ "select product_name,'0' from product)prod "
	    									+ "group by prod.product_name order by total desc limit 10 offset ?");
	    							pstmt.setString(1,cons);
	    							pstmt.setInt(2,Integer.parseInt(pageColumn));
	    							rs = pstmt.executeQuery();
	    							sum = 0;
	    							while(rs.next())
	    								sum = sum + rs.getInt("total");	
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							pstmt.setString(1,cons);
	    							pstmt.setInt(2,Integer.parseInt(pageColumn));
	    							rs2 = pstmt.executeQuery();
	    							while(rs2.next()){ %>
	    								<td>$<%= rs2.getInt("total") %></td>
	    							<% } %>
	    							</tr> <%
	    						}
    						}
    						else{
    							if(ordering.equals("alphabetical")){
    								pstmt = conn.prepareStatement("select prod.product_name, sum(prod.sum)as total from("
    										+"select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
    										+"from state, product,person,shopping_cart,products_in_cart,category "
    										+"where state.state_name = ? and person.state_id = state.id and "
    										+"person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
    										+"product.id = products_in_cart.product_id and product.category_id = category.id and "
    										+"category.category_name = ? group by product_name "
    										+"union "
    										+"select product_name,'0'  from product,category "
    										+"where category.id = product.category_id and category.category_name = ?)prod "
    										+"group by prod.product_name order by total desc, product_name asc limit 10 offset ?");
    								pstmt.setString(1,cons);
    								pstmt.setString(2,filter);
    								pstmt.setString(3,filter);
	    							pstmt.setInt(4,Integer.parseInt(pageColumn));
	    							rs = pstmt.executeQuery();
	    							sum = 0;
	    							while(rs.next())
	    								sum = sum + rs.getInt("total");
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							pstmt.setString(1,cons);
    								pstmt.setString(2,filter);
    								pstmt.setString(3,filter);
	    							pstmt.setInt(4,Integer.parseInt(pageColumn));
	    							rs2 = pstmt.executeQuery();
	    							while(rs2.next()){ %>
	    								<td>$<%= rs2.getInt("total") %></td>
	    							<% } %>
	    							</tr> <%
    							}
    							else{
    								pstmt = conn.prepareStatement("select prod.product_name, sum(prod.sum)as total "
    										+ "from(select product.product_name ,sum(products_in_cart.price * products_in_cart.quantity) as sum "
    										+"from state, product,person,shopping_cart,products_in_cart,category "
    										+"where state.state_name = ? and person.state_id = state.id and "
    										+"person.id = shopping_cart.person_id and shopping_cart.id = products_in_cart.cart_id and "
    										+"product.id = products_in_cart.product_id and product.category_id = category.id and "
    										+"category.category_name = ? group by product_name "
    										+"union "
    										+"select product_name,'0'  from product,category "
    										+"where category.id = product.category_id and category.category_name = ? )prod "
    										+"group by prod.product_name order by total desc limit 10 offset ?");
    								pstmt.setString(1,cons);
    								pstmt.setString(2,filter);
    								pstmt.setString(3,filter);
	    							pstmt.setInt(4,Integer.parseInt(pageColumn));
	    							rs = pstmt.executeQuery();
	    							sum = 0;
	    							while(rs.next())
	    								sum = sum + rs.getInt("total");	
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							pstmt.setString(1,cons);
    								pstmt.setString(2,filter);
    								pstmt.setString(3,filter);
	    							pstmt.setInt(4,Integer.parseInt(pageColumn));
	    							rs2 = pstmt.executeQuery();
	    							while(rs2.next()){ %>
	    								<td>$<%= rs2.getInt("total") %></td>
	    							<% } %>
	    							</tr> <%
    							}
    						}
    					}
    				}
    			if(consumers.size() >= 20){
        			if(rowView.equals("customers")){
        				%>
        				<td align="center">
        				<form method="GET" action="analytics.jsp">
        				<input type="hidden" value="<%= Integer.parseInt(pageRow)+20 %>" name="pageRow" />
        				<input type="hidden" value="<%= Integer.parseInt(pageColumn) %>" name="pageColumn" />
        				<input type="hidden" value="<%= rowView %>" name="rowView" />
        				<input type="hidden" value="<%= ordering %>" name="ordering" />
        				<input type="hidden" value="<%= filter %>" name="filter" />
        				<input type="submit" value="Next 20 Customers"/>
        				</form>
        				</td><%
        			}
        				else{%>
        				<td align="center">
        				<form method="GET" action="analytics.jsp">
        				<input type="hidden" value="<%= Integer.parseInt(pageRow)+20 %>" name="pageRow" />
        				<input type="hidden" value="<%= Integer.parseInt(pageColumn) %>" name="pageColumn" />
        				<input type="hidden" value="<%= rowView %>" name="rowView" />
        				<input type="hidden" value="<%= ordering %>" name="ordering" />
        				<input type="hidden" value="<%= filter %>" name="filter" />
        				<input type="submit" value="Next 20 States"/>
        				</form>
        				</td><%
        			}
        		}
        		if(products.size() >= 10){ %>
        				<td align = "center">
        				<form method="GET" action="analytics.jsp">
        				<input type="hidden" value="<%= Integer.parseInt(pageRow) %>" name="pageRow" />
        				<input type="hidden" value="<%= Integer.parseInt(pageColumn) +10 %>" name="pageColumn" />
        				<input type="hidden" value="<%= rowView %>" name="rowView" />
        				<input type="hidden" value="<%= ordering %>" name="ordering" />
        				<input type="hidden" value="<%= filter %>" name="filter" />
        				<input type="submit" value="Next 10 Products"/>
        				</form>
        				</td> <%
        		} %>
    			</table>
    			<%
            }
			catch(SQLException e){
    			System.out.print(e);	
    		}
            finally{
            	if (rs != null) {
                    try {
                        rs.close();
                    } catch (SQLException e) { } // Ignore
                    rs = null;
                }
            	if (rs2 != null) {
                    try {
                        rs2.close();
                    } catch (SQLException e) { } // Ignore
                    rs2 = null;
                }
            	if (rs3 != null) {
                    try {
                        rs3.close();
                    } catch (SQLException e) { } // Ignore
                    rs3 = null;
                }
                if (pstmt != null) {
                    try {
                        pstmt.close();
                    } catch (SQLException e) { } // Ignore
                    pstmt = null;
                }
                if (pstmt2 != null) {
                    try {
                        pstmt2.close();
                    } catch (SQLException e) { } // Ignore
                    pstmt2 = null;
                }
                if (conn != null) {
                    try {
                        conn.close();
                    } catch (SQLException e) { } // Ignore
                    conn = null;
                }
            }
    		
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