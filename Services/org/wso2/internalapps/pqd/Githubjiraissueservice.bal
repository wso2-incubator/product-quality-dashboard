package org.wso2.internalapps.pqd;

import ballerina.lang.messages;
import ballerina.net.http;
import ballerina.lang.jsons;
import ballerina.utils.logger;
import ballerina.lang.datatables;
import ballerina.data.sql;


@http:configuration {basePath:"/internal/product-quality/v1.0/github", httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> IssuesService {
    boolean issuesDBConBool = createIssuesDBcon();
    sql:ClientConnector sqlCon = issuesDBcon;

    @http:GET {}
    @http:Path {value:"/issues/issuetype/{issueTypeId}/severity/{severityId}"}
    resource getIssuesFilteredAll(message m, @http:PathParam {value: "issueTypeId"} int issueTypeId,
                                  @http:PathParam {value: "severityId"} int severityId,
                                  @http:QueryParam {value:"category"} string category,
                                  @http:QueryParam {value:"categoryId"} int categoryId){

        message response = {};

        json responseJson;
        responseJson = getIssuesData(sqlCon, category, categoryId, issueTypeId, severityId);

        messages:setJsonPayload(response, responseJson);

        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");


        reply response;

    }

    @http:GET {}
    @http:Path {value:"/issues/history/{category}/{categoryId}"}
    resource getGithubHistory(message m, @http:PathParam {value: "category"} string category,
                              @http:PathParam {value: "categoryId"} int categoryId,
                              @http:QueryParam {value: "issuetypeId"} int issueTypeId,
                              @http:QueryParam {value: "severityId"} int severityId,
                              @http:QueryParam {value: "period"} string period,
                              @http:QueryParam {value: "dateFrom"} string startDate,
                              @http:QueryParam {value: "dateTo"} string endDate){

        message response = {};

        json responseJson = getIssuesHistory(sqlCon, category, categoryId, issueTypeId, severityId, startDate, endDate, period);

        messages:setJsonPayload(response, responseJson);

        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");

        reply response;

    }

}


function getIssuesData(sql:ClientConnector sqlCon, string category, int categoryId,
                        int issueTypeId, int severityId) (json) {
    logger:debug("getGithubIssuesData function got invoked for category : " + category + "; categoryId : "
                 + categoryId + "; and issueTypeId : " + issueTypeId + "; severityId : " + severityId);

    // available categories
    // 1. all
    // 2. area
    // 3. product
    // 4. component

    // issueTypeId = 0 or severityId = 0  indicates that issueTypeId or severityId is not selected

    if(category == "all"){
        if (issueTypeId == 0 && severityId == 0){

            sql:Parameter[] emptyParams = [];
            json areaIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_AREA_CURRENT_ISSUES_QUERY, emptyParams);
            json issueTypeJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_ISSUETYPE_CURRENT_ISSUES_QUERY, emptyParams);
            json severityJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_SEVERITY_CURRENT_ISSUES_QUERY, emptyParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int areaIndex = 0;
            while(areaIndex < lengthof areaIssueJson) {
                var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[areaIndex], "$.pqd_issues_count");
                int areaIssues = areaIssueVar;

                json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[areaIndex], "$.pqd_area_name"),
                                               "id": jsons:getInt(areaIssueJson[areaIndex], "$.pqd_area_id"),
                                               "issues": areaIssues
                                           };
                jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);
                areaIndex = areaIndex + 1;
            }

            int issueTypeIndex = 0;
            while(issueTypeIndex < lengthof issueTypeJson) {

                var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[issueTypeIndex], "$.pqd_issues_count");
                int issueTypeIssues = issueTypeIssueVar;

                json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[issueTypeIndex], "$.pqd_issue_type"),
                                                "id": jsons:getInt(issueTypeJson[issueTypeIndex], "$.pqd_issue_type_id"),
                                                "issues": issueTypeIssues
                                            };
                jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);
                issueTypeIndex = issueTypeIndex + 1;
            }

            int severityIndex = 0;
            while(severityIndex < lengthof severityJson) {

                var severityIssueVar, _ = <int>jsons:getFloat(severityJson[severityIndex], "$.pqd_issues_count");

                json currentSeverityJson = {"name": jsons:getString(severityJson[severityIndex], "$.pqd_severity"),
                                               "id": jsons:getInt(severityJson[severityIndex], "$.pqd_severity_id"),
                                               "issues": severityIssueVar
                                           };
                jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);
                severityIndex = severityIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if (issueTypeId == 0){
            sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};
            sql:Parameter[] sqlParams = [severityIdParam];
            json areaIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_AREA_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY, sqlParams);
            json issueTypeJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_ISSUETYPE_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int areaIndex = 0;
            while(areaIndex < lengthof areaIssueJson) {
                var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[areaIndex], "$.pqd_issues_count");
                int areaIssues = areaIssueVar;

                json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[areaIndex], "$.pqd_area_name"),
                                               "id": jsons:getInt(areaIssueJson[areaIndex], "$.pqd_area_id"),
                                               "issues": areaIssues
                                           };
                jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);
                areaIndex = areaIndex + 1;
            }

            int issueTypeIndex = 0;
            while(issueTypeIndex < lengthof issueTypeJson) {

                var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[issueTypeIndex], "$.pqd_issues_count");
                int issueTypeIssues = issueTypeIssueVar;

                json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[issueTypeIndex], "$.pqd_issue_type"),
                                                "id": jsons:getInt(issueTypeJson[issueTypeIndex], "$.pqd_issue_type_id"),
                                                "issues": issueTypeIssues
                                            };
                jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);
                issueTypeIndex = issueTypeIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;


        } else if (severityId == 0){
            sql:Parameter issueTypeIdParam = {sqlType : "integer", value: issueTypeId};
            sql:Parameter[] sqlParams = [issueTypeIdParam];
            json areaIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_AREA_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY, sqlParams);
            json severityJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_SEVERITY_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int areaIndex = 0;
            while(areaIndex < lengthof areaIssueJson) {
                var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[areaIndex], "$.pqd_issues_count");
                int areaIssues = areaIssueVar;

                json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[areaIndex], "$.pqd_area_name"),
                                               "id": jsons:getInt(areaIssueJson[areaIndex], "$.pqd_area_id"),
                                               "issues": areaIssues
                                           };
                jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);
                areaIndex = areaIndex + 1;
            }

            int severityIndex = 0;
            while(severityIndex < lengthof severityJson) {

                var severityIssueVar, _ = <int>jsons:getFloat(severityJson[severityIndex], "$.pqd_issues_count");

                json currentSeverityJson = {"name": jsons:getString(severityJson[severityIndex], "$.pqd_severity"),
                                               "id": jsons:getInt(severityJson[severityIndex], "$.pqd_severity_id"),
                                               "issues": severityIssueVar
                                           };
                jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);
                severityIndex = severityIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if ((issueTypeId != 0) && (severityId != 0)){
            sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
            sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};
            sql:Parameter[] sqlParams = [issueTypeIdParam, severityIdParam];
            json areaIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_AREA_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_SEVERITY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int areaIndex = 0;
            while(areaIndex < lengthof areaIssueJson) {
                var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[areaIndex], "$.pqd_issues_count");
                int areaIssues = areaIssueVar;

                json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[areaIndex], "$.pqd_area_name"),
                                               "id": jsons:getInt(areaIssueJson[areaIndex], "$.pqd_area_id"),
                                               "issues": areaIssues
                                           };
                jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);
                areaIndex = areaIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;
        }
    } else if (category == "area"){
        if (issueTypeId == 0 && severityId == 0){
            sql:Parameter areaIdParam = { sqlType: "integer", value: categoryId};
            sql:Parameter[] sqlParams = [areaIdParam];
            json productIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_PRODUCT_CURRENT_ISSUES_QUERY, sqlParams);
            json issueTypeJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_ISSUETYPE_CURRENT_ISSUES_QUERY, sqlParams);
            json severityJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_SEVERITY_CURRENT_ISSUES_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int productIndex = 0;
            while(productIndex < lengthof productIssueJson) {
                var productIssueVar, _ = <int>jsons:getFloat(productIssueJson[productIndex], "$.pqd_issues_count");
                int productIssues = productIssueVar;

                json currentProductItemJson = {"name": jsons:getString(productIssueJson[productIndex], "$.pqd_product_name"),
                                                  "id": jsons:getInt(productIssueJson[productIndex], "$.pqd_product_id"),
                                                  "issues": productIssues
                                              };
                jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);
                productIndex = productIndex + 1;
            }

            int issueTypeIndex = 0;
            while(issueTypeIndex < lengthof issueTypeJson) {

                var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[issueTypeIndex], "$.pqd_issues_count");
                int issueTypeIssues = issueTypeIssueVar;

                json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[issueTypeIndex], "$.pqd_issue_type"),
                                                "id": jsons:getInt(issueTypeJson[issueTypeIndex], "$.pqd_issue_type_id"),
                                                "issues": issueTypeIssues
                                            };
                jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);
                issueTypeIndex = issueTypeIndex + 1;
            }

            int severityIndex = 0;
            while(severityIndex < lengthof severityJson) {

                var severityIssueVar, _ = <int>jsons:getFloat(severityJson[severityIndex], "$.pqd_issues_count");

                json currentSeverityJson = {"name": jsons:getString(severityJson[severityIndex], "$.pqd_severity"),
                                               "id": jsons:getInt(severityJson[severityIndex], "$.pqd_severity_id"),
                                               "issues": severityIssueVar
                                           };
                jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);
                severityIndex = severityIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if (issueTypeId == 0){
            sql:Parameter areaIdParam = { sqlType: "integer", value: categoryId};
            sql:Parameter severityIdParam = { sqlType: "integer", value: severityId};
            sql:Parameter[] sqlParams = [areaIdParam, severityIdParam];
            json productIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_PRODUCT_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY, sqlParams);
            json issueTypeJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_ISSUETYPE_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int productIndex = 0;
            while(productIndex < lengthof productIssueJson) {
                var productIssueVar, _ = <int>jsons:getFloat(productIssueJson[productIndex], "$.pqd_issues_count");
                int productIssues = productIssueVar;

                json currentProductItemJson = {"name": jsons:getString(productIssueJson[productIndex], "$.pqd_product_name"),
                                                  "id": jsons:getInt(productIssueJson[productIndex], "$.pqd_product_id"),
                                                  "issues": productIssues
                                              };
                jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);
                productIndex = productIndex + 1;
            }

            int issueTypeIndex = 0;
            while(issueTypeIndex < lengthof issueTypeJson) {

                var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[issueTypeIndex], "$.pqd_issues_count");
                int issueTypeIssues = issueTypeIssueVar;

                json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[issueTypeIndex], "$.pqd_issue_type"),
                                                "id": jsons:getInt(issueTypeJson[issueTypeIndex], "$.pqd_issue_type_id"),
                                                "issues": issueTypeIssues
                                            };
                jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);
                issueTypeIndex = issueTypeIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if (severityId == 0){

            sql:Parameter areaIdParam = { sqlType: "integer", value: categoryId};
            sql:Parameter issueTypeIdParam = { sqlType: "integer", value: issueTypeId};
            sql:Parameter[] sqlParams = [areaIdParam, issueTypeIdParam];
            json productIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_PRODUCT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY, sqlParams);
            json severityJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_SEVERITY_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int productIndex = 0;
            while(productIndex < lengthof productIssueJson) {
                var productIssueVar, _ = <int>jsons:getFloat(productIssueJson[productIndex], "$.pqd_issues_count");
                int productIssues = productIssueVar;

                json currentProductItemJson = {"name": jsons:getString(productIssueJson[productIndex], "$.pqd_product_name"),
                                                  "id": jsons:getInt(productIssueJson[productIndex], "$.pqd_product_id"),
                                                  "issues": productIssues
                                              };
                jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);
                productIndex = productIndex + 1;
            }

            int severityIndex = 0;
            while(severityIndex < lengthof severityJson) {

                var severityIssueVar, _ = <int>jsons:getFloat(severityJson[severityIndex], "$.pqd_issues_count");

                json currentSeverityJson = {"name": jsons:getString(severityJson[severityIndex], "$.pqd_severity"),
                                               "id": jsons:getInt(severityJson[severityIndex], "$.pqd_severity_id"),
                                               "issues": severityIssueVar
                                           };
                jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);
                severityIndex = severityIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if ((issueTypeId != 0) && (severityId != 0)){
            sql:Parameter areaIdParam = { sqlType: "integer", value: categoryId};
            sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
            sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};
            sql:Parameter[] sqlParams = [areaIdParam, issueTypeIdParam, severityIdParam];
            json productIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_PRODUCT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_SEVERITY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int productIndex = 0;
            while(productIndex < lengthof productIssueJson) {
                var productIssueVar, _ = <int>jsons:getFloat(productIssueJson[productIndex], "$.pqd_issues_count");
                int productIssues = productIssueVar;

                json currentProductItemJson = {"name": jsons:getString(productIssueJson[productIndex], "$.pqd_product_name"),
                                                  "id": jsons:getInt(productIssueJson[productIndex], "$.pqd_product_id"),
                                                  "issues": productIssues
                                              };
                jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);
                productIndex = productIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;
        }

    } else if (category == "product"){
        if (issueTypeId == 0 && severityId == 0){
            sql:Parameter productIdParam = { sqlType: "integer", value: categoryId};
            sql:Parameter[] sqlParams = [productIdParam];
            json componentIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_QUERY, sqlParams);
            json issueTypeJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_ISSUETYPE_CURRENT_ISSUES_QUERY, sqlParams);
            json severityJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_SEVERITY_CURRENT_ISSUES_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int componentIndex = 0;
            while(componentIndex < lengthof componentIssueJson) {
                var componentIssueVar, _ = <int>jsons:getFloat(componentIssueJson[componentIndex], "$.pqd_issues_count");
                int componentIssues = componentIssueVar;

                json currentComponentItemJson = {"name": jsons:getString(componentIssueJson[componentIndex], "$.pqd_component_name"),
                                                    "id": jsons:getInt(componentIssueJson[componentIndex], "$.pqd_component_id"),
                                                    "issues": componentIssues
                                                };
                jsons:addToArray(responseJson, "$.data.items", currentComponentItemJson);
                componentIndex = componentIndex + 1;
            }

            int issueTypeIndex = 0;
            while(issueTypeIndex < lengthof issueTypeJson) {

                var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[issueTypeIndex], "$.pqd_issues_count");
                int issueTypeIssues = issueTypeIssueVar;

                json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[issueTypeIndex], "$.pqd_issue_type"),
                                                "id": jsons:getInt(issueTypeJson[issueTypeIndex], "$.pqd_issue_type_id"),
                                                "issues": issueTypeIssues
                                            };
                jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);
                issueTypeIndex = issueTypeIndex + 1;
            }

            int severityIndex = 0;
            while(severityIndex < lengthof severityJson) {

                var severityIssueVar, _ = <int>jsons:getFloat(severityJson[severityIndex], "$.pqd_issues_count");

                json currentSeverityJson = {"name": jsons:getString(severityJson[severityIndex], "$.pqd_severity"),
                                               "id": jsons:getInt(severityJson[severityIndex], "$.pqd_severity_id"),
                                               "issues": severityIssueVar
                                           };
                jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);
                severityIndex = severityIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if (issueTypeId == 0){

            sql:Parameter productIdParam = { sqlType: "integer", value: categoryId};
            sql:Parameter severityIdParam = { sqlType: "integer", value:severityId};
            sql:Parameter[] sqlParams = [productIdParam, severityIdParam];
            json componentIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY, sqlParams);
            json issueTypeJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_ISSUETYPE_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int componentIndex = 0;
            while(componentIndex < lengthof componentIssueJson) {
                var componentIssueVar, _ = <int>jsons:getFloat(componentIssueJson[componentIndex], "$.pqd_issues_count");
                int componentIssues = componentIssueVar;

                json currentComponentItemJson = {"name": jsons:getString(componentIssueJson[componentIndex], "$.pqd_component_name"),
                                                    "id": jsons:getInt(componentIssueJson[componentIndex], "$.pqd_component_id"),
                                                    "issues": componentIssues
                                                };
                jsons:addToArray(responseJson, "$.data.items", currentComponentItemJson);
                componentIndex = componentIndex + 1;
            }

            int issueTypeIndex = 0;
            while(issueTypeIndex < lengthof issueTypeJson) {

                var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[issueTypeIndex], "$.pqd_issues_count");
                int issueTypeIssues = issueTypeIssueVar;

                json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[issueTypeIndex], "$.pqd_issue_type"),
                                                "id": jsons:getInt(issueTypeJson[issueTypeIndex], "$.pqd_issue_type_id"),
                                                "issues": issueTypeIssues
                                            };
                jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);
                issueTypeIndex = issueTypeIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if (severityId == 0){
            sql:Parameter productIdParam = { sqlType: "integer", value: categoryId};
            sql:Parameter issueTypeIdParam = { sqlType: "integer", value: issueTypeId};
            sql:Parameter[] sqlParams = [productIdParam, issueTypeIdParam];
            json componentIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY, sqlParams);
            json severityJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_SEVERITY_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int componentIndex = 0;
            while(componentIndex < lengthof componentIssueJson) {
                var componentIssueVar, _ = <int>jsons:getFloat(componentIssueJson[componentIndex], "$.pqd_issues_count");
                int componentIssues = componentIssueVar;

                json currentComponentItemJson = {"name": jsons:getString(componentIssueJson[componentIndex], "$.pqd_component_name"),
                                                    "id": jsons:getInt(componentIssueJson[componentIndex], "$.pqd_component_id"),
                                                    "issues": componentIssues
                                                };
                jsons:addToArray(responseJson, "$.data.items", currentComponentItemJson);
                componentIndex = componentIndex + 1;
            }

            int severityIndex = 0;
            while(severityIndex < lengthof severityJson) {

                var severityIssueVar, _ = <int>jsons:getFloat(severityJson[severityIndex], "$.pqd_issues_count");

                json currentSeverityJson = {"name": jsons:getString(severityJson[severityIndex], "$.pqd_severity"),
                                               "id": jsons:getInt(severityJson[severityIndex], "$.pqd_severity_id"),
                                               "issues": severityIssueVar
                                           };
                jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);
                severityIndex = severityIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if ((issueTypeId != 0) && (severityId != 0)){
            sql:Parameter productIdParam = { sqlType: "integer", value: categoryId};
            sql:Parameter issueTypeIdParam = { sqlType: "integer", value: issueTypeId};
            sql:Parameter severityIdParam = { sqlType: "integer", value: severityId};
            sql:Parameter[] sqlParams = [productIdParam, issueTypeIdParam, severityIdParam];
            json componentIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_SEVERITY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int componentIndex = 0;
            while(componentIndex < lengthof componentIssueJson) {
                var componentIssueVar, _ = <int>jsons:getFloat(componentIssueJson[componentIndex], "$.pqd_issues_count");
                int componentIssues = componentIssueVar;

                json currentComponentItemJson = {"name": jsons:getString(componentIssueJson[componentIndex], "$.pqd_component_name"),
                                                    "id": jsons:getInt(componentIssueJson[componentIndex], "$.pqd_component_id"),
                                                    "issues": componentIssues
                                                };
                jsons:addToArray(responseJson, "$.data.items", currentComponentItemJson);
                componentIndex = componentIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;
        }

    } else if (category == "version"){
        if (issueTypeId == 0 && severityId == 0){

        } else if (issueTypeId == 0){

        } else if (severityId == 0){

        } else if ((issueTypeId != 0) && (severityId != 0)){

        }

    } else if (category == "component"){
        if (issueTypeId == 0 && severityId == 0){

            sql:Parameter componentIdParam = {sqlType:"integer", value: categoryId};
            sql:Parameter[] componentParams = [componentIdParam];

            json productIdJson = getDataFromDatabase(sqlCon, GET_PRODUCT_ID_FOR_COMPONENT_ID, componentParams);
            int productId = 0;
            if (lengthof productIdJson > 0){
                productId = jsons:getInt(productIdJson, "$[0].pqd_product_id");
            } else {
                json responseJson = {"error":true, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};
                return responseJson;
            }

            sql:Parameter productIdParam = { sqlType: "integer", value: productId};
            sql:Parameter[] productParams = [productIdParam];
            json componentIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_QUERY, productParams);
            json issueTypeJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_ISSUETYPE_CURRENT_ISSUES_QUERY, componentParams);
            json severityJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_SEVERITY_CURRENT_ISSUES_QUERY, componentParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int componentIndex = 0;
            while(componentIndex < lengthof componentIssueJson) {
                var componentIssueVar, _ = <int>jsons:getFloat(componentIssueJson[componentIndex], "$.pqd_issues_count");
                int componentIssues = componentIssueVar;

                json currentComponentItemJson = {"name": jsons:getString(componentIssueJson[componentIndex], "$.pqd_component_name"),
                                                    "id": jsons:getInt(componentIssueJson[componentIndex], "$.pqd_component_id"),
                                                    "issues": componentIssues
                                                };
                jsons:addToArray(responseJson, "$.data.items", currentComponentItemJson);
                componentIndex = componentIndex + 1;
            }

            int issueTypeIndex = 0;
            while(issueTypeIndex < lengthof issueTypeJson) {

                var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[issueTypeIndex], "$.pqd_issues_count");
                int issueTypeIssues = issueTypeIssueVar;

                json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[issueTypeIndex], "$.pqd_issue_type"),
                                                "id": jsons:getInt(issueTypeJson[issueTypeIndex], "$.pqd_issue_type_id"),
                                                "issues": issueTypeIssues
                                            };
                jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);
                issueTypeIndex = issueTypeIndex + 1;
            }

            int severityIndex = 0;
            while(severityIndex < lengthof severityJson) {

                var severityIssueVar, _ = <int>jsons:getFloat(severityJson[severityIndex], "$.pqd_issues_count");

                json currentSeverityJson = {"name": jsons:getString(severityJson[severityIndex], "$.pqd_severity"),
                                               "id": jsons:getInt(severityJson[severityIndex], "$.pqd_severity_id"),
                                               "issues": severityIssueVar
                                           };
                jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);
                severityIndex = severityIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if (issueTypeId == 0){
            sql:Parameter componentIdParam = {sqlType:"integer", value: categoryId};
            sql:Parameter[] componentParams = [componentIdParam];

            json productIdJson = getDataFromDatabase(sqlCon, GET_PRODUCT_ID_FOR_COMPONENT_ID, componentParams);
            int productId = 0;
            if (lengthof productIdJson > 0){
                productId = jsons:getInt(productIdJson, "$[0].pqd_product_id");
            } else {
                json responseJson = {"error":true, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};
                return responseJson;
            }

            sql:Parameter productIdParam = { sqlType: "integer", value: productId };
            sql:Parameter severityIdParam = { sqlType: "integer", value: severityId };
            sql:Parameter[] productIdParams = [productIdParam, severityIdParam];
            sql:Parameter[] sqlParams = [componentIdParam, severityIdParam];
            json componentIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY, productIdParams);
            json issueTypeJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_ISSUETYPE_CURRENT_ISSUES_FILTER_BY_SEVERITY_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int componentIndex = 0;
            while(componentIndex < lengthof componentIssueJson) {
                var componentIssueVar, _ = <int>jsons:getFloat(componentIssueJson[componentIndex], "$.pqd_issues_count");
                int componentIssues = componentIssueVar;

                json currentComponentItemJson = {"name": jsons:getString(componentIssueJson[componentIndex], "$.pqd_component_name"),
                                                    "id": jsons:getInt(componentIssueJson[componentIndex], "$.pqd_component_id"),
                                                    "issues": componentIssues
                                                };
                jsons:addToArray(responseJson, "$.data.items", currentComponentItemJson);
                componentIndex = componentIndex + 1;
            }

            int issueTypeIndex = 0;
            while(issueTypeIndex < lengthof issueTypeJson) {

                var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[issueTypeIndex], "$.pqd_issues_count");
                int issueTypeIssues = issueTypeIssueVar;

                json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[issueTypeIndex], "$.pqd_issue_type"),
                                                "id": jsons:getInt(issueTypeJson[issueTypeIndex], "$.pqd_issue_type_id"),
                                                "issues": issueTypeIssues
                                            };
                jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);
                issueTypeIndex = issueTypeIndex + 1;
            }


            logger:info(responseJson);
            return responseJson;

        } else if (severityId == 0){
            sql:Parameter componentIdParam = {sqlType:"integer", value: categoryId};
            sql:Parameter[] componentParams = [componentIdParam];

            json productIdJson = getDataFromDatabase(sqlCon, GET_PRODUCT_ID_FOR_COMPONENT_ID, componentParams);
            int productId = 0;
            if (lengthof productIdJson > 0){
                productId = jsons:getInt(productIdJson, "$[0].pqd_product_id");
            } else {
                json responseJson = {"error":true, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};
                return responseJson;
            }

            sql:Parameter productIdParam = { sqlType: "integer", value: productId};
            sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
            sql:Parameter[] productIdParams = [productIdParam, issueTypeIdParam];
            sql:Parameter[] sqlParams = [componentIdParam, issueTypeIdParam];
            json componentIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY, productIdParams);
            json severityJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_SEVERITY_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_QUERY, sqlParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int componentIndex = 0;
            while(componentIndex < lengthof componentIssueJson) {
                var componentIssueVar, _ = <int>jsons:getFloat(componentIssueJson[componentIndex], "$.pqd_issues_count");
                int componentIssues = componentIssueVar;

                json currentComponentItemJson = {"name": jsons:getString(componentIssueJson[componentIndex], "$.pqd_component_name"),
                                                    "id": jsons:getInt(componentIssueJson[componentIndex], "$.pqd_component_id"),
                                                    "issues": componentIssues
                                                };
                jsons:addToArray(responseJson, "$.data.items", currentComponentItemJson);
                componentIndex = componentIndex + 1;
            }

            int severityIndex = 0;
            while(severityIndex < lengthof severityJson) {

                var severityIssueVar, _ = <int>jsons:getFloat(severityJson[severityIndex], "$.pqd_issues_count");

                json currentSeverityJson = {"name": jsons:getString(severityJson[severityIndex], "$.pqd_severity"),
                                               "id": jsons:getInt(severityJson[severityIndex], "$.pqd_severity_id"),
                                               "issues": severityIssueVar
                                           };
                jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);
                severityIndex = severityIndex + 1;
            }

            logger:info(responseJson);
            return responseJson;

        } else if ((issueTypeId != 0) && (severityId != 0)){
            sql:Parameter componentIdParam = {sqlType:"integer", value: categoryId};
            sql:Parameter[] componentParams = [componentIdParam];

            json productIdJson = getDataFromDatabase(sqlCon, GET_PRODUCT_ID_FOR_COMPONENT_ID, componentParams);
            int productId = 0;
            if (lengthof productIdJson > 0){
                productId = jsons:getInt(productIdJson, "$[0].pqd_product_id");
            } else {
                json responseJson = {"error":true, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};
                return responseJson;
            }

            sql:Parameter productIdParam = { sqlType: "integer", value: productId };
            sql:Parameter issueTypeIdParam = { sqlType: "integer", value: issueTypeId };
            sql:Parameter severityIdParam = { sqlType: "integer", value: severityId };
            sql:Parameter[] productIdParams = [productIdParam, issueTypeIdParam, severityIdParam];
            json componentIssueJson = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_COMPONENT_CURRENT_ISSUES_FILTER_BY_ISSUETYPE_SEVERITY, productIdParams);

            json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

            int componentIndex = 0;
            while(componentIndex < lengthof componentIssueJson) {
                var componentIssueVar, _ = <int>jsons:getFloat(componentIssueJson[componentIndex], "$.pqd_issues_count");
                int componentIssues = componentIssueVar;

                json currentComponentItemJson = {"name": jsons:getString(componentIssueJson[componentIndex], "$.pqd_component_name"),
                                                    "id": jsons:getInt(componentIssueJson[componentIndex], "$.pqd_component_id"),
                                                    "issues": componentIssues
                                                };
                jsons:addToArray(responseJson, "$.data.items", currentComponentItemJson);
                componentIndex = componentIndex + 1;
            }
            logger:info(responseJson);
            return responseJson;
        }

    }

    json responseJson = {"error": true, "msg": ""};

    logger:info(responseJson);
    return responseJson;
}

function getIssuesHistory(sql:ClientConnector sqlCon, string category, int categoryId,
                           int issueTypeId, int severityId, string startDate, string endDate, string period) (json) {
    logger:debug("getHistory function got invoked for category : " + category +
                 " and categoryId : " + categoryId + " and issueTypeId : " + issueTypeId + " and severityId : " + severityId + " and startDate : " + startDate
                 + " and endDate : " + endDate + " and period : " + period);

    json responseJson = {"error": false, "data":[] };

    sql:Parameter startDateParam = {sqlType: "varchar", value: startDate};
    sql:Parameter endDateParam = {sqlType: "varchar", value: endDate};

    if(period=="day"){

        if(category=="all"){
            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_DAY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;


            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_DAY_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_DAY_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            }
        } else if (category == "area"){
            sql:Parameter areaIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [areaIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_DAY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [areaIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_DAY_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [areaIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_DAY_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [areaIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            }
        } else if (category == "product"){
            sql:Parameter productIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [productIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_DAY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [productIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_DAY_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [productIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_DAY_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [productIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            }
        } else if (category == "component"){
            sql:Parameter componentIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [componentIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_DAY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;


            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [componentIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_DAY_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [componentIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_DAY_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [componentIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    string getDate = jsons:getString(response[index], "$.pqd_date");
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            }
        }

    } else if (period == "Month"){
        if(category=="all"){
            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_MONTH, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;


            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_MONTH_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_MONTH_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            }
        } else if (category == "area"){
            sql:Parameter areaIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [areaIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_MONTH, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [areaIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_MONTH_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [areaIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_MONTH_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [areaIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            }
        } else if (category == "product"){
            sql:Parameter productIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [productIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_MONTH, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [productIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_MONTH_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [productIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_MONTH_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [productIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            }
        } else if (category == "Component"){
            sql:Parameter componentIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [componentIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_MONTH, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;


            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [componentIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_MONTH_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [componentIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_MONTH_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [componentIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int month = jsons:getInt(response[index], "$.month");
                    string getDate = year + "-" + month;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            }
        }


    } else if (period == "Quarter"){

        if(category=="all"){
            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_QUARTER, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;


            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            }
        } else if (category == "area"){
            sql:Parameter areaIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [areaIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_QUARTER, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [areaIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_QUARTER_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [areaIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_QUARTER_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [areaIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            }
        } else if (category == "product"){
            sql:Parameter productIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [productIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_QUARTER, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [productIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_QUARTER_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [productIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [productIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            }
        } else if (category == "Component"){
            sql:Parameter componentIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [componentIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_QUARTER, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;


            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [componentIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_QUARTER_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [componentIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [componentIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    int quarter = jsons:getInt(response[index], "$.quarter");
                    string getDate = year + "-" + quarter;
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            }
        }

    } else if (period == "Year"){
        if(category=="all"){
            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_YEAR, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;


            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_YEAR_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_YEAR_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_ALL_AREAS_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            }
        } else if (category == "area"){
            sql:Parameter areaIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [areaIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_YEAR, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [areaIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_YEAR_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [areaIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_YEAR_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [areaIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_AREA_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            }
        } else if (category == "product"){
            sql:Parameter productIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [productIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_YEAR, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [productIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_YEAR_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;
            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [productIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_YEAR_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [productIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_PRODUCT_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            }
        } else if (category == "Component"){
            sql:Parameter componentIdParam = {sqlType:"integer", value: categoryId};

            if ((issueTypeId == 0) && (severityId == 0)){
                sql:Parameter[] params = [componentIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_YEAR, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;


            } else if (issueTypeId == 0){
                sql:Parameter severityIdParam = {sqlType:"integer", value: severityId};
                sql:Parameter[] params = [componentIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_YEAR_FILTER_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if (severityId == 0){
                sql:Parameter issueTypeIdParam = {sqlType: "integer", value: issueTypeId};
                sql:Parameter[] params = [componentIdParam, issueTypeIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_YEAR_FILTER_ISSUETYPE, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            } else if ((issueTypeId != 0) && (severityId != 0)){
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value: issueTypeId};
                sql:Parameter severityIdParam = {sqlType: "integer", value: severityId};

                sql:Parameter[] params = [componentIdParam, issueTypeIdParam, severityIdParam, startDateParam, endDateParam];
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_JIRA_COMPONENT_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY, params);

                int index = 0;

                while (index < lengthof response){
                    int year = jsons:getInt(response[index], "$.year");
                    string getDate = year + "";
                    float count = jsons:getFloat(response[index], "$.pqd_issues_count");

                    json currentJson = {"date" : getDate, "count" : count};
                    jsons:addToArray(responseJson, "$.data", currentJson);
                    index = index + 1;
                }

                return responseJson;

            }
        }

    }

    responseJson = {"error": true, "data":[]};

    return responseJson;
}


function getDataFromDatabase(sql:ClientConnector sqlCon, string sqlQuery, sql:Parameter[] paramsForQuery)(json){
    logger:debug("getDataFromDatabase function got invoked for sqlQuery : " + sqlQuery);

    datatable commonDt = sql:ClientConnector.select(sqlCon, sqlQuery, paramsForQuery);
    var commonVar, _ = <json>commonDt;
    logger:debug(commonVar);
    json commonDataResponseJson = commonVar;
    datatables:close(commonDt);
    return commonDataResponseJson;
}