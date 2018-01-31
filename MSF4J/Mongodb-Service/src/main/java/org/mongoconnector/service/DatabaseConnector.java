package org.mongoconnector.service;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.msf4j.MicroservicesRunner;

public class DatabaseConnector {

    private static final Logger log = LoggerFactory.getLogger(MicroservicesRunner.class);
    MongoDbConnector mongo = new MongoDbConnector();

    public String getJobDatafromDatabase() {
        Connection conn = null;
        Statement stmt = null;

        Configuration conf = new Configuration();
        ReaderYml read = new ReaderYml();
        try{
            conf = read.readYaml();
        }catch (IOException e){

        }


        try {
            Class.forName(conf.getJDBC_DRIVER());
            conn = DriverManager.getConnection(conf.getDB_URL(), conf.getUSER(), conf.getPASS());
            log.info("PQD DATABASE CONNECTED SUCCESSFULLY");

            stmt = conn.createStatement();
            String sql;
            sql = "SELECT buildNumber,component FROM JNKS_FAILED_BUILD_DETAILS WHERE BINARY failureReason = 'UNKNOWN'";
            ResultSet rs = stmt.executeQuery(sql);

            while(rs.next()){
                //Retrieve by column name
                int buildNumber  = rs.getInt("buildNumber");
                String component = rs.getString("component");
                String failureReasonsCategory = "";
                String updateResult ="done";

                //Display values
                System.out.print("buildNumber: " + buildNumber);
                System.out.println(", component: " + component);
                String mongoResult = mongo.getReasonsFromDatabase(component,buildNumber);

                if( !mongoResult.equals("null")){
                    JSONObject resultJSON = new JSONObject(mongoResult);
                    String result = resultJSON.getString("result");

                    if(resultJSON.has("failureCauses")){
                        List<String> patternList = new ArrayList<String>(); //contains the set of failure patterns

                        JSONArray failureCauses = resultJSON.getJSONArray("failureCauses");

                        for (int i = 0; i < failureCauses.length(); i++) {
                            JSONObject cause = failureCauses.getJSONObject(i);
                            JSONArray indications = cause.getJSONArray("indications");
                            for(int x = 0; x < indications.length(); x++){
                                JSONObject pattern = indications.getJSONObject(x);
                                String patternOfFailure = pattern.getString("pattern");
                                patternList.add(patternOfFailure);
                            }

                        }

                        //getting failure category from mongodb
                        for (int y=0; y < patternList.size(); y++){
                            System.out.println("GETTING CATEGORIES FROM MONGODB");
                            String currentPattern = patternList.get(y);
                            String category = mongo.getFailureCategory(currentPattern);

                            JSONObject categoryJSON = new JSONObject(category);

                            if(categoryJSON.has("categories")){
                                JSONArray failureCategoryArray = categoryJSON.getJSONArray("categories");
                                String categoryOfFailure = failureCategoryArray.get(0).toString();

                                failureReasonsCategory += categoryOfFailure+",";
                            }

                        }

                        if(!failureReasonsCategory.equals("")){
                            failureReasonsCategory = failureReasonsCategory.substring(0, failureReasonsCategory.length() - 1);
                            updateResult = updateFailureReason(buildNumber,component,failureReasonsCategory);
                        }else{
                            failureReasonsCategory = "Unknown";
                            updateResult = updateFailureReason(buildNumber,component,failureReasonsCategory);
                        }

                    }else{
                       if(result.equals("UNSTABLE")){
                           failureReasonsCategory = result;
                           updateResult = updateFailureReason(buildNumber,component,failureReasonsCategory);
                       }else{
                           failureReasonsCategory = "Unknown";
                           updateResult = updateFailureReason(buildNumber,component,failureReasonsCategory);
                       }
                    }


                    if(updateResult.equals("done")){
                        log.info("--------------------------------------------------------------------------------------");
                        log.info("- BUILD "+buildNumber+"-"+component+" FAILURE REASON UPDATED SUCCESSFULLY");
                        log.info("--------------------------------------------------------------------------------------");
                    }else{
                        log.info("--------------------------------------------------------------------------------------");
                        log.info("- BUILD "+buildNumber+"-"+component+" FAILURE REASON UPDATED FAILED");
                        log.info("--------------------------------------------------------------------------------------");
                    }
                }else{
                    failureReasonsCategory = "Unknown";
                    updateResult = updateFailureReason(buildNumber,component,failureReasonsCategory);

                    if(updateResult.equals("done")){
                        log.info("--------------------------------------------------------------------------------------");
                        log.info("- BUILD "+buildNumber+"-"+component+" FAILURE REASON UPDATED SUCCESSFULLY");
                        log.info("--------------------------------------------------------------------------------------");
                    }else{
                        log.info("--------------------------------------------------------------------------------------");
                        log.info("- BUILD "+buildNumber+"-"+component+" FAILURE REASON UPDATED FAILED");
                        log.info("--------------------------------------------------------------------------------------");
                    }
                }

            }
            rs.close();
            stmt.close();
            conn.close();

        } catch (Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        } finally {
            //finally block used to close resources
            try {
                if (stmt != null)
                    stmt.close();
            } catch (SQLException se2) {
            }// nothing we can do
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }

        return "JDBC SHUTING DOWN";
    }

    public String updateFailureReason(int buildNumber, String component, String reason){
        Connection conn = null;
        Statement stmt = null;

        Configuration conf = new Configuration();
        ReaderYml read = new ReaderYml();
        try{
            conf = read.readYaml();
        }catch (IOException e){

        }

        String result = "done";
        try {
            Class.forName(conf.getJDBC_DRIVER());
            conn = DriverManager.getConnection(conf.getDB_URL(), conf.getUSER(), conf.getPASS());

            stmt = conn.createStatement();
            String sql = "UPDATE JNKS_FAILED_BUILD_DETAILS SET failureReason =? WHERE buildNumber =? AND component=? ;";
            PreparedStatement ps = conn.prepareStatement(sql);

            // set the preparedstatement parameters
            ps.setString(1,reason);
            ps.setInt(2,buildNumber);
            ps.setString(3,component);

            ps.executeUpdate();
            ps.close();
            stmt.close();
            conn.close();

        } catch (Exception e) {
            //Handle errors for Class.forName
            result = "not-done";
            e.printStackTrace();
        } finally {
            //finally block used to close resources
            try {
                if (stmt != null)
                    stmt.close();
            } catch (SQLException se2) {
            }// nothing we can do
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }

        return result;
    }

}
