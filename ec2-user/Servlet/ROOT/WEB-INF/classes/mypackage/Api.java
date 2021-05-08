package mypackage;

import javax.servlet.ServletException;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServlet;
import java.io.*;
import java.util.*;
import java.time.LocalDate;
import java.time.temporal.IsoFields;
import at.favre.lib.crypto.bcrypt.*;
import at.favre.lib.bytes.*;



public final class Api extends HttpServlet
{
    public void doGet(final HttpServletRequest request, final HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("application/json");
        String date = "";
        final PrintWriter out = response.getWriter();
        // String apiField = request.getPathInfo().substring(5);
        String apiField = sanitize(request.getParameter("get"));
        switch(apiField){
            // need case to get profile w list of favorited companies and companies w notes
            case "onLoad":
                date = sanitize(request.getParameter("date"));
                out.println(Procedures.onLoad(sanitize(request.getParameter("ticker")),date,getYear(date),getQuarter(date),sanitize(request.getParameter("username"))));
                break;
            case "updateSummaryStats":
                date = sanitize(request.getParameter("date"));
                out.println(Procedures.updateSummaryStats(sanitize(request.getParameter("ticker")),date,getQuarter(date),getYear(date)));
                break;
        }
        out.flush();
    }
    
    
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        final PrintWriter out = response.getWriter();
        PrintWriter logger = new PrintWriter("/home/ec2-user/logger.txt");
        String apiField = request.getParameter("post");
        String saltedHash ="";
        String password ="";
        switch(apiField){
            case "signIn":
                password = sanitize(request.getParameter("password"));
                saltedHash = Procedures.signIn(sanitize(request.getParameter("username")));
                boolean result = BCrypt.verifyer().verify(password.toCharArray(), saltedHash).verified;
                out.println(result);
                break;
            case "updateNotes":
                Procedures.updateNotes(sanitize(request.getParameter("username")), sanitize(request.getParameter("ticker")), sanitize(request.getParameter("note")));
                out.println(true);
                break;
            case "favorite":
                Procedures.favorite(sanitize(request.getParameter("username")), sanitize(request.getParameter("ticker")));
                out.println(true);
                break;
        }
        out.flush();
        logger.flush();
    }
  
  
  public static String inputStreamToString(InputStream inputStream) throws IOException {
    ByteArrayOutputStream into = new ByteArrayOutputStream();
    byte[] buf = new byte[4096];
    for (int n; 0 < (n = inputStream.read(buf));)
        into.write(buf, 0, n);
    into.close();
    return new String(into.toByteArray(), "UTF-8");
  }
  
  public static int getQuarter(String date){
    LocalDate localDate = LocalDate.parse(date);
    return localDate.get(IsoFields.QUARTER_OF_YEAR);
  }

  public static int getYear(String date){
    return Integer.parseInt(date.substring(0,4));
  }
  
  public static String sanitize(String unsanitized){
    return unsanitized.replaceAll("[^-0-9a-zA-Z _:.,]", "");
  }
  
  public static void main(String[] args){

  }
  


}





