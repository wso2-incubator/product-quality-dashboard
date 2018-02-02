package org.wso2.internalapps.pqd;

import ballerina.net.http;

http:ClientConnector JENKINS_Connector = null;

http:ClientConnector GITHUB_Connector = null;

http:ClientConnector SIDDHI_Connector = null;

http:ClientConnector SIDDHI_REST_Connector = null;

int[] lastDateOfMonth = [31,28,31,30,31,30,31,31,30,31,30,31];

const string CONFIGURATION_PATH_JENKINS = "config.json";

json allComponentAreaJson = null;

const int MILI_SECONDS_PER_DAY_JENKINS = 86400000;

const string GET_ALL_PRODUCT_COMPONENTS = "SELECT pqd_component_name,pqd_area_id FROM pqd_component;" ;

const string GET_REPO_FOLDER = "SELECT Folder FROM JNKS_COMPONENTFOLDER where Component=? ;";

const string GET_ALL_PRODUCTS_JENKINS = "SELECT pqd_area_name as product FROM pqd_area where pqd_area_name != 'Other' order by pqd_area_name ASC;";

const string INSERT_COMPONENT_PRODUCT = "INSERT INTO pqd_component (pqd_component_name,pqd_area_id,pqd_product_id,pqd_product_version_id,github_repo_name,github_repo_organization) VALUES (?,?,?,?,?,?);";

const string INSERT_COMPONENT_FOLDER = "INSERT INTO JNKS_COMPONENTFOLDER (Component,Folder) VALUES (?,?)";

const string UPDATE_COMPONENT_FOLDER = "UPDATE JNKS_COMPONENTFOLDER SET Folder=? WHERE Component=? AND Folder =?;";

const string GET_PRODUCT_ID = "SELECT pqd_product_id FROM pqd_product WHERE pqd_area_id=? AND pqd_product_name='No Product' ;";

const string GET_AREA_NAME = "SELECT pqd_area_name FROM pqd_area WHERE pqd_area_id = ? ;";

const string GET_PRODUCT_AREA_COMPONENT = "SELECT pqd_area.pqd_area_name AS area,pqd_component.pqd_component_name AS component FROM pqd_area JOIN pqd_component ON pqd_component.pqd_area_id=pqd_area.pqd_area_id";

const string GET_SPECIFIC_PRODUCT_AREA_COMPONENT = "SELECT pqd_area.pqd_area_name AS area,pqd_component.pqd_component_name AS component FROM pqd_area JOIN pqd_component ON pqd_component.pqd_area_id=pqd_area.pqd_area_id WHERE pqd_area.pqd_area_name = ? ORDER BY component";

const string GET_FAILURE_DETAILS = "SELECT * FROM JNKS_FAILED_BUILD_DETAILS WHERE product=? AND timestamp >= ? AND timestamp <= ?  order by timestamp DESC";

const string GET_FAILURE_DETAILS_FOR_COMPONENT = "SELECT * FROM JNKS_FAILED_BUILD_DETAILS WHERE product=? AND component=? AND timestamp >= ? AND timestamp <= ? order by timestamp DESC";

const string GET_ALL_FAILURE_CONTRIBUTORS = "select count(committedBy) as total,committedBy,GROUP_CONCAT(PRmergedName) as PRmergedBy from JNKS_FAILED_BUILD_DETAILS where committedBy not in ('Started by timer','ballerinalang') AND committedBy NOT REGEXP '^git' AND committedBy NOT REGEXP '^wso2' AND committedBy NOT regexp '^Started' AND committedBy NOT regexp '^jenkin' AND (timestamp >=? AND timestamp<=?) group by committedBy,PRmergedName order by total DESC limit 10;";

const string GET_ALL_FAILURE_REASONS = "select failureReason,count(failureReason) as count from (select
                                          SUBSTRING_INDEX(SUBSTRING_INDEX(JNKS_FAILED_BUILD_DETAILS.failureReason, ',', numbers.n), ',', -1) failureReason
                                        from
                                          (select 1 n union all
                                           select 2 union all select 3 union all
                                           select 4 union all select 5) numbers INNER JOIN JNKS_FAILED_BUILD_DETAILS
                                          on CHAR_LENGTH(JNKS_FAILED_BUILD_DETAILS.failureReason)
                                             -CHAR_LENGTH(REPLACE(JNKS_FAILED_BUILD_DETAILS.failureReason, ',', ''))>=numbers.n-1 AND (JNKS_FAILED_BUILD_DETAILS.timestamp >= ? AND JNKS_FAILED_BUILD_DETAILS.timestamp <=?)
                                        order by
                                          n ) as f group by failureReason";

const string GET_ALL_FAILURE_REASONS_DRILLDOWN = "select product,failureReason,count(failureReason) as count from (select
                                                      product,
                                                      SUBSTRING_INDEX(SUBSTRING_INDEX(JNKS_FAILED_BUILD_DETAILS.failureReason, ',', numbers.n), ',', -1) failureReason
                                                    from
                                                      (select 1 n union all
                                                       select 2 union all select 3 union all
                                                       select 4 union all select 5) numbers INNER JOIN JNKS_FAILED_BUILD_DETAILS
                                                      on CHAR_LENGTH(JNKS_FAILED_BUILD_DETAILS.failureReason)
                                                         -CHAR_LENGTH(REPLACE(JNKS_FAILED_BUILD_DETAILS.failureReason, ',', ''))>=numbers.n-1 AND (JNKS_FAILED_BUILD_DETAILS.timestamp >= ? AND JNKS_FAILED_BUILD_DETAILS.timestamp <=?)
                                                    order by
                                                      product, n ) as f group by failureReason,product order by failureReason";

const string GET_ALL_FAILURE_REASONS_FOR_PRODUCT = "select product,failureReason,count(failureReason) as count from (select
                                                      product,
                                                      SUBSTRING_INDEX(SUBSTRING_INDEX(JNKS_FAILED_BUILD_DETAILS.failureReason, ',', numbers.n), ',', -1) failureReason
                                                    from
                                                      (select 1 n union all
                                                       select 2 union all select 3 union all
                                                       select 4 union all select 5) numbers INNER JOIN JNKS_FAILED_BUILD_DETAILS
                                                      on CHAR_LENGTH(JNKS_FAILED_BUILD_DETAILS.failureReason)
                                                         -CHAR_LENGTH(REPLACE(JNKS_FAILED_BUILD_DETAILS.failureReason, ',', ''))>=numbers.n-1 AND JNKS_FAILED_BUILD_DETAILS.product=? AND (JNKS_FAILED_BUILD_DETAILS.timestamp >= ? AND JNKS_FAILED_BUILD_DETAILS.timestamp <=?)
                                                    order by
                                                      product, n ) as f group by failureReason,product order by failureReason";

const string SET_UPDATE_ZERO = "SET SQL_SAFE_UPDATES = 0;";
