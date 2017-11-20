package org.wso2.internalapps.pqd;

import ballerina.net.http;
import org.wso2.ballerina.connectors.jira;
import ballerina.lang.jsons;
import ballerina.lang.messages;
import org.wso2.ballerina.connectors.basicauth;
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

    jira:ClientConnector jiraConnector = create jira:ClientConnector(jiraURL, jiraUsername, jiraPassword);


    @http:GET {}
    @http:Path {value:"/issues/summary/testing"}
    resource AllJiraIssuesByProjectTESTING (message m) {
        json projectList = {"projects":[]};
        json issueTypeList = {"issuetypes":[]};
        json severityList ={"severities":[]};

        logger:debug("creating sql client connector..");
        sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

        getProjectNamesIssueTypesAndSeveritiesTESTING2(projectList, issueTypeList, severityList, dbConnector);
        message response = getJiraIssuesSummaryTESTING2(projectList, issueTypeList, severityList, jiraConnector, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/test"}
    resource test(message m,
                  @http:QueryParam {value:"dateFrom"} string dateFrom,
                  @http:QueryParam {value:"dateTo"} string dateTo) {

        //message response = getProjectVersions("DAS");
        message response = {};
        system:println(dateFrom);
        system:println(dateTo);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/getJiraIssues"}
    resource getJiraIssues(message m) {
        //message response = getIssueCount();
        message response = {};
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/get/{product}"}
    resource get(message m, @http:PathParam {value:"product"} string product) {
        //saveIssuesSummaryDaily();
        message response = getProjectVersions(product);
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/all"}
    resource getAllIssueSummary(message m) {
        json data = getAllIssueSummary();
        message response = {};
        messages:setJsonPayload(response, data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/all/testing"}
    resource getAllIssueSummaryTesting(message m) {
        json data = getAllIssueSummaryTESTING();
        message response = {};
        messages:setJsonPayload(response, data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/summary/area/{area}"}
    resource getAreaLevelIssueSummary(message m, @http:PathParam {value:"area"} string area) {
        system:println(area);
        message response =  getAreaLevelIssueSummary(area);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/area/{area}/testing"}
    resource getAreaLevelIssueSummaryTesting(message m, @http:PathParam {value:"area"} int area) {
        message response =  getAreaLevelIssueSummaryTESTING(area);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/product/{product}"}
    resource getProductLevelIssueSummary(message m, @http:PathParam {value:"product"} int product) {
        message response = getProductLevelIssueSummary(product);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/product/{product}/testing"}
    resource getProductLevelIssueSummaryTesting(message m, @http:PathParam {value:"product"} int product) {
        message response = getProductLevelIssueSummaryTESTING(product);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/{product}/version/{version}"}
    resource getProductVersionLevelIssueSummary(message m ,@http:PathParam {value:"product"} int product, @http:PathParam {value:"version"} string version) {
        message response = getProductVersionLevelIssueSummary(product, version);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/{product}/component/{component}"}
    resource getComponentLevelIssueSummary(message m ,@http:PathParam {value:"product"} int product, @http:PathParam {value:"component"} int component) {
        message response = getComponentLevelIssueSummary(product, component);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/component/{component}/testing"}
    resource getComponentLevelIssueSummaryTESTING(message m , @http:PathParam {value:"component"} int component) {
        message response = getComponentLevelIssueSummaryTESTING(component);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
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

        json data = getHistory(product, component, version, both, issuetype, severity, dateFrom, dateTo, period);
        message response = {};
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        messages:setJsonPayload(response, data);
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

        json data = getHistoryForAreas(area, both, issuetype, severity, dateFrom, dateTo, period);
        message response = {};
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        messages:setJsonPayload(response, data);
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

        json data = getHistoryForAll(both, issuetype, severity, dateFrom, dateTo, period);
        message response = {};
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");
        messages:setJsonPayload(response, data);
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/saveHistory"}
    resource saveHistory(message m) {
        saveIssuesSummaryDaily();
        message response = {};
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/saveHistory/testing"}
    resource saveIssuesSummaryDailyTESTING(message m) {
        saveIssuesSummaryDailyTESTING();
        message response = {};
        reply response;
    }




}


function getProjectComponents(string projectKey)(json){

    basicauth:ClientConnector jiraEP = create basicauth:ClientConnector(jiraURL, jiraUsername, jiraPassword);
    message request = {};
    string jiraPath = "/rest/api/2/project/"+projectKey+"/components";


    message response = basicauth:ClientConnector.get(jiraEP, jiraPath, request);
    json body = messages:getJsonPayload(response);
    json componentNameList = jsons:getJson(body, "$.*.name");
    json componentIdList = jsons:getJson(body, "$.*.id");
    json componentList = {"componentIdList": componentIdList, "componentNameList": componentNameList};
    return componentList;

}

function getProjectVersions(string projectKey)(message){

    basicauth:ClientConnector jiraEP = create basicauth:ClientConnector(jiraURL, jiraUsername, jiraPassword);
    message request = {};
    string jiraPath =  "/rest/api/2/project/"+projectKey;
    //string jiraPath = "/rest/api/2/project/"+projectKey+"";
    message response = basicauth:ClientConnector.get(jiraEP, jiraPath, request);
    return response;

}

function enterData()(message){

    string[] a = [

                 ];

    string[] b =[

                ];

    int j = lengthof b;
    int i = j-1;
    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];
    sql:Parameter para = {sqlType:"integer", value:10023};

    while(i >= 0){
        string num = b[i];
        //var x,_ = <int>num;
        //sql:Parameter para1 = {sqlType:"varchar", value:a[i]};
        sql:Parameter para2 = {sqlType:"varchar", value:num};
        params = [para, para2];

        int q = sql:ClientConnector.update(sqlCon, "INSERT INTO pqd_product_jira_version (pqd_product_jira_id, pqd_product_jira_version)" +
                                                   " VALUES (?,?)", params);
//int q = sql:ClientConnector.update(sqlCon, "INSERT INTO pqd_component_jira (pqd_component_jira_id, pqd_product_jira_id, " +
//                                                   " 	pqd_component_jira_name) VALUES (?,?,?)", params);

        i = i -1;
    }

    message Response ={};
    messages:setStringPayload(Response,"OK");
    return Response;

}



function getProjectsIssueTypesAndSeverities(json projectList, string[] issueTypeList, string[] severityList, sql:ClientConnector dbConnector){
    sql:Parameter[] params = [];

    logger:debug("getting JIRA product names from the database. Accessing query: GET_PRODUCT_DB_QUERY");
    datatable productDatatable = sql:ClientConnector.select(dbConnector, GET_PRODUCT_DB_QUERY, params);

    logger:debug("Iterating through productDatatable records.");
    while (datatables:hasNext(productDatatable)) {
        any productDataStruct = datatables:next(productDatatable);
        var productRowSet, _ = (JIRAProduct)productDataStruct;

        string projectKey = productRowSet.pqd_product_jira_key;
        int projectId = productRowSet.pqd_product_jira_id;

        json project = {"key":projectKey, "id":projectId};
        jsons:addToArray(projectList, "$.projects", project);
    }
    datatables:close(productDatatable);

    logger:debug("getting JIRA issue types names from the database. Accessing query: GET_ISSUE_TYPE_DB_QUERY");
    datatable issueTypeDatatable = sql:ClientConnector.select(dbConnector, GET_ISSUE_TYPE_DB_QUERY, params);
    int index = 0;

    logger:debug("Iterating through productDatatable records.");
    while (datatables:hasNext(issueTypeDatatable)) {
        any issueTypeDataStruct = datatables:next(issueTypeDatatable);
        var issueTypeRowSet, _ = (JIRAIssueType)issueTypeDataStruct;

        string issueType = issueTypeRowSet.pqd_issue_type;

        issueTypeList[index] = issueType;
        index = index + 1;

    }
    datatables:close(issueTypeDatatable);

    datatable severityDatatable = sql:ClientConnector.select(dbConnector, GET_SEVERITY_DB_QUERY, params);
    index = 0;

    logger:debug("Iterating through productDatatable records.");
    while (datatables:hasNext(severityDatatable)) {
        any severityDataStruct = datatables:next(severityDatatable);
        var severityRowSet, _ = (JIRASeverity )severityDataStruct;

        string severity = severityRowSet.pqd_jira_severity;

        severityList[index] = severity;
        index = index + 1;
    }
    datatables:close(severityDatatable);

}
function getProjectNamesIssueTypesAndSeveritiesTESTING2(json projectList, json issueTypeList,  json severityList, sql:ClientConnector dbConnector){
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
    datatable issueTypeDatatable = sql:ClientConnector.select(dbConnector, GET_ISSUE_TYPE_DB_QUERY_VERSION2, params);

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
    datatable severityDatatable = sql:ClientConnector.select(dbConnector, GET_SEVERITY_DB_QUERY_VERSION2, params);

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


function getJiraIssuesSummary(json projectList, string[] issueTypeList, string[] severityList, jira:ClientConnector jiraConnector, sql:ClientConnector dbConnector)(message ){

    int remainingCount = 10;
    int startAt = 0;
    int totalIssues;
    int numOfPages = 0;
    json jiraJSONResponse;
    json Result = {"data":[], "error": false};
    string projects = getProjectsAsString(projectList);
    string issueTypes = getIssueTypeAsString(issueTypeList);

    system:println("getting data");
    while (remainingCount > 0) {
        json payload = {"jql":" project in ("+projects+") AND status in (Open, 'In Progress')" +
                              "  AND issuetype in ("+issueTypes+")"
                       , "startAt":startAt, "maxResults":1000, "validateQuery":true,
                           "fields": ["project", "components","issuetype","customfield_10075", "versions"]};

        message jiraResponse = jira:ClientConnector.searchJira(jiraConnector, payload);

        boolean[] statusCode = checkStatusCode(http:getStatusCode(jiraResponse));
        boolean statusCodeSuccess = statusCode[0];
        boolean hasErrorMessage = statusCode[1];

        jiraJSONResponse = messages:getJsonPayload(jiraResponse);

        if (statusCodeSuccess) {
            totalIssues = jsons:getInt(jiraJSONResponse, "$.total");
            startAt = startAt + 1000;
            remainingCount = totalIssues - startAt;

            jsons:addToArray(Result, "$.data", jsons:getJson(jiraJSONResponse, "$.issues"));

        }
        else{
            if (hasErrorMessage) {
                logger:error("errorMessage: "+createErrorMsg(jiraJSONResponse));
                Result.error = true;
            }else{
                logger:error("error");
                Result.error = true;
            }
        }
        numOfPages = numOfPages + 1;
    }

    boolean error = jsons:getBoolean(Result, "$.error");
    system:println("got data");

    message Response = {};
    if (!error){
        changeIssueFormat(projectList, issueTypeList, severityList, Result, numOfPages);
    }
    messages:setStringPayload(Response,"OK");
    return Response;
}

function getJiraIssuesSummaryTESTING2(json projectList, json issueTypeList, json severityList, jira:ClientConnector jiraConnector, sql:ClientConnector dbConnector)(message ){

    int remainingCount = 10;
    int startAt = 0;
    int totalIssues;
    int numOfPages = 0;
    json jiraJSONResponse;
    json Result = {"data":[], "error": false};

    logger:debug("creating JIRA project ids as a comma seperated string.");
    string projects = getProjectsAsStringTESTING2(projectList);
    logger:info("project ids to be searched: " + projects);

    logger:debug("creating JIRA issue types as a comma seperated string.");
    string issueTypes = getIssueTypeAsStringTESTING2(issueTypeList);
    logger:info("issue types to be searched: " + issueTypes);

    logger:debug("fetching data from JIRA.");
    while (remainingCount > 0) {
        json payload = {"jql":" project in ("+projects+") AND status in (Open, 'In Progress')" +
                              "  AND issuetype in ("+issueTypes+")"
                       , "startAt":startAt, "maxResults":1000, "validateQuery":true,
                           "fields": ["project", "components","issuetype","customfield_10075", "versions"]};

        var stringPayload, _ = <json>payload;
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
            startAt = startAt + 1000;
            remainingCount = totalIssues - startAt;

            jsons:addToArray(Result, "$.data", jsons:getJson(jiraJSONResponse, "$.issues"));

        }
        else{
            if (hasErrorMessage) {
                logger:error("errorMessage: "+createErrorMsg(jiraJSONResponse));
                Result.error = true;
            }else{
                logger:error("error");
                Result.error = true;
            }
        }
        numOfPages = numOfPages + 1;
    }

    logger:info("finished fetching data from JIRA API.");
    boolean error = jsons:getBoolean(Result, "$.error");

    message Response = {};
    if (!error){
        changeIssueFormatTESTING2(projectList, issueTypeList, severityList, Result, numOfPages, dbConnector);
    }
    messages:setStringPayload(Response,"OK");
    //messages:setJsonPayload(Response,Result);
    return Response;
}


function changeIssueFormatTESTING2(json projectList, json issueTypeList, json severityList, json rawData, int numOfPages, sql:ClientConnector dbConnector){

    json issues = {"data":[]};
    json data = {"project":{}};

    int index1 = numOfPages - 1;
    json issue = {};

    logger:debug("reformatting the issue json.");
    while (index1 >= 0) {
        int totalNumOfIssues = lengthof rawData.data[index1];
        int index2 = totalNumOfIssues - 1;
        while (index2 >= 0) {
            issue = rawData.data[index1][index2];
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
            int index3 = lengthOfComponents - 1;

            while (index3 >= 0) {
                json object = {"id": component[index3].id, "name": component[index3].name, "issuetype":issueType, "severity": severity};
                jsons:addToArray(components, "$.components", object);
                index3 = index3-1;
            }
            jsons:addToObject(data, "$.project", "components", components.components);
            jsons:addToObject(data, "$.project", "issuetype", issueType);
            jsons:addToObject(data, "$.project", "severity", severity);

            json versions = {"versions": []};
            json version = issue.fields.versions;
            int lengthOfVersions = lengthof version;
            int index4 = lengthOfVersions - 1;

            if (index4 < 0) {
                json object = {"name": "none", "issuetype":issueType, "severity": severity};
                jsons:addToArray(versions, "$.versions", object);
            }

            while (index4 >= 0) {
                json object = {"name": version[index4].name, "issuetype":issueType, "severity": severity};
                jsons:addToArray(versions, "$.versions", object);
                index4 = index4-1;
            }

            jsons:addToObject(data, "$.project", "version", versions.versions);
            jsons:addToArray(issues, "$.data", data);
            index2 = index2 - 1;
        }
        index1 = index1 -1;

    }

    logger:debug("finished reformatting the issue json.");
    countIssuesTESTING2(projectList, issueTypeList, severityList, issues, dbConnector);

}


function getProjectsAsStringTESTING2(json projectList)(string){
    json projectIDs = jsons:getJson(projectList, "$.projects[*].jiraProjectId");
    int numOfProjects = lengthof projectIDs;

    if(numOfProjects > 0){
        int index = numOfProjects - 1;
        string projects = "";

        while (index >= 0) {
            int projectID = jsons:getInt(projectIDs, "$.["+index+"]");
            projects = projects + "'" + projectID + "',";
            index = index - 1;
        }

        int length = strings:length(projects);
        string result = strings:subString(projects, 0, length-1);

        return result;
    }
    return null;
}


function getIssueTypeAsStringTESTING2(json issueTypeList)(string){
    json issuetypes = jsons:getJson(issueTypeList, "$.issuetypes[*].type");
    int numOfIssueTypes = lengthof issuetypes;

    if(numOfIssueTypes > 0){
        int index = numOfIssueTypes - 1;
        string issueTypes = "";

        while (index >= 0) {
            string issuetype = jsons:getString(issuetypes, "$.["+index+"]");
            issueTypes = issueTypes + "'" + issuetype + "',";
            index = index - 1;
        }

        int length = strings:length(issueTypes);
        string result = strings:subString(issueTypes, 0, length-1);
        return result;
    }

    return null;
}





function countTypeIssues(string date, json projectDetails, string[] issueTypeList, string[] severityList, json issues, string path, sql:ClientConnector sqlCon){

    int lengthOfTypes = issueTypeList.length;
    int index = lengthOfTypes - 1;
    while (index >= 0) {
        string issueType = issueTypeList[index];
        string jsonPath = path + "[?(@.issuetype == '"+issueType+"')]";
        projectDetails.jira_issue_type = issueType;

        json typeIssues = jsons:getJson(issues, jsonPath);
        countSeverityIssues(date, projectDetails, severityList, typeIssues, "$", sqlCon);

        index = index - 1;
    }
}

function countTypeIssuesTESTING2(string date, json projectDetails, json issueTypeList, json severityList, json issues, string path, sql:ClientConnector sqlCon){

    int numOfIssueTypes = lengthof issueTypeList.issuetypes;
    int index = numOfIssueTypes - 1;
    while (index >= 0) {
        int issueTypeId = jsons:getInt(issueTypeList.issuetypes, "$.["+index+"].id");
        string issueType = jsons:getString(issueTypeList.issuetypes, "$.["+index+"].type");

        string jsonPath = path + "[?(@.issuetype == '"+issueType+"')]";
        projectDetails.jira_issue_type = issueTypeId;

        json typeIssues = jsons:getJson(issues, jsonPath);
        countSeverityIssuesTESTING2(date, projectDetails, severityList, typeIssues, "$", sqlCon);

        index = index - 1;
    }

}


function countSeverityIssues(string date, json projectDetails, string[] severityList, json typeIssues, string path, sql:ClientConnector sqlCon){
    int lengthOfSeverityArray = severityList.length;

    int index = lengthOfSeverityArray - 1;

    while (index >= 0) {
        string severity = severityList[index];
        projectDetails.jira_severity = severity;
        string jsonPath = path + "[?(@.severity == '"+severity+"')]";

        json severityIssues = jsons:getJson(typeIssues, jsonPath);
        int numOfIssues = lengthof severityIssues;

        if(numOfIssues != 0){

            int pqd_product_jira_id = jsons:getInt(projectDetails, "$.product_jira_id");
            int pqd_component_jira_id = jsons:getInt(projectDetails, "$.component_jira_id");
            string product_jira_version = jsons:getString(projectDetails, "$.product_jira_version");
            string pqd_jira_issue_type = jsons:getString(projectDetails, "$.jira_issue_type");
            string pqd_jira_severity = jsons:getString(projectDetails, "$.jira_severity");

            saveIssuesInDatabase(pqd_product_jira_id, pqd_component_jira_id, product_jira_version, pqd_jira_issue_type, pqd_jira_severity, date, numOfIssues, sqlCon);
            //saveIssuesInDatabase(pqd_product_jira_id, pqd_component_jira_id, product_jira_version, pqd_jira_issue_type, pqd_jira_severity, snapshotId, numOfIssues, sqlCon);
        }
        index = index - 1;
    }
}





function countSeverityIssuesTESTING2(string date, json projectDetails, json severityList, json issueDetails, string path, sql:ClientConnector sqlCon){

    int numOfSeverities = lengthof severityList.severities;
    int index = numOfSeverities - 1;

    while (index >= 0) {
        int severityId = jsons:getInt(severityList.severities, "$.["+index+"].id");
        string severity = jsons:getString(severityList.severities, "$.["+index+"].severity");

        string jsonPath = path + "[?(@.severity == '"+severity+"')]";
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

            saveIssuesInDatabaseTESTING2(pqd_area_id, pqd_product_id, pqd_component_jira_id, product_jira_version, pqd_jira_issue_type, pqd_jira_severity, date, numOfIssues, sqlCon);

        }
        index = index - 1;
    }
}


function saveIssuesInDatabaseTESTING2(int pqd_area_id, int pqd_product_id, int pqd_component_jira_id, int product_jira_version, int pqd_jira_issue_type, int pqd_jira_severity,string date, int numOfIssues, sql:ClientConnector sqlCon){
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

function saveIssuesInDatabase(int pqd_product_jira_id, int pqd_component_jira_id, string product_jira_version, string pqd_jira_issue_type, string pqd_jira_severity, string date, int numOfIssues, sql:ClientConnector sqlCon){
    sql:Parameter[] params = [];

    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:pqd_product_jira_id};
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:pqd_component_jira_id};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:product_jira_version};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:pqd_jira_issue_type};
    sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:pqd_jira_severity};
    sql:Parameter pqd_updated_para = {sqlType:"varchar", value:date};
    sql:Parameter pqd_issue_count_para = {sqlType:"integer", value:numOfIssues};

    params = [pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para,
              pqd_jira_issue_type_para, pqd_jira_severity_para, pqd_issue_count_para, pqd_updated_para];

    int UpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES, params);
}

function saveIssuesSummaryDaily(){
    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    int numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_HISTORY, params);

}
function saveIssuesSummaryDailyTESTING(){
    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    int numOfUpdatedRows;
    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_HISTORY_BY_PRODUCT, params);
    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_HISTORY_BY_VERSION, params);
    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_HISTORY_BY_COMPONENT, params);

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

function countIssues(json projectIdList, string[] issueTypeList, string[] severityList, json data){

    int numOfProjects = lengthof projectIdList;
    int remainingNumOfProjects = numOfProjects - 1;
    json issues = {"data":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);

    int numOfUpdatedRows;
    sql:Parameter[] params = [];

    numOfUpdatedRows = sql:ClientConnector.update(sqlCon, DELETE_JIRA_ISSUES, params);

    string [] keyColumns = [];
    string [] pqd_snapshot_id;

    int year;
    int month;
    int day;
    time:Time currentTime = time:currentTime();
    year, month, day = time:getDate(currentTime);
    string date = year + "-" + month + "-" + day;
    system:println("Date:" + year + ":" + month + ":" + day);

    while (remainingNumOfProjects >= 0) {
        int projectId = jsons:getInt(projectIdList,"$.["+remainingNumOfProjects+"]");
        json projectDetails = {"product_jira_id":0, "component_jira_id":0, "product_jira_version":"null", "jira_issue_type":"null", "jira_severity":"null"};
        projectDetails.product_jira_id = projectId;

        system:println(projectId);
        json issuesForProduct = jsons:getJson(data, "$.data[*].project[?(@.id=='"+projectId+"')]");

        countTypeIssues(date, projectDetails, issueTypeList, severityList, issuesForProduct, "$", sqlCon);

        int totalIssuesForProduct = lengthof issuesForProduct;

        sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:projectId};
        params = [pqd_product_jira_id_para];

        datatable componentsDatatable = sql:ClientConnector.select(sqlCon, GET_PROJECT_COMPONENTS, params);

        while (datatables:hasNext(componentsDatatable)) {
            any componentDataStruct = datatables:next(componentsDatatable);
            var componentRowSet, _ = (JiraComponent)componentDataStruct;

            int componentId = componentRowSet.pqd_component_jira_id;

            projectDetails.component_jira_id = componentId;
            json componentIssues = jsons:getJson(issuesForProduct, "$[*].components[?(@.id == '"+componentId+"')]");


            countTypeIssues(date, projectDetails, issueTypeList, severityList, componentIssues, "$", sqlCon);
        }
        datatables:close(componentsDatatable);

        params = [pqd_product_jira_id_para];

        datatable versionsDatatable = sql:ClientConnector.select(sqlCon, GET_PROJECT_VERSIONS, params);

        while (datatables:hasNext(versionsDatatable)) {
            any productVersionDataStruct = datatables:next(versionsDatatable);
            var productVersionRowSet, _ = (JiraProductVersion)productVersionDataStruct;

            string productVersion = productVersionRowSet.pqd_product_jira_version;
            projectDetails.component_jira_id = 0;
            projectDetails.product_jira_version = productVersion;
            json productVersionIssues = jsons:getJson(issuesForProduct, "$[*].version[?(@.name == '"+productVersion+"')]" );

            countTypeIssues(date, projectDetails, issueTypeList, severityList, productVersionIssues, "$", sqlCon);

        }

        datatables:close(versionsDatatable);

        remainingNumOfProjects = remainingNumOfProjects -1;
    }

    system:println("done counting");

}
function countIssuesTESTING2(json projectList, json issueTypeList, json severityList, json data, sql:ClientConnector dbConnector){

    int numOfProjects = lengthof projectList.projects;
    int remainingNumOfProjects = numOfProjects - 1;
    json issues = {"data":[]};

    int numOfUpdatedRows;
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
    while (remainingNumOfProjects >= 0) {
        int projectId = jsons:getInt(projectList.projects,"$.["+remainingNumOfProjects+"].jiraProjectId");
        int areaId = jsons:getInt(projectList.projects,"$.["+remainingNumOfProjects+"].area");
        int productId = jsons:getInt(projectList.projects,"$.["+remainingNumOfProjects+"].productID");

        json projectDetails = {"pqd_area_id": areaId, "pqd_product_id":productId, "component_jira_id":0, "product_jira_version":0, "jira_issue_type":0, "jira_severity":0};

        json issuesForProduct = jsons:getJson(data, "$.data[*].project[?(@.id=='"+projectId+"')]");

        countTypeIssuesTESTING2(date, projectDetails, issueTypeList, severityList, issuesForProduct, "$", sqlCon);

        int totalIssuesForProduct = lengthof issuesForProduct;

        sql:Parameter pqd_product_id_para = {sqlType:"integer", value:productId};
        params = [pqd_product_id_para];
        datatable componentsDatatable = sql:ClientConnector.select(sqlCon, GET_PROJECT_COMPONENTS_VERSION2, params);

        while (datatables:hasNext(componentsDatatable)) {
            any componentDataStruct = datatables:next(componentsDatatable);
            var componentRowSet, _ = (PQDComponent)componentDataStruct;

            int componentId = componentRowSet.pqd_component_id;
            int jiraComponentId = componentRowSet.jira_component_id;

            projectDetails.component_jira_id = componentId;
            json componentIssues = jsons:getJson(issuesForProduct, "$[*].components[?(@.id == '"+jiraComponentId+"')]");

            countTypeIssuesTESTING2(date, projectDetails, issueTypeList, severityList, issuesForProduct, "$", sqlCon);
        }
        datatables:close(componentsDatatable);

        params = [pqd_product_id_para];
        datatable versionsDatatable = sql:ClientConnector.select(sqlCon, GET_PROJECT_VERSIONS_VERSION2, params);

        while (datatables:hasNext(versionsDatatable)) {
            any productVersionDataStruct = datatables:next(versionsDatatable);
            var productVersionRowSet, _ = (PQDProductVersion)productVersionDataStruct;

            int productVersionId = productVersionRowSet.pqd_product_version_id;
            string productVersion = productVersionRowSet.pqd_product_version;

            projectDetails.component_jira_id = 0;
            projectDetails.product_jira_version = productVersionId;
            json productVersionIssues = jsons:getJson(issuesForProduct, "$[*].version[?(@.name == '"+productVersion+"')]" );

            countTypeIssuesTESTING2(date, projectDetails, issueTypeList, severityList, productVersionIssues, "$", sqlCon);
        }

        datatables:close(versionsDatatable);
        remainingNumOfProjects = remainingNumOfProjects -1;
    }

    logger:info("finished counting and saving issues for product, component and product version levels.");

}

function saveProductLevelCount(int productId, int snapshotId, int numOfIssues, sql:ClientConnector sqlCon){
    sql:Parameter[] params = [];

    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
    sql:Parameter pqd_snapshot_id_para = {sqlType:"integer", value:snapshotId};
    sql:Parameter pqd_issue_count_para = {sqlType:"integer", value:numOfIssues};


    params = [pqd_product_jira_id_para, pqd_snapshot_id_para, pqd_issue_count_para];

    int numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_OF_PRODUCT_LEVEL, params);

}



function getAllIssueSummary()(json){
    json data = {"error":false};
    json allAreas = {"name":"all", "items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:0};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    params = [pqd_component_jira_id_para, pqd_product_jira_version_para];

    datatable allCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_FOR_AREA, params);

    while (datatables:hasNext(allCountTable)) {
        any allCountDataStruct = datatables:next(allCountTable);
        var allCountRowSet, _ = (AreaIssuesCount)allCountDataStruct;

        string areaName = allCountRowSet.pqd_area_name;
        float areaIssueCount = allCountRowSet.area_level_issues;
        int pID = allCountRowSet.pqd_product_jira_id;

        json area = {"name":areaName, "id":pID, "issues":areaIssueCount};
        jsons:addToArray(allAreas, "$.items", area);
    }
    datatables:close(allCountTable);

    pqd_component_jira_id_para = {sqlType:"integer", value:0};
    pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    params = [pqd_component_jira_id_para, pqd_product_jira_version_para];
    datatable allProductIssueTypeTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_AREA, params);

    while (datatables:hasNext(allProductIssueTypeTable)) {
        any typeLevelCountDataStruct = datatables:next(allProductIssueTypeTable);
        var typeLevelCountRowSet, _ = (IssueTypeIssuesCount)typeLevelCountDataStruct;

        string issueTypeName = typeLevelCountRowSet.pqd_jira_issue_type;
        float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

        json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};

        sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issueTypeName};
        params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para];

        datatable severityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE_FOR_AREA, params);

        while (datatables:hasNext(severityCountTable)) {
            any severityLevelCountDataStruct = datatables:next(severityCountTable);
            var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

            string severityName = severityLevelCountRowSet.pqd_jira_severity;
            float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

            json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};
            jsons:addToArray(issueType, "$.severity", severity);

        }
        datatables:close(severityCountTable);
        jsons:addToArray(allAreas, "$.issuetype", issueType);

    }
    datatables:close(allProductIssueTypeTable);

    params = [pqd_component_jira_id_para, pqd_product_jira_version_para];
    datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_PRODUCT_FOR_AREA, params);

    while (datatables:hasNext(AllProductSeverityCountTable)) {
        any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
        var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

        string severityName = severityLevelCountRowSet.pqd_jira_severity;
        float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

        json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};

        sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severityName};
        params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];

        datatable issueTypeCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_SEVERITY_OF_PRODUCT_FOR_AREA, params);

        while (datatables:hasNext(issueTypeCountTable)) {
            any typeLevelCountDataStruct = datatables:next(issueTypeCountTable);
            var typeLevelCountRowSet, _ = (IssueTypeIssuesCount)typeLevelCountDataStruct;

            string issueTypeName = typeLevelCountRowSet.pqd_jira_issue_type;
            float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

            json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};
            jsons:addToArray(severity, "$.issuetype", issueType);

        }
        datatables:close(issueTypeCountTable);
        jsons:addToArray(allAreas, "$.severity", severity);
    }
    datatables:close(AllProductSeverityCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",allAreas);

    return data;
}

function getAllIssueSummaryTESTING()(json){
    json data = {"error":false};
    json allAreas = {"name":"all", "items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];

    datatable allCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_FOR_AREA_TESTING, params);

    while (datatables:hasNext(allCountTable)){
        any allCountDataStruct = datatables:next(allCountTable);
        var allCountRowSet, _ = (PQDAreaIssuesCount)allCountDataStruct;

        int areaId = allCountRowSet.pqd_area_id;
        float areaIssueCount = allCountRowSet.area_level_issues;

        json area = {"id":areaId, "issues":areaIssueCount};
        jsons:addToArray(allAreas, "$.items", area);
    }
    datatables:close(allCountTable);

    datatable allProductIssueTypeTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_FOR_ALL_TESTING, params);

    while (datatables:hasNext(allProductIssueTypeTable)) {
        any typeLevelCountDataStruct = datatables:next(allProductIssueTypeTable);
        var typeLevelCountRowSet, _ = (PQDIssueTypeIssuesCount)typeLevelCountDataStruct;

        int issueTypeId = typeLevelCountRowSet.pqd_issue_type_id;
        float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

        json issueType = {"id":issueTypeId, "issues":typeIssueCount};
        jsons:addToArray(allAreas, "$.issuetype", issueType);
    }
    datatables:close(allProductIssueTypeTable);

    datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_FOR_ALL_TESTING, params);
    while (datatables:hasNext(AllProductSeverityCountTable)) {
        any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
        var severityLevelCountRowSet, _ = (PQDSeverityIssuesCount)severityLevelCountDataStruct;

        int severityId = severityLevelCountRowSet.pqd_severity_id;
        float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

        json severity = {"id":severityId, "issues":severityIssueCount};
        jsons:addToArray(allAreas, "$.severity", severity);
    }
    datatables:close(AllProductSeverityCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",allAreas);

    return data;
}

function getAreaLevelIssueSummary(string areaName)(message){
    json data = {"error":false};
    json area = {"name":areaName, "items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:0};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_product_area_para = {sqlType:"varchar", value:areaName};
    params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_product_area_para ];

    datatable productCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_PRODUCT, params);

    while (datatables:hasNext(productCountTable)) {

        any productLevelCountDataStruct = datatables:next(productCountTable);
        var productLevelCountRowSet, _ = (ProductIssueCount)productLevelCountDataStruct;

        int productId = productLevelCountRowSet.pqd_product_jira_id;
        string productName = productLevelCountRowSet.pqd_product_jira_name;
        float productIssueCount = productLevelCountRowSet.product_level_issues;

        json product = {"name":productName, "id":productId, "issues":productIssueCount};
        jsons:addToArray(area, "$.items", product);
    }
    datatables:close(productCountTable);

    params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_product_area_para ];
    datatable allProductIssueTypeTable = sql:ClientConnector.select(sqlCon, GET_ALL_ISSUE_TYPE_COUNT, params);

    while (datatables:hasNext(allProductIssueTypeTable)) {
        any typeLevelCountDataStruct = datatables:next(allProductIssueTypeTable);
        var typeLevelCountRowSet, _ = (IssueTypeIssuesCount)typeLevelCountDataStruct;

        string issueTypeName = typeLevelCountRowSet.pqd_jira_issue_type;
        float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

        json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};

        sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issueTypeName};
        params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_issue_type_para, pqd_product_area_para];

        datatable severityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_ISSUE_TYPE_FOR_ALL_PRODUCTS, params);

        while (datatables:hasNext(severityCountTable)) {
            any severityLevelCountDataStruct = datatables:next(severityCountTable);
            var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

            string severityName = severityLevelCountRowSet.pqd_jira_severity;
            float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

            json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};
            jsons:addToArray(issueType, "$.severity", severity);

        }
        datatables:close(severityCountTable);
        jsons:addToArray(area, "$.issuetype", issueType);

    }
    datatables:close(allProductIssueTypeTable);

    params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_product_area_para ];
    datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY, params);

    while (datatables:hasNext(AllProductSeverityCountTable)) {
        any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
        var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

        string severityName = severityLevelCountRowSet.pqd_jira_severity;
        float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

        json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};

        sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severityName};
        params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para, pqd_product_area_para];

        datatable issueTypeCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_SEVERITY, params);

        while (datatables:hasNext(issueTypeCountTable)) {
            any typeLevelCountDataStruct = datatables:next(issueTypeCountTable);
            var typeLevelCountRowSet, _ = (IssueTypeIssuesCount)typeLevelCountDataStruct;

            string issueTypeName = typeLevelCountRowSet.pqd_jira_issue_type;
            float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

            json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};
            jsons:addToArray(severity, "$.issuetype", issueType);

        }
        datatables:close(issueTypeCountTable);
        jsons:addToArray(area, "$.severity", severity);
    }
    datatables:close(AllProductSeverityCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",area);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getAreaLevelIssueSummaryTESTING(int areaId)(message){
    json data = {"error":false};
    json area = {"items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_area_para = {sqlType:"integer", value:areaId};
    params = [pqd_product_area_para ];

    datatable productCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_PRODUCT_FOR_AREA_TESTING, params);

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

    params = [pqd_product_area_para ];
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

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",area);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getProductLevelIssueSummary(int productId)(message){
    json data = {"error":false};
    json product = {"items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:0};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
    params = [pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para];

    datatable versionCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_OF_VERSION_BY_PRODUCT, params);

    while (datatables:hasNext(versionCountTable)) {
        any versionLevelCountDataStruct = datatables:next(versionCountTable);
        var versionLevelCountRowSet, _ = (VersionIssuesCount)versionLevelCountDataStruct;

        string versionName = versionLevelCountRowSet.pqd_product_jira_version;
        float versionIssueCount = versionLevelCountRowSet.version_level_issues;

        json productVersion = {"name":versionName, "id":versionName, "issues":versionIssueCount};
        jsons:addToArray(product, "$.items", productVersion);
    }
    datatables:close(versionCountTable);

    params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_product_jira_id_para];
    datatable allProductIssueTypeTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE, params);

    while (datatables:hasNext(allProductIssueTypeTable)) {
        any typeLevelCountDataStruct = datatables:next(allProductIssueTypeTable);
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
        jsons:addToArray(product, "$.issuetype", issueType);

    }
    datatables:close(allProductIssueTypeTable);

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

        datatable issueTypeCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_SEVERITY_OF_PRODUCT, params);

        while (datatables:hasNext(issueTypeCountTable)) {
            any typeLevelCountDataStruct = datatables:next(issueTypeCountTable);
            var typeLevelCountRowSet, _ = (IssueTypeIssuesCount)typeLevelCountDataStruct;

            string issueTypeName = typeLevelCountRowSet.pqd_jira_issue_type;
            float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

            json issueType = {"name":issueTypeName, "id":null, "issues":typeIssueCount, "severity":[]};
            jsons:addToArray(severity, "$.issuetype", issueType);

        }
        datatables:close(issueTypeCountTable);
        jsons:addToArray(product, "$.severity", severity);
    }
    datatables:close(AllProductSeverityCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",product);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}


function getProductVersionLevelIssueSummary(int productId, string productVersion)(message){
    json data = {"error":false};
    json version = {"items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
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

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",version);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getProductLevelIssueSummaryTESTING(int productId)(message){
    json data = {"error":false};
    json product = {"items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};

    params = [pqd_product_jira_id_para];
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

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",product);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getComponentLevelIssueSummary(int productId, int componentId)(message){
    logger:info(time:currentTime());
    json data = {"error":false};
    json component = {"items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:componentId};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
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
        jsons:addToArray(component, "$.issuetype", issueType);
    }
    datatables:close(issueTypeCountTable);


    params = [pqd_component_jira_id_para, pqd_product_jira_version_para];
    datatable severityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_COMPONENT, params);

    while (datatables:hasNext(severityCountTable)) {
        any severityLevelCountDataStruct = datatables:next(severityCountTable);
        var severityLevelCountRowSet, _ = (SeverityIssuesCount)severityLevelCountDataStruct;

        string severityName = severityLevelCountRowSet.pqd_jira_severity;
        float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

        json severity = {"name":severityName, "id":null, "issues":severityIssueCount, "issuetype":[]};

        sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severityName};
        params = [pqd_component_jira_id_para, pqd_product_jira_version_para, pqd_jira_severity_para];

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

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",component);

    message response = {};
    messages:setJsonPayload(response, data);
    logger:info(time:currentTime());
    return response;
}

function getComponentLevelIssueSummaryTESTING(int componentId)(message){

    json data = {"error":false};
    json component = {"items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:componentId};

    params = [pqd_component_jira_id_para];
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

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",component);

    message response = {};
    messages:setJsonPayload(response, data);
    logger:info(time:currentTime());
    return response;
}

function getHistoryForAll(string both, string issuetype, string severity,string dateFrom, string dateTo, string period)(json){
    json data = {"error":false};
    json history = {"data":[]};
    //SELECT d.pqd_product_id, b.pqd_issue_type_id, c.pqd_severity_id, a.pqd_issue_count, a.pqd_updated FROM `pqd_jira_issues_history` as a join pqd_issue_type as b on a.pqd_jira_issue_type = b.pqd_issue_type join pqd_severity as c on a.pqd_jira_severity = c.pqd_severity join pqd_product as d on a.pqd_product_jira_id = d.jira_project_id WHERE pqd_component_jira_id = 0 and pqd_product_jira_version = "null"//SELECT d.pqd_product_id, b.pqd_issue_type_id, c.pqd_severity_id, a.pqd_issue_count, a.pqd_updated FROM `pqd_jira_issues_history` as a join pqd_issue_type as b on a.pqd_jira_issue_type = b.pqd_issue_type join pqd_severity as c on a.pqd_jira_severity = c.pqd_severity join pqd_product as d on a.pqd_product_jira_id = d.jira_project_id WHERE pqd_component_jira_id = 0 and pqd_product_jira_version = "null"
    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:0};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issuetype};
    sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severity};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    datatable historyTable;

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
        datatables:close(historyTable);

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
        datatables:close(historyTable);

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
        datatables:close(historyTable);
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
        datatables:close(historyTable);
    }
    //datatables:close(historyTable);
    sql:ClientConnector.close(sqlCon);

    jsons:addToObject(data, "$", "data",history);
    return data;
}
function getHistoryForIssueTypeTESTING(string category, int categoryId, int issuetype, string dateFrom, string dateTo, string period)(json){
    json data = {"error":false};
    json history = {"data":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_category_id_para = {sqlType:"integer", value:categoryId};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"integer", value:issuetype};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    params = [pqd_date_from_para, pqd_date_to_para, pqd_category_id_para, pqd_jira_issue_type_para];
    datatable historyTable;

    if(period == "day"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_issue_type_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_TESTING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_TESTING, params);

        }
        while (datatables:hasNext(historyTable)) {
            any areaLevelHistoryDataStruct = datatables:next(historyTable);
            var areaLevelHistoryRowSet, _ = (History)areaLevelHistoryDataStruct;

            float IssueCount = areaLevelHistoryRowSet.issues;
            string date = areaLevelHistoryRowSet.pqd_updated;

            json info = {"date":date, "count":IssueCount};
            jsons:addToArray(history, "$.data", info);

        }
        datatables:close(historyTable);

    }else if(period == "Year"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_issue_type_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_BY_YEAR_TESTING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_OF_AREA_FOR_ISSUE_TYPE_BY_YEAR_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_BY_YEAR_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_BY_YEAR_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_BY_YEAR_TESTING, params);

        }
        while (datatables:hasNext(historyTable)) {
            any areaLevelHistoryDataStruct = datatables:next(historyTable);
            var areaLevelHistoryRowSet, _ = (HistoryByYear)areaLevelHistoryDataStruct;

            float IssueCount = areaLevelHistoryRowSet.issues;
            int year = areaLevelHistoryRowSet.year;

            json info = {"date":year, "count":IssueCount};
            jsons:addToArray(history, "$.data", info);

        }
        datatables:close(historyTable);

    }else if(period == "Month"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_issue_type_para];
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_BY_MONTH_TESTING, params);
        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_BY_MONTH_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_BY_MONTH_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_BY_MONTH_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_BY_MONTH_TESTING, params);

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
        datatables:close(historyTable);
    }else if(period == "Quarter"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_issue_type_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_BY_QUARTER_TETSING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_BY_QUARTER_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_BY_QUARTER_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_BY_QUARTER_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_BY_QUARTER_TESTING, params);

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
        datatables:close(historyTable);
    }
    sql:ClientConnector.close(sqlCon);

    jsons:addToObject(data, "$", "data",history);
    return data;
}
function getHistoryForIssueTypeAndSeverityTESTING(string category, int categoryId, int issuetype, int severity, string dateFrom, string dateTo, string period)(json){
    json data = {"error":false};
    json history = {"data":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_category_id_para = {sqlType:"integer", value:categoryId};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"integer", value:issuetype};
    sql:Parameter pqd_jira_severity_para = {sqlType:"integer", value:severity};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    params = [pqd_date_from_para, pqd_date_to_para, pqd_category_id_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
    datatable historyTable;

    if(period == "day"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING, params);

        }
        while (datatables:hasNext(historyTable)) {
            any areaLevelHistoryDataStruct = datatables:next(historyTable);
            var areaLevelHistoryRowSet, _ = (History)areaLevelHistoryDataStruct;

            float IssueCount = areaLevelHistoryRowSet.issues;
            string date = areaLevelHistoryRowSet.pqd_updated;

            json info = {"date":date, "count":IssueCount};
            jsons:addToArray(history, "$.data", info);

        }
        datatables:close(historyTable);

    }else if(period == "Year"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_YEAR_TESTING, params);

        }
        while (datatables:hasNext(historyTable)) {
            any areaLevelHistoryDataStruct = datatables:next(historyTable);
            var areaLevelHistoryRowSet, _ = (HistoryByYear)areaLevelHistoryDataStruct;

            float IssueCount = areaLevelHistoryRowSet.issues;
            int year = areaLevelHistoryRowSet.year;

            json info = {"date":year, "count":IssueCount};
            jsons:addToArray(history, "$.data", info);

        }
        datatables:close(historyTable);

    }else if(period == "Month"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING, params);
        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_MONTH_TESTING, params);

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
        datatables:close(historyTable);
    }else if(period == "Quarter"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_issue_type_para, pqd_jira_severity_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TETSING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_ISSUE_TYPE_AND_SEVERITY_BY_QUARTER_TESTING, params);

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
        datatables:close(historyTable);
    }
    sql:ClientConnector.close(sqlCon);

    jsons:addToObject(data, "$", "data",history);
    return data;
}
function getHistoryForSeverityTESTING(string category, int categoryId, int severity, string dateFrom, string dateTo, string period)(json){
    json data = {"error":false};
    json history = {"data":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_category_id_para = {sqlType:"integer", value:categoryId};
    sql:Parameter pqd_jira_severity_para = {sqlType:"integer", value:severity};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    params = [pqd_date_from_para, pqd_date_to_para, pqd_category_id_para, pqd_jira_severity_para];
    datatable historyTable;

    if(period == "day"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_severity_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_SEVERITY_TESTING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_AREA_FOR_SEVERITY_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_SEVERITY_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_SEVERITY_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_SEVERITY_TESTING, params);

        }
        while (datatables:hasNext(historyTable)) {
            any areaLevelHistoryDataStruct = datatables:next(historyTable);
            var areaLevelHistoryRowSet, _ = (History)areaLevelHistoryDataStruct;

            float IssueCount = areaLevelHistoryRowSet.issues;
            string date = areaLevelHistoryRowSet.pqd_updated;

            json info = {"date":date, "count":IssueCount};
            jsons:addToArray(history, "$.data", info);

        }
        datatables:close(historyTable);

    }else if(period == "Year"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_severity_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_SEVERITY_BY_YEAR_TESTING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ISSUE_TYPE_OF_AREA_FOR_SEVERITY_BY_YEAR_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_SEVERITY_BY_YEAR_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_SEVERITY_BY_YEAR_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_SEVERITY_BY_YEAR_TESTING, params);

        }
        while (datatables:hasNext(historyTable)) {
            any areaLevelHistoryDataStruct = datatables:next(historyTable);
            var areaLevelHistoryRowSet, _ = (HistoryByYear)areaLevelHistoryDataStruct;

            float IssueCount = areaLevelHistoryRowSet.issues;
            int year = areaLevelHistoryRowSet.year;

            json info = {"date":year, "count":IssueCount};
            jsons:addToArray(history, "$.data", info);

        }
        datatables:close(historyTable);

    }else if(period == "Month"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_severity_para];
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_ALL_FOR_SEVERITY_BY_MONTH_TESTING, params);
        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_AREA_FOR_SEVERITY_BY_MONTH_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_PRODUCT_FOR_SEVERITY_BY_MONTH_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_VERSION_FOR_SEVERITY_BY_MONTH_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon,GET_ISSUE_HISTORY_OF_COMPONENT_FOR_SEVERITY_BY_MONTH_TESTING, params);

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
        datatables:close(historyTable);
    }else if(period == "Quarter"){
        if(category == "all"){
            params = [pqd_date_from_para, pqd_date_to_para, pqd_jira_severity_para];
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_ALL_FOR_SEVERITY_BY_QUARTER_TETSING, params);

        }else if (category == "area"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_AREA_FOR_SEVERITY_BY_QUARTER_TESTING, params);

        }else if (category == "product"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_PRODUCT_FOR_SEVERITY_BY_QUARTER_TESTING, params);

        }else if (category == "version"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_VERSION_FOR_SEVERITY_BY_QUARTER_TESTING, params);

        }else if (category == "component"){
            historyTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_HISTORY_OF_COMPONENT_FOR_SEVERITY_BY_QUARTER_TESTING, params);

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
        datatables:close(historyTable);
    }
    sql:ClientConnector.close(sqlCon);

    jsons:addToObject(data, "$", "data",history);
    return data;
}

function getHistoryForAreas(string area, string both, string issuetype, string severity,string dateFrom, string dateTo, string period)(json){
    json data = {"error":false};
    json history = {"data":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_area_para = {sqlType:"varchar", value:area};
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:0};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:"null"};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issuetype};
    sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severity};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    sql:Parameter pqd_period_para = {sqlType:"varchar", value:period};
    datatable historyTable;

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
    datatables:close(historyTable);
    sql:ClientConnector.close(sqlCon);

    jsons:addToObject(data, "$", "data",history);
    return data;
}

function getHistory(int product, int component, string version, string both, string issuetype, string severity,string dateFrom, string dateTo, string period)(json){
    json data = {"error":false};
    json history = {"data":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:product};
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:component};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:version};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:issuetype};
    sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:severity};
    sql:Parameter pqd_date_from_para = {sqlType:"varchar", value:dateFrom};
    sql:Parameter pqd_date_to_para = {sqlType:"varchar", value:dateTo};
    sql:Parameter pqd_period_para = {sqlType:"varchar", value:period};
    datatable historyTable;

    if(period == "day"){
        if(both == "no"){
            if(issuetype == "no" && severity == "no"){
                system:println("no no");
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
    datatables:close(historyTable);
    sql:ClientConnector.close(sqlCon);

    jsons:addToObject(data, "$", "data",history);
    return data;
}






function getAllSummaryForIssueType(int issuetypeId)(json){
    json data = {"error":false};
    json allAreas = {"name":"all", "items":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_issue_type_id_para = {sqlType:"integer", value:issuetypeId};

    params = [pqd_issue_type_id_para];
    datatable allCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_OF_AREA_FOR_ISSUE_TYPE_TESTING, params);

    while (datatables:hasNext(allCountTable)){
        any allCountDataStruct = datatables:next(allCountTable);
        var allCountRowSet, _ = (PQDAreaIssuesCount)allCountDataStruct;

        int areaId = allCountRowSet.pqd_area_id;
        float areaIssueCount = allCountRowSet.area_level_issues;

        json area = {"id":areaId, "issues":areaIssueCount};
        jsons:addToArray(allAreas, "$.items", area);
    }
    datatables:close(allCountTable);

    params = [pqd_issue_type_id_para];
    datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_ALL_FOR_ISSUE_TYPE_TESTING, params);

    while (datatables:hasNext(AllProductSeverityCountTable)) {
        any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
        var severityLevelCountRowSet, _ = (PQDSeverityIssuesCount)severityLevelCountDataStruct;

        int severityId = severityLevelCountRowSet.pqd_severity_id;
        float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

        json severity = {"id":severityId, "issues":severityIssueCount};
        jsons:addToArray(allAreas, "$.severity", severity);
    }
    datatables:close(AllProductSeverityCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",allAreas);

    return data;

}

function getAllSummaryForSeverity(int severityId)(json){
    json data = {"error":false};
    json allAreas = {"name":"all", "items":[], "issutype":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_severity_id_para = {sqlType:"integer", value:severityId};

    params = [pqd_severity_id_para];
    datatable allCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_OF_AREA_FOR_SEVERITY_TESTING, params);

    while (datatables:hasNext(allCountTable)){
        any allCountDataStruct = datatables:next(allCountTable);
        var allCountRowSet, _ = (PQDAreaIssuesCount)allCountDataStruct;

        int areaId = allCountRowSet.pqd_area_id;
        float areaIssueCount = allCountRowSet.area_level_issues;

        json area = {"id":areaId, "issues":areaIssueCount};
        jsons:addToArray(allAreas, "$.items", area);
    }
    datatables:close(allCountTable);

    params = [pqd_severity_id_para];
    datatable allProductIssueTypeTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_ALL_FOR_SEVERIRY_TESTING, params);

    while (datatables:hasNext(allProductIssueTypeTable)) {
        any typeLevelCountDataStruct = datatables:next(allProductIssueTypeTable);
        var typeLevelCountRowSet, _ = (PQDIssueTypeIssuesCount)typeLevelCountDataStruct;

        int issueTypeId = typeLevelCountRowSet.pqd_issue_type_id;
        float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

        json issueType = {"id":issueTypeId, "issues":typeIssueCount};
        jsons:addToArray(allAreas, "$.issuetype", issueType);
    }
    datatables:close(allProductIssueTypeTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",allAreas);

    return data;

}

function getAllSummaryForIssueTypeAndSeverity(int issuetypeId, int severityId)(json){
    json data = {"error":false};
    json allAreas = {"name":"all", "items":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_severity_id_para = {sqlType:"integer", value:severityId};
    sql:Parameter pqd_issue_type_id_para = {sqlType:"integer", value:issuetypeId};

    params = [pqd_issue_type_id_para, pqd_severity_id_para];
    datatable allCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_OF_AREA_FOR_BOTH_ISSUE_TYPE_AND_SEVERITY_TESTING, params);

    while (datatables:hasNext(allCountTable)){
        any allCountDataStruct = datatables:next(allCountTable);
        var allCountRowSet, _ = (PQDAreaIssuesCount)allCountDataStruct;

        int areaId = allCountRowSet.pqd_area_id;
        float areaIssueCount = allCountRowSet.area_level_issues;

        json area = {"id":areaId, "issues":areaIssueCount};
        jsons:addToArray(allAreas, "$.items", area);
    }
    datatables:close(allCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",allAreas);

    return data;

}

function getAreaLevelIssueSummaryForIssueType(int areaId, int issuetypeId)(message){
    json data = {"error":false};
    json area = {"id":areaId, "items":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_area_para = {sqlType:"integer", value:areaId};
    sql:Parameter pqd_issue_type_id_para = {sqlType:"integer", value:issuetypeId};

    params = [pqd_product_area_para ,pqd_issue_type_id_para];

    datatable productCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_PRODUCT_OF_AREA_FOR_ISSUE_TYPE_TESTING, params);

    while (datatables:hasNext(productCountTable)) {

        any productLevelCountDataStruct = datatables:next(productCountTable);
        var productLevelCountRowSet, _ = (PQDProductIssueCount)productLevelCountDataStruct;

        int productId = productLevelCountRowSet.pqd_product_id;
        float productIssueCount = productLevelCountRowSet.product_level_issues;

        json product = {"id":productId, "issues":productIssueCount};
        jsons:addToArray(area, "$.items", product);
    }
    datatables:close(productCountTable);

    params = [pqd_product_area_para ,pqd_issue_type_id_para];
    datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_AREA_FOR_SEVERITY_TESTING, params);

    while (datatables:hasNext(AllProductSeverityCountTable)) {
        any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
        var severityLevelCountRowSet, _ = (PQDSeverityIssuesCount)severityLevelCountDataStruct;

        int severityId = severityLevelCountRowSet.pqd_severity_id;
        float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

        json severity = {"id":severityId, "issues":severityIssueCount, "issuetype":[]};
        jsons:addToArray(area, "$.severity", severity);
    }
    datatables:close(AllProductSeverityCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",area);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getAreaLevelIssueSummaryForSeverity(int areaId, int severityId)(message){
    json data = {"error":false};
    json area = {"id":areaId, "items":[], "issuetype":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_area_para = {sqlType:"integer", value:areaId};
    sql:Parameter pqd_severity_para = {sqlType:"integer", value:severityId};

    params = [pqd_product_area_para ,pqd_severity_para];
    datatable productCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_PRODUCT_OF_AREA_FOR_SEVERITY_TESTING, params);

    while (datatables:hasNext(productCountTable)) {

        any productLevelCountDataStruct = datatables:next(productCountTable);
        var productLevelCountRowSet, _ = (PQDProductIssueCount)productLevelCountDataStruct;

        int productId = productLevelCountRowSet.pqd_product_id;
        float productIssueCount = productLevelCountRowSet.product_level_issues;

        json product = {"id":productId, "issues":productIssueCount};
        jsons:addToArray(area, "$.items", product);
    }
    datatables:close(productCountTable);

    params = [pqd_product_area_para, pqd_severity_para];
    datatable allProductIssueTypeTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_AREA_FOR_SEVERITY_TESTING, params);

    while (datatables:hasNext(allProductIssueTypeTable)) {
        any typeLevelCountDataStruct = datatables:next(allProductIssueTypeTable);
        var typeLevelCountRowSet, _ = (PQDIssueTypeIssuesCount)typeLevelCountDataStruct;

        int issueTypeId = typeLevelCountRowSet.pqd_issue_type_id;
        float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

        json issueType = {"id":issueTypeId, "issues":typeIssueCount};
        jsons:addToArray(area, "$.issuetype", issueType);

    }
    datatables:close(allProductIssueTypeTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",area);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getAreaLevelIssueSummaryForIssueTypeAndSeverity(int areaId, int issuetypeId, int severityId)(message){
    json data = {"error":false};
    json area = {"id":areaId, "items":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_area_para = {sqlType:"integer", value:areaId};
    sql:Parameter pqd_severity_para = {sqlType:"integer", value:severityId};
    sql:Parameter pqd_issue_type_id_para = {sqlType:"integer", value:issuetypeId};


    params = [pqd_product_area_para, pqd_issue_type_id_para, pqd_severity_para];
    datatable productCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_PRODUCT_OF_AREA_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING, params);

    while (datatables:hasNext(productCountTable)) {

        any productLevelCountDataStruct = datatables:next(productCountTable);
        var productLevelCountRowSet, _ = (PQDProductIssueCount)productLevelCountDataStruct;

        int productId = productLevelCountRowSet.pqd_product_id;
        float productIssueCount = productLevelCountRowSet.product_level_issues;

        json product = {"id":productId, "issues":productIssueCount};
        jsons:addToArray(area, "$.items", product);
    }
    datatables:close(productCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",area);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getProductLevelIssueSummaryForIssueType(int productId, int issuetypeId)(message){
    json data = {"error":false};
    json product = {"items":[], "severity":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
    sql:Parameter pqd_issue_type_id_para = {sqlType:"integer", value:issuetypeId};

    params = [pqd_product_jira_id_para, pqd_issue_type_id_para];
    datatable componentCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_COMPONENT_OF_PRODUCT_FOR_ISSUE_TYPE_TESTING, params);

    while (datatables:hasNext(componentCountTable)) {
        any componentLevelCountDataStruct = datatables:next(componentCountTable);
        var componentLevelCountRowSet, _ = (PQDComponentIssuesCount)componentLevelCountDataStruct;

        int componentId = componentLevelCountRowSet.pqd_component_id;
        float componentIssueCount = componentLevelCountRowSet.component_level_issues;

        json component = {"id":componentId, "issues":componentIssueCount};
        jsons:addToArray(product, "$.items", component);
    }
    datatables:close(componentCountTable);

    datatable AllProductSeverityCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_SEVERITY_OF_PRODUCT_FOR_ISSUE_TYPE_TESTING, params);

    while (datatables:hasNext(AllProductSeverityCountTable)) {
        any severityLevelCountDataStruct = datatables:next(AllProductSeverityCountTable);
        var severityLevelCountRowSet, _ = (PQDSeverityIssuesCount)severityLevelCountDataStruct;

        int severityId = severityLevelCountRowSet.pqd_severity_id;
        float severityIssueCount = severityLevelCountRowSet.severity_level_issues;

        json severity = {"id":severityId, "issues":severityIssueCount};
        jsons:addToArray(product, "$.severity", severity);
    }
    datatables:close(AllProductSeverityCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",product);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getProductLevelIssueSummaryForSeverity(int productId, int severityId)(message){
    json data = {"error":false};
    json product = {"items":[], "issuetype":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
    sql:Parameter pqd_severity_id_para = {sqlType:"integer", value:severityId};

    params = [pqd_product_jira_id_para, pqd_severity_id_para];
    datatable componentCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_COMPONENT_OF_PRODUCT_FOR_SEVERITY_TESTING, params);

    while (datatables:hasNext(componentCountTable)) {
        any componentLevelCountDataStruct = datatables:next(componentCountTable);
        var componentLevelCountRowSet, _ = (PQDComponentIssuesCount)componentLevelCountDataStruct;

        int componentId = componentLevelCountRowSet.pqd_component_id;
        float componentIssueCount = componentLevelCountRowSet.component_level_issues;

        json component = {"id":componentId, "issues":componentIssueCount};
        jsons:addToArray(product, "$.items", component);
    }
    datatables:close(componentCountTable);

    params = [pqd_product_jira_id_para, pqd_severity_id_para];
    datatable issueTypeCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_ISSUE_TYPE_OF_PRODUCT_FOR_SEVERITY_TESTING, params);

    while (datatables:hasNext(issueTypeCountTable)) {
        any typeLevelCountDataStruct = datatables:next(issueTypeCountTable);
        var typeLevelCountRowSet, _ = (PQDIssueTypeIssuesCount)typeLevelCountDataStruct;

        int issueTypeId = typeLevelCountRowSet.pqd_issue_type_id;
        float typeIssueCount = typeLevelCountRowSet.issue_type_level_issues;

        json issueType = {"id":issueTypeId, "issues":typeIssueCount, "severity":[]};
        jsons:addToArray(product, "$.issuetype", issueType);

    }
    datatables:close(issueTypeCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",product);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}

function getProductLevelIssueSummaryForIssueTypeAndSeverity(int productId, int issuetypeId, int severityId)(message){
    json data = {"error":false};
    json product = {"id": productId, "items":[]};

    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
    sql:Parameter pqd_issue_type_id_para = {sqlType:"integer", value:issuetypeId};
    sql:Parameter pqd_severity_id_para = {sqlType:"integer", value:severityId};

    params = [pqd_product_jira_id_para, pqd_severity_id_para];
    datatable componentCountTable = sql:ClientConnector.select(sqlCon, GET_ISSUE_COUNT_BY_COMPONENT_OF_PRODUCT_FOR_ISSUE_TYPE_AND_SEVERITY_TESTING, params);

    while (datatables:hasNext(componentCountTable)) {
        any componentLevelCountDataStruct = datatables:next(componentCountTable);
        var componentLevelCountRowSet, _ = (PQDComponentIssuesCount)componentLevelCountDataStruct;

        int componentId = componentLevelCountRowSet.pqd_component_id;
        float componentIssueCount = componentLevelCountRowSet.component_level_issues;

        json component = {"id":componentId, "issues":componentIssueCount};
        jsons:addToArray(product, "$.items", component);
    }
    datatables:close(componentCountTable);

    sql:ClientConnector.close(sqlCon);
    jsons:addToObject(data, "$", "data",product);

    message response = {};
    messages:setJsonPayload(response, data);
    return response;
}


