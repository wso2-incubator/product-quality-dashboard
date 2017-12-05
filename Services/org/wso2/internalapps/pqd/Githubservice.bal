package org.wso2.internalapps.pqd;

import ballerina.lang.messages;
import ballerina.net.http;
import ballerina.lang.jsons;
import ballerina.utils.logger;
import ballerina.lang.files;
import ballerina.lang.blobs;
import ballerina.lang.errors;
import ballerina.lang.datatables;
import ballerina.data.sql;
import ballerina.lang.strings;
import ballerina.lang.time;

struct GithubArea{
    int pqd_area_id;
    string pqd_area_name;
}

struct GithubProduct{
    int pqd_product_id;
    string pqd_product_name;
}

struct GithubProductVersion{
    int pqd_product_version_id;
    string pqd_product_version;
    string pqd_product_version_github_tag;
}

struct GithubComponentVersion{
    int pqd_component_version_id;
    string pqd_component_version;
    string pqd_component_version_github_label_text;
}

struct GithubComponent{
    int pqd_component_id;
    string pqd_component_name;
    string github_repo_name;
}

struct GithubIssueType{
    int pqd_issue_type_id;
    string pqd_issue_type;
    string pqd_issue_type_github_label_text;
    string pqd_issue_type_github_label_color;
}

struct GithubSeverity{
    int pqd_severity_id;
    string pqd_severity;
    string pqd_severity_github_label_text;
    string pqd_severity_github_label_color;
}

struct GithubIssueTypeUnknown{
    int pqd_issue_type_id;
}

struct GithubSeverityUnknown{
    int pqd_severity_id;
}

struct GithubComponentIssue{
    int pqd_component_id;
    int pqd_issue_type_id;
    int pqd_severity_id;
    int pqd_issues_count;
}

struct GithubProductIssue{
    int pqd_product_id;
    int pqd_issue_type_id;
    int pqd_severity_id;
    int pqd_issues_count;
}

struct GithubAreaIssue{
    int pqd_area_id;
    int pqd_issue_type_id;
    int pqd_severity_id;
    int pqd_issues_count;
}

json githubConfigData = getConfigData(CONFIG_PATH);

@http:configuration {basePath:"/internal/product-quality/v1.0/fetch-github", httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> GithubService {

    @http:GET {}
    @http:Path {value:"/issues/update"}
    resource updateDatabaseWithLiveData(message m){
        logger:debug("updateDatabaseWithLiveData resource invoked");

        message response = {};

        messages:setStringPayload(response, "Update progress started");
        logger:debug("updateDatabaseWithLiveData resourve responded successfully");

        reply response;

        worker updateTables {
            logger:info(time:currentTime());

            sql:Parameter[][] batchParams = [];

            sql:Parameter[] paramsForComponent = [];
            int a = 0;

            json componentJson = getDataFromDatabase(GET_GITHUB_COMPONENT_QUERY, paramsForComponent);

            while(a < lengthof componentJson){
                logger:debug("check");  //this is added here due to a bug in ballerina. ToDO: Remove it in later versions
                try{
                    string githubRepoName = jsons:getString(componentJson[a], "$.github_repo_name");
                    string githubOrganization = jsons:getString(componentJson[a], "$.github_repo_organization");
                    json issuesJson = getRepoIssues(githubOrganization, githubRepoName);
                    sortGithubIssues(batchParams, jsons:getInt(componentJson[a], "$.pqd_component_id"),
                                     jsons:getString(componentJson[a], "$.pqd_component_name"), issuesJson);
                    logger:debug(lengthof batchParams);
                    logger:info("Data fetched successfully for componentId : " + jsons:getInt(componentJson[a], "$.pqd_component_id"));
                    a = a + 1;
                } catch (errors:Error err) {
                    logger:debug("Data fetch failed for componentId : " + jsons:getInt(componentJson[a], "$.pqd_component_id"));
                    logger:debug("Github repo might not exist for the above the componentId");
                    logger:debug(err.msg);
                    a = a + 1;
                }
            }

            logger:debug(lengthof batchParams);

            updateTotalForComponentIssues(batchParams);

            logger:info(time:currentTime());
        }

    }


    @http:GET {}
    @http:Path {value:"/issues/store"}
    resource storeDataInHistory(message m){
        logger:debug("storeDataInHistory resource got invoked");
        sql:ClientConnector sqlCon = createIssuesDBcon();

        message response = {};

        transaction{

            int year;
            int month;
            int day;
            time:Time currentTime = time:currentTime();
            year, month, day = time:getDate(currentTime);
            string date = year + "-" + month + "-" + day;

            sql:Parameter dateParam = {sqlType:"varchar", value:date};
            sql:Parameter[] paramForHistoryDate = [dateParam];
            json historyDates = getDataFromDatabase(GET_GITHUB_COMPONENT_HISTORY_DATES_QUERY, paramForHistoryDate);

            if(lengthof historyDates != 0){
                abort;
            }

            sql:Parameter[] paramForCurrentIssues = [];
            datatable currentIssueCountDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_CURRENT_ISSUES_QUERY, paramForCurrentIssues);

            sql:Parameter[][] batchParamsForComponent = [];
            int a = 0;

            while(datatables:hasNext(currentIssueCountDt)){
                any currentIssueCountStruct = datatables:next(currentIssueCountDt);
                var currentIssueCount, _ = (GithubComponentIssue)currentIssueCountStruct;

                sql:Parameter componentIdParam = {sqlType:"integer", value:currentIssueCount.pqd_component_id};
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value:currentIssueCount.pqd_issue_type_id};
                sql:Parameter severityIdParam = {sqlType:"integer", value:currentIssueCount.pqd_severity_id};
                sql:Parameter issuesCountParam = {sqlType:"integer", value:currentIssueCount.pqd_issues_count};

                sql:Parameter[] currentParamsForBatchUpdate = [componentIdParam, issueTypeIdParam, severityIdParam, issuesCountParam, dateParam];

                batchParamsForComponent[a] = currentParamsForBatchUpdate;

                a = a + 1;

            }

            int[] count = sql:ClientConnector.batchUpdate(sqlCon, INSERT_GITHUB_COMPONENT_ISSUES_HISTORY_QUERY, batchParamsForComponent);

            datatables:close(currentIssueCountDt);


            datatable currentProductIssueCountDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_CURRENT_ISSUES_QUERY, paramForCurrentIssues);

            sql:Parameter[][] batchParamsForProduct = [];
            int b = 0;

            while(datatables:hasNext(currentProductIssueCountDt)){
                any currentProductIssueCountStruct = datatables:next(currentProductIssueCountDt);
                var currentIssueCount, _ = (GithubProductIssue)currentProductIssueCountStruct;

                sql:Parameter productIdParam = {sqlType:"integer", value:currentIssueCount.pqd_product_id};
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value:currentIssueCount.pqd_issue_type_id};
                sql:Parameter severityIdParam = {sqlType:"integer", value:currentIssueCount.pqd_severity_id};
                sql:Parameter issuesCountParam = {sqlType:"integer", value:currentIssueCount.pqd_issues_count};

                sql:Parameter[] currentParamsForBatchUpdate = [productIdParam, issueTypeIdParam, severityIdParam, issuesCountParam, dateParam];

                batchParamsForProduct[b] = currentParamsForBatchUpdate;

                b = b + 1;

            }

            int[] count1 = sql:ClientConnector.batchUpdate(sqlCon, INSERT_GITHUB_PRODUCT_ISSUES_HISTORY_QUERY, batchParamsForProduct);

            datatables:close(currentProductIssueCountDt);

            datatable currentAreaIssueCountDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_CURRENT_ISSUES_QUERY, paramForCurrentIssues);

            sql:Parameter[][] batchParamsForArea = [];
            int c = 0;

            while(datatables:hasNext(currentAreaIssueCountDt)){
                any currentAreaIssueCountStruct = datatables:next(currentAreaIssueCountDt);
                var currentIssueCount, _ = (GithubAreaIssue)currentAreaIssueCountStruct;

                sql:Parameter areaIdParam = {sqlType:"integer", value:currentIssueCount.pqd_area_id};
                sql:Parameter issueTypeIdParam = {sqlType:"integer", value:currentIssueCount.pqd_issue_type_id};
                sql:Parameter severityIdParam = {sqlType:"integer", value:currentIssueCount.pqd_severity_id};
                sql:Parameter issuesCountParam = {sqlType:"integer", value:currentIssueCount.pqd_issues_count};

                sql:Parameter[] currentParamsForBatchUpdate = [areaIdParam, issueTypeIdParam, severityIdParam, issuesCountParam, dateParam];

                batchParamsForArea[c] = currentParamsForBatchUpdate;

                c = c + 1;

            }

            int[] count2 = sql:ClientConnector.batchUpdate(sqlCon, INSERT_GITHUB_AREA_ISSUES_HISTORY_QUERY, batchParamsForArea);

            datatables:close(currentAreaIssueCountDt);

        } aborted{
            json responseJson = {"error" : true, "msg":"Inserting data to history table failed. Data for today's date may exist already"};
            messages:setJsonPayload(response, responseJson);
        } committed{
            json responseJson = {"error": false, "msg":"Data successfully stored in history tables"};
            messages:setJsonPayload(response, responseJson);
        }

        sqlCon.close();

        logger:debug("storeDataInHistory resource responded successfully");
        reply response;
    }

}




function getRepoIssues(string organization, string repoName)(json){

    //this function gets the repo issues for a particular repo and organisation
    logger:debug("getRepoIssues function invoked for repo " + repoName + " under organisation " + organization);

    message response = httpGetForGithub("/repos/" + organization +"/" + repoName + "/issues");
    json jsonResponse = messages:getJsonPayload(response);
    json filterJsonForPullRequest = jsons:getJson(jsonResponse, "$.[?(!@.pull_request)]");
    json filteredJson = jsons:getJson(filterJsonForPullRequest, "$.[?(@.state=='open')]");
    logger:debug("repo issues received : " + jsons:toString(jsonResponse));

    return filteredJson;
}


function httpGetForGithub(string path)(message ){

    logger:debug("httpGetForGithub function invoked with path " + path);

    //this is a common method to get github response
    //pass a path to the method and it will give a json response
    string domainUrl = GITHUB_API_DOMAIN_URL;
    message request = {};
    message response = {};

    http:ClientConnector githubCon = create http:ClientConnector(domainUrl);

    messages:setHeader(request, "Authorization", jsons:getString(githubConfigData, "$.GITHUB.GITHUB_TOKEN"));
    messages:setHeader(request, "Content-Type", "application/json");
    path = path + "?per_page=100";
    response = http:ClientConnector.get(githubCon, path, request);
    message finalResponse = collectDataFromPagination(response);

    return finalResponse;

}

function collectDataFromPagination(message response)(message ){

    //this function will handle pagination for httpGetForGithubMethod
    string linkHeader = "";
    json combinedJsonResponse = messages:getJsonPayload(response);
    boolean isLinkHeaderAvailable = true;

    message currentRequest = {};
    message currentResponse = response;

    while(isLinkHeaderAvailable){
        logger:debug("while loop running for pagination");
        try {
            string rateLimitHeader = messages:getHeader(currentResponse, "x-ratelimit-remaining");
            logger:debug("x-ratelimit-remaining : " + rateLimitHeader);

            linkHeader = messages:getHeader(currentResponse, "link");

            json links = splitLinkHeader(linkHeader);

            try {
                string nextLink = jsons:getString(links, "$.next");

                logger:debug("current next link for pagination : " + nextLink);

                http:ClientConnector httpCon = create http:ClientConnector(nextLink);

                currentRequest = {};
                currentResponse = http:ClientConnector.get(httpCon, "", currentRequest);

                json currentJsonResponse = messages:getJsonPayload(currentResponse);
                int currentResponseLength = lengthof currentJsonResponse;

                int index = 0;

                while(index < currentResponseLength){

                    jsons:addToArray(combinedJsonResponse, "$", currentJsonResponse[index]);

                    index = index + 1;
                }

            } catch (errors:Error err){
                isLinkHeaderAvailable = false;
            }

        } catch(errors:Error err){
            logger:debug("link Header does not exist");
            isLinkHeaderAvailable = false;
        }
    }

    message combinedResponse = {};
    messages:setJsonPayload(combinedResponse, combinedJsonResponse);

    return combinedResponse;


}

function splitLinkHeader(string linkHeader)(json){
    logger:debug("splitLinkHeader function invoked for : " + linkHeader);


    //this will parse the link header present in the github response

    if (strings:length(linkHeader) == 0) {
        logger:error("Header length must be greater than zero");
    }

    string[] parts = strings:split(linkHeader, ",");
    json links = {};

    int i = 0;

    while (i < lengthof parts){
        string[] section = strings:split(parts[i], ";");

        if (lengthof section != 2){
            logger:error("header section could not be split on ';'");
        }

        string url = strings:trim(strings:replaceFirst(section[0], "<(.*)>", "$1"));
        string name = strings:subString(section[1], 6, strings:length(section[1]) -1 );

        jsons:addToObject(links, "$", name, url);

        i = i + 1;
    }

    logger:debug(links);

    return links;

}


function getConfigData(string filePath)(json){
    //get the config data read from the json
    files:File configFile = {path: filePath};

    try{
        files:open(configFile, "r");
        logger:debug(filePath + " file found");

    } catch (errors:Error err) {
        logger:error(filePath + " file not found. " + err.msg);
    }

    var content, numberOfBytes = files:read(configFile, FILE_READ_CHARACTER_LIMIT);
    logger:debug("Configuration details from " + filePath + " read");

    files:close(configFile);
    logger:debug(filePath + " file closed");

    string configString = blobs:toString(content, "utf-8");

    json configJson;

    try{
        configJson = jsons:parse(configString);

    } catch (errors:Error err) {
        logger:error("JSON syntax error found in "+ filePath + " " + err.msg);
        configJson = jsons:parse(configString);
        configJson = null;
    }
    return configJson;

}




function sortGithubIssues(sql:Parameter[][] batchParams, int componentId, string componentName, json issuesJson){

    logger:debug("SortGithubIssues function invoked for component : " + componentName);

    sql:ClientConnector sqlCon = createIssuesDBcon();

    int issuesJsonLength = lengthof issuesJson;

    json issueType = [];
    json severity = [];

    json issueTypeIDs = [];
    json severityIDs = [];

    string issueTypeLabelColor;
    string severityLabelColor;

    sql:Parameter[] paramsForIssueType = [];

    datatable issueTypeDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ISSUE_TYPE_QUERY, paramsForIssueType);

    while (datatables:hasNext(issueTypeDt)){
        any dataStruct = datatables:next(issueTypeDt);
        var rowSet, _ = (GithubIssueType)dataStruct;
        jsons:addToArray(issueType, "$", rowSet.pqd_issue_type_github_label_text);
        jsons:addToArray(issueTypeIDs, "$", rowSet.pqd_issue_type_id);

        issueTypeLabelColor = rowSet.pqd_issue_type_github_label_color;

        logger:debug("Data retrieved " + rowSet.pqd_issue_type);
    }

    datatables:close(issueTypeDt);

    sql:Parameter[] paramsForSeverity = [];

    datatable severityDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_SEVERITY_QUERY, paramsForSeverity);

    while (datatables:hasNext(severityDt)){
        any dataStruct = datatables:next(severityDt);
        var rowSet, _ = (GithubSeverity)dataStruct;
        jsons:addToArray(severity, "$", rowSet.pqd_severity_github_label_text);
        jsons:addToArray(severityIDs, "$", rowSet.pqd_severity_id);

        severityLabelColor = rowSet.pqd_severity_github_label_color;

        logger:debug("Data retrieved " + rowSet.pqd_severity);
    }

    datatables:close(severityDt);

    int index = 0;

    logger:debug("Issue Types : " + jsons:toString(issueType));

    logger:debug("Severity : "  + jsons:toString(severity));

    int[][] issuesCount = [];

    int n1 = 0;
    while (n1 < lengthof issueTypeIDs + 1){
        int[] tempIssuesCount = [];
        int n2 = 0;
        while (n2 < lengthof severityIDs + 1){
            tempIssuesCount[n2] = 0;
            n2 = n2 + 1;
        }
        issuesCount[n1] = tempIssuesCount;
        n1 = n1 + 1;
    }

    while(index < issuesJsonLength){

        json currentIssueJson = issuesJson[index];

        json issueTypeLabels = jsons:getJson(currentIssueJson, "$.labels[?(@.color=='" + issueTypeLabelColor +"')].name");


        int m = lengthof issueTypeIDs;
        int n = lengthof severityIDs;

        if(lengthof issueTypeLabels != 0){
            m =  getIndex(issueType, jsons:getString(issueTypeLabels, "$[0]"));
        }

        json severityLabels = jsons:getJson(currentIssueJson, "$.labels[?(@.color=='" + severityLabelColor +"')].name");

        if(lengthof severityLabels != 0){
            n =  getIndex(severity, jsons:getString(severityLabels, "$[0]"));
        }

        if(m == -1){
            m = lengthof issueTypeIDs;
        }

        if(n == -1){
            n = lengthof severityIDs;
        }

        issuesCount[m][n] = issuesCount[m][n] + 1;
        index = index + 1;
    }


    sql:Parameter[] paramForUnknown = [];
    json unknownIssueTypeId = getDataFromDatabase(GET_GITHUB_ISSUE_TYPE_UNKNOWN_QUERY, paramForUnknown);
    json unknownSeverityId = getDataFromDatabase(GET_GITHUB_SEVERITY_UNKNOWN_QUERY, paramForUnknown);

    jsons:addToArray(issueTypeIDs, "$", jsons:getInt(unknownIssueTypeId, "$[0].pqd_issue_type_id"));
    jsons:addToArray(severityIDs, "$", jsons:getInt(unknownSeverityId, "$[0].pqd_severity_id"));

    int commonIndex = lengthof batchParams;

    int p = 0;

    while(p < lengthof issueTypeIDs){
        int q = 0;

        while(q < lengthof severityIDs){

            sql:Parameter componentIdParam = {sqlType:"integer", value:componentId};
            sql:Parameter issueTypeIdParam = {sqlType:"integer", value:issueTypeIDs[p]};
            sql:Parameter severityIdParam = {sqlType:"integer", value:severityIDs[q]};
            sql:Parameter issueCountIdParam = {sqlType:"integer", value:issuesCount[p][q]};

            sql:Parameter[] paramsForComponentIssueInsert = [componentIdParam, issueTypeIdParam, severityIdParam, issueCountIdParam];
            batchParams[commonIndex] = paramsForComponentIssueInsert;
            commonIndex = commonIndex + 1;
            q = q + 1;
        }

        p = p + 1;
    }
    logger:debug(issuesCount);
    sqlCon.close();
}


function updateTotalForComponentIssues(sql:Parameter[][] batchParams){
    logger:debug("updateTotalForComponentIssues invoked");

    sql:ClientConnector sqlCon = createIssuesDBcon();

    transaction{
        sql:Parameter[] paramsForTruncate = [];
        int rowsDeleted = sql:ClientConnector.update(sqlCon, DELETE_GITHUB_COMPONENT_ISSUES_QUERY, paramsForTruncate);

        int[] rowsInserted = sql:ClientConnector.batchUpdate(sqlCon, INSERT_GITHUB_COMPONENT_ISSUES_QUERY, batchParams);


    }aborted{
        logger:info("Updating live github data for components failed");
        sqlCon.close();
    }committed{
        logger:debug("Updating live github data for components completed");
        sqlCon.close();
        updateTotalForProductIssues();
    }
}

function updateTotalForProductIssues(){
    logger:debug("updateTotalForProductIssues invoked");

    sql:ClientConnector sqlCon = createIssuesDBcon();

    transaction{
        sql:Parameter[] paramsForTruncate = [];
        int rowsDeleted = sql:ClientConnector.update(sqlCon, DELETE_GITHUB_TOTAL_PRODUCT_ISSUES_QUERY, paramsForTruncate);

        sql:Parameter[] paramsForProduct = [];
        int rowsInserted = sql:ClientConnector.update(sqlCon, GET_PRODUCT_TOTAL_ISSUES_QUERY, paramsForProduct);
    } aborted{
        logger:error("update product github issues transaction aborted");
        sqlCon.close();
    } committed{
        logger:debug("update product github issues transaction completed");
        sqlCon.close();
        updateTotalForAreaIssues();
    }
}


function updateTotalForAreaIssues(){
    logger:debug("updateTotalForAreaIssues invoked");

    sql:ClientConnector sqlCon = createIssuesDBcon();

    transaction{
        sql:Parameter[] paramsForTruncate = [];
        int rowsDeleted = sql:ClientConnector.update(sqlCon, DELETE_GITHUB_AREA_ISSUES_QUERY, paramsForTruncate);

        sql:Parameter[] paramsForArea = [];
        int rowsInserted = sql:ClientConnector.update(sqlCon, GET_AREA_ISSUES_QUERY, paramsForArea);
    } aborted{
        logger:error("update area github issues transaction aborted");
        sqlCon.close();
    } committed{
        logger:debug("update area github issues transaction completed");
        sqlCon.close();
    }
}

function getIndex(json array, string element)(int){
    //this function will return the index of the element in the json array

    int arrLength = lengthof array;

    //while loop to run through json array
    int i = 0;
    while(i < arrLength){
        if (jsons:getString(array, "$[" + i +"]") == element){
            return i;
        }
        i = i + 1;
    }
    return -1;
}


function getIssueTypeAll(sql:ClientConnector sqlCon)(json){
    logger:debug("Get issue type all function got invoked");

    //this function will return all the issue type in the database

    sql:Parameter[] paramsForIssueTypeAll = [];

    json issueTypesJson = getDataFromDatabase(GET_GITHUB_ISSUE_TYPE_ALL_QUERY, paramsForIssueTypeAll);
    json issueTypesArray = jsons:getJson(issueTypesJson, "$[*].pqd_issue_type");

    return issueTypesArray;
}


function getSeverityAll(sql:ClientConnector sqlCon)(json){
    logger:debug("Get severity all function got invoked");

    //this function will retrieve all the severity type in the database

    sql:Parameter[] paramsForSeverityAll = [];

    json severityJson = getDataFromDatabase(GET_GITHUB_SEVERITY_ALL_QUERY, paramsForSeverityAll);
    json severityArray = jsons:getJson(severityJson, "$[*].pqd_severity");

    return severityArray;
}



