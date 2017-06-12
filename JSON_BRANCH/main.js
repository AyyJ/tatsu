function showCustJson() {
	 var str = document.getElementById('filter_id').value;
	 var xmlHttp = new XMLHttpRequest();
	 var url= "analytics_json.jsp";
	 url = url + "?filter=" + str;
	 var stateChanged = function () {
			 if (xmlHttp.readyState==4) {
			  var jsonStr = xmlHttp.responseText;
			  var result = JSON.parse(jsonStr);
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
			  var jsonStr = xmlHttp.responseText;
			  var result = JSON.parse(jsonStr);
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
    var row="<td>";
    var cols="";
    var arr = obj.prod_headers;
    var arr2 = obj.states;
    var arr3 = obj.inner;
    
    for(i = 0; i < arr.length; i++) {
    	row = row + "<td id='"+ arr[i].prod_name + "'>"+ arr[i].prod_name +" ($" + arr[i].prod_total + ") </td>";
    }
    row = row + "</tr><tr>";
    for(i = 0; i < arr2.length; i++){
    	console.log("Starting for loop for " + arr2[i].state_name);
    	cols = cols + "<td>"+ arr2[i].state_name +" ($" + arr2[i].state_overall_total + ") </td>"; 
    	for(j=0; j<arr3.length; j++){
        	console.log("Starting second for loop for " + arr2[i].state_name);
    		if(arr3[j].state == arr2[i].state_name){
    	    	console.log("inside if statement for " + arr2[i].state_name);
    			cols = cols + "<td id='" + arr3[j].product + "_" + arr3[j].state + "'> $" + arr3[j].total + "</td>";
    		}
    		
    	}
    	cols = cols + "</tr>";
    	
    }

    document.getElementById("tablebody").innerHTML = row + cols;
    
}