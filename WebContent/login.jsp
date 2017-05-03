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
  <!-- Custom styles for this template -->
</head>

<body>
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

      <form class="form-signin">
        <h2 class="form-signin-heading">Please log in</h2>
        <label for="name" class="sr-only">Name</label>
        <input type="text" id="name" class="form-control" placeholder="Name" required autofocus>
        <button class="btn btn-lg btn-primary btn-block" style="margin-top: 5px;" type="submit">Sign in</button>
      </form>
        <button class="btn btn-lg btn-primary btn-block" style="width: 300px; margin: auto;" onclick="window.location.href='signup.jsp';">Sign Up</button>
</body>
</html>