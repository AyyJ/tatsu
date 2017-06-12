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

						<div id="sorry"> </div>
						<% if (request.getAttribute("error")!=null && Boolean.parseBoolean(request.getAttribute("error").toString())) {%>
							<h4 style="color:red"> Error : <%= request.getAttribute("errorMsg").toString()%></h4>
						<%}%>
						<% if (request.getAttribute("message")!=null) {%>
							<h4> Message : <%= request.getAttribute("message").toString()%></h4>
						<%}%>


			<%
			
			String filter = request.getParameter("filter");
			String firstPage = request.getParameter("firstPage");
			if(filter == null)
				filter = "all";
			if(firstPage == null)
				firstPage = "true";
			



		
			
			%>
						<form action="analytics.jsp" method="post" >
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
								<input type="hidden" value="true" name="firstPage" />
							<h4><input type="submit" value="Run Query" /></h4>
						</form>
					</td>
				</tr>
			</table>
			<button onClick="refreshTable();" value="refresh" style="float: left;">Refresh</button>
          <button onClick="refreshTable();" value="refresh" style="float: right;">Refresh</button>
			<%
			ArrayList<String> consumers = new ArrayList<String>();
			ArrayList<String> products = new ArrayList<String>();
			ArrayList<Integer> totals = new ArrayList<Integer>();
			int sum = 0;
			int sum2 = 0;
			int tot = 0;
			%>

		<%-- -------- Open Connection Code -------- --%>
    	<%

    		Connection conn = null;
    		PreparedStatement pstmt = null;
    		PreparedStatement pstmt2 = null;
    		ResultSet rs3 = null;
    		ResultSet rs = null;
    		ResultSet rs2 = null;
    		ResultSet rs4 = null;

    		try {
    			// Registering Postgresql JDBC driver with the DriverManager
    			Class.forName("org.postgresql.Driver");

    			// Open a connection to the database using DriverManager
    			conn = DriverManager.getConnection(
    			"jdbc:postgresql://localhost/Tatsu?" +
    			"user=postgres&password=postgres1");

    			if(filter.equals("all")){
							pstmt2 = conn.prepareStatement("SELECT * FROM stateSales ORDER BY totalsale DESC LIMIT 50 ");
							rs2 = pstmt2.executeQuery();
							while(rs2.next()){
								consumers.add(rs2.getString("state_name"));
							}
    						// top k state ordering, filter by all
    						pstmt = conn.prepareStatement("SELECT product_name,Sum(total) as totalsale FROM stateTopK WHERE state_name=? GROUP BY product_name ORDER BY totalsale DESC LIMIT 50 ");
    						pstmt.setString(1,consumers.get(0));
    						rs = pstmt.executeQuery();
    						while(rs.next()) {
    							products.add(rs.getString("product_name"));
							}
    		}
    				
    				else{
    					
    						// top k state ordering, filter by category
	    					pstmt2 = conn.prepareStatement("SELECT * FROM filteredStateSales WHERE category_name=? union SELECT * FROM filteredStateSales WHERE category_name is null ORDER BY totalsale DESC LIMIT 50 ");
							pstmt2.setString(1,filter);
							rs2 = pstmt2.executeQuery();
							while(rs2.next()){
								consumers.add(rs2.getString("state_name"));
							}
    						pstmt = conn.prepareStatement("SELECT product_name, p.sale AS totalsale FROM filteredStateTopK, "
    								+ "(SELECT SUM(total) AS sale FROM filteredStateTopK WHERE state_name = ?) as p "
									+ "WHERE category_name=? GROUP BY product_name, p.sale "
									+ "ORDER BY totalsale DESC LIMIT 50");
    						pstmt.setString(2,filter);
    						pstmt.setString(1,consumers.get(0));
    						//pstmt.setString(3,filter);
    						//pstmt.setString(4,consumers.get(0));
    						rs = pstmt.executeQuery();
    						while(rs.next()){
    							products.add(rs.getString("product_name"));
    						}
    					}
    			
    				
    			
    			//done with columns and rows
    			%>
    	
    			<table border =1 align="center">

    			<tr>
    			<td>
    	
    			<%
    				for(String prod:products){
    					if(filter.equals("all")){
	    					pstmt = conn.prepareStatement("SELECT totalsale FROM topSales WHERE product_name = ? ORDER BY totalsale");
	    					pstmt.setString(1, prod);
    					}
    					else{
    						pstmt = conn.prepareStatement("SELECT totalsale FROM filteredProdSales WHERE product_name = ? ORDER BY totalsale");
	    					pstmt.setString(1, prod);
	    					//pstmt.setString(2,filter);
    					}
    					rs = pstmt.executeQuery();
    					while(rs.next())
    						sum2 = (int)rs.getDouble("totalsale");
    					
    					%>
    					<td><%=prod %> ($<%=sum2 %>)</td>
    					<%
    				}
    			%>
				</tr>
    			<%
    				for(String cons:consumers){
    		////////////////////////// Table for Customers ////////////////////
    					
	    						
	    							
	    							sum = 0;
	    							for(int index = 0; index < products.size(); index++){
		    							pstmt = conn.prepareStatement("SELECT total FROM stateTopK WHERE state_name = ? AND product_name = ?");
		    							pstmt.setString(1,cons);
		    							pstmt.setString(2,products.get(index));

		    							rs = pstmt.executeQuery();
		    							while(rs.next()){
		    								tot = rs.getInt("total");
		    								sum = sum + tot;
		    								totals.add(index, tot);
		    							}
	    							}
	    							%>
	    							<tr>
	    							<td><%= cons %> ($<%= sum %>)</td>
	    							<%
	    							
	    							for(int i = 0; i < totals.size(); i++){ %>
	    								<td>$<%= totals.get(i) %></td>
	    							<% } %>
	    							</tr> <%
	    							totals.clear();
    						
    					    						}
    			%>
    			
    			</table>
		  <button onClick="refreshTable();" value="refresh" style="float: left;">Refresh</button>
          <button onClick="refreshTable();" value="refresh" style="float: right;">Refresh</button>
    			<%
            }
			catch(SQLException e){
    			System.out.print(e + "\n");
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
