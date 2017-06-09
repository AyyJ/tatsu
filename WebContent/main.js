function showCustJson(str) {
	document.getElementById("log").innerHTML = "inside showCustJson";
	 var xmlHttp = new XMLHttpRequest();
	 var url="jsonCustomer.jsp";
	 url = url + "?action=all";
	 var stateChanged = function () {
			document.getElementById("log").innerHTML = "inside statechanged";
			 if (xmlHttp.readyState==4) {
			  console.log(xmlHttp.responseText);
			  var jsonStr = xmlHttp.responseText;
			  var result = JSON.parse(jsonStr);
			  console.log(result);
			  listAllRows(result);
			 }
		}
	 xmlHttp.onreadystatechange = stateChanged;
	 xmlHttp.open("GET", url, true);
	 xmlHttp.send(null);
	}

function changeColor(){
	document.getElementById("log").innerHTML = "inside changeColor";
	 var xmlHttp = new XMLHttpRequest();
	 var url="jsonCustomer.jsp";
	 url = url + "?action=color";
	 var stateChanged = function () {
			document.getElementById("log").innerHTML = "inside statechanged";
			 if (xmlHttp.readyState==4) {
			  console.log(xmlHttp.responseText);
			  var jsonStr = xmlHttp.responseText;
			  var result = JSON.parse(jsonStr);
			  console.log(result);
			  showDelta(result);
			 }
		}
	 xmlHttp.onreadystatechange = stateChanged;
	 xmlHttp.open("GET", url, true);
	 xmlHttp.send(null);
}
	
function showDelta(obj) {
	var i;
    var row="";
    var arr = obj.CompanyList;
    for(i = 0; i < arr.length; i++) {
    	var x = document.getElementById("name_"+arr[i].id);
    	x.innerHTML = "<label>"+ arr[i].name +"</label>";
    	x.style.backgroundColor = "red"
    	
    	x = document.getElementById("city_"+arr[i].id);
    	x.innerHTML = "<label>"+ arr[i].city +"</label>";
    	x.style.backgroundColor = "red"
    }
}
function listAllRows(obj) {
    var i;
    var row="";
    var arr = obj.CompanyList;
    for(i = 0; i < arr.length; i++) {
    	row = row + "<tr><td id=name_"+arr[i].id+"><label>"+ arr[i].name +"</label></td>" +
    	"<td id=city_"+ arr[i].id +"><label>"+ arr[i].city +" </label></td>"+
    	"</tr>";
    }
    console.log(row);
    document.getElementById("tablebody").innerHTML = row;
    
}