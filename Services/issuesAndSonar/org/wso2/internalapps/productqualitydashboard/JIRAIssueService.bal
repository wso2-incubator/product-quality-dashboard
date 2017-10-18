package org.wso2.internalapps.productqualitydashboard;

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


string jiraURL = jsons:getString(configData, "$.JIRAurl");
string jiraUsername = jsons:getString(configData, "$.JIRAusername");
string jiraPassword = jsons:getString(configData, "$.JIRApassword");

struct JIRAProduct{
    int pqd_product_jira_id;
    string pqd_product_jira_key;
    string pqd_product_jira_name;
}

struct JIRAIssueType {
    string pqd_issue_type;
}

struct JIRASeverity{
    string pqd_jira_severity;
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

struct JiraProductVersion{
    string  pqd_product_jira_version;
}

struct SnapshotId{
    int pqd_snapshot_id;
}

struct ProductIssueCount{
    int pqd_product_jira_id;
    string pqd_product_jira_name;
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

struct IssueTypeIssuesCount{
    string pqd_jira_issue_type;
    float issue_type_level_issues;
}

struct SeverityIssuesCount{
    string pqd_jira_severity;
    float severity_level_issues;
}

struct VersionIssuesCount{
    string pqd_product_jira_version;
    float version_level_issues;
}

struct AreaIssuesCount{
    string pqd_area_name;
    float area_level_issues;
}


@http:configuration {basePath:"/internal/product-quality/v1.0/jira", httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> JiraService {

    jira:ClientConnector jiraConnector = create jira:ClientConnector(jiraURL, jiraUsername, jiraPassword);

    @http:GET {}
    @http:Path {value:"/issues/summary"}
    resource AllJiraIssuesByProject (message m) {
        json projectList = {"projects":[]};
        string[] issueTypeList = [];
        string[] severityList =[];
        getProjectsIssueTypesAndSeverities(projectList, issueTypeList, severityList);
        message response = getJiraIssuesSummary(projectList, issueTypeList, severityList, jiraConnector);
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
    @http:Path {value:"/get"}
    resource get(message m) {
        //saveIssuesSummaryDaily();
        message response = {};
        //message response = aa(jiraConnector);
        //message response = getProjectVersions("WSAS");

        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/all"}
    resource getAllIssueSummary(message m) {
        message response = getAllIssueSummary();
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/area/{area}"}
    resource getAreaLevelIssueSummary(message m, @http:PathParam {value:"area"} string area) {
        system:println(area);
        message response =  getAreaLevelIssueSummary(area);
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/product/{product}"}
    resource getProductLevelIssueSummary(message m, @http:PathParam {value:"product"} int product) {
        message response = getProductLevelIssueSummary(product);
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/{product}/version/{version}"}
    resource getProductVersionLevelIssueSummary(message m ,@http:PathParam {value:"product"} int product, @http:PathParam {value:"version"} string version) {
        message response = getProductVersionLevelIssueSummary(product, version);
        reply response;
    }
    @http:GET {}
    @http:Path {value:"/issues/summary/{product}/component/{component}"}
    resource getComponentLevelIssueSummary(message m ,@http:PathParam {value:"product"} int product, @http:PathParam {value:"component"} int component) {
        message response = getComponentLevelIssueSummary(product, component);
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
    string jiraPath =  "/rest/api/2/project/"+projectKey+"/components";
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



function getProjectsIssueTypesAndSeverities(json projectList, string[] issueTypeList, string[] severityList){
    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];

    datatable productDatatable = sql:ClientConnector.select(dbConnector, GET_PRODUCT_DB_QUERY, params);

    while (datatables:hasNext(productDatatable)) {
        any productDataStruct = datatables:next(productDatatable);
        var productRowSet, _ = (JIRAProduct)productDataStruct;

        string projectKey = productRowSet.pqd_product_jira_key;
        int projectId = productRowSet.pqd_product_jira_id;

        json project = {"key":projectKey, "id":projectId};
        jsons:addToArray(projectList, "$.projects", project);
    }
    datatables:close(productDatatable);

    datatable issueTypeDatatable = sql:ClientConnector.select(dbConnector, GET_ISSUE_TYPE_DB_QUERY, params);
    int index = 0;

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

    while (datatables:hasNext(severityDatatable)) {
        any severityDataStruct = datatables:next(severityDatatable);
        var severityRowSet, _ = (JIRASeverity )severityDataStruct;

        string severity = severityRowSet.pqd_jira_severity;

        severityList[index] = severity;
        index = index + 1;
    }
    datatables:close(severityDatatable);

}


function getJiraIssuesSummary(json projectList, string[] issueTypeList, string[] severityList, jira:ClientConnector jiraConnector)(message ){

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


function changeIssueFormat(json projectList, string[] issueTypeList, string[] severityList, json rawData, int numOfPages){
    json issues = {"data":[]};
    json data = {"project":{}};
    json projectIdList = jsons:getJson(projectList, "$.projects[*].id");

    int index1 = numOfPages - 1;

    json issue = {};

    while (index1 >= 0) {
        int totalNumOfIssues = lengthof rawData.data[index1];
        int index2 = totalNumOfIssues - 1;
        while (index2 >= 0) {
            issue = rawData.data[index1][index2];
            jsons:addToObject(data, "$.project", "id", issue.fields.project.id);
            jsons:addToObject(data, "$.project", "key", issue.fields.project.key);

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

            //if (index3 < 0) {
            //    json object = {"id":0, "name": "none", "issuetype":issueType, "severity": severity};
            //    jsons:addToArray(components, "$.components", object);
            //}

            while (index3 >= 0) {
                json object = {"id": component[index3].id, "name": component[index3].name, "issuetype":issueType, "severity": severity};
                jsons:addToArray(components, "$.components", object);
                index3 = index3-1;
            }
            jsons:addToObject(data, "$.project", "components", components.components);
            jsons:addToObject(data, "$.project", "issuetype", issueType);
            jsons:addToObject(data, "$.project", "severity", severity);
        //system:println(issue);

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
    countIssues(projectIdList, issueTypeList, severityList, issues);

}


function getProjectsAsString(json projectList)(string){
    json projectKeys = jsons:getJson(projectList, "$.projects[*].key");
    int numOfProjects = lengthof projectKeys;
    int index = numOfProjects - 1;
    string projects = "";

    while (index >= 0) {
        string projectKey = jsons:getString(projectKeys, "$.["+index+"]");
        projects = projects + "'" + projectKey + "',";
        index = index - 1;
    }

    int length = strings:length(projects);
    string result = strings:subString(projects, 0, length-1);
    return result;
}


function getIssueTypeAsString(string[] issueTypeList)(string){
    int numOfIssueTypes = lengthof issueTypeList;
    int index = numOfIssueTypes - 1;
    string issueTypes = "";

    while (index >= 0) {
        issueTypes = issueTypes + "'" + issueTypeList[index] + "',";
        index = index - 1;
    }

    int length = strings:length(issueTypes);
    string result = strings:subString(issueTypes, 0, length-1);
    return result;
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


function saveIssuesInDatabaseTesting(int pqd_product_jira_id, int pqd_component_jira_id, string product_jira_version, string pqd_jira_issue_type, string pqd_jira_severity, int snapshotId, int numOfIssues, sql:ClientConnector sqlCon){
    sql:Parameter[] params = [];

    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:pqd_product_jira_id};
    sql:Parameter pqd_component_jira_id_para = {sqlType:"integer", value:pqd_component_jira_id};
    sql:Parameter pqd_product_jira_version_para = {sqlType:"varchar", value:product_jira_version};
    sql:Parameter pqd_jira_issue_type_para = {sqlType:"varchar", value:pqd_jira_issue_type};
    sql:Parameter pqd_jira_severity_para = {sqlType:"varchar", value:pqd_jira_severity};
    sql:Parameter pqd_snapshot_id_para = {sqlType:"integer", value:snapshotId};
    sql:Parameter pqd_issue_count_para = {sqlType:"integer", value:numOfIssues};

    string query = "";
    if(pqd_component_jira_id == 0){
        if(product_jira_version == "null"){
            params = [pqd_product_jira_id_para, pqd_jira_issue_type_para, pqd_jira_severity_para, pqd_snapshot_id_para,
                      pqd_issue_count_para];
            query = INSERT_JIRA_ISSUES_BY_PRODUCT;
        }else{
            params = [pqd_product_jira_id_para, pqd_product_jira_version_para,
                      pqd_jira_issue_type_para, pqd_jira_severity_para, pqd_snapshot_id_para,
                      pqd_issue_count_para];
            query = INSERT_JIRA_ISSUES_BY_VERSION;
        }
    }else{
        if(product_jira_version == "null"){
            params = [pqd_product_jira_id_para, pqd_component_jira_id_para,
                      pqd_jira_issue_type_para, pqd_jira_severity_para, pqd_snapshot_id_para,
                      pqd_issue_count_para];
            query = INSERT_JIRA_ISSUES_BY_COMPONENT;
        }
    }

    int numOfUpdatedRows = sql:ClientConnector.update(sqlCon, query, params);
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
        JIRAurl = jsons:getString(configData, "$.JIRAurl");
        JIRAusername = jsons:getString(configData, "$.JIRAusername");
        JIRApassword = jsons:getString(configData, "$.JIRApassword");

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

function saveProductLevelCount(int productId, int snapshotId, int numOfIssues, sql:ClientConnector sqlCon){
    sql:Parameter[] params = [];

    sql:Parameter pqd_product_jira_id_para = {sqlType:"integer", value:productId};
    sql:Parameter pqd_snapshot_id_para = {sqlType:"integer", value:snapshotId};
    sql:Parameter pqd_issue_count_para = {sqlType:"integer", value:numOfIssues};


    params = [pqd_product_jira_id_para, pqd_snapshot_id_para, pqd_issue_count_para];

    int numOfUpdatedRows = sql:ClientConnector.update(sqlCon, INSERT_JIRA_ISSUES_OF_PRODUCT_LEVEL, params);

}



function getAllIssueSummary()(message){
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

        json area = {"name":areaName, "id":areaName, "issues":areaIssueCount};
        jsons:addToArray(allAreas, "$.items", area);
    }
    datatables:close(allCountTable);

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

    message response = {};
    messages:setJsonPayload(response, data);
    return response;

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

    params = [pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
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


    params = [pqd_product_jira_id_para, pqd_component_jira_id_para, pqd_product_jira_version_para];
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

function getComponentLevelIssueSummary(int productId, int componentId)(message){
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
    return response;
}

function getHistoryForAll(string both, string issuetype, string severity,string dateFrom, string dateTo, string period)(json){
    json data = {"error":false};
    json history = {"data":[]};

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



