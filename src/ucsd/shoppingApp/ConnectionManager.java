package ucsd.shoppingApp;

import java.sql.*;

public class ConnectionManager {
	public static Connection con = null;
	
	public ConnectionManager(){	
	}
	
	public static Connection getConnection() {
		try {
			 Class.forName("org.postgresql.Driver");
			
            con = DriverManager.getConnection(
                    "jdbc:postgresql://localhost/Tatsu?" +
                    "user=postgres&password=postgres1");
            con.setAutoCommit(false);
		} catch(Exception e) {
			e.printStackTrace();
		}
		return con;
	}
	
	public static void closeConnection(Connection con) {
		try {
			if(con != null) {
				con.close();
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
}
