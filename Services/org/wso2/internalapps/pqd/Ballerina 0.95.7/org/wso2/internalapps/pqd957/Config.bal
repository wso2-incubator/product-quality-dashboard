package org.wso2.internalapps.pqd957;

const string CONFIG_PATH = "config.json";


const string GET_ALL_AREAS="SELECT * FROM pqd_area";

const string GET_PRODUCTS_OF_AREA="SELECT pqd_product_id,pqd_product_name FROM pqd_product WHERE pqd_area_id=?";



const string GET_COMPONENT_OF_AREA="SELECT pqd_component_id,pqd_component_name,pqd_product_id,sonar_project_key FROM pqd_component" +
                                   " WHERE pqd_area_id=?";

const string GET_COMPONENT_OF_PRODUCT="SELECT pqd_component_id,pqd_component_name,pqd_product_id,sonar_project_key FROM pqd_component" +
                                      " WHERE pqd_product_id=?";

const string GET_DETAILS_OF_COMPONENT = "SELECT pqd_component_id,pqd_component_name,pqd_product_id,sonar_project_key FROM pqd_component " +
                                        "WHERE pqd_component_id=?";



const string GET_LINE_COVERAGE_DETAILS="SELECT lines_to_cover,covered_lines,uncovered_lines,line_coverage FROM "+
                                       "live_line_coverage where component_name=? and component_id=?";

const string GET_ALL_AREA_DAILY_LINE_COVERAGE="SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines) as "
                                              +"covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                              "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage FROM "+
                                              "line_coverage_history as a INNER JOIN pqd_component as b "+
                                              "ON a.component_name=b.pqd_component_name where date between ? and ? group by date";

const string GET_ALL_AREA_MONTHLY_LINE_COVERAGE="SELECT year(date) as year,month(date) as month,AVG(lines_to_cover) as "+
                                                "lines_to_cover,AVG(covered_lines) as covered_lines,AVG(uncovered_lines) "+
                                                "as uncovered_lines,(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                                "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines) "+
                                                "as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                                "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                                "FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                                "ON a.component_name=b.pqd_component_name where date between ? and ? "+
                                                "group by date) as T group by year,month";

const string GET_ALL_AREA_QUARTERLY_LINE_COVERAGE="SELECT year(date) as year,quarter(date) as quarter,AVG(lines_to_cover) as "+
                                                  "lines_to_cover,AVG(covered_lines) as covered_lines,AVG(uncovered_lines) "+
                                                  "as uncovered_lines,(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                                  "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines) "+
                                                  "as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                                  "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                                  "FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                                  "ON a.component_name=b.pqd_component_name where date between ? and ? "+
                                                  "group by date) as T group by year,quarter";

const string GET_ALL_AREA_YEARLY_LINE_COVERAGE="SELECT year(date) as year,AVG(lines_to_cover) as "+
                                               "lines_to_cover,AVG(covered_lines) as covered_lines,AVG(uncovered_lines) "+
                                               "as uncovered_lines,(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                               "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines) "+
                                               "as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                               "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                               "FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                               "ON a.component_name=b.pqd_component_name where date between ? and ? "+
                                               "group by date) as T group by year";

const string GET_SELECTED_AREA_DAILY_LINE_COVERAGE="SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines)"+
                                                   " as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                                   "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                                   "FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                                   "ON a.component_name=b.pqd_component_name where pqd_area_id=? "+
                                                   "and date between ? and ? group by date";

const string GET_SELECTED_AREA_MONTHLY_LINE_COVERAGE="SELECT year(date) as year,month(date) as month,"+
                                                     "AVG(lines_to_cover) as lines_to_cover,AVG(covered_lines) as covered_lines,"+
                                                     "AVG(uncovered_lines) as uncovered_lines,"+
                                                     "(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                                     "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,"+
                                                     "SUM(covered_lines) as covered_lines,SUM(uncovered_lines) "+
                                                     "as uncovered_lines,(SUM(covered_lines)/SUM(lines_to_cover))*100 as "+
                                                     "line_coverage FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                                     "ON a.component_name=b.pqd_component_name where pqd_area_id=? "+
                                                     "and date between ? and ? group by date) as T group by year,month";

const string GET_SELECTED_AREA_QUARTERLY_LINE_COVERAGE="SELECT year(date) as year,quarter(date) as quarter,"+
                                                       "AVG(lines_to_cover) as lines_to_cover,"+
                                                       "AVG(covered_lines) as covered_lines,AVG(uncovered_lines) as "+
                                                       "uncovered_lines,(AVG(covered_lines)/AVG(lines_to_cover))*100 as "+
                                                       "line_coverage FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,"+
                                                       "SUM(covered_lines) as covered_lines,SUM(uncovered_lines) as "+
                                                       "uncovered_lines,(SUM(covered_lines)/SUM(lines_to_cover))*100 as "+
                                                       "line_coverage FROM line_coverage_history as a INNER JOIN pqd_component "+
                                                       "as b ON a.component_name=b.pqd_component_name where "+
                                                       "pqd_area_id=? and date between ? and ? group by date) as "+
                                                       "T group by year,quarter";

const string GET_SELECTED_AREA_YEARLY_LINE_COVERAGE="SELECT year(date) as year,AVG(lines_to_cover) as "+
                                                    "lines_to_cover,AVG(covered_lines) as covered_lines,"+
                                                    "AVG(uncovered_lines) as uncovered_lines,"+
                                                    "(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                                    "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines) "+
                                                    "as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                                    "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                                    "FROM line_coverage_history as a INNER JOIN pqd_component as b ON "+
                                                    "a.component_name=b.pqd_component_name where pqd_area_id=?"+
                                                    " and date between ? and ? group by date) as T group by year";

const string GET_SELECTED_PRODUCT_DAILY_LINE_COVERAGE="SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines)"+
                                                      " as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                                      "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                                      "FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                                      "ON a.component_name=b.pqd_component_name where pqd_product_id=? "+
                                                      "and date between ? and ? group by date";

const string GET_SELECTED_PRODUCT_MONTHLY_LINE_COVERAGE="SELECT year(date) as year,month(date) as month,"+
                                                        "AVG(lines_to_cover) as lines_to_cover,AVG(covered_lines) as covered_lines,"+
                                                        "AVG(uncovered_lines) as uncovered_lines,"+
                                                        "(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                                        "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,"+
                                                        "SUM(covered_lines) as covered_lines,SUM(uncovered_lines) "+
                                                        "as uncovered_lines,(SUM(covered_lines)/SUM(lines_to_cover))*100 as "+
                                                        "line_coverage FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                                        "ON a.component_name=b.pqd_component_name where pqd_product_id=? "+
                                                        "and date between ? and ? group by date) as T group by year,month";

const string GET_SELECTED_PRODUCT_QUARTERLY_LINE_COVERAGE="SELECT year(date) as year,quarter(date) as quarter,"+
                                                          "AVG(lines_to_cover) as lines_to_cover,"+
                                                          "AVG(covered_lines) as covered_lines,AVG(uncovered_lines) as "+
                                                          "uncovered_lines,(AVG(covered_lines)/AVG(lines_to_cover))*100 as "+
                                                          "line_coverage FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,"+
                                                          "SUM(covered_lines) as covered_lines,SUM(uncovered_lines) as "+
                                                          "uncovered_lines,(SUM(covered_lines)/SUM(lines_to_cover))*100 as "+
                                                          "line_coverage FROM line_coverage_history as a INNER JOIN pqd_component "+
                                                          "as b ON a.component_name=b.pqd_component_name where "+
                                                          "pqd_product_id=? and date between ? and ? group by date) as "+
                                                          "T group by year,quarter";

const string GET_SELECTED_PRODUCT_YEARLY_LINE_COVERAGE="SELECT year(date) as year,AVG(lines_to_cover) as "+
                                                       "lines_to_cover,AVG(covered_lines) as covered_lines,"+
                                                       "AVG(uncovered_lines) as uncovered_lines,"+
                                                       "(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                                       "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines) "+
                                                       "as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                                       "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                                       "FROM line_coverage_history as a INNER JOIN pqd_component as b ON "+
                                                       "a.component_name=b.pqd_component_name where pqd_product_id=?"+
                                                       " and date between ? and ? group by date) as T group by year";

const string GET_SELECTED_COMPONENT_DAILY_LINE_COVERAGE="SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines)"+
                                                        " as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                                        "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                                        "FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                                        "ON a.component_name=b.pqd_component_name where pqd_component_id=? "+
                                                        "and date between ? and ? group by date";

const string GET_SELECTED_COMPONENT_MONTHLY_LINE_COVERAGE="SELECT year(date) as year,month(date) as month,"+
                                                          "AVG(lines_to_cover) as lines_to_cover,AVG(covered_lines) as covered_lines,"+
                                                          "AVG(uncovered_lines) as uncovered_lines,"+
                                                          "(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                                          "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,"+
                                                          "SUM(covered_lines) as covered_lines,SUM(uncovered_lines) "+
                                                          "as uncovered_lines,(SUM(covered_lines)/SUM(lines_to_cover))*100 as "+
                                                          "line_coverage FROM line_coverage_history as a INNER JOIN pqd_component as b "+
                                                          "ON a.component_name=b.pqd_component_name where pqd_component_id=? "+
                                                          "and date between ? and ? group by date) as T group by year,month";

const string GET_SELECTED_COMPONENT_QUARTERLY_LINE_COVERAGE="SELECT year(date) as year,quarter(date) as quarter,"+
                                                            "AVG(lines_to_cover) as lines_to_cover,"+
                                                            "AVG(covered_lines) as covered_lines,AVG(uncovered_lines) as "+
                                                            "uncovered_lines,(AVG(covered_lines)/AVG(lines_to_cover))*100 as "+
                                                            "line_coverage FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,"+
                                                            "SUM(covered_lines) as covered_lines,SUM(uncovered_lines) as "+
                                                            "uncovered_lines,(SUM(covered_lines)/SUM(lines_to_cover))*100 as "+
                                                            "line_coverage FROM line_coverage_history as a INNER JOIN pqd_component "+
                                                            "as b ON a.component_name=b.pqd_component_name where "+
                                                            "pqd_component_id=? and date between ? and ? group by date) as "+
                                                            "T group by year,quarter";

const string GET_SELECTED_COMPONENT_YEARLY_LINE_COVERAGE="SELECT year(date) as year,AVG(lines_to_cover) as "+
                                                         "lines_to_cover,AVG(covered_lines) as covered_lines,"+
                                                         "AVG(uncovered_lines) as uncovered_lines,"+
                                                         "(AVG(covered_lines)/AVG(lines_to_cover))*100 as line_coverage "+
                                                         "FROM(SELECT date,SUM(lines_to_cover) as lines_to_cover,SUM(covered_lines) "+
                                                         "as covered_lines,SUM(uncovered_lines) as uncovered_lines,"+
                                                         "(SUM(covered_lines)/SUM(lines_to_cover))*100 as line_coverage "+
                                                         "FROM line_coverage_history as a INNER JOIN pqd_component as b ON "+
                                                         "a.component_name=b.pqd_component_name where pqd_component_id=?"+
                                                         " and date between ? and ? group by date) as T group by year";

const string GET_FUNCCOVERAGE_SNAPSHOT_ID="SELECT snapshot_id FROM functional_coverage_snapshot ORDER BY snapshot_id DESC LIMIT 1";

const string GET_TESTLINKPRODUCT_OF_AREA ="SELECT pqd_product_id,pqd_product_name,testlink_project_name FROM pqd_product WHERE pqd_area_id=?";

const string GET_TESTLINKPRODUCT_OF_PRODUCT ="SELECT pqd_product_id,pqd_product_name,testlink_project_name FROM pqd_product WHERE pqd_product_id=?";

const string GET_FUNC_COVERAGE_DETAILS="SELECT project_name,test_plan_name,total_features,passed_features,failed_features,blocked_features,not_run_features,"+
                                       "functional_coverage FROM daily_functional_coverage WHERE project_name=? and snapshot_id=?";

const string GET_ALL_AREA_DAILY_FUNC_COVERAGE="SELECT date,SUM(total_features) as total_features,SUM(passed_features) as passed_features"+
                                              ",(SUM(passed_features)/SUM(total_features))*100 as functional_coverage FROM daily_functional_coverage"+
                                              " as a INNER JOIN pqd_product as b ON a.project_name=b.testlink_project_name "+
                                              "where date between ? and ? group by date";

const string GET_ALL_AREA_MONTHLY_FUNC_COVERAGE="SELECT year(date) as year,month(date) as month,AVG(total_features) as total_features,"+
                                                "AVG(passed_features) as passed_features,(AVG(passed_features)/AVG(total_features))*100 "+
                                                "as functional_coverage FROM(SELECT date,SUM(total_features) as total_features,"+
                                                "SUM(passed_features) as passed_features,(SUM(passed_features)/SUM(total_features))*100 "+
                                                "as functional_coverage FROM daily_functional_coverage as a INNER JOIN pqd_product as "+
                                                "b ON a.project_name=b.testlink_project_name where date between ? and ? group by date)"+
                                                " as T group by year,month";

const string GET_ALL_AREA_QUARTERLY_FUNC_COVERAGE="SELECT year(date) as year,quarter(date) as quarter,AVG(total_features) as total_features"+
                                                  ",AVG(passed_features) as passed_features,(AVG(passed_features)/AVG(total_features))*100"+
                                                  " as functional_coverage FROM(SELECT date,SUM(total_features) as total_features,"+
                                                  "SUM(passed_features) as passed_features,(SUM(passed_features)/SUM(total_features))*100"+
                                                  " as functional_coverage FROM daily_functional_coverage as a INNER JOIN pqd_product "+
                                                  "as b ON a.project_name=b.testlink_project_name where date between ? and ? group by date) "+
                                                  "as T group by year,quarter";

const string GET_ALL_AREA_YEARLY_FUNC_COVERAGE="SELECT year(date) as year,AVG(total_features) as total_features,AVG(passed_features) as "+
                                               "passed_features,(AVG(passed_features)/AVG(total_features))*100 as functional_coverage FROM"+
                                               "(SELECT date,SUM(total_features) as total_features,SUM(passed_features) as passed_features,"+
                                               "(SUM(passed_features)/SUM(total_features))*100 as functional_coverage FROM "+
                                               "daily_functional_coverage as a INNER JOIN pqd_product as b ON a.project_name=b.testlink_project_name"+
                                               " where date between ? and ? group by date) as T group by year";

const string GET_SELECTED_AREA_DAILTY_FUNC_COVERAGE = "SELECT date,SUM(total_features) as total_features,SUM(passed_features) as passed_features," +
                                                      "(SUM(passed_features)/SUM(total_features))*100 as functional_coverage FROM daily_functional_coverage as"+
                                                      " a INNER JOIN pqd_product as b ON a.project_name=b.testlink_project_name where pqd_area_id=? "+
                                                      "and date between ? and ? group by date";

const string GET_SELECTED_AREA_MONTHLY_FUNC_COVERAGE="SELECT year(date) as year,month(date) as month,AVG(total_features) as total_features,"+
                                                     "AVG(passed_features) as passed_features,(AVG(passed_features)/AVG(total_features))*100 "+
                                                     "as functional_coverage FROM(SELECT date,SUM(total_features) as total_features,"+
                                                     "SUM(passed_features) as passed_features,(SUM(passed_features)/SUM(total_features))*100 "+
                                                     "as functional_coverage FROM daily_functional_coverage as a INNER JOIN pqd_product as "+
                                                     "b ON a.project_name=b.testlink_project_name where pqd_area_id=? and date between ? and ? "+
                                                     "group by date) as T group by year,month";

const string GET_SELECTED_AREA_QUARTERLY_FUNC_COVERAGE="SELECT year(date) as year,quarter(date) as quarter,AVG(total_features) as total_features"+
                                                       ",AVG(passed_features) as passed_features,(AVG(passed_features)/AVG(total_features))*100"+
                                                       " as functional_coverage FROM(SELECT date,SUM(total_features) as total_features,"+
                                                       "SUM(passed_features) as passed_features,(SUM(passed_features)/SUM(total_features))*100"+
                                                       " as functional_coverage FROM daily_functional_coverage as a INNER JOIN pqd_product "+
                                                       "as b ON a.project_name=b.testlink_project_name where pqd_area_id=? and date between ? and ?"+
                                                       " group by date) as T group by year,quarter";

const string GET_SELECTED_AREA_YEARLY_FUNC_COVERAGE="SELECT year(date) as year,AVG(total_features) as total_features,AVG(passed_features) as "+
                                                    "passed_features,(AVG(passed_features)/AVG(total_features))*100 as functional_coverage FROM"+
                                                    "(SELECT date,SUM(total_features) as total_features,SUM(passed_features) as passed_features,"+
                                                    "(SUM(passed_features)/SUM(total_features))*100 as functional_coverage FROM "+
                                                    "daily_functional_coverage as a INNER JOIN pqd_product as b ON a.project_name=b.testlink_project_name"+
                                                    " where pqd_area_id=? and date between ? and ? group by date) as T group by year";

const string GET_SELECTED_PRODUCT_DAILTY_FUNC_COVERAGE = "SELECT date,SUM(total_features) as total_features,SUM(passed_features) as passed_features," +
                                                         "(SUM(passed_features)/SUM(total_features))*100 as functional_coverage FROM daily_functional_coverage as"+
                                                         " a INNER JOIN pqd_product as b ON a.project_name=b.testlink_project_name where pqd_product_id=? "+
                                                         "and date between ? and ? group by date";

const string GET_SELECTED_PRODUCT_MONTHLY_FUNC_COVERAGE="SELECT year(date) as year,month(date) as month,AVG(total_features) as total_features,"+
                                                        "AVG(passed_features) as passed_features,(AVG(passed_features)/AVG(total_features))*100 "+
                                                        "as functional_coverage FROM(SELECT date,SUM(total_features) as total_features,"+
                                                        "SUM(passed_features) as passed_features,(SUM(passed_features)/SUM(total_features))*100 "+
                                                        "as functional_coverage FROM daily_functional_coverage as a INNER JOIN pqd_product as "+
                                                        "b ON a.project_name=b.testlink_project_name where pqd_product_id=? and date between ? and ? "+
                                                        "group by date) as T group by year,month";

const string GET_SELECTED_PRODUCT_QUARTERLY_FUNC_COVERAGE="SELECT year(date) as year,quarter(date) as quarter,AVG(total_features) as total_features"+
                                                          ",AVG(passed_features) as passed_features,(AVG(passed_features)/AVG(total_features))*100"+
                                                          " as functional_coverage FROM(SELECT date,SUM(total_features) as total_features,"+
                                                          "SUM(passed_features) as passed_features,(SUM(passed_features)/SUM(total_features))*100"+
                                                          " as functional_coverage FROM daily_functional_coverage as a INNER JOIN pqd_product "+
                                                          "as b ON a.project_name=b.testlink_project_name where pqd_product_id=? and date between ? and ?"+
                                                          " group by date) as T group by year,quarter";

const string GET_SELECTED_PRODUCT_YEARLY_FUNC_COVERAGE="SELECT year(date) as year,AVG(total_features) as total_features,AVG(passed_features) as "+
                                                       "passed_features,(AVG(passed_features)/AVG(total_features))*100 as functional_coverage FROM"+
                                                       "(SELECT date,SUM(total_features) as total_features,SUM(passed_features) as passed_features,"+
                                                       "(SUM(passed_features)/SUM(total_features))*100 as functional_coverage FROM "+
                                                       "daily_functional_coverage as a INNER JOIN pqd_product as b ON a.project_name=b.testlink_project_name"+
                                                       " where pqd_product_id=? and date between ? and ? group by date) as T group by year";
