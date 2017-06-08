<% response.setContentType("application/json") ; %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.*, java.lang.*"%>
<%@ page import="java.util.*" %>
<%
 class Company{
	private String id;
	private String name;
	private String city;
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}
	
	Company(){
	}
 };
  
 //Get the results from Database
 ArrayList<Company> companies = new ArrayList<Company>();
 System.out.print(request.getParameter("action").toString());
 if (request.getParameter("action").toString().equalsIgnoreCase("all")){
	 for (int i=0;i<10;i++){
		 Company c = new Company();
		 c.setName("Company_"+Integer.toString(i));
		 c.setCity("City_"+Integer.toString(i));
		 c.setId(Integer.toString(i));
		 companies.add(c);
		 //TODO add id to update particular cell
	 }
 }
 else {
	 for (int i=0;i<10;i+=2){
		 Company c = new Company();
		 c.setName("Change_Company_"+Integer.toString(i));
		 c.setCity("Change_City_"+Integer.toString(i));
		 c.setId(Integer.toString(i));
		 companies.add(c);
		 //TODO add id to update particular cell
	 }
 }

 // put the results in Json object
JSONObject jObject = new JSONObject();
try
{
    JSONArray jArray = new JSONArray();
    for (Company c : companies)
    {
         JSONObject cJSON = new JSONObject();
         cJSON.put("id", c.getId());
         cJSON.put("name", c.getName());
         cJSON.put("city", c.getCity());
         jArray.put(cJSON);
    }
    jObject.put("CompanyList", jArray);
} catch (Exception jse) {
    jse.printStackTrace();
}
response.getWriter().print(jObject);
 %>