package org.wso2.internalapps.pqd;

import ballerina.data.sql;
import ballerina.lang.errors;
import ballerina.lang.files;
import ballerina.lang.blobs;
import ballerina.lang.jsons;
import ballerina.utils.logger;
import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.lang.strings;
import ballerina.lang.time;
import ballerina.lang.datatables;
import ballerina.lang.system;


function getConfigurationDataFromJSON (string FILE_PATH) (json) {
    files:File configFile = {path:FILE_PATH};

    try {
        files:open(configFile, "r");
        //logger:info("CONFIG.JSON READ SUCCESSFULLY");
    } catch (errors:Error err) {
        logger:info("ERROR IN READ CONGIG.JSON - "+ err.msg);
    }

    var content, numberOfBytes = files:read(configFile, 100000);
    files:close(configFile);
    string configString = blobs:toString(content, "utf-8");
    json configJson = null;

    try {
        configJson = jsons:parse(configString);
    } catch (errors:Error err) {
        logger:error("JSON PARSE FUNCTION ERROR - " + err.msg);
    }

    return configJson;
}

function setLocalDatabaseConfiguration()(sql:ClientConnector) {
    sql:ClientConnector dbConnection = null;

    try {
        json configs = getConfigurationDataFromJSON(CONFIGURATION_PATH_JENKINS);

        var dbHost, _ = (string)configs.LOCAL_JDBC.DB_HOST;
        var dbPort, _ = (int)configs.LOCAL_JDBC.DB_PORT;
        var dbName, _ = (string)configs.LOCAL_JDBC.DB_NAME;
        var dbUser, _ = (string)configs.LOCAL_JDBC.DB_USERNAME;
        var dbPassword, _ = (string)configs.LOCAL_JDBC.DB_PASSWORD;
        var dbPoolSize, _ = (int)configs.LOCAL_JDBC.MAXIMUM_POOL_SIZE;


        map props = {"jdbcUrl":"jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "", "username":dbUser, "password":dbPassword, "maximumPoolSize":dbPoolSize};
        dbConnection = create sql:ClientConnector(props);

        //logger:info("MYSQL DB CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING MYSQL DB CONNECTOR - " + err.msg);
    }

    return dbConnection;
}

function setPQDDatabaseConfiguration()(sql:ClientConnector) {
    sql:ClientConnector dbConnection = null;

    try {
        json configs = getConfigurationDataFromJSON(CONFIGURATION_PATH_JENKINS);

        var dbHost, _ = (string)configs.PQD_JDBC.DB_HOST;
        var dbPort, _ = (int)configs.PQD_JDBC.DB_PORT;
        var dbName, _ = (string)configs.PQD_JDBC.DB_NAME;
        var dbUser, _ = (string)configs.PQD_JDBC.DB_USERNAME;
        var dbPassword, _ = (string)configs.PQD_JDBC.DB_PASSWORD;
        var dbPoolSize, _ = (int)configs.PQD_JDBC.MAXIMUM_POOL_SIZE;


        map props = {"jdbcUrl":"jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "", "username":dbUser, "password":dbPassword, "maximumPoolSize":dbPoolSize};
        dbConnection = create sql:ClientConnector(props);

        //logger:info("MYSQL DB CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING MYSQL DB CONNECTOR - " + err.msg);
    }

    return dbConnection;
}

function setJenkinsConnector () {

    try {
        json JENKINSconfigs = getConfigurationDataFromJSON(CONFIGURATION_PATH_JENKINS);
        var JENKINS_BASE_URL, _ = (string)JENKINSconfigs.JENKINS.BASE_URL;

        JENKINS_Connector = create http:ClientConnector(JENKINS_BASE_URL);

        //logger:info("JENKINS CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING JENKINS CONNECTOR" + err.msg);
    }

}

function setGithubConnector () {

    try {
        json GITHUBconfigs = getConfigurationDataFromJSON(CONFIGURATION_PATH_JENKINS);
        var GITHUB_BASE_URL, _ = (string)GITHUBconfigs.GITHUB.BASE_URL;

        GITHUB_Connector = create http:ClientConnector(GITHUB_BASE_URL);

        //logger:info("GITHUB CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING GITHUB CONNECTOR - " + err.msg);
    }

}

function setSiddhiConnector () {

    try {
        json GITHUBconfigs = getConfigurationDataFromJSON(CONFIGURATION_PATH_JENKINS);
        var SIDDHI_BASE_URL, _ = (string)GITHUBconfigs.SIDDHI.BASE_URL;

        SIDDHI_Connector = create http:ClientConnector(SIDDHI_BASE_URL);

        logger:info("SIDDHI CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING SIDDHI CONNECTOR - " + err.msg);
    }

}

function setSiddhiRESTConnector () {

    try {
        json GITHUBconfigs = getConfigurationDataFromJSON(CONFIGURATION_PATH_JENKINS);
        var SIDDHI_REST_URL, _ = (string)GITHUBconfigs.SIDDHI.REST_API;

        SIDDHI_REST_Connector = create http:ClientConnector(SIDDHI_REST_URL);

        logger:info("SIDDHI REST CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING SIDDHI REST CONNECTOR - " + err.msg);
    }

}

function getBuildDataFromJenkinsAndGithub()(json){
    logger:info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    logger:info("JENKINS GET BUILD DATA JOB STARTED");
    logger:info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

    int globalIncrement = 0;
    int globalCurrentTime;
    json jenkinsAndGitBuildData = {"events":[]}; // json array that publish to stream processor
    int numberOfEvents = 0;

    //create MYSQL client connector
    sql:ClientConnector dbConnection = setPQDDatabaseConfiguration();

    //SQL parameters
    sql:Parameter[] params = [];

    //get all product components from database
    datatable resultsOfAllProductComponents = dbConnection.select(GET_ALL_PRODUCT_COMPONENTS, params);
    var jsonResOfProductComponents, _ = <json>resultsOfAllProductComponents;

    int sizeOfComponentJson = lengthof jsonResOfProductComponents;

    datatables:close(resultsOfAllProductComponents);
    dbConnection.close();


    if (JENKINS_Connector == null) {
        setJenkinsConnector();
    }

    json configs = getConfigurationDataFromJSON(CONFIGURATION_PATH_JENKINS);
    var JENKINS_ACCESS_TOKEN, _ = (string)configs.JENKINS.ACCESS_TOKEN;

    int loop = 0;
    while (loop < sizeOfComponentJson) {

        var component,_ = (string)jsonResOfProductComponents[loop].pqd_component_name;
        var productAreaId,_ = (int)jsonResOfProductComponents[loop].pqd_area_id;
        string areaName;

        //get relevant product area name according to the product area id
        sql:ClientConnector pqdConnector = setPQDDatabaseConfiguration();
        sql:Parameter[] paramsOfProduct = [];
        sql:Parameter areaIdOfProduct = {sqlType:"integer", value:productAreaId};
        paramsOfProduct = [areaIdOfProduct];

        datatable resultsOfAreaName = pqdConnector.select(GET_AREA_NAME, paramsOfProduct);
        var jsonResOfAreaName, _ = <json>resultsOfAreaName;

        areaName,_ = (string)jsonResOfAreaName[0].pqd_area_name;

        datatables:close(resultsOfAreaName);
        pqdConnector.close();


        //get relevant repo folder in jenkins
        sql:ClientConnector folderMappingConnection = setPQDDatabaseConfiguration();
        sql:Parameter[] paramsOfComponent = [];
        sql:Parameter components = {sqlType:"varchar", value:component};
        paramsOfComponent = [components];

        datatable resultsOfFolderName = folderMappingConnection.select(GET_REPO_FOLDER, paramsOfComponent);
        var jsonResOfFolderName, _ = <json>resultsOfFolderName;

        int lengthOfFolderResult = lengthof jsonResOfFolderName;

        datatables:close(resultsOfFolderName);
        folderMappingConnection.close();

        try{
            if(lengthOfFolderResult != 0){
                var folderName,_ = (string)jsonResOfFolderName[0].Folder;

                json allBuildDataFromjenkins = [];

                datatables:close(resultsOfFolderName);
                folderMappingConnection.close();


                try {
                    message request = {};
                    message response = {};
                    messages:setHeader(request, "Authorization", JENKINS_ACCESS_TOKEN);

                    if(folderName != "none"){
                        response = JENKINS_Connector.get("/job/"+folderName+"/job/"+component+"/api/json?tree=builds[actions[causes[shortDescription],lastBuiltRevision[SHA1],remoteUrls],url,duration,number,result,timestamp,changeSet[items[author[fullName]]],culprits[fullName]]&pretty=true", request);
                    }else{
                        response = JENKINS_Connector.get("/job/"+component+"/api/json?tree=builds[actions[causes[shortDescription],lastBuiltRevision[SHA1],remoteUrls],url,duration,number,result,timestamp,changeSet[items[author[fullName]]],culprits[fullName]]&pretty=true", request);
                    }

                    system:println("https://wso2.org/jenkins/job/"+folderName+"/job/"+component+"/");

                    int statusCode = http:getStatusCode(response);

                    if (statusCode == 200) {
                        logger:info("RECEIVED " + folderName + "/" + component + " BUILD DATA FROM JENKINS");
                        json jenkinsBuildRecords = messages:getJsonPayload(response);
                        allBuildDataFromjenkins = jenkinsBuildRecords;
                    } else {
                        logger:info("ERROR IN RECEIVING " + folderName + "/" + component + " BUILD DATA FROM JENKINS!!!!");
                        allBuildDataFromjenkins = {"builds":[]};
                    }

                } catch (errors:Error err) {
                    logger:error("JENKINS CONNECTION ERROR - " + err.msg);
                }


                int loop2 = 0;
                int numberOfBuildsInComponent = lengthof allBuildDataFromjenkins.builds;
                int relatedBuildCountPerComponent = 0;
                int SUCCESS_COUNT = 0;
                int FAILURE_COUNT = 0;

                while(loop2 < numberOfBuildsInComponent){
                    //current time
                    time:Time currentTime = time:currentTime();
                    int currentTimeInt = currentTime.time;

                    //substract 1 day from current time
                    time:Time timeStructSub = time:subtractDuration(currentTime, 0, 0, 1, 0, 0, 0, 0);
                    int lastDayTimeInt = timeStructSub.time;

                    json currentBuild = allBuildDataFromjenkins.builds[loop2];
                    var timestampOfBuild,_ =(int)currentBuild.timestamp;

                    string buildResult;

                    if(currentBuild.result != null){

                        buildResult   ,_ = (string)currentBuild.result;
                        if(timestampOfBuild <= currentTimeInt && timestampOfBuild >= lastDayTimeInt && (buildResult != "ABORTED")){

                            relatedBuildCountPerComponent = relatedBuildCountPerComponent + 1;
                            SUCCESS_COUNT = SUCCESS_COUNT + 1;

                            json buildDetails = {
                                                    "buildNumber":0,
                                                    "product":"none",
                                                    "component":"none",
                                                    "result":"none",
                                                    "duration":0,
                                                    "committedBy":"none",
                                                    "PRmergedGitID":"none",
                                                    "PRmergedName":"none",
                                                    "commitUrl":"none",
                                                    "repoOwner":"none",
                                                    "repoName":"none",
                                                    "timestamp":0,
                                                    "jobUrl":"none",
                                                    "culprits":"none",
                                                    "buildStatus":1,
                                                    "failureReason":"UNKNOWN"
                                                };

                            buildDetails.buildNumber = currentBuild.number;
                            buildDetails.product = areaName;
                            buildDetails.component = component;
                            buildDetails.result = currentBuild.result;
                            buildDetails.duration = currentBuild.duration;
                            buildDetails.timestamp = currentBuild.timestamp;
                            buildDetails.jobUrl = currentBuild.url;

                            if(buildResult == "FAILURE" || buildResult == "UNSTABLE"){

                                //getting the reason for that build happen
                                string buildCause;

                                SUCCESS_COUNT = SUCCESS_COUNT - 1;
                                FAILURE_COUNT = FAILURE_COUNT + 1;

                                buildDetails.buildStatus = 0;

                                int actionKeyLength = lengthof currentBuild.actions;
                                string commitSHA1;
                                string repoOwner;
                                string repoName;


                                int loop3 = 0;
                                while(loop3 < actionKeyLength){
                                    string[] keySet = jsons:getKeys(currentBuild.actions[loop3]);
                                    int lengthOfKeySet = lengthof keySet;

                                    if(lengthOfKeySet > 0){
                                        int loop4 = 0;
                                        while(loop4<lengthOfKeySet){
                                            if(keySet[loop4] == "causes"){
                                                buildCause,_ = (string)currentBuild.actions[loop3].causes[0].shortDescription;
                                            }

                                            if(keySet[loop4] == "lastBuiltRevision"){
                                                commitSHA1,_ =(string)currentBuild.actions[loop3].lastBuiltRevision.SHA1;
                                            }

                                            if(keySet[loop4] == "remoteUrls"){
                                                var temp,_ = (string)currentBuild.actions[loop3].remoteUrls[0];
                                                string[] temp1 = strings:split(temp, "/");
                                                var repoOwnerString,_ = (string)temp1[3];
                                                repoOwner = repoOwnerString;
                                                string[] temp2 = strings:split(temp1[4], ".git");
                                                var repoNameString,_ = (string)temp2[0];
                                                repoName = repoNameString;
                                            }


                                            loop4 = loop4 + 1;
                                        }
                                    }

                                    buildDetails.repoOwner = repoOwner;
                                    buildDetails.repoName = repoName;

                                    loop3 = loop3 + 1;
                                }


                                //check if current build is occure due to commit of a developer commit or not
                                //Started by timer means this build is cause due to automation not developer commit
                                //If it is not a developer commit no need to get details from GITHUB

                                if(buildCause != "Started by timer"){
                                    //get commit and PR details from GitHub
                                    if (GITHUB_Connector == null) {
                                        setGithubConnector();
                                    }

                                    json gitCommitDetails;
                                    var GITHUB_ACCESS_TOKEN, _ = (string)configs.GITHUB.ACCESS_TOKEN;

                                    try {
                                        message request = {};
                                        message response = {};
                                        messages:setHeader(request, "Authorization", GITHUB_ACCESS_TOKEN);

                                        response = GITHUB_Connector.get("/repos/"+repoOwner+"/"+repoName+"/commits/"+commitSHA1, request);
                                        int statusCode = http:getStatusCode(response);

                                        if (statusCode == 200) {
                                            logger:info("RECEIVED " + repoName + " COMMIT DATA FROM GITHUB");
                                            json gitCommitRecords = messages:getJsonPayload(response);
                                            gitCommitDetails = gitCommitRecords;

                                        }else if (statusCode == 301){
                                            message newResponse = {};

                                            json getResponseJson = messages:getJsonPayload(response);
                                            var redirectUrl,_ = (string)getResponseJson.url;
                                            string[] pathArray = strings:split(redirectUrl,"https://api.github.com");
                                            var gitNewPath,_ = (string)pathArray[1];

                                            newResponse = GITHUB_Connector.get(gitNewPath, request);

                                            logger:info("RECEIVED " + repoName + " COMMIT DATA FROM GITHUB");

                                            json gitCommitRecords = messages:getJsonPayload(newResponse);
                                            gitCommitDetails = gitCommitRecords;

                                        } else {
                                            logger:info("ERROR IN RECEIVING " + repoName + " COMMIT DATA FROM GITHUB!!!!");
                                        }

                                    } catch (errors:Error err) {
                                        logger:error("GITHUB CONNECTION ERROR - " + err.msg);
                                    }

                                    buildDetails.PRmergedGitID = gitCommitDetails.author.login;
                                    buildDetails.PRmergedName = gitCommitDetails.commit.author.name;
                                    buildDetails.commitUrl = gitCommitDetails.html_url;

                                    //get commit person details
                                    if(gitCommitDetails.commit.verification.payload != null){
                                        try{
                                            var gitMessage,_ = (string)gitCommitDetails.commit.verification.payload;
                                            string[] splitTemp = strings:split(gitMessage, "from ");
                                            var halfSplitString,_ = (string)splitTemp[1];
                                            string[] splitTemp2 = strings:split(halfSplitString, "/");
                                            var commiterName,_ = (string)splitTemp2[0];

                                            buildDetails.committedBy = commiterName;
                                        }catch(errors:Error err) {
                                            buildDetails.committedBy = gitCommitDetails.commit.committer.name;
                                        }

                                    }else{
                                        buildDetails.committedBy = gitCommitDetails.commit.committer.name;
                                    }

                                }else{
                                    buildDetails.PRmergedGitID = "Started by timer";
                                    buildDetails.PRmergedName ="Started by timer";
                                    buildDetails.committedBy = "Started by timer";
                                }

                                //get culprits if exists
                                string culprits = "";
                                int lengthOfCulprits = lengthof currentBuild.culprits;
                                if(lengthOfCulprits > 0){
                                    int loop5 = 0;
                                    while(loop5 < lengthOfCulprits){
                                        var tempCulprits,_ = (string)currentBuild.culprits[loop5].fullName;
                                        culprits = culprits + tempCulprits + ",";

                                        loop5 = loop5 + 1;
                                    }

                                }

                                buildDetails.culprits = culprits;
                            }

                            jenkinsAndGitBuildData.events[globalIncrement] = buildDetails;
                            globalIncrement = globalIncrement + 1;
                        }
                    }

                    loop2 = loop2 + 1;

                }

                logger:info("TOTAL "+relatedBuildCountPerComponent+" BUILD(S) GOT FROM "+component);
                logger:info(SUCCESS_COUNT+"- SUCCESS AND "+FAILURE_COUNT+"- FAILURE BUILD(S) GOT FROM "+component);


                numberOfEvents = numberOfEvents + relatedBuildCountPerComponent;
            }
        }catch(errors:Error err){
            logger:info("ERROR IN GETTING DATA FROM - "+component);
        }

        loop = loop + 1;
    }

    time:Time currentTime = time:currentTime();
    int currentTimeInt = currentTime.time;
    globalCurrentTime = currentTimeInt;

    //adding dummy element to avoid losing data in stream processor memory
    json testDetails = {
                            "buildNumber":0,
                            "product":"test",
                            "component":"test",
                            "result":"SUCCESS",
                            "duration":0,
                            "committedBy":"none",
                            "PRmergedGitID":"none",
                            "PRmergedName":"none",
                            "commitUrl":"none",
                            "repoOwner":"none",
                            "repoName":"none",
                            "timestamp":globalCurrentTime,
                            "jobUrl":"none",
                            "culprits":"none",
                            "buildStatus":1,
                            "failureReason":"UNKNOWN"
                        };
    jenkinsAndGitBuildData.events[globalIncrement] = testDetails;

    logger:info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    logger:info("JENKINS GET BUILD DATA JOB FINISHED");
    logger:info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

    if (SIDDHI_Connector == null) {
        setSiddhiConnector();
    }

    logger:info(numberOfEvents+" EVENTS SENT TO THE SIDDHI PROCESSOR");

    int statusCodeFromSiddhi;
    try{
        message requestMain = {};
        message responseMain = {};
        messages:setJsonPayload(requestMain, jenkinsAndGitBuildData);

        responseMain = SIDDHI_Connector.post("/get-jenkins-data", requestMain);

        statusCodeFromSiddhi = http:getStatusCode(responseMain);

    }catch (errors:Error err) {
        logger:error("SIDDHI CONNECTION ERROR - " + err.msg);
    }
    //system:println(jenkinsAndGitBuildData);
    logger:info(statusCodeFromSiddhi+" RESPONSE! - DATA SENT TO SIDDHI HTTP CONNECTOR");

    //return "BUILD DATA SEND TO SIDDI HTTP CONNECTOR SUCCESSFULLY";

    system:println(jenkinsAndGitBuildData);
    return jenkinsAndGitBuildData;
}

function insertNewComponent(string productID, string component, string org){
    var productAreaId,_ = <int>productID;

    sql:ClientConnector dbConnection = setPQDDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter[] parameters2 = [];

    sql:Parameter pId = {sqlType:"integer", value:productAreaId};
    params = [pId];

    datatable resultOfProductID  = dbConnection.select(GET_PRODUCT_ID , params);
    var productIdJson, _ = <json>resultOfProductID;
    var productId,_ = (int)productIdJson[0].pqd_product_id;

    sql:Parameter areaId = {sqlType:"integer", value:productAreaId};
    sql:Parameter ComponentProductId = {sqlType:"integer", value:productId};
    sql:Parameter versionId = {sqlType:"integer", value:0};
    sql:Parameter componentName = {sqlType:"varchar", value:component};
    sql:Parameter organization = {sqlType:"varchar", value:org};
    parameters2 = [componentName,areaId,ComponentProductId,versionId,componentName,organization];

    int resultsOfInsertNewComponent = dbConnection.update(INSERT_COMPONENT_PRODUCT, parameters2);

    dbConnection.close();

    if(resultsOfInsertNewComponent == 1){
        logger:info("NEW COMPONENT-PRODUCT ADDED TO THE DATABASE");
    }else{
        logger:info("ERROR IN ADDING COMPONENT-PRODUCT TO THE DATABASE");
    }


}

function insertNewFolderComponentMapping(string component, string folder){

    sql:ClientConnector dbConnection = setPQDDatabaseConfiguration();
    sql:Parameter[] params = [];

    sql:Parameter folders = {sqlType:"varchar", value:folder};
    sql:Parameter components = {sqlType:"varchar", value:component};
    params = [components,folders];

    int resultsOfInsertNewComponent = dbConnection.update(INSERT_COMPONENT_FOLDER, params);

    dbConnection.close();

    if(resultsOfInsertNewComponent == 1){
        logger:info("NEW COMPONENT-FOLDER ADDED TO THE DATABASE");
    }else{
        logger:info("ERROR IN ADDING COMPONENT-PRODUCT TO THE DATABASE");
    }
}

function loadJenkinsBuildDataDashboard(string start, string end)(json){
    //SQL connector initialized
    sql:ClientConnector dbConnection = setPQDDatabaseConfiguration();
    sql:Parameter[] params = [];

    datatable resultsOfAllProducts = dbConnection.select(GET_ALL_PRODUCTS_JENKINS, params);
    var resultOfProducts, _ = <json>resultsOfAllProducts;

    json jsonResOfAllProducts = resultOfProducts;
    json dateRangeArray = getDateRangeAsArray(start,end);
    logger:debug(jsonResOfAllProducts);

    int lengthOfDateArray = lengthof dateRangeArray;
    datatables:close(resultsOfAllProducts);
    dbConnection.close();

    if (SIDDHI_REST_Connector == null) {
        setSiddhiRESTConnector();
    }

    json resultsFromSiddhiAggregation = [];
    if(lengthOfDateArray == 1){
        logger:info("FETCHING DATA FROM SIDDHI REST API");

        try{
            message request = {};
            message response = {};

            var startDate,_ = (string)dateRangeArray[0][0];
            var endDate,_ = (string)dateRangeArray[0][1];

            json payload = {
                               "appName" : "getJenkinsDataFromBallerina",
                               "query" : "from buildDataAggregation within '"+startDate+" 00:00:00 +05:30', '"+endDate+" 23:59:59 +05:30' per 'days' select sum,component,count having component !='test'"
                           };


            messages:setJsonPayload(request, payload);
            messages:addHeader(request, "Authorization", "Basic YWRtaW46YWRtaW4=");
            messages:addHeader(request, "Content-Type", "application/json");

            response = SIDDHI_REST_Connector.post("/query", request);

            int statusCodeFromSiddhiRest = http:getStatusCode(response);

            if(statusCodeFromSiddhiRest == 200){
                resultsFromSiddhiAggregation[0] = messages:getJsonPayload(response);
                logger:info("FETCHED DATA FROM SIDDHI REST API");
            }else{
                logger:error("SIDDHI REST CONNECTION ERROR");
            }

        }catch (errors:Error err) {
            logger:error("SIDDHI REST CONNECTION ERROR - " + err.msg);
        }
    }else{
        //if there is more than 1 length it means there are three elements in the array
        //first element need to query with days, second element need to query with months nad last elment need to query with days
        try{
            message request1 = {};
            message response1 = {};

            var startDate1,_ = (string)dateRangeArray[0][0];
            var endDate1,_ = (string)dateRangeArray[0][1];

            json payload1 = {
                               "appName" : "getJenkinsDataFromBallerina",
                               "query" : "from buildDataAggregation within '"+startDate1+" 00:00:00 +05:30', '"+endDate1+" 23:59:59 +05:30' per 'days' select sum,component,count having component !='test'"
                           };

            messages:setJsonPayload(request1, payload1);
            messages:addHeader(request1, "Authorization", "Basic YWRtaW46YWRtaW4=");
            messages:addHeader(request1, "Content-Type", "application/json");
            response1 = SIDDHI_REST_Connector.post("/query", request1);
            int statusCodeFromSiddhiRest1 = http:getStatusCode(response1);

            if(statusCodeFromSiddhiRest1 == 200){
                resultsFromSiddhiAggregation[0] = messages:getJsonPayload(response1);
                logger:info("FETCHED DATA SET 1 FROM SIDDHI REST API");
            }else{
                logger:error("SIDDHI REST CONNECTION ERROR");
            }

        }catch (errors:Error err) {
            logger:error("SIDDHI REST CONNECTION ERROR - " + err.msg);
        }


        // months data set
        try{
            message request2 = {};
            message response2 = {};

            var startDate2,_ = (string)dateRangeArray[1][0];
            var endDate2,_ = (string)dateRangeArray[1][1];

            json payload2 = {
                               "appName" : "getJenkinsDataFromBallerina",
                               "query" : "from buildDataAggregation within '"+startDate2+" 00:00:00 +05:30', '"+endDate2+" 23:59:59 +05:30' per 'months' select sum,component,count having component !='test'"
                           };

            messages:setJsonPayload(request2, payload2);
            messages:addHeader(request2, "Authorization", "Basic YWRtaW46YWRtaW4=");
            messages:addHeader(request2, "Content-Type", "application/json");
            response2 = SIDDHI_REST_Connector.post("/query", request2);
            int statusCodeFromSiddhiRest2 = http:getStatusCode(response2);

            if(statusCodeFromSiddhiRest2 == 200){
                resultsFromSiddhiAggregation[1] = messages:getJsonPayload(response2);
                logger:info("FETCHED DATA SET TWO FROM SIDDHI REST API");
            }else{
                logger:error("SIDDHI REST CONNECTION ERROR");
            }

        }catch (errors:Error err) {
            logger:error("SIDDHI REST CONNECTION ERROR - " + err.msg);
        }


        //day data set

        try{
            message request3 = {};
            message response3 = {};

            var startDate3,_ = (string)dateRangeArray[2][0];
            var endDate3,_ = (string)dateRangeArray[2][1];

            json payload3 = {
                                "appName" : "getJenkinsDataFromBallerina",
                                "query" : "from buildDataAggregation within '"+startDate3+" 00:00:00 +05:30', '"+endDate3+" 23:59:59 +05:30' per 'days' select sum,component,count having component !='test'"
                            };

            messages:setJsonPayload(request3, payload3);
            messages:addHeader(request3, "Authorization", "Basic YWRtaW46YWRtaW4=");
            messages:addHeader(request3, "Content-Type", "application/json");
            response3 = SIDDHI_REST_Connector.post("/query", request3);
            int statusCodeFromSiddhiRest3 = http:getStatusCode(response3);

            if(statusCodeFromSiddhiRest3 == 200){
                resultsFromSiddhiAggregation[2] = messages:getJsonPayload(response3);
                logger:info("FETCHED DATA SET THREE FROM SIDDHI REST API");
            }else{
                logger:error("SIDDHI REST CONNECTION ERROR");
            }

        }catch (errors:Error err) {
            logger:error("SIDDHI REST CONNECTION ERROR - " + err.msg);
        }

    }

    //create JSON for all the area including total,success and failure build counts
    json buildStats = [];
    json componentWiseBuildData = [];
    int[] nextComponentIndex = [];
    int lengthOfAreas = lengthof jsonResOfAllProducts;
    int loop = 0;
    while(loop < lengthOfAreas){
        json product = {
                           "productArea":jsonResOfAllProducts[loop].product,
                           "totalBuilds":0,
                           "successBuilds":0,
                           "failureBuilds":0,
                           "stability":"NA",
                           "successRate":"N/A",
                           "failureRate":"N/A"
                       };
        buildStats[loop] = product;

        json components = {
                              "productArea":jsonResOfAllProducts[loop].product,
                              "components":[]
                          };

        componentWiseBuildData[loop] = components;
        nextComponentIndex[loop] = 0;

        loop = loop + 1;
    }

    int lengthOfSiddhiResponse = lengthof resultsFromSiddhiAggregation;
    int increment = 0;

    while(increment < lengthOfSiddhiResponse){
        int innerLoop = 0;
        int lenOfResult = lengthof resultsFromSiddhiAggregation[increment].records;
        while(innerLoop < lenOfResult){
            var component,_ = (string)resultsFromSiddhiAggregation[increment].records[innerLoop][1];
            string productArea = getProductAreaForComponent(component);

            if(productArea == "Other"){
                innerLoop = innerLoop + 1;
                continue;
            }

            var totalBuild,_ = (int)resultsFromSiddhiAggregation[increment].records[innerLoop][2];
            var successBuild,_ = (int)resultsFromSiddhiAggregation[increment].records[innerLoop][0];
            int failureBuild = totalBuild - successBuild;

            //get index of received product area
            int index = 0;
            while(index < lengthOfAreas){
                var loopArea,_ = (string)buildStats[index].productArea;

                if(loopArea==productArea){
                    break;
                }
                index = index + 1;
            }

            var sBuild,_ = (int)buildStats[index].successBuilds;
            buildStats[index].successBuilds = sBuild + successBuild;
            var fBuild,_ = (int)buildStats[index].failureBuilds;
            buildStats[index].failureBuilds = fBuild + failureBuild;
            var tBuild,_ = (int)buildStats[index].totalBuilds;
            buildStats[index].totalBuilds = tBuild + totalBuild;


            //adding data to componentWiseBuildData JSON
            json details = {
                               "componentName":"unknown",
                               "totalBuilds":0,
                               "successBuilds":0,
                               "failureBuilds":0
                           };
            details.totalBuilds = totalBuild;
            details.successBuilds = successBuild;
            details.failureBuilds = failureBuild;
            details.componentName = component;

            int currentIndex = nextComponentIndex[index];
            componentWiseBuildData[index].components[currentIndex] = details;
            nextComponentIndex[index] = nextComponentIndex[index] + 1;

            innerLoop = innerLoop + 1;
        }

        increment = increment + 1;
    }

    loop = 0;
    while(loop < lengthOfAreas){
        var sCount1,_ = (int)buildStats[loop].successBuilds;
        var tCount1,_ = (int)buildStats[loop].totalBuilds;
        var fCount1,_ = (int)buildStats[loop].failureBuilds;

        string sCountFloat = sCount1+".0";
        string tCountFloat = tCount1+".0";
        string fCountFloat = fCount1+".0";

        var sCount,_ = <float>sCountFloat;
        var tCount,_ = <float>tCountFloat;
        var fCount,_ = <float>fCountFloat;

        if(tCount != 0){
            float successRateComponent = sCount/tCount*100;
            float failureRateComponent = fCount/tCount*100;

            buildStats[loop].successRate = successRateComponent;
            buildStats[loop].failureRate = failureRateComponent;

            if(failureRateComponent == 0){
                buildStats[loop].stability = "Sunny";
            }else if(failureRateComponent> 0 && failureRateComponent<40){
                buildStats[loop].stability = "PartlyCloudy";
            }else if(failureRateComponent>=40 && failureRateComponent<60){
                buildStats[loop].stability = "Cloudy";
            }else if(failureRateComponent>=60 && failureRateComponent<80){
                buildStats[loop].stability = "Rainy";
            }else if(failureRateComponent>=80 && failureRateComponent<=100){
                buildStats[loop].stability = "Stormy";
            }
        }

        loop = loop + 1;
    }


    time:Time startDate = time:parse(start + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    time:Time endDate = time:parse(end + "T23:59:59.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    sql:ClientConnector localConnection = setPQDDatabaseConfiguration();
    sql:Parameter[] paramsOfContributors = [];
    sql:Parameter startDates = {sqlType:"varchar", value:startDate.time};
    sql:Parameter endDates = {sqlType:"varchar", value:endDate.time};

    paramsOfContributors = [startDates,endDates];

    datatable resultsOfContributors = localConnection.select(GET_ALL_FAILURE_CONTRIBUTORS, paramsOfContributors);
    var failureContributors, _ = <json>resultsOfContributors;

    loop = 0;
    while(loop < lengthof failureContributors){
        string[] contributorName = [];
        int[] contributorCount = [];
        int cursor = 0;
        var mergedBy,_ = (string) failureContributors[loop].PRmergedBy;
        string[] currentList = strings:split(mergedBy, ",");

        int innerLoop = 0;
        while(innerLoop < lengthof currentList){

            if(innerLoop != 0){
                string flag = "false";

                int loop3 = 0;
                while(loop3 < lengthof contributorName){
                    if(currentList[innerLoop] == contributorName[loop3]){
                        contributorCount[loop3] = contributorCount[loop3] + 1;
                        flag = "true";
                        break;
                    }
                    loop3 = loop3 + 1;
                }

                if(flag == "false"){
                    contributorName[cursor] = currentList[innerLoop];
                    contributorCount[cursor] = 1;
                    cursor = cursor + 1;
                }
            }else{
                contributorName[cursor] = currentList[innerLoop];
                contributorCount[cursor] = 1;
                cursor = cursor + 1;
            }

            innerLoop = innerLoop + 1;
        }

        innerLoop = 0;
        string finalStringOfMergedPeople = "";
        while(innerLoop < lengthof contributorName){
            if(contributorCount[innerLoop] != 1){
                finalStringOfMergedPeople = finalStringOfMergedPeople + contributorName[innerLoop]+"("+contributorCount[innerLoop]+"),";
            }else{
                finalStringOfMergedPeople = finalStringOfMergedPeople + contributorName[innerLoop]+",";
            }

            innerLoop = innerLoop + 1;
        }

        int length = strings:length(finalStringOfMergedPeople);
        finalStringOfMergedPeople = strings:subString(finalStringOfMergedPeople, 0, length-1);
        failureContributors[loop].PRmergedBy = finalStringOfMergedPeople;

        loop = loop + 1;
    }


    //load failure Reasons for the pie chart in the dashboard
    sql:Parameter[] paramsOfReasons = [];
    paramsOfReasons = [startDates,endDates];

    datatable resultsOfReasons = localConnection.select(GET_ALL_FAILURE_REASONS, paramsOfReasons);
    var failureReasons, _ = <json>resultsOfReasons;

    datatable resultsOfReasonsDrillDown = localConnection.select(GET_ALL_FAILURE_REASONS_DRILLDOWN, paramsOfReasons);
    var failureReasonsDrillDown, _ = <json>resultsOfReasonsDrillDown;


    json failureReasonsJSON = [];
    json failureReasonsDrillDownJSON = [];
    loop = 0;
    while(loop < lengthof failureReasons){
        json temp = {"name":"x","y":0,"drilldown":"c"};
        temp.name = failureReasons[loop].failureReason;
        temp.y = failureReasons[loop].count;
        temp.drilldown = failureReasons[loop].failureReason;
        failureReasonsJSON[loop] = temp;
        loop = loop + 1;
    }

    loop = 0;
    json dataJSON = [];
    while(loop < lengthof failureReasons){
        int loop2 = 0;
        increment = 0;
        json dump = [];
        while(loop2 < lengthof failureReasonsDrillDown){
            var reasonOne,_ = (string)failureReasons[loop].failureReason;
            var reasonTwo,_ = (string)failureReasonsDrillDown[loop2].failureReason;

            if(reasonOne == reasonTwo){
                json temp3 =[];
                temp3[0] = failureReasonsDrillDown[loop2].product;
                temp3[1] = failureReasonsDrillDown[loop2].count;
                dump[increment] = temp3;
                increment = increment + 1;
            }

            loop2 = loop2 + 1;
        }
        dataJSON[loop] = dump;
        loop = loop +1;
    }


    loop = 0;
    while(loop < lengthof failureReasons){
        json temp2 = {"name":"x","id":0,"data":"c"};
        temp2.name = failureReasons[loop].failureReason;
        temp2.id = failureReasons[loop].failureReason;
        temp2.data = dataJSON[loop];
        failureReasonsDrillDownJSON[loop] = temp2;
        loop = loop + 1;
    }

    system:println(failureReasonsJSON);
    json finalData = {
                         "buildData":buildStats,
                         "componentWiseBuildData":componentWiseBuildData,
                         "failureContributors":failureContributors,
                         "failureReasons":failureReasonsJSON,
                         "failureReasonsDrilldown":failureReasonsDrillDownJSON
                     };

    //close datatables and SQL connector
    datatables:close(resultsOfContributors);
    localConnection.close();

    logger:info("JENKINS BUILD DATA SENT SUCCESSFULLY");

    return finalData;
}

function getDateRangeAsArray(string start, string end)(json){
    //check date duration of request
    time:Time startDate = time:parse(start + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    time:Time endDate = time:parse(end + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    int dayCount = (endDate.time - startDate.time) / MILI_SECONDS_PER_DAY_JENKINS;

    json dayRanges = [];
    string[] startDateSplit = strings:split(start, "-");
    var yearOfStartDate,_ =<int>startDateSplit[0];
    var monthOfStartDate,_ = <int>startDateSplit[1];
    var dayOfStartDate,_ = <int>startDateSplit[2];

    string[] endDateSplit = strings:split(end, "-");
    var yearOfEndDate,_ = <int>endDateSplit[0];
    var monthOfEndDate,_ = <int>endDateSplit[1];
    var dayOfEndDate,_ = <int>endDateSplit[2];

    if(dayCount > 365){
        //fetch data as 'years', 'months' and 'days'
        int monthDifference = monthOfEndDate - monthOfStartDate;
        int yearDifference = yearOfEndDate - yearOfStartDate;

        if(monthDifference <= 0){
            monthDifference = monthDifference +12 + yearDifference*12;
        }else{
            monthDifference = monthDifference + yearDifference*12;
        }

        int loop = 0;
        int increment = 0;
        string bool = "False";

        int[] middleMonths = [];
        int lastDay = lastDateOfMonth[monthOfStartDate - 1];
        while(loop < monthDifference +1){

            if(lastDay == 28){
                if(yearOfStartDate % 4 == 0){
                    lastDay = 29;
                }
            }

            if(bool == "False"){
                string dayStart;
                string dayEnds;

                if(monthOfStartDate < 10){
                    if(dayOfStartDate < 10){
                        dayStart = yearOfStartDate+"-0"+monthOfStartDate+"-0"+dayOfStartDate;
                        dayEnds = yearOfStartDate+"-0"+monthOfStartDate+"-"+lastDay;
                    }else{
                        dayStart = yearOfStartDate+"-0"+monthOfStartDate+"-"+dayOfStartDate;
                        dayEnds = yearOfStartDate+"-0"+monthOfStartDate+"-"+lastDay;
                    }

                }else{
                    if(dayOfStartDate < 10){
                        dayStart = yearOfStartDate+"-"+monthOfStartDate+"-0"+dayOfStartDate;
                        dayEnds = yearOfStartDate+"-"+monthOfStartDate+"-"+lastDay;
                    }else{
                        dayStart = yearOfStartDate+"-"+monthOfStartDate+"-"+dayOfStartDate;
                        dayEnds = yearOfStartDate+"-"+monthOfStartDate+"-"+lastDay;
                    }
                }

                bool = "True";

                json temp = [dayStart,dayEnds];
                dayRanges[increment] = temp;
                increment = increment +1;

            }else if(loop == monthDifference){
                int length = lengthof middleMonths;
                string dayStart;
                string dayEnds;

                if(middleMonths[0]>12){
                    if(middleMonths[0]-12 < 10){
                        dayStart = (yearOfStartDate+1)+"-0"+(middleMonths[0]-12)+"-01";
                    }else{
                        dayStart = (yearOfStartDate+1)+"-"+(middleMonths[0]-12)+"-01";
                    }

                }else{
                    if(middleMonths[0] < 10){
                        dayStart = yearOfStartDate+"-0"+middleMonths[0]+"-01";
                    }else{
                        dayStart = yearOfStartDate+"-"+middleMonths[0]+"-01";
                    }

                }

                int n = middleMonths[length -1]/12;

                if(middleMonths[length -1] > 12){
                    int temp;
                    int temp2;
                    if((middleMonths[length-1]-12*n) == 0){
                        temp = 12;
                        temp2 = yearDifference -1;
                    }else{
                        temp = (middleMonths[length-1]-12*n);
                        temp2 = yearDifference;
                    }

                    int lastDate = lastDateOfMonth[temp -1];
                    if(lastDate == 28){
                        if(yearOfStartDate % 4 == 0){
                            lastDate = 29;
                        }
                    }

                    if(temp < 10){
                        dayEnds = (yearOfStartDate+temp2)+"-0"+temp+"-"+lastDate;
                    }else{
                        dayEnds = (yearOfStartDate+temp2)+"-"+temp+"-"+lastDate;
                    }

                }else{
                    int lastDate = lastDateOfMonth[(middleMonths[length-1]) -1];
                    if(lastDate == 28){
                        if(yearOfStartDate % 4 == 0){
                            lastDate = 29;
                        }
                    }

                    if(middleMonths[length-1] < 10){
                        dayEnds = yearOfStartDate+"-0"+middleMonths[length-1]+"-"+lastDate;
                    }else{
                        dayEnds = yearOfStartDate+"-"+middleMonths[length-1]+"-"+lastDate;
                    }

                }

                json temp = [dayStart,dayEnds];
                dayRanges[increment] = temp;
                increment = increment +1 ;

                string lastDayStart;
                string lastDayEnds;

                if(monthOfStartDate>12*n){
                    if(monthOfStartDate-12*n < 10){
                        lastDayStart = (yearOfStartDate+yearDifference)+"-0"+(monthOfStartDate-12*n)+"-01";
                        if(dayOfEndDate < 10){
                            lastDayEnds = (yearOfStartDate+yearDifference)+"-0"+(monthOfStartDate-12*n)+"-0"+dayOfEndDate;
                        }else{
                            lastDayEnds = (yearOfStartDate+yearDifference)+"-0"+(monthOfStartDate-12*n)+"-"+dayOfEndDate;
                        }
                    }else{
                        lastDayStart = (yearOfStartDate+yearDifference)+"-"+(monthOfStartDate-12*n)+"-01";
                        if(dayOfEndDate < 10){
                            lastDayEnds = (yearOfStartDate+yearDifference)+"-"+(monthOfStartDate-12*n)+"-0"+dayOfEndDate;
                        }else{
                            lastDayEnds = (yearOfStartDate+yearDifference)+"-"+(monthOfStartDate-12*n)+"-"+dayOfEndDate;
                        }
                    }

                }else{
                    if(monthOfStartDate < 10){
                        lastDayStart = yearOfStartDate+"-0"+monthOfStartDate+"-01";
                        if(dayOfEndDate < 10){
                            lastDayEnds = yearOfStartDate+"-0"+monthOfStartDate+"-0"+dayOfEndDate;
                        }else{
                            lastDayEnds = yearOfStartDate+"-0"+monthOfStartDate+"-"+dayOfEndDate;
                        }
                    }else{
                        lastDayStart = yearOfStartDate+"-"+monthOfStartDate+"-01";
                        if(dayOfEndDate < 10){
                            lastDayEnds = yearOfStartDate+"-"+monthOfStartDate+"-0"+dayOfEndDate;
                        }else{
                            lastDayEnds = yearOfStartDate+"-"+monthOfStartDate+"-0"+dayOfEndDate;
                        }
                    }
                }

                temp = [lastDayStart,lastDayEnds];
                dayRanges[increment] = temp;
                increment = increment +1 ;

            }else{
                middleMonths[loop-1] = monthOfStartDate;
            }

            monthOfStartDate = monthOfStartDate + 1;
            loop = loop + 1;
        }

    }else if(dayCount > 30){
        //fetch data as 'months' and 'days'

        if(yearOfStartDate == yearOfEndDate){
            int monthDifference = monthOfEndDate - monthOfStartDate;
            int loop = 0;
            int increment = 0;
            string bool = "False";

            int[] middleMonths = [];
            while(loop < monthDifference+1){
                int lastDay = lastDateOfMonth[monthOfStartDate - 1];

                if(lastDay == 28){
                    if(yearOfStartDate % 4 == 0){
                        lastDay = 29;
                    }
                }

                if(bool == "False"){
                    string dayStart;
                    string dayEnds;

                    if(monthOfStartDate < 10){
                        if(dayOfStartDate < 10){
                            dayStart = yearOfStartDate+"-0"+monthOfStartDate+"-0"+dayOfStartDate;
                        }else{
                            dayStart = yearOfStartDate+"-0"+monthOfStartDate+"-"+dayOfStartDate;
                        }
                        dayEnds = yearOfStartDate+"-0"+monthOfStartDate+"-"+lastDay;
                    }else{
                        if(dayOfStartDate < 10){
                            dayStart = yearOfStartDate+"-"+monthOfStartDate+"-0"+dayOfStartDate;
                        }else{
                            dayStart = yearOfStartDate+"-"+monthOfStartDate+"-"+dayOfStartDate;
                        }
                        dayEnds = yearOfStartDate+"-"+monthOfStartDate+"-"+lastDay;
                    }

                    bool = "True";

                    json temp = [dayStart,dayEnds];
                    dayRanges[increment] = temp;
                    increment = increment +1;

                }else if(loop == monthDifference){
                    int length = lengthof middleMonths;
                    string dayStart;
                    string dayEnds;

                    if(middleMonths[0] < 10){
                        dayStart = yearOfStartDate+"-0"+middleMonths[0]+"-01";
                    }else{
                        dayStart = yearOfStartDate+"-"+middleMonths[0]+"-01";
                    }

                    int lastDate = lastDateOfMonth[middleMonths[length-1] -1];
                    if(lastDate == 28){
                        if(yearOfStartDate % 4 == 0){
                            lastDate = 29;
                        }
                    }

                    if(middleMonths[length-1] < 10){
                        dayEnds = yearOfStartDate+"-0"+middleMonths[length-1]+"-"+lastDate;
                    }else{
                        dayEnds = yearOfStartDate+"-"+middleMonths[length-1]+"-"+lastDate;
                    }

                    json temp = [dayStart,dayEnds];
                    dayRanges[increment] = temp;
                    increment = increment +1 ;

                    string lastDayStart;
                    string lastDayEnds;

                    if(monthOfStartDate < 10){
                        lastDayStart = yearOfStartDate+"-0"+monthOfStartDate+"-01";
                        if(dayOfEndDate < 10){
                            lastDayEnds = yearOfStartDate+"-0"+monthOfStartDate+"-0"+dayOfEndDate;
                        }else{
                            lastDayEnds = yearOfStartDate+"-0"+monthOfStartDate+"-"+dayOfEndDate;
                        }
                    }else{
                        lastDayStart = yearOfStartDate+"-"+monthOfStartDate+"-01";
                        if(dayOfEndDate < 10){
                            lastDayEnds = yearOfStartDate+"-"+monthOfStartDate+"-0"+dayOfEndDate;
                        }else{
                            lastDayEnds = yearOfStartDate+"-"+monthOfStartDate+"-"+dayOfEndDate;
                        }
                    }

                    temp = [lastDayStart,lastDayEnds];
                    dayRanges[increment] = temp;
                    increment = increment +1 ;

                }else{
                    middleMonths[loop-1] = monthOfStartDate;
                }

                monthOfStartDate = monthOfStartDate + 1;
                loop = loop + 1;
            }

        }else{
            int monthDifference = monthOfEndDate - monthOfStartDate;

            if(monthDifference <= 0){
                monthDifference = monthDifference +12;
            }
            int loop = 0;
            int increment = 0;
            string bool = "False";

            int[] middleMonths = [];
            int lastDay = lastDateOfMonth[monthOfStartDate - 1];
            while(loop < monthDifference +1){

                if(lastDay == 28){
                    if(yearOfStartDate % 4 == 0){
                        lastDay = 29;
                    }
                }

                if(bool == "False"){
                    string dayStart;

                    if(dayOfStartDate < 10){
                        if(monthOfStartDate < 10){
                            dayStart = yearOfStartDate+"-0"+monthOfStartDate+"-0"+dayOfStartDate;
                        }else{
                            dayStart = yearOfStartDate+"-"+monthOfStartDate+"-0"+dayOfStartDate;
                        }
                    }else{
                        if(monthOfStartDate < 10){
                            dayStart = yearOfStartDate+"-0"+monthOfStartDate+"-"+dayOfStartDate;
                        }else{
                            dayStart = yearOfStartDate+"-"+monthOfStartDate+"-"+dayOfStartDate;
                        }
                    }
                    string dayEnds = yearOfStartDate+"-"+monthOfStartDate+"-"+lastDay;
                    bool = "True";

                    json temp = [dayStart,dayEnds];
                    dayRanges[increment] = temp;
                    increment = increment +1;

                }else if(loop == monthDifference){
                    int length = lengthof middleMonths;
                    string dayStart;
                    string dayEnds;

                    if(middleMonths[0]>12){
                        if((middleMonths[0]-12) < 10){
                            dayStart = (yearOfStartDate+1)+"-0"+(middleMonths[0]-12)+"-01";
                        }else{
                            dayStart = (yearOfStartDate+1)+"-"+(middleMonths[0]-12)+"-01";
                        }

                    }else{
                        if(middleMonths[0] < 10){
                            dayStart = yearOfStartDate+"-0"+middleMonths[0]+"-01";
                        }else{
                            dayStart = yearOfStartDate+"-"+middleMonths[0]+"-01";
                        }

                    }

                    if(middleMonths[length -1] > 12){
                        int lastDate = lastDateOfMonth[(middleMonths[length-1]-12) -1];
                        if(lastDate == 28){
                            if(yearOfStartDate % 4 == 0){
                                lastDate = 29;
                            }
                        }

                        if((middleMonths[length-1]-12) < 10){
                            dayEnds = (yearOfStartDate+1)+"-0"+(middleMonths[length-1]-12)+"-"+lastDate;
                        }else{
                            dayEnds = (yearOfStartDate+1)+"-"+(middleMonths[length-1]-12)+"-"+lastDate;
                        }

                    }else{
                        int lastDate = lastDateOfMonth[(middleMonths[length-1]) -1];
                        if(lastDate == 28){
                            if(yearOfStartDate % 4 == 0){
                                lastDate = 29;
                            }
                        }

                        if(middleMonths[length-1] < 10){
                            dayEnds = yearOfStartDate+"-0"+middleMonths[length-1]+"-"+lastDate;
                        }else{
                            dayEnds = yearOfStartDate+"-"+middleMonths[length-1]+"-"+lastDate;
                        }
                    }

                    json temp = [dayStart,dayEnds];
                    dayRanges[increment] = temp;
                    increment = increment +1 ;

                    string lastDayStart;
                    string lastDayEnds;

                    if(monthOfStartDate>12){
                        if((monthOfStartDate-12) < 10){
                            lastDayStart = (yearOfStartDate+1)+"-0"+(monthOfStartDate-12)+"-01";
                            lastDayEnds = (yearOfStartDate+1)+"-0"+(monthOfStartDate-12)+"-"+dayOfEndDate;
                        }else{
                            lastDayStart = (yearOfStartDate+1)+"-"+(monthOfStartDate-12)+"-01";
                            lastDayEnds = (yearOfStartDate+1)+"-"+(monthOfStartDate-12)+"-"+dayOfEndDate;
                        }

                    }else{
                        if(monthOfStartDate < 10){
                            lastDayStart = yearOfStartDate+"-0"+monthOfStartDate+"-01";
                            lastDayEnds = yearOfStartDate+"-0"+monthOfStartDate+"-"+dayOfEndDate;
                        }else{
                            lastDayStart = yearOfStartDate+"-"+monthOfStartDate+"-01";
                            lastDayEnds = yearOfStartDate+"-"+monthOfStartDate+"-"+dayOfEndDate;
                        }
                    }

                    temp = [lastDayStart,lastDayEnds];
                    dayRanges[increment] = temp;
                    increment = increment +1 ;

                }else{
                    middleMonths[loop-1] = monthOfStartDate;
                }

                monthOfStartDate = monthOfStartDate + 1;
                loop = loop + 1;
            }
        }
    }else{
        //fetch data as 'days'
        dayRanges[0] = [start,end];
    }

    return dayRanges;
}

function getProductAreaForComponent(string component)(string){
    string area;

    if(allComponentAreaJson == null){
        sql:ClientConnector dbConnection = setPQDDatabaseConfiguration();
        sql:Parameter[] params = [];

        datatable resultsOfArea = dbConnection.select(GET_PRODUCT_AREA_COMPONENT, params);
        var jsonResOfArea, _ = <json>resultsOfArea;

        allComponentAreaJson = jsonResOfArea;

        int loop = 0;
        int length = lengthof jsonResOfArea;
        while(loop < length){
            var areaComponent,_ = (string)allComponentAreaJson[loop].component;
            if(component == areaComponent){
                area,_ = (string)allComponentAreaJson[loop].area;
                break;
            }

            loop = loop + 1;
        }

        dbConnection.close();

    }else{
        int loop = 0;
        int length = lengthof allComponentAreaJson;
        while(loop < length){
            var areaComponent,_ = (string)allComponentAreaJson[loop].component;
            if(component == areaComponent){
                area,_ = (string)allComponentAreaJson[loop].area;
                break;
            }

            loop = loop + 1;
        }
    }

    return area;
}

function loadDataForProductArea(string start, string end, string area)(json){
    sql:ClientConnector dbConnections = setPQDDatabaseConfiguration();
    sql:Parameter[] params = [];
    sql:Parameter areaName = {sqlType:"varchar", value:area};
    params = [areaName];

    datatable resultsOfArea = dbConnections.select(GET_SPECIFIC_PRODUCT_AREA_COMPONENT, params);
    var jsonResOfAreaComponent, _ = <json>resultsOfArea;
    int totalComponents = lengthof jsonResOfAreaComponent;

    //getting failure reasons
    time:Time startDate = time:parse(start + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    time:Time endDate = time:parse(end + "T23:59:59.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");

    sql:ClientConnector dbLocalConnections = setPQDDatabaseConfiguration();
    sql:Parameter[] failureParams = [];
    sql:Parameter startDates = {sqlType:"varchar", value:startDate.time};
    sql:Parameter endDates = {sqlType:"varchar", value:endDate.time};
    sql:Parameter productArea = {sqlType:"varchar", value:area};
    failureParams = [productArea,startDates,endDates];

    datatable resultsOfFailures = dbLocalConnections.select(GET_FAILURE_DETAILS, failureParams);
    var jsonResOfFailures, _ = <json>resultsOfFailures;

    datatable resultsOfFailuresReason = dbLocalConnections.select(GET_ALL_FAILURE_REASONS_FOR_PRODUCT, failureParams);
    var jsonResOfFailureReasons, _ = <json>resultsOfFailuresReason;

    json failureReasons = [];
    int loop = 0;
    while(loop < lengthof jsonResOfFailureReasons){
        json temp = {"name":"x","y":0};
        temp.name = jsonResOfFailureReasons[loop].failureReason;
        temp.y = jsonResOfFailureReasons[loop].count;
        failureReasons[loop] = temp;
        loop = loop + 1;
    }

    json specificArea = {
                            "allComponents":jsonResOfAreaComponent,
                            "total":totalComponents,
                            "failureDetails":jsonResOfFailures,
                            "failureReasons":failureReasons
                        };

    dbConnections.close();
    dbLocalConnections.close();

    return specificArea;
}

function loadDataOfCulpritsForComponent(string start, string end, string area, string component)(json){
    //getting failure reasons
    time:Time startDate = time:parse(start + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    time:Time endDate = time:parse(end + "T23:59:59.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");

    sql:ClientConnector dbLocalConnections = setPQDDatabaseConfiguration();
    sql:Parameter[] failureParams = [];
    sql:Parameter startDates = {sqlType:"varchar", value:startDate.time};
    sql:Parameter endDates = {sqlType:"varchar", value:endDate.time};
    sql:Parameter productArea = {sqlType:"varchar", value:area};

    json jsonResOfFailures = [];

    if(component == "all"){
        failureParams = [productArea,startDates,endDates];
        datatable resultsOfFailures = dbLocalConnections.select(GET_FAILURE_DETAILS, failureParams);
        jsonResOfFailures, _ = <json>resultsOfFailures;
    }else{
        sql:Parameter componentRequested = {sqlType:"varchar", value:component};
        failureParams = [productArea,componentRequested,startDates,endDates];
        datatable resultsOfFailures = dbLocalConnections.select(GET_FAILURE_DETAILS_FOR_COMPONENT, failureParams);
        jsonResOfFailures, _ = <json>resultsOfFailures;
    }
    logger:debug(jsonResOfFailures);
    dbLocalConnections.close();

    return jsonResOfFailures;
}

function updateFolderComponentMapping(string component, string folderBefore, string folderAfter){
    sql:ClientConnector dbConnection = setPQDDatabaseConfiguration();
    sql:Parameter[] params = [];
    sql:Parameter[] params2 = [];

    sql:Parameter foldersFirst = {sqlType:"varchar", value:folderBefore};
    sql:Parameter foldersNow = {sqlType:"varchar", value:folderAfter};
    sql:Parameter components = {sqlType:"varchar", value:component};
    params = [foldersNow,components,foldersFirst];

    datatable resultsOfAllProducts = dbConnection.select(SET_UPDATE_ZERO, params2);
    int resultsOfUpdateNewComponent = dbConnection.update(UPDATE_COMPONENT_FOLDER, params);

    dbConnection.close();

    if(resultsOfUpdateNewComponent == 1){
        logger:info("COMPONENT-FOLDER UPDATED IN THE DATABASE \n");
    }else{
        logger:info("ERROR IN UPDATING COMPONENT-PRODUCT IN THE DATABASE \n");
    }
}

