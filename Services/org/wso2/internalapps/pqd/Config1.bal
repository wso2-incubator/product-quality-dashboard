package org.wso2.internalapps.pqd;

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_DAY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                        "(SELECT pqd_date, pqd_issues_count FROM pqd_github_area_issues_history " +
                                                        "UNION ALL SELECT pqd_updated AS pqd_date, pqd_issue_count AS pqd_issues_count " +
                                                        "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_date " +
                                                        "BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_DAY_FILTER_ISSUETYPE = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                         "(SELECT pqd_date, pqd_issues_count, pqd_issue_type_id " +
                                                                         "FROM pqd_github_area_issues_history UNION ALL SELECT pqd_updated " +
                                                                         "AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_issue_type_id " +
                                                                         "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_issue_type_id = ? " +
                                                                         "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_DAY_FILTER_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                        "(SELECT pqd_date, pqd_issues_count, pqd_severity_id " +
                                                                        "FROM pqd_github_area_issues_history UNION ALL SELECT pqd_updated " +
                                                                        "AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_severity_id " +
                                                                        "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_severity_id = ? " +
                                                                        "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                                  "(SELECT pqd_date, pqd_issues_count, pqd_severity_id, pqd_issue_type_id " +
                                                                                  "FROM pqd_github_area_issues_history UNION ALL " +
                                                                                  "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                  "AS pqd_issues_count, pqd_severity_id, pqd_issue_type_id " +
                                                                                  "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                                  "WHERE pqd_issue_type_id = ? AND pqd_severity_id = ? AND pqd_date " +
                                                                                  "BETWEEN ? AND ? GROUP BY pqd_date";


const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_MONTH = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                          "AVG(pqd_issues_count) as pqd_issues_count FROM (SELECT pqd_date," +
                                                          "SUM(pqd_issues_count) as pqd_issues_count FROM (SELECT pqd_date, " +
                                                          "pqd_issues_count FROM pqd_github_area_issues_history UNION ALL " +
                                                          "SELECT pqd_updated AS pqd_date, pqd_issue_count AS pqd_issues_count " +
                                                          "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_date " +
                                                          "BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_MONTH_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                                           "AVG(pqd_issues_count) as pqd_issues_count " +
                                                                           "FROM (SELECT pqd_date,SUM(pqd_issues_count) as " +
                                                                           "pqd_issues_count FROM (SELECT pqd_date, pqd_issues_count, " +
                                                                           "pqd_issue_type_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                           "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                           "AS pqd_issues_count, pqd_issue_type_id " +
                                                                           "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                           "WHERE pqd_issue_type_id = ? AND pqd_date BETWEEN ? AND ? " +
                                                                           "GROUP BY pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_MONTH_FILTER_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                                          "AVG(pqd_issues_count) as pqd_issues_count " +
                                                                          "FROM (SELECT pqd_date,SUM(pqd_issues_count) as " +
                                                                          "pqd_issues_count FROM (SELECT pqd_date, pqd_issues_count, " +
                                                                          "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                          "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                          "AS pqd_issues_count, pqd_severity_id " +
                                                                          "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                          "WHERE pqd_severity_id = ? AND pqd_date BETWEEN ? AND ? " +
                                                                          "GROUP BY pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month, " +
                                                                                    "AVG(pqd_issues_count) as pqd_issues_count " +
                                                                                    "FROM (SELECT pqd_date,SUM(pqd_issues_count) as " +
                                                                                    "pqd_issues_count FROM (SELECT pqd_date, pqd_issues_count, " +
                                                                                    "pqd_issue_type_id, pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                                    "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                    "AS pqd_issues_count, pqd_issue_type_id, pqd_severity_id " +
                                                                                    "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                                    "WHERE pqd_issue_type_id = ? AND pqd_severity_id = ? AND pqd_date BETWEEN ? AND ? " +
                                                                                    "GROUP BY pqd_date)AS T GROUP BY year,month";


const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_QUARTER = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                            "AVG(pqd_issues_count) as pqd_issues_count FROM (SELECT pqd_date," +
                                                            "SUM(pqd_issues_count) as pqd_issues_count FROM (SELECT pqd_date, " +
                                                            "pqd_issues_count FROM pqd_github_area_issues_history UNION ALL " +
                                                            "SELECT pqd_updated AS pqd_date, pqd_issue_count AS pqd_issues_count " +
                                                            "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_date " +
                                                            "BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                            "GROUP BY year,quarter";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                                             "AVG(pqd_issues_count) as pqd_issues_count " +
                                                                             "FROM (SELECT pqd_date,SUM(pqd_issues_count) as " +
                                                                             "pqd_issues_count FROM (SELECT pqd_date, pqd_issues_count, " +
                                                                             "pqd_issue_type_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                             "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                             "AS pqd_issues_count, pqd_issue_type_id " +
                                                                             "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                             "WHERE pqd_issue_type_id = ? AND pqd_date BETWEEN ? AND ? " +
                                                                        "GROUP BY pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                                            "AVG(pqd_issues_count) as pqd_issues_count " +
                                                                            "FROM (SELECT pqd_date,SUM(pqd_issues_count) as " +
                                                                            "pqd_issues_count FROM (SELECT pqd_date, pqd_issues_count, " +
                                                                            "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                            "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                            "AS pqd_issues_count, pqd_severity_id " +
                                                                            "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                            "WHERE pqd_severity_id = ? AND pqd_date BETWEEN ? AND ? " +
                                                                            "GROUP BY pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, " +
                                                                                      "AVG(pqd_issues_count) as pqd_issues_count " +
                                                                                      "FROM (SELECT pqd_date,SUM(pqd_issues_count) as " +
                                                                                      "pqd_issues_count FROM (SELECT pqd_date, pqd_issues_count, pqd_issue_type_id, " +
                                                                                      "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                                      "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                      "AS pqd_issues_count, pqd_issue_type_id, pqd_severity_id " +
                                                                                      "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                                      "WHERE pqd_issue_type_id = ? AND pqd_severity_id = ? AND pqd_date BETWEEN ? AND ? " +
                                                                                      "GROUP BY pqd_date)AS T GROUP BY year,quarter";


const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_YEAR = "SELECT year(pqd_date)year, " +
                                                         "AVG(pqd_issues_count) as pqd_issues_count FROM (SELECT pqd_date," +
                                                         "SUM(pqd_issues_count) as pqd_issues_count FROM (SELECT pqd_date, " +
                                                         "pqd_issues_count FROM pqd_github_area_issues_history UNION ALL " +
                                                         "SELECT pqd_updated AS pqd_date, pqd_issue_count AS pqd_issues_count " +
                                                         "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_date " +
                                                         "BETWEEN ? AND ? GROUP BY pqd_date)AS T " +
                                                         "GROUP BY year";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_YEAR_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, " +
                                                                          "AVG(pqd_issues_count) as pqd_issues_count " +
                                                                          "FROM (SELECT pqd_date,SUM(pqd_issues_count) as " +
                                                                          "pqd_issues_count FROM (SELECT pqd_date, pqd_issues_count, " +
                                                                          "pqd_issue_type_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                          "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                          "AS pqd_issues_count, pqd_issue_type_id " +
                                                                          "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                          "WHERE pqd_issue_type_id = ? AND pqd_date BETWEEN ? AND ? " +
                                                                          "GROUP BY pqd_date)AS T GROUP BY year";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_YEAR_FILTER_SEVERITY = "SELECT year(pqd_date)year, " +
                                                                         " AVG(pqd_issues_count) as pqd_issues_count FROM " +
                                                                         "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                         "`pqd_github_area_issues_history` WHERE pqd_severity_id = ? " +
                                                                         "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date) AS T " +
                                                                         "GROUP BY year";

const string GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, " +
                                                                                   "AVG(pqd_issues_count) as pqd_issues_count " +
                                                                                   "FROM (SELECT pqd_date,SUM(pqd_issues_count) as " +
                                                                                   "pqd_issues_count FROM (SELECT pqd_date, pqd_issues_count, pqd_issue_type_id, " +
                                                                                   "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                                   "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                   "AS pqd_issues_count, pqd_issue_type_id, pqd_severity_id " +
                                                                                   "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                                   "WHERE pqd_issue_type_id = ? AND pqd_severity_id = ? AND pqd_date BETWEEN ? AND ? " +
                                                                                   "GROUP BY pqd_date)AS T GROUP BY year";


const string GET_GITHUB_JIRA_AREA_HISTORY_BY_DAY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                   "(SELECT pqd_date, pqd_issues_count, pqd_area_id FROM pqd_github_area_issues_history " +
                                                   "UNION ALL SELECT pqd_updated AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_area_id " +
                                                   "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id = ? AND pqd_date " +
                                                   "BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_DAY_FILTER_ISSUETYPE = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                    "(SELECT pqd_date, pqd_issues_count, pqd_area_id, pqd_issue_type_id " +
                                                                    "FROM pqd_github_area_issues_history UNION ALL SELECT pqd_updated " +
                                                                    "AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_area_id, pqd_issue_type_id " +
                                                                    "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id = ? AND pqd_issue_type_id = ? " +
                                                                    "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_DAY_FILTER_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                   "(SELECT pqd_date, pqd_issues_count, pqd_area_id, pqd_severity_id " +
                                                                   "FROM pqd_github_area_issues_history UNION ALL SELECT pqd_updated " +
                                                                   "AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_area_id, pqd_severity_id " +
                                                                   "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id = ? AND pqd_severity_id = ? " +
                                                                   "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                             "(SELECT pqd_date, pqd_issues_count, pqd_area_id, pqd_severity_id, pqd_issue_type_id " +
                                                                             "FROM pqd_github_area_issues_history UNION ALL " +
                                                                             "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                             "AS pqd_issues_count, pqd_area_id, pqd_severity_id, pqd_issue_type_id " +
                                                                             "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                             "WHERE pqd_area_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? AND pqd_date " +
                                                                             "BETWEEN ? AND ? GROUP BY pqd_date";


const string GET_GITHUB_JIRA_AREA_HISTORY_BY_MONTH = "SELECT year(pqd_date)year, month(pqd_date) as month, AVG(pqd_issues_count) as "+
                                                     "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                     "FROM (SELECT pqd_date, pqd_issues_count, pqd_area_id " +
                                                     "FROM pqd_github_area_issues_history UNION ALL " +
                                                     "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                     "AS pqd_issues_count, pqd_area_id " +
                                                     "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? AND "+
                                                     "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_MONTH_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                      "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                      "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                      "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id FROM "+
                                                                      "pqd_github_area_issues_history UNION ALL SELECT pqd_updated AS "+
                                                                      "pqd_date, pqd_issue_count AS pqd_issues_count,pqd_area_id,pqd_issue_type_id FROM "+
                                                                      "pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                      "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                      " pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_MONTH_FILTER_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                     "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                     "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id, " +
                                                                     "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                     "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                     "AS pqd_issues_count,pqd_area_id,pqd_severity_id " +
                                                                     "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                     "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                     " pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                               "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                               "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                               "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                                               "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                               "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                               "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                                               "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                               "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                               " pqd_date)AS T GROUP BY year,month";


const string GET_GITHUB_JIRA_AREA_HISTORY_BY_QUARTER = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, AVG(pqd_issues_count) as "+
                                                       "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                       "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                       "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                       "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                       "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                       "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? AND "+
                                                       "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_QUARTER_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                        "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                        "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                        "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                                        "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                        "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                        "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                                        "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                        "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                        " pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_QUARTER_FILTER_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                       "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                       "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                       "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                                       "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                       "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                       "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                                       "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                       "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                       " pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                                 "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                                 "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                                 "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                                                 "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                                 "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                 "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                                                 "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                                 "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                                 " pqd_date)AS T GROUP BY year,quarter";


const string GET_GITHUB_JIRA_AREA_HISTORY_BY_YEAR = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as "+
                                                    "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                    "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                    "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                    "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                    "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                    "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? AND "+
                                                    "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_YEAR_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                     "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                                     "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                     "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                     "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                                     "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                     "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                     " pqd_date)AS T GROUP BY year";

const string GET_GITHUB_JIRA_AREA_HISTORY_BY_YEAR_FILTER_SEVERITY = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                    "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                    "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                                    "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                    "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                    "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                                    "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                    "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                    " pqd_date)AS T GROUP BY year";


const string GET_GITHUB_JIRA_AREA_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                              "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                              "FROM (SELECT pqd_date, pqd_issues_count,pqd_area_id,pqd_issue_type_id, " +
                                                                              "pqd_severity_id FROM pqd_github_area_issues_history UNION ALL " +
                                                                              "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                              "AS pqd_issues_count,pqd_area_id,pqd_issue_type_id, pqd_severity_id " +
                                                                              "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_area_id=? "+
                                                                              "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                              " pqd_date)AS T GROUP BY year";




const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_DAY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                   "(SELECT pqd_date, pqd_issues_count, pqd_product_id FROM pqd_github_product_issues_history " +
                                                   "UNION ALL SELECT pqd_updated AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_product_id " +
                                                   "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id = ? AND pqd_date " +
                                                   "BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_DAY_FILTER_ISSUETYPE = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                    "(SELECT pqd_date, pqd_issues_count, pqd_product_id, pqd_issue_type_id " +
                                                                    "FROM pqd_github_product_issues_history UNION ALL SELECT pqd_updated " +
                                                                    "AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_product_id, pqd_issue_type_id " +
                                                                    "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id = ? AND pqd_issue_type_id = ? " +
                                                                    "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_DAY_FILTER_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                   "(SELECT pqd_date, pqd_issues_count, pqd_product_id, pqd_severity_id " +
                                                                   "FROM pqd_github_product_issues_history UNION ALL SELECT pqd_updated " +
                                                                   "AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_product_id, pqd_severity_id " +
                                                                   "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id = ? AND pqd_severity_id = ? " +
                                                                   "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                             "(SELECT pqd_date, pqd_issues_count, pqd_product_id, pqd_severity_id, pqd_issue_type_id " +
                                                                             "FROM pqd_github_product_issues_history UNION ALL " +
                                                                             "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                             "AS pqd_issues_count, pqd_product_id, pqd_severity_id, pqd_issue_type_id " +
                                                                             "FROM pqd_jira_issues_history_by_product) AS gj " +
                                                                             "WHERE pqd_product_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? AND pqd_date " +
                                                                             "BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_MONTH = "SELECT year(pqd_date)year, month(pqd_date) as month, AVG(pqd_issues_count) as "+
                                                     "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                     "FROM (SELECT pqd_date, pqd_issues_count, pqd_product_id " +
                                                     "FROM pqd_github_product_issues_history UNION ALL " +
                                                     "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                     "AS pqd_issues_count, pqd_product_id " +
                                                     "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? AND "+
                                                     "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_MONTH_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                      "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                      "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                      "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id FROM "+
                                                                      "pqd_github_product_issues_history UNION ALL SELECT pqd_updated AS "+
                                                                      "pqd_date, pqd_issue_count AS pqd_issues_count,pqd_product_id,pqd_issue_type_id FROM "+
                                                                      "pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                      "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                      " pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_MONTH_FILTER_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                     "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                     "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id, " +
                                                                     "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                                     "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                     "AS pqd_issues_count,pqd_product_id,pqd_severity_id " +
                                                                     "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                     "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                     " pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                               "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                               "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                               "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                                               "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                                               "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                               "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                                               "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                               "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                               " pqd_date)AS T GROUP BY year,month";


const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_QUARTER = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, AVG(pqd_issues_count) as "+
                                                       "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                       "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                       "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                       "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                       "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                       "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? AND "+
                                                       "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                        "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                        "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                        "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                                        "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                                        "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                        "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                                        "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                        "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                        " pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_QUARTER_FILTER_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                       "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                       "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                       "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                                       "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                                       "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                       "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                                       "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                       "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                       " pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                                 "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                                 "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                                 "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                                                 "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                                                 "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                 "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                                                 "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                                 "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                                 " pqd_date)AS T GROUP BY year,quarter";


const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_YEAR = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as "+
                                                    "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                    "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                    "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                    "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                    "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                    "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? AND "+
                                                    "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_YEAR_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                     "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                     "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                                     "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                                     "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                     "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                                     "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                     "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                     " pqd_date)AS T GROUP BY year";

const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_YEAR_FILTER_SEVERITY = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                    "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                    "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                                    "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                                    "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                    "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                                    "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                    "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                    " pqd_date)AS T GROUP BY year";


const string GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                              "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                              "FROM (SELECT pqd_date, pqd_issues_count,pqd_product_id,pqd_issue_type_id, " +
                                                                              "pqd_severity_id FROM pqd_github_product_issues_history UNION ALL " +
                                                                              "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                              "AS pqd_issues_count,pqd_product_id,pqd_issue_type_id, pqd_severity_id " +
                                                                              "FROM pqd_jira_issues_history_by_product) AS gj WHERE pqd_product_id=? "+
                                                                              "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                              " pqd_date)AS T GROUP BY year";




const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_DAY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                      "(SELECT pqd_date, pqd_issues_count, pqd_component_id FROM pqd_github_component_issues_history " +
                                                      "UNION ALL SELECT pqd_updated AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_component_id " +
                                                      "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id = ? AND pqd_date " +
                                                      "BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_DAY_FILTER_ISSUETYPE = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                       "(SELECT pqd_date, pqd_issues_count, pqd_component_id, pqd_issue_type_id " +
                                                                       "FROM pqd_github_component_issues_history UNION ALL SELECT pqd_updated " +
                                                                       "AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_component_id, pqd_issue_type_id " +
                                                                       "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id = ? AND pqd_issue_type_id = ? " +
                                                                       "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_DAY_FILTER_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                      "(SELECT pqd_date, pqd_issues_count, pqd_component_id, pqd_severity_id " +
                                                                      "FROM pqd_github_component_issues_history UNION ALL SELECT pqd_updated " +
                                                                      "AS pqd_date, pqd_issue_count AS pqd_issues_count, pqd_component_id, pqd_severity_id " +
                                                                      "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id = ? AND pqd_severity_id = ? " +
                                                                      "AND pqd_date BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY = "SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count FROM " +
                                                                                "(SELECT pqd_date, pqd_issues_count, pqd_component_id, pqd_severity_id, pqd_issue_type_id " +
                                                                                "FROM pqd_github_component_issues_history UNION ALL " +
                                                                                "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                "AS pqd_issues_count, pqd_component_id, pqd_severity_id, pqd_issue_type_id " +
                                                                                "FROM pqd_jira_issues_history_by_component) AS gj " +
                                                                                "WHERE pqd_component_id = ? AND pqd_issue_type_id = ? AND pqd_severity_id = ? AND pqd_date " +
                                                                                "BETWEEN ? AND ? GROUP BY pqd_date";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_MONTH = "SELECT year(pqd_date)year, month(pqd_date) as month, AVG(pqd_issues_count) as "+
                                                        "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                        "FROM (SELECT pqd_date, pqd_issues_count, pqd_component_id " +
                                                        "FROM pqd_github_component_issues_history UNION ALL " +
                                                        "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                        "AS pqd_issues_count, pqd_component_id " +
                                                        "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? AND "+
                                                        "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_MONTH_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                         "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                         "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                         "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id FROM "+
                                                                         "pqd_github_component_issues_history UNION ALL SELECT pqd_updated AS "+
                                                                         "pqd_date, pqd_issue_count AS pqd_issues_count,pqd_component_id,pqd_issue_type_id FROM "+
                                                                         "pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                         "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                         " pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_MONTH_FILTER_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                        "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                        "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                        "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id, " +
                                                                        "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                                        "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                        "AS pqd_issues_count,pqd_component_id,pqd_severity_id " +
                                                                        "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                        "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                        " pqd_date)AS T GROUP BY year,month";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, month(pqd_date) as month,"+
                                                                                  "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                                  "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                                  "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                                                  "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                                                  "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                  "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                                                  "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                                  "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                                  " pqd_date)AS T GROUP BY year,month";


const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_QUARTER = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter, AVG(pqd_issues_count) as "+
                                                          "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                          "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                          "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                          "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                          "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                          "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? AND "+
                                                          "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                           "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                           "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                           "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                                           "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                                           "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                           "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                                           "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                           "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                           " pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_QUARTER_FILTER_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                          "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                          "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                          "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                                          "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                                          "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                          "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                                          "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                          "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                          " pqd_date)AS T GROUP BY year,quarter";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year, quarter(pqd_date) as quarter,"+
                                                                                    "AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                                    "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                                    "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                                                    "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                                                    "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                    "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                                                    "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                                    "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                                    " pqd_date)AS T GROUP BY year,quarter";


const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_YEAR = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as "+
                                                       "pqd_issues_count FROM (SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                       "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                       "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                       "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                       "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                       "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? AND "+
                                                       "pqd_date BETWEEN ? AND ? GROUP BY pqd_date)AS T GROUP BY year";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_YEAR_FILTER_ISSUETYPE = "SELECT year(pqd_date)year, AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                        "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                        "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                                        "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                                        "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                        "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                                        "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                        "AND pqd_issue_type_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                        " pqd_date)AS T GROUP BY year";

const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_YEAR_FILTER_SEVERITY = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                       "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                       "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                                       "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                                       "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                       "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                                       "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                       "AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                       " pqd_date)AS T GROUP BY year";


const string GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY = "SELECT year(pqd_date)year,AVG(pqd_issues_count) as pqd_issues_count FROM "+
                                                                                 "(SELECT pqd_date,SUM(pqd_issues_count) as pqd_issues_count "+
                                                                                 "FROM (SELECT pqd_date, pqd_issues_count,pqd_component_id,pqd_issue_type_id, " +
                                                                                 "pqd_severity_id FROM pqd_github_component_issues_history UNION ALL " +
                                                                                 "SELECT pqd_updated AS pqd_date, pqd_issue_count " +
                                                                                 "AS pqd_issues_count,pqd_component_id,pqd_issue_type_id, pqd_severity_id " +
                                                                                 "FROM pqd_jira_issues_history_by_component) AS gj WHERE pqd_component_id=? "+
                                                                                 "AND pqd_issue_type_id=? AND pqd_severity_id=? AND pqd_date BETWEEN ? AND ? GROUP BY"+
                                                                                 " pqd_date)AS T GROUP BY year";


const string GET_GITHUB_JIRA_ALL_AREAS_AREA_CURRENT_ISSUES_QUERY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, SUM(gj.pqd_issues_count) " +
                                                                   "AS pqd_issues_count FROM pqd_area INNER JOIN " +
                                                                   "(SELECT pqd_area_id, pqd_issues_count FROM pqd_area_issues " +
                                                                   "UNION ALL SELECT pqd_area_id, pqd_issue_count AS pqd_issues_count " +
                                                                   "FROM pqd_jira_issues_by_product) AS gj WHERE " +
                                                                   "pqd_area.pqd_area_id = gj.pqd_area_id GROUP BY pqd_area_id";

const string GET_GITHUB_JIRA_ALL_AREAS_ISSUETYPE_CURRENT_ISSUES_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                        "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                        "INNER JOIN (SELECT pqd_issue_type_id, pqd_issues_count FROM pqd_area_issues " +
                                                                        "UNION ALL SELECT pqd_issue_type_id, pqd_issue_count AS pqd_issues_count " +
                                                                        "FROM pqd_jira_issues_by_product) AS gj WHERE pqd_issue_type.pqd_issue_type_id = gj.pqd_issue_type_id " +
                                                                        "GROUP BY pqd_issue_type_id";

const string GET_GITHUB_JIRA_ALL_AREAS_SEVERITY_CURRENT_ISSUES_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                                       "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                                       "INNER JOIN (SELECT pqd_severity_id, pqd_issues_count FROM pqd_area_issues " +
                                                                       "UNION ALL SELECT pqd_severity_id, pqd_issue_count AS pqd_issues_count " +
                                                                       "FROM pqd_jira_issues_by_product) AS gj WHERE pqd_severity.pqd_severity_id = gj.pqd_severity_id " +
                                                                       "GROUP BY pqd_severity_id";


const string GET_GITHUB_JIRA_ALL_AREAS_AREA_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, " +
                                                                                       "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM " +
                                                                                       "pqd_area INNER JOIN (SELECT pqd_area_id, pqd_issues_count, " +
                                                                                       "pqd_issue_type_id FROM pqd_area_issues UNION ALL SELECT pqd_area_id, pqd_issue_count " +
                                                                                       "AS pqd_issues_count, pqd_issue_type_id FROM pqd_jira_issues_by_product) AS gj " +
                                                                                       "WHERE pqd_area.pqd_area_id = gj.pqd_area_id AND gj.pqd_issue_type_id = ? GROUP BY pqd_area_id";

const string GET_GITHUB_JIRA_ALL_AREAS_SEVERITY_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                                                           "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                                                           "INNER JOIN (SELECT pqd_severity_id, pqd_issues_count, pqd_issue_type_id " +
                                                                                           "FROM pqd_area_issues UNION ALL SELECT pqd_severity_id, pqd_issue_count " +
                                                                                           "AS pqd_issues_count, pqd_issue_type_id FROM pqd_jira_issues_by_product) " +
                                                                                           "AS gj WHERE pqd_severity.pqd_severity_id = gj.pqd_severity_id " +
                                                                                           "AND gj.pqd_issue_type_id = ? GROUP BY pqd_severity_id";

const string GET_GITHUB_JIRA_ALL_AREAS_AREA_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, " +
                                                                                      "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM " +
                                                                                      "pqd_area INNER JOIN (SELECT pqd_area_id, pqd_issues_count, " +
                                                                                      "pqd_severity_id FROM pqd_area_issues UNION ALL SELECT pqd_area_id, pqd_issue_count " +
                                                                                      "AS pqd_issues_count, pqd_severity_id FROM pqd_jira_issues_by_product) AS gj " +
                                                                                      "WHERE pqd_area.pqd_area_id = gj.pqd_area_id AND gj.pqd_severity_id = ? GROUP BY pqd_area_id";

const string GET_GITHUB_JIRA_ALL_AREAS_ISSUETYPE_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                                           "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                                           "INNER JOIN (SELECT pqd_issue_type_id, pqd_issues_count, pqd_severity_id " +
                                                                                           "FROM pqd_area_issues UNION ALL SELECT pqd_issue_type_id, pqd_issue_count " +
                                                                                           "AS pqd_issues_count, pqd_severity_id FROM pqd_jira_issues_by_product) " +
                                                                                           "AS gj WHERE pqd_issue_type.pqd_issue_type_id = gj.pqd_issue_type_id " +
                                                                                           "AND gj.pqd_severity_id = ? GROUP BY pqd_issue_type_id";

const string GET_GITHUB_JIRA_ALL_AREAS_AREA_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_SEVERITY = "SELECT pqd_area.pqd_area_id, pqd_area.pqd_area_name, " +
                                                                                          "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM " +
                                                                                          "pqd_area INNER JOIN (SELECT pqd_area_id, pqd_issues_count, " +
                                                                                          "pqd_issue_type_id, pqd_severity_id FROM pqd_area_issues UNION ALL SELECT pqd_area_id, pqd_issue_count " +
                                                                                          "AS pqd_issues_count, pqd_issue_type_id, pqd_severity_id FROM pqd_jira_issues_by_product) AS gj " +
                                                                                          "WHERE pqd_area.pqd_area_id = gj.pqd_area_id AND gj.pqd_issue_type_id = ? " +
                                                                                          "AND gj.pqd_severity_id = ? GROUP BY pqd_area_id";


const string GET_GITHUB_JIRA_AREA_PRODUCT_CURRENT_ISSUES_QUERY = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                                                 "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_product " +
                                                                 "INNER JOIN (SELECT pqd_product_id, pqd_issues_count " +
                                                                 "FROM pqd_product_issues UNION ALL SELECT pqd_product_id, pqd_issue_count " +
                                                                 "AS pqd_issues_count FROM pqd_jira_issues_by_product) " +
                                                                 "AS gj WHERE pqd_product.pqd_product_id = gj.pqd_product_id " +
                                                                 "AND pqd_product.pqd_area_id = ? GROUP BY pqd_product_id";

const string GET_GITHUB_JIRA_AREA_ISSUETYPE_CURRENT_ISSUES_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                   "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                   "INNER JOIN (SELECT pqd_issue_type_id, pqd_issues_count, pqd_area_id " +
                                                                   "FROM pqd_area_issues UNION ALL SELECT pqd_issue_type_id, pqd_issue_count " +
                                                                   "AS pqd_issues_count, pqd_area_id FROM pqd_jira_issues_by_product) " +
                                                                   "AS gj WHERE pqd_issue_type.pqd_issue_type_id = gj.pqd_issue_type_id " +
                                                                   "AND gj.pqd_area_id = ? GROUP BY pqd_issue_type_id";

const string GET_GITHUB_JIRA_AREA_SEVERITY_CURRENT_ISSUES_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                                  "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                                  "INNER JOIN (SELECT pqd_severity_id, pqd_issues_count, pqd_area_id " +
                                                                  "FROM pqd_area_issues UNION ALL SELECT pqd_severity_id, pqd_issue_count " +
                                                                  "AS pqd_issues_count, pqd_area_id FROM pqd_jira_issues_by_product) " +
                                                                  "AS gj WHERE pqd_severity.pqd_severity_id = gj.pqd_severity_id " +
                                                                  "AND gj.pqd_area_id = ? GROUP BY pqd_severity_id";


const string GET_GITHUB_JIRA_AREA_PRODUCT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                                                                     "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_product " +
                                                                                     "INNER JOIN (SELECT pqd_product_id, pqd_issues_count, pqd_issue_type_id " +
                                                                                     "FROM pqd_product_issues UNION ALL SELECT pqd_product_id, pqd_issue_count " +
                                                                                     "AS pqd_issues_count, pqd_issue_type_id FROM pqd_jira_issues_by_product) " +
                                                                                     "AS gj WHERE pqd_product.pqd_product_id = gj.pqd_product_id " +
                                                                                     "AND pqd_product.pqd_area_id = ? AND gj.pqd_issue_type_id = ? GROUP BY pqd_product_id";

const string GET_GITHUB_JIRA_AREA_SEVERITY_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                                                      "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                                                      "INNER JOIN (SELECT pqd_severity_id, pqd_issues_count, pqd_area_id, pqd_issue_type_id " +
                                                                                      "FROM pqd_area_issues UNION ALL SELECT pqd_severity_id, pqd_issue_count " +
                                                                                      "AS pqd_issues_count, pqd_area_id, pqd_issue_type_id FROM pqd_jira_issues_by_product) " +
                                                                                      "AS gj WHERE pqd_severity.pqd_severity_id = gj.pqd_severity_id " +
                                                                                      "AND gj.pqd_area_id = ? AND gj.pqd_issue_type_id = ? GROUP BY pqd_severity_id";

const string GET_GITHUB_JIRA_AREA_PRODUCT_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                                                                    "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_product " +
                                                                                    "INNER JOIN (SELECT pqd_product_id, pqd_issues_count, pqd_severity_id " +
                                                                                    "FROM pqd_product_issues UNION ALL SELECT pqd_product_id, pqd_issue_count " +
                                                                                    "AS pqd_issues_count, pqd_severity_id FROM pqd_jira_issues_by_product) " +
                                                                                    "AS gj WHERE pqd_product.pqd_product_id = gj.pqd_product_id " +
                                                                                    "AND pqd_product.pqd_area_id = ? AND gj.pqd_severity_id = ? GROUP BY pqd_product_id";

const string GET_GITHUB_JIRA_AREA_ISSUETYPE_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                                      "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                                      "INNER JOIN (SELECT pqd_issue_type_id, pqd_issues_count, pqd_area_id, pqd_severity_id " +
                                                                                      "FROM pqd_area_issues UNION ALL SELECT pqd_issue_type_id, pqd_issue_count " +
                                                                                      "AS pqd_issues_count, pqd_area_id, pqd_severity_id FROM pqd_jira_issues_by_product) " +
                                                                                      "AS gj WHERE pqd_issue_type.pqd_issue_type_id = gj.pqd_issue_type_id " +
                                                                                      "AND gj.pqd_area_id = ? AND gj.pqd_severity_id = ? GROUP BY pqd_issue_type_id";

const string GET_GITHUB_JIRA_AREA_PRODUCT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_SEVERITY = "SELECT pqd_product.pqd_product_id, pqd_product.pqd_product_name, " +
                                                                                        "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_product " +
                                                                                        "INNER JOIN (SELECT pqd_product_id, pqd_issues_count, pqd_issue_type_id, pqd_severity_id " +
                                                                                        "FROM pqd_product_issues UNION ALL SELECT pqd_product_id, pqd_issue_count " +
                                                                                        "AS pqd_issues_count, pqd_issue_type_id, pqd_severity_id FROM pqd_jira_issues_by_product) " +
                                                                                        "AS gj WHERE pqd_product.pqd_product_id = gj.pqd_product_id " +
                                                                                        "AND pqd_product.pqd_area_id = ? AND gj.pqd_issue_type_id = ? AND gj.pqd_severity_id = ? GROUP BY pqd_product_id";



const string GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_QUERY = "SELECT pqd_component.pqd_component_id, pqd_component.pqd_component_name, " +
                                                                      "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_component " +
                                                                      "INNER JOIN (SELECT pqd_component_id, pqd_issues_count " +
                                                                      "FROM pqd_component_issues UNION ALL SELECT pqd_component_id, pqd_issue_count " +
                                                                      "AS pqd_issues_count FROM pqd_jira_issues_by_component) " +
                                                                      "AS gj WHERE pqd_component.pqd_component_id = gj.pqd_component_id " +
                                                                      "AND pqd_component.pqd_product_id = ? GROUP BY pqd_component_id";

const string GET_GITHUB_JIRA_PRODUCT_ISSUETYPE_CURRENT_ISSUES_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                      "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                      "INNER JOIN (SELECT pqd_issue_type_id, pqd_issues_count, pqd_product_id " +
                                                                      "FROM pqd_product_issues UNION ALL SELECT pqd_issue_type_id, pqd_issue_count " +
                                                                      "AS pqd_issues_count, pqd_product_id FROM pqd_jira_issues_by_product) " +
                                                                      "AS gj WHERE pqd_issue_type.pqd_issue_type_id = gj.pqd_issue_type_id " +
                                                                      "AND gj.pqd_product_id = ? GROUP BY pqd_issue_type_id";

const string GET_GITHUB_JIRA_PRODUCT_SEVERITY_CURRENT_ISSUES_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                                     "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                                     "INNER JOIN (SELECT pqd_severity_id, pqd_issues_count, pqd_product_id " +
                                                                     "FROM pqd_product_issues UNION ALL SELECT pqd_severity_id, pqd_issue_count " +
                                                                     "AS pqd_issues_count, pqd_product_id FROM pqd_jira_issues_by_product) " +
                                                                     "AS gj WHERE pqd_severity.pqd_severity_id = gj.pqd_severity_id " +
                                                                     "AND gj.pqd_product_id = ? GROUP BY pqd_severity_id";


const string GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY = "SELECT pqd_component.pqd_component_id, pqd_component.pqd_component_name, " +
                                                                                          "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_component " +
                                                                                          "INNER JOIN (SELECT pqd_component_id, pqd_issues_count, pqd_issue_type_id " +
                                                                                          "FROM pqd_component_issues UNION ALL SELECT pqd_component_id, pqd_issue_count " +
                                                                                          "AS pqd_issues_count, pqd_issue_type_id FROM pqd_jira_issues_by_component) " +
                                                                                          "AS gj WHERE pqd_component.pqd_component_id = gj.pqd_component_id " +
                                                                                          "AND pqd_component.pqd_product_id = ? AND gj.pqd_issue_type_id = ? GROUP BY pqd_component_id";

const string GET_GITHUB_JIRA_PRODUCT_SEVERITY_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                                                         "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                                                         "INNER JOIN (SELECT pqd_severity_id, pqd_issues_count, pqd_product_id, pqd_issue_type_id " +
                                                                                         "FROM pqd_product_issues UNION ALL SELECT pqd_severity_id, pqd_issue_count " +
                                                                                         "AS pqd_issues_count, pqd_product_id, pqd_issue_type_id FROM pqd_jira_issues_by_product) " +
                                                                                         "AS gj WHERE pqd_severity.pqd_severity_id = gj.pqd_severity_id " +
                                                                                         "AND gj.pqd_product_id = ? AND gj.pqd_issue_type_id = ? GROUP BY pqd_severity_id";

const string GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY = "SELECT pqd_component.pqd_component_id, pqd_component.pqd_component_name, " +
                                                                                         "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_component " +
                                                                                         "INNER JOIN (SELECT pqd_component_id, pqd_issues_count, pqd_severity_id " +
                                                                                         "FROM pqd_component_issues UNION ALL SELECT pqd_component_id, pqd_issue_count " +
                                                                                         "AS pqd_issues_count, pqd_severity_id FROM pqd_jira_issues_by_component) " +
                                                                                         "AS gj WHERE pqd_component.pqd_component_id = gj.pqd_component_id " +
                                                                                         "AND pqd_component.pqd_product_id = ? AND gj.pqd_severity_id = ? GROUP BY pqd_component_id";

const string GET_GITHUB_JIRA_PRODUCT_ISSUETYPE_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                                         "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                                         "INNER JOIN (SELECT pqd_issue_type_id, pqd_issues_count, pqd_product_id, pqd_severity_id " +
                                                                                         "FROM pqd_product_issues UNION ALL SELECT pqd_issue_type_id, pqd_issue_count " +
                                                                                         "AS pqd_issues_count, pqd_product_id, pqd_severity_id FROM pqd_jira_issues_by_product) " +
                                                                                         "AS gj WHERE pqd_issue_type.pqd_issue_type_id = gj.pqd_issue_type_id " +
                                                                                         "AND gj.pqd_product_id = ? AND gj.pqd_severity_id = ? GROUP BY pqd_issue_type_id";

const string GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_SEVERITY = "SELECT pqd_component.pqd_component_id, pqd_component.pqd_component_name, " +
                                                                                             "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_component " +
                                                                                             "INNER JOIN (SELECT pqd_component_id, pqd_issues_count, pqd_issue_type_id, pqd_severity_id " +
                                                                                             "FROM pqd_component_issues UNION ALL SELECT pqd_component_id, pqd_issue_count " +
                                                                                             "AS pqd_issues_count, pqd_issue_type_id, pqd_severity_id FROM pqd_jira_issues_by_component) " +
                                                                                             "AS gj WHERE pqd_component.pqd_component_id = gj.pqd_component_id " +
                                                                                             "AND pqd_component.pqd_product_id = ? AND gj.pqd_issue_type_id = ? AND gj.pqd_severity_id = ? GROUP BY pqd_component_id";



const string GET_GITHUB_JIRA_COMPONENT_ISSUETYPE_CURRENT_ISSUES_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                        "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                        "INNER JOIN (SELECT pqd_issue_type_id, pqd_issues_count, pqd_component_id " +
                                                                        "FROM pqd_component_issues UNION ALL SELECT pqd_issue_type_id, pqd_issue_count " +
                                                                        "AS pqd_issues_count, pqd_component_id FROM pqd_jira_issues_by_component) " +
                                                                        "AS gj WHERE pqd_issue_type.pqd_issue_type_id = gj.pqd_issue_type_id " +
                                                                        "AND gj.pqd_component_id = ? GROUP BY pqd_issue_type_id";

const string GET_GITHUB_JIRA_COMPONENT_SEVERITY_CURRENT_ISSUES_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                                       "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                                       "INNER JOIN (SELECT pqd_severity_id, pqd_issues_count, pqd_component_id " +
                                                                       "FROM pqd_component_issues UNION ALL SELECT pqd_severity_id, pqd_issue_count " +
                                                                       "AS pqd_issues_count, pqd_component_id FROM pqd_jira_issues_by_component) " +
                                                                       "AS gj WHERE pqd_severity.pqd_severity_id = gj.pqd_severity_id " +
                                                                       "AND gj.pqd_component_id = ? GROUP BY pqd_severity_id";

const string GET_GITHUB_JIRA_COMPONENT_SEVERITY_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY = "SELECT pqd_severity.pqd_severity_id, pqd_severity.pqd_severity, " +
                                                                                           "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_severity " +
                                                                                           "INNER JOIN (SELECT pqd_severity_id, pqd_issues_count, pqd_component_id, pqd_issue_type_id " +
                                                                                           "FROM pqd_component_issues UNION ALL SELECT pqd_severity_id, pqd_issue_count " +
                                                                                           "AS pqd_issues_count, pqd_component_id, pqd_issue_type_id FROM pqd_jira_issues_by_component) " +
                                                                                           "AS gj WHERE pqd_severity.pqd_severity_id = gj.pqd_severity_id " +
                                                                                           "AND gj.pqd_component_id = ? AND gj.pqd_issue_type_id = ? GROUP BY pqd_severity_id";

const string GET_GITHUB_JIRA_COMPONENT_ISSUETYPE_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY = "SELECT pqd_issue_type.pqd_issue_type_id, pqd_issue_type.pqd_issue_type, " +
                                                                                           "SUM(gj.pqd_issues_count) AS pqd_issues_count FROM pqd_issue_type " +
                                                                                           "INNER JOIN (SELECT pqd_issue_type_id, pqd_issues_count, pqd_component_id, pqd_severity_id " +
                                                                                           "FROM pqd_component_issues UNION ALL SELECT pqd_issue_type_id, pqd_issue_count " +
                                                                                           "AS pqd_issues_count, pqd_component_id, pqd_severity_id FROM pqd_jira_issues_by_component) " +
                                                                                           "AS gj WHERE pqd_issue_type.pqd_issue_type_id = gj.pqd_issue_type_id " +
                                                                                           "AND gj.pqd_component_id = ? AND gj.pqd_severity_id = ? GROUP BY pqd_issue_type_id";