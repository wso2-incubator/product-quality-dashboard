package org.wso2.internalapps.pqd;

import ballerina.data.sql;
import ballerina.lang.messages;
import ballerina.lang.strings;
import ballerina.lang.time;
import ballerina.lang.errors;
import ballerina.lang.files;
import ballerina.lang.blobs;
import ballerina.lang.jsons;
import ballerina.net.http;
import ballerina.utils.logger;
import ballerina.lang.datatables;


function getConfigurationData (string FILE_PATH) (json) {

    files:File configFile = {path:FILE_PATH};

    try {
        files:open(configFile, "r");
        logger:debug("CONFIG.JSON READ SUCCESSFULLY");
    } catch (errors:Error err) {
        logger:debug("ERROR IN READ CONFIG.JSON - "+ err.msg);
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

function setDatabaseConfiguration()(sql:ClientConnector) {
    sql:ClientConnector dbConnection = null;

    try {
        json configs = getConfigurationData(CONFIGURATION_PATH);

        var dbHost, _ = (string)configs.PMT_JDBC.DB_HOST;
        var dbPort, _ = (int)configs.PMT_JDBC.DB_PORT;
        var dbName, _ = (string)configs.PMT_JDBC.DB_NAME;
        var dbUser, _ = (string)configs.PMT_JDBC.DB_USERNAME;
        var dbPassword, _ = (string)configs.PMT_JDBC.DB_PASSWORD;
        var dbPoolSize, _ = (int)configs.PMT_JDBC.MAXIMUM_POOL_SIZE;


        map props = {"jdbcUrl":"jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "", "username":dbUser, "password":dbPassword, "maximumPoolSize":dbPoolSize};
        dbConnection = create sql:ClientConnector(props);

        logger:info("MYSQL DB CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING MYSQL DB CONNECTOR - " + err.msg);
    }

    return dbConnection;
}

function setJIRAConnector () {

    try {
        json JIRAconfigs = getConfigurationData(CONFIGURATION_PATH);
        var JIRA_BASE_URL, _ = (string)JIRAconfigs.SUPPORT_JIRA.BASE_URL;

        JIRA_Connector = create http:ClientConnector(JIRA_BASE_URL);

        logger:info("JIRA CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING JIRA CONNECTOR - " + err.msg);
    }

}

function setHTTPConnector () {

    try {
        json complexityConfigs = getConfigurationData(CONFIGURATION_PATH);
        var BASE_URL, _ = (string)complexityConfigs.PATCH_COMPLEXITY.BASE_URL;
        http_Connector = create http:ClientConnector(BASE_URL);

        logger:info("HTTP CLIENT CONNECTOR INITIALIZED");

    } catch (errors:Error err) {
        logger:error("ERROR IN INITIALIZING HTTP CLIENT CONNECTOR - " + err.msg);
    }

}

function loadDashboardWithHistory (string start, string end) (json) {
    logger:info("PMT SERVICES STARTED");

    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    //SQL parameters
    sql:Parameter[] params = [];
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};

    //get all products
    params = [valueOfActiveIsYes, valueOfActiveIsNo];
    datatable resultsOfAllProducts = dbConnection.select(GET_ALL_PRODUCTS, params);
    var jsonResOfProducts, _ = <json>resultsOfAllProducts;

    //get all versions of each product
    params = [];
    datatable resultsOfAllProductsVersions = dbConnection.select(GET_ALL_VERSIONS, params);
    var jsonResOfVersions, _ = <json>resultsOfAllProductsVersions;

    json drillDownMenu = {"allProducts":jsonResOfProducts, "allVersions":jsonResOfVersions};

    //get reactive patch counts
    params = [valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
    datatable resultOfDatabaseReactivePatches = dbConnection.select(GET_REACTIVE_PATCH_COUNTS, params);
    var jsonResOfReactive, _ = <json>resultOfDatabaseReactivePatches;
    var reactiveCount, castErr = (int)jsonResOfReactive[0].total;

    //get proactive patch counts
    params = [valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
    datatable resultOfDatabaseProactivePatches = dbConnection.select(GET_PROACTIVE_PATCH_COUNTS, params);
    var jsonResOfProactive, _ = <json>resultOfDatabaseProactivePatches;
    var proactiveCount, _ = (int)jsonResOfProactive[0].total;

    //get security internal patches
    params = [valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
    datatable resultOfDatabaseSecurityInternalPatches = dbConnection.select(GET_SECURITY_INTERNAL_PATCHES, params);
    var jsonResOfSecurityInternal, _ = <json>resultOfDatabaseSecurityInternalPatches;

    string securityInternal_ID;
    string[] idPool = [];
    int[] idCounts = [];
    int[] verifyActualId = [];
    int securityLength = lengthof jsonResOfSecurityInternal;
    int loop = 0;
    int fetchPatchCount = 0;
    int statusCode;

    //get reactive and proactive patches
    while (loop < securityLength) {
        var supportUrl, _ = (string)jsonResOfSecurityInternal[loop].SUPPORT_JIRA;
        var supportUrlCount, _ = (int)jsonResOfSecurityInternal[loop].COUNT;
        string[] array = strings:split(supportUrl, "/");
        securityInternal_ID = securityInternal_ID + array[5] + ",";
        fetchPatchCount = fetchPatchCount + supportUrlCount;
        idPool[loop] = array[5];
        idCounts[loop] = supportUrlCount;
        verifyActualId[loop] = 0;
        loop = loop + 1;
    }

    int unCategorizedCount = 0;
    int securityStringLength = strings:length(securityInternal_ID);
    string finalSecurityIds;
    json jiraRecords;
    string bool = "True";

    if (securityStringLength > 0) {
        finalSecurityIds = strings:subString(securityInternal_ID, 0, securityStringLength - 1);

        string[] startArray = strings:split(start, "-");
        string[] endArray = strings:split(end, "-");

        logger:info("SUPPORT JIRA CONNECTED");

        try {
            if (JIRA_Connector == null) {
                setJIRAConnector();
            }

            json configs = getConfigurationData(CONFIGURATION_PATH);
            var JIRA_ACCESS_TOKEN, _ = (string)configs.SUPPORT_JIRA.ACCESS_TOKEN;

            message request = {};
            message response = {};
            messages:setHeader(request, "Authorization", JIRA_ACCESS_TOKEN);

            json payload = {"jql":"created>='" + startArray[0] + "/" + startArray[1] + "/" + startArray[2] + " 00:00' and  created<='" + endArray[0] + "/" + endArray[1] + "/" + endArray[2] + " 23:59' AND issuekey in (" + finalSecurityIds + ") AND labels in (CustFoundVuln,ExtFoundVuln,IntFoundVuln)"};
            messages:setJsonPayload(request, payload);

            response = JIRA_Connector.post(JIRA_PATH, request);

            jiraRecords = messages:getJsonPayload(response);
            statusCode = http:getStatusCode(response);

        } catch (errors:Error err) {
            logger:error("SUPPORT JIRA CONNECTION ERROR - " + err.msg);
        }

        logger:info("SUPPORT JIRA DATA RECEIVED");

        if (statusCode == 200) {
            var jiraFetchCount, _ = (int)jiraRecords.total;

            if (jiraFetchCount == 0) {
                unCategorizedCount = fetchPatchCount - jiraFetchCount;
            } else {
                int issueLength = lengthof jiraRecords.issues;
                loop = 0;
                while (loop < securityLength) {
                    int loop2 = 0;
                    var tempCount = 0;
                    while (loop2 < issueLength) {
                        var id, _ = (string)jiraRecords.issues[loop2].key;
                        if (idPool[loop] == id) {
                            tempCount = idCounts[loop];
                            verifyActualId[loop] = 1;
                            int loop3 = 0;
                            int labelInt = lengthof jiraRecords.issues[loop2].fields.labels;
                            while (loop3 < labelInt) {
                                var label, _ = (string)jiraRecords.issues[loop2].fields.labels[loop3];
                                if (label == "ExtFoundVuln" || label == "CustFoundVuln") {
                                    reactiveCount = reactiveCount + tempCount;
                                    break;
                                } else if (label == "IntFoundVuln") {
                                    proactiveCount = proactiveCount + tempCount;
                                    break;
                                }
                                loop3 = loop3 + 1;
                            }
                        }
                        loop2 = loop2 + 1;
                    }
                    loop = loop + 1;
                }

                loop = 0;
                while (loop < securityLength) {
                    if (verifyActualId[loop] == 0) {
                        unCategorizedCount = unCategorizedCount + idCounts[loop];
                    }
                    loop = loop + 1;
                }
            }
        }else{
            bool = "False";
        }

    }

    json loadCounts = {   "yetToStartCount":yetToStartCount(start, end),
                          "inProgressCount":inProgressCount(start, end),
                          "completedCount":completedCount(start, end),
                          "partiallyCompletedCount":partiallyCompletedCount(start, end),
                          "ETACount":overETACount(start, end),
                          "reactiveCount":reactiveCount,
                          "proactiveCount":proactiveCount,
                          "uncategorizedCount":unCategorizedCount,
                          "menuDetails":drillDownMenu,
                          "isJIRAConnected":bool
                      };

    logger:info("PMT DASHBOARD LOADED SUCCESSFULLY");

    datatables:close(resultsOfAllProducts);
    datatables:close(resultsOfAllProductsVersions);
    datatables:close(resultOfDatabaseReactivePatches);
    datatables:close(resultOfDatabaseProactivePatches);
    datatables:close(resultOfDatabaseSecurityInternalPatches);

    //close MYSQL client connector
    dbConnection.close();

    return loadCounts;

}

function yetToStartCount (string start, string end) (int) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};

    params = [startDate, endDate, valueOfActiveIsNo, endDate, valueOfActiveIsYes, startDate, endDate];
    datatable resultOfYetToStartPatchCount = dbConnection.select(GET_YET_TO_START_PATCH_COUNTS, params);
    var jsonResOfYetToStartCount, _ = <json>resultOfYetToStartPatchCount;
    var yetToStartPatchCount, _ = (int)jsonResOfYetToStartCount[0].qtotal;

    datatables:close(resultOfYetToStartPatchCount);

    //close MYSQL client connector
    dbConnection.close();

    return yetToStartPatchCount;
}

function completedCount (string start, string end) (int) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    params = [valueOfActiveIsNo, startDate, endDate, startDate, endDate, startDate, endDate];

    datatable resultOfCompletePatchCount = dbConnection.select(GET_COMPLETED_PATCH_COUNTS, params);
    var jsonResOfCompletedCount, _ = <json>resultOfCompletePatchCount;
    var completeCount, _ = (int)jsonResOfCompletedCount[0].ctotal;

    datatables:close(resultOfCompletePatchCount);

    //close MYSQL client connector
    dbConnection.close();

    return completeCount;
}

function partiallyCompletedCount (string start, string end) (int) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    params = [valueOfActiveIsNo, startDate, endDate, startDate, endDate, startDate, endDate];

    datatable resultOfPartiallyCompletedCount = dbConnection.select(PARTIALLY_COMPLETED_PATCH_COUNTS, params);
    var jsonResOfPartiallyCompletedCount, _ = <json>resultOfPartiallyCompletedCount;
    var partiallyCompleteCount, _ = (int)jsonResOfPartiallyCompletedCount[0].ctotal;

    datatables:close(resultOfPartiallyCompletedCount);

    //close MYSQL client connector
    dbConnection.close();


    return partiallyCompleteCount;
}

function inProgressCount (string start, string end) (int) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
    params = [startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate];

    datatable resultOfInProgressCount = dbConnection.select(GET_IN_PROGRESS_PATCH_COUNTS, params);
    var jsonResOfInProgressCount, _ = <json>resultOfInProgressCount;
    var inProgressPatchCount, _ = (int)jsonResOfInProgressCount[0].devtotal;

    datatables:close(resultOfInProgressCount);

    //close MYSQL client connector
    dbConnection.close();

    return inProgressPatchCount;
}

function overETACount (string start, string end) (int) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
    params = [startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate, endDate];

    datatable resultOfOverETACount = dbConnection.select(GET_OVER_ETA_PATCH_COUNTS, params);
    var jsonResOfOverETACount, _ = <json>resultOfOverETACount;
    var etaCount, _ = (int)jsonResOfOverETACount[0].etatotal;

    datatables:close(resultOfOverETACount);

    //close MYSQL client connector
    dbConnection.close();

    return etaCount;
}

function queuedDetails (string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    params = [startDate, endDate, valueOfActiveIsNo, endDate, valueOfActiveIsYes, startDate, endDate];
    datatable resultOfYetToStartPatchDetails = dbConnection.select(GET_YET_TO_START_PATCH_DETAILS, params);
    var jsonResOfQueueDetails, _ = <json>resultOfYetToStartPatchDetails;

    logger:info("YET TO START DETAILS SENT");

    logger:debug(jsonResOfQueueDetails);
    //close MYSQL client connector
    dbConnection.close();

    return jsonResOfQueueDetails;
}

function devDetails (string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};

    params = [startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate];
    datatable resultOfInProgressPatchDetails = dbConnection.select(GET_IN_PROGRESS_PATCH_DETAILS, params);
    var jsonResOfDevDetails, _ = <json>resultOfInProgressPatchDetails;

    logger:info("IN PROGRESS DETAILS SENT");
    logger:debug(jsonResOfDevDetails);
    //close MYSQL client connector
    dbConnection.close();

    return jsonResOfDevDetails;
}

function completeDetails (string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter valueOfStatusIsOne = {sqlType:"varchar", value:"1"};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    params = [valueOfStatusIsOne, valueOfActiveIsNo, startDate, endDate, startDate, endDate, startDate, endDate];
    datatable resultOfAllCompletePatchDetails = dbConnection.select(GET_COMPLETED_PATCH_DETAILS, params);
    var jsonResOfCompleteDetails, _ = <json>resultOfAllCompletePatchDetails;

    logger:info("COMPLETED DETAILS SENT");
    logger:debug(jsonResOfCompleteDetails);
    //close MYSQL client connector
    dbConnection.close();

    return jsonResOfCompleteDetails;
}

function menuBadgesCounts (string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};

    params = [startDate, endDate, valueOfActiveIsNo, endDate, valueOfActiveIsYes, startDate, endDate];
    datatable resultOfProductWiseTetToStartCount = dbConnection.select(PRODUCT_WISE_YET_TO_START_COUNT, params);
    var jsonResOfQueuedCount, _ = <json>resultOfProductWiseTetToStartCount;

    params = [startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate, endDate];
    datatable resultOfProductWiseOverETACount = dbConnection.select(PRODUCT_WISE_OVER_ETA_COUNT, params);
    var jsonResOfETACounts, _ = <json>resultOfProductWiseOverETACount;

    params = [startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate];
    datatable resultOfProductWiseInProgressCount = dbConnection.select(PRODUCT_WISE_IN_PROGRESS_COUNT, params);
    var jsonResOfDEVCounts, _ = <json>resultOfProductWiseInProgressCount;

    json menuBadgeCount = {"jsonResOfQueuedCount":jsonResOfQueuedCount, "jsonResOfETACounts":jsonResOfETACounts, "jsonResOfDEVCounts":jsonResOfDEVCounts};

    logger:info("MAIN MENU BADGE COUNTS SENT");
    datatables:close(resultOfProductWiseTetToStartCount);
    datatables:close(resultOfProductWiseOverETACount);
    datatables:close(resultOfProductWiseInProgressCount);

    //close MYSQL client connector
    dbConnection.close();

    return menuBadgeCount;
}

function menuVersionBadgesCounts (string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};


    params = [startDate, endDate, valueOfActiveIsNo, endDate, valueOfActiveIsYes, startDate, endDate];
    datatable resultOfVersionWiseYetToStartPatchCount = dbConnection.select(VERSION_WISE_YET_TO_START_COUNT, params);
    var jsonResOfQueuedCount, _ = <json>resultOfVersionWiseYetToStartPatchCount;

    params = [startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate, endDate];
    datatable resultOfVersionWiseOverETACount = dbConnection.select(VERSION_WISE_OVER_ETA_COUNT, params);
    var jsonResOfETACounts, _ = <json>resultOfVersionWiseOverETACount;

    params = [startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate];
    datatable resultOfVersionWiseInProgressCount = dbConnection.select(VERSION_WISE_IN_PROGRESS_COUNT, params);
    var jsonResOfDEVCounts, _ = <json>resultOfVersionWiseInProgressCount;

    json menuBadgeCount = {"jsonResOfQueuedCount":jsonResOfQueuedCount, "jsonResOfETACounts":jsonResOfETACounts, "jsonResOfDEVCounts":jsonResOfDEVCounts};

    logger:info("MAIN MENU VERSION BADGE COUNTS SENT");
    datatables:close(resultOfVersionWiseYetToStartPatchCount);
    datatables:close(resultOfVersionWiseOverETACount);
    datatables:close(resultOfVersionWiseInProgressCount);

    //close MYSQL client connector
    dbConnection.close();

    return menuBadgeCount;
}

function reportedPatchGraph (string duration, string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    logger:info("REPORTED PATCHES FOR " + duration + " REQUESTED");

    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};

    params = [valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
    boolean isEmpty = false;
    int jsonResOfReportedPatchesLength = 0;
    int loop = 0;
    json reportedPatchDrillDown = [];
    json jsonResOfReportedPatches = {};
    json weekFirstDate = {};

    if (duration == "month") {
        datatable resultOfReportedPatchesMonthly = dbConnection.select(REPORTED_PATCH_MONTH_BASIS, params);
        jsonResOfReportedPatches, _ = <json>resultOfReportedPatchesMonthly;

        jsonResOfReportedPatchesLength = lengthof jsonResOfReportedPatches;

        while (loop < jsonResOfReportedPatchesLength) {
            sql:Parameter currentMonth = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].TYPE};
            sql:Parameter month = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].MONTH};
            sql:Parameter quarter = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].QUARTER};
            sql:Parameter year = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].YEAR};
            params = [currentMonth, month, quarter, year, valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
            datatable resultOfReportedPatchProductWiseMonth = dbConnection.select(REPORTED_PATCH_PRODUCT_WISE_MONTH_BASIS, params);
            reportedPatchDrillDown[loop], _ = <json>resultOfReportedPatchProductWiseMonth;
            loop = loop + 1;
        }


    } else if (duration == "day") {
        datatable resultOfReportedPatchDaily = dbConnection.select(REPORTED_PATCH_DAY_BASIS, params);
        jsonResOfReportedPatches, _ = <json>resultOfReportedPatchDaily;

        jsonResOfReportedPatchesLength = lengthof jsonResOfReportedPatches;

        while (loop < jsonResOfReportedPatchesLength) {
            sql:Parameter currentDay = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].TYPE};
            sql:Parameter month = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].MONTH};
            sql:Parameter quarter = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].QUARTER};
            sql:Parameter year = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].YEAR};
            params = [currentDay, month, quarter, year, valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
            datatable resultOfReportedPatchProductWiseDaily = dbConnection.select(REPORTED_PATCH_PRODUCT_WISE_DAY_BASIS, params);
            reportedPatchDrillDown[loop], _ = <json>resultOfReportedPatchProductWiseDaily;
            loop = loop + 1;
        }


    } else if (duration == "week") {
        datatable resultOfReportedPatchWeekly = dbConnection.select(REPORTED_PATCH_WEEK_BASIS, params);
        jsonResOfReportedPatches, _ = <json>resultOfReportedPatchWeekly;

        jsonResOfReportedPatchesLength = lengthof jsonResOfReportedPatches;


        while (loop < jsonResOfReportedPatchesLength) {
            sql:Parameter currentWeek = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].TYPE};
            sql:Parameter currentYear = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].YEAR};
            params = [currentWeek, currentYear, valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
            datatable resultOfReportedPatchProductWiseWeekly = dbConnection.select(REPORTED_PATCH_PRODUCT_WISE_WEEK_BASIS, params);
            reportedPatchDrillDown[loop], _ = <json>resultOfReportedPatchProductWiseWeekly;
            loop = loop + 1;
        }


    } else if (duration == "quarter") {
        datatable resultOfReportedPatchQuarterly = dbConnection.select(REPORTED_PATCH_QUARTER_BASIS, params);
        jsonResOfReportedPatches, _ = <json>resultOfReportedPatchQuarterly;

        jsonResOfReportedPatchesLength = lengthof jsonResOfReportedPatches;


        while (loop < jsonResOfReportedPatchesLength) {
            sql:Parameter currentQuarter = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].TYPE};
            sql:Parameter currentYear = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].YEAR};
            params = [currentQuarter, currentYear, valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
            datatable resultOfReportedPatchProductWiseQuarterly = dbConnection.select(REPORTED_PATCH_PRODUCT_WISE_QUARTER_BASIS, params);
            reportedPatchDrillDown[loop], _ = <json>resultOfReportedPatchProductWiseQuarterly;
            loop = loop + 1;
        }

    } else if (duration == "year") {
        datatable resultOfReportedPatchYearly = dbConnection.select(REPORTED_PATCH_YEAR_BASIS, params);
        jsonResOfReportedPatches, _ = <json>resultOfReportedPatchYearly;

        jsonResOfReportedPatchesLength = lengthof jsonResOfReportedPatches;


        while (loop < jsonResOfReportedPatchesLength) {
            sql:Parameter currentYear = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].TYPE};
            sql:Parameter year = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].YEAR};
            params = [currentYear, year, valueOfActiveIsYes, valueOfActiveIsNo, startDate, endDate];
            datatable resultOfReportedPatchProductWiseYearly = dbConnection.select(REPORTED_PATCH_PRODUCT_WISE_YEAR_BASIS, params);
            reportedPatchDrillDown[loop], _ = <json>resultOfReportedPatchProductWiseYearly;
            loop = loop + 1;
        }

    }


    if (jsonResOfReportedPatchesLength == 0) {
        isEmpty = true;
    }

    json mainArray = [];
    loop = 0;

    while (loop < jsonResOfReportedPatchesLength) {
        json dump = {name:"x", y:2016, drilldown:"y"};
        dump.y = jsonResOfReportedPatches[loop].COUNTS;
        var patchCount, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
        if (duration == "month") {
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var patchName, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            dump.name = patchYear + "-" + months[patchName - 1];
            dump.drilldown = patchYear + "-" + months[patchName - 1];
        } else if (duration == "quarter") {
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var quarter, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            dump.name = patchYear + "-" + quarter;
            dump.drilldown = patchYear + "-" + quarter;
        } else if (duration == "day") {
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var patchMonth, castErr = (int)jsonResOfReportedPatches[loop].MONTH;
            var date, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            dump.name = patchYear + "-" + months[patchMonth - 1] + "-" + date;
            dump.drilldown = patchYear + "-" + months[patchMonth - 1] + "-" + date;
        } else if (duration == "week") {
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var week, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            var weekDate, castErr = (string)jsonResOfReportedPatches[loop].FIRSTDATE;
            dump.name = weekDate;
            dump.drilldown = weekDate+loop;
        } else {
            dump.name = jsonResOfReportedPatches[loop].TYPE;
            dump.drilldown = jsonResOfReportedPatches[loop].TYPE;
        }
        mainArray[loop] = dump;
        loop = loop + 1;
    }

    json chartData = [];
    int reportedPatchesDrillDownLength = lengthof reportedPatchDrillDown;
    loop = 0;

    while (loop < reportedPatchesDrillDownLength) {
        json temps = [];
        int loop2 = 0;
        int index = 0;
        int innerElementLength = lengthof reportedPatchDrillDown[loop];
        while (loop2 < innerElementLength) {
            json temp = [];
            var patchCount, castErr = (int)reportedPatchDrillDown[loop][loop2].total;
            var patchName, castErr = (string)reportedPatchDrillDown[loop][loop2].PRODUCT_NAME;
            temp[0] = patchName;
            temp[1] = patchCount;
            temps[index] = temp;
            loop2 = loop2 + 1;
            index = index + 1;
        }
        chartData[loop] = temps;
        loop = loop + 1;
    }

    json drillDown = [];
    loop = 0;
    while (loop < jsonResOfReportedPatchesLength) {
        json temp = {name:"x", id:2016, data:"y"};
        if (duration == "month") {
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var patchName, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            temp.name = patchYear + "-" + months[patchName - 1];
            temp.id = patchYear + "-" + months[patchName - 1];
        } else if (duration == "quarter") {
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var quarter, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            temp.name = patchYear + "-" + quarter;
            temp.id = patchYear + "-" + quarter;
        } else if (duration == "day") {
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var patchMonth, castErr = (int)jsonResOfReportedPatches[loop].MONTH;
            var date, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            temp.name = patchYear + "-" + months[patchMonth - 1] + "-" + date;
            temp.id = patchYear + "-" + months[patchMonth - 1] + "-" + date;
        } else if (duration == "week") {
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var week, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            var weekDate, castErr = (string)jsonResOfReportedPatches[loop].FIRSTDATE;
            temp.name = weekDate;
            temp.id = weekDate+loop;
        } else {
            temp.name = jsonResOfReportedPatches[loop].TYPE;
            temp.id = jsonResOfReportedPatches[loop].TYPE;
        }
        temp.data = chartData[loop];
        drillDown[loop] = temp;
        loop = loop + 1;
    }

    json reportedPatches = {"isEmpty":isEmpty, "graphMainData":mainArray, "graphDrillDownData":drillDown};

    logger:info("REPORTED PATCHES FOR " + duration + " DATA SENT");

    //close MYSQL client connector
    dbConnection.close();

    return reportedPatches;
}

function totalProductSummaryCounts (string inputProduct, string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
    sql:Parameter product = {sqlType:"varchar", value:inputProduct};
    sql:Parameter valueBug = {sqlType:"varchar", value:"Bug"};

    params = [valueOfActiveIsYes, valueOfActiveIsNo, product, valueBug, startDate, endDate];
    datatable resultOfProductBugCount = dbConnection.select(SPECIFIC_PRODUCT_BUG_COUNT, params);
    var jsonResOfBugCount, _ = <json>resultOfProductBugCount;

    params = [product, startDate, endDate, valueOfActiveIsNo, endDate, product, valueOfActiveIsYes, startDate, endDate];
    datatable resultOfProductYetToStartCount = dbConnection.select(SPECIFIC_PRODUCT_YET_TO_START_COUNT, params);
    var jsonResOfQueuedCounts, _ = <json>resultOfProductYetToStartCount;

    params = [valueOfStatusIsOne, product, startDate, endDate, startDate, endDate, startDate, endDate];
    datatable resultOfProductCompleteCount = dbConnection.select(SPECIFIC_PRODUCT_COMPLETED_COUNT, params);
    var jsonResOfCompleteCounts, _ = <json>resultOfProductCompleteCount;

    params = [product, startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate];
    datatable resultOfProductInProgressCount = dbConnection.select(SPECIFIC_PRODUCT_IN_PROGRESS_COUNT, params);
    var jsonResOfDevCounts, _ = <json>resultOfProductInProgressCount;

    params = [valueOfStatusIsOne, product, startDate, endDate, startDate, endDate, startDate, endDate];
    datatable resultOfProductPartiallyCompleteCount = dbConnection.select(SPECIFIC_PRODUCT_PARTIALLY_COMPLETED_COUNT, params);
    var jsonResOfPartiallyCompleteCounts, _ = <json>resultOfProductPartiallyCompleteCount;

    json totalProductSummaryCount = {"jsonResOfQueuedCounts":jsonResOfQueuedCounts, "jsonResOfDevCounts":jsonResOfDevCounts, "jsonResOfCompleteCounts":jsonResOfCompleteCounts, "jsonResOfBugCount":jsonResOfBugCount, "jsonResOfPartiallyCompleteCount":jsonResOfPartiallyCompleteCounts};

    logger:info("RETURNED " + inputProduct + " TOTAL SUMMARY COUNTS");

    //close MYSQL client connector
    dbConnection.close();

    return totalProductSummaryCount;
}

function selectedProductTotalReleaseTrend (string inputProduct, string duration, string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
    sql:Parameter product = {sqlType:"varchar", value:inputProduct};

    params = [product, valueOfStatusIsOne, startDate, endDate, startDate, endDate, startDate, endDate];
    boolean isEmpty = false;
    int jsonResOfReleaseTrendLength = 0;
    int loop = 0;
    json jsonResOfReleaseTrend = {};
    json jsonResOfCompleteReleaseTrend = {};
    json jsonResOfPartiallyCompleteReleaseTrend = {};
    json weekFirstDate = {};

    if (duration == "week") {
        datatable resultOfTotalReleaseTrendWeekly = dbConnection.select(ALL_RELEASE_TREND_OF_TOTAL_PRODUCT_WEEK, params);
        jsonResOfReleaseTrend, _ = <json>resultOfTotalReleaseTrendWeekly;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;
        weekFirstDate = getReleaseFirstDateFromWeekNumber(start, end);

        datatable resultOfCompleteReleaseTrendWeekly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_WEEK, params);
        jsonResOfCompleteReleaseTrend, _ = <json>resultOfCompleteReleaseTrendWeekly;

        datatable resultOfPartiallyCompleteReleaseTrendWeekly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_WEEK, params);
        jsonResOfPartiallyCompleteReleaseTrend, _ = <json>resultOfPartiallyCompleteReleaseTrendWeekly;

    } else if (duration == "month") {
        datatable resultOfTotalReleaseTrendMonthly = dbConnection.select(ALL_RELEASE_TREND_OF_TOTAL_PRODUCT_MONTH, params);
        jsonResOfReleaseTrend, _ = <json>resultOfTotalReleaseTrendMonthly;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        datatable resultOfCompleteReleaseTrendMonthly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_MONTH, params);
        jsonResOfCompleteReleaseTrend, _ = <json>resultOfCompleteReleaseTrendMonthly;

        datatable resultOfPartiallyCompleteReleaseTrendMonthly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_MONTH, params);
        jsonResOfPartiallyCompleteReleaseTrend, _ = <json>resultOfPartiallyCompleteReleaseTrendMonthly;


    } else if (duration == "quarter") {
        datatable resultOfTotalReleaseTrendQuarterly = dbConnection.select(ALL_RELEASE_TREND_OF_TOTAL_PRODUCT_QUARTER, params);
        jsonResOfReleaseTrend, _ = <json>resultOfTotalReleaseTrendQuarterly;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;


        datatable resultOfCompleteReleaseTrendQuarterly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_QUARTER, params);
        jsonResOfCompleteReleaseTrend, _ = <json>resultOfCompleteReleaseTrendQuarterly;

        datatable resultOfPartiallyCompleteReleaseTrendQuarterly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_QUARTER, params);
        jsonResOfPartiallyCompleteReleaseTrend, _ = <json>resultOfPartiallyCompleteReleaseTrendQuarterly;


    } else if (duration == "year") {
        datatable resultOfTotalReleaseTrendYearly = dbConnection.select(ALL_RELEASE_TREND_OF_TOTAL_PRODUCT_YEAR, params);
        jsonResOfReleaseTrend, _ = <json>resultOfTotalReleaseTrendYearly;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        datatable resultOfCompleteReleaseTrendYearly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_YEAR, params);
        jsonResOfCompleteReleaseTrend, _ = <json>resultOfCompleteReleaseTrendYearly;

        datatable resultOfPartiallyCompleteReleaseTrendYearly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_YEAR, params);
        jsonResOfPartiallyCompleteReleaseTrend, _ = <json>resultOfPartiallyCompleteReleaseTrendYearly;

    }


    if (jsonResOfReleaseTrendLength == 0) {
        isEmpty = true;
    }

    json mainArray = [];
    loop = 0;

    //create array of including partially and fully completed patch counts
    json partiallyArray = [];
    json completeArray = [];

    while (loop < jsonResOfReleaseTrendLength) {
        int loop2 = 0;
        boolean flag = false;
        while (loop2 < lengthof jsonResOfCompleteReleaseTrend) {
            var resType, _ = (int)jsonResOfReleaseTrend[loop].TYPE;
            var resYear, _ = (int)jsonResOfReleaseTrend[loop].YEAR;
            var comType, _ = (int)jsonResOfCompleteReleaseTrend[loop2].TYPE;
            var comYear, _ = (int)jsonResOfCompleteReleaseTrend[loop2].YEAR;

            if (resType == comType && resYear == comYear) {

                completeArray[loop] = jsonResOfCompleteReleaseTrend[loop2].total;
                flag = true;
                break;
            }
            loop2 = loop2 + 1;
        }
        if (!flag) {
            completeArray[loop] = 0;
        }

        loop = loop + 1;
    }


    loop = 0;
    while (loop < jsonResOfReleaseTrendLength) {
        int loop2 = 0;
        boolean flag = false;
        while (loop2 < lengthof jsonResOfPartiallyCompleteReleaseTrend) {
            var resType, _ = (int)jsonResOfReleaseTrend[loop].TYPE;
            var resYear, _ = (int)jsonResOfReleaseTrend[loop].YEAR;
            var comType, _ = (int)jsonResOfPartiallyCompleteReleaseTrend[loop2].TYPE;
            var comYear, _ = (int)jsonResOfPartiallyCompleteReleaseTrend[loop2].YEAR;

            if (resType == comType && resYear == comYear) {
                partiallyArray[loop] = jsonResOfPartiallyCompleteReleaseTrend[loop2].total;
                flag = true;
                break;
            }
            loop2 = loop2 + 1;
        }
        if (!flag) {
            partiallyArray[loop] = 0;
        }

        loop = loop + 1;
    }


    loop = 0;
    while (loop < jsonResOfReleaseTrendLength) {
        json dump = {name:"x", y:2016, sub:"array"};
        dump.y = jsonResOfReleaseTrend[loop].total;
        dump.sub = [completeArray[loop], partiallyArray[loop]];
        var patchCount, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
        if (duration == "month") {
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var patchName, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear + "-" + months[patchName - 1];
        } else if (duration == "quarter") {
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var quarter, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear + "-" + quarter;
        } else if (duration == "day") {
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var patchMonth, castErr = (int)jsonResOfReleaseTrend[loop].MONTH;
            var date, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear + "-" + months[patchMonth - 1] + "-" + date;
        } else if (duration == "week") {
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var week, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            var weekDate, castErr = (string)weekFirstDate[loop].FIRSTWEEK;
            dump.name = weekDate;
        } else {
            dump.name = jsonResOfReleaseTrend[loop].TYPE;
        }
        mainArray[loop] = dump;
        loop = loop + 1;
    }

    json reportedPatches = {"isEmpty":isEmpty, "totalReleaseTrend":mainArray};

    logger:info(inputProduct + " TOTAL RELEASE " + duration + " TREND DATA SENT");

    //close MYSQL client connector
    dbConnection.close();

    return reportedPatches;
}

function selectedProductVersionSummaryCounts (string inputProduct, string inVersion, string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
    sql:Parameter product = {sqlType:"varchar", value:inputProduct};
    sql:Parameter valueBug = {sqlType:"varchar", value:"Bug"};
    sql:Parameter inputVersion = {sqlType:"varchar", value:inVersion};

    params = [valueOfActiveIsYes, valueOfActiveIsNo, product, inputVersion, valueBug, startDate, endDate];
    datatable resultOfProductVersionBugCount = dbConnection.select(SPECIFIC_PRODUCT_VERSION_BUG_COUNT, params);
    var jsonResOfBugCount, _ = <json>resultOfProductVersionBugCount;

    params = [product, inputVersion, startDate, endDate, valueOfActiveIsNo, endDate, product, inputVersion, valueOfActiveIsYes, startDate, endDate];
    datatable resultOfVersionBugCount = dbConnection.select(SPECIFIC_PRODUCT_VERSION_YET_TO_START_COUNT, params);
    var jsonResOfQueuedCounts, _ = <json>resultOfVersionBugCount;

    params = [valueOfStatusIsOne, product, inputVersion, startDate, endDate, startDate, endDate, startDate, endDate];
    datatable resultOfVersionYetToStartCount = dbConnection.select(SPECIFIC_PRODUCT_VERSION_COMPLETED_COUNT, params);
    var jsonResOfCompleteCounts, _ = <json>resultOfVersionYetToStartCount;

    params = [product, inputVersion, startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate];
    datatable resultOfProductVersionInProgressCount = dbConnection.select(SPECIFIC_PRODUCT_VERSION_IN_PROGRESS_COUNT, params);
    var jsonResOfDevCounts, _ = <json>resultOfProductVersionInProgressCount;

    params = [valueOfStatusIsOne, product, inputVersion, startDate, endDate, startDate, endDate, startDate, endDate];
    datatable resultOfProductVersionPartiallyCompletedCount = dbConnection.select(SPECIFIC_PRODUCT_VERSION_PARTIALLY_COMPLETED_COUNT, params);
    var jsonResOfPartiallyCompleteCounts, _ = <json>resultOfProductVersionPartiallyCompletedCount;

    json versionProductSummaryCount = {"jsonResOfQueuedCounts":jsonResOfQueuedCounts, "jsonResOfDevCounts":jsonResOfDevCounts, "jsonResOfCompleteCounts":jsonResOfCompleteCounts, "jsonResOfBugCount":jsonResOfBugCount, "jsonResOfPartiallyCompleteCount":jsonResOfPartiallyCompleteCounts};

    logger:info("RETURNED " + inputProduct + "-" + inVersion + " TOTAL SUMMARY COUNTS");

    //close MYSQL client connector
    dbConnection.close();

    return versionProductSummaryCount;
}

function selectedProductVersionReleaseTrend (string inputProduct, string inVersion, string duration, string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
    sql:Parameter product = {sqlType:"varchar", value:inputProduct};
    sql:Parameter version = {sqlType:"varchar", value:inVersion};

    params = [product, version, valueOfStatusIsOne, startDate, endDate, startDate, endDate, startDate, endDate];
    boolean isEmpty = false;
    int jsonResOfReleaseTrendLength = 0;
    int loop = 0;
    json jsonResOfReleaseTrend = {};
    json jsonResOfCompleteReleaseTrend = {};
    json jsonResOfPartiallyCompleteReleaseTrend = {};
    json weekFirstDate = {};

    if (duration == "week") {
        datatable resultOfAllReleaseTrendWeekly = dbConnection.select(ALL_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_WEEK, params);
        jsonResOfReleaseTrend, _ = <json>resultOfAllReleaseTrendWeekly;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;
        weekFirstDate = getReleaseFirstDateFromWeekNumber(start, end);

        datatable resultOfAllCompleteReleaseTrendWeekly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_WEEK, params);
        jsonResOfCompleteReleaseTrend, _ = <json>resultOfAllCompleteReleaseTrendWeekly;

        datatable resultOfAllPartiallyCompleteReleaseTrendWeekly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_WEEK, params);
        jsonResOfPartiallyCompleteReleaseTrend, _ = <json>resultOfAllPartiallyCompleteReleaseTrendWeekly;


    } else if (duration == "month") {
        datatable resultOfAllReleaseTrendMonthly = dbConnection.select(ALL_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_MONTH, params);
        jsonResOfReleaseTrend, _ = <json>resultOfAllReleaseTrendMonthly;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        datatable resultOfAllCompleteReleaseTrendMonthly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_MONTH, params);
        jsonResOfCompleteReleaseTrend, _ = <json>resultOfAllCompleteReleaseTrendMonthly;

        datatable resultOfAllPartiallyCompleteReleaseTrendMonthly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_MONTH, params);
        jsonResOfPartiallyCompleteReleaseTrend, _ = <json>resultOfAllPartiallyCompleteReleaseTrendMonthly;


    } else if (duration == "quarter") {
        datatable resultOfAllReleaseTrendQuarterly = dbConnection.select(ALL_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_QUARTER, params);
        jsonResOfReleaseTrend, _ = <json>resultOfAllReleaseTrendQuarterly;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        datatable resultOfAllCompleteReleaseTrendQuarterly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_QUARTER, params);
        jsonResOfCompleteReleaseTrend, _ = <json>resultOfAllCompleteReleaseTrendQuarterly;

        datatable resultOfAllPartiallyCompleteReleaseTrendQuarterly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_QUARTER, params);
        jsonResOfPartiallyCompleteReleaseTrend, _ = <json>resultOfAllPartiallyCompleteReleaseTrendQuarterly;


    } else if (duration == "year") {
        datatable resultOfAllReleaseTrendYearly = dbConnection.select(ALL_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_YEAR, params);
        jsonResOfReleaseTrend, _ = <json>resultOfAllReleaseTrendYearly;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        datatable resultOfAllCompleteReleaseTrendYearly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_YEAR, params);
        jsonResOfCompleteReleaseTrend, _ = <json>resultOfAllCompleteReleaseTrendYearly;

        datatable resultOfAllPartiallyCompleteReleaseTrendYearly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_TOTAL_PRODUCT_VERSION_YEAR, params);
        jsonResOfPartiallyCompleteReleaseTrend, _ = <json>resultOfAllPartiallyCompleteReleaseTrendYearly;

    }


    if (jsonResOfReleaseTrendLength == 0) {
        isEmpty = true;
    }

    json mainArray = [];
    loop = 0;

    //create array of including partially and fully completed patch counts
    json partiallyArray = [];
    json completeArray = [];

    while (loop < jsonResOfReleaseTrendLength) {
        int loop2 = 0;
        boolean flag = false;
        while (loop2 < lengthof jsonResOfCompleteReleaseTrend) {
            var resType, _ = (int)jsonResOfReleaseTrend[loop].TYPE;
            var resYear, _ = (int)jsonResOfReleaseTrend[loop].YEAR;
            var comType, _ = (int)jsonResOfCompleteReleaseTrend[loop2].TYPE;
            var comYear, _ = (int)jsonResOfCompleteReleaseTrend[loop2].YEAR;

            if (resType == comType && resYear == comYear) {

                completeArray[loop] = jsonResOfCompleteReleaseTrend[loop2].total;
                flag = true;
                break;
            }
            loop2 = loop2 + 1;
        }
        if (!flag) {
            completeArray[loop] = 0;
        }

        loop = loop + 1;
    }


    loop = 0;
    while (loop < jsonResOfReleaseTrendLength) {
        int loop2 = 0;
        boolean flag = false;
        while (loop2 < lengthof jsonResOfPartiallyCompleteReleaseTrend) {
            var resType, _ = (int)jsonResOfReleaseTrend[loop].TYPE;
            var resYear, _ = (int)jsonResOfReleaseTrend[loop].YEAR;
            var comType, _ = (int)jsonResOfPartiallyCompleteReleaseTrend[loop2].TYPE;
            var comYear, _ = (int)jsonResOfPartiallyCompleteReleaseTrend[loop2].YEAR;

            if (resType == comType && resYear == comYear) {
                partiallyArray[loop] = jsonResOfPartiallyCompleteReleaseTrend[loop2].total;
                flag = true;
                break;
            }
            loop2 = loop2 + 1;
        }
        if (!flag) {
            partiallyArray[loop] = 0;
        }

        loop = loop + 1;
    }

    //create response JSON to send data
    loop = 0;
    while (loop < jsonResOfReleaseTrendLength) {
        json dump = {name:"x", y:2016, sub:"array"};
        dump.y = jsonResOfReleaseTrend[loop].total;
        dump.sub = [completeArray[loop], partiallyArray[loop]];
        var patchCount, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
        if (duration == "month") {
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var patchName, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear + "-" + months[patchName - 1];
        } else if (duration == "quarter") {
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var quarter, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear + "-" + quarter;
        } else if (duration == "day") {
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var patchMonth, castErr = (int)jsonResOfReleaseTrend[loop].MONTH;
            var date, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear + "-" + months[patchMonth - 1] + "-" + date;
        } else if (duration == "week") {
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var week, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            var weekDate, castErr = (string)weekFirstDate[loop].FIRSTWEEK;
            dump.name = weekDate;
        } else {
            dump.name = jsonResOfReleaseTrend[loop].TYPE;
        }
        mainArray[loop] = dump;
        loop = loop + 1;
    }

    json reportedPatches = {"isEmpty":isEmpty, "versionReleaseTrend":mainArray};

    logger:info(inputProduct + "-" + inVersion + " RELEASE TREND DATA SENT");

    //close MYSQL client connector
    dbConnection.close();

    return reportedPatches;
}

function selectedProductAllVersionReleaseTrend (string inProduct, string inVersion, string duration, string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    string[] versionArray = strings:split(inVersion, "-");
    int versionLength = lengthof versionArray;
    sql:Parameter[] params = [];
    int loop = 0;
    boolean isEmpty = false;
    int jsonResOfReleaseTrendLength = 0;
    json jsonResOfReleaseTrend = [];
    json jsonResOfCompleteReleaseTrend = [];
    json jsonResOfPartiallyCompleteReleaseTrend = [];
    json weekFirstDate = {};

    while (loop < versionLength) {
        sql:Parameter product = {sqlType:"varchar", value:inProduct};
        sql:Parameter currentVersion = {sqlType:"varchar", value:versionArray[loop]};
        sql:Parameter startDate = {sqlType:"date", value:start};
        sql:Parameter endDate = {sqlType:"date", value:end};
        sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};

        params = [product, currentVersion, valueOfStatusIsOne, startDate, endDate, startDate, endDate, startDate, endDate];

        if (duration == "week") {
            datatable resultOfAllVersionReleaseTrendWeekly = dbConnection.select(ALL_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_WEEK, params);
            jsonResOfReleaseTrend[loop], _ = <json>resultOfAllVersionReleaseTrendWeekly;

            datatable resultOfAllVersionCompleteReleaseTrendWeekly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_WEEK, params);
            jsonResOfCompleteReleaseTrend[loop], _ = <json>resultOfAllVersionCompleteReleaseTrendWeekly;

            datatable resultOfAllVersionPartiallyCompleteReleaseTrendWeekly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_WEEK, params);
            jsonResOfPartiallyCompleteReleaseTrend[loop], _ = <json>resultOfAllVersionPartiallyCompleteReleaseTrendWeekly;

        } else if (duration == "month") {
            datatable resultOfAllVersionReleaseTrendMonthly = dbConnection.select(ALL_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_MONTH, params);
            jsonResOfReleaseTrend[loop], _ = <json>resultOfAllVersionReleaseTrendMonthly;

            datatable resultOfAllVersionCompleteReleaseTrendMonthly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_MONTH, params);
            jsonResOfCompleteReleaseTrend[loop], _ = <json>resultOfAllVersionCompleteReleaseTrendMonthly;

            datatable resultOfAllVersionPartiallyCompleteReleaseTrendMonthly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_MONTH, params);
            jsonResOfPartiallyCompleteReleaseTrend[loop], _ = <json>resultOfAllVersionPartiallyCompleteReleaseTrendMonthly;

        } else if (duration == "quarter") {
            datatable resultOfAllVersionReleaseTrendQuarterly = dbConnection.select(ALL_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_QUARTER, params);
            jsonResOfReleaseTrend[loop], _ = <json>resultOfAllVersionReleaseTrendQuarterly;

            datatable resultOfAllVersionCompleteReleaseTrendQuarterly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_QUARTER, params);
            jsonResOfCompleteReleaseTrend[loop], _ = <json>resultOfAllVersionCompleteReleaseTrendQuarterly;

            datatable resultOfAllVersionPartiallyCompleteReleaseTrendQuarterly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_QUARTER, params);
            jsonResOfPartiallyCompleteReleaseTrend[loop], _ = <json>resultOfAllVersionPartiallyCompleteReleaseTrendQuarterly;

        } else if (duration == "year") {
            datatable resultOfAllVersionReleaseTrendYearly = dbConnection.select(ALL_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_YEAR, params);
            jsonResOfReleaseTrend[loop], _ = <json>resultOfAllVersionReleaseTrendYearly;

            datatable resultOfAllVersionCompleteReleaseTrendYearly = dbConnection.select(COMPLETE_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_YEAR, params);
            jsonResOfCompleteReleaseTrend[loop], _ = <json>resultOfAllVersionCompleteReleaseTrendYearly;

            datatable resultOfAllVersionPartiallyCompleteReleaseTrendYearly = dbConnection.select(PARTIALLY_COMPLETE_RELEASE_TREND_OF_ALL_PRODUCT_VERSION_YEAR, params);
            jsonResOfPartiallyCompleteReleaseTrend[loop], _ = <json>resultOfAllVersionPartiallyCompleteReleaseTrendYearly;
        }

        loop = loop + 1;
    }

    jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;
    if (jsonResOfReleaseTrendLength == 0) {
        isEmpty = true;
    }

    json reportedPatches = {"isEmpty":isEmpty, "versionReleaseTrend":jsonResOfReleaseTrend, "versionCompletedReleaseTrend":jsonResOfCompleteReleaseTrend, "versionPartiallyCompletedReleasedTrend":jsonResOfPartiallyCompleteReleaseTrend};

    logger:info(inProduct + " ALL VERSION RELEASE TREND DATA SENT");
    logger:debug(reportedPatches);
    //close MYSQL client connector
    dbConnection.close();

    return reportedPatches;
}

function getCategoryDatesForSelectedAllProductVersions (string inProduct, string duration, string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    sql:Parameter[] params = [];
    sql:Parameter product = {sqlType:"varchar", value:inProduct};
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};

    params = [product, valueOfStatusIsOne, startDate, endDate, startDate, endDate, startDate, endDate];
    json jsonResOfcategory = {};

    if (duration == "week") {
        datatable resultOfCategoryDatesInAllVersionsWeekly = dbConnection.select(RELEASE_TREND_OF_ALL_PRODUCT_CATEGORY_WEEK, params);
        jsonResOfcategory, _ = <json>resultOfCategoryDatesInAllVersionsWeekly;

    } else if (duration == "month") {
        datatable resultOfCategoryDatesInAllVersionsMonthly = dbConnection.select(RELEASE_TREND_OF_ALL_PRODUCT_CATEGORY_MONTH, params);
        jsonResOfcategory, _ = <json>resultOfCategoryDatesInAllVersionsMonthly;

    } else if (duration == "quarter") {
        datatable resultOfCategoryDatesInAllVersionsQuarterly = dbConnection.select(RELEASE_TREND_OF_ALL_PRODUCT_CATEGORY_QUARTER, params);
        jsonResOfcategory, _ = <json>resultOfCategoryDatesInAllVersionsQuarterly;

    } else if (duration == "year") {
        datatable resultOfCategoryDatesInAllVersionsYearly = dbConnection.select(RELEASE_TREND_OF_ALL_PRODUCT_CATEGORY_YEAR, params);
        jsonResOfcategory, _ = <json>resultOfCategoryDatesInAllVersionsYearly;
    }

    logger:info("ALL VERSION CATEGORIES SENT");
    logger:debug(jsonResOfcategory);
    //close MYSQL client connector
    dbConnection.close();

    return jsonResOfcategory;
}

function queuedAgeGraphGenerator (string lastMonthDate) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    logger:info("PMT QUEUED AGE GRAPH TAB SELECTED");

    string[] lastDateOfMonthArray = strings:split(lastMonthDate, ">");

    int monthLimitLength = lengthof lastDateOfMonthArray;
    int loop = 0;
    json ageGroup = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]];

    while (loop < monthLimitLength) {
        sql:Parameter[] params = [];


        sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
        sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
        sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
        sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
        sql:Parameter startingDate = {sqlType:"varchar", value:FIRST_DATE_OF_PMT};
        sql:Parameter lastMonthEndDate = {sqlType:"varchar", value:lastDateOfMonthArray[loop]};

        params = [startingDate, lastMonthEndDate, valueOfActiveIsNo, lastMonthEndDate, valueOfActiveIsYes, startingDate, lastMonthEndDate, startingDate, lastMonthEndDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, lastMonthEndDate, lastMonthEndDate];

        datatable resultOfAllPatchesAtThePatchQueue = dbConnection.select(GET_ALL_PATCHES_FOR_QUEUED_AGE_GRAPH_GIVEN_TIME_GAP, params);
        var fetchMonthData, _ = <json>resultOfAllPatchesAtThePatchQueue;

        int fetchLength = lengthof fetchMonthData;
        int loop2 = 0;

        //Check each patch and put each patch into appropriate date count bucket
        while (loop2 < fetchLength) {
            var reportD, _ = (string)fetchMonthData[loop2].REPORT_DATE;
            time:Time reportDate = time:parse(reportD + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            time:Time activeMonthEnd = time:parse(lastDateOfMonthArray[loop] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            int dayCount = (activeMonthEnd.time - reportDate.time) / MILI_SECONDS_PER_DAY;

            if (dayCount >= 90) {
                var val1, _ = (int)ageGroup[0][loop];
                ageGroup[0][loop] = val1 + 1;
            } else if (dayCount >= 60) {
                var val2, _ = (int)ageGroup[1][loop];
                ageGroup[1][loop] = val2 + 1;
            } else if (dayCount >= 30) {
                var val3, _ = (int)ageGroup[2][loop];
                ageGroup[2][loop] = val3 + 1;
            } else if (dayCount >= 14) {
                var val4, _ = (int)ageGroup[3][loop];
                ageGroup[3][loop] = val4 + 1;
            } else if (dayCount >= 7) {
                var val5, _ = (int)ageGroup[4][loop];
                ageGroup[4][loop] = val5 + 1;
            } else if (dayCount >= 0) {
                var val6, _ = (int)ageGroup[5][loop];
                ageGroup[5][loop] = val6 + 1;
            }

            loop2 = loop2 + 1;
        }

        loop = loop + 1;
    }

    logger:info("QUEUED AGE GRAPH DATA SENT");

    //close MYSQL client connector
    dbConnection.close();

    return ageGroup;
}

function ageDrillDownGraph (string group, string month) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    json fetchData = [];
    json fetchDrillDownData = [];
    int currentGroupIndex = 0;
    int[][] groupLimits = [[90, 60], [60, 30], [30, 14], [14, 7], [7, 0]];

    if (group == "60") {
        currentGroupIndex = 0;
    } else if (group == "30") {
        currentGroupIndex = 1;
    } else if (group == "14") {
        currentGroupIndex = 2;
    } else if (group == "7") {
        currentGroupIndex = 3;
    } else if (group == "0") {
        currentGroupIndex = 4;
    }

    //get product and version drill down to day count buckets
    //check selected area is Days>90 or not
    if (group != "90") {
        sql:Parameter[] params = [];
        sql:Parameter startingDate = {sqlType:"varchar", value:"2014-01-01"};
        sql:Parameter activeMonthEndDate = {sqlType:"varchar", value:month};
        sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
        sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
        sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
        sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
        sql:Parameter upperLimit = {sqlType:"varchar", value:groupLimits[currentGroupIndex][0]};
        sql:Parameter lowerLimit = {sqlType:"varchar", value:groupLimits[currentGroupIndex][1]};
        params = [startingDate, activeMonthEndDate, valueOfActiveIsNo, activeMonthEndDate, valueOfActiveIsYes, startingDate, activeMonthEndDate, startingDate, activeMonthEndDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, activeMonthEndDate, activeMonthEndDate, activeMonthEndDate, upperLimit, activeMonthEndDate, lowerLimit];

        datatable resultOfAllProductsNotMoreThanDayNinety = dbConnection.select(ALL_PRODUCTS_OF_NOT_MORE_THAN_90_DAYS_QUEUED, params);
        fetchData, _ = <json>resultOfAllProductsNotMoreThanDayNinety;


        datatable resultOfAllProductVersionsNotMoreThanDayNinety = dbConnection.select(ALL_PRODUCTS_VERSIONS_OF_NOT_MORE_THAN_90_DAYS_QUEUED, params);
        fetchDrillDownData, _ = <json>resultOfAllProductVersionsNotMoreThanDayNinety;
    } else {
        sql:Parameter[] params = [];
        sql:Parameter startingDate = {sqlType:"varchar", value:"2014-01-01"};
        sql:Parameter activeMonthEndDate = {sqlType:"varchar", value:month};
        sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
        sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
        sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
        sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
        sql:Parameter valueNinety = {sqlType:"varchar", value:"90"};
        params = [startingDate, activeMonthEndDate, valueOfActiveIsNo, activeMonthEndDate, valueOfActiveIsYes, startingDate, activeMonthEndDate, startingDate, activeMonthEndDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, activeMonthEndDate, activeMonthEndDate, activeMonthEndDate, valueNinety];

        datatable resultOfAllProductsMoreThanDayNinety = dbConnection.select(ALL_PRODUCTS_OF_MORE_THAN_90_DAYS_QUEUED, params);
        fetchData, _ = <json>resultOfAllProductsMoreThanDayNinety;


        datatable resultOfAllProductVersionsMoreThanDayNinety = dbConnection.select(ALL_PRODUCTS_VERSIONS_OF_MORE_THAN_90_DAYS_QUEUED, params);
        fetchDrillDownData, _ = <json>resultOfAllProductVersionsMoreThanDayNinety;
    }


    json mainArray = [];
    json drillDownArray = [];
    int loop = 0;
    int mainLength = lengthof fetchData;

    //create main product data set and version data JSONs
    while (loop < mainLength) {
        json dump = {name:"x", y:2016, drilldown:"y"};
        var patchCount, _ = (int)fetchData[loop].AGE;
        dump.y = patchCount;
        dump.name = fetchData[loop].PRODUCT_NAME;
        dump.drilldown = fetchData[loop].PRODUCT_NAME;

        mainArray[loop] = dump;
        loop = loop + 1;
    }

    int mainArrayLength = lengthof mainArray;
    loop = 0;
    int loop2 = 0;
    int tempCount = 0;
    json versionData = [];

    //create version array
    while (loop < mainArrayLength) {
        var val, _ = (int)mainArray[loop].y;
        int midLength = val;
        tempCount = loop2;
        json temp = [];
        int indexOf = 0;
        int totalVersions = 0;
        while (loop2 < tempCount + midLength) {
            if (totalVersions != midLength) {
                json temp2 = [];
                var versionCount, castErr = (int)fetchDrillDownData[loop2].AGE;
                totalVersions = totalVersions + versionCount;
                var versionName, castErr = (string)fetchDrillDownData[loop2].PRODUCT_VERSION;
                temp2[0] = versionName;
                temp2[1] = versionCount;
                temp[indexOf] = temp2;
                indexOf = indexOf + 1;
                loop2 = loop2 + 1;
            } else {
                break;
            }

        }
        versionData[loop] = temp;
        loop = loop + 1;
    }

    loop = 0;
    while (loop < mainLength) {
        json temp = {name:"x", id:2016, data:"y"};
        temp.name = fetchData[loop].PRODUCT_NAME;
        temp.id = fetchData[loop].PRODUCT_NAME;
        temp.data = versionData[loop];
        drillDownArray[loop] = temp;
        loop = loop + 1;
    }

    json ageDrillDownGraphJSON = {"mainData":mainArray, "drillDown":drillDownArray};

    logger:info("QUEUED AGE GRAPH DRILL DOWN DATA SENT");

    //close MYSQL client connector
    dbConnection.close();

    return ageDrillDownGraphJSON;
}

function lifeCycleStackGraph (string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    logger:info("LIFE-CYCLE TAB SELECTED");

    string[] allStates = ["Queued", "PreQADevelopment", "Development", "ReadyForQA", "ReleasedNotInPublicSVN", "ReleasedNotAutomated", "Released", "Broken", "Regression"];
    json countsInStates = [0, 0, 0, 0, 0, 0, 0, 0, 0]; //showing patch count in each state
    json statesOfDuration = []; // including all states according to given time period
    json products = []; // including all products according to given time period
    json dayCountAndNumbersOfPatches = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]];
    json movementAverages = [[0, 0], [0, 0]]; //including data of average date of moving Queued->Development and Development->Released
    json statesIds = [[], [], [], [], [], [], [], [], []]; //Including patches ID and eID of each states
    json finalStatesCounts = []; //including states counts with products

    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};

    params = [startDate, endDate, valueOfActiveIsNo, endDate, valueOfActiveIsYes, startDate, endDate, startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate, startDate, endDate, startDate, endDate, startDate, endDate];

    datatable resultOfGetAllPatchesAccordingToGivenDateRange = dbConnection.select(GET_ALL_PATCH_DATA_IN_GIVEN_DATE_RANGE, params);
    var fetchAllPatchData, _ = <json>resultOfGetAllPatchesAccordingToGivenDateRange;

    datatable resultOfGetAllProductsAccordingToGivenDateRange = dbConnection.select(FETCH_ALL_PRODUCTS_FOR_LIFE_CYCLE_GIVEN_DATE_RANGE, params);
    var fetchAllProducts, _ = <json>resultOfGetAllProductsAccordingToGivenDateRange;

    int loop = 0;
    int loop2 = 0;
    int fetchProductLength = lengthof fetchAllProducts;
    int allStatesCount = lengthof allStates;

    //initialize finalStatesCount array with all products
    while (loop < allStatesCount) {
        json temp = [];
        loop2 = 0;
        while (loop2 < fetchProductLength) {
            temp[loop2] = 0;
            loop2 = loop2 + 1;
        }
        finalStatesCounts[loop] = temp;
        loop = loop + 1;
    }

    //get all products into products arrays
    loop = 0;
    while (loop < fetchProductLength) {
        var product, _ = (string)fetchAllProducts[loop].PRODUCT_NAME;
        products[loop] = product;
        loop = loop + 1;
    }

    //Decompose all patches into states,products and average counts
    loop = 0;
    loop2 = 0;
    int allPatchesLength = lengthof fetchAllPatchData;
    while (loop < fetchProductLength) {
        loop2 = 0;
        while (loop2 < allPatchesLength) {
            var product, _ = (string)products[loop];
            var getProduct, _ = (string)fetchAllPatchData[loop2].PRODUCT_NAME;
            if (product == getProduct) {
                time:Time durationLastDate = time:parse(end + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");

                time:Time regressionDateTime = null;
                time:Time brokenDateTime = null;
                time:Time releasedDateTime = null;
                time:Time rnaDateTime = null;
                time:Time rnipsDateTime = null;
                time:Time QADateTime = null;
                time:Time devDateTime = null;
                time:Time preQADateTime = null;

                string patchState = "";
                if (fetchAllPatchData[loop2].LC_STATE != null) {
                    var state, _ = (string)fetchAllPatchData[loop2].LC_STATE;
                    patchState = state;
                }

                //initialize values into Time variables
                if (fetchAllPatchData[loop2].REGRESSION_ON != null) {
                    var regressionDate, _ = (string)fetchAllPatchData[loop2].REGRESSION_ON;
                    string[] temp = strings:split(regressionDate, " ");
                    regressionDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop2].BROKEN_ON != null) {
                    var brokenDate, _ = (string)fetchAllPatchData[loop2].BROKEN_ON;
                    string[] temp = strings:split(brokenDate, " ");
                    brokenDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop2].RELEASED_ON != null) {
                    var releasedDate, _ = (string)fetchAllPatchData[loop2].RELEASED_ON;
                    string[] temp = strings:split(releasedDate, " ");
                    releasedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop2].RELEASED_NOT_AUTOMATED_ON != null) {
                    var rnaDate, _ = (string)fetchAllPatchData[loop2].RELEASED_NOT_AUTOMATED_ON;
                    string[] temp = strings:split(rnaDate, " ");
                    rnaDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop2].RELEASED_NOT_IN_PUBLIC_SVN_ON != null) {
                    var rnipsDate, _ = (string)fetchAllPatchData[loop2].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                    string[] temp = strings:split(rnipsDate, " ");
                    rnipsDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop2].QA_STARTED_ON != null) {
                    var QADate, _ = (string)fetchAllPatchData[loop2].QA_STARTED_ON;
                    string[] temp = strings:split(QADate, " ");
                    QADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop2].DEVELOPMENT_STARTED_ON != null) {
                    var devDate, _ = (string)fetchAllPatchData[loop2].DEVELOPMENT_STARTED_ON;
                    string[] temp = strings:split(devDate, " ");
                    devDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop2].PRE_QA_STARTED_ON != null) {
                    var preQADate, _ = (string)fetchAllPatchData[loop2].PRE_QA_STARTED_ON;
                    string[] temp = strings:split(preQADate, " ");
                    preQADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }

                //starting to devide patches in to states according to their timestamps in database
                if ((regressionDateTime != null && regressionDateTime.time <= durationLastDate.time && patchState == "Regression") || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Regression")) {
                    var sCount, _ = (int)countsInStates[8];
                    countsInStates[8] = sCount + 1; // increment regression state count
                    var count, _ = (int)finalStatesCounts[8][loop];
                    finalStatesCounts[8][loop] = count + 1; //increment regression count in finalStatesCount array
                    int currentStatesIdsIndex = lengthof statesIds[8];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[8][currentStatesIdsIndex] = temp; // ad ID and eID of patch in regression slot

                } else if (brokenDateTime != null && brokenDateTime.time <= durationLastDate.time && patchState == "Broken" || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Broken")) {
                    var sCount, _ = (int)countsInStates[7];
                    countsInStates[7] = sCount + 1; // increment Broken state count
                    var count, _ = (int)finalStatesCounts[7][loop];
                    finalStatesCounts[7][loop] = count + 1; //increment broken count in finalStatesCount array
                    int currentStatesIdsIndex = lengthof statesIds[7];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[7][currentStatesIdsIndex] = temp; // ad ID and eID of patch in broken slot

                } else if ((releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Released") || (rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && patchState == "Released") || (rnipsDateTime != null && rnipsDateTime.time <= durationLastDate.time && patchState == "Released")) {
                    var sCount, _ = (int)countsInStates[6];
                    countsInStates[6] = sCount + 1; //increment Released state count
                    var count, _ = (int)finalStatesCounts[6][loop];
                    finalStatesCounts[6][loop] = count + 1; //increment Released count in finalStatesCount array
                    int currentStatesIdsIndex = lengthof statesIds[6];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[6][currentStatesIdsIndex] = temp; // ad ID and eID of patch in Released slot

                } else if ((rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && (patchState == "ReleasedNotAutomated" || patchState == "Released")) || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "ReleasedNotAutomated") || (rnipsDateTime != null && rnipsDateTime.time <= durationLastDate.time && patchState == "ReleasedNotAutomated")) {
                    var sCount, _ = (int)countsInStates[5];
                    countsInStates[5] = sCount + 1;
                    var count, _ = (int)finalStatesCounts[5][loop];
                    finalStatesCounts[5][loop] = count + 1;
                    int currentStatesIdsIndex = lengthof statesIds[5];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[5][currentStatesIdsIndex] = temp;

                } else if ((rnipsDateTime != null && rnipsDateTime.time <= durationLastDate.time && (patchState == "ReleasedNotInPublicSVN" || patchState == "Released" || patchState == "ReleasedNotAutomated")) || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "ReleasedNotInPublicSVN") || (rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && patchState == "ReleasedNotInPublicSVN")) {
                    var sCount, _ = (int)countsInStates[4];
                    countsInStates[4] = sCount + 1;
                    var count, _ = (int)finalStatesCounts[4][loop];
                    finalStatesCounts[4][loop] = count + 1;
                    int currentStatesIdsIndex = lengthof statesIds[4];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[4][currentStatesIdsIndex] = temp;

                } else if (QADateTime != null && QADateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                    //system:println(fetchAllPatchData[loop2].ID);
                    var sCount, _ = (int)countsInStates[3];
                    countsInStates[3] = sCount + 1;
                    var count, _ = (int)finalStatesCounts[3][loop];
                    finalStatesCounts[3][loop] = count + 1;
                    int currentStatesIdsIndex = lengthof statesIds[3];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[3][currentStatesIdsIndex] = temp;

                } else if (devDateTime != null && devDateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                    //system:println(fetchAllPatchData[loop2].ID);
                    var sCount, _ = (int)countsInStates[2];
                    countsInStates[2] = sCount + 1;
                    var count, _ = (int)finalStatesCounts[2][loop];
                    finalStatesCounts[2][loop] = count + 1;
                    int currentStatesIdsIndex = lengthof statesIds[2];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[2][currentStatesIdsIndex] = temp;

                } else if (preQADateTime != null && preQADateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                    //system:println(fetchAllPatchData[loop2].ID);
                    var sCount, _ = (int)countsInStates[1];
                    countsInStates[1] = sCount + 1;
                    var count, _ = (int)finalStatesCounts[1][loop];
                    finalStatesCounts[1][loop] = count + 1;
                    int currentStatesIdsIndex = lengthof statesIds[1];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[1][currentStatesIdsIndex] = temp;

                } else if ((patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                    var sCount, _ = (int)countsInStates[0];
                    countsInStates[0] = sCount + 1;
                    var count, _ = (int)finalStatesCounts[0][loop];
                    finalStatesCounts[0][loop] = count + 1;
                    int currentStatesIdsIndex = lengthof statesIds[0];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop2].ID;
                    temp[1] = fetchAllPatchData[loop2].eID;
                    statesIds[0][currentStatesIdsIndex] = temp;
                }

            }
            loop2 = loop2 + 1;
        }

        loop = loop + 1;
    }

    //adding states to statesOfDuration array
    loop = 0;
    while (loop < allStatesCount) {
        statesOfDuration[loop] = allStates[loop];
        loop = loop + 1;
    }

    //calculate average count of move one state to another by using timestamps in database
    loop = 0;
    while (loop < allPatchesLength) {
        time:Time releasedDateTime = null;
        time:Time rnaDateTime = null;
        time:Time rnipsDateTime = null;
        time:Time QADateTime = null;
        time:Time devDateTime = null;
        time:Time preQADateTime = null;
        time:Time queuedDateTime = null;


        if (fetchAllPatchData[loop].RELEASED_ON != null) {
            var releasedDate, _ = (string)fetchAllPatchData[loop].RELEASED_ON;
            string[] temp = strings:split(releasedDate, " ");
            releasedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if (fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON != null) {
            var rnaDate, _ = (string)fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON;
            string[] temp = strings:split(rnaDate, " ");
            rnaDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if (fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON != null) {
            var rnipsDate, _ = (string)fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON;
            string[] temp = strings:split(rnipsDate, " ");
            rnipsDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if (fetchAllPatchData[loop].QA_STARTED_ON != null) {
            var QADate, _ = (string)fetchAllPatchData[loop].QA_STARTED_ON;
            string[] temp = strings:split(QADate, " ");
            QADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if (fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON != null) {
            var devDate, _ = (string)fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON;
            string[] temp = strings:split(devDate, " ");
            devDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if (fetchAllPatchData[loop].PRE_QA_STARTED_ON != null) {
            var preQADate, _ = (string)fetchAllPatchData[loop].PRE_QA_STARTED_ON;
            string[] temp = strings:split(preQADate, " ");
            preQADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if (fetchAllPatchData[loop].REPORT_DATE != null) {
            var qDate, _ = (string)fetchAllPatchData[loop].REPORT_DATE;
            string[] temp = strings:split(qDate, " ");
            queuedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }

        if (queuedDateTime != null && preQADateTime != null) {
            int dayCount = (preQADateTime.time - queuedDateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[0][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[0][1];
            var count3, _ = (int)movementAverages[0][0];
            var count4, _ = (int)movementAverages[0][1];
            dayCountAndNumbersOfPatches[0][0] = count1 + dayCount; // Adding day gap
            dayCountAndNumbersOfPatches[0][1] = count2 + 1; //increment patch count
            movementAverages[0][0] = count3 + dayCount;  // Adding day gap
            movementAverages[0][1] = count4 + 1;  //increment patch count
        }
        if (preQADateTime != null && devDateTime != null) {
            int dayCount = (devDateTime.time - preQADateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[1][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[1][1];
            dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[1][1] = count2 + 1;
        }
        if (queuedDateTime != null && preQADateTime == null && devDateTime != null) {
            int dayCount = (devDateTime.time - queuedDateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[1][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[1][1];
            var count3, _ = (int)movementAverages[0][0];
            var count4, _ = (int)movementAverages[0][1];
            dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[1][1] = count2 + 1;
            movementAverages[0][0] = count3 + dayCount;
            movementAverages[0][1] = count4 + 1;
        }
        if (QADateTime != null && devDateTime != null) {
            int dayCount = (QADateTime.time - devDateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[2][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[2][1];
            dayCountAndNumbersOfPatches[2][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[2][1] = count2 + 1;
        }
        if (QADateTime != null && rnipsDateTime != null) {
            int dayCount = (rnipsDateTime.time - QADateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[3][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[3][1];
            var count3, _ = (int)movementAverages[1][0];
            var count4, _ = (int)movementAverages[1][1];
            dayCountAndNumbersOfPatches[3][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[3][1] = count2 + 1;
            movementAverages[1][0] = count3 + dayCount;
            movementAverages[1][1] = count4 + 1;
        }
        if (rnipsDateTime != null && rnaDateTime != null) {
            int dayCount = (rnaDateTime.time - rnipsDateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[4][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[4][1];
            dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[4][1] = count2 + 1;
        }
        if (releasedDateTime != null && rnaDateTime != null) {
            int dayCount = (releasedDateTime.time - rnaDateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
            dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[5][1] = count2 + 1;
        }
        if (releasedDateTime != null && rnaDateTime == null && rnipsDateTime != null) {
            int dayCount = (releasedDateTime.time - rnipsDateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
            dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[5][1] = count2 + 1;
        }
        if (QADateTime != null && rnipsDateTime == null && rnaDateTime != null) {
            int dayCount = (rnaDateTime.time - QADateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[4][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[4][1];
            var count3, _ = (int)movementAverages[1][0];
            var count4, _ = (int)movementAverages[1][1];
            dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[4][1] = count2 + 1;
            movementAverages[1][0] = count3 + dayCount;
            movementAverages[1][1] = count4 + 1;
        }
        if (releasedDateTime != null && rnaDateTime == null && rnipsDateTime == null && QADateTime != null) {
            int dayCount = (releasedDateTime.time - QADateTime.time) / 86400000;
            var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
            var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
            var count3, _ = (int)movementAverages[1][0];
            var count4, _ = (int)movementAverages[1][1];
            dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            movementAverages[1][0] = count3 + dayCount;
            movementAverages[1][1] = count4 + 1;

        }
        loop = loop + 1;
    }


    json stackArray = {"category":statesOfDuration, "products":products, "counts":finalStatesCounts, "stateCounts":countsInStates, "patchDetails":fetchAllPatchData, "averageSummary":dayCountAndNumbersOfPatches, "mainSumamry":movementAverages, "statesIds":statesIds};

    logger:info("LIFE-CYCLE DATA SENT");

    //close MYSQL client connector
    dbConnection.close();

    return stackArray;
}

function stateTransitionGraphOfLifeCycle (string product, string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    json countsInStates = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    json dayCountAndNumbersOfPatches = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]];
    json movementAverages = [[0, 0], [0, 0]];
    json products = [];
    json fetchAllPatchData = [];
    json statesIds = [[], [], [], [], [], [], [], [], []];


    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter valueOfActiveIsYes = {sqlType:"varchar", value:"Yes"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"integer", value:0};
    sql:Parameter valueOfStatusIsOne = {sqlType:"integer", value:1};
    sql:Parameter givenProduct = {sqlType:"varchar", value:product};

    if (product == "all") {
        params = [startDate, endDate, valueOfActiveIsNo, endDate, valueOfActiveIsYes, startDate, endDate, startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate, startDate, endDate, startDate, endDate, startDate, endDate];

        datatable resultOfAllPatches = dbConnection.select(FETCH_ALL_PATCH_DATA_FOR_DROP_DOWN_SELECTION, params);
        fetchAllPatchData, _ = <json>resultOfAllPatches;

        datatable resultOfAllProducts = dbConnection.select(FETCH_ALL_PRODUCTS_DATA_FOR_DROP_DOWN_SELECTION, params);
        var fetchAllProducts, _ = <json>resultOfAllProducts;

        int loop = 0;
        int loop2 = 0;
        int fetchProductLength = lengthof fetchAllProducts;

        //values adding to products array
        loop = 0;
        while (loop < fetchProductLength) {
            var cproduct, _ = (string)fetchAllProducts[loop].PRODUCT_NAME;
            products[loop] = cproduct;
            loop = loop + 1;
        }

        loop = 0;
        loop2 = 0;

        //devide patches in to states and get counts and average days spent to state transition
        int allPatchesLength = lengthof fetchAllPatchData;
        while (loop < fetchProductLength) {
            loop2 = 0;
            while (loop2 < allPatchesLength) {
                var cproduct, _ = (string)products[loop];
                var getProduct, _ = (string)fetchAllPatchData[loop2].PRODUCT_NAME;

                if (cproduct == getProduct) {
                    time:Time durationLastDate = time:parse(end + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");

                    time:Time regressionDateTime = null;
                    time:Time brokenDateTime = null;
                    time:Time releasedDateTime = null;
                    time:Time rnaDateTime = null;
                    time:Time rnipsDateTime = null;
                    time:Time QADateTime = null;
                    time:Time devDateTime = null;
                    time:Time preQADateTime = null;

                    string patchState = "";
                    if (fetchAllPatchData[loop2].LC_STATE != null) {
                        var state, _ = (string)fetchAllPatchData[loop2].LC_STATE;
                        patchState = state;
                    }

                    if (fetchAllPatchData[loop2].REGRESSION_ON != null) {
                        var regressionDate, _ = (string)fetchAllPatchData[loop2].REGRESSION_ON;
                        string[] temp = strings:split(regressionDate, " ");
                        regressionDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if (fetchAllPatchData[loop2].BROKEN_ON != null) {
                        var brokenDate, _ = (string)fetchAllPatchData[loop2].BROKEN_ON;
                        string[] temp = strings:split(brokenDate, " ");
                        brokenDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if (fetchAllPatchData[loop2].RELEASED_ON != null) {
                        var releasedDate, _ = (string)fetchAllPatchData[loop2].RELEASED_ON;
                        string[] temp = strings:split(releasedDate, " ");
                        releasedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if (fetchAllPatchData[loop2].RELEASED_NOT_AUTOMATED_ON != null) {
                        var rnaDate, _ = (string)fetchAllPatchData[loop2].RELEASED_NOT_AUTOMATED_ON;
                        string[] temp = strings:split(rnaDate, " ");
                        rnaDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if (fetchAllPatchData[loop2].RELEASED_NOT_IN_PUBLIC_SVN_ON != null) {
                        var rnipsDate, _ = (string)fetchAllPatchData[loop2].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                        string[] temp = strings:split(rnipsDate, " ");
                        rnipsDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if (fetchAllPatchData[loop2].QA_STARTED_ON != null) {
                        var QADate, _ = (string)fetchAllPatchData[loop2].QA_STARTED_ON;
                        string[] temp = strings:split(QADate, " ");
                        QADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if (fetchAllPatchData[loop2].DEVELOPMENT_STARTED_ON != null) {
                        var devDate, _ = (string)fetchAllPatchData[loop2].DEVELOPMENT_STARTED_ON;
                        string[] temp = strings:split(devDate, " ");
                        devDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if (fetchAllPatchData[loop2].PRE_QA_STARTED_ON != null) {
                        var preQADate, _ = (string)fetchAllPatchData[loop2].PRE_QA_STARTED_ON;
                        string[] temp = strings:split(preQADate, " ");
                        preQADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }

                    //devide patches in to related state according t timestap in database
                    if ((regressionDateTime != null && regressionDateTime.time <= durationLastDate.time && patchState == "Regression") || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Regression")) {
                        var sCount, _ = (int)countsInStates[8];
                        countsInStates[8] = sCount + 1; // increment regression count
                        int currentStatesIdsIndex = lengthof statesIds[8];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[8][currentStatesIdsIndex] = temp; // adding ID and eID into stateId regression slot

                    } else if (brokenDateTime != null && brokenDateTime.time <= durationLastDate.time && patchState == "Broken" || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Broken")) {
                        var sCount, _ = (int)countsInStates[7];
                        countsInStates[7] = sCount + 1;
                        int currentStatesIdsIndex = lengthof statesIds[7];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[7][currentStatesIdsIndex] = temp;

                    } else if ((releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Released") || (rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && patchState == "Released")) {
                        var sCount, _ = (int)countsInStates[6];
                        countsInStates[6] = sCount + 1;
                        int currentStatesIdsIndex = lengthof statesIds[6];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[6][currentStatesIdsIndex] = temp;

                    } else if ((rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && (patchState == "ReleasedNotAutomated" || patchState == "Released")) || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "ReleasedNotAutomated") || (rnipsDateTime != null && rnipsDateTime.time <= durationLastDate.time && patchState == "ReleasedNotAutomated")) {
                        var sCount, _ = (int)countsInStates[5];
                        countsInStates[5] = sCount + 1;
                        int currentStatesIdsIndex = lengthof statesIds[5];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[5][currentStatesIdsIndex] = temp;

                    } else if ((rnipsDateTime != null && rnipsDateTime.time <= durationLastDate.time && (patchState == "ReleasedNotInPublicSVN" || patchState == "Released" || patchState == "ReleasedNotAutomated")) || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "ReleasedNotInPublicSVN") || (rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && patchState == "ReleasedNotInPublicSVN")) {
                        var sCount, _ = (int)countsInStates[4];
                        countsInStates[4] = sCount + 1;
                        int currentStatesIdsIndex = lengthof statesIds[4];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[4][currentStatesIdsIndex] = temp;

                    } else if (QADateTime != null && QADateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                        var sCount, _ = (int)countsInStates[3];
                        countsInStates[3] = sCount + 1;
                        int currentStatesIdsIndex = lengthof statesIds[3];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[3][currentStatesIdsIndex] = temp;

                    } else if (devDateTime != null && devDateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                        var sCount, _ = (int)countsInStates[2];
                        countsInStates[2] = sCount + 1;
                        int currentStatesIdsIndex = lengthof statesIds[2];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[2][currentStatesIdsIndex] = temp;

                    } else if (preQADateTime != null && preQADateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                        var sCount, _ = (int)countsInStates[1];
                        countsInStates[1] = sCount + 1;
                        int currentStatesIdsIndex = lengthof statesIds[1];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[1][currentStatesIdsIndex] = temp;

                    } else if ((patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                        var sCount, _ = (int)countsInStates[0];
                        countsInStates[0] = sCount + 1;
                        int currentStatesIdsIndex = lengthof statesIds[0];
                        json temp = [];
                        temp[0] = fetchAllPatchData[loop2].ID;
                        temp[1] = fetchAllPatchData[loop2].eID;
                        statesIds[0][currentStatesIdsIndex] = temp;

                    }

                }
                loop2 = loop2 + 1;
            }
            loop = loop + 1;
        }

        loop = 0;

        //get average count and movement average count of states
        while (loop < allPatchesLength) {
            time:Time releasedDateTime = null;
            time:Time rnaDateTime = null;
            time:Time rnipsDateTime = null;
            time:Time QADateTime = null;
            time:Time devDateTime = null;
            time:Time preQADateTime = null;
            time:Time queuedDateTime = null;

            if (fetchAllPatchData[loop].RELEASED_ON != null) {
                var releasedDate, _ = (string)fetchAllPatchData[loop].RELEASED_ON;
                string[] temp = strings:split(releasedDate, " ");
                releasedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON != null) {
                var rnaDate, _ = (string)fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON;
                string[] temp = strings:split(rnaDate, " ");
                rnaDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON != null) {
                var rnipsDate, _ = (string)fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                string[] temp = strings:split(rnipsDate, " ");
                rnipsDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].QA_STARTED_ON != null) {
                var QADate, _ = (string)fetchAllPatchData[loop].QA_STARTED_ON;
                string[] temp = strings:split(QADate, " ");
                QADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON != null) {
                var devDate, _ = (string)fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON;
                string[] temp = strings:split(devDate, " ");
                devDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].PRE_QA_STARTED_ON != null) {
                var preQADate, _ = (string)fetchAllPatchData[loop].PRE_QA_STARTED_ON;
                string[] temp = strings:split(preQADate, " ");
                preQADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].REPORT_DATE != null) {
                var qDate, _ = (string)fetchAllPatchData[loop].REPORT_DATE;
                string[] temp = strings:split(qDate, " ");
                queuedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }

            if (queuedDateTime != null && preQADateTime != null) {
                int dayCount = (preQADateTime.time - queuedDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[0][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[0][1];
                var count3, _ = (int)movementAverages[0][0];
                var count4, _ = (int)movementAverages[0][1];
                dayCountAndNumbersOfPatches[0][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[0][1] = count2 + 1;
                movementAverages[0][0] = count3 + dayCount;
                movementAverages[0][1] = count4 + 1;
            }
            if (preQADateTime != null && devDateTime != null) {
                int dayCount = (devDateTime.time - preQADateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[1][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[1][1];
                dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[1][1] = count2 + 1;
            }
            if (queuedDateTime != null && preQADateTime == null && devDateTime != null) {
                int dayCount = (devDateTime.time - queuedDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[1][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[1][1];
                var count3, _ = (int)movementAverages[0][0];
                var count4, _ = (int)movementAverages[0][1];
                dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[1][1] = count2 + 1;
                movementAverages[0][0] = count3 + dayCount;
                movementAverages[0][1] = count4 + 1;
            }
            if (QADateTime != null && devDateTime != null) {
                int dayCount = (QADateTime.time - devDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[2][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[2][1];
                dayCountAndNumbersOfPatches[2][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[2][1] = count2 + 1;
            }
            if (QADateTime != null && rnipsDateTime != null) {
                int dayCount = (rnipsDateTime.time - QADateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[3][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[3][1];
                var count3, _ = (int)movementAverages[1][0];
                var count4, _ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[3][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[3][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;
            }
            if (rnipsDateTime != null && rnaDateTime != null) {
                int dayCount = (rnaDateTime.time - rnipsDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[4][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[4][1];
                dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[4][1] = count2 + 1;
            }
            if (releasedDateTime != null && rnaDateTime != null) {
                int dayCount = (releasedDateTime.time - rnaDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
                dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            }
            if (releasedDateTime != null && rnaDateTime == null && rnipsDateTime != null) {
                int dayCount = (releasedDateTime.time - rnipsDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
                dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            }
            if (QADateTime != null && rnipsDateTime == null && rnaDateTime != null) {
                int dayCount = (rnaDateTime.time - QADateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[4][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[4][1];
                var count3, _ = (int)movementAverages[1][0];
                var count4, _ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[4][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;
            }
            if (releasedDateTime != null && rnaDateTime == null && rnipsDateTime == null && QADateTime != null) {
                int dayCount = (releasedDateTime.time - QADateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
                var count3, _ = (int)movementAverages[1][0];
                var count4, _ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[5][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;

            }
            loop = loop + 1;
        }


    } else {
        params = [startDate, endDate, valueOfActiveIsNo, endDate, valueOfActiveIsYes, startDate, endDate, startDate, endDate, valueOfActiveIsNo, valueOfStatusIsZero, valueOfActiveIsNo, valueOfStatusIsOne, endDate, endDate, startDate, endDate, startDate, endDate, startDate, endDate, givenProduct];

        datatable resultOfAllPatches = dbConnection.select(FETCH_REQUIRED_PRODUCT_PATCH_DATA_FOR_DROP_DOWN_SELECTION, params);
        fetchAllPatchData, _ = <json>resultOfAllPatches;

        int loop = 0;
        int allPatchesLength = lengthof fetchAllPatchData;
        while (loop < allPatchesLength) {
            var cproduct, _ = (string)product;
            var getProduct, _ = (string)fetchAllPatchData[loop].PRODUCT_NAME;

            if (cproduct == getProduct) {
                time:Time durationLastDate = time:parse(end + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");

                time:Time regressionDateTime = null;
                time:Time brokenDateTime = null;
                time:Time releasedDateTime = null;
                time:Time rnaDateTime = null;
                time:Time rnipsDateTime = null;
                time:Time QADateTime = null;
                time:Time devDateTime = null;
                time:Time preQADateTime = null;

                string patchState = "";
                if (fetchAllPatchData[loop].LC_STATE != null) {
                    var state, _ = (string)fetchAllPatchData[loop].LC_STATE;
                    patchState = state;
                }


                if (fetchAllPatchData[loop].REGRESSION_ON != null) {
                    var regressionDate, _ = (string)fetchAllPatchData[loop].REGRESSION_ON;
                    string[] temp = strings:split(regressionDate, " ");
                    regressionDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop].BROKEN_ON != null) {
                    var brokenDate, _ = (string)fetchAllPatchData[loop].BROKEN_ON;
                    string[] temp = strings:split(brokenDate, " ");
                    brokenDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop].RELEASED_ON != null) {
                    var releasedDate, _ = (string)fetchAllPatchData[loop].RELEASED_ON;
                    string[] temp = strings:split(releasedDate, " ");
                    releasedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON != null) {
                    var rnaDate, _ = (string)fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON;
                    string[] temp = strings:split(rnaDate, " ");
                    rnaDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON != null) {
                    var rnipsDate, _ = (string)fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                    string[] temp = strings:split(rnipsDate, " ");
                    rnipsDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop].QA_STARTED_ON != null) {
                    var QADate, _ = (string)fetchAllPatchData[loop].QA_STARTED_ON;
                    string[] temp = strings:split(QADate, " ");
                    QADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON != null) {
                    var devDate, _ = (string)fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON;
                    string[] temp = strings:split(devDate, " ");
                    devDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if (fetchAllPatchData[loop].PRE_QA_STARTED_ON != null) {
                    var preQADate, _ = (string)fetchAllPatchData[loop].PRE_QA_STARTED_ON;
                    string[] temp = strings:split(preQADate, " ");
                    preQADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }

                if ((regressionDateTime != null && regressionDateTime.time <= durationLastDate.time && patchState == "Regression") || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Regression")) {
                    var sCount, _ = (int)countsInStates[8];
                    countsInStates[8] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[8];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[8][currentStatesIdsIndex] = temp;

                } else if (brokenDateTime != null && brokenDateTime.time <= durationLastDate.time && patchState == "Broken" || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Broken")) {
                    var sCount, _ = (int)countsInStates[7];
                    countsInStates[7] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[7];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[7][currentStatesIdsIndex] = temp;

                } else if ((releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "Released") || (rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && patchState == "Released")) {
                    var sCount, _ = (int)countsInStates[6];
                    countsInStates[6] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[6];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[6][currentStatesIdsIndex] = temp;

                } else if ((rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && (patchState == "ReleasedNotAutomated" || patchState == "Released")) || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "ReleasedNotAutomated") || (rnipsDateTime != null && rnipsDateTime.time <= durationLastDate.time && patchState == "ReleasedNotAutomated")) {
                    var sCount, _ = (int)countsInStates[5];
                    countsInStates[5] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[5];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[5][currentStatesIdsIndex] = temp;

                } else if ((rnipsDateTime != null && rnipsDateTime.time <= durationLastDate.time && (patchState == "ReleasedNotInPublicSVN" || patchState == "Released" || patchState == "ReleasedNotAutomated")) || (releasedDateTime != null && releasedDateTime.time <= durationLastDate.time && patchState == "ReleasedNotInPublicSVN") || (rnaDateTime != null && rnaDateTime.time <= durationLastDate.time && patchState == "ReleasedNotInPublicSVN")) {
                    var sCount, _ = (int)countsInStates[4];
                    countsInStates[4] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[4];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[4][currentStatesIdsIndex] = temp;

                } else if (QADateTime != null && QADateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                    var sCount, _ = (int)countsInStates[3];
                    countsInStates[3] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[3];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[3][currentStatesIdsIndex] = temp;

                } else if (devDateTime != null && devDateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                    var sCount, _ = (int)countsInStates[2];
                    countsInStates[2] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[2];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[2][currentStatesIdsIndex] = temp;

                } else if (preQADateTime != null && preQADateTime.time <= durationLastDate.time && (patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                    var sCount, _ = (int)countsInStates[1];
                    countsInStates[1] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[1];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[1][currentStatesIdsIndex] = temp;

                } else if ((patchState != "OnHold" && patchState != "Broken" && patchState != "N/A")) {
                    var sCount, _ = (int)countsInStates[0];
                    countsInStates[0] = sCount + 1;
                    int currentStatesIdsIndex = lengthof statesIds[0];
                    json temp = [];
                    temp[0] = fetchAllPatchData[loop].ID;
                    temp[1] = fetchAllPatchData[loop].eID;
                    statesIds[0][currentStatesIdsIndex] = temp;

                }

            }
            loop = loop + 1;
        }

        loop = 0;
        while (loop < allPatchesLength) {

            time:Time releasedDateTime = null;
            time:Time rnaDateTime = null;
            time:Time rnipsDateTime = null;
            time:Time QADateTime = null;
            time:Time devDateTime = null;
            time:Time preQADateTime = null;
            time:Time queuedDateTime = null;


            if (fetchAllPatchData[loop].RELEASED_ON != null) {
                var releasedDate, _ = (string)fetchAllPatchData[loop].RELEASED_ON;
                string[] temp = strings:split(releasedDate, " ");
                releasedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON != null) {
                var rnaDate, _ = (string)fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON;
                string[] temp = strings:split(rnaDate, " ");
                rnaDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON != null) {
                var rnipsDate, _ = (string)fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                string[] temp = strings:split(rnipsDate, " ");
                rnipsDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].QA_STARTED_ON != null) {
                var QADate, _ = (string)fetchAllPatchData[loop].QA_STARTED_ON;
                string[] temp = strings:split(QADate, " ");
                QADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON != null) {
                var devDate, _ = (string)fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON;
                string[] temp = strings:split(devDate, " ");
                devDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].PRE_QA_STARTED_ON != null) {
                var preQADate, _ = (string)fetchAllPatchData[loop].PRE_QA_STARTED_ON;
                string[] temp = strings:split(preQADate, " ");
                preQADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if (fetchAllPatchData[loop].REPORT_DATE != null) {
                var qDate, _ = (string)fetchAllPatchData[loop].REPORT_DATE;
                string[] temp = strings:split(qDate, " ");
                queuedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }

            if (queuedDateTime != null && preQADateTime != null) {
                int dayCount = (preQADateTime.time - queuedDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[0][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[0][1];
                var count3, _ = (int)movementAverages[0][0];
                var count4, _ = (int)movementAverages[0][1];
                dayCountAndNumbersOfPatches[0][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[0][1] = count2 + 1;
                movementAverages[0][0] = count3 + dayCount;
                movementAverages[0][1] = count4 + 1;
            }
            if (preQADateTime != null && devDateTime != null) {
                int dayCount = (devDateTime.time - preQADateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[1][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[1][1];
                dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[1][1] = count2 + 1;
            }
            if (queuedDateTime != null && preQADateTime == null && devDateTime != null) {
                int dayCount = (devDateTime.time - queuedDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[1][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[1][1];
                var count3, _ = (int)movementAverages[0][0];
                var count4, _ = (int)movementAverages[0][1];
                dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[1][1] = count2 + 1;
                movementAverages[0][0] = count3 + dayCount;
                movementAverages[0][1] = count4 + 1;
            }
            if (QADateTime != null && devDateTime != null) {
                int dayCount = (QADateTime.time - devDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[2][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[2][1];
                dayCountAndNumbersOfPatches[2][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[2][1] = count2 + 1;
            }
            if (QADateTime != null && rnipsDateTime != null) {
                int dayCount = (rnipsDateTime.time - QADateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[3][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[3][1];
                var count3, _ = (int)movementAverages[1][0];
                var count4, _ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[3][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[3][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;
            }
            if (rnipsDateTime != null && rnaDateTime != null) {
                int dayCount = (rnaDateTime.time - rnipsDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[4][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[4][1];
                dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[4][1] = count2 + 1;
            }
            if (releasedDateTime != null && rnaDateTime != null) {
                int dayCount = (releasedDateTime.time - rnaDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
                dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            }
            if (releasedDateTime != null && rnaDateTime == null && rnipsDateTime != null) {
                int dayCount = (releasedDateTime.time - rnipsDateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
                dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            }
            if (QADateTime != null && rnipsDateTime == null && rnaDateTime != null) {
                int dayCount = (rnaDateTime.time - QADateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[4][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[4][1];
                var count3, _ = (int)movementAverages[1][0];
                var count4, _ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[4][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;
            }
            if (releasedDateTime != null && rnaDateTime == null && rnipsDateTime == null && QADateTime != null) {
                int dayCount = (releasedDateTime.time - QADateTime.time) / 86400000;
                var count1, _ = (int)dayCountAndNumbersOfPatches[5][0];
                var count2, _ = (int)dayCountAndNumbersOfPatches[5][1];
                var count3, _ = (int)movementAverages[1][0];
                var count4, _ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[5][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;

            }
            loop = loop + 1;
        }
    }

    json response = {"stateCounts":countsInStates, "averageDates":dayCountAndNumbersOfPatches, "patchDetails":fetchAllPatchData, "mainSumamry":movementAverages, "statesIds":statesIds};

    logger:info("SELECTED FIELD LIFE-CYCLE DATA SENT");

    //close MYSQL client connector
    dbConnection.close();

    return response;
}

function getSpecificPatchLifeCycle (string patchID, string eID) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();


    json fetchPatchData = [];
    json dayCountAndNumbersOfPatches = [0, 0, 0, 0, 0, 0];

    sql:Parameter[] params = [];
    sql:Parameter patchId = {sqlType:"varchar", value:patchID};
    sql:Parameter patchEID = {sqlType:"varchar", value:eID};


    if (eID != "0") {
        params = [patchId, patchEID];
        datatable resultOfPatchDetail = dbConnection.select(PATCH_DETAILS_OF_EID_NOT_EQUAL_TO_ZERO, params);
        fetchPatchData, _ = <json>resultOfPatchDetail;
    } else {
        params = [patchId];
        datatable resultOfPatchDetail = dbConnection.select(PATCH_DETAILS_OF_EID_EQUAL_TO_ZERO, params);
        fetchPatchData, _ = <json>resultOfPatchDetail;
    }


    time:Time releasedDateTime = null;
    time:Time rnaDateTime = null;
    time:Time rnipsDateTime = null;
    time:Time QADateTime = null;
    time:Time devDateTime = null;
    time:Time preQADateTime = null;
    time:Time queuedDateTime = null;

    //getting details and takes date count of selected patch
    if (fetchPatchData[0].RELEASED_ON != null) {
        var releasedDate, _ = (string)fetchPatchData[0].RELEASED_ON;
        string[] temp = strings:split(releasedDate, " ");
        releasedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if (fetchPatchData[0].RELEASED_NOT_AUTOMATED_ON != null) {
        var rnaDate, _ = (string)fetchPatchData[0].RELEASED_NOT_AUTOMATED_ON;
        string[] temp = strings:split(rnaDate, " ");
        rnaDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if (fetchPatchData[0].RELEASED_NOT_IN_PUBLIC_SVN_ON != null) {
        var rnipsDate, _ = (string)fetchPatchData[0].RELEASED_NOT_IN_PUBLIC_SVN_ON;
        string[] temp = strings:split(rnipsDate, " ");
        rnipsDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if (fetchPatchData[0].QA_STARTED_ON != null) {
        var QADate, _ = (string)fetchPatchData[0].QA_STARTED_ON;
        string[] temp = strings:split(QADate, " ");
        QADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if (fetchPatchData[0].DEVELOPMENT_STARTED_ON != null) {
        var devDate, _ = (string)fetchPatchData[0].DEVELOPMENT_STARTED_ON;
        string[] temp = strings:split(devDate, " ");
        devDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if (fetchPatchData[0].PRE_QA_STARTED_ON != null) {
        var preQADate, _ = (string)fetchPatchData[0].PRE_QA_STARTED_ON;
        string[] temp = strings:split(preQADate, " ");
        preQADateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if (fetchPatchData[0].REPORT_DATE != null) {
        var qDate, _ = (string)fetchPatchData[0].REPORT_DATE;
        string[] temp = strings:split(qDate, " ");
        queuedDateTime = time:parse(temp[0] + "T00:00:00.000-0000", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }

    if (queuedDateTime != null && preQADateTime != null) {
        int dayCount = (preQADateTime.time - queuedDateTime.time) / 86400000;
        var count1, _ = (int)dayCountAndNumbersOfPatches[0];
        dayCountAndNumbersOfPatches[0] = count1 + dayCount;
    }
    if (preQADateTime != null && devDateTime != null) {
        int dayCount = (devDateTime.time - preQADateTime.time) / 86400000;
        var count1, _ = (int)dayCountAndNumbersOfPatches[1];
        dayCountAndNumbersOfPatches[1] = count1 + dayCount;
    }
    if (queuedDateTime != null && preQADateTime == null && devDateTime != null) {
        int dayCount = (devDateTime.time - queuedDateTime.time) / 86400000;
        var count1, _ = (int)dayCountAndNumbersOfPatches[1];
        dayCountAndNumbersOfPatches[1] = count1 + dayCount;
    }
    if (QADateTime != null && devDateTime != null) {
        int dayCount = (QADateTime.time - devDateTime.time) / 86400000;
        var count1, _ = (int)dayCountAndNumbersOfPatches[2];
        dayCountAndNumbersOfPatches[2] = count1 + dayCount;
    }
    if (QADateTime != null && rnipsDateTime != null) {
        int dayCount = (rnipsDateTime.time - QADateTime.time) / 86400000;
        var count1, _ = (int)dayCountAndNumbersOfPatches[3];
        dayCountAndNumbersOfPatches[3] = count1 + dayCount;
    }
    if (rnipsDateTime != null && rnaDateTime != null) {
        int dayCount = (rnaDateTime.time - rnipsDateTime.time) / 86400000;
        var count1, _ = (int)dayCountAndNumbersOfPatches[4];
        dayCountAndNumbersOfPatches[4] = count1 + dayCount;
    }
    if (releasedDateTime != null && rnaDateTime == null && rnipsDateTime == null && QADateTime != null) {
        int dayCount = (releasedDateTime.time - QADateTime.time) / 86400000;
        var count1, _ = (int)dayCountAndNumbersOfPatches[5];
        dayCountAndNumbersOfPatches[5] = count1 + dayCount;
    }


    json response = {"dateCounts":dayCountAndNumbersOfPatches, "patchDetails":fetchPatchData};

    logger:info("SELECTED PATCH LIFE-CYCLE DATA SENT");

    //close MYSQL client connector
    dbConnection.close();

    return response;
}

function getFirstDateFromWeekNumber (string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    json weekFirstDate = {};
    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"varchar", value:start};
    sql:Parameter endDate = {sqlType:"varchar", value:end};
    params = [startDate, endDate];

    datatable resultOfReportedPatchWeekWiseFirstDate = dbConnection.select(GET_FIRST_DATE_OF_WEEK, params);
    weekFirstDate, _ = <json>resultOfReportedPatchWeekWiseFirstDate;

    logger:debug(weekFirstDate);

    //close MYSQL client connector
    dbConnection.close();

    return weekFirstDate;
}

function getReleaseFirstDateFromWeekNumber (string start, string end) (json) {
    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    json weekFirstDate = {};
    sql:Parameter[] params = [];
    sql:Parameter startDate = {sqlType:"varchar", value:start};
    sql:Parameter endDate = {sqlType:"varchar", value:end};
    params = [startDate, endDate, startDate, endDate, startDate, endDate];

    datatable resultOfReleasedPatchWeeklyWiseFirstDate = dbConnection.select(GET_RELEASED_WEEK_FIRST_DATE, params);
    weekFirstDate, _ = <json>resultOfReleasedPatchWeeklyWiseFirstDate;

    logger:debug(weekFirstDate);

    //close MYSQL client connector
    dbConnection.close();

    return weekFirstDate;
}

function getPatchComplexity(string start, string end)(json){
    logger:info("PATCH COMPLEXITY REQUESTED");

    //create MYSQL client connector
    sql:ClientConnector dbConnection = setDatabaseConfiguration();

    sql:Parameter[] params = [];
    sql:Parameter valueOfStatusIsOne = {sqlType:"varchar", value:"1"};
    sql:Parameter valueOfStatusIsZero = {sqlType:"varchar", value:"0"};
    sql:Parameter valueOfActiveIsNo = {sqlType:"varchar", value:"No"};
    sql:Parameter startDate = {sqlType:"date", value:start};
    sql:Parameter endDate = {sqlType:"date", value:end};

    json setOfPatchNames;

    //get in progress and completed PATCH_NAMES
    params = [startDate, endDate,valueOfActiveIsNo,valueOfStatusIsZero,valueOfActiveIsNo,valueOfStatusIsOne,endDate,endDate,valueOfStatusIsOne,valueOfActiveIsNo,startDate,endDate,startDate,endDate,startDate,endDate];
    datatable resultOfPatchNamesOfInProgressAndCompleted = dbConnection.select(GET_PATCH_NAMES_FOR_PATCH_COMPLEXITY, params);
    setOfPatchNames, _= <json>resultOfPatchNamesOfInProgressAndCompleted;

    logger:debug(setOfPatchNames); // not required, issue in ballerina

    //getting data of patch complexity accorifng to patch names from python script that host in wso2 servers
    logger:info("HTTP CLIENT CONNECTOR STARTED TO GET PATCH COMPLEXITY DATA");

    json patchComplexityData;

    try {
        if (http_Connector == null) {
            setHTTPConnector();
        }

        message request = {};
        message response = {};
        messages:setJsonPayload(request, setOfPatchNames);

        response = http_Connector.post(COMPLEXITY_DATA_PATH, request);

        patchComplexityData = messages:getJsonPayload(response);

    } catch (errors:Error err) {
        logger:error("HTTP CLIENT CONNECTOR - " + err.msg);
    }

    logger:info("PATCH COMPLEXITY DATA RECEIVED");

    logger:debug(patchComplexityData); // not required, issue in ballerina

    //close MYSQL client connector
    dbConnection.close();

    return patchComplexityData;
}

