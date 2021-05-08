package mypackage;

import java.sql.*;  
import java.io.StringWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
//import com.google.gson.*;

public class Procedures {
    public static Connection con;
    public static Statement st;
    
    public static final String USERNAME="admin";
    public static final String PASSWORD="341rdsPassword";
    public static final String URL="jdbc:mysql://csds-database.cs3zkkouwnd5.us-east-2.rds.amazonaws.com:3306/CSDS341_Project?allowMultiQueries=true";
    public static final String DRIVER="com.mysql.jdbc.Driver";
    
    public static StringWriter sw = new StringWriter();
    public static PrintWriter pw = new PrintWriter(sw);
    
    //public static Gson gson = new Gson();
        
     public static void main(String[] args){
        //System.out.println(Runtime.exec("echo $CLASSPATH"));
         System.out.println(onLoad("AAPL","2017-11-10",2017,4,"Tarun"));
     }
     
     public static String executePost(String query){
        String stackTrace = "";
        try{
           Class.forName(DRIVER);
           con=DriverManager.getConnection(URL, USERNAME, PASSWORD);
           CallableStatement cs =  con.prepareCall(query);
           cs.execute();
        } catch (Exception e) {
           e.printStackTrace(pw);
           stackTrace = sw.toString();
        }
        return stackTrace;
     }
     
     
     public static String createJson(String query){
        String stackTrace = "";
        try{
            Class.forName(DRIVER);
            con=DriverManager.getConnection(URL, USERNAME, PASSWORD);
            CallableStatement cs =  con.prepareCall(query);
            // ResultSet rs = cs.executeQuery();
            boolean isResultSet = cs.execute();
            String json = new String();
            json = "{";
            while(isResultSet) {
                ResultSet resultSet = cs.getResultSet();
                ResultSetMetaData rsmd = resultSet.getMetaData();
                
                String table = new String();
                table = "[";
                
                String colName = rsmd.getColumnLabel(1);
                json += "\"" + colName + "\" : ";
                
                while(resultSet.next()) {
                    
                    String row = new String();
                    row = "{";
                    
                    int numCols = rsmd.getColumnCount();
                    
                    for (int i=1; i<=numCols; i++){
                        
                        String currentColName = rsmd.getColumnLabel(i);
                        
                        row += "\"" + currentColName + "\" : \"";
                        
                        if (i != numCols){
                            row += resultSet.getString(i) + "\", ";
                        } else {
                            row += resultSet.getString(i) + "\"";
                        }
                    }
                    
                    row += "}";
                    
                    table += row + ", ";
                    
                }
                
                if (table.length() > 1){
                   table = table.substring(0, table.length() - 2); 
                }
                //table += "]";
                
                json += table + "],\n";
                
                isResultSet = cs.getMoreResults();
            }
            json = json.substring(0, json.length() - 2);
            json += "}";
            json = json.replaceAll("E-7","");
            return json;
        } catch (Exception e) {
            e.printStackTrace(pw);
            stackTrace = sw.toString();
        }
        return stackTrace;
     }
     
     
    public static String getTupleString(String query){
        String stackTrace = "";
        try{
           Class.forName(DRIVER);
           con=DriverManager.getConnection(URL, USERNAME, PASSWORD);
           CallableStatement cs =  con.prepareCall(query);
           boolean isResultSet = cs.execute();
           ResultSet resultSet = cs.getResultSet();
           String results ="";
           int i=0;
           while(resultSet.next()){
                i++;
                results += cs.getResultSet().getString(i);
           }
           return results;
        } catch (Exception e) {
           e.printStackTrace(pw);
           stackTrace = sw.toString();
        }
        return stackTrace;
     }

    public static String onLoad(String company, String date, int year, int quarter, String user) {
        String query = "{call onLoad(\"" + company + "\",\"" + date + "\",\"" + year + "\",\"" + quarter + "\",\"" + user + "\")}";
        String json = createJson(query);
        return json;
    }
    
    
    public static String updateSummaryStats(String company, String date, int quarter, int year) {
        String query = "{call updateSummaryStats(\"" + company + "\",\"" + date + "\",\"" + quarter + "\",\"" + year + "\")}";
        String json = createJson(query);
        return json;
    }
    
    public static String executiveModalBox(String name) {
        String query = "{call executiveModalBox(\"" + name + "\")}";
        String json = createJson(query);
        return json;
    }
    
    public static String institutionModalBox(String name) {
        String query = "{call institutionModalBox(\"" + name + "\")}";
        String json = createJson(query);
        return json;
    }
    
    public static String signIn(String username) {
        String query = "{call signIn(\"" + username + "\")}";
        String tuple = getTupleString(query);
        return tuple;
    }
    
    
    public static void favorite(String username, String company) {
        String query = "{call favorite(\"" + username + "\",\"" + company + "\")}";
        executePost(query);
    }
    
    public static void updateNotes(String username, String company, String notes) {
        String query = "{call updateNotes(\"" + username + "\",\"" + company + "\",\"" + notes + "\")}";
        executePost(query);
    }
    

}