package org.wso2.internalapps.pqd.functionalcoverage;

public class Constants {

    public static final String GET_FUNCCOVERAGE_SNAPSHOT_ID="SELECT snapshot_id FROM functional_coverage_snapshot  " +
                                                            "ORDER BY snapshot_id DESC LIMIT 1";
    public static final String INSERT_FUNCCOVERAGE_SNAPSHOT_DETAILS="INSERT INTO functional_coverage_snapshot (date)" +
                                                                    " VALUES(?)";
    public static final String INSERT_DAILY_FUNCCOVERAGE_DETAILS="INSERT INTO daily_functional_coverage (snapshot_id," +
                    "date,project_name,test_plan_name,total_features,passed_features,failed_features,blocked_features," +
                    "not_run_features,functional_coverage) VALUES (?,?,?,?,?,?,?,?,?,?)";

}
