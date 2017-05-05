    <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>myShop :: Shopping Cart</title>
        <!-- Bootstrap core CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <link rel="stylesheet" href="global.css">
        </head>
        <body>
        <nav class="navbar navbar-inverse navbar-fixed-top">
        <div class="container-fluid">
        <div class="navbar-header">
        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="#">myShop</a>
        </div>
        </div>
        </nav>

        <div class="container-fluid">
		  <div class="row">
		    <div class="col-sm-3 col-md-2 sidebar">
		      <ul class="nav nav-sidebar">
		        <li class="active"><a href="home.jsp">Home</a></li>
				  <% if(session.getAttribute("role").equals("1")){ %>
				    <li><a href="#">Categories <span class="sr-only">(current)</span></a></li>
				  <% } else { %>
					<li><a href="error.html">Categories</a></li>
				  <% } %>
				  <% if(session.getAttribute("role").equals("1")){ %>
					<li><a href="manageProducts.jsp">Manage Products</a></li>
				  <% } else { %>
					<li><a href="error.html">Manage Products</a></li>
				  <% } %>
				<li><a href="viewProducts.jsp">View Products</a></li>
		        <li><a href="order.jsp">Order</a></li>
		        <li><a href="shoppingCart.jsp">Shopping Cart</a></li>
		      </ul>
		    </div>
            <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
              <h1 class="page-header">Welcome to myShop <% if(session.getAttribute("name") != null) { out.print(session.getAttribute("name"));} %></h1>

        <div class="row placeholders">

        </div>
        <!-- Save for later?
        <h2 class="sub-header">Section title</h2>
        <div class="table-responsive">
        <table class="table table-striped">
        <thead>
        <tr>
        <th>#</th>
        <th>Header</th>
        <th>Header</th>
        <th>Header</th>
        <th>Header</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>1,001</td>
        <td>Lorem</td>
        <td>ipsum</td>
        <td>dolor</td>
        <td>sit</td>
        </tr>
        <tr>
        <td>1,002</td>
        <td>amet</td>
        <td>consectetur</td>
        <td>adipiscing</td>
        <td>elit</td>
        </tr>
        <tr>
        <td>1,003</td>
        <td>Integer</td>
        <td>nec</td>
        <td>odio</td>
        <td>Praesent</td>
        </tr>
        <tr>
        <td>1,003</td>
        <td>libero</td>
        <td>Sed</td>
        <td>cursus</td>
        <td>ante</td>
        </tr>
        </tbody>
        </table>
        </div> -->
        </div>
        </div>
        </div>
        </body>
        </html>