package org.wso2.internalapps.productqualitydashboard;

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


@http:configuration {basePath:"/internal/product-quality/v1.0/github", httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> GithubService {
    json configData = getConfigData(CONFIG_PATH);

    map propertiesMap = getSQLconfigData(configData);
    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);


    @http:GET {}
    @http:Path {value:"/issues/count/product/{product-repo-name}"}
    resource getGithubIssuesCountForProduct(message m, @http:PathParam {value:"product-repo-name"} string productRepoName){
        http:ClientConnector httpCon = create http:ClientConnector("https://api.github.com");

        string issuesPath = "/repos/wso2/" + productRepoName + "/issues";

        message request = {};
        message requestH = {};

        message githubResponse = {};
        json githubJSONResponse = {};

        requestH = {};
        message response = {};


        githubResponse = http:ClientConnector.get(httpCon, issuesPath, requestH);
        githubJSONResponse = messages:getJsonPayload(githubResponse);

        int issuesCount = jsons:getInt(githubJSONResponse, "$.length()");

        json jsonResponse = {"error" : false, "count": issuesCount };

        messages:setJsonPayload(response, jsonResponse);

        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/count/component/{component-repo-name}"}
    resource getGithubIssuesCountForComponent(message m, @http:PathParam {value:"component-repo-name"} string componentRepoName){
        json responseJson = getRepoIssues("wso2", componentRepoName);
        message response = {};

        messages:setJsonPayload(response, responseJson);

        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/component/{component-id}"}
    resource getGithubIssuesForComponent(message m, @http:PathParam {value:"component-id"} int componentId){
        json responseJson = getComponentIssues(sqlCon, componentId);
        
        message response = {};

        messages:setJsonPayload(response, responseJson);

        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/all"}
    resource getGithubIssuesForAllAreas(message m){
        json responseJson = getAllAreaIssue(sqlCon);

        message response = {};

        messages:setJsonPayload(response, responseJson);

        reply response;
    }


    @http:GET {}
    @http:Path {value:"/issues/count/component/{component-repo-name}/type/{issue-type}"}
    resource getGithubIssuessForComponentByType(message m,
                                                @http:PathParam {value:"component-repo-name"} string componentRepoName,
                                                @http:PathParam {value:"issue-type"} string issueType){
        message response = {};
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/count"}
    resource getGithubIssuesByorganizationSummary(message m){
        logger:debug("getGithubIssuesByorganizationSummary invoked");

        message response = {};
        json jsonResponse = getOrganizationRepoSummary("wso2");

        messages:setJsonPayload(response, jsonResponse);

        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/summary"}
    resource getGithubIssuesForProductComponent(message m){
        logger:debug("getGithubIssuesForProductComponent invoked");

        message response = {};

        json jsonResponse = {"data": [], "error": false};

        sql:Parameter[] params = [];

        datatable productDatatable = sql:ClientConnector.select(sqlCon, GET_PRODUCT_DB_QUERY, params);

        while (datatables:hasNext(productDatatable)){
            any dataStruct1 = datatables:next(productDatatable);
            var productRowSet, _ = (Product)dataStruct1;
            logger:trace("Product retrieved " + productRowSet.pqd_product_name);

            json productJson = {"name": productRowSet.pqd_product_name,
                                   "component": []
                               };

            int productGithubOpenIssues = 0;

            sql:Parameter productIdParam = {sqlType:"varchar", value:productRowSet.pqd_product_id};
            sql:Parameter[] componentParams = [productIdParam];

            datatable componentDatatable = sql:ClientConnector.select(sqlCon, GET_COMPONENT_DB_QUERY, componentParams);


            while (datatables:hasNext(componentDatatable)){
                any dataStruct2 = datatables:next(componentDatatable);
                var componentRowSet, _ = (ComponentRepo)dataStruct2;

                logger:trace("Component Data retrieved : " + componentRowSet.pqd_component_name);

                int componentGithubOpenIssues = getGithubRepoOpenIssues(componentRowSet.pqd_github_repo_name);


                productGithubOpenIssues = productGithubOpenIssues + componentGithubOpenIssues;

                json componentJson = {"name": componentRowSet.pqd_component_name,
                                         "issues": componentGithubOpenIssues
                                     };

                jsons:addToArray(productJson, "$.component", componentJson);
            }

            jsons:addToObject(productJson, "$", "issues", productGithubOpenIssues);


            jsons:addToArray(jsonResponse, "$.data", productJson);



            datatables:close(componentDatatable);
        }

        datatables:close(productDatatable);

        messages:setJsonPayload(response, jsonResponse);

        messages:setHeader(response, "Access-Control-Allow-Origin", "*");

        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");

        reply response;

    }

    @http:GET {}
    @http:Path {value:"/repos"}
    resource getAllRepos(message m){

        logger:debug("Get all repos resource invoked");

        json responseJson = {"organizations" : [], "error": false};

        json organizations = getOrganizationList(sqlCon);

        int index = 0;

        while(index < lengthof organizations){
            var currentOrganization, _ = (string)organizations[index];
            json repoSummary = getOrganizationRepoSummary(currentOrganization);

            json repoNames = jsons:getJson(repoSummary, "$[*].name");
            json currentOrganizationJson = {"name": currentOrganization, "repos": repoNames};

            jsons:addToArray(responseJson, "$.organizations", currentOrganizationJson);

            index = index + 1;
        }

        message response = {};
        messages:setJsonPayload(response, responseJson);

        logger:debug("Get all repos responded successfully");
        reply response;
    }


    @http:GET {}
    @http:Path {value:"/areas"}
    resource getAllAreas(message m){
        logger:debug("Get all areas resource invoked");

        message response = {};
        json jsonResponse = {"areas": [], "error" : false };

        sql:Parameter[] paramsForArea = [];
        datatable areaDatatable = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_QUERY, paramsForArea);

        while (datatables:hasNext(areaDatatable)){
            any dataStruct = datatables:next(areaDatatable);
            var rowSet, _ = (GithubArea)dataStruct;
            jsons:addToArray(jsonResponse, "$.areas", rowSet.pqd_area_name);

            logger:debug("Data retrieved " + rowSet.pqd_area_name);
        }

        messages:setJsonPayload(response, jsonResponse);

        datatables:close(areaDatatable);

        logger:debug("getAllareas resources responded successfully");

        reply response;
    }

    @http:GET {}
    @http:Path {value:"/products"}
    resource getAllProducts(message m){
        logger:debug("Get all products resource invoked");

        message response = {};
        json jsonResponse = {"products": [], "error" : false };

        sql:Parameter[] paramsForProduct = [];
        datatable productDatatable = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_QUERY, paramsForProduct);

        while (datatables:hasNext(productDatatable)){
            any dataStruct = datatables:next(productDatatable);
            var rowSet, _ = (GithubProduct)dataStruct;
            jsons:addToArray(jsonResponse, "$.products", rowSet.pqd_product_name);

            logger:debug("Data retrieved " + rowSet.pqd_product_name);
        }

        messages:setJsonPayload(response, jsonResponse);

        datatables:close(productDatatable);

        logger:debug("getAllProducts resources responded successfully");

        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/update"}
    resource updateDatabaseWithLiveData(message m){
        logger:debug("updateDatabaseWithLiveData resource invoked");

        message response = {};

        logger:info(time:currentTime());

        sql:Parameter[] paramsForTruncate = [];
        sql:ClientConnector.update(sqlCon, DELETE_GITHUB_COMPONENT_ISSUES_QUERY, paramsForTruncate);

        sql:Parameter[] paramsForComponent = [];
        datatable componentDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_QUERY, paramsForComponent);

        var componentJson, _ = <json>componentDt;

        int a = 0;

        while(a < lengthof componentJson){
            logger:debug("check");
            try{
                string githubRepoName = jsons:getString(componentJson[a], "$.github_repo_name");
                string githubOrganization = jsons:getString(componentJson[a], "$.github_repo_organization");
                json issuesJson = getRepoIssues(githubOrganization, githubRepoName);
                sortGithubIssues(sqlCon, jsons:getInt(componentJson[a], "$.pqd_component_id"),
                                 jsons:getString(componentJson[a], "$.pqd_component_name"), issuesJson);
                logger:info("Data fetched successfully for componentId : " + jsons:getInt(componentJson[a], "$.pqd_component_id"));
                a = a + 1;
            } catch (errors:Error err) {
                logger:info("Data fetch failed for componentId : " + jsons:getInt(componentJson[a], "$.pqd_component_id"));
                logger:info(err.msg);
                a = a + 1;
            }
        }

        datatables:close(componentDt);

        updateTotalForProductIssues(sqlCon);

        updateTotalForAreaIssues(sqlCon);

        messages:setStringPayload(response, "Success");
        logger:debug("updateDatabaseWithLiveData resourve responded successfully");

        logger:info(time:currentTime());

        reply response;
    }


    @http:GET {}
    @http:Path {value:"/issues/updateOld"}
    resource updateDatabaseWithLiveDataOld(message m){

        message response = {};

        //sql:Parameter[] paramsForProduct = [];
        //datatable productDatatable = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_QUERY, paramsForProduct);
        //
        //int issueCount = 0;
        //
        //while(datatables:hasNext(productDatatable)){
        //    any productData = datatables:next(productDatatable);
        //    var productRowSet, _ = (GithubProduct)productData;
        //
        //    sql:Parameter productIdParam = {sqlType:"integer", value:productRowSet.pqd_product_id};
        //    sql:Parameter[] paramsForComponent = [productIdParam];
        //
        //
        //
        //    datatable componentDatatable = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_QUERY, paramsForComponent);
        //    while(datatables:hasNext(componentDatatable)){
        //        any componentData = datatables:next(componentDatatable);
        //        var componentRowSet, _ = (GithubComponent)componentData;
        //
        //        json componentIssueJson = getGithubComponentIssuesv4(componentRowSet.pqd_component_github_repo);
        //
        //
        //        sql:Parameter componentIdParam = {sqlType:"integer", value:componentRowSet.pqd_component_id};
        //        sql:Parameter[] paramsForComponentVersion = [componentIdParam];
        //
        //        datatable componentVersionDatatable = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_VERSION_QUERY, paramsForComponentVersion);
        //        while(datatables:hasNext(componentVersionDatatable)){
        //            any componentVersionData = datatables:next(componentVersionDatatable);
        //            var componentVersionRowSet, _ = (GithubComponentVersion)componentVersionData;
        //
        //            sql:Parameter componentVersionIdParam = {sqlType:"integer", value:componentVersionRowSet.pqd_component_version_id};
        //            sql:Parameter[] paramsForIssueType = [componentVersionIdParam];
        //
        //            //json filteredComponentVersionJson = jsons:getJson(componentIssueJson, "");
        //
        //            datatable issueTypeDatatable = sql:ClientConnector.select(sqlCon, GET_GITHUB_ISSUETYPE_QUERY, paramsForIssueType);
        //            while(datatables:hasNext(issueTypeDatatable)){
        //                any issueTypeData = datatables:next(issueTypeDatatable);
        //                var issueTypeRowSet, _ = (GithubIssueType)issueTypeData;
        //
        //                sql:Parameter[] paramsForSeverity = [componentVersionIdParam];
        //
        //                datatable severityDatatable = sql:ClientConnector.select(sqlCon, GET_GITHUB_SEVERITY_QUERY, paramsForSeverity);
        //
        //                while(datatables:hasNext(severityDatatable)){
        //                    any severityData = datatables:next(severityDatatable);
        //                    var severityRowSet, _ = (GithubSeverity)severityData;
        //
        //                    string check = productRowSet.pqd_product_name + " " +
        //                                   componentRowSet.pqd_component_name + " " +
        //                                   componentVersionRowSet.pqd_component_version + " " +
        //                                   issueTypeRowSet.pqd_issue_type + " " +
        //                                   severityRowSet.pqd_severity;
        //
        //                    logger:info(check);
        //                }
        //            }
        //            datatables:close(issueTypeDatatable);
        //        }
        //        datatables:close(componentVersionDatatable);
        //    }
        //    datatables:close(componentDatatable);
        //}
        //
        //datatables:close(productDatatable);
        //
        ////messages:setJsonPayload(response, check);

        reply response;

    }

    @http:GET {}
    @http:Path {value:"/issues/store"}
    resource storeDataInHistory(message m){
        logger:debug("storeDataInHistory resource got invoked");

        message response = {};

        sql:Parameter[] paramForCurrentIssues = [];

        datatable currentIssueCountDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_CURRENT_ISSUES_QUERY, paramForCurrentIssues);

        sql:Parameter[][] batchParams = [];
        int a = 0;

        while(datatables:hasNext(currentIssueCountDt)){
            any currentIssueCountStruct = datatables:next(currentIssueCountDt);
            var currentIssueCount, _ = (GithubComponentIssue)currentIssueCountStruct;

            sql:Parameter componentIdParam = {sqlType:"integer", value:currentIssueCount.pqd_component_id};
            sql:Parameter issueTypeIdParam = {sqlType:"integer", value:currentIssueCount.pqd_issue_type_id};
            sql:Parameter severityIdParam = {sqlType:"integer", value:currentIssueCount.pqd_severity_id};
            sql:Parameter issuesCountParam = {sqlType:"integer", value:currentIssueCount.pqd_issues_count};

            int year;
            int month;
            int day;
            time:Time currentTime = time:currentTime();
            year, month, day = time:getDate(currentTime);
            string date = year + "-" + month + "-" + day;

            sql:Parameter dateParam = {sqlType:"varchar", value:date};

            sql:Parameter[] currentParamsForBatchUpdate = [componentIdParam, issueTypeIdParam, severityIdParam, issuesCountParam, dateParam];

            batchParams[a] = currentParamsForBatchUpdate;

            a = a + 1;

        }

        int[] count = sql:ClientConnector.batchUpdate(sqlCon, INSERT_GITHUB_COMPONENT_ISSUES_HISTORY_QUERY,batchParams);

        datatables:close(currentIssueCountDt);


        datatable currentProductIssueCountDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_CURRENT_ISSUES_QUERY, paramForCurrentIssues);

        sql:Parameter[][] batchParams1 = [];
        int b = 0;

        while(datatables:hasNext(currentProductIssueCountDt)){
            any currentProductIssueCountStruct = datatables:next(currentProductIssueCountDt);
            var currentIssueCount, _ = (GithubProductIssue)currentProductIssueCountStruct;

            sql:Parameter productIdParam = {sqlType:"integer", value:currentIssueCount.pqd_product_id};
            sql:Parameter issueTypeIdParam = {sqlType:"integer", value:currentIssueCount.pqd_issue_type_id};
            sql:Parameter severityIdParam = {sqlType:"integer", value:currentIssueCount.pqd_severity_id};
            sql:Parameter issuesCountParam = {sqlType:"integer", value:currentIssueCount.pqd_issues_count};

            int year;
            int month;
            int day;
            time:Time currentTime = time:currentTime();
            year, month, day = time:getDate(currentTime);
            string date = year + "-" + month + "-" + day;

            sql:Parameter dateParam = {sqlType:"varchar", value:date};

            sql:Parameter[] currentParamsForBatchUpdate = [productIdParam, issueTypeIdParam, severityIdParam, issuesCountParam, dateParam];

            batchParams1[b] = currentParamsForBatchUpdate;

            b = b + 1;

        }

        int[] count1 = sql:ClientConnector.batchUpdate(sqlCon, INSERT_GITHUB_PRODUCT_ISSUES_HISTORY_QUERY,batchParams1);

        datatables:close(currentProductIssueCountDt);


        datatable currentAreaIssueCountDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_CURRENT_ISSUES_QUERY, paramForCurrentIssues);

        sql:Parameter[][] batchParams2 = [];
        int c = 0;

        while(datatables:hasNext(currentAreaIssueCountDt)){
            any currentAreaIssueCountStruct = datatables:next(currentAreaIssueCountDt);
            var currentIssueCount, _ = (GithubAreaIssue)currentAreaIssueCountStruct;

            sql:Parameter areaIdParam = {sqlType:"integer", value:currentIssueCount.pqd_area_id};
            sql:Parameter issueTypeIdParam = {sqlType:"integer", value:currentIssueCount.pqd_issue_type_id};
            sql:Parameter severityIdParam = {sqlType:"integer", value:currentIssueCount.pqd_severity_id};
            sql:Parameter issuesCountParam = {sqlType:"integer", value:currentIssueCount.pqd_issues_count};

            int year;
            int month;
            int day;
            time:Time currentTime = time:currentTime();
            year, month, day = time:getDate(currentTime);
            string date = year + "-" + month + "-" + day;

            sql:Parameter dateParam = {sqlType:"varchar", value:date};

            sql:Parameter[] currentParamsForBatchUpdate = [areaIdParam, issueTypeIdParam, severityIdParam, issuesCountParam, dateParam];

            batchParams2[c] = currentParamsForBatchUpdate;

            c = c + 1;

        }

        int[] count2 = sql:ClientConnector.batchUpdate(sqlCon, INSERT_GITHUB_AREA_ISSUES_HISTORY_QUERY,batchParams2);

        datatables:close(currentAreaIssueCountDt);

        messages:setStringPayload(response, "SUCCESS");

        logger:debug("storeDataInHistory resource responded successfully");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/issues/issuetype/{issueTypeId}/severity/{severityId}"}
    resource getIssuesFilteredAll(message m, @http:PathParam {value: "issueTypeId"} int issueTypeId,
                                       @http:PathParam {value: "severityId"} int severityId,
                                       @http:QueryParam {value:"category"} string category,
                                       @http:QueryParam {value:"categoryId"} int categoryId){

        message response = {};

        json responseJson;

        if(category == "all"){
            if ((issueTypeId == 0) && (severityId == 0)){
                responseJson = getAllAreaIssue(sqlCon);
            }
            else if (issueTypeId == 0){
                responseJson = getAllAreaSeverityIssues(sqlCon, severityId);
            }
            else if (severityId == 0){
                responseJson = getAllAreaIssueTypeIssues(sqlCon, issueTypeId);
            }
            else if ((issueTypeId != 0) && (severityId != 0)){
                responseJson = getAllAreaIssueTypeSeverityIssues(sqlCon, issueTypeId, severityId);
            }


        } else if (category == "area"){
            if ((issueTypeId == 0) && (severityId == 0)){
                responseJson = getAreaIssues(sqlCon, categoryId);
            }
            else if (issueTypeId == 0){
                responseJson = getAreaSeverityIssues(sqlCon, categoryId, severityId);
            }
            else if (severityId == 0){
                responseJson = getAreaIssueTypeIssues(sqlCon, categoryId, issueTypeId);
            }
            else if ((issueTypeId != 0) && (severityId != 0)){
                responseJson = getAreaIssueTypeSeverityIssues(sqlCon, categoryId, issueTypeId, severityId);
            }


        } else if (category == "product"){
            if ((issueTypeId == 0) && (severityId == 0)){
                responseJson = getProductIssues(sqlCon, categoryId);
            }
            else if (issueTypeId == 0){
                responseJson = getProductSeverityIssues(sqlCon, categoryId, severityId);
            }
            else if (severityId == 0){
                responseJson = getProductIssueTypeIssues(sqlCon, categoryId, issueTypeId);
            }
            else if ((issueTypeId != 0) && (severityId != 0)){
                responseJson = getProductIssueTypeSeverityIssues(sqlCon, categoryId, issueTypeId, severityId);
            }
        } else if (category == "version"){

        } else if (category == "component"){
                    if ((issueTypeId == 0) && (severityId == 0)){
                        responseJson = getComponentIssues1(sqlCon, categoryId);
                    }
                    else if (issueTypeId == 0){
                        responseJson = getComponentSeverityIssues(sqlCon, categoryId, severityId);
                    }
                    else if (severityId == 0){
                        responseJson = getComponentIssueTypeIssues(sqlCon, categoryId, issueTypeId);
                    }
                    else if ((issueTypeId != 0) && (severityId != 0)){
                        responseJson = getComponentIssueTypeSeverityIssues(sqlCon, categoryId, issueTypeId, severityId);
                    }
        }

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

        json responseJson = getGithubHistory(sqlCon, category, categoryId, issueTypeId, severityId, startDate, endDate, period);

        messages:setJsonPayload(response, responseJson);

        messages:setHeader(response, "Access-Control-Allow-Origin", "*");

        messages:setHeader(response, "Access-Control-Allow-Methods", "GET, OPTIONS");


        reply response;

    }


}

function getOrganizationRepoSummary (string organization) (json) {

    logger:debug("getorganizationRepoSummary function invoked for organization " + organization);

    message response = httpGetForGithub("/orgs/"+ organization + "/repos");
    json jsonResponse = messages:getJsonPayload(response);


    logger:trace("organization repo summary received : " + jsons:toString(jsonResponse) );

    return jsonResponse;
}


function getRepoSummary(string repoName)(json){
    logger:debug("getRepoSummary function invoked for repo " + repoName);

    message response = httpGetForGithub("/repos/wso2/" + repoName);
    json jsonResponse = messages:getJsonPayload(response);

    logger:trace("repo summary received : " + jsons:toString(jsonResponse));

    return jsonResponse;
}


function getRepoIssues(string organization, string repoName)(json){
    logger:debug("getRepoIssues function invoked for repo " + repoName);

    message response = httpGetForGithub("/repos/" + organization +"/" + repoName + "/issues");
    json jsonResponse = messages:getJsonPayload(response);

    json filteredJson = jsons:getJson(jsonResponse, "$.[?(@.state=='open')]");

    logger:trace("repo issues received : " + jsons:toString(jsonResponse));

    return filteredJson;
}

function getRepoIssuesByType(string repoName, string issueType)(json){
    logger:debug("getRepoIssuesByType function invoked for repo " + repoName);

    message response = httpGetForGithub("/repos/wso2/" + repoName + "/issues");
    json jsonResponse = messages:getJsonPayload(response);

    logger:trace("repo issues received : " + jsons:toString(jsonResponse));

    return jsonResponse;
}

function getGithubRepoOpenIssues(string repoName)(int issueCount){
    logger:debug("getRepoOpenIssues function invoked for repo " + repoName);

    message response = httpGetForGithub("/repos/wso2/" + repoName);
    json jsonResponse = messages:getJsonPayload(response);

    issueCount = jsons:getInt(jsonResponse, "$.open_issues");

    logger:trace("repo issues received for " + repoName + " : " + issueCount);

    return issueCount;
}

function getGithubRepoIssueCountByLabel(string repoName)(json issueCountByLabel){
    logger:debug("getGithubRepoIssueCountByLabel function invoked for repo " + repoName);

    json repoIssues = getRepoIssues("wso2", repoName);

    json labels = getGithubRepoLabels(repoName);

    issueCountByLabel = [];

    int i = 0;

    while (i < lengthof labels){

        string jsonPath = "$..labels[?(@.name==" + jsons:getString(labels, "$.[" + i + "]");
        json filteredIssuesByLabel = jsons:getJson(repoIssues, jsonPath );
        int issueCount = lengthof filteredIssuesByLabel;

        json issueCountJson = {"name":labels[i], "issues":issueCount};

        jsons:addToArray(issueCountByLabel,"$", issueCountJson);

        i = i + 1;
    }

    return issueCountByLabel;
}

function getGithubRepoLabels(string repoName)(json labels){
    logger:debug("getGithubRepoLabels function invoked for repo " + repoName);

    message labelResponse  = httpGetForGithub("/repos/wso2/" + repoName + "labels");
    json labelJson = messages:getJsonPayload(labelResponse);

    labels = jsons:getJson(labelJson, "$..name");

    logger:debug("labels returned : " + jsons:toString(labels));

    return labels;

}



function httpGetForGithub(string path)(message ){

    logger:debug("httpGetForGithub function invoked with path " + path);

    string domainUrl = "https://api.github.com";
    message request = {};
    message response = {};

    json configData = getConfigData(CONFIG_PATH);

    http:ClientConnector githubCon = create http:ClientConnector(domainUrl);

    //messages:setHeader(request, "Authentication:", "token " + jsons:getString(configData, "$.githubAccessToken"));
    messages:setHeader(request, "Content-Type", "application/json");

    string clientId = jsons:getString(configData, "$.githubClientId");
    string clientSecret = jsons:getString(configData, "$.githubClientSecret");

    string authenticatedPath = path + "?client_id=" + clientId + "&client_secret=" + clientSecret + "&per_page=100";

    response = http:ClientConnector.get(githubCon, authenticatedPath, request);

    message finalResponse = collectDataFromPagination(response);

    return finalResponse;

}


function collectDataFromPagination(message response)(message ){
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

                //jsons:addToArray(combinedJsonResponse, "$", messages:getJsonPayload(currentResponse));


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

    files:File configFile = {path: filePath};

    try{
        files:open(configFile, "r");
        logger:debug(filePath + " file found");

    } catch (errors:Error err) {
        logger:error(filePath + " file not found. " + err.msg);
    }

    var content, numberOfBytes = files:read(configFile, 100000);
    logger:debug(filePath + " content read");

    files:close(configFile);
    logger:debug(filePath + " file closed");

    string configString = blobs:toString(content, "utf-8");

    try{
        json configJson = jsons:parse(configString);
        return configJson;

    } catch (errors:Error err) {
        logger:error("JSON syntax error found in "+ filePath + " " + err.msg);
        json configJson = jsons:parse(configString);
    }

    return null;


}

function getGithubComponentIssuesv4(string productRepo)(json){

    logger:info("getGithubProductIssuesv4 function invoked with productRepo " + productRepo );

    string domainUrl = "https://api.github.com";
    message request = {};
    message response = {};

    json configData = getConfigData(CONFIG_PATH);

    http:ClientConnector githubCon = create http:ClientConnector(domainUrl);

    messages:setHeader(request, "Authorization", "bearer " + jsons:getString(configData, "$.githubAccessToken"));
    messages:setHeader(request, "Content-Type", "application/json");

    //string clientId = jsons:getString(configData, "$.githubClientId");
    //string clientSecret = jsons:getString(configData, "$.githubClientSecret");
    //
    //string authenticatedPath = path + "?client_id=" + clientId + "&client_secret=" + clientSecret + "&per_page=100";

    json requestJsonBody = {"query" : "query($repoNames: String!){organization(login:\"wso2\"){repository(name:$repoNames) {name, issues(first:100, states: OPEN) {edges {node {title,url, labels(first: 10) {edges {node {name, color}}}}} pageInfo{endCursor, hasNextPage} totalCount}}}}",
                               "variables": {"repoNames": productRepo}
                           };
    messages:setJsonPayload(request, requestJsonBody);

    response = http:ClientConnector.post(githubCon, "/graphql", request);

    //message finalResponse = collectDataFromPagination(response);

    json responseJson = messages:getJsonPayload(response);

    return responseJson;

}


function sortGithubIssues(sql:ClientConnector sqlCon, int componentId, string componentName, json issuesJson){

    logger:debug("SortGithubIssues function invoked for component : " + componentName);

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

    int[][] issuesCount = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];



    while(index < issuesJsonLength){

        json currentIssueJson = issuesJson[index];

        json issueTypeLabels = jsons:getJson(currentIssueJson, "$.labels[?(@.color=='" + issueTypeLabelColor +"')].name");


        int m = 7;

        int n = 5;

        if(lengthof issueTypeLabels != 0){
            m =  getIndex(issueType, jsons:getString(issueTypeLabels, "$[0]"));

        }

        json severityLabels = jsons:getJson(currentIssueJson, "$.labels[?(@.color=='" + severityLabelColor +"')].name");

        if(lengthof severityLabels != 0){
            n =  getIndex(severity, jsons:getString(severityLabels, "$[0]"));
        }

        if(m == -1){
            m = 7;
        }

        if(n == -1){
            n = 5;
        }

        issuesCount[m][n] = issuesCount[m][n] + 1;

        index = index + 1;
    }



    jsons:addToArray(issueTypeIDs, "$", 10);
    jsons:addToArray(severityIDs, "$", 7);

    int p = 0;


    while(p < lengthof issueTypeIDs){
        int q = 0;

        while(q < lengthof severityIDs){

            sql:Parameter componentIdParam = {sqlType:"integer", value:componentId};
            sql:Parameter issueTypeIdParam = {sqlType:"integer", value:issueTypeIDs[p]};
            sql:Parameter severityIdParam = {sqlType:"integer", value:severityIDs[q]};
            sql:Parameter issueCountIdParam = {sqlType:"integer", value:issuesCount[p][q]};

            sql:Parameter[] paramsForComponentIssueInsert = [componentIdParam, issueTypeIdParam, severityIdParam, issueCountIdParam];

            sql:ClientConnector.update(sqlCon, INSERT_GITHUB_COMPONENT_ISSUES_QUERY, paramsForComponentIssueInsert);

            q = q + 1;
        }

        p = p + 1;
    }


    logger:debug(issuesCount);
}

function sortGithubIssuesForProduct(sql:ClientConnector sqlCon, int productId, string productName, json issuesJson) {

    logger:debug("SortGithubIssues function invoked for product : " + productName);

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

    int[][] issuesCount = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];



    while(index < issuesJsonLength){

        json currentIssueJson = issuesJson[index];

        json issueTypeLabels = jsons:getJson(currentIssueJson, "$.labels[?(@.color=='" + issueTypeLabelColor +"')].name");


        int m = 7;

        int n = 5;

        if(lengthof issueTypeLabels != 0){
            m =  getIndex(issueType, jsons:getString(issueTypeLabels, "$[0]"));

        }

        json severityLabels = jsons:getJson(currentIssueJson, "$.labels[?(@.color=='" + severityLabelColor +"')].name");

        if(lengthof severityLabels != 0){
            n =  getIndex(severity, jsons:getString(severityLabels, "$[0]"));
        }

        if(m == -1){
            m = 7;
        }

        if(n == -1){
            n = 5;
        }

        issuesCount[m][n] = issuesCount[m][n] + 1;

        index = index + 1;
    }



    jsons:addToArray(issueTypeIDs, "$", 10);
    jsons:addToArray(severityIDs, "$", 7);

    int p = 0;


    while(p < lengthof issueTypeIDs){
        int q = 0;

        while(q < lengthof severityIDs){

            sql:Parameter productIdParam = {sqlType:"integer", value:productId};
            sql:Parameter issueTypeIdParam = {sqlType:"integer", value:issueTypeIDs[p]};
            sql:Parameter severityIdParam = {sqlType:"integer", value:severityIDs[q]};
            sql:Parameter issueCountIdParam = {sqlType:"integer", value:issuesCount[p][q]};

            sql:Parameter[] paramsForProductIssueInsert = [productIdParam, issueTypeIdParam, severityIdParam, issueCountIdParam];

            sql:ClientConnector.update(sqlCon, INSERT_GITHUB_PRODUCT_ISSUES_QUERY, paramsForProductIssueInsert);

            q = q + 1;
        }

        p = p + 1;
    }


    logger:debug(issuesCount);
}

function updateTotalForProductIssues(sql:ClientConnector sqlCon){
    logger:debug("updateTotalForProductIssues invoked");

    //sql:Parameter[] paramsForProductGroupBy = [];
    //
    //datatable productTotalIssuesDt = sql:ClientConnector.select(sqlCon, GET_PRODUCT_TOTAL_ISSUES_QUERY, paramsForProductGroupBy);
    //var productTotalIssuesVar, _ = <json> productTotalIssuesDt;
    //json productTotalIssuesJson = productTotalIssuesVar;
    //
    //datatables:close(productTotalIssuesDt);
    //
    //
    //sql:Parameter[] paramsForProduct = [];
    //
    //datatable productIssuesDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_CURRENT_ISSUES_QUERY, paramsForProduct);
    //var productIssuesVar, _ = <json>productIssuesDt;
    //json productIssuesJson = productIssuesVar;
    //
    //datatables:close(productIssuesDt);
    //
    //int a = 0;
    //
    //while(a < lengthof productIssuesJson){
    //
    //}

    sql:Parameter[] paramsForTruncate = [];
    int rows1 = sql:ClientConnector.update(sqlCon, DELETE_GITHUB_TOTAL_PRODUCT_ISSUES_QUERY, paramsForTruncate);

    sql:Parameter[] paramsForProduct = [];
    int rows2 = sql:ClientConnector.update(sqlCon, GET_PRODUCT_TOTAL_ISSUES_QUERY, paramsForProduct);

}


function updateTotalForAreaIssues(sql:ClientConnector sqlCon){
    logger:debug("updateTotalForAreaIssues invoked");


    sql:Parameter[] paramsForTruncate = [];
    int rows1 = sql:ClientConnector.update(sqlCon, DELETE_GITHUB_AREA_ISSUES_QUERY, paramsForTruncate);

    sql:Parameter[] paramsForArea = [];
    int rows2 = sql:ClientConnector.update(sqlCon, GET_AREA_ISSUES_QUERY, paramsForArea);

}

function getIndex(json array, string element)(int){
    int arrLength = lengthof array;

    int i = 0;

    while(i < arrLength){
        if (jsons:getString(array, "$[" + i +"]") == element){

            return i;
        }

        i = i + 1;
    }

    return -1;
}


function getComponentIssues(sql:ClientConnector sqlCon, int componentId)(json){
    logger:debug("get Component Issues function got invoked for component Id : " + componentId);

    sql:Parameter componentIdParam = {sqlType:"integer", value:componentId};

    sql:Parameter[] paramsForComponentIssues = [componentIdParam];

    datatable componentIssuesDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_ISSUES, paramsForComponentIssues);

    var componentIssuesVar, error = <json>componentIssuesDt;
    json componentIssuesJson = jsons:getJson(componentIssuesVar, "$");
    datatables:close(componentIssuesDt);

    json formattedComponentIssues = formatComponentIssues(sqlCon, componentId, componentIssuesJson);

    return formattedComponentIssues;
}


function getProductIssues(sql:ClientConnector sqlCon, int productId)(json){
    logger:debug("get Product Issues functions got invoked for product id : " + productId);

    sql:Parameter productIdParam = {sqlType:"integer", value:productId};
    sql:Parameter[] paramsForProduct = [productIdParam];


    datatable productIssueSumDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_SUM_QUERY, paramsForProduct);
    var productIssueVar, _ = <json>productIssueSumDt;
    logger:debug(productIssueVar);
    json productIssueJson = productIssueVar;
    datatables:close(productIssueSumDt);

    datatable productComponentIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_COMPONENT_ISSUES, paramsForProduct);
    var productComponentIssuesVar, _ = <json>productComponentIssueDt;
    logger:debug(productComponentIssuesVar);
    json productComponentJson = productComponentIssuesVar;
    datatables:close(productComponentIssueDt);

    datatable productIssueTypeIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_ISSUETYPE_ISSUES, paramsForProduct);
    var productIssueTypeIssuesVar, _ = <json>productIssueTypeIssueDt;
    logger:debug(productIssueTypeIssuesVar);
    json issueTypeJson = productIssueTypeIssuesVar;
    datatables:close(productIssueTypeIssueDt);

    datatable productSeverityDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_SEVERITY_ISSUES, paramsForProduct);
    var productSeverityIssuesVar, _ = <json>productSeverityDt;
    logger:debug(productSeverityIssuesVar);
    json severityJson = productSeverityIssuesVar;
    datatables:close(productSeverityDt);

    json responseJson = {"error":false, "data": {"items": [], "issueIssuetype":[], "issueSeverity":[]}};


    if (lengthof productIssueJson == 1) {
        var productIssuesVar, _ = <int>jsons:getFloat(productIssueJson[0], "$.pqd_issues_count");
        int areaIssuesInt = productIssuesVar;

        jsons:addToObject(responseJson, "$.data", "name", jsons:getString(productIssueJson[0], "$.pqd_product_name"));
        jsons:addToObject(responseJson, "$.data", "id", jsons:getInt(productIssueJson[0], "$.pqd_product_id"));
        jsons:addToObject(responseJson, "$.data", "issues", areaIssuesInt);

    } else {
        return responseJson;
    }

    int a = 0;

    while(a < lengthof productComponentJson){

        var productIssuesVar, _ = <int>jsons:getFloat(productComponentJson[a], "$.pqd_issues_count");
        int productIssues = productIssuesVar;

        //logger:info("check " +areaIssues);

        json currentProductItemJson = {"name": jsons:getString(productComponentJson[a], "$.pqd_component_name"),
                                          "id": jsons:getInt(productComponentJson[a], "$.pqd_component_id"),
                                          "issues": productIssues
                                      };

        jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);

        a = a + 1;
    }

    int b = 0;


    while(b < lengthof issueTypeJson){

        var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[b], "$.pqd_issues_count");
        int issueTypeIssues = issueTypeIssueVar;

        json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[b], "$.pqd_issue_type"),
                                        "id": jsons:getInt(issueTypeJson[b], "$.pqd_issue_type_id"),
                                        "issues": issueTypeIssues
                                    };

        jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);

        b = b + 1;
    }

    int c = 0;


    while(c < lengthof severityJson){

        var severityIssueVar, _ = <int>jsons:getFloat(severityJson[c], "$.pqd_issues_count");

        json currentSeverityJson = {"name": jsons:getString(severityJson[c], "$.pqd_severity"),
                                       "id": jsons:getInt(severityJson[c], "$.pqd_severity_id"),
                                       "issues": severityIssueVar
                                   };

        jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);

        c = c + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getComponentIssues1(sql:ClientConnector sqlCon, int componentId)(json){
    logger:debug("get Product Issues functions got invoked for component id : " + componentId);

    sql:Parameter paramForComponentId = {sqlType:"integer", value: componentId};
    sql:Parameter[] paramsForComponent = [paramForComponentId];

    json productIdJson = getDataFromDatabase(sqlCon, GET_PRODUCT_ID_FOR_COMPONENT_ID, paramsForComponent);

    int productId = 0;

    if (lengthof productIdJson > 0){
        productId = jsons:getInt(productIdJson, "$[0].pqd_product_id");
    } else {
        json responseJson = {"error":true, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};
        return responseJson;
    }

    sql:Parameter paramForProduct = {sqlType: "integer", value:productId};
    sql:Parameter[] paramsForProduct = [paramForProduct];


    datatable productIssueSumDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_SUM_QUERY, paramsForProduct);
    var productIssueVar, _ = <json>productIssueSumDt;
    logger:debug(productIssueVar);
    json productIssueJson = productIssueVar;
    datatables:close(productIssueSumDt);

    datatable productComponentIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_COMPONENT_ISSUES, paramsForProduct);
    var productComponentIssuesVar, _ = <json>productComponentIssueDt;
    logger:debug(productComponentIssuesVar);
    json productComponentJson = productComponentIssuesVar;
    datatables:close(productComponentIssueDt);


    datatable productIssueTypeIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_ISSUETYPE_ISSUES, paramsForComponent);
    var productIssueTypeIssuesVar, _ = <json>productIssueTypeIssueDt;
    logger:debug(productIssueTypeIssuesVar);
    json issueTypeJson = productIssueTypeIssuesVar;
    datatables:close(productIssueTypeIssueDt);

    datatable productSeverityDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_SEVERITY_ISSUES, paramsForComponent);
    var productSeverityIssuesVar, _ = <json>productSeverityDt;
    logger:debug(productSeverityIssuesVar);
    json severityJson = productSeverityIssuesVar;
    datatables:close(productSeverityDt);

    json responseJson = {"error":false, "data": {"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof productComponentJson){

        var productIssuesVar, _ = <int>jsons:getFloat(productComponentJson[a], "$.pqd_issues_count");
        int productIssues = productIssuesVar;

        //logger:info("check " +areaIssues);

        json currentProductItemJson = {"name": jsons:getString(productComponentJson[a], "$.pqd_component_name"),
                                          "id": jsons:getInt(productComponentJson[a], "$.pqd_component_id"),
                                          "issues": productIssues
                                      };

        jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);

        a = a + 1;
    }


    int b = 0;


    while(b < lengthof issueTypeJson){

        var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[b], "$.pqd_issues_count");
        int issueTypeIssues = issueTypeIssueVar;

        json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[b], "$.pqd_issue_type"),
                                        "id": jsons:getInt(issueTypeJson[b], "$.pqd_issue_type_id"),
                                        "issues": issueTypeIssues
                                    };

        jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);

        b = b + 1;
    }

    int c = 0;


    while(c < lengthof severityJson){

        var severityIssueVar, _ = <int>jsons:getFloat(severityJson[c], "$.pqd_issues_count");

        json currentSeverityJson = {"name": jsons:getString(severityJson[c], "$.pqd_severity"),
                                       "id": jsons:getInt(severityJson[c], "$.pqd_severity_id"),
                                       "issues": severityIssueVar
                                   };

        jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);

        c = c + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getAreaIssues(sql:ClientConnector sqlCon, int areaId)(json){
    logger:debug("get Area Issues functions got invoked for area id : " + areaId);

    sql:Parameter areaIdParam = {sqlType:"integer", value:areaId};
    sql:Parameter[] paramsForArea = [areaIdParam];


    datatable areaIssueSumDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_SUM_QUERY, paramsForArea);
    var areaIssueVar, _ = <json>areaIssueSumDt;
    logger:debug(areaIssueVar);
    json areaIssueJson = areaIssueVar;
    datatables:close(areaIssueSumDt);

    datatable areaProductIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_PRODUCT_ISSUES, paramsForArea);
    var areaProductIssuesVar, _ = <json>areaProductIssueDt;
    logger:debug(areaProductIssuesVar);
    json areaProductJson = areaProductIssuesVar;
    datatables:close(areaProductIssueDt);

    datatable areaIssueTypeIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_ISSUETYPE_ISSUES, paramsForArea);
    var areaIssueTypeIssuesVar, _ = <json>areaIssueTypeIssueDt;
    logger:debug(areaIssueTypeIssuesVar);
    json issueTypeJson = areaIssueTypeIssuesVar;
    datatables:close(areaIssueTypeIssueDt);

    datatable areaSeverityDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_SEVERITY_ISSUES, paramsForArea);
    var areaSeverityIssuesVar, _ = <json>areaSeverityDt;
    logger:debug(areaSeverityIssuesVar);
    json severityJson = areaSeverityIssuesVar;
    datatables:close(areaSeverityDt);

    json responseJson = {"error":false, "data": {"items": [], "issueIssuetype":[], "issueSeverity":[]}};


    if (lengthof areaIssueJson == 1){
        var areaIssuesVar, _ = <int>jsons:getFloat(areaIssueJson[0], "$.pqd_issues_count");
        int areaIssuesInt = areaIssuesVar;

        jsons:addToObject(responseJson, "$.data", "name", jsons:getString(areaIssueJson[0], "$.pqd_area_name"));
        jsons:addToObject(responseJson, "$.data", "id", jsons:getInt(areaIssueJson[0], "$.pqd_area_id"));
        jsons:addToObject(responseJson, "$.data", "issues", areaIssuesInt);

    } else {
        return responseJson;
    }

    int a = 0;


    while(a < lengthof areaProductJson){

        var areaIssuesVar, _ = <int>jsons:getFloat(areaProductJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssuesVar;

        //logger:info("check " +areaIssues);

        json currentProductItemJson = {"name": jsons:getString(areaProductJson[a], "$.pqd_product_name"),
                                       "id": jsons:getInt(areaProductJson[a], "$.pqd_product_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);

        a = a + 1;
    }

    int b = 0;


    while(b < lengthof issueTypeJson){

        var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[b], "$.pqd_issues_count");
        int issueTypeIssues = issueTypeIssueVar;

        json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[b], "$.pqd_issue_type"),
                                        "id": jsons:getInt(issueTypeJson[b], "$.pqd_issue_type_id"),
                                        "issues": issueTypeIssues
                                    };

        jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);

        b = b + 1;
    }

    int c = 0;


    while(c < lengthof severityJson){

        var severityIssueVar, _ = <int>jsons:getFloat(severityJson[c], "$.pqd_issues_count");

        json currentSeverityJson = {"name": jsons:getString(severityJson[c], "$.pqd_severity"),
                                       "id": jsons:getInt(severityJson[c], "$.pqd_severity_id"),
                                       "issues": severityIssueVar
                                   };

        jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);

        c = c + 1;
    }

    logger:info(responseJson);

    return responseJson;


}

function formatComponentIssues(sql:ClientConnector sqlCon, int componentId, json componentIssues)(json){
    logger:debug("formart Component Issues function got revoked for component Id : " + componentId);

    sql:Parameter componentIdParam = {sqlType:"integer", value:componentId};
    sql:Parameter[] paramsForComponentName = [componentIdParam];

    datatable componentNameDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_NAME_QUERY, paramsForComponentName);

    var componentNameVar, error = <json>componentNameDt;

    json componentNameJson = jsons:getJson(componentNameVar, "$");
    datatables:close(componentNameDt);

    string componentName;

    if (lengthof componentNameJson > 0){
        componentName = jsons:getString(componentNameJson, "$[0].pqd_component_name");
    } else{
        return null;
    }

    json formattedComponentIssues = {"error": false, "data": {"name" : componentName, "id" : componentId, "issueIssuetype": [], "issueSeverity": []}};

    json issueTypeJson = getIssueTypeAll(sqlCon);
    json severityJson = getSeverityAll(sqlCon);

    int issueIndex = 0;

    int currentComponentIssues = 0;

    while(issueIndex < lengthof issueTypeJson){

        int severityIndex = 0;
        int currentIssueTypeIssues = 0;

        json currentIssueType = {"name": issueTypeJson[issueIndex], "severity": []};

        var currentIssueTypeString, _ = (string)issueTypeJson[issueIndex];

        while(severityIndex < lengthof severityJson){

            var currentSeverityString, _ = (string)severityJson[severityIndex];
            json currentSeverityIssuesJson = jsons:getJson(componentIssues, "$.[?(@.pqd_severity=='"+ currentSeverityString +
                                                              "' && @.pqd_issue_type=='"+ currentIssueTypeString+"')].pqd_issues_count");


            int currentSeverityIssues = jsons:getInt(currentSeverityIssuesJson, "$[0]");


            currentIssueTypeIssues = currentIssueTypeIssues + currentSeverityIssues;
            json currentSeverity = { "name" : severityJson[severityIndex], "issues": currentSeverityIssues};

            jsons:addToArray(currentIssueType, "$.severity", currentSeverity);

            severityIndex = severityIndex + 1;
        }

        jsons:addToObject(currentIssueType, "$", "issues", currentIssueTypeIssues);
        jsons:addToArray(formattedComponentIssues, "$.data.issueIssuetype", currentIssueType);

        currentComponentIssues = currentComponentIssues + currentIssueTypeIssues;
        issueIndex = issueIndex + 1;
    }

    int severityIndex = 0;

    int currentComponentIssues1 = 0;

    while(severityIndex < lengthof severityJson){

        issueIndex = 0;
        int currentSeverityIssues = 0;

        json currentSeverity = {"name": severityJson[severityIndex], "issuetype": []};

        var currentSeverityString, _ = (string)severityJson[severityIndex];

        while(issueIndex < lengthof issueTypeJson){

            var currentIssueTypeString, _ = (string)issueTypeJson[issueIndex];
            json currentIssueTypeIssuesJson = jsons:getJson(componentIssues, "$.[?(@.pqd_severity=='"+ currentSeverityString +
                                                                            "' && @.pqd_issue_type=='"+ currentIssueTypeString+"')].pqd_issues_count");

            int currentIssueTypeIssues = jsons:getInt(currentIssueTypeIssuesJson, "$[0]");


            currentSeverityIssues = currentSeverityIssues + currentIssueTypeIssues;
            json currentIssueType = { "name" : issueTypeJson[issueIndex], "issues": currentIssueTypeIssues};

            jsons:addToArray(currentSeverity, "$.issuetype", currentIssueType);

            issueIndex = issueIndex + 1;
        }

        jsons:addToObject(currentSeverity,"$", "issues", currentSeverityIssues);
        jsons:addToArray(formattedComponentIssues, "$.data.issueSeverity", currentSeverity);

        currentComponentIssues1 = currentComponentIssues1 + currentSeverityIssues;
        severityIndex = severityIndex + 1;
    }

    jsons:addToObject(formattedComponentIssues, "$", "issues", currentComponentIssues);
    //jsons:addToObject(formattedComponentIssues, "$", "issues1", currentComponentIssues1);

    logger:debug("Format Component Issues function responded successfully with json : " + jsons:toString(formattedComponentIssues));

    return formattedComponentIssues;
}

function getAllAreaIssueTypeIssues(sql:ClientConnector sqlCon, int issueTypeId)(json){
    logger:debug("getAllAreaIssueTypeIssue function got invoked for issue type : " + issueTypeId);

    sql:Parameter paramForIssueTypeId = {sqlType: "integer", value: issueTypeId};
    sql:Parameter[] paramsForIssueTypeId = [paramForIssueTypeId];

    datatable allAreaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ALL_AREAS_ISSUETYPE_CURRENT_ISSUES_QUERY, paramsForIssueTypeId);
    var areaVar, _ = <json>allAreaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(allAreaIssueDt);

    datatable allSeverityIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ALL_AREAS_ISSUETYPE_SEVERITY_QUERY, paramsForIssueTypeId);
    var severityVar, _ = <json>allSeverityIssueDt;
    logger:debug(severityVar);
    json severityJson = severityVar;
    datatables:close(allSeverityIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_area_name"),
                                       "id": jsons:getInt(areaIssueJson[a], "$.pqd_area_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }

    int c = 0;

    while(c < lengthof severityJson){

        var severityIssueVar, _ = <int>jsons:getFloat(severityJson[c], "$.pqd_issues_count");

        json currentSeverityJson = {"name": jsons:getString(severityJson[c], "$.pqd_severity"),
                                       "id": jsons:getInt(severityJson[c], "$.pqd_severity_id"),
                                       "issues": severityIssueVar
                                   };

        jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);

        c = c + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getAllAreaSeverityIssues(sql:ClientConnector sqlCon, int severityId)(json){
    logger:debug("getAllAreaSeverityIssue function got invoked for severityID "+ severityId);

    sql:Parameter paramForSeverityId = {sqlType: "integer", value: severityId};
    sql:Parameter[] paramsForSeverityId = [paramForSeverityId];

    datatable allAreaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ALL_AREAS_SEVERITY_CURRENT_ISSUES_QUERY, paramsForSeverityId);
    var areaVar, _ = <json>allAreaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(allAreaIssueDt);

    datatable allIssueTypeIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ALL_AREAS_SEVERITY_ISSUETYPE_QUERY, paramsForSeverityId);
    var issueTypeVar, _ = <json>allIssueTypeIssueDt;
    logger:debug(issueTypeVar);
    json issueTypeJson = issueTypeVar;
    datatables:close(allIssueTypeIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_area_name"),
                                       "id": jsons:getInt(areaIssueJson[a], "$.pqd_area_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }

    int b = 0;

    while(b < lengthof issueTypeJson){

        var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[b], "$.pqd_issues_count");
        int issueTypeIssues = issueTypeIssueVar;

        json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[b], "$.pqd_issue_type"),
                                        "id": jsons:getInt(issueTypeJson[b], "$.pqd_issue_type_id"),
                                        "issues": issueTypeIssues
                                    };

        jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);

        b = b + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getAllAreaIssueTypeSeverityIssues(sql:ClientConnector sqlCon, int issueTypeId, int severityId)(json){
    logger:debug("getAllAreaSeverityIssue function got invoked for severityID "+ severityId);

    sql:Parameter paramForSeverityId = {sqlType: "integer", value: severityId};
    sql:Parameter paramForIssuetypeId = {sqlType: "integer", value: issueTypeId};
    sql:Parameter[] paramsForFilterId = [paramForIssuetypeId, paramForSeverityId];

    datatable allAreaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ALL_AREAS_FILTERED_CURRENT_ISSUES_QUERY, paramsForFilterId);
    var areaVar, _ = <json>allAreaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(allAreaIssueDt);



    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_area_name"),
                                       "id": jsons:getInt(areaIssueJson[a], "$.pqd_area_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }


    logger:info(responseJson);

    return responseJson;
}

function getAreaIssueTypeIssues(sql:ClientConnector sqlCon, int areaId, int issueTypeId)(json){
    logger:debug("getAreaIssueTypeIssue function got invoked for area : " + areaId + " and issue type : " + issueTypeId);

    sql:Parameter paramForAreaId = {sqlType:"integer", value: areaId};
    sql:Parameter paramForIssueTypeId = {sqlType: "integer", value: issueTypeId};
    sql:Parameter[] paramsForIssueTypeId = [paramForAreaId, paramForIssueTypeId];

    datatable areaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_PRODUCT_FILTER_BY_ISSUETYPE_ISSUES, paramsForIssueTypeId);
    var areaVar, _ = <json>areaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(areaIssueDt);

    datatable severityIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_SEVERITY_FILTER_BY_ISSUETYPE_ISSUES, paramsForIssueTypeId);
    var severityVar, _ = <json>severityIssueDt;
    logger:debug(severityVar);
    json severityJson = severityVar;
    datatables:close(severityIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_product_name"),
                                       "id": jsons:getInt(areaIssueJson[a], "$.pqd_product_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }

    int c = 0;

    while(c < lengthof severityJson){

        var severityIssueVar, _ = <int>jsons:getFloat(severityJson[c], "$.pqd_issues_count");

        json currentSeverityJson = {"name": jsons:getString(severityJson[c], "$.pqd_severity"),
                                       "id": jsons:getInt(severityJson[c], "$.pqd_severity_id"),
                                       "issues": severityIssueVar
                                   };

        jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);

        c = c + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getAreaSeverityIssues(sql:ClientConnector sqlCon, int areaId, int severityId)(json){
    logger:debug("getAreaSeverityIssue function got invoked for areaId : "+ areaId + " and severityID "+ severityId);

    sql:Parameter paramForAreaId = {sqlType: "integer", value: areaId};
    sql:Parameter paramForSeverityId = {sqlType: "integer", value: severityId};
    sql:Parameter[] paramsForSeverityId = [paramForAreaId, paramForSeverityId];

    datatable areaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_PRODUCT_FILTER_BY_SEVERITY_ISSUES, paramsForSeverityId);
    var areaVar, _ = <json>areaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(areaIssueDt);

    datatable issueTypeIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_ISSUETYPE_FILTER_BY_SEVERITY_ISSUES, paramsForSeverityId);
    var issueTypeVar, _ = <json>issueTypeIssueDt;
    logger:debug(issueTypeVar);
    json issueTypeJson = issueTypeVar;
    datatables:close(issueTypeIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_product_name"),
                                       "id": jsons:getInt(areaIssueJson[a], "$.pqd_product_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }

    int b = 0;

    while(b < lengthof issueTypeJson){

        var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[b], "$.pqd_issues_count");
        int issueTypeIssues = issueTypeIssueVar;

        json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[b], "$.pqd_issue_type"),
                                        "id": jsons:getInt(issueTypeJson[b], "$.pqd_issue_type_id"),
                                        "issues": issueTypeIssues
                                    };

        jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);

        b = b + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getAreaIssueTypeSeverityIssues(sql:ClientConnector sqlCon, int areaId, int issueTypeId, int severityId)(json){
    logger:debug("getAreaIssueTypeSeverityIssue function got invoked for areaId : " + areaId +
                 " issueTypeId : " +  issueTypeId + " severityID "+ severityId);

    sql:Parameter paramForAreaId = {sqlType: "integer", value: areaId};
    sql:Parameter paramForSeverityId = {sqlType: "integer", value: severityId};
    sql:Parameter paramForIssuetypeId = {sqlType: "integer", value: issueTypeId};
    sql:Parameter[] paramsForFilterId = [paramForAreaId, paramForSeverityId, paramForIssuetypeId];

    datatable allAreaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_AREA_PRODUCT_FILTER_BY_SEVERITY_AND_ISSUETYPE, paramsForFilterId);
    var areaVar, _ = <json>allAreaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(allAreaIssueDt);



    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_product_name"),
                                       "id": jsons:getInt(areaIssueJson[a], "$.pqd_product_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }


    logger:info(responseJson);
    return responseJson;
}

function getProductIssueTypeIssues(sql:ClientConnector sqlCon, int productId, int issueTypeId)(json){
    logger:debug("getProductIssueTypeIssue function got invoked for product : " + productId + " and issue type : " + issueTypeId);

    sql:Parameter paramForProductId = {sqlType:"integer", value: productId};
    sql:Parameter paramForIssueTypeId = {sqlType: "integer", value: issueTypeId};
    sql:Parameter[] paramsForIssueTypeId = [paramForProductId, paramForIssueTypeId];

    datatable productIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_ISSUETYPE, paramsForIssueTypeId);
    var productVar, _ = <json>productIssueDt;
    logger:debug(productVar);
    json productIssueJson = productVar;
    datatables:close(productIssueDt);

    datatable severityIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_SEVERITY_ISSUES_FILTER_BY_ISSUETYPE, paramsForIssueTypeId);
    var severityVar, _ = <json>severityIssueDt;
    logger:debug(severityVar);
    json severityJson = severityVar;
    datatables:close(severityIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof productIssueJson){

        var productIssueVar, _ = <int>jsons:getFloat(productIssueJson[a], "$.pqd_issues_count");
        int productIssues = productIssueVar;

        //logger:info("check " +areaIssues);

        json currentProductItemJson = {"name":jsons:getString(productIssueJson[a], "$.pqd_component_name"),
                                       "id": jsons:getInt(productIssueJson[a], "$.pqd_component_id"),
                                       "issues": productIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);

        a = a + 1;
    }

    int c = 0;

    while(c < lengthof severityJson){

        var severityIssueVar, _ = <int>jsons:getFloat(severityJson[c], "$.pqd_issues_count");

        json currentSeverityJson = {"name": jsons:getString(severityJson[c], "$.pqd_severity"),
                                       "id": jsons:getInt(severityJson[c], "$.pqd_severity_id"),
                                       "issues": severityIssueVar
                                   };

        jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);

        c = c + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getProductSeverityIssues(sql:ClientConnector sqlCon, int productId, int severityId)(json){
    logger:debug("getProductSeverityIssue function got invoked for areaId : "+ productId + " and severityID "+ severityId);

    sql:Parameter paramForProductId = {sqlType: "integer", value: productId};
    sql:Parameter paramForSeverityId = {sqlType: "integer", value: severityId};
    sql:Parameter[] paramsForSeverityId = [paramForProductId, paramForSeverityId];

    datatable productIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_SEVERITY, paramsForSeverityId);
    var productVar, _ = <json>productIssueDt;
    logger:debug(productVar);
    json productIssueJson = productVar;
    datatables:close(productIssueDt);

    datatable issueTypeIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_ISSUETYPE_ISSUES_FILTER_BY_SEVERITY, paramsForSeverityId);
    var issueTypeVar, _ = <json>issueTypeIssueDt;
    logger:debug(issueTypeVar);
    json issueTypeJson = issueTypeVar;
    datatables:close(issueTypeIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof productIssueJson) {

        var productIssueVar, _ = <int>jsons:getFloat(productIssueJson[a], "$.pqd_issues_count");
        int areaIssues = productIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(productIssueJson[a], "$.pqd_component_name"),
                                       "id": jsons:getInt(productIssueJson[a], "$.pqd_component_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }

    int b = 0;

    while(b < lengthof issueTypeJson){

        var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[b], "$.pqd_issues_count");
        int issueTypeIssues = issueTypeIssueVar;

        json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[b], "$.pqd_issue_type"),
                                        "id": jsons:getInt(issueTypeJson[b], "$.pqd_issue_type_id"),
                                        "issues": issueTypeIssues
                                    };

        jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);

        b = b + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getProductIssueTypeSeverityIssues(sql:ClientConnector sqlCon, int productId, int issueTypeId, int severityId)(json){
    logger:debug("getProductIssueTypeSeverityIssue function got invoked for areaId : " + productId +
                 " issueTypeId : " +  issueTypeId + " severityID "+ severityId);

    sql:Parameter paramForProductId = {sqlType:"integer", value:productId};
    sql:Parameter paramForSeverityId = {sqlType: "integer", value: severityId};
    sql:Parameter paramForIssuetypeId = {sqlType: "integer", value: issueTypeId};
    sql:Parameter[] paramsForFilterId = [paramForProductId, paramForSeverityId, paramForIssuetypeId];

    datatable allAreaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_ISSUETYPE_SEVERITY, paramsForFilterId);
    var areaVar, _ = <json>allAreaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(allAreaIssueDt);



    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_component_name"),
                                       "id": jsons:getInt(areaIssueJson[a], "$.pqd_component_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }


    logger:info(responseJson);
    return responseJson;
}

function getComponentIssueTypeIssues(sql:ClientConnector sqlCon, int componentId, int issueTypeId)(json){
    logger:debug("getComponentIssueTypeIssue function got invoked for component : " + componentId + " and issue type : " + issueTypeId);

    sql:Parameter paramForComponentId = {sqlType:"integer", value: componentId};
    sql:Parameter[] paramsForComponent = [paramForComponentId];

    json productIdJson = getDataFromDatabase(sqlCon, GET_PRODUCT_ID_FOR_COMPONENT_ID, paramsForComponent);

    int productId = 0;

    if (lengthof productIdJson > 0){
        productId = jsons:getInt(productIdJson, "$[0].pqd_product_id");
    } else {
        json responseJson = {"error":true, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};
        return responseJson;
    }

    sql:Parameter paramForProductId = {sqlType:"integer", value: productId};
    sql:Parameter paramForIssueTypeId = {sqlType: "integer", value: issueTypeId};
    sql:Parameter[] paramsForProductId = [paramForProductId, paramForIssueTypeId];

    datatable productIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_ISSUETYPE, paramsForProductId);
    var productVar, _ = <json>productIssueDt;
    logger:debug(productVar);
    json productIssueJson = productVar;
    datatables:close(productIssueDt);

    sql:Parameter[] paramsForComponentId = [paramForComponentId, paramForIssueTypeId];

    datatable severityIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_SEVERITY_ISSUES_FILTER_BY_ISSUETYPE, paramsForComponentId);
    var severityVar, _ = <json>severityIssueDt;
    logger:debug(severityVar);
    json severityJson = severityVar;
    datatables:close(severityIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof productIssueJson){

        var productIssueVar, _ = <int>jsons:getFloat(productIssueJson[a], "$.pqd_issues_count");
        int productIssues = productIssueVar;

        //logger:info("check " +areaIssues);

        json currentProductItemJson = {"name":jsons:getString(productIssueJson[a], "$.pqd_component_name"),
                                          "id": jsons:getInt(productIssueJson[a], "$.pqd_component_id"),
                                          "issues": productIssues
                                      };

        jsons:addToArray(responseJson, "$.data.items", currentProductItemJson);

        a = a + 1;
    }

    int c = 0;

    while(c < lengthof severityJson){

        var severityIssueVar, _ = <int>jsons:getFloat(severityJson[c], "$.pqd_issues_count");

        json currentSeverityJson = {"name": jsons:getString(severityJson[c], "$.pqd_severity"),
                                       "id": jsons:getInt(severityJson[c], "$.pqd_severity_id"),
                                       "issues": severityIssueVar
                                   };

        jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);

        c = c + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getComponentSeverityIssues(sql:ClientConnector sqlCon, int componentId, int severityId)(json){
    logger:debug("getComponentSeverityIssue function got invoked for areaId : "+ componentId + " and severityID "+ severityId);


    sql:Parameter paramForComponentId = {sqlType:"integer", value: componentId};
    sql:Parameter[] paramsForComponent = [paramForComponentId];

    json productIdJson = getDataFromDatabase(sqlCon, GET_PRODUCT_ID_FOR_COMPONENT_ID, paramsForComponent);

    int productId = 0;

    if (lengthof productIdJson > 0){
        productId = jsons:getInt(productIdJson, "$[0].pqd_product_id");
    } else {
        json responseJson = {"error":true, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};
        return responseJson;
    }

    sql:Parameter paramForProductId = {sqlType: "integer", value: productId};
    sql:Parameter paramForSeverityId = {sqlType: "integer", value: severityId};
    sql:Parameter[] paramsForProductId = [paramForProductId, paramForSeverityId];

    datatable productIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_SEVERITY, paramsForProductId);
    var productVar, _ = <json>productIssueDt;
    logger:debug(productVar);
    json productIssueJson = productVar;
    datatables:close(productIssueDt);

    sql:Parameter[] paramsForComponentId = [paramForComponentId, paramForSeverityId];

    datatable issueTypeIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_COMPONENT_ISSUETYPE_ISSUES_FILTER_BY_SEVERITY, paramsForComponentId);
    var issueTypeVar, _ = <json>issueTypeIssueDt;
    logger:debug(issueTypeVar);
    json issueTypeJson = issueTypeVar;
    datatables:close(issueTypeIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof productIssueJson) {

        var productIssueVar, _ = <int>jsons:getFloat(productIssueJson[a], "$.pqd_issues_count");
        int areaIssues = productIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(productIssueJson[a], "$.pqd_component_name"),
                                       "id": jsons:getInt(productIssueJson[a], "$.pqd_component_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }

    int b = 0;

    while(b < lengthof issueTypeJson){

        var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[b], "$.pqd_issues_count");
        int issueTypeIssues = issueTypeIssueVar;

        json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[b], "$.pqd_issue_type"),
                                        "id": jsons:getInt(issueTypeJson[b], "$.pqd_issue_type_id"),
                                        "issues": issueTypeIssues
                                    };

        jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);

        b = b + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getComponentIssueTypeSeverityIssues(sql:ClientConnector sqlCon, int componentId, int issueTypeId, int severityId)(json){
    logger:debug("getComponentIssueTypeSeverityIssue function got invoked for componentId : " + componentId +
                 " issueTypeId : " +  issueTypeId + " severityID "+ severityId);


    sql:Parameter paramForComponentId = {sqlType:"integer", value: componentId};
    sql:Parameter[] paramsForComponent = [paramForComponentId];

    json productIdJson = getDataFromDatabase(sqlCon, GET_PRODUCT_ID_FOR_COMPONENT_ID, paramsForComponent);

    int productId = 0;

    if (lengthof productIdJson > 0){
        productId = jsons:getInt(productIdJson, "$[0].pqd_product_id");
    } else {
        json responseJson = {"error":true, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};
        return responseJson;
    }


    sql:Parameter paramForProductId = {sqlType:"integer", value:productId};
    sql:Parameter paramForSeverityId = {sqlType: "integer", value: severityId};
    sql:Parameter paramForIssuetypeId = {sqlType: "integer", value: issueTypeId};
    sql:Parameter[] paramsForFilterId = [paramForProductId, paramForSeverityId, paramForIssuetypeId];

    datatable allAreaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_PRODUCT_COMPONENT_ISSUES_FILTERED_BY_ISSUETYPE_SEVERITY, paramsForFilterId);
    var areaVar, _ = <json>allAreaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(allAreaIssueDt);



    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_component_name"),
                                       "id": jsons:getInt(areaIssueJson[a], "$.pqd_component_id"),
                                       "issues": areaIssues
                                   };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }


    logger:info(responseJson);
    return responseJson;
}

function getAllAreaIssue(sql:ClientConnector sqlCon)(json) {
    logger:debug("getAllAreaIssue function got invoked");

    sql:Parameter[] paramForAllArea = [];

    datatable allAreaIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ALL_AREAS_CURRENT_ISSUES_QUERY, paramForAllArea);
    var areaVar, _ = <json>allAreaIssueDt;
    logger:debug(areaVar);
    json areaIssueJson = areaVar;
    datatables:close(allAreaIssueDt);

    datatable allIssueTypeIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ALL_AREAS_ISSUETYPE_QUERY, paramForAllArea);
    var issueTypeVar, _ = <json>allIssueTypeIssueDt;
    logger:debug(issueTypeVar);
    json issueTypeJson = issueTypeVar;
    datatables:close(allIssueTypeIssueDt);

    datatable allSeverityIssueDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ALL_AREAS_SEVERITY_QUERY, paramForAllArea);
    var severityVar, _ = <json>allSeverityIssueDt;
    logger:debug(severityVar);
    json severityJson = severityVar;
    datatables:close(allSeverityIssueDt);


    json responseJson = {"error":false, "data":{"items": [], "issueIssuetype":[], "issueSeverity":[]}};

    int a = 0;

    while(a < lengthof areaIssueJson){

        var areaIssueVar, _ = <int>jsons:getFloat(areaIssueJson[a], "$.pqd_issues_count");
        int areaIssues = areaIssueVar;

        //logger:info("check " +areaIssues);

        json currentAreaItemJson = {"name": jsons:getString(areaIssueJson[a], "$.pqd_area_name"),
                                  "id": jsons:getInt(areaIssueJson[a], "$.pqd_area_id"),
                                  "issues": areaIssues
                              };

        jsons:addToArray(responseJson, "$.data.items", currentAreaItemJson);

        a = a + 1;
    }

    int b = 0;

    while(b < lengthof issueTypeJson){

        var issueTypeIssueVar, _ = <int>jsons:getFloat(issueTypeJson[b], "$.pqd_issues_count");
        int issueTypeIssues = issueTypeIssueVar;

        json currentIssueTypeJson = {"name": jsons:getString(issueTypeJson[b], "$.pqd_issue_type"),
                                       "id": jsons:getInt(issueTypeJson[b], "$.pqd_issue_type_id"),
                                       "issues": issueTypeIssues
                                   };

        jsons:addToArray(responseJson, "$.data.issueIssuetype", currentIssueTypeJson);

        b = b + 1;
    }

    int c = 0;

    while(c < lengthof severityJson){

        var severityIssueVar, _ = <int>jsons:getFloat(severityJson[c], "$.pqd_issues_count");

        json currentSeverityJson = {"name": jsons:getString(severityJson[c], "$.pqd_severity"),
                                        "id": jsons:getInt(severityJson[c], "$.pqd_severity_id"),
                                        "issues": severityIssueVar
                                    };

        jsons:addToArray(responseJson, "$.data.issueSeverity", currentSeverityJson);

        c = c + 1;
    }

    logger:info(responseJson);
    return responseJson;
}

function getIssueTypeAll(sql:ClientConnector sqlCon)(json){
    logger:debug("Get issue type all function got invoked");

    sql:Parameter[] paramsForIssueTypeAll = [];
    datatable issueTypeDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ISSUE_TYPE_ALL_QUERY, paramsForIssueTypeAll);

    var issueTypes, err = <json>issueTypeDt;
    json issueTypesJson = jsons:getJson(issueTypes, "$");

    datatables:close(issueTypeDt);

    json issueTypesArray = jsons:getJson(issueTypesJson, "$[*].pqd_issue_type");

    return issueTypesArray;
}

function getSeverityAll(sql:ClientConnector sqlCon)(json){
    logger:debug("Get severity all function got invoked");

    sql:Parameter[] paramsForSeverityAll = [];
    datatable severityDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_SEVERITY_ALL_QUERY, paramsForSeverityAll);

    var severity, err = <json>severityDt;
    json severityJson = jsons:getJson(severity, "$");

    datatables:close(severityDt);

    json severityArray = jsons:getJson(severityJson, "$[*].pqd_severity");

    return severityArray;
}

function getOrganizationList (sql:ClientConnector sqlCon) (json) {
    logger:debug("Get organization list function got invoked");

    sql:Parameter[] paramsFororganization = [];
    datatable organizationDt = sql:ClientConnector.select(sqlCon, GET_GITHUB_ORGANIZATION_QUERY, paramsFororganization);

    var organizationList, _ = <json>organizationDt;

    datatables:close(organizationDt);
    json organizationJson = organizationList;

    json organizations = jsons:getJson(organizationJson, "$[*].pqd_organization_name");

    return organizations;
}


function getGithubHistory(sql:ClientConnector sqlCon, string category, int categoryId, int issueTypeId, int severityId, string startDate, string endDate, string period)(json){
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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_DAY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_DAY_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_DAY_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_DAY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_DAY_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_DAY_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_DAY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_DAY_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_DAY_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_DAY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_DAY_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_DAY_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_DAY_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_MONTH, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_MONTH_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_MONTH_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_MONTH, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_MONTH_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_MONTH_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_MONTH, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_MONTH_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_MONTH_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_MONTH, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_MONTH_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_MONTH_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_MONTH_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_QUARTER, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_QUARTER, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_QUARTER_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_QUARTER_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_QUARTER, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_QUARTER_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_QUARTER, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_QUARTER_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_QUARTER_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_YEAR, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_YEAR_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_YEAR_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_ALL_AREAS_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_YEAR, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_YEAR_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_YEAR_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_AREA_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_YEAR, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_YEAR_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_YEAR_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_PRODUCT_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_YEAR, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_YEAR_FILTER_SEVERITY, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_YEAR_FILTER_ISSUETYPE, params);

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
                json response = getDataFromDatabase(sqlCon, GET_GITHUB_COMPONENT_HISTORY_BY_YEAR_FILTER_ISSUETYPE_SEVERITY, params);

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
    datatable commonDt = sql:ClientConnector.select(sqlCon, sqlQuery, paramsForQuery);
    var commonVar, _ = <json>commonDt;
    logger:debug(commonVar);
    json commonDataResponseJson = commonVar;
    datatables:close(commonDt);
    return commonDataResponseJson;
}



