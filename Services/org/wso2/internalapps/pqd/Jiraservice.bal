package org.wso2.internalapps.pqd;

import ballerina.net.http;
import org.wso2.ballerina.connectors.jira;
import ballerina.lang.jsons;
import ballerina.lang.messages;
import ballerina.data.sql;
import ballerina.lang.datatables;
import ballerina.utils.logger;
import ballerina.lang.strings;
import ballerina.lang.errors;
import ballerina.lang.system;
import ballerina.lang.time;

string jiraURL = jsons:getString(configData, "$.JIRA.JIRA_URL");
string jiraUsername = jsons:getString(configData, "$.JIRA.JIRA_USERNAME");
string jiraPassword = jsons:getString(configData, "$.JIRA.JIRA_PASSWORD");

struct JIRAProduct{
    int pqd_product_jira_id;
    string pqd_product_jira_key;
    string pqd_product_jira_name;
}
struct PQDProduct{
    int pqd_area_id;
    int pqd_product_id;
    int jira_project_id;
}

struct PQDIssueType {
    int pqd_issue_type_id;
    string pqd_issue_type;
}

struct JIRAIssueType {
    string pqd_issue_type;
}

struct JIRASeverity{
    string pqd_jira_severity;
}

struct PQDSeverity{
    int pqd_severity_id;
    string pqd_severity;
}

struct Product{
    string pqd_product_name;
    string pqd_product_id;
    string pqd_jira_project_key;
    string pqd_jira_project_name;
}

struct JiraComponent{
    int pqd_component_jira_id;

}
struct PQDComponent{
    int pqd_component_id;
    int jira_component_id;
}

struct JiraProductVersion{
    string  pqd_product_jira_version;
}
struct PQDProductVersion{
    int  pqd_product_version_id;
    string  pqd_product_version;
}

struct SnapshotId{
    int pqd_snapshot_id;
}

struct ProductIssueCount{
    int pqd_product_jira_id;
    string pqd_product_jira_name;
    float product_level_issues;

}
struct PQDProductIssueCount{
    int pqd_product_id;
    float product_level_issues;
}

struct ProductIssueCountHistory{
    int pqd_product_jira_id;
    string pqd_product_jira_name;
    float product_level_issues;
    string pqd_updated;
}

struct History{
    float issues;
    string pqd_updated;
}
struct HistoryByYear{
    float issues;
    int year;
}
struct HistoryByMonth{
    float issues;
    int year;
    int month;
}
struct HistoryByQuarter{
    float issues;
    int year;
    int quarter;
}

struct ALLCountHistory{
    float all_issues;
    string pqd_updated;
}
struct AreaCountHistory{
    float area_level_issues;
    string pqd_updated;
}

struct ComponentIssuesCount{
    int pqd_component_jira_id;
    string pqd_component_jira_name;
    float component_level_issues;
}
struct PQDComponentIssuesCount{
    int pqd_component_id;
    float component_level_issues;
}

struct IssueTypeIssuesCount{
    string pqd_jira_issue_type;
    float issue_type_level_issues;
}

struct PQDIssueTypeIssuesCount{
    int pqd_issue_type_id;
    float issue_type_level_issues;
}

struct SeverityIssuesCount{
    string pqd_jira_severity;
    float severity_level_issues;
}
struct PQDSeverityIssuesCount{
    int pqd_severity_id;
    float severity_level_issues;
}

struct VersionIssuesCount{
    string pqd_product_jira_version;
    float version_level_issues;
}

struct AreaIssuesCount{
    string pqd_area_name;
    float area_level_issues;
    int pqd_product_jira_id;
}

struct PQDAreaIssuesCount{
    int pqd_area_id;
    float area_level_issues;
}


@http:configuration {basePath:"/internal/product-quality/v1.0/jira", httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> JiraService {
    json configData = getConfigData(CONFIG_PATH);



    jira:ClientConnector jiraConnector = create jira:ClientConnector(jiraURL, jiraUsername, jiraPassword);

    @http:GET {}
    @http:Path {value:"/issues"}
    resource saveJiraIssues(message m) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json resp = getJiraIssues(jiraConnector, dbConnector);

        message response = {};
        messages:setJsonPayload(response, resp);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");

        dbConnector.close();
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/summary/all"}
    resource getAllJiraIssueSummary(message m) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data = getOverallJiraIssueSummary(dbConnector);

        message response = {};
        messages:setJsonPayload(response, data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        dbConnector.close();
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/summary/area/{area}"}
    resource getAreaLevelIssueSummary(message m, @http:PathParam {value:"area"} int area) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data =  getAreaLevelIssueSummary(area, dbConnector);

        message response = {};
        messages:setJsonPayload(response, data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        dbConnector.close();
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/summary/product/{product}"}
    resource getProductLevelIssueSummary(message m, @http:PathParam {value:"product"} int product) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data = getProductLevelIssueSummary(product, dbConnector);

        message response = {};
        messages:setJsonPayload(response, data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        dbConnector.close();
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/{product}/version/{version}"}
    resource getProductVersionLevelIssueSummary(message m ,@http:PathParam {value:"product"} int product, @http:PathParam {value:"version"} string version) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data = getProductVersionLevelIssueSummary(product, version, dbConnector);

        message response = {};
        messages:setJsonPayload(response, data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        dbConnector.close();
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/{product}/component/{component}"}
    resource getComponentLevelIssueSummaryTESTING(message m ,@http:PathParam {value:"product"} int product, @http:PathParam {value:"component"} int component) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data = getComponentLevelIssueSummaryT(product, component, dbConnector);

        message response = {};
        messages:setJsonPayload(response, data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        dbConnector.close();
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/component/{component}"}
    resource getComponentLevelIssueSummary(message m , @http:PathParam {value:"component"} int component) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data = getComponentLevelIssueSummary(component, dbConnector);

        message response = {};
        messages:setJsonPayload(response, data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        dbConnector.close();
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/history"}
    resource getHistory(message m,
                        @http:QueryParam {value:"product"} int product,
                        @http:QueryParam {value:"component"} int component,
                        @http:QueryParam {value:"version"} string version,
                        @http:QueryParam {value:"both"} string both,
                        @http:QueryParam {value:"issuetype"} string issuetype,
                        @http:QueryParam {value:"severity"} string severity,
                        @http:QueryParam {value:"dateFrom"} string dateFrom,
                        @http:QueryParam {value:"dateTo"} string dateTo,
                        @http:QueryParam {value:"period"} string period) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data = getHistory(product, component, version, both, issuetype, severity, dateFrom, dateTo, period, dbConnector);
        message response = {};
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        messages:setJsonPayload(response, data);
        dbConnector.close();
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/history/area"}
    resource getHistoryForAreas(message m,
                                @http:QueryParam {value:"area"} string area,
                                @http:QueryParam {value:"both"} string both,
                                @http:QueryParam {value:"issuetype"} string issuetype,
                                @http:QueryParam {value:"severity"} string severity,
                                @http:QueryParam {value:"dateFrom"} string dateFrom,
                                @http:QueryParam {value:"dateTo"} string dateTo,
                                @http:QueryParam {value:"period"} string period) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data = getHistoryForAreas(area, both, issuetype, severity, dateFrom, dateTo, period, dbConnector);
        message response = {};
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        messages:setJsonPayload(response, data);
        dbConnector.close();
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/history/all"}
    resource getHistoryForAll(message m,
                              @http:QueryParam {value:"both"} string both,
                              @http:QueryParam {value:"issuetype"} string issuetype,
                              @http:QueryParam {value:"severity"} string severity,
                              @http:QueryParam {value:"dateFrom"} string dateFrom,
                              @http:QueryParam {value:"dateTo"} string dateTo,
                              @http:QueryParam {value:"period"} string period) {
        sql:ClientConnector dbConnector = createIssuesDBcon();
        json data = getHistoryForAll(both, issuetype, severity, dateFrom, dateTo, period, dbConnector);
        message response = {};
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        messages:setJsonPayload(response, data);
        dbConnector.close();
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/saveHistory"}
    resource saveIssuesSummaryDaily(message m) {
        saveIssuesSummaryDaily();
        message response = {};
	messages:setJsonPayload(response, {"error":false});
        reply response;
    }

}




function getEverything(json projectList, json issueTypeList,  json severityList, sql:ClientConnector dbConnector){
    sql:Parameter[] params = [];

    logger:debug("getting JIRA product names from the database. Accessing query: GET_PRODUCT_DB_QUERY_VERSION2");
    datatable productDatatable = sql:ClientConnector.select(dbConnector, GET_PRODUCT_DB_QUERY_VERSION2, params);

    logger:debug("Iterating through productDatatable records.");
    while (datatables:hasNext(productDatatable)) {
        any productDataStruct = datatables:next(productDatatable);
        var productRowSet, _ = (PQDProduct)productDataStruct;

        int areaId = productRowSet.pqd_area_id;
        int productId = productRowSet.pqd_product_id;
        int jiraProjectId = productRowSet.jira_project_id;

        json project = {"area":areaId, "productID":productId, "jiraProjectId":jiraProjectId};
        jsons:addToArray(projectList, "$.projects", project);
    }
    datatables:close(productDatatable);

    logger:debug("getting JIRA issue types names from the database. Accessing query: GET_ISSUE_TYPE_DB_QUERY_VERSION2");
    datatable issueTypeDatatable = sql:ClientConnector.select(dbConnector, GET_ISSUE_TYPE_DB_QUERY, params);

    logger:debug("Iterating through issueTypeDatatable records.");
    while (datatables:hasNext(issueTypeDatatable)) {
        any issueTypeDataStruct = datatables:next(issueTypeDatatable);
        var issueTypeRowSet, _ = (PQDIssueType)issueTypeDataStruct;

        int issueTypeID = issueTypeRowSet.pqd_issue_type_id;
        string issueType = issueTypeRowSet.pqd_issue_type;

        json issuetypeJson = {"id":issueTypeID, "type":issueType};
        jsons:addToArray(issueTypeList, "$.issuetypes", issuetypeJson);

    }
    datatables:close(issueTypeDatatable);

    logger:debug("getting JIRA severity names from the database. Accessing query: GET_SEVERITY_DB_QUERY_VERSION2");
    datatable severityDatatable = sql:ClientConnector.select(dbConnector, GET_SEVERITY_DB_QUERY, params);

    logger:debug("Iterating through severityDatatable records.");
    while (datatables:hasNext(severityDatatable)) {
        any severityDataStruct = datatables:next(severityDatatable);
        var severityRowSet, _ = (PQDSeverity)severityDataStruct;

        int severityId = severityRowSet.pqd_severity_id;
        string severity = severityRowSet.pqd_severity;

        json severityJson = {"id":severityId, "severity":severity};
        jsons:addToArray(severityList, "$.severities", severityJson);

    }
    datatables:close(severityDatatable);

}




function getJiraIssues(jira:ClientConnector jiraConnector, sql:ClientConnector dbConnector)(json){

    int remainingCount = 10;
    int startAt = 0;
    int totalIssues;
    json jiraJSONResponse;
    json Result = {"data":[]};
    json finalResponse = {"error":{"status":false, "msg":""}};

    json projectList = {"projects":[]};
    json issueTypeList = {"issuetypes":[]};
    json severityList ={"severities":[]};

    getEverything(projectList, issueTypeList, severityList, dbConnector);

    logger:debug("creating JIRA project ids as a comma seperated string.");
    string projects = getProjectsAsString(projectList);
    logger:info("project ids to be searched: " + projects);

    logger:debug("creating JIRA issue types as a comma seperated string.");
    string issueTypes = getIssueTypeAsString(issueTypeList);
    logger:info("issue types to be searched: " + issueTypes);

    logger:debug("fetching data from JIRA.");
    while (remainingCount > 0) {
        try{
            json payload = {"jql":" project in ("+projects+") AND status in (Open, 'In Progress')" +
                                  "  AND issuetype in ("+issueTypes+")"
                           , "startAt":startAt, "maxResults":1000, "validateQuery":true,
                               "fields": ["project", "components","issuetype","customfield_10075", "versions"]};

            var stringPayload, _ = (string)payload;

            logger:debug("created jql payload for JIRA: " + stringPayload);

            logger:debug("invoking searchJira action in JIRA client connector with the payload.");
            message jiraResponse = jira:ClientConnector.searchJira(jiraConnector, payload);

            boolean[] statusCode = checkStatusCode(http:getStatusCode(jiraResponse));
            boolean statusCodeSuccess = statusCode[0];
            boolean hasErrorMessage = statusCode[1];

            jiraJSONResponse = messages:getJsonPayload(jiraResponse);

            if (statusCodeSuccess) {
                logger:info("fetched data succesully");
                totalIssues = jsons:getInt(jiraJSONResponse, "$.total");

                jsons:addToArray(Result, "$.data", jsons:getJson(jiraJSONResponse, "$.issues"));
            }
            else{
                if (hasErrorMessage) {
                    logger:error("error occurred while fetiching data from JIRA - "+createErrorMsg(jiraJSONResponse));
                }else{
                    logger:error("error occurred while fetiching data from JIRA");
                }
            }

            startAt = startAt + 1000;
            remainingCount = totalIssues - startAt;


        }catch(errors:Error err){
            logger:error("error occured while handling pagination. " + err.msg);
            finalResponse.error.status = true;
            finalResponse.error.msg = "Pagination failed.";
            return finalResponse;
        }
    }


    logger:info("finished fetching data from JIRA API.");

    int numOfPages = lengthof Result.data;

    if(numOfPages > 0){
        logger:debug("changing the format of each issue.");
        finalResponse = changeIssueFormat(projectList, issueTypeList, severityList, Result, finalResponse, dbConnector);
    }else{
        finalResponse.error.msg = "Zero data fetched";
    }

    return finalResponse;
}


function changeIssueFormat(json projectList, json issueTypeList, json severityList, json rawData,
                           json finalResponse, sql:ClientConnector dbConnector)(json){

    json issues = {"data":[]};
    json data = {"project":{}};

    int pageIndex = (lengthof rawData.data) - 1;
    json issue = {};

    try{
        while (pageIndex >= 0) {

            int totalNumOfIssues = lengthof rawData.data[pageIndex];
            int issueIndex = totalNumOfIssues - 1;

            while (issueIndex >= 0) {
                issue = rawData.data[pageIndex][issueIndex];
                jsons:addToObject(data, "$.project", "id", issue.fields.project.id);

                string issueType = jsons:getString(issue, "$.fields.issuetype.name");
                string severity;
                try {
                    severity = jsons:getString(issue,"$.fields.customfield_10075.value");
                }catch (errors:Error err) {
                    severity = "Unknown";
                }

                json components = {"components": []};
                json component = issue.fields.components;
                int lengthOfComponents = lengthof component;
                int componentIndex = lengthOfComponents - 1;

                while (componentIndex >= 0) {
                    json object = {"id": component[componentIndex].id, "name": component[componentIndex].name, "issuetype":issueType, "severity": severity};
                    jsons:addToArray(components, "$.components", object);
                    componentIndex = componentIndex-1;
                }
                jsons:addToObject(data, "$.project", "components", components.components);
                jsons:addToObject(data, "$.project", "issuetype", issueType);
                jsons:addToObject(data, "$.project", "severity", severity);

                json versions = {"versions": []};
                json projectVersions = issue.fields.versions;
                int lengthOfVersions = lengthof projectVersions;
                int versionIndex = lengthOfVersions - 1;

                if (versionIndex < 0) {
                    json object = {"name": "none", "issuetype":issueType, "severity": severity};
                    jsons:addToArray(versions, "$.versions", object);
                }

                while (versionIndex >= 0) {
                    json object = {"name": projectVersions[versionIndex].name, "issuetype":issueType, "severity": severity};
                    jsons:addToArray(versions, "$.versions", object);
                    versionIndex = versionIndex-1;
                }

                jsons:addToObject(data, "$.project", "version", versions.versions);
                jsons:addToArray(issues, "$.data", data);
                issueIndex = issueIndex - 1;
            }
            pageIndex = pageIndex -1;

        }

        logger:debug("finished formatting the issue json.");
        finalResponse = countIssues(projectList, issueTypeList, severityList, issues, finalResponse, dbConnector);

    }catch(errors:Error err){
        logger:error(err.msg);
        finalResponse.error.status = true;
        finalResponse.error.msg = "Error occurred while formatting JIRA issues";
        return finalResponse;
    }

    return finalResponse;

}


function getProjectsAsString(json projectList)(string){
    json projectIDs = jsons:getJson(projectList, "$.projects[*].jiraProjectId");
    int numOfProjects = lengthof projectIDs;
    string projects = "";

    if(numOfProjects > 0){
        int index = numOfProjects - 1;


        while (index >= 0) {
            int projectID = jsons:getInt(projectIDs, "$.["+index+"]");
            projects = projects + "'" + projectID + "',";
            index = index - 1;
        }

        int length = strings:length(projects);
        string result = strings:subString(projects, 0, length-1);

        return result;
    }
    return projects;
}


function getIssueTypeAsString(json issueTypeList)(string){
    json issuetypes = jsons:getJson(issueTypeList, "$.issuetypes[*].type");
    int numOfIssueTypes = lengthof issuetypes;
    string issueTypes = "";

    if(numOfIssueTypes > 0){
        int index = numOfIssueTypes - 1;


        while (index >= 0) {
            string issuetype = jsons:getString(issuetypes, "$.["+index+"]");
            issueTypes = issueTypes + "'" + issuetype + "',";
            index = index - 1;
        }

        int length = strings:length(issueTypes);
        string result = strings:subString(issueTypes, 0, length-1);
        return result;
    }

    return issueTypes;
}



function countTypeIssues(string date, json projectDetails, json issueTypeList, json severityList, json issues, sql:ClientConnector sqlCon){

    int numOfIssueTypes = lengthof issueTypeList.issuetypes;
    int index = numOfIssueTypes - 1;
    while (index >= 0) {
        int issueTypeId = jsons:getInt(issueTypeList.issuetypes, "$.["+index+"].id");
        string issueType = jsons:getString(issueTypeList.issuetypes, "$.["+index+"].type");

        string jsonPath = "$[?(@.issuetype == '"+issueType+"')]";
        projectDetails.jira_issue_type = issueTypeId;

        json typeIssues = jsons:getJson(issues, jsonPath);
        countSeverityIssues(date, projectDetails, severityList, typeIssues, sqlCon);

        index = index - 1;
    }

}




function countSeverityIssues(string date, json projectDetails, json severityList, json issueDetails, sql:ClientConnector sqlCon){

    int numOfSeverities = lengthof severityList.severities;
    int index = numOfSeverities - 1;

    while (index >= 0) {
        int severityId = jsons:getInt(severityList.severities, "$.["+index+"].id");
        string severity = jsons:getString(severityList.severities, "$.["+index+"].severity");

        string jsonPath = "$[?(@.severity == '"+severity+"')]";
        projectDetails.jira_severity = severityId;

        json severityIssues = jsons:getJson(issueDetails, jsonPath);
        int numOfIssues = lengthof severityIssues;

        if(numOfIssues != 0){
            int pqd_area_id = jsons:getInt(projectDetails, "$.pqd_area_id");
            int pqd_product_id = jsons:getInt(projectDetails, "$.pqd_product_id");
            int pqd_component_jira_id = jsons:getInt(projectDetails, "$.component_jira_id");
            int product_jira_version = jsons:getInt(projectDetails, "$.product_jira_version");
            int pqd_jira_issue_type = jsons:getInt(projectDetails, "$.jira_issue_type");
            int pqd_jira_severity = jsons:getInt(projectDetails, "$.jira_severity");

            saveIssuesInDatabase(pqd_area_id, pqd_product_id, pqd_component_jira_id, product_jira_version, pqd_jira_issue_type, pqd_jira_severity, date, numOfIssues, sqlCon);

        }
        index = index - 1;
    }
}


function saveIssuesInDatabase(int pqd_area_id, int pqd_product_id, int pqd_component_jira_id, int product_jira_version, int pqd_jira_issue_type, int pqd_jira_severity,string date, int numOfIssues, sql:ClientConnector sqlCon){
    sql:Parameter[] params = [];

    sql:Parameter pqd_area_id_para = {sqlType:"integer", value:pqd_area_id};
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:pqd_product_id};
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:pqd_component_jira_id};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"integer", value:product_jira_version};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"integer", value:pqd_jira_issue_type};
    sql:Parameter pqd_jira_severity_para = {sqlType:"integer", value:pqd_jira_severity};
    sql:Parameter pqd_issue_count_para = {sqlType:"integer", value:numOfIssues};
    sql:Parameter pqd_updated_para = {sqlType:"varchar", value:date};

    string query = "";
    if(pqd_component_jira_id == 0){
        if(product_jira_version == 0){
            logger:debug("saving issue summary data for product level. Accessing query: INSERT_JIRA_ISSUES_BY_PRODUCT.");
            params = [pqd_area_id_para, pqd_product_jira_id_para, pqd_jira_issue_type_para, pqd_jira_severity_para,
                      pqd_issue_count_para, pqd_updated_para];
            query = INSERT_JIRA_ISSUES_BY_PRODUCT;
        }else{
            logger:debug("saving issue summary data for product version level. Accessing query: INSERT_JIRA_ISSUES_BY_VERSION.");
            params = [pqd_product_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para, pqd_issue_count_para, pqd_updated_para];
            query = INSERT_JIRA_ISSUES_BY_VERSION;
        }
    }else{
        if(product_jira_version == 0){
            logger:debug("saving issue summary data for component level. Accessing query: INSERT_JIRA_ISSUES_BY_COMPONENT.");
            params = [pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_jira_issue_type_para, pqd_jira_severity_para, pqd_issue_count_para, pqd_updated_para];
            query = INSERT_JIRA_ISSUES_BY_COMPONENT;
        }
    }

    logger:debug("pqd_area_id: " + pqd_area_id + ", pqd_product_id: " + pqd_product_id + ", pqd_component_jira_id: " +
                 pqd_component_jira_id + ", product_jira_version: " + product_jira_version + ", pqd_jira_issue_type: " +
                 pqd_jira_issue_type + ", pqd_jira_severity: " + pqd_jira_severity + ", numOfIssues: " + numOfIssues +
                 ", date: " + date);

    int numOfUpdatedRows = sql:ClientConnector.update(sqlCon, query, params);
    logger:debug(numOfUpdatedRows + "number of rows got updated.");
}



function countStatusIssues(json ProjectIssueSummary, json issuesForProduct, string path){
    string[] statusList = ["Open", "In Progress"];
    int lengthOfStatus = statusList.length;
    int statusIssuesCount;
    int index = lengthOfStatus - 1;
    while (index >= 0) {
        string status = statusList[index];
        string jsonPath = path + "[?(@.status == '"+status+"')]";
        json statusIssues = jsons:getJson(issuesForProduct, jsonPath);
        statusIssuesCount = lengthof statusIssues;
        json statusTypeJson = {"name": status, "id":"", "issues": statusIssuesCount, "issuetype":[],
                                  "status":[], "component": []};
        jsons:addToArray(ProjectIssueSummary, "$.status", statusTypeJson);
        index = index - 1;
    }

}


function checkStatusCode(int statusCode)(boolean[]){
    logger:info("response status code: "+ statusCode);
    int leadingNum = statusCode / 100;
    boolean[] response;

    if (leadingNum == 2) {
        response = [true, false];
    }else if(leadingNum == 1 || leadingNum == 3){
        response = [false, false];
    }else{
        response = [false, true];
    }
    return response;
}


function createErrorMsg(json jiraJSONResponse)(string){
    string errorMsg = "";
    json errorMsgCountInString = jiraJSONResponse.errorMessages;
    int len = lengthof errorMsgCountInString;
    while (len > 0) {
        int index = len - 1;
        errorMsg = errorMsg + jsons:getString(errorMsgCountInString, "$.["+index+"]");
        len = len-1;
    }

    return errorMsg;
}


function getJIRAconfigData(json configData)(json){

    string JIRAurl;
    string JIRAusername;
    string JIRApassword;

    try {
        JIRAurl = jsons:getString(configData, "$.JIRA.JIRA_URL");
        JIRAusername = jsons:getString(configData, "$.JIRA.JIRA_USERNAME");
        JIRApassword = jsons:getString(configData, "$.JIRA.JIRA_PASSWORD");

    } catch (errors:Error err) {
        logger:error("Properties not defined in config.json: " + err.msg );
        JIRAurl = jsons:getString(configData, "$.JIRAurl");
        JIRAusername = jsons:getString(configData, "$.JIRAusername");
        JIRApassword = jsons:getString(configData, "$.JIRApassword");
    }

    json credentials = {"JIRAurl": JIRAurl,"username": JIRAusername,"password": JIRApassword};

    return credentials;

}


function countIssues(json projectList, json issueTypeList, json severityList, json data, json finalResponse,
                     sql:ClientConnector sqlCon)(json){

    int numOfProjects = lengthof projectList.projects;
    int projectIndex = numOfProjects - 1;
    int numOfUpdatedRows;
    json issues = {"data":[]};

    sql:Parameter[] params = [];

    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, DELETE_JIRA_ISSUES_BY_PRODUCT, params);
    logger:debug("deleted "+numOfUpdatedRows+" records from pqd_jira_issues_by_product table. Accessing query: DELETE_JIRA_ISSUES_BY_PRODUCT");

    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, DELETE_JIRA_ISSUES_BY_COMPONENT, params);
    logger:debug("deleted "+numOfUpdatedRows+" records from pqd_jira_issues_by_component table. Accessing query: DELETE_JIRA_ISSUES_BY_COMPONENT");

    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, DELETE_JIRA_ISSUES_BY_VERSION, params);
    logger:debug("deleted "+numOfUpdatedRows+" records from pqd_jira_issues_by_product_version table. Accessing query: DELETE_JIRA_ISSUES_BY_VERSION");

    int year;
    int month;
    int day;
    time:Time currentTime = time:currentTime();
    year, month, day = time:getDate(currentTime);
    string date = year + "-" + month + "-" + day;
    logger:debug("got current date." + year + ":" + month + ":" + day);

    logger:debug("counting issues for product, component and product version level.");
    try {
        while (projectIndex >= 0) {

            int projectId = jsons:getInt(projectList.projects, "$.[" + projectIndex + "].jiraProjectId");
            int areaId = jsons:getInt(projectList.projects, "$.[" + projectIndex + "].area");
            int productId = jsons:getInt(projectList.projects, "$.[" + projectIndex + "].productID");

            json projectDetails = {"pqd_area_id":areaId, "pqd_product_id":productId, "component_jira_id":0, "product_jira_version":0, "jira_issue_type":0, "jira_severity":0};

            json issuesForProduct = jsons:getJson(data, "$.data[*].project[?(@.id=='" + projectId + "')]");

            countTypeIssues(date, projectDetails, issueTypeList, severityList, issuesForProduct, sqlCon);

            sql:Parameter pqd_product_id_para = {sqlType:"integer", value:productId};
            params = [pqd_product_id_para];
            datatable componentsDatatable = sql:ClientConnector.select(sqlCon, GET_PROJECT_COMPONENTS, params);

            while (datatables:hasNext(componentsDatatable)) {
                any componentDataStruct = datatables:next(componentsDatatable);
                var componentRowSet, _ = (PQDComponent)componentDataStruct;

                int componentId = componentRowSet.pqd_component_id;
                int jiraComponentId = componentRowSet.jira_component_id;

                projectDetails.component_jira_id = componentId;
                json componentIssues = jsons:getJson(issuesForProduct, "$[*].components[?(@.id == '" + jiraComponentId + "')]");

                countTypeIssues(date, projectDetails, issueTypeList, severityList, issuesForProduct, sqlCon);
            }
            datatables:close(componentsDatatable);

            params = [pqd_product_id_para];
            datatable versionsDatatable = sql:ClientConnector.select(sqlCon, GET_PROJECT_VERSIONS, params);

            while (datatables:hasNext(versionsDatatable)) {
                any productVersionDataStruct = datatables:next(versionsDatatable);
                var productVersionRowSet, _ = (PQDProductVersion)productVersionDataStruct;

                int productVersionId = productVersionRowSet.pqd_product_version_id;
                string productVersion = productVersionRowSet.pqd_product_version;

                projectDetails.component_jira_id = 0;
                projectDetails.product_jira_version = productVersionId;
                json productVersionIssues = jsons:getJson(issuesForProduct, "$[*].version[?(@.name == '" + productVersion + "')]");

                countTypeIssues(date, projectDetails, issueTypeList, severityList, productVersionIssues, sqlCon);
            }

            datatables:close(versionsDatatable);
            projectIndex = projectIndex - 1;

        }
        finalResponse.error.status = false;
        finalResponse.error.msg = "succeed";

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        finalResponse.error.status = true;
        finalResponse.error.msg = err.msg;
        return finalResponse;
    }

    logger:info("finished counting and saving issues for product, component and product version levels.");
    return finalResponse;
}


function getOverallJiraIssueSummary(sql:ClientConnector sqlCon)(json){
    json data = {"error":false};
    json allAreas = {"name":"all", "items":[], "issuetype":[], "severity":[]};

    sql:Parameter[] params = [];

    try{
        logger:debug("getting issue count summary per area.");
        datatable allCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_FOR_AREA, params);

        while (datatables:hasNext(allCountTable)){
            any allCountDataStruct = datatables:next(allCountTable);
            var allCountRowSet, _ = (PQDAreaIssuesCount)allCountDataStruct;

            int areaId = allCountRowSet.pqd_area_id;
            float areaIssueCount = allCountRowSet.area_level_issues;

            json area = {"id":areaId, "issues":areaIssueCount};
            jsons:addToArray(allAreas, "$.items", area);
        }
        datatables:close(allCountTable);

        logger:debug("getting issue count summary per issue type.");
        datatable allProductIssueTypeTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_ALL, params);

        while (datatables:hasNext(allProductIssueTypeTable)) {
            any typeLevelCountDataStruct = datatables:next(allProductIssueTypeTable);
            var typeLevelCountRowSet, _ = (PQDIssueTypeIssuesCount)typeLevelCountDataStruct;

            int issueTypeId = typeLevelCountRowSet.pqd_issue_type_id;
            float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

            json issueType = {"id":issueTypeId, "issues":typeIssueCount};
            jsons:addToArray(allAreas, "$.issuetype", issueType);
        }
        datatables:close(allProductIssueTypeTable);

        logger:debug("getting issue count summary per severity.");
        datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_FOR_ALL, params);

        while (datatables:hasNext(AllProductSeverityCountTable)) {
            any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
            var severityLevelCountRowSet, _ = (PQDSeverityIssuesCount)severityLevelCountDataStruct;

            int severityId = severityLevelCountRowSet.pqd_severity_id;
            float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

            json severity = {"id":severityId, "issues":severityIssueCount};
            jsons:addToArray(allAreas, "$.severity", severity);
        }
        datatables:close(AllProductSeverityCountTable);

        jsons:addToObject(data, "$", "data",allAreas);
        logger:info("succefully created the overall issue count summary json");

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        data.error = true;
        jsons:addToObject(data, "$", "msg", err.msg);
        return data;
    }

    return data;
}



function getAreaLevelIssueSummary(int areaId, sql:ClientConnector sqlCon)(json){
    json data = {"error":false};
    json area = {"items":[], "issuetype":[], "severity":[]};

    sql:Parameter[] params = [];
    sql:Parameter pqd_product_area_para = {sqlType:"integer", value:areaId};

    try{
        params = [pqd_product_area_para];
        logger:debug("getting issue count summary of products " + areaId);
        datatable productCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_PRODUCT_FOR_AREA, params);

        while (datatables:hasNext(productCountTable)) {

            any productLevelCountDataStruct = datatables:next(productCountTable);
            var productLevelCountRowSet, _ = (PQDProductIssueCount)productLevelCountDataStruct;

            int productId = productLevelCountRowSet.pqd_product_id;
            float productIssueCount = productLevelCountRowSet.product_level_issues;

            json product = {"id":productId, "issues":productIssueCount};
            jsons:addToArray(area, "$.items", product);
        }
        datatables:close(productCountTable);

        params = [pqd_product_area_para ];
        logger:debug("getting issue count summary for issue types of area " + areaId);
        datatable allProductIssueTypeTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_AREA_TESTING, params);

        while (datatables:hasNext(allProductIssueTypeTable)) {
            any typeLevelCountDataStruct = datatables:next(allProductIssueTypeTable);
            var typeLevelCountRowSet, _ = (PQDIssueTypeIssuesCount)typeLevelCountDataStruct;

            int issueTypeId = typeLevelCountRowSet.pqd_issue_type_id;
            float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

            json issueType = {"id":issueTypeId, "issues":typeIssueCount};
            jsons:addToArray(area, "$.issuetype", issueType);

        }
        datatables:close(allProductIssueTypeTable);

        params = [pqd_product_area_para];
        logger:debug("getting issue count summary for severities of area " + areaId);
        datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_FOR_AREA_TESTING, params);

        while (datatables:hasNext(AllProductSeverityCountTable)) {
            any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
            var severityLevelCountRowSet, _ = (PQDSeverityIssuesCount)severityLevelCountDataStruct;

            int severityId = severityLevelCountRowSet.pqd_severity_id;
            float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

            json severity = {"id":severityId, "issues":severityIssueCount};
            jsons:addToArray(area, "$.severity", severity);
        }
        datatables:close(AllProductSeverityCountTable);

        jsons:addToObject(data, "$", "data",area);
        logger:info("succefully created the issue count summary json for area " + areaId);

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        data.error = true;
        jsons:addToObject(data, "$", "msg", err.msg);
        return data;
    }
    return data;
}



function getProductVersionLevelIssueSummary(int productId, string productVersion, sql:ClientConnector sqlCon)(json){
    json data = {"error":false};
    json version = {"items":[], "issuetype":[], "severity":[]};

    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:0};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
    params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_product_jira_id_para];

    datatable componentCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_COMPONENT, params);

    while (datatables:hasNext(componentCountTable)) {
        any componentLevelCountDataStruct = datatables:next(componentCountTable);
        var componentLevelCountRowSet, _ = (ComponentIssuesCount)componentLevelCountDataStruct;

        int componentId = componentLevelCountRowSet.pqd_component_jira_id;
        string componentName = componentLevelCountRowSet.pqd_component_jira_name;
        float componentIssueCount = componentLevelCountRowSet.component_level_issues;

        json component = {"name":componentName, "id":componentId, "issues":componentIssueCount};
        jsons:addToArray(version, "$.items", component);
    }
    datatables:close(componentCountTable);

    pqd_product_jira_version_para = {sqlType:"varchar", value:productVersion};
    params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_product_jira_id_para];

    datatable issueTypeCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE, params);

    while (datatables:hasNext(issueTypeCountTable)) {
        any typeLevelCountDataStruct = datatables:next(issueTypeCountTable);
        var typeLevelCountRowSet, _ = (IssueTypeIssuesCount)typeLevelCountDataStruct;

        string issueTypeName = typeLevelCountRowSet.pqd_jira_issue_type;
        float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

        json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};

        sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issueTypeName};

        params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_product_jira_id_para];

        datatable severityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE, params);

        while (datatables:hasNext(severityCountTable)) {
            any severityLevelCountDataStruct = datatables:next(severityCountTable);
            var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

            string severityName = severityLevelCountRowSet.pqd_jira_severity;
            float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

            json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};

            jsons:addToArray(issueType, "$.severity", severity);

        }
        datatables:close(severityCountTable);
        jsons:addToArray(version, "$.issuetype", issueType);

    }
    datatables:close(issueTypeCountTable);

    pqd_product_jira_version_para = {sqlType:"varchar", value:productVersion};
    pqd_component_jira_id_para = {sqlType:"integer", value:0};

    params = [pqd_product_jira_id_para, pqd_product_jira_version_para, pqd_component_jira_id_para];
    datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_PRODUCT, params);

    while (datatables:hasNext(AllProductSeverityCountTable)) {
        any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
        var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

        string severityName = severityLevelCountRowSet.pqd_jira_severity;
        float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

        json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};

        sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severityName};
        params = [pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];

        datatable issueTypeTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_SEVERITY_OF_PRODUCT, params);

        while (datatables:hasNext(issueTypeTable)) {
            any typeLevelDataStruct = datatables:next(issueTypeTable);
            var typeLevelRowSet, _ = (IssueTypeIssuesCount)typeLevelDataStruct;

            string issueTypeName = typeLevelRowSet.pqd_jira_issue_type;
            float typeIssueCount = typeLevelRowSet.issue_type_level_issues;

            json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};
            jsons:addToArray(severity, "$.issuetype", issueType);

        }
        datatables:close(issueTypeCountTable);
        jsons:addToArray(version, "$.severity", severity);
    }
    datatables:close(AllProductSeverityCountTable);

    jsons:addToObject(data, "$", "data",version);

    return data;
}



function getProductLevelIssueSummary(int productId, sql:ClientConnector sqlCon)(json){
    json data = {"error":false};
    json product = {"items":[], "issuetype":[], "severity":[]};

    sql:Parameter[] params = [];
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};

    try{
        params = [pqd_product_jira_id_para];
        logger:debug("getting issue count summary for product " + productId);
        datatable componentCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_COMPONENT_FOR_PRODUCT_TESTING, params);

        while (datatables:hasNext(componentCountTable)) {
            any componentLevelCountDataStruct = datatables:next(componentCountTable);
            var componentLevelCountRowSet, _ = (PQDComponentIssuesCount)componentLevelCountDataStruct;

            int componentId = componentLevelCountRowSet.pqd_component_id;
            float componentIssueCount = componentLevelCountRowSet.component_level_issues;

            json component = {"id":componentId, "issues":componentIssueCount};
            jsons:addToArray(product, "$.items", component);
        }
        datatables:close(componentCountTable);


        params = [pqd_product_jira_id_para];
        logger:debug("getting issue count summary for issue types of product " + productId);
        datatable issueTypeCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_PRODUCT_TESTING, params);

        while (datatables:hasNext(issueTypeCountTable)) {
            any typeLevelCountDataStruct = datatables:next(issueTypeCountTable);
            var typeLevelCountRowSet, _ = (PQDIssueTypeIssuesCount)typeLevelCountDataStruct;

            int issueTypeId = typeLevelCountRowSet.pqd_issue_type_id;
            float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

            json issueType = {"id":issueTypeId, "issues":typeIssueCount, "severity":[]};
            jsons:addToArray(product, "$.issuetype", issueType);

        }
        datatables:close(issueTypeCountTable);

        params = [pqd_product_jira_id_para];
        logger:debug("getting issue count summary for severities of product " + productId);
        datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_FOR_PRODUCT_TESTING, params);

        while (datatables:hasNext(AllProductSeverityCountTable)) {
            any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
            var severityLevelCountRowSet, _ = (PQDSeverityIssuesCount)severityLevelCountDataStruct;

            int severityId = severityLevelCountRowSet.pqd_severity_id;
            float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

            json severity = {"id":severityId, "issues":severityIssueCount};
            jsons:addToArray(product, "$.severity", severity);
        }
        datatables:close(AllProductSeverityCountTable);

        jsons:addToObject(data, "$", "data",product);
        logger:info("succefully created the issue count summary json for product " + productId);

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        data.error = true;
        jsons:addToObject(data, "$", "msg", err.msg);
        return data;
    }
    return data;

}

function getComponentLevelIssueSummaryT(int productId, int componentId, sql:ClientConnector sqlCon)(json){
    json data = {"error":false};
    json component = {"items":[], "issuetype":[], "severity":[]};

    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:componentId};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
    params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_product_jira_id_para];

    try{
        logger:debug("getting issue count summary for issue types of component " + componentId + " of product " + productId);
        datatable issueTypeCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE, params);

        while (datatables:hasNext(issueTypeCountTable)) {
            any typeLevelCountDataStruct = datatables:next(issueTypeCountTable);
            var typeLevelCountRowSet, _ = (IssueTypeIssuesCount)typeLevelCountDataStruct;

            string issueTypeName = typeLevelCountRowSet.pqd_jira_issue_type;
            float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

            json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};

            sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issueTypeName};
            params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_product_jira_id_para];

            logger:debug("getting issue count summary for severities of issueType " + issueTypeName + " for component " + componentId);
            datatable severityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE, params);

            while (datatables:hasNext(severityCountTable)) {
                any severityLevelCountDataStruct = datatables:next(severityCountTable);
                var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

                string severityName = severityLevelCountRowSet.pqd_jira_severity;
                float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

                json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};

                jsons:addToArray(issueType, "$.severity", severity);

            }
            datatables:close(severityCountTable);
            jsons:addToArray(component, "$.issuetype", issueType);
        }
        datatables:close(issueTypeCountTable);


        params = [pqd_component_jira_id_para, pqd_product_jira_version_para];
        logger:debug("getting issue count summary for severities of component " + componentId + " of product " + productId);
        datatable severityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_COMPONENT, params);

        while (datatables:hasNext(severityCountTable)) {
            any severityLevelCountDataStruct = datatables:next(severityCountTable);
            var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

            string severityName = severityLevelCountRowSet.pqd_jira_severity;
            float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

            json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};

            sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severityName};
            params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];

            logger:debug("getting issue count summary for issuetypes of severity " + severityName + " for component " + componentId);
            datatable issueTypeCountTable2 = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE2, params);

            while (datatables:hasNext(issueTypeCountTable2)) {
                any typeLevelCountDataStruct = datatables:next(issueTypeCountTable2);
                var typeLevelCountRowSet, _ = (IssueTypeIssuesCount)typeLevelCountDataStruct;

                string issueTypeName = typeLevelCountRowSet.pqd_jira_issue_type;
                float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

                json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};
                jsons:addToArray(severity, "$.issuetype", issueType);

            }
            datatables:close(issueTypeCountTable2);
            jsons:addToArray(component, "$.severity", severity);
        }
        datatables:close(severityCountTable);

        jsons:addToObject(data, "$", "data",component);
        logger:info("succefully created the issue count summary json for component " + componentId);

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        data.error = true;
        jsons:addToObject(data, "$", "msg", err.msg);
        return data;
    }

    return data;
}

function getComponentLevelIssueSummary(int componentId, sql:ClientConnector sqlCon)(json){

    json data = {"error":false};
    json component = {"items":[], "issuetype":[], "severity":[]};

    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:componentId};

    try{
        params = [pqd_component_jira_id_para];
        logger:debug("getting issue count summary for issue types of component " + componentId);
        datatable issueTypeCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_COMPONENT_TESTING, params);

        while (datatables:hasNext(issueTypeCountTable)) {
            any typeLevelCountDataStruct = datatables:next(issueTypeCountTable);
            var typeLevelCountRowSet, _ = (PQDIssueTypeIssuesCount)typeLevelCountDataStruct;

            int issueTypeId = typeLevelCountRowSet.pqd_issue_type_id;
            float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

            json issueType = {"id":issueTypeId, "issues":typeIssueCount};
            jsons:addToArray(component, "$.issuetype", issueType);
        }
        datatables:close(issueTypeCountTable);


        params = [pqd_component_jira_id_para];
        logger:debug("getting issue count summary for severities of component " + componentId);
        datatable severityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_FOR_COMPONENT_TESTING, params);

        while (datatables:hasNext(severityCountTable)) {
            any severityLevelCountDataStruct = datatables:next(severityCountTable);
            var severityLevelCountRowSet, _ = (PQDSeverityIssuesCount)severityLevelCountDataStruct;

            int severityId = severityLevelCountRowSet.pqd_severity_id;
            float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

            json severity = {"id":severityId, "issues":severityIssueCount};
            jsons:addToArray(component, "$.severity", severity);
        }
        datatables:close(severityCountTable);

        jsons:addToObject(data, "$", "data",component);
        logger:info("succefully created the issue count summary json for component " + componentId);

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        data.error = true;
        jsons:addToObject(data, "$", "msg", err.msg);
        return data;
    }
    return data;

}

function getHistoryForAll(string both, string issuetype, string severity,string dateFrom, string dateTo,
                          string period, sql:ClientConnector sqlCon)(json){
    json data = {"error":false};
    json history = {"data":[]};

    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:0};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issuetype};
    sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severity};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    datatable historyTable;


    try{
        if(period == "day"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_FOR_ALL, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_FOR_ALL, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_FOR_ALL, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_ALL, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (History)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                string date = areaLevelHistoryRowSet.pqd_updated;

                json info = {"date":date, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }

        }else if(period == "Year"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_FOR_ALL_BY_YEAR, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_ALL_BY_YEAR, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_FOR_ALL_BY_YEAR, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para,  pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_ALL_BY_YEAR, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByYear)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;

                json info = {"date":year, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }

        }else if(period == "Month"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_FOR_ALL_BY_MONTH, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_ALL_BY_MONTH, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_FOR_ALL_BY_MONTH, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_ALL_BY_MONTH, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByMonth)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;
                int month = areaLevelHistoryRowSet.month;

                json info = {"date":year+" "+month, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }

        }else if(period == "Quarter"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_FOR_ALL_BY_QUARTER, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_ALL_BY_QUARTER, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_FOR_ALL_BY_QUARTER, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_ALL_BY_QUARTER, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByQuarter)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;
                int quarter = areaLevelHistoryRowSet.quarter;

                json info = {"date":year + "-Q" + quarter, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }
        }

        jsons:addToObject(data, "$", "data",history);
        logger:info("successfully created the history json.");

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        data.error = true;
        jsons:addToObject(data, "$", "msg", err.msg);
    }

    datatables:close(historyTable);
    return data;

}



function getHistoryForAreas(string area, string both, string issuetype, string severity,string dateFrom, string dateTo,
                            string period, sql:ClientConnector sqlCon)(json){
    json data = {"error":false};
    json history = {"data":[]};

    sql:Parameter[] params = [];
    sql:Parameter pqd_product_area_para = {sqlType:"varchar", value:area};
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:0};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issuetype};
    sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severity};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    datatable historyTable;

    try{
        if(period == "day"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_FOR_AREA, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_AREA, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_FOR_AREA, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_AREA, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (History)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                string date = areaLevelHistoryRowSet.pqd_updated;

                json info = {"date":date, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }

        }else if(period == "Year"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_FOR_AREA_BY_YEAR, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_AREA_BY_YEAR, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_FOR_AREA_BY_YEAR, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_AREA_BY_YEAR, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByYear)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;

                json info = {"date":year, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }
        }else if(period == "Month"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_FOR_AREA_BY_MONTH, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_AREA_BY_MONTH, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_FOR_AREA_BY_MONTH, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_AREA_BY_MONTH, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByMonth)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;
                int month = areaLevelHistoryRowSet.month;

                json info = {"date":year+" "+month, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }
        }else if(period == "Quarter"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_FOR_AREA_BY_QUARTER, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_FOR_AREA_BY_QUARTER, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_FOR_AREA_BY_QUARTER, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_product_area_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_FOR_AREA_BY_QUARTER, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByQuarter)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;
                int quarter = areaLevelHistoryRowSet.quarter;

                json info = {"date":year + "-Q" + quarter, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }
        }

        jsons:addToObject(data, "$", "data",history);
        logger:info("successfully created the history json.");

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        data.error = true;
        jsons:addToObject(data, "$", "msg", err.msg);
    }

    datatables:close(historyTable);
    return data;
}

function getHistory(int product, int component, string productVersion, string both, string issuetype, string severity,
                    string dateFrom, string dateTo, string period, sql:ClientConnector sqlCon)(json){
    json data = {"error":false};
    json history = {"data":[]};

    sql:Parameter[] params = [];
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:product};
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:component};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:productVersion};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issuetype};
    sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severity};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    datatable historyTable;

    try{
        if(period == "day"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY, params);

            }

            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (History)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                string date = areaLevelHistoryRowSet.pqd_updated;

                json info = {"date":date, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }

        }else if(period == "Year"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_BY_YEAR, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_BY_YEAR, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_BY_YEAR, params);

                }
            }else if(both == "yes"){
                system:println("both");
                params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_BY_YEAR, params);

            }

            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByYear)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;

                json info = {"date":year, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }
        }else if(period == "Month"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_BY_MONTH, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_BY_MONTH, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_BY_MONTH, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_BY_MONTH, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByMonth)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;
                int month = areaLevelHistoryRowSet.month;

                json info = {"date":year+" "+month, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }
        }else if(period == "Quarter"){
            if(both == "no"){
                if(issuetype == "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_BY_QUARTER, params);

                }else if(issuetype != "no" && severity == "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_BY_QUARTER, params);

                }else if(issuetype == "no" && severity != "no"){
                    params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];
                    historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_SEVERITY_BY_QUARTER, params);

                }
            }else if(both == "yes"){
                params = [pqd_date_from_para, pqd_date_to_para, pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
                historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER, params);

            }
            while (datatables:hasNext(historyTable)) {
                any areaLevelHistoryDataStruct = datatables:next(historyTable);
                var areaLevelHistoryRowSet, _ = (HistoryByQuarter)areaLevelHistoryDataStruct;

                float IssueCount = areaLevelHistoryRowSet.issues;
                int year = areaLevelHistoryRowSet.year;
                int quarter = areaLevelHistoryRowSet.quarter;

                json info = {"date":year + "-Q" + quarter, "count":IssueCount};
                jsons:addToArray(history, "$.data", info);

            }
        }

        jsons:addToObject(data, "$", "data",history);
        logger:info("successfully created the history json.");

    }catch(errors:Error err){
        logger:error("error occurred. " + err.msg);
        data.error = true;
        jsons:addToObject(data, "$", "msg", err.msg);
    }

    datatables:close(historyTable);
    return data;
}

function saveIssuesSummaryDaily(){
    sql:ClientConnector sqlCon = createIssuesDBcon();
    sql:Parameter[] params = [];
    int numOfUpdatedRows;
    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_HISTORY_BY_PRODUCT, params);
    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_HISTORY_BY_VERSION, params);
    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_HISTORY_BY_COMPONENT, params);
    sqlCon.close();
}



