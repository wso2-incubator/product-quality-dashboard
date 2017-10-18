package org.wso2.internalapps.productqualitydashboard;

const string GET_GITHUB_AREA_QUERY = "SELECT pqd_area_id, pqd_area_name FROM pqd_area";

const string GET_GITHUB_PRODUCT_QUERY = "SELECT pqd_product_id, pqd_product_name, pqd_area_id, github_repo_name " +
                                        "FROM pqd_product";

const string GET_GITHUB_AREA_PRODUCT_QUERY = "SELECT pqd_product_id, pqd_product_name, pqd_area_id, github_repo_name " +
                                        "FROM pqd_product WHERE pqd_area_id = ?";

const string GET_GITHUB_PRODUCT_COMPONENT_QUERY = "SELECT pqd_component_id, pqd_component_name, pqd_product_id, github_repo_name " +
                                             "FROM pqd_component WHERE pqd_product_id = ?";

const string GET_GITHUB_ISSUE_TYPE_ALL_QUERY = "SELECT pqd_issue_type_id, pqd_issue_type, pqd_issue_type_github_label_text, pqd_issue_type_github_label_color " +
                                               "FROM pqd_issue_type";

const string GET_GITHUB_SEVERITY_ALL_QUERY = "SELECT pqd_severity_id, pqd_severity, pqd_severity_github_label_text, pqd_severity_github_label_color " +
                                             "FROM pqd_severity";

const string GET_GITHUB_ISSUE_TYPE_QUERY = "SELECT pqd_issue_type_id, pqd_issue_type, pqd_issue_type_github_label_text, pqd_issue_type_github_label_color " +
                                           "FROM pqd_issue_type WHERE pqd_issue_type <> 'Unknown'";

const string GET_GITHUB_SEVERITY_QUERY = "SELECT pqd_severity_id, pqd_severity, pqd_severity_github_label_text, pqd_severity_github_label_color " +
                                         "FROM pqd_severity WHERE pqd_severity <> 'Unknown'";

const string GET_GITHUB_ISSUE_TYPE_UNKNOWN_ID_QUERY = "SELECT pqd_issue_type_id FROM pqd_issue_type WHERE pqd_issue_type = 'Unknown'";

const string GET_GITHUB_SEVERITY_UNKNOWN_ID_QUERY = "SELECT pqd_severity FROM pqd_severity WHERE pqd_severity = 'Unknown'";

const string GET_GITHUB_LAST_SNAPSHOT = "SELECT pqd_snapshot_id from pqd_snapshot ORDER BY pqd_snapshot_id DESC LIMIT 1";

const string GET_GITHUB_AREA_ISSUES1 = "SELECT pqd_area_id, pqd_issue_type_id, pqd_severity_id, pqd_issues_count " +
                                      "FROM pqd_area_issues WHERE pqd_snapshot_id = ? AND pqd_area_id = ?";

const string GET_GITHUB_PRODUCT_ISSUES1 = "SELECT pqd_product_id, pqd_issue_type_id, pqd_severity_id, pqd_issues_count " +
                                      "FROM pqd_product_issues WHERE pqd_snapshot_id = ? AND pqd_product_id = ?";

const string GET_GITHUB_VERSION_ISSUES = "SELECT pqd_product_version_id, pqd_issue_type_id, pqd_severity_id, pqd_issues_count " +
                                      "FROM pqd_product_version_issues WHERE pqd_snapshot_id = ? AND pqd_product_version_id = ?";



const string GET_GITHUB_COMPONENT_ISSUES = "SELECT pqd_component.pqd_component_name, pqd_issue_type.pqd_issue_type, " +
                                           "pqd_severity.pqd_severity, pqd_component_issues.pqd_issues_count, " +
                                           "pqd_component_issues.pqd_updated FROM `pqd_component_issues` " +
                                           "INNER JOIN pqd_component INNER JOIN pqd_issue_type INNER JOIN " +
                                           "pqd_severity WHERE pqd_component.pqd_component_id = pqd_component_issues.pqd_component_id " +
                                           "AND pqd_issue_type.pqd_issue_type_id = pqd_component_issues.pqd_issue_type_id " +
                                           "AND pqd_severity.pqd_severity_id = pqd_component_issues.pqd_severity_id " +
                                           "AND pqd_component_issues.pqd_component_id = ?";

const string GET_GITHUB_PRODUCT_ISSUES = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                         "SUM(pqd_product_issues.pqd_issues_count) AS pqd_issues_count " +
                                         "FROM pqd_product INNER JOIN pqd_product_issues WHERE " +
                                         "pqd_product.pqd_product_id = pqd_product_issues.pqd_product_id " +
                                         "AND pqd_product.pqd_product_id = ? GROUP BY pqd_product_id";

const string GET_GITHUB_PRODUCT_ISSUETYPE_ISSUES = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                   "SUM(pqd_product_issues.pqd_issues_count) AS pqd_issues_count " +
                                                   "FROM pqd_issue_type INNER JOIN pqd_product_issues WHERE " +
                                                   "pqd_issue_type.pqd_issue_type_id = pqd_product_issues.pqd_issue_type_id " +
                                                   "AND pqd_product_issues.pqd_product_id = ? GROUP BY pqd_issue_type_id";

const string GET_GITHUB_PRODUCT_ISSUETYPE_ISSUES_FILTER_BY_SEVERITY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                   "SUM(pqd_product_issues.pqd_issues_count) AS pqd_issues_count " +
                                                   "FROM pqd_issue_type INNER JOIN pqd_product_issues WHERE " +
                                                   "pqd_issue_type.pqd_issue_type_id = pqd_product_issues.pqd_issue_type_id " +
                                                   "AND pqd_product_issues.pqd_product_id = ? AND pqd_product_issues.pqd_severity_id = ? " +
                                                                      "GROUP BY pqd_issue_type_id";

const string GET_GITHUB_PRODUCT_SEVERITY_ISSUES = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                  "SUM(pqd_product_issues.pqd_issues_count) AS pqd_issues_count " +
                                                  "FROM pqd_severity INNER JOIN pqd_product_issues WHERE " +
                                                  "pqd_severity.pqd_severity_id = pqd_product_issues.pqd_severity_id " +
                                                  "AND pqd_product_issues.pqd_product_id = ? GROUP BY pqd_severity_id";

const string GET_GITHUB_PRODUCT_SEVERITY_ISSUES_FILTER_BY_ISSUETYPE = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                  "SUM(pqd_product_issues.pqd_issues_count) AS pqd_issues_count " +
                                                  "FROM pqd_severity INNER JOIN pqd_product_issues WHERE " +
                                                  "pqd_severity.pqd_severity_id = pqd_product_issues.pqd_severity_id " +
                                                  "AND pqd_product_issues.pqd_product_id = ? " +
                                                                      "AND pqd_product_issues.pqd_issue_type_id = ? GROUP BY pqd_severity_id";

const string GET_GITHUB_PRODUCT_SUM_QUERY = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, SUM(pqd_product_issues.pqd_issues_count) " +
                                            "AS pqd_issues_count FROM pqd_product INNER JOIN pqd_product_issues " +
                                            "WHERE pqd_product_issues.pqd_product_id = ? AND " +
                                            "pqd_product.pqd_product_id = pqd_product_issues.pqd_product_id";

const string GET_GITHUB_PRODUCT_COMPONENT_ISSUES = "SELECT pqd_component.pqd_component_id, pqd_component.pqd_component_name, " +
                                            "SUM(pqd_component_issues.pqd_issues_count) AS pqd_issues_count " +
                                            "FROM pqd_component INNER JOIN pqd_component_issues WHERE " +
                                            "pqd_component.pqd_component_id = pqd_component_issues.pqd_component_id " +
                                            "AND pqd_component.pqd_product_id = ? GROUP BY pqd_component_id, pqd_component_name";

const string GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_ISSUETYPE = "SELECT pqd_component.pqd_component_id, pqd_component.pqd_component_name, " +
                                                   "SUM(pqd_component_issues.pqd_issues_count) AS pqd_issues_count " +
                                                   "FROM pqd_component INNER JOIN pqd_component_issues WHERE " +
                                                   "pqd_component.pqd_component_id = pqd_component_issues.pqd_component_id " +
                                                   "AND pqd_component.pqd_product_id = ? AND pqd_component_issues.pqd_issue_type_id = ? GROUP BY pqd_component_id, pqd_component_name";

const string GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_SEVERITY = "SELECT pqd_component.pqd_component_id, pqd_component.pqd_component_name, " +
                                                                         "SUM(pqd_component_issues.pqd_issues_count) AS pqd_issues_count " +
                                                                         "FROM pqd_component INNER JOIN pqd_component_issues WHERE " +
                                                                         "pqd_component.pqd_component_id = pqd_component_issues.pqd_component_id " +
                                                                         "AND pqd_component.pqd_product_id = ? AND pqd_component_issues.pqd_severity_id = ? GROUP BY pqd_component_id, pqd_component_name";

const string GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_ISSUETYPE_SEVERITY = "SELECT pqd_component.pqd_component_id, pqd_component.pqd_component_name, " +
                                                                         "SUM(pqd_component_issues.pqd_issues_count) AS pqd_issues_count " +
                                                                         "FROM pqd_component INNER JOIN pqd_component_issues WHERE " +
                                                                         "pqd_component.pqd_component_id = pqd_component_issues.pqd_component_id " +
                                                                         "AND pqd_component.pqd_product_id = ? AND pqd_component_issues.pqd_severity_id = ?" +
                                                                                  "AND pqd_component_issues.pqd_issue_type_id = ? GROUP BY pqd_component_id, pqd_component_name";

const string GET_GITHUB_PRODUCT_PRODUCT_ISSUES = "SELECT pqd_product.pqd_product_id AS pqd_component_id, pqd_product.pqd_product_name " +
                                          "AS pqd_component_name, SUM(pqd_product_issues.pqd_issues_count) " +
                                          "AS pqd_issues_count FROM pqd_product INNER JOIN pqd_product_issues WHERE " +
                                          "pqd_product.pqd_product_id = pqd_product_issues.pqd_product_id AND " +
                                          "pqd_product.pqd_product_id = ? GROUP BY pqd_product.pqd_product_id, " +
                                          "pqd_product.pqd_product_name";

const string GET_GITHUB_AREA_SUM_QUERY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, SUM(pqd_area_issues.pqd_issues_count) " +
                                         "AS pqd_issues_count FROM pqd_area INNER JOIN pqd_area_issues " +
                                         "WHERE pqd_area_issues.pqd_area_id = ? AND " +
                                         "pqd_area.pqd_area_id = pqd_area_issues.pqd_area_id";


const string GET_GITHUB_AREA_PRODUCT_ISSUES = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                              "SUM(pqd_product_issues.pqd_issues_count) AS pqd_issues_count " +
                                              "FROM pqd_product INNER JOIN pqd_product_issues WHERE " +
                                              "pqd_product.pqd_product_id = pqd_product_issues.pqd_product_id AND " +
                                              "pqd_product.pqd_area_id = ? GROUP BY pqd_product_id";

const string GET_GITHUB_AREA_PRODUCT_FILTER_BY_ISSUETYPE_ISSUES = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                                                  "SUM(pqd_product_issues.pqd_issues_count) AS " +
                                                                  "pqd_issues_count FROM pqd_product INNER JOIN " +
                                                                  "pqd_product_issues WHERE " +
                                                                  "pqd_product.pqd_product_id = pqd_product_issues.pqd_product_id " +
                                                                  "AND pqd_product.pqd_area_id = ? AND " +
                                                                  "pqd_product_issues.pqd_issue_type_id = ? GROUP BY pqd_product_id";

const string GET_GITHUB_AREA_PRODUCT_FILTER_BY_SEVERITY_ISSUES = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                                                  "SUM(pqd_product_issues.pqd_issues_count) AS " +
                                                                  "pqd_issues_count FROM pqd_product INNER JOIN " +
                                                                  "pqd_product_issues WHERE " +
                                                                  "pqd_product.pqd_product_id = pqd_product_issues.pqd_product_id " +
                                                                  "AND pqd_product.pqd_area_id = ? AND " +
                                                                  "pqd_product_issues.pqd_severity_id = ? GROUP BY pqd_product_id";

const string GET_GITHUB_AREA_PRODUCT_FILTER_BY_SEVERITY_AND_ISSUETYPE = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                                                        "SUM(pqd_product_issues.pqd_issues_count) AS " +
                                                                        "pqd_issues_count FROM pqd_product INNER JOIN " +
                                                                        "pqd_product_issues WHERE " +
                                                                        "pqd_product.pqd_product_id = pqd_product_issues.pqd_product_id " +
                                                                        "AND pqd_product.pqd_area_id = ? AND " +
                                                                        "pqd_product_issues.pqd_severity_id = ? " +
                                                                        "AND pqd_product_issues.pqd_issue_type_id = ? GROUP BY pqd_product_id";


const string GET_GITHUB_AREA_ISSUETYPE_ISSUES = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                "INNER JOIN pqd_area_issues WHERE " +
                                                "pqd_issue_type.pqd_issue_type_id = pqd_area_issues.pqd_issue_type_id " +
                                                "AND pqd_area_issues.pqd_area_id = ? GROUP BY pqd_issue_type_id";

const string GET_GITHUB_AREA_ISSUETYPE_FILTER_BY_SEVERITY_ISSUES = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                   "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                   "INNER JOIN pqd_area_issues WHERE " +
                                                                   "pqd_issue_type.pqd_issue_type_id = pqd_area_issues.pqd_issue_type_id " +
                                                                   "AND pqd_area_issues.pqd_area_id = ? AND pqd_area_issues.pqd_severity_id = ? " +
                                                                   "GROUP BY pqd_issue_type_id";

const string GET_GITHUB_AREA_SEVERITY_FILTER_BY_ISSUETYPE_ISSUES = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                             "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                             "INNER JOIN pqd_area_issues WHERE pqd_severity.pqd_severity_id = pqd_area_issues.pqd_severity_id " +
                                                             "AND pqd_area_issues.pqd_area_id = ? AND pqd_area_issues.pqd_issue_type_id = ? GROUP BY pqd_severity_id";


const string GET_GITHUB_AREA_SEVERITY_ISSUES = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                      "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                      "INNER JOIN pqd_area_issues WHERE pqd_severity.pqd_severity_id = pqd_area_issues.pqd_severity_id " +
                                      "AND pqd_area_issues.pqd_area_id = ? GROUP BY pqd_severity_id";



const string DELETE_GITHUB_COMPONENT_ISSUES_QUERY = "TRUNCATE TABLE pqd_component_issues";

const string DELETE_GITHUB_PRODUCT_ISSUES_QUERY = "TRUNCATE TABLE pqd_product_issues";

const string INSERT_GITHUB_COMPONENT_ISSUES_QUERY = "INSERT INTO pqd_component_issues(pqd_component_id, pqd_issue_type_id, " +
                                                    "pqd_severity_id, pqd_issues_count) " +
                                                    "VALUES (?, ?, ?, ?)";

const string INSERT_GITHUB_PRODUCT_ISSUES_QUERY = "INSERT INTO pqd_product_issues(pqd_product_id, pqd_issue_type_id, " +
                                                    "pqd_severity_id, pqd_issues_count) " +
                                                    "VALUES (?, ?, ?, ?)";

const string INSERT_GITHUB_COMPONENT_ISSUES_HISTORY_QUERY = "INSERT INTO pqd_github_component_issues_history(pqd_component_id, " +
                                                            "pqd_issue_type_id, pqd_severity_id, pqd_issues_count, pqd_date) " +
                                                            "VALUES (?, ?, ?, ?, ?)";

const string INSERT_GITHUB_AREA_ISSUES_HISTORY_QUERY = "INSERT INTO pqd_github_area_issues_history(pqd_area_id, " +
                                                            "pqd_issue_type_id, pqd_severity_id, pqd_issues_count, pqd_date) " +
                                                            "VALUES (?, ?, ?, ?, ?)";

const string INSERT_GITHUB_PRODUCT_ISSUES_HISTORY_QUERY = "INSERT INTO pqd_github_product_issues_history(pqd_product_id, " +
                                                          "pqd_issue_type_id, pqd_severity_id, pqd_issues_count, pqd_date) " +
                                                          "VALUES (?, ?, ?, ?, ?)";

const string GET_GITHUB_COMPONENT_CURRENT_ISSUES_QUERY = "SELECT pqd_component_id, pqd_issue_type_id, pqd_severity_id, pqd_issues_count " +
                                                         "FROM pqd_component_issues";

const string GET_GITHUB_PRODUCT_CURRENT_ISSUES_QUERY = "SELECT pqd_product_id, pqd_issue_type_id, pqd_severity_id, pqd_issues_count " +
                                                         "FROM pqd_product_issues";

const string GET_GITHUB_AREA_CURRENT_ISSUES_QUERY = "SELECT pqd_area_id, pqd_issue_type_id, pqd_severity_id, pqd_issues_count " +
                                                       "FROM pqd_area_issues";

const string GET_GITHUB_ALL_AREAS_CURRENT_ISSUES_QUERY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, " +
                                                         "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count " +
                                                         "FROM pqd_area INNER JOIN pqd_area_issues " +
                                                         "WHERE pqd_area.pqd_area_id = pqd_area_issues.pqd_area_id " +
                                                         "GROUP BY pqd_area_id";

const string GET_GITHUB_ALL_AREAS_ISSUETYPE_CURRENT_ISSUES_QUERY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, " +
                                                                   "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count " +
                                                                   "FROM pqd_area INNER JOIN pqd_area_issues WHERE " +
                                                                   "pqd_area.pqd_area_id = pqd_area_issues.pqd_area_id " +
                                                                   "AND pqd_area_issues.pqd_issue_type_id = ? GROUP BY pqd_area_id";

const string GET_GITHUB_ALL_AREAS_SEVERITY_CURRENT_ISSUES_QUERY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, " +
                                                                  "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count " +
                                                                  "FROM pqd_area INNER JOIN pqd_area_issues WHERE " +
                                                                  "pqd_area.pqd_area_id = pqd_area_issues.pqd_area_id " +
                                                                  "AND pqd_area_issues.pqd_severity_id = ? GROUP BY pqd_area_id";

const string GET_GITHUB_ALL_AREAS_FILTERED_CURRENT_ISSUES_QUERY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, " +
                                                                  "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count " +
                                                                  "FROM pqd_area INNER JOIN pqd_area_issues WHERE " +
                                                                  "pqd_area.pqd_area_id = pqd_area_issues.pqd_area_id " +
                                                                  "AND pqd_area_issues.pqd_issue_type_id = ? " +
                                                                  "AND pqd_area_issues.pqd_severity_id = ? GROUP BY pqd_area_id";

const string GET_GITHUB_ALL_AREAS_ISSUETYPE_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                    "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                    "INNER JOIN pqd_area_issues " +
                                                    "WHERE pqd_issue_type.pqd_issue_type_id = pqd_area_issues.pqd_issue_type_id " +
                                                    "GROUP BY pqd_issue_type_id";

const string GET_GITHUB_ALL_AREAS_SEVERITY_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                   "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count " +
                                                   "FROM pqd_severity INNER JOIN pqd_area_issues " +
                                                   "WHERE pqd_severity.pqd_severity_id = pqd_area_issues.pqd_severity_id " +
                                                   "GROUP BY pqd_severity_id";

const string GET_GITHUB_ALL_AREAS_SEVERITY_ISSUETYPE_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                    "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                    "INNER JOIN pqd_area_issues " +
                                                    "WHERE pqd_issue_type.pqd_issue_type_id = pqd_area_issues.pqd_issue_type_id " +
                                                             "AND pqd_area_issues.pqd_severity_id = ? " +
                                                    "GROUP BY pqd_issue_type_id";

const string GET_GITHUB_ALL_AREAS_ISSUETYPE_SEVERITY_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                             "SUM(pqd_area_issues.pqd_issues_count) AS pqd_issues_count " +
                                                             "FROM pqd_severity INNER JOIN pqd_area_issues " +
                                                             "WHERE pqd_severity.pqd_severity_id = pqd_area_issues.pqd_severity_id " +
                                                             "AND pqd_area_issues.pqd_issue_type_id = ? " +
                                                             "GROUP BY pqd_severity_id";

const string GET_GITHUB_COMPONENT_QUERY = "SELECT pqd_component_id, pqd_component_name, pqd_product_id, github_repo_name, github_repo_organization " +
                                          "FROM pqd_component";

const string GET_GITHUB_COMPONENT_NAME_QUERY = "SELECT pqd_component_name FROM pqd_component WHERE pqd_component_id = ?";

const string GET_GITHUB_ORGANIZATION_QUERY = "SELECT pqd_organization_name FROM pqd_github_organization";

const string GET_PRODUCT_TOTAL_ISSUES_QUERY = "INSERT INTO pqd_product_issues(pqd_product_id, pqd_issue_type_id, " +
                                              "pqd_severity_id, pqd_issues_count) " +
                                              "SELECT pqd_product.pqd_product_id, pqd_component_issues.pqd_issue_type_id, " +
                                              "pqd_component_issues.pqd_severity_id, SUM(pqd_component_issues.pqd_issues_count) AS pqd_issues_count " +
                                              "FROM pqd_product INNER JOIN pqd_component INNER JOIN pqd_component_issues " +
                                              "WHERE pqd_product.pqd_product_id = pqd_component.pqd_product_id AND " +
                                              "pqd_component.pqd_component_id = pqd_component_issues.pqd_component_id " +
                                              "GROUP BY pqd_product_id, " +
                                              "pqd_issue_type_id, pqd_severity_id";

const string DELETE_GITHUB_TOTAL_PRODUCT_ISSUES_QUERY = "TRUNCATE TABLE pqd_product_issues";


const string GET_AREA_ISSUES_QUERY = "INSERT INTO pqd_area_issues(pqd_area_id, pqd_issue_type_id, pqd_severity_id, pqd_issues_count) " +
                                     "SELECT combined.pqd_area_id, combined.pqd_issue_type_id, combined.pqd_severity_id, " +
                                     "SUM(combined.pqd_issues_count) AS pqd_issues_count " +
                                     "FROM (SELECT pqd_area.pqd_area_id, pqd_product_issues.pqd_issue_type_id, " +
                                     "pqd_product_issues.pqd_severity_id, pqd_product_issues.pqd_issues_count " +
                                     "FROM pqd_area INNER JOIN pqd_product INNER JOIN pqd_product_issues " +
                                     "WHERE pqd_area.pqd_area_id = pqd_product.pqd_area_id AND " +
                                     "pqd_product.pqd_product_id = pqd_product_issues.pqd_product_id) " +
                                     "AS combined GROUP BY combined.pqd_area_id, combined.pqd_issue_type_id, combined.pqd_severity_id";

const string DELETE_GITHUB_AREA_ISSUES_QUERY = "TRUNCATE TABLE pqd_area_issues";



const string GET_GITHUB_ALL_AREAS_HISTORY_BY_DAY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_area_issues_history` " +
                                                   "WHERE pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_DAY_FILTER_ISSUETYPE = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_area_issues_history` " +
                                                                    "WHERE pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_DAY_FILTER_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_area_issues_history` " +
                                                                   "WHERE pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                             "`pqd_github_area_issues_history` WHERE pqd_issue_type_id=? " +
                                                                             "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? " +
                                                                             "GROUP BY pqd_date";


const string GET_GITHUB_ALL_AREAS_HISTORY_BY_MONTH = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                     "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                     "`pqd_github_area_issues_history` WHERE pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                     "GROUP BY year,month";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_MONTH_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, month(pqd_date) as month," +
                                                                      " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                      "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                      "`pqd_github_area_issues_history` WHERE pqd_issue_type_id=? AND " +
                                                                      "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                      "GROUP BY year,month";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_MONTH_FILTER_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month," +
                                                                     " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "`pqd_github_area_issues_history` WHERE pqd_severity_id=? " +
                                                                     "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                     "GROUP BY year,month";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                                               "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                               "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                               "FROM `pqd_github_area_issues_history` " +
                                                                               "WHERE pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                               "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                               "GROUP BY year,month";


const string GET_GITHUB_ALL_AREAS_HISTORY_BY_QUARTER = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                       "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                       "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                       "`pqd_github_area_issues_history` WHERE pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                       "GROUP BY year,quarter";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter," +
                                                                        " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                        "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                        "`pqd_github_area_issues_history` WHERE pqd_issue_type_id=? AND " +
                                                                        "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                        "GROUP BY year,quarter";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter," +
                                                                       " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                       "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                       "`pqd_github_area_issues_history` WHERE pqd_severity_id=? " +
                                                                       "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                       "GROUP BY year,quarter";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                                                 "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                                 "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                                 "FROM `pqd_github_area_issues_history` " +
                                                                                 "WHERE pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                                 "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                                 "GROUP BY year,quarter";


const string GET_GITHUB_ALL_AREAS_HISTORY_BY_YEAR = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                    "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                    "`pqd_github_area_issues_history` WHERE pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                    "GROUP BY year";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_YEAR_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "`pqd_github_area_issues_history` WHERE pqd_issue_type_id=? AND " +
                                                                     "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                     "GROUP BY year";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_YEAR_FILTER_SEVERITY = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                    "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                    "`pqd_github_area_issues_history` WHERE pqd_severity_id=? " +
                                                                    "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                    "GROUP BY year";

const string GET_GITHUB_ALL_AREAS_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                              "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                              "FROM `pqd_github_area_issues_history` " +
                                                                              "WHERE pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                              "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                              "GROUP BY year";


const string GET_GITHUB_AREA_HISTORY_BY_DAY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_area_issues_history` " +
                                                   "WHERE pqd_area_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_AREA_HISTORY_BY_DAY_FILTER_ISSUETYPE = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_area_issues_history` " +
                                                                    "WHERE pqd_area_id=? AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_AREA_HISTORY_BY_DAY_FILTER_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_area_issues_history` " +
                                                                   "WHERE pqd_area_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_AREA_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                             "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_issue_type_id=? " +
                                                                             "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? " +
                                                                             "GROUP BY pqd_date";


const string GET_GITHUB_AREA_HISTORY_BY_MONTH = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                     "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                     "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                     "GROUP BY year,month";

const string GET_GITHUB_AREA_HISTORY_BY_MONTH_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, month(pqd_date) as month," +
                                                                      " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                      "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                      "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_issue_type_id=? AND " +
                                                                      "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                      "GROUP BY year,month";

const string GET_GITHUB_AREA_HISTORY_BY_MONTH_FILTER_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month," +
                                                                     " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_severity_id=? " +
                                                                     "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                     "GROUP BY year,month";

const string GET_GITHUB_AREA_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                                               "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                               "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                               "FROM `pqd_github_area_issues_history` " +
                                                                               "WHERE pqd_area_id=? AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                               "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                               "GROUP BY year,month";


const string GET_GITHUB_AREA_HISTORY_BY_QUARTER = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                       "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                       "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                       "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                       "GROUP BY year,quarter";

const string GET_GITHUB_AREA_HISTORY_BY_QUARTER_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter," +
                                                                        " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                        "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                        "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_issue_type_id=? AND " +
                                                                        "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                        "GROUP BY year,quarter";

const string GET_GITHUB_AREA_HISTORY_BY_QUARTER_FILTER_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter," +
                                                                       " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                       "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                       "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_severity_id=? " +
                                                                       "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                       "GROUP BY year,quarter";

const string GET_GITHUB_AREA_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                                                 "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                                 "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                                 "FROM `pqd_github_area_issues_history` " +
                                                                                 "WHERE pqd_area_id=? AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                                 "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                                 "GROUP BY year,quarter";


const string GET_GITHUB_AREA_HISTORY_BY_YEAR = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                    "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                    "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                    "GROUP BY year";

const string GET_GITHUB_AREA_HISTORY_BY_YEAR_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_issue_type_id=? AND " +
                                                                     "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                     "GROUP BY year";

const string GET_GITHUB_AREA_HISTORY_BY_YEAR_FILTER_SEVERITY = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                    "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                    "`pqd_github_area_issues_history` WHERE pqd_area_id=? AND pqd_severity_id=? " +
                                                                    "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                    "GROUP BY year";

const string GET_GITHUB_AREA_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                              "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                              "FROM `pqd_github_area_issues_history` " +
                                                                              "WHERE pqd_area_id=? AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                              "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                              "GROUP BY year";



const string GET_GITHUB_PRODUCT_HISTORY_BY_DAY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_product_issues_history` " +
                                              "WHERE pqd_product_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_PRODUCT_HISTORY_BY_DAY_FILTER_ISSUETYPE = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_product_issues_history` " +
                                                               "WHERE pqd_product_id=? AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_PRODUCT_HISTORY_BY_DAY_FILTER_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_product_issues_history` " +
                                                              "WHERE pqd_product_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_PRODUCT_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                        "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_issue_type_id=? " +
                                                                        "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? " +
                                                                        "GROUP BY pqd_date";


const string GET_GITHUB_PRODUCT_HISTORY_BY_MONTH = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                "GROUP BY year,month";

const string GET_GITHUB_PRODUCT_HISTORY_BY_MONTH_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, month(pqd_date) as month," +
                                                                 " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                 "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                 "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_issue_type_id=? AND " +
                                                                 "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                 "GROUP BY year,month";

const string GET_GITHUB_PRODUCT_HISTORY_BY_MONTH_FILTER_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month," +
                                                                " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_severity_id=? " +
                                                                "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                "GROUP BY year,month";

const string GET_GITHUB_PRODUCT_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                                          "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                          "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                          "FROM `pqd_github_product_issues_history` " +
                                                                          "WHERE pqd_product_id=? AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                          "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                          "GROUP BY year,month";


const string GET_GITHUB_PRODUCT_HISTORY_BY_QUARTER = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                  "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                  "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                  "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                  "GROUP BY year,quarter";

const string GET_GITHUB_PRODUCT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter," +
                                                                   " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                   "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                   "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_issue_type_id=? AND " +
                                                                   "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                   "GROUP BY year,quarter";

const string GET_GITHUB_PRODUCT_HISTORY_BY_QUARTER_FILTER_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter," +
                                                                  " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                  "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                  "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_severity_id=? " +
                                                                  "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                  "GROUP BY year,quarter";

const string GET_GITHUB_PRODUCT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                                            "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                            "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                            "FROM `pqd_github_product_issues_history` " +
                                                                            "WHERE pqd_product_id=? AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                            "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                            "GROUP BY year,quarter";


const string GET_GITHUB_PRODUCT_HISTORY_BY_YEAR = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                               "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                               "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                               "GROUP BY year";

const string GET_GITHUB_PRODUCT_HISTORY_BY_YEAR_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_issue_type_id=? AND " +
                                                                "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                "GROUP BY year";

const string GET_GITHUB_PRODUCT_HISTORY_BY_YEAR_FILTER_SEVERITY = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                               "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                               "`pqd_github_product_issues_history` WHERE pqd_product_id=? AND pqd_severity_id=? " +
                                                               "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                               "GROUP BY year";

const string GET_GITHUB_PRODUCT_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                         "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                         "FROM `pqd_github_product_issues_history` " +
                                                                         "WHERE pqd_product_id=? AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                         "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                         "GROUP BY year";



const string GET_GITHUB_COMPONENT_HISTORY_BY_DAY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_component_issues_history` " +
                                                 "WHERE pqd_component_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_COMPONENT_HISTORY_BY_DAY_FILTER_ISSUETYPE = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_component_issues_history` " +
                                                                  "WHERE pqd_component_id=? AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_COMPONENT_HISTORY_BY_DAY_FILTER_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM `pqd_github_component_issues_history` " +
                                                                 "WHERE pqd_component_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_COMPONENT_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                           "`pqd_github_component_issues_history` WHERE pqd_component_id=? AND pqd_issue_type_id=? " +
                                                                           "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? " +
                                                                           "GROUP BY pqd_date";


const string GET_GITHUB_COMPONENT_HISTORY_BY_MONTH = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                   "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                   "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                   "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                   "GROUP BY year,month";

const string GET_GITHUB_COMPONENT_HISTORY_BY_MONTH_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, month(pqd_date) as month," +
                                                                    " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                    "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                    "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_issue_type_id=? AND " +
                                                                    "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                    "GROUP BY year,month";

const string GET_GITHUB_COMPONENT_HISTORY_BY_MONTH_FILTER_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month," +
                                                                   " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                   "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                   "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_severity_id=? " +
                                                                   "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                   "GROUP BY year,month";

const string GET_GITHUB_COMPONENT_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                                             "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                             "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                             "FROM `pqd_github_component_issues_history` " +
                                                                             "WHERE `pqd_component_id=?` AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                             "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                             "GROUP BY year,month";


const string GET_GITHUB_COMPONENT_HISTORY_BY_QUARTER = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                     "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                     "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                     "GROUP BY year,quarter";

const string GET_GITHUB_COMPONENT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter," +
                                                                      " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                      "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                      "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_issue_type_id=? AND " +
                                                                      "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                      "GROUP BY year,quarter";

const string GET_GITHUB_COMPONENT_HISTORY_BY_QUARTER_FILTER_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter," +
                                                                     " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                     "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_severity_id=? " +
                                                                     "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                     "GROUP BY year,quarter";

const string GET_GITHUB_COMPONENT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                                               "AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                               "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                               "FROM `pqd_github_component_issues_history` " +
                                                                               "WHERE `pqd_component_id=?` AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                               "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                               "GROUP BY year,quarter";


const string GET_GITHUB_COMPONENT_HISTORY_BY_YEAR = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                  "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                  "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                  "GROUP BY year";

const string GET_GITHUB_COMPONENT_HISTORY_BY_YEAR_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                   "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                   "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_issue_type_id=? AND " +
                                                                   "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                   "GROUP BY year";

const string GET_GITHUB_COMPONENT_HISTORY_BY_YEAR_FILTER_SEVERITY = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                  "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                  "`pqd_github_component_issues_history` WHERE `pqd_component_id=?` AND pqd_severity_id=? " +
                                                                  "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                  "GROUP BY year";

const string GET_GITHUB_COMPONENT_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                            "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count " +
                                                                            "FROM `pqd_github_component_issues_history` " +
                                                                            "WHERE `pqd_component_id=?` AND pqd_issue_type_id=? AND pqd_severity_id=? " +
                                                                            "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                                            "GROUP BY year";




