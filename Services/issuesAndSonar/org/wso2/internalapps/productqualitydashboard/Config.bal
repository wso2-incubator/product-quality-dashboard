package org.wso2.internalapps.productqualitydashboard;

const string GET_AREA_DETAIL = "SELECT pqd_product_jira_id,pqd_product_jira_key, pqd_product_jira_name FROM pqd_product_jira";

const string CONFIG_PATH = "config.json";

const string API_VERSION = "v1.0";

const string GET_ALL_ISSUE_TYPE_DB_QUERY_VERSION2 = "SELECT pqd_issue_type_id, pqd_issue_type FROM pqd_issue_type";

const string GET_SEVERITY_DB_QUERY_VERSION2 = "SELECT pqd_severity_id, pqd_severity FROM pqd_severity";

const string PRODUCT_COMPONENT_REPO_TABLE_NAME = "pqd_product_component_repo_table";


const string GET_ALL_ISSUE_TYPE_COUNT = "SELECT a.pqd_jira_issue_type, SUM(a.pqd_issue_count) AS issue_type_level_issues " +
                                        "FROM pqd_jira_issues AS a JOIN pqd_product_areas AS c ON a.pqd_product_jira_id = c.pqd_product_jira_id WHERE pqd_component_jira_id = ? AND" +
                                        " pqd_product_jira_version = ?  AND c.pqd_area_name = ? " +
                                        "GROUP BY a.pqd_jira_issue_type";

const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_AREA_TESTING = "SELECT pqd_issue_type_id, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                        "FROM pqd_jira_issues_by_product WHERE " +
                                        "pqd_area_id = ? GROUP BY pqd_issue_type_id";
const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_AREA_FOR_SEVERITY_TESTING = "SELECT pqd_issue_type_id, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                        "FROM pqd_jira_issues_by_product WHERE pqd_area_id = ? AND pqd_severity_id = ? " +
                                        " GROUP BY pqd_issue_type_id";

const string GET_ALL_ISSUE_TYPE_COUNT_TEST = "SELECT pqd_jira_issue_type, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                        "FROM jira_issues WHERE pqd_component_jira_id = ? AND" +
                                        " pqd_product_jira_version = ? ";

const string GET_ALL_ISSUE_TYPE_COUNT_1 = "SELECT pqd_jira_issue_type, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                        "FROM pqd_jira_issues_by_product WHERE pqd_snapshot_id = ? " +
                                        "GROUP BY pqd_jira_issue_type";

const string GET_PRODUCT_DB_QUERY = "SELECT pqd_product_jira_id,pqd_product_jira_key, pqd_product_jira_name FROM pqd_product_jira";
const string GET_PRODUCT_DB_QUERY_VERSION2= "SELECT pqd_area_id,pqd_product_id, jira_project_id FROM pqd_product WHERE jira_project_id != 0";

const string GET_ISSUE_TYPE_DB_QUERY = "SELECT pqd_issue_type FROM pqd_jira_issue_type";
const string GET_ISSUE_TYPE_DB_QUERY_VERSION2 = "SELECT pqd_issue_type_id, pqd_issue_type FROM pqd_issue_type WHERE jira_issue_type IS NOT NULL";


const string GET_SEVERITY_DB_QUERY = "SELECT pqd_jira_severity FROM pqd_jira_severity";


const string GET_JIRA_PROJECTS_DB_QUERY = "SELECT * FROM pqd_jira_projects WHERE pqd_product_id = ?";

const string GET_JIRA_COMPONENTS_DB_QUERY = "SELECT * FROM pqd_jira_components WHERE pqd_jira_project_id = ?";

const string GET_COMPONENT_DB_QUERY = "SELECT * FROM pqd_component_repo where pqd_product_id = ?";

const string GET_PROJECT_VERSIONS = "SELECT pqd_product_jira_version FROM pqd_product_jira_version where pqd_product_jira_id = ?";
const string GET_PROJECT_VERSIONS_VERSION2 = "SELECT pqd_product_version_id, pqd_product_version FROM pqd_product_version where pqd_product_id = ?";

const string GET_PROJECT_COMPONENTS = "SELECT pqd_component_jira_id FROM pqd_component_jira where pqd_product_jira_id = ?";
const string GET_PROJECT_COMPONENTS_VERSION2 = "SELECT pqd_component_id, jira_component_id FROM pqd_component where pqd_product_id = ? AND jira_component_id != 0";

const string INSERT_SNAPSHOT_ID = "INSERT INTO pqd_jira_snapshot () VALUES ()";

const string INSERT_JIRA_ISSUES_OF_PRODUCT_LEVEL = "INSERT INTO jira_product_count (" +
                                                   "pqd_product_jira_id," +
                                                   "issue_count, " +
                                                   "pqd_snapshot_id) " +
                                                   "VALUES (?,?,?)";


const string INSERT_JIRA_ISSUES = "INSERT INTO pqd_jira_issues (" +
                                               "pqd_product_jira_id," +
                                                "pqd_component_jira_id, " +
                                                "pqd_product_jira_version," +
                                               "pqd_jira_issue_type," +
                                               "pqd_jira_severity, " +
                                               "pqd_issue_count," +
                                               "pqd_updated) " +
                                      "VALUES (?,?,?,?,?,?,?)";

const string DELETE_JIRA_ISSUES = "DELETE FROM pqd_jira_issues WHERE 1";
const string DELETE_JIRA_ISSUES_BY_PRODUCT = "DELETE FROM pqd_jira_issues_by_product WHERE 1";
const string DELETE_JIRA_ISSUES_BY_COMPONENT = "DELETE FROM pqd_jira_issues_by_component WHERE 1";
const string DELETE_JIRA_ISSUES_BY_VERSION = "DELETE FROM pqd_jira_issues_by_product_version WHERE 1";

const string INSERT_JIRA_ISSUES_HISTORY = "INSERT INTO pqd_jira_issues_history SELECT * FROM pqd_jira_issues";
const string INSERT_JIRA_ISSUES_HISTORY_BY_PRODUCT = "INSERT INTO pqd_jira_issues_history_by_product SELECT * FROM pqd_jira_issues_by_product";
const string INSERT_JIRA_ISSUES_HISTORY_BY_VERSION = "INSERT INTO pqd_jira_issues_history_by_version SELECT * FROM pqd_jira_issues_by_product_version";
const string INSERT_JIRA_ISSUES_HISTORY_BY_COMPONENT = "INSERT INTO pqd_jira_issues_history_by_component SELECT * FROM pqd_jira_issues_by_component";

const string INSERT_JIRA_ISSUES_VIEW = "CREATE OR REPLACE VIEW jira_issues AS SELECT pqd_product_jira_id," +
                                       "pqd_component_jira_id, " +
                                       "pqd_product_jira_version," +
                                       "pqd_jira_issue_type," +
                                       "pqd_jira_severity, " +
                                       "pqd_issue_count FROM pqd_jira_issues";

const string INSERT_JIRA_ISSUES_BY_PRODUCT = "INSERT INTO pqd_jira_issues_by_product (" +
                                                "pqd_area_id," +
                                                "pqd_product_id," +
                                                "pqd_issue_type_id," +
                                                "pqd_severity_id, " +
                                                "pqd_issue_count, pqd_updated) " +
                                             "VALUES (?,?,?,?,?,?)";

const string INSERT_JIRA_ISSUES_BY_COMPONENT = "INSERT INTO pqd_jira_issues_by_component (" +
                                               "pqd_product_id," +
                                               "pqd_component_id, " +
                                               "pqd_issue_type_id," +
                                               "pqd_severity_id, " +
                                               "pqd_issue_count, pqd_updated) " +
                                      "VALUES (?,?,?,?,?,?)";

const string INSERT_JIRA_ISSUES_BY_VERSION = "INSERT INTO pqd_jira_issues_by_product_version (" +
                                             "pqd_product_id," +
                                             "pqd_product_version_id," +
                                               "pqd_issue_type_id," +
                                               "pqd_severity_id, " +
                                               "pqd_issue_count, pqd_updated) " +
                                      "VALUES (?,?,?,?,?,?)";


const string GET_ISSUE_COUNT_BY_PRODUCT = "SELECT a.pqd_product_jira_id AS pqd_product_jira_id, b.pqd_product_jira_name AS pqd_product_jira_name, SUM(pqd_issue_count) " +
                                          "AS product_level_issues FROM pqd_jira_issues AS a JOIN pqd_product_jira AS b " +
                                          "ON a.pqd_product_jira_id = b.pqd_product_jira_id JOIN pqd_product_areas AS c ON a.pqd_product_jira_id = c.pqd_product_jira_id WHERE " +
                                          "pqd_component_jira_id = ? AND pqd_product_jira_version = ? AND c.pqd_area_name = ? GROUP BY pqd_product_jira_id";
const string GET_ISSUE_COUNT_BY_PRODUCT_FOR_AREA_TESTING = "SELECT pqd_product_id, SUM(pqd_issue_count) " +
                                          "AS product_level_issues FROM pqd_jira_issues_by_product " +
                                          "WHERE pqd_area_id = ? GROUP BY pqd_product_id";
const string GET_ISSUE_COUNT_BY_PRODUCT_OF_AREA_FOR_ISSUE_TYPE_TESTING = "SELECT pqd_product_id, SUM(pqd_issue_count) " +
                                          "AS product_level_issues FROM pqd_jira_issues_by_product " +
                                          "WHERE pqd_area_id = ? AND pqd_issue_type_id = ? GROUP BY pqd_product_id";
const string GET_ISSUE_COUNT_BY_PRODUCT_OF_AREA_FOR_SEVERITY_TESTING = "SELECT pqd_product_id, SUM(pqd_issue_count) " +
                                          "AS product_level_issues FROM pqd_jira_issues_by_product " +
                                          "WHERE pqd_area_id = ? AND pqd_severity_id = ? GROUP BY pqd_product_id";
const string GET_ISSUE_COUNT_BY_PRODUCT_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING = "SELECT pqd_product_id, SUM(pqd_issue_count) " +
                                          "AS product_level_issues FROM pqd_jira_issues_by_product " +
                                          "WHERE pqd_area_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_product_id";


const string GET_ISSUE_HISTORY_FOR_AREA =  "SELECT SUM(pqd_issue_count) AS issues, a.pqd_updated FROM pqd_jira_issues_history " +
                                           "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                           "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                           "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                           "GROUP BY a.pqd_updated";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_TESTING =  "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                           "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_issue_type_id = ?  " +
                                           "GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING =  "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                           "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ?  " +
                                           "GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_SEVERITY_TESTING =  "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                           "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_severity_id = ?  " +
                                           "GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_AREA =
                                    "SELECT SUM(pqd_issue_count) AS issues, a.pqd_updated FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? GROUP BY a.pqd_updated";


const string GET_ISSUE_HISTORY_OF_SEVERITY_FOR_AREA =
                                    "SELECT SUM(pqd_issue_count) AS issues, a.pqd_updated FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_severity = ? GROUP BY a.pqd_updated";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_AREA =
                                    "SELECT SUM(pqd_issue_count) AS issues, a.pqd_updated FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY a.pqd_updated";

const string GET_ISSUE_HISTORY_FOR_AREA_BY_YEAR =
                                    "SELECT SUM(pqd_issue_count) AS issues, year (a.pqd_updated) AS year FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "GROUP BY year";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_AREA_BY_YEAR =
                                    "SELECT SUM(pqd_issue_count) AS issues, year (a.pqd_updated) AS year FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? GROUP BY year";
const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_OF_AREA_FOR_ISSUE_TYPE_BY_YEAR_TESTING =
                                    "SELECT SUM(t.issues) AS issues, year (t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_issue_type_id = ?  " +
                                    "GROUP BY pqd_updated) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING =
                                    "SELECT SUM(t.issues) AS issues, year (t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ?  " +
                                    "GROUP BY pqd_updated) as t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_OF_AREA_FOR_SEVERITY_BY_YEAR_TESTING =
                                    "SELECT SUM(t.issues) AS issues, year (t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_severity_id = ?  " +
                                    "GROUP BY pqd_updated) t GROUP BY year";


const string GET_ISSUE_HISTORY_OF_SEVERITY_FOR_AREA_BY_YEAR =
                                    "SELECT SUM(pqd_issue_count) AS issues, year (a.pqd_updated) AS year FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_severity = ? GROUP BY year";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_AREA_BY_YEAR =
                                    "SELECT SUM(pqd_issue_count) AS issues, year (a.pqd_updated) AS year FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year";

const string GET_ISSUE_HISTORY_FOR_AREA_BY_MONTH =
                                    "SELECT SUM(pqd_issue_count) AS issues, year(a.pqd_updated) AS year, month(a.pqd_updated)" +
                                    " AS month FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "GROUP BY year, month";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_AREA_BY_MONTH =
                                    "SELECT SUM(pqd_issue_count) AS issues, ? (a.pqd_updated) AS year, month(a.pqd_updated)" +
                                    " AS month FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_BY_MONTH_TESTING =
                                    "SELECT SUM(t.issues) AS issues, ? (t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_issue_type_id = ?  " +
                                    "GROUP BY pqd_updated) t GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING =
                                    "SELECT SUM(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ?  " +
                                    "GROUP BY pqd_updated) as t  GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_SEVERITY_BY_MONTH_TESTING =
                                    "SELECT SUM(t.issues) AS issues, ? (t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_severity_id = ?  " +
                                    "GROUP BY pqd_updated) t GROUP BY year, month";


const string GET_ISSUE_HISTORY_OF_SEVERITY_FOR_AREA_BY_MONTH =
                                    "SELECT SUM(pqd_issue_count) AS issues, ? (a.pqd_updated) AS year, month(a.pqd_updated)" +
                                    " AS month FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_severity = ? GROUP BY year, month";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_AREA_BY_MONTH =
                                    "SELECT SUM(pqd_issue_count) AS issues, ? (a.pqd_updated) AS year, month(a.pqd_updated)" +
                                    " AS month FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year, month";


const string GET_ISSUE_HISTORY_FOR_AREA_BY_QUARTER =
                                    "SELECT SUM(pqd_issue_count) AS issues, year(a.pqd_updated) AS year, quarter(a.pqd_updated)" +
                                    " AS quarter FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "GROUP BY year, quarter";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_AREA_BY_QUARTER =
                                    "SELECT SUM(pqd_issue_count) AS issues, year(a.pqd_updated) AS year, quarter(a.pqd_updated)" +
                                    " AS quarter FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_issue_type_id = ?  " +
                                    "GROUP BY pqd_updated) t  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TESTING =
                                    "SELECT SUM(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ?  " +
                                    "GROUP BY pqd_updated) as t  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_AREA_FOR_SEVERITY_BY_QUARTER_TESTING =
                                    "SELECT SUM(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_area_id = ? AND pqd_severity_id = ?  " +
                                    "GROUP BY pqd_updated) t GROUP BY year, quarter";


const string GET_ISSUE_HISTORY_OF_SEVERITY_FOR_AREA_BY_QUARTER =
                                    "SELECT SUM(pqd_issue_count) AS issues, ? (a.pqd_updated) AS year, quarter(a.pqd_updated)" +
                                    " AS quarter FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_severity = ? GROUP BY year, quarter";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_AREA_BY_QUARTER =
                                    "SELECT SUM(pqd_issue_count) AS issues, ? (a.pqd_updated) AS year, quarter(a.pqd_updated)" +
                                    " AS quarter FROM pqd_jira_issues_history " +
                                    "AS a JOIN pqd_product_areas AS b ON a.pqd_product_jira_id = b.pqd_product_jira_id " +
                                    "WHERE a.pqd_updated BETWEEN ? AND ? AND b.pqd_area_name = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year, quarter";


const string GET_ISSUE_HISTORY =  "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history " +
                                           "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                           "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                           "GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_SEVERITY_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND  pqd_severity_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_SEVERITY_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_severity_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_SEVERITY_TESTING =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_severity_id = ? GROUP BY pqd_updated";


const string GET_ISSUE_HISTORY_OF_SEVERITY =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_severity = ? GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY =
                                    "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_BY_YEAR =
                                    "SELECT SUM(pqd_issue_count) AS issues, year(pqd_updated) AS year FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "GROUP BY year";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_BY_YEAR =
                                    "SELECT SUM(pqd_issue_count) AS issues, year(pqd_updated) AS year FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? GROUP BY year";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_update) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM pqd_jira_issues_history_by_product " +
                                    "WHERE (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_SEVERITY_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_SEVERITY_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_SEVERITY_BY_YEAR_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND  pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year";


const string GET_ISSUE_HISTORY_OF_SEVERITY_BY_YEAR =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_severity = ? GROUP BY year";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_BY_YEAR =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year";

const string GET_ISSUE_HISTORY_BY_MONTH =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, month(pqd_updated)" +
                                    " AS month FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "GROUP BY year, month";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_BY_MONTH =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, month(pqd_updated)" +
                                    " AS month FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated) t GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_update) t  GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated) t GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_SEVERITY_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_SEVERITY_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year, month";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_SEVERITY_BY_MONTH_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated)" +
                                    " AS month FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND  pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, month";


const string GET_ISSUE_HISTORY_OF_SEVERITY_BY_MONTH =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, month(pqd_updated)" +
                                    " AS month FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_severity = ? GROUP BY year, month";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_BY_MONTH =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, month(pqd_updated)" +
                                    " AS month FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year, month";


const string GET_ISSUE_HISTORY_BY_QUARTER =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, quarter(pqd_updated)" +
                                    " AS quarter FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "GROUP BY year, quarter";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_BY_QUARTER =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, quarter(pqd_updated)" +
                                    " AS quarter FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated) t GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_update) t  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND pqd_issue_type_id = ? GROUP BY pqd_updated) t GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_PRODUCT_FOR_SEVERITY_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_id = ? AND " +
                                    "AND pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_VERSION_FOR_SEVERITY_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_version " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_version_id = ? " +
                                    "AND pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_COMPONENT_FOR_SEVERITY_BY_QUARTER_TESTING =
                                    "SELECT AVG(t.issues) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated)" +
                                    " AS quarter FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_component " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_id = ? " +
                                    "AND  pqd_severity_id = ? GROUP BY pqd_updated) t  GROUP BY year, quarter";


const string GET_ISSUE_HISTORY_OF_SEVERITY_BY_QUARTER =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, quarter(pqd_updated)" +
                                    " AS quarter FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_severity = ? GROUP BY year, quarter";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER =
                                    "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, quarter(pqd_updated)" +
                                    " AS quarter FROM pqd_jira_issues_history " +
                                    "WHERE pqd_updated BETWEEN ? AND ? AND pqd_product_jira_id = ? AND " +
                                    "pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                    "AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year, quarter";



const string GET_ISSUE_HISTORY_FOR_ALL =
                                "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_TESTING =
                                "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_issue_type_id = ? GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING =
                                "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_SEVERITY_TESTING =
                                "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_severity_id = ? GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_OF_ISSUE_FOR_ALL =
                                "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_issue_type = ? GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_OF_SEVERITY_FOR_ALL =
                                "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_severity = ? GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_ALL =
                                "SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY pqd_updated";

const string GET_ISSUE_HISTORY_FOR_ALL_BY_YEAR =
                                "SELECT SUM(pqd_issue_count) AS issues, year(pqd_updated) AS year FROM pqd_jira_issues_history " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? GROUP BY year";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_BY_YEAR_TESTING =
                                "SELECT AVG(table1.issues) AS issues, year(table1.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_issue_type_id = ? GROUP BY pqd_updated) table1 GROUP BY year";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING =
                                "SELECT AVG(table1.issues) AS issues, year(table1.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) table1 GROUP BY year";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_SEVERITY_BY_YEAR_TESTING =
                                "SELECT AVG(t.pqd_issue_count) AS issues, year(t.pqd_updated) AS year FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_ALL_BY_YEAR =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year FROM pqd_jira_issues_history " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_issue_type = ? GROUP BY year";

const string GET_ISSUE_HISTORY_OF_SEVERITY_FOR_ALL_BY_YEAR =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year FROM pqd_jira_issues_history " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_severity = ? GROUP BY year";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_ALL_BY_YEAR =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year FROM pqd_jira_issues_history " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year";

const string GET_ISSUE_HISTORY_FOR_ALL_BY_MONTH =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, month(pqd_updated) AS month" +
                                " FROM pqd_jira_issues_history WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? GROUP BY year, month";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_ALL_BY_MONTH =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, month(pqd_updated) AS month" +
                                " FROM pqd_jira_issues_history WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_issue_type = ? GROUP BY year,month";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_BY_MONTH_TESTING =
                                "SELECT AVG(table1.issues) AS issues, year(table1.pqd_updated) AS year, month(table1.pqd_updated) AS month" +
                                " FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_issue_type_id = ? GROUP BY pqd_updated) table1 GROUP BY year,month";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING =
                                "SELECT AVG(table1.issues) AS issues, year(table1.pqd_updated) AS year, month(table1.pqd_updated) AS month" +
                                " (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) table1  GROUP BY year,month";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_SEVERITY_BY_MONTH_TESTING =
                                "SELECT AVG(t.pqd_issue_count) AS issues, year(t.pqd_updated) AS year, month(t.pqd_updated) AS month" +
                                " FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year,month";

const string GET_ISSUE_HISTORY_OF_SEVERITY_FOR_ALL_BY_MONTH =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, month(pqd_updated) AS month" +
                                " FROM pqd_jira_issues_history WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_severity = ? GROUP BY year, month";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_ALL_BY_MONTH =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, month(pqd_updated) AS month" +
                                " FROM pqd_jira_issues_history WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year, month";

const string GET_ISSUE_HISTORY_FOR_ALL_BY_QUARTER =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, quarter(pqd_updated) AS quarter " +
                                " FROM pqd_jira_issues_history WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? GROUP BY year, quarter";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_ALL_BY_QUARTER =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, quarter(pqd_updated) AS quarter" +
                                " FROM pqd_jira_issues_history WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_issue_type = ? GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_BY_QUARTER_TETSING =
                                "SELECT AVG(table1.issues) AS issues, year(table1.pqd_updated) AS year, quarter(table1.pqd_updated) AS quarter" +
                                " FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_issue_type_id = ? GROUP BY pqd_updated) table1 GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TETSING =
                                "SELECT AVG(table1.issues) AS issues, year(table1.pqd_updated) AS year, quarter(table1.pqd_updated) AS quarter" +
                                " FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? GROUP BY pqd_updated) table1  GROUP BY year, quarter";
const string GET_ISSUE_HISTORY_OF_ALL_FOR_SEVERITY_BY_QUARTER_TETSING =
                                "SELECT AVG(t.pqd_issue_count) AS issues, year(t.pqd_updated) AS year, quarter(t.pqd_updated) AS quarter" +
                                " FROM (SELECT SUM(pqd_issue_count) AS issues, pqd_updated FROM pqd_jira_issues_history_by_product " +
                                "WHERE pqd_updated BETWEEN ? AND ? AND pqd_severity_id = ? GROUP BY pqd_updated) t GROUP BY year, quarter";

const string GET_ISSUE_HISTORY_OF_SEVERITY_FOR_ALL_BY_QUARTER =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, quarter(pqd_updated) AS quarter" +
                                " FROM pqd_jira_issues_history WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_severity = ? GROUP BY year, quarter";

const string GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_ALL_BY_QUARTER =
                                "SELECT AVG(pqd_issue_count) AS issues, year(pqd_updated) AS year, quarter(pqd_updated) AS quarter" +
                                " FROM pqd_jira_issues_history WHERE pqd_updated BETWEEN ? AND ? AND pqd_component_jira_id = ? AND " +
                                "pqd_product_jira_version = ? AND pqd_jira_issue_type = ? AND pqd_jira_severity = ? GROUP BY year, quarter";


const string GET_ISSUE_COUNT_BY_COMPONENT = "SELECT b.pqd_component_jira_id, b.pqd_component_jira_name," +
                                          " SUM(pqd_issue_count) AS component_level_issues FROM pqd_jira_issues AS a " +
                                          "RIGHT JOIN pqd_component_jira AS b ON a.pqd_component_jira_id = b.pqd_component_jira_id " +
                                          "WHERE a.pqd_component_jira_id != ? AND pqd_product_jira_version = ? " +
                                          "AND a.pqd_product_jira_id = ? GROUP BY a.pqd_component_jira_id";
const string GET_ISSUE_COUNT_BY_COMPONENT_FOR_PRODUCT_TESTING = "SELECT pqd_component_id, SUM(pqd_issue_count) AS component_level_issues FROM pqd_jira_issues_by_component " +
                                          "WHERE pqd_product_id = ? GROUP BY pqd_component_id";
const string GET_ISSUE_COUNT_BY_COMPONENT_OF_PRODUCT_FOR_ISSUE_TYPE_TESTING = "SELECT pqd_component_id, SUM(pqd_issue_count) AS component_level_issues FROM pqd_jira_issues_by_component " +
                                          "WHERE pqd_product_id = ? AND pqd_issue_type_id = ? ROUP BY pqd_component_id";
const string GET_ISSUE_COUNT_BY_COMPONENT_OF_PRODUCT_FOR_SEVERITY_TESTING = "SELECT pqd_component_id, SUM(pqd_issue_count) AS component_level_issues FROM pqd_jira_issues_by_component " +
                                          "WHERE pqd_product_id = ? AND pqd_severity_id = ? ROUP BY pqd_component_id";
const string GET_ISSUE_COUNT_BY_COMPONENT_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING = "SELECT pqd_component_id, SUM(pqd_issue_count) AS component_level_issues FROM pqd_jira_issues_by_component " +
                                          "WHERE pqd_product_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? ROUP BY pqd_component_id";

const string GET_ISSUE_COUNT_OF_COMPONENT_BY_ISSUE_TYPE = "SELECT b.pqd_component_jira_id, b.pqd_component_jira_name," +
                                          " SUM(pqd_issue_count) AS component_level_issues FROM pqd_jira_issues AS a " +
                                          "RIGHT JOIN pqd_component_jira AS b ON a.pqd_component_jira_id = b.pqd_component_jira_id " +
                                          "WHERE a.pqd_product_jira_id = ? AND a.pqd_component_jira_id != ? AND pqd_product_jira_version = ? " +
                                          "AND pqd_jira_issue_type GROUP BY a.pqd_component_jira_id";


const string GET_ISSUE_COUNT_BY_ISSUE_TYPE = "SELECT pqd_jira_issue_type, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                            "FROM pqd_jira_issues WHERE pqd_component_jira_id = ? AND" +
                                            " pqd_product_jira_version = ? AND pqd_product_jira_id = ? " +
                                            "GROUP BY pqd_jira_issue_type";
const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_PRODUCT_TESTING = "SELECT pqd_issue_type_id, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                            "FROM pqd_jira_issues_by_product WHERE pqd_product_id = ? " +
                                            "GROUP BY pqd_issue_type_id";
const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_PRODUCT_FOR_SEVERITY_TESTING = "SELECT pqd_issue_type_id, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                            "FROM pqd_jira_issues_by_product WHERE pqd_product_id = ? AND pqd_severity_id = ? " +
                                            "GROUP BY pqd_issue_type_id";
const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_COMPONENT_TESTING = "SELECT pqd_issue_type_id, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                             "FROM pqd_jira_issues_by_component WHERE pqd_component_jira_id = ? " +
                                             "GROUP BY pqd_issue_type_id";


const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_AREA = "SELECT pqd_jira_issue_type, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                                      "FROM pqd_jira_issues " +
                                                      "WHERE pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                                      "GROUP BY pqd_jira_issue_type";
const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_ALL_TESTING =
                                        "SELECT pqd_issue_type_id, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                        "FROM pqd_jira_issues_by_product GROUP BY pqd_issue_type_id";
const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_ALL_FOR_SEVERIRY_TESTING =
                                        "SELECT pqd_issue_type_id, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                        "FROM pqd_jira_issues_by_product WHERE pqd_severity_id = ? GROUP BY pqd_issue_type_id";

const string GET_ISSUE_COUNT_BY_SEVERITY_OF_PRODUCT_FOR_AREA = "SELECT pqd_jira_severity, SUM(pqd_issue_count) AS severity_level_issues" +
                                                               " FROM pqd_jira_issues WHERE " +
                                                               " pqd_component_jira_id = ? AND pqd_product_jira_version = ? " +
                                                               " GROUP BY pqd_jira_severity";
const string GET_ISSUE_COUNT_BY_SEVERITY_FOR_ALL_TESTING = "SELECT pqd_severity_id, SUM(pqd_issue_count) AS severity_level_issues" +
                                                            " FROM pqd_jira_issues_by_product GROUP BY pqd_severity_id";
const string GET_ISSUE_COUNT_BY_SEVERITY_OF_ALL_FOR_ISSUE_TYPE_TESTING =
                                                "SELECT pqd_severity_id, SUM(pqd_issue_count) AS severity_level_issues" +
                                                " FROM pqd_jira_issues_by_product WHERE pqd_issue_type_id = ? GROUP BY pqd_severity_id";


const string GET_ISSUE_COUNT_BY_SEVERITY = "SELECT a.pqd_jira_severity, SUM(a.pqd_issue_count) AS severity_level_issues" +
                                            " FROM pqd_jira_issues AS a JOIN pqd_product_areas AS c ON a.pqd_product_jira_id = c.pqd_product_jira_id WHERE a.pqd_component_jira_id = ? AND " +
                                            "a.pqd_product_jira_version = ? AND c.pqd_area_name = ? " +
                                            " GROUP BY a.pqd_jira_severity";
const string GET_ISSUE_COUNT_BY_SEVERITY_FOR_AREA_TESTING = "SELECT pqd_severity_id, SUM(pqd_issue_count) AS severity_level_issues" +
                                            " FROM pqd_jira_issues_by_product WHERE pqd_area_id = ? " +
                                            " GROUP BY pqd_severity_id";
const string GET_ISSUE_COUNT_BY_SEVERITY_OF_AREA_FOR_SEVERITY_TESTING = "SELECT pqd_severity_id, SUM(pqd_issue_count) AS severity_level_issues" +
                                            " FROM pqd_jira_issues_by_product WHERE pqd_area_id = ? AND pqd_severity_id = ?" +
                                            " GROUP BY pqd_severity_id";


const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_SEVERITY = "SELECT a.pqd_jira_issue_type, SUM(a.pqd_issue_count) AS issue_type_level_issues " +
                                                         "FROM pqd_jira_issues AS a JOIN pqd_product_areas AS c ON a.pqd_product_jira_id = c.pqd_product_jira_id" +
                                                         " WHERE a.pqd_component_jira_id = ? AND" +
                                                         " a.pqd_product_jira_version = ? AND a.pqd_jira_severity = ?  AND c.pqd_area_name = ? " +
                                                         "GROUP BY a.pqd_jira_issue_type";

const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_SEVERITY_OF_PRODUCT = "SELECT pqd_jira_issue_type, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                                         "FROM pqd_jira_issues WHERE pqd_product_jira_id = ? AND pqd_component_jira_id = ? AND" +
                                                         " pqd_product_jira_version = ? AND pqd_jira_severity = ? " +
                                                         "GROUP BY pqd_jira_issue_type";

const string GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_SEVERITY_OF_PRODUCT_FOR_AREA = "SELECT pqd_jira_issue_type, SUM(pqd_issue_count) AS issue_type_level_issues " +
                                                         "FROM pqd_jira_issues WHERE pqd_component_jira_id = ? AND" +
                                                         " pqd_product_jira_version = ? AND pqd_jira_severity = ? " +
                                                         "GROUP BY pqd_jira_issue_type";

const string GET_ISSUE_COUNT_OF_VERSION_BY_PRODUCT = "SELECT pqd_product_jira_version, SUM(pqd_issue_count) AS version_level_issues " +
                                             "FROM pqd_jira_issues WHERE pqd_product_jira_id = ? AND pqd_component_jira_id = ? AND " +
                                             " pqd_product_jira_version != ?  " +
                                             "GROUP BY pqd_product_jira_version";

const string GET_ISSUE_COUNT_FOR_AREA = "SELECT c.pqd_area_name, SUM(pqd_issue_count) AS area_level_issues, a.pqd_product_jira_id " +
                                        "FROM pqd_jira_issues AS a JOIN pqd_product_areas AS c ON a.pqd_product_jira_id = c.pqd_product_jira_id" +
                                        " WHERE pqd_component_jira_id = ? AND pqd_product_jira_version = ?  " +
                                        "GROUP BY c.pqd_area_name";
const string GET_ISSUE_COUNT_FOR_AREA_TESTING = "SELECT pqd_area_id, SUM(pqd_issue_count) AS area_level_issues " +
                                        "FROM pqd_jira_issues_by_product " +
                                        "GROUP BY pqd_area_id";
const string GET_ISSUE_COUNT_OF_AREA_FOR_ISSUE_TYPE_TESTING = "SELECT pqd_area_id, SUM(pqd_issue_count) AS area_level_issues " +
                                        "FROM pqd_jira_issues_by_product WHERE pqd_issue_type_id = ? " +
                                        "GROUP BY pqd_area_id";
const string GET_ISSUE_COUNT_OF_AREA_FOR_SEVERITY_TESTING = "SELECT pqd_area_id, SUM(pqd_issue_count) AS area_level_issues " +
                                        "FROM pqd_jira_issues_by_product WHERE pqd_severity_id = ? " +
                                        "GROUP BY pqd_area_id";
const string GET_ISSUE_COUNT_OF_AREA_FOR_BOTH_ISSUE_TYPE_AND_SEVERITY_TESTING = "SELECT pqd_area_id, SUM(pqd_issue_count) AS area_level_issues " +
                                        "FROM pqd_jira_issues_by_product WHERE pqd_issue_type_id = ? AND pqd_severity_id = ? " +
                                        "GROUP BY pqd_area_id";

const string GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE = "SELECT pqd_jira_severity, SUM(pqd_issue_count) AS severity_level_issues" +
                                                         " FROM pqd_jira_issues WHERE pqd_component_jira_id = ? AND " +
                                                         "pqd_product_jira_version = ? AND " +
                                                         "pqd_jira_issue_type = ? AND pqd_product_jira_id = ? GROUP BY pqd_jira_severity";

const string GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE_FOR_AREA = "SELECT pqd_jira_severity, SUM(pqd_issue_count) AS severity_level_issues" +
                                                                " FROM pqd_jira_issues WHERE pqd_component_jira_id = ? AND " +
                                                                "pqd_product_jira_version = ? AND " +
                                                                "pqd_jira_issue_type = ? GROUP BY pqd_jira_severity";

const string GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE2 = "SELECT pqd_jira_issue_type, SUM(pqd_issue_count) AS issue_type_level_issues" +
                                                         " FROM pqd_jira_issues WHERE pqd_component_jira_id = ? AND " +
                                                         "pqd_product_jira_version = ? AND " +
                                                         "pqd_jira_severity = ? GROUP BY pqd_jira_issue_type";


const string GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE_FOR_ALL_PRODUCTS = "SELECT a.pqd_jira_severity, SUM(a.pqd_issue_count) AS severity_level_issues" +
                                                         " FROM pqd_jira_issues AS a JOIN pqd_product_areas AS c ON a.pqd_product_jira_id = c.pqd_product_jira_id WHERE a.pqd_component_jira_id = ? AND " +
                                                         "a.pqd_product_jira_version = ? AND " +
                                                         "a.pqd_jira_issue_type = ? AND c.pqd_area_name = ? GROUP BY a.pqd_jira_severity";

const string GET_ISSUE_COUNT_BY_SEVERITY_OF_COMPONENT = "SELECT pqd_jira_severity, SUM(pqd_issue_count) AS severity_level_issues" +
                                                        " FROM pqd_jira_issues WHERE pqd_component_jira_id = ? AND " +
                                                        "pqd_product_jira_version = ? " +
                                                        " GROUP BY pqd_jira_severity";
const string GET_ISSUE_COUNT_BY_SEVERITY_FOR_COMPONENT_TESTING = "SELECT pqd_severity_id, SUM(pqd_issue_count) AS severity_level_issues" +
                                                        " FROM pqd_jira_issues_by_component WHERE pqd_component_jira_id = ? " +
                                                        " GROUP BY pqd_severity_id";

const string GET_ISSUE_COUNT_BY_SEVERITY_OF_PRODUCT = "SELECT pqd_jira_severity, SUM(pqd_issue_count) AS severity_level_issues" +
                                                        " FROM pqd_jira_issues WHERE pqd_product_jira_id = ? AND " +
                                                        "pqd_product_jira_version = ? AND pqd_component_jira_id = ?" +
                                                        " GROUP BY pqd_jira_severity";
const string GET_ISSUE_COUNT_BY_SEVERITY_FOR_PRODUCT_TESTING = "SELECT pqd_severity_id, SUM(pqd_issue_count) AS severity_level_issues" +
                                                        " FROM pqd_jira_issues_by_product WHERE pqd_product_id = ? GROUP BY pqd_severity_id";
const string GET_ISSUE_COUNT_BY_SEVERITY_OF_PRODUCT_FOR_ISSUE_TYPE_TESTING = "SELECT pqd_severity_id, SUM(pqd_issue_count) AS severity_level_issues" +
                                                        " FROM pqd_jira_issues_by_product WHERE pqd_product_id = ? AND pqd_issue_type_id = ? GROUP BY pqd_severity_id";


const string GET_PRODUCTS_NAMES = "SELECT pqd_product_jira_id, pqd_product_jira_name FROM pqd_product_jira";

const string GET_MAPPING = "SELECT pqd_component_jira_id AS id, "+
                           "pqd_component_jira_name AS name FROM pqd_component_jira  "+
                           "WHERE pqd_product_jira_id = ?";

const string GET_MAPPING_VERSION = "SELECT pqd_product_jira_version AS id "+
                           " FROM pqd_product_jira_version  "+
                           "WHERE pqd_product_jira_id = ?";




const string INSERT_SNAPSHOT_DETAILS="INSERT INTO sonar_issues_date_table (date) VALUES (?)";

const string GET_SNAPSHOT_ID="SELECT snapshot_id FROM sonar_issues_date_table  ORDER BY snapshot_id DESC LIMIT 1";

const string INSERT_SONAR_ISSUES="INSERT INTO sonar_issues_table(snapshot_id,date,project_key,BLOCKER_BUG,CRITICAL_BUG,MAJOR_BUG,"+
                                 "MINOR_BUG,INFO_BUG,BLOCKER_CODE_SMELL,CRITICAL_CODE_SMELL,MAJOR_CODE_SMELL,MINOR_CODE_SMELL,"+
                                 "INFO_CODE_SMELL,BLOCKER_VULNERABILITY,CRITICAL_VULNERABILITY,MAJOR_VULNERABILITY,MINOR_VULNERABILITY,"+
                                 "INFO_VULNERABILITY,total) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

const string GET_ALL_AREAS="SELECT * FROM pqd_area";

const string GET_PRODUCTS_OF_AREA="SELECT pqd_product_id,pqd_product_name FROM pqd_product WHERE pqd_area_id=?";

const string GET_ALL_OF_SONAR_ISSUES= "SELECT * FROM sonar_issues_table WHERE project_key=? and snapshot_id=?";

const string GET_COMPONENT_OF_AREA="SELECT pqd_component_id,pqd_component_name,pqd_product_id,sonar_project_key FROM pqd_component" +
                                   " WHERE pqd_area_id=?";

const string GET_COMPONENT_OF_PRODUCT="SELECT pqd_component_id,pqd_component_name,pqd_product_id,sonar_project_key FROM pqd_component" +
                                      " WHERE pqd_product_id=?";

const string GET_DETAILS_OF_COMPONENT = "SELECT pqd_component_id,pqd_component_name,pqd_product_id,sonar_project_key FROM pqd_component " +
                                        "WHERE pqd_component_id=?";

const string GET_DAILY_HISTORY_FOR_ALL_AREA = "SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                              "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                              "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                              "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL," +
                                              "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                              "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY," +
                                              "SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY,SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY," +
                                              "SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY,SUM(total) as total " +
                                              "FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                              "ON a.project_key=b.sonar_project_key where date between ? and ? group by date";

const string GET_MONTHLY_HISTORY_FOR_ALL_AREA="SELECT year(date) as year,month(date) as month,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                              "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG,AVG(MINOR_BUG) as MINOR_BUG," +
                                              "AVG(INFO_BUG) as INFO_BUG,AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL," +
                                              "AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL,AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL," +
                                              "AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL," +
                                              "AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                              "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY," +
                                              "AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                              "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, " +
                                              "AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY,AVG(total) as total " +
                                              "FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                              "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                              "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                              "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL," +
                                              "SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY,SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY," +
                                              "SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY,SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY," +
                                              " SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY,SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                              "ON a.project_key=b.sonar_project_key where date between ? and ? group by date)AS T group by year,month";

const string GET_QUARTERLY_HISTORY_FOR_ALL_AREA="SELECT year(date) as year,quarter(date) as quarter,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG,AVG(MINOR_BUG) as MINOR_BUG," +
                                                "AVG(INFO_BUG) as INFO_BUG,AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL," +
                                                "AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL,AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL," +
                                                "AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL," +
                                                "AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY," +
                                                "AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, " +
                                                "AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY,AVG(total) as total " +
                                                "FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL," +
                                                "SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY,SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY," +
                                                "SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY,SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY," +
                                                " SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY,SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                "ON a.project_key=b.sonar_project_key where date between ? and ? group by date)AS T group by year,quarter";

const string GET_YEARLY_HISTORY_FOR_ALL_AREA="SELECT year(date) as year,AVG(BLOCKER_BUG) as BLOCKER_BUG,AVG(CRITICAL_BUG) as CRITICAL_BUG," +
                                             "AVG(MAJOR_BUG) as MAJOR_BUG,AVG(MINOR_BUG) as MINOR_BUG,AVG(INFO_BUG) as INFO_BUG," +
                                             "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                             "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL," +
                                             "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                             "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY," +
                                             "AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                             "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, " +
                                             "AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY,AVG(total) as total " +
                                             "FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                             "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                             "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                             "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL," +
                                             "SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY,SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY," +
                                             "SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY,SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY," +
                                             " SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY,SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                             "ON a.project_key=b.sonar_project_key where date between ? and ? group by date)AS T group by year";

const string GET_DAILY_HISTORY_FOR_SELECTED_AREA = "SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                   "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                   "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                   "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL," +
                                                   " SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                   "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                   "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                   "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                   "ON a.project_key=b.sonar_project_key where pqd_area_id=? and date between ? and ? group by date";

const string GET_MONTHLY_HISTORY_FOR_SELECTED_AREA = "SELECT year(date) as year,month(date) as month,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                     "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                     "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                     "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                     "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                     "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                     "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                     "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                     "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                     "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                     "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                     "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                     "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                     "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                     "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                     "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                     "ON a.project_key=b.sonar_project_key where pqd_area_id=? and date between ? and ? group by date)" +
                                                     "AS T group by year,month";

const string GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA = "SELECT year(date) as year,quarter(date) as quarter,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                       "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                       "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                       "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                       "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                       "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                       "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                       "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                       "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                       "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                       "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                       "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                       "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                       "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                       "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                       "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                       "ON a.project_key=b.sonar_project_key where pqd_area_id=? and date between ? and ? group by date)" +
                                                       "AS T group by year,quarter";

const string GET_YEARLY_HISTORY_FOR_SELECTED_AREA = "SELECT year(date) as year,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                    "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                    "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                    "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                    "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                    "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                    "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                    "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                    "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                    "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                    "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                    "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                    "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                    "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                    "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                    "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                    "ON a.project_key=b.sonar_project_key where pqd_area_id=? and date between ? and ? group by date)" +
                                                    "AS T group by year";

const string GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT = "SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                      "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                      "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                      "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL," +
                                                      " SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                      "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                      "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                      "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                      "ON a.project_key=b.sonar_project_key where pqd_product_id=? and date between ? and ? group by date";

const string GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT = "SELECT year(date) as year,month(date) as month,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                        "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                        "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                        "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                        "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                        "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                        "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                        "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                        "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                        "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                        "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                        "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                        "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                        "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                        "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                        "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                        "ON a.project_key=b.sonar_project_key where pqd_product_id=? and date between ? and ? group by date)" +
                                                        "AS T group by year,month";

const string GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT = "SELECT year(date) as year,quarter(date) as quarter,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                          "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                          "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                          "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                          "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                          "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                          "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                          "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                          "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                          "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                          "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                          "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                          "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                          "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                          "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                          "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                          "ON a.project_key=b.sonar_project_key where pqd_product_id=? and date between ? and ? group by date)" +
                                                          "AS T group by year,quarter";

const string GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT = "SELECT year(date) as year,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                       "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                       "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                       "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                       "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                       "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                       "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                       "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                       "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                       "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                       "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                       "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                       "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                       "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                       "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                       "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                       "ON a.project_key=b.sonar_project_key where pqd_product_id=? and date between ? and ? group by date)" +
                                                       "AS T group by year";

const string GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT = "SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                        "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                        "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                        "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL," +
                                                        " SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                        "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                        "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                        "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                        "ON a.project_key=b.sonar_project_key where pqd_component_id=? and date between ? and ? group by date";

const string GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT = "SELECT year(date) as year,month(date) as month,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                          "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                          "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                          "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                          "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                          "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                          "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                          "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                          "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                          "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                          "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                          "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                          "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                          "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                          "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                          "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                          "ON a.project_key=b.sonar_project_key where pqd_component_id=? and date between ? and ? group by date)" +
                                                          "AS T group by year,month";

const string GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT = "SELECT year(date) as year,quarter(date) as quarter,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                            "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                            "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                            "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                            "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                            "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                            "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                            "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                            "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                            "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                            "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                            "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                            "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                            "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                            "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                            "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                            "ON a.project_key=b.sonar_project_key where pqd_component_id=? and date between ? and ? group by date)" +
                                                            "AS T group by year,quarter";

const string GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT = "SELECT year(date) as year,AVG(BLOCKER_BUG) as BLOCKER_BUG," +
                                                         "AVG(CRITICAL_BUG) as CRITICAL_BUG,AVG(MAJOR_BUG) as MAJOR_BUG," +
                                                         "AVG(MINOR_BUG) as MINOR_BUG, AVG(INFO_BUG) as INFO_BUG," +
                                                         "AVG(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,AVG(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                         "AVG(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,AVG(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                         "AVG(INFO_CODE_SMELL) as INFO_CODE_SMELL,AVG(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                         "AVG(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,AVG(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                         "AVG(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, AVG(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                         "AVG(total) as total FROM(SELECT date,SUM(BLOCKER_BUG) as BLOCKER_BUG,SUM(CRITICAL_BUG) as CRITICAL_BUG," +
                                                         "SUM(MAJOR_BUG) as MAJOR_BUG,SUM(MINOR_BUG) as MINOR_BUG, SUM(INFO_BUG) as INFO_BUG," +
                                                         "SUM(BLOCKER_CODE_SMELL) as BLOCKER_CODE_SMELL,SUM(CRITICAL_CODE_SMELL) as CRITICAL_CODE_SMELL," +
                                                         "SUM(MAJOR_CODE_SMELL) as MAJOR_CODE_SMELL,SUM(MINOR_CODE_SMELL) as MINOR_CODE_SMELL, " +
                                                         "SUM(INFO_CODE_SMELL) as INFO_CODE_SMELL,SUM(BLOCKER_VULNERABILITY) as BLOCKER_VULNERABILITY," +
                                                         "SUM(CRITICAL_VULNERABILITY) as CRITICAL_VULNERABILITY,SUM(MAJOR_VULNERABILITY) as MAJOR_VULNERABILITY," +
                                                         "SUM(MINOR_VULNERABILITY) as MINOR_VULNERABILITY, SUM(INFO_VULNERABILITY) as INFO_VULNERABILITY," +
                                                         "SUM(total) as total FROM sonar_issues_table as a INNER JOIN pqd_component as b " +
                                                         "ON a.project_key=b.sonar_project_key where pqd_component_id=? and date between ? and ? group by date)" +
                                                         "AS T group by year";
