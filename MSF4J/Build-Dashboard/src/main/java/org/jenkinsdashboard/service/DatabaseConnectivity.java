package org.jenkinsdashboard.service;

import java.io.IOException;
import java.sql.*;

public class DatabaseConnectivity {

    public String insertDBWithComponent(String productArea, String component){
        Connection conn = null;
        Statement stmt = null;

        //read config.yml file
        Configuration conf = new Configuration();
        ReaderYml read = new ReaderYml();
        try{
            conf = read.readYaml();
        }catch (IOException e){

        }

        String result = "done";
        try {
            Class.forName(conf.getJDBC_DRIVER());
            conn = DriverManager.getConnection(conf.getDB_URL(), conf.getUSER(), conf.getPASSWORD());

            stmt = conn.createStatement();
            String sql = "INSERT INTO JNKS_COMPONENTPRODUCT (Product, Component) VALUES (?, ?);";
            PreparedStatement ps = conn.prepareStatement(sql);

            // set the preparedstatement parameters
            ps.setString(1,productArea);
            ps.setString(2,component);

            ps.execute();
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
