package org.wso2.internalapps.pqd.functionalcoverage;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.exceptions.jdbc4.MySQLIntegrityConstraintViolationException;

import java.io.IOException;
import java.sql.*;
import java.sql.DriverManager;

public final class MysqlConnect {
    public Connection conn;
    private static PreparedStatement preparedStatement;
    private static Statement statement;
    public static MysqlConnect db;
    private MysqlConnect() {
        ReaderYaml yamlreader=new ReaderYaml();
        try {
            Config config = yamlreader.readYaml();
            String url = config.getDbUrl();
            String dbName = config.getDbName();
            String driver = "com.mysql.jdbc.Driver";
            String userName = config.getDbUserName();
            String password = config.getDbPassword();
            try {
                Class.forName(driver).newInstance();
                this.conn = (Connection) DriverManager.getConnection(url + dbName, userName, password);
            } catch (Exception sqle) {
                sqle.printStackTrace();
            }
        }catch(IOException ioece){
            ioece.printStackTrace();
        }
    }

    public static synchronized MysqlConnect getDbCon() {
        if ( db == null ) {
            db = new MysqlConnect();
        }
        return db;

    }

    public static int getLastSnapshotId(String query) throws SQLException{
        statement = db.conn.createStatement();
        ResultSet res = statement.executeQuery(query);
        int snapshot_id=0;
        while (res.next()){
            snapshot_id=res.getInt("snapshot_id");
        }
        return snapshot_id;
    }

    public static int insertIntoSnapshotTable(String insertQuery,String date) throws SQLException {
        preparedStatement = db.conn.prepareStatement(insertQuery);
        preparedStatement.setString(1,date);
        int result=0;
        try {
            result = preparedStatement.executeUpdate();
        }catch (MySQLIntegrityConstraintViolationException ex){
            System.out.println(ex.getMessage());
        }
        return result;
    }

    public static int insertIntoDailyFunctionalCoverageTable(String insertQuery,int snapshot_id,String date,
                                                             String project_name,String test_plan_name, int total_fatures,
                                                             int passed_features, int failed_features,int blocked_features,
                                                             int not_run_features,float functional_coverage) throws SQLException {
        preparedStatement = db.conn.prepareStatement(insertQuery);
        preparedStatement.setInt(1,snapshot_id);
        preparedStatement.setString(2,date);
        preparedStatement.setString(3,project_name);
        preparedStatement.setString(4,test_plan_name);
        preparedStatement.setInt(5,total_fatures);
        preparedStatement.setInt(6,passed_features);
        preparedStatement.setInt(7,failed_features);
        preparedStatement.setInt(8,blocked_features);
        preparedStatement.setInt(9,not_run_features);
        preparedStatement.setFloat(10,functional_coverage);

        int result = preparedStatement.executeUpdate();
        return result;
    }

}
