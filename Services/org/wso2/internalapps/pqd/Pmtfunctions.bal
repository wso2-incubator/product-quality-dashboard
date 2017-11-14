package org.wso2.internalapps.pqd;

import ballerina.data.sql;
import ballerina.lang.system;
import ballerina.lang.messages;
import ballerina.lang.strings;
import ballerina.lang.time;
import org.wso2.ballerina.connectors.jira;

string filePath = "config.json";
string[] monthLimit = null;
string lastQueuedMonth = "";
sql:ClientConnector dbConnection = null;
jira:ClientConnector JIRA_Connector = null;
sql:Parameter[] params = [];
string[] months = ["January", "February", "March", "April", "May","June", "July", "August", "September", "October", "November","December"];



function dbConnectivity() {
    json configs = getConfigData(filePath);

    var dbHost,_ = (string)configs.PMT_JDBC.DB_HOST;
    var dbPort,_ = (int)configs.PMT_JDBC.DB_PORT;
    var dbName,_ = (string)configs.PMT_JDBC.DB_NAME;
    var dbUser,_ = (string)configs.PMT_JDBC.DB_USERNAME;
    var dbPassword,_ = (string)configs.PMT_JDBC.DB_PASSWORD;
    var dbPoolSize,_ = (int)configs.PMT_JDBC.MAXIMUM_POOL_SIZE;


    map props = {"jdbcUrl":"jdbc:mysql://" + dbHost + ":" + dbPort + "/"+dbName+"", "username":dbUser, "password":dbPassword,"maximumPoolSize":dbPoolSize};
    dbConnection = create sql:ClientConnector(props);
}

function jiraConnector(){
    json JIRAconfigs = getConfigData(filePath);
    var JIRA_BASE_URL,_ = (string)JIRAconfigs.SUPPORT_JIRA.BASE_URL;
    var JIRA_USERNAME,_ = (string)JIRAconfigs.SUPPORT_JIRA.USERNAME;
    var JIRA_PASSWORD,_ = (string)JIRAconfigs.SUPPORT_JIRA.PASSWORD;

    JIRA_Connector = create jira:ClientConnector(JIRA_BASE_URL,JIRA_USERNAME,JIRA_PASSWORD);
}

function loadDashboard(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }

    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"date", value:start};
    sql:Parameter p3 = {sqlType:"date", value:end};
    params = [p1,p2,p3];
    datatable dt = dbConnection.select("SELECT count(ACTIVE) as qtotal FROM PATCH_QUEUE WHERE ACTIVE =? AND REPORT_DATE >= ? AND REPORT_DATE <=?", params);
    var jsonResOfYetToStartCount, _ = <json>dt;

    sql:Parameter p4 = {sqlType:"varchar", value:"No"};
    sql:Parameter p5 = {sqlType:"date", value:start};
    sql:Parameter p6 = {sqlType:"date", value:end};
    params = [p4,p5,p6];
    datatable dt1 = dbConnection.select("
                select count(distinct(PATCH_ETA.PATCH_NAME)) as ctotal from PATCH_ETA join PATCH_QUEUE on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID where
                PATCH_QUEUE.ACTIVE=? AND
                PATCH_ETA.STATUS=1  AND PATCH_ETA.RELEASED_ON >= ? AND
                PATCH_ETA.RELEASED_ON <= ? AND (PATCH_ETA.LC_STATE IN ('ReleasedNotInPublicSVN','Released','ReleasedNotAutomated'))", params);
    var jsonResOfCompletedCount, _ = <json>dt1;

    sql:Parameter p7 = {sqlType:"varchar", value:"No"};
    sql:Parameter p8 = {sqlType:"integer", value:0};
    sql:Parameter p9 = {sqlType:"date", value:start};
    sql:Parameter p10 = {sqlType:"date", value:end};
    params = [p7,p8,p9,p10];
    datatable dt3 = dbConnection.select("
                select count(distinct(PATCH_ETA.PATCH_NAME)) as dtotal from PATCH_ETA join PATCH_QUEUE on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID where
                PATCH_QUEUE.ACTIVE=? AND PATCH_ETA.STATUS=?  AND PATCH_ETA.RELEASED_ON IS null AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ? AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','ReleasedNotInPublicSVN','ReleasedNotAutomated','N/A'))", params);
    var jsonResOfInProgressCount, _ = <json>dt3;

    sql:Parameter p11 = {sqlType:"varchar", value:"No"};
    sql:Parameter p12= {sqlType:"integer", value:0};
    sql:Parameter p13= {sqlType:"date", value:start};
    sql:Parameter p14 = {sqlType:"date", value:end};
    params = [p11,p12,p13,p14];
    datatable dt4 = dbConnection.select("
                SELECT COUNT(PATCH_ETA.PATCH_NAME) AS etotal FROM PATCH_ETA LEFT OUTER JOIN PATCH_QUEUE ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                WHERE PATCH_QUEUE.ACTIVE = ?  AND PATCH_ETA.RELEASED_ON IS null AND PATCH_ETA.STATUS = ? AND PATCH_ETA.WORST_CASE_ESTIMATE < CURDATE() AND PATCH_QUEUE.REPORT_DATE >= ?
                AND PATCH_QUEUE.REPORT_DATE <= ?  AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','ReleasedNotInPublicSVN','ReleasedNotAutomated','N/A'))", params);
    var jsonResOfOverETACount, _ = <json>dt4;

    sql:Parameter p15 = {sqlType:"varchar", value:""};
    sql:Parameter p16 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p17 = {sqlType:"varchar", value:"No"};
    params = [p15,p16,p17];
    datatable dt5 = dbConnection.select("select distinct(PRODUCT_NAME) as products from PATCH_QUEUE WHERE PRODUCT_NAME !=? AND (ACTIVE=? or ACTIVE=?) ORDER BY PRODUCT_NAME ASC", params);
    var jsonResOfProducts, _ = <json>dt5;


    params = [];
    datatable dt6 = dbConnection.select("select distinct(PRODUCT_VERSION) as VERSION, PRODUCT_NAME FROM PATCH_QUEUE ORDER BY PRODUCT_NAME ASC, PRODUCT_VERSION", params);
    var jsonResOfVersions, _ = <json>dt6;
    json drillDownMenu = {"allProducts":jsonResOfProducts,"allVersions":jsonResOfVersions};


    sql:Parameter p18 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p19 = {sqlType:"varchar", value:"No"};
    sql:Parameter p20 = {sqlType:"date", value:start};
    sql:Parameter p21 = {sqlType:"date", value:end};
    params = [p18,p19,p20,p21];
    datatable dt7 = dbConnection.select("SELECT count(PATCH_QUEUE.SUPPORT_JIRA) as total FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID  WHERE (PATCH_QUEUE.SUPPORT_JIRA NOT LIKE '%/DEVINTERNAL-%'
                                            AND PATCH_QUEUE.SUPPORT_JIRA NOT LIKE '%/SECURITYINTERNAL-%') AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?)
                                            AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A')) AND PATCH_QUEUE.REPORT_DATE >=? AND PATCH_QUEUE.REPORT_DATE <=?", params);
    var jsonResOfReactive, _ = <json>dt7;
    var reactiveCount,castErr = (int)jsonResOfReactive[0].total;


    sql:Parameter p22 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p23 = {sqlType:"varchar", value:"No"};
    sql:Parameter p24 = {sqlType:"date", value:start};
    sql:Parameter p25 = {sqlType:"date", value:end};
    params = [p22,p23,p24,p25];
    datatable dt8 = dbConnection.select("SELECT COUNT(SUPPORT_JIRA) as total FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID  WHERE SUPPORT_JIRA LIKE '%/DEVINTERNAL-%'
                                              AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?) AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A')) AND REPORT_DATE >= ? AND REPORT_DATE <= ?", params);
    var jsonResOfProactive, _ = <json>dt8;
    var proactiveCount,_ = (int)jsonResOfProactive[0].total;


    params = [p22,p23,p24,p25];
    datatable dt9 = dbConnection.select("SELECT distinct(SUPPORT_JIRA), count(SUPPORT_JIRA) as COUNT FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID  WHERE SUPPORT_JIRA LIKE '%/SECURITYINTERNAL-%'
                                              AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?) AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A')) AND REPORT_DATE >= ? AND REPORT_DATE <= ? group by SUPPORT_JIRA", params);
    var jsonResOfSecurityInternal, _ = <json>dt9;

    string securityInternal_ID = "";
    string[] idPool = [];
    int[] idCounts = [];
    int[] verifyActualId = [];
    int securityLength = lengthof jsonResOfSecurityInternal;
    int loop =0;
    int fetchPatchCount = 0;

    while(loop<securityLength){
        var supportUrl,_ =(string)jsonResOfSecurityInternal[loop].SUPPORT_JIRA;
        var supportUrlCount,_ =(int)jsonResOfSecurityInternal[loop].COUNT;
        string[] array = strings:split(supportUrl, "/");
        securityInternal_ID = securityInternal_ID + array[5]+",";
        fetchPatchCount = fetchPatchCount + supportUrlCount;
        idPool[loop] = array[5];
        idCounts[loop] = supportUrlCount;
        verifyActualId[loop] = 0;
        loop = loop + 1;
    }

    int unCategorizedCount = 0;
    system:println(reactiveCount);
    system:println(proactiveCount);
    int securityStringLength = strings:length(securityInternal_ID);
    string finalSecurityIds = "";

    if(securityStringLength>0){
        finalSecurityIds = strings:subString(securityInternal_ID, 0, securityStringLength-1);

        string[] startArray = strings:split(start, "-");
        string[] endArray = strings:split(end, "-");

        if(JIRA_Connector == null){
            jiraConnector();
        }

        json payload = {"jql":"created>='"+startArray[0]+"/"+startArray[1]+"/"+startArray[2]+" 00:00' and  created<='"+endArray[0]+"/"+endArray[1]+"/"+endArray[2]+" 23:59' AND issuekey in ("+finalSecurityIds+") AND labels in (CustFoundVuln,ExtFoundVuln,IntFoundVuln)"};
        message jiraResponse = jira:ClientConnector.searchJira(JIRA_Connector, payload);
        //system:println(jiraResponse);
        json jiraRecords = messages:getJsonPayload(jiraResponse);
        system:println(jiraRecords);
        var jiraFetchCount,_ = (int)jiraRecords.total;

        if(jiraFetchCount == 0){
            unCategorizedCount = fetchPatchCount - jiraFetchCount;
        }else{
            int issueLength = lengthof jiraRecords.issues;
            loop = 0;
            while(loop<securityLength){
                int loop2 = 0;
                var tempCount = 0;
                while(loop2<issueLength){
                    var id,_ = (string)jiraRecords.issues[loop2].key;
                    if(idPool[loop] == id){
                        tempCount = idCounts[loop];
                        verifyActualId[loop] = 1;

                        int loop3 = 0;
                        int labelInt = lengthof jiraRecords.issues[loop2].fields.labels;
                        while(loop3<labelInt){
                            var label,_ = (string)jiraRecords.issues[loop2].fields.labels[loop3];
                            if(label == "ExtFoundVuln" || label == "CustFoundVuln"){
                                system:println("Reactive");
                                reactiveCount = reactiveCount + tempCount;
                                break;
                            }else if(label == "IntFoundVuln"){
                                system:println("Proactive");
                                proactiveCount = proactiveCount + tempCount;
                                break;
                            }
                            loop3 = loop3 + 1;
                        }
                    }
                    loop2 = loop2 + 1;
                }
                loop =loop +1;
            }

            loop = 0;
            while(loop<securityLength){
                if(verifyActualId[loop] == 0){
                    unCategorizedCount = unCategorizedCount + idCounts[loop];
                }
                loop = loop + 1;
            }
        }
    }

    json loadCounts = {   "yetToStartCount":jsonResOfYetToStartCount[0].qtotal,
                          "inProgressCount":jsonResOfInProgressCount[0].dtotal,
                          "completedCount":jsonResOfCompletedCount[0].ctotal,
                          "ETACount":jsonResOfOverETACount[0].etotal,
                          "reactiveCount":reactiveCount,
                          "proactiveCount":proactiveCount,
                          "uncategorizedCount":unCategorizedCount,
                          "menuDetails":drillDownMenu
                      };

    return loadCounts;

}

function loadDashboardWithHistory(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }

    sql:Parameter[] params = [];

    sql:Parameter p15 = {sqlType:"varchar", value:""};
    sql:Parameter p16 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p17 = {sqlType:"varchar", value:"No"};
    params = [p15,p16,p17];
    datatable dt5 = dbConnection.select("select distinct(PRODUCT_NAME) as products from PATCH_QUEUE WHERE PRODUCT_NAME !=? AND (ACTIVE=? or ACTIVE=?) ORDER BY PRODUCT_NAME ASC", params);
    var jsonResOfProducts, _ = <json>dt5;


    params = [];
    datatable dt6 = dbConnection.select("select distinct(PRODUCT_VERSION) as VERSION, PRODUCT_NAME FROM PATCH_QUEUE ORDER BY PRODUCT_NAME ASC, PRODUCT_VERSION", params);
    var jsonResOfVersions, _ = <json>dt6;
    json drillDownMenu = {"allProducts":jsonResOfProducts,"allVersions":jsonResOfVersions};


    sql:Parameter p18 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p19 = {sqlType:"varchar", value:"No"};
    sql:Parameter p20 = {sqlType:"date", value:start};
    sql:Parameter p21 = {sqlType:"date", value:end};
    params = [p18,p19,p20,p21];
    datatable dt7 = dbConnection.select("SELECT count(PATCH_QUEUE.SUPPORT_JIRA) as total FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID  WHERE (PATCH_QUEUE.SUPPORT_JIRA NOT LIKE '%/DEVINTERNAL-%'
                                            AND PATCH_QUEUE.SUPPORT_JIRA NOT LIKE '%/SECURITYINTERNAL-%') AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?)
                                            AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A')) AND PATCH_QUEUE.REPORT_DATE >=? AND PATCH_QUEUE.REPORT_DATE <=?", params);
    var jsonResOfReactive, _ = <json>dt7;
    var reactiveCount,castErr = (int)jsonResOfReactive[0].total;


    sql:Parameter p22 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p23 = {sqlType:"varchar", value:"No"};
    sql:Parameter p24 = {sqlType:"date", value:start};
    sql:Parameter p25 = {sqlType:"date", value:end};
    params = [p22,p23,p24,p25];
    datatable dt8 = dbConnection.select("SELECT COUNT(SUPPORT_JIRA) as total FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID  WHERE SUPPORT_JIRA LIKE '%/DEVINTERNAL-%'
                                              AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?) AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A')) AND REPORT_DATE >= ? AND REPORT_DATE <= ?", params);
    var jsonResOfProactive, _ = <json>dt8;
    var proactiveCount,_ = (int)jsonResOfProactive[0].total;


    params = [p22,p23,p24,p25];
    datatable dt9 = dbConnection.select("SELECT distinct(SUPPORT_JIRA), count(SUPPORT_JIRA) as COUNT FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID  WHERE SUPPORT_JIRA LIKE '%/SECURITYINTERNAL-%'
                                              AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?) AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A')) AND REPORT_DATE >= ? AND REPORT_DATE <= ? group by SUPPORT_JIRA", params);
    var jsonResOfSecurityInternal, _ = <json>dt9;

    string securityInternal_ID = "";
    string[] idPool = [];
    int[] idCounts = [];
    int[] verifyActualId = [];
    int securityLength = lengthof jsonResOfSecurityInternal;
    int loop =0;
    int fetchPatchCount = 0;

    while(loop<securityLength){
        var supportUrl,_ =(string)jsonResOfSecurityInternal[loop].SUPPORT_JIRA;
        var supportUrlCount,_ =(int)jsonResOfSecurityInternal[loop].COUNT;
        string[] array = strings:split(supportUrl, "/");
        securityInternal_ID = securityInternal_ID + array[5]+",";
        fetchPatchCount = fetchPatchCount + supportUrlCount;
        idPool[loop] = array[5];
        idCounts[loop] = supportUrlCount;
        verifyActualId[loop] = 0;
        loop = loop + 1;
    }

    int unCategorizedCount = 0;
    system:println(reactiveCount);
    system:println(proactiveCount);
    int securityStringLength = strings:length(securityInternal_ID);
    string finalSecurityIds = "";

    if(securityStringLength>0){
        finalSecurityIds = strings:subString(securityInternal_ID, 0, securityStringLength-1);

        string[] startArray = strings:split(start, "-");
        string[] endArray = strings:split(end, "-");

        if(JIRA_Connector == null){
            jiraConnector();
        }

        json payload = {"jql":"created>='"+startArray[0]+"/"+startArray[1]+"/"+startArray[2]+" 00:00' and  created<='"+endArray[0]+"/"+endArray[1]+"/"+endArray[2]+" 23:59' AND issuekey in ("+finalSecurityIds+") AND labels in (CustFoundVuln,ExtFoundVuln,IntFoundVuln)"};
        message jiraResponse = jira:ClientConnector.searchJira(JIRA_Connector, payload);
        //system:println(jiraResponse);
        json jiraRecords = messages:getJsonPayload(jiraResponse);
        system:println(jiraRecords);
        var jiraFetchCount,_ = (int)jiraRecords.total;

        if(jiraFetchCount == 0){
            unCategorizedCount = fetchPatchCount - jiraFetchCount;
        }else{
            int issueLength = lengthof jiraRecords.issues;
            loop = 0;
            while(loop<securityLength){
                int loop2 = 0;
                var tempCount = 0;
                while(loop2<issueLength){
                    var id,_ = (string)jiraRecords.issues[loop2].key;
                    if(idPool[loop] == id){
                        tempCount = idCounts[loop];
                        verifyActualId[loop] = 1;

                        int loop3 = 0;
                        int labelInt = lengthof jiraRecords.issues[loop2].fields.labels;
                        while(loop3<labelInt){
                            var label,_ = (string)jiraRecords.issues[loop2].fields.labels[loop3];
                            if(label == "ExtFoundVuln" || label == "CustFoundVuln"){
                                system:println("Reactive");
                                reactiveCount = reactiveCount + tempCount;
                                break;
                            }else if(label == "IntFoundVuln"){
                                system:println("Proactive");
                                proactiveCount = proactiveCount + tempCount;
                                break;
                            }
                            loop3 = loop3 + 1;
                        }
                    }
                    loop2 = loop2 + 1;
                }
                loop =loop +1;
            }

            loop = 0;
            while(loop<securityLength){
                if(verifyActualId[loop] == 0){
                    unCategorizedCount = unCategorizedCount + idCounts[loop];
                }
                loop = loop + 1;
            }
        }
    }

    json loadCounts = {   "yetToStartCount":getYetToStartCount(start,end),
                          "inProgressCount":inProgressCount(start,end),
                          "completedCount":completedCount(start,end),
                          "ETACount":overETACount(start,end),
                          "reactiveCount":reactiveCount,
                          "proactiveCount":proactiveCount,
                          "uncategorizedCount":unCategorizedCount,
                          "menuDetails":drillDownMenu
                      };

    return loadCounts;

}

function getYetToStartCount(string start,string end)(int){

    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"date", value:start};
    sql:Parameter p2 = {sqlType:"date", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};

    params = [p1,p2,p3,p2,p4,p1,p2];
    datatable dt = dbConnection.select("select count(*) as qtotal  from (SELECT PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.LC_STATE
            FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
            AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
            UNION ALL select PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,null as DEVELOPMENT_STARTED_ON, null as LC_STATE FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t", params);
    var jsonResOfYetToStartCount, _ = <json>dt;
    system:println(jsonResOfYetToStartCount);
    var yetToStartCount,_ = (int)jsonResOfYetToStartCount[0].qtotal;
    return yetToStartCount;
}

function completedCount(string start,string end)(int){
    sql:Parameter[] params = [];

    sql:Parameter p4 = {sqlType:"varchar", value:"No"};
    sql:Parameter p5 = {sqlType:"date", value:start};
    sql:Parameter p6 = {sqlType:"date", value:end};
    params = [p4,p5,p6];
    datatable dt1 = dbConnection.select("
                select count(distinct(PATCH_ETA.PATCH_NAME)) as ctotal from PATCH_ETA join PATCH_QUEUE on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID where
                PATCH_QUEUE.ACTIVE=? AND
                PATCH_ETA.STATUS=1  AND PATCH_ETA.RELEASED_ON >= ? AND
                PATCH_ETA.RELEASED_ON <= ? AND (PATCH_ETA.LC_STATE IN ('ReleasedNotInPublicSVN','Released','ReleasedNotAutomated'))", params);
    var jsonResOfCompletedCount, _ = <json>dt1;
    var completeCount,_ = (int)jsonResOfCompletedCount[0].ctotal;
    return completeCount;
}

function inProgressCount(string start,string end)(int){
    sql:Parameter[] params = [];

    sql:Parameter p1 = {sqlType:"date", value:start};
    sql:Parameter p2 = {sqlType:"date", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"integer", value:0};
    sql:Parameter p5 = {sqlType:"integer", value:1};

    params = [p1,p2,p3,p4,p3,p5,p2,p2,p2,p2];
    datatable dt3 = dbConnection.select("select count(*) as devtotal from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))", params);
    var jsonResOfInProgressCount, _ = <json>dt3;
    var inProgressPatchCount,_ = (int)jsonResOfInProgressCount[0].devtotal;
    return inProgressPatchCount;
}

function overETACount(string start,string end)(int){
    sql:Parameter[] params = [];

    sql:Parameter p1 = {sqlType:"date", value:start};
    sql:Parameter p2 = {sqlType:"date", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"integer", value:0};
    sql:Parameter p5 = {sqlType:"integer", value:1};

    params = [p1,p2,p3,p4,p3,p5,p2,p2,p2,p2,p2];
    datatable dt3 = dbConnection.select("select count(*) as etatotal from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?))) AND PATCH_ETA.WORST_CASE_ESTIMATE<?", params);
    var jsonResOfOverETACount, _ = <json>dt3;
    var etaCount,_ = (int)jsonResOfOverETACount[0].etatotal;
    return etaCount;
}

function queuedDetails(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"date", value:start};
    sql:Parameter p2 = {sqlType:"date", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};
    params = [p1,p2,p3,p2,p4,p1,p2];
    datatable dt = dbConnection.select("select SUPPORT_JIRA,PRODUCT_NAME,PRODUCT_VERSION,CLIENT,REPORTER,ASSIGNED_TO,REPORT_DATE  from (SELECT SUPPORT_JIRA,PRODUCT_NAME,PRODUCT_VERSION,CLIENT,REPORTER,ASSIGNED_TO,REPORT_DATE
            FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
            AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
            UNION ALL select SUPPORT_JIRA,PRODUCT_NAME,PRODUCT_VERSION,CLIENT,REPORTER,ASSIGNED_TO,REPORT_DATE FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t", params);
    var jsonResOfQueueDetails, _ = <json>dt;
   
    return jsonResOfQueueDetails;
}

function devDetails(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"date", value:start};
    sql:Parameter p2 = {sqlType:"date", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"integer", value:0};
    sql:Parameter p5 = {sqlType:"integer", value:1};

    params = [p1,p2,p3,p4,p3,p5,p2,p2,p2,p2];
    datatable dt = dbConnection.select("select PATCH_QUEUE.SUPPORT_JIRA,PATCH_ETA.PATCH_NAME,PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.CLIENT,PATCH_ETA.DEVELOPED_BY,PATCH_QUEUE.ASSIGNED_TO,PATCH_QUEUE.REPORT_DATE,PATCH_ETA.WORST_CASE_ESTIMATE from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))", params);
    var jsonResOfDevDetails, _ = <json>dt;

    return jsonResOfDevDetails;
}

function completeDetails(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"1"};
    sql:Parameter p2 = {sqlType:"varchar", value:"No"};
    sql:Parameter p3 = {sqlType:"date", value:start};
    sql:Parameter p4 = {sqlType:"date", value:end};
    params = [p1,p2,p3,p4];
    datatable dt = dbConnection.select("select PATCH_QUEUE.SUPPORT_JIRA,PATCH_ETA.PATCH_NAME,PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.CLIENT,PATCH_ETA.DEVELOPED_BY,PATCH_QUEUE.ASSIGNED_TO,PATCH_QUEUE.REPORT_DATE from
                                            PATCH_ETA JOIN PATCH_QUEUE on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID WHERE PATCH_ETA.STATUS=? AND PATCH_QUEUE.ACTIVE=? AND
                                            PATCH_ETA.RELEASED_ON >= ? AND
                                            PATCH_ETA.RELEASED_ON <= ?", params);
    var jsonResOfCompleteDetails, _ = <json>dt;
   
    return jsonResOfCompleteDetails;
}

function menuBadgesCounts(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"date", value:start};
    sql:Parameter p2 = {sqlType:"date", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};

    params = [p1,p2,p3,p2,p4,p1,p2];
    datatable dt = dbConnection.select("select PRODUCT_NAME, SUM(total) as total from ( select total,PRODUCT_NAME  from (SELECT COUNT(PATCH_QUEUE.PRODUCT_NAME) as total,PATCH_QUEUE.PRODUCT_NAME
            FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
            AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')  group by PATCH_QUEUE.PRODUCT_NAME
            UNION ALL select COUNT(PATCH_QUEUE.PRODUCT_NAME) as total,PATCH_QUEUE.PRODUCT_NAME FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?  group by PATCH_QUEUE.PRODUCT_NAME) as t) as y group by PRODUCT_NAME", params);

    var jsonResOfQueuedCount, _ = <json>dt;

    sql:Parameter p01 = {sqlType:"date", value:start};
    sql:Parameter p02 = {sqlType:"date", value:end};
    sql:Parameter p03 = {sqlType:"varchar", value:"No"};
    sql:Parameter p04 = {sqlType:"integer", value:0};
    sql:Parameter p05 = {sqlType:"integer", value:1};

    params = [p01,p02,p03,p04,p03,p05,p02,p02,p02,p02,p02];
    datatable dt2 = dbConnection.select("SELECT COUNT(PATCH_QUEUE.PRODUCT_NAME) as total,PATCH_QUEUE.PRODUCT_NAME from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?))) AND PATCH_ETA.WORST_CASE_ESTIMATE< ? group by PATCH_QUEUE.PRODUCT_NAME", params);
    var jsonResOfETACounts, _ = <json>dt2;

    sql:Parameter pp1 = {sqlType:"date", value:start};
    sql:Parameter pp2 = {sqlType:"date", value:end};
    sql:Parameter pp3 = {sqlType:"varchar", value:"No"};
    sql:Parameter pp4 = {sqlType:"integer", value:0};
    sql:Parameter pp5 = {sqlType:"integer", value:1};

    params = [pp1,pp2,pp3,pp4,pp3,pp5,pp2,pp2,pp2,pp2];
    datatable dt3 = dbConnection.select("select COUNT(distinct(PATCH_ETA.PATCH_NAME)) as total,PATCH_QUEUE.PRODUCT_NAME from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?))) group by PATCH_QUEUE.PRODUCT_NAME", params);
    var jsonResOfDEVCounts, _ = <json>dt3;

    json menuBadgeCount = {"jsonResOfQueuedCount":jsonResOfQueuedCount,"jsonResOfETACounts":jsonResOfETACounts,"jsonResOfDEVCounts":jsonResOfDEVCounts};

    return menuBadgeCount;
}

function menuVersionBadgesCounts(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"date", value:start};
    sql:Parameter p2 = {sqlType:"date", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};

    params = [p1,p2,p3,p2,p4,p1,p2];
    datatable dt = dbConnection.select("select PRODUCT_NAME, SUM(total) as total,PRODUCT_VERSION from ( select total,PRODUCT_NAME,PRODUCT_VERSION  from (SELECT COUNT(PATCH_QUEUE.PRODUCT_NAME) as total,PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION
            FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
            AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')  group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION
            UNION ALL select COUNT(PATCH_QUEUE.PRODUCT_NAME) as total,PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?  group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION) as t) as y group by PRODUCT_NAME,PRODUCT_VERSION", params);

    var jsonResOfQueuedCount, _ = <json>dt;

    sql:Parameter p01 = {sqlType:"date", value:start};
    sql:Parameter p02 = {sqlType:"date", value:end};
    sql:Parameter p03 = {sqlType:"varchar", value:"No"};
    sql:Parameter p04 = {sqlType:"integer", value:0};
    sql:Parameter p05 = {sqlType:"integer", value:1};

    params = [p01,p02,p03,p04,p03,p05,p02,p02,p02,p02,p02];
    datatable dt2 = dbConnection.select("SELECT COUNT(PATCH_QUEUE.PRODUCT_NAME) as total,PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?))) AND PATCH_ETA.WORST_CASE_ESTIMATE< ? group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
    var jsonResOfETACounts, _ = <json>dt2;

    sql:Parameter pp1 = {sqlType:"date", value:start};
    sql:Parameter pp2 = {sqlType:"date", value:end};
    sql:Parameter pp3 = {sqlType:"varchar", value:"No"};
    sql:Parameter pp4 = {sqlType:"integer", value:0};
    sql:Parameter pp5 = {sqlType:"integer", value:1};

    params = [pp1,pp2,pp3,pp4,pp3,pp5,pp2,pp2,pp2,pp2];
    datatable dt3 = dbConnection.select("select COUNT(distinct(PATCH_ETA.PATCH_NAME)) as total,PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?))) group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
    var jsonResOfDEVCounts, _ = <json>dt3;

    json menuBadgeCount = {"jsonResOfQueuedCount":jsonResOfQueuedCount,"jsonResOfETACounts":jsonResOfETACounts,"jsonResOfDEVCounts":jsonResOfDEVCounts};

    return menuBadgeCount;
}

function reportedPatchGraph(string duration,string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"varchar", value:"No"};
    sql:Parameter p3 = {sqlType:"varchar", value:start};
    sql:Parameter p4 = {sqlType:"varchar", value:end};

    params = [p1,p2,p3,p4];
    boolean isEmpty = false;
    int jsonResOfReportedPatchesLength=0;
    int loop = 0;
    json reportedPatchDrillDown = [];
    json jsonResOfReportedPatches ={};
    json weekFirstDate ={};

    if(duration !="year" && duration !="quarter" && duration !="week"){
        datatable dt = dbConnection.select("SELECT count("+duration+"(PATCH_QUEUE.REPORT_DATE)) as COUNTS,"+duration+"(REPORT_DATE) as TYPE,MONTH(REPORT_DATE) AS MONTH,QUARTER(REPORT_DATE) AS QUARTER, YEAR(REPORT_DATE) AS YEAR
                                        FROM PATCH_QUEUE WHERE (PATCH_QUEUE.ACTIVE=? OR PATCH_QUEUE.ACTIVE=?) AND PATCH_QUEUE.REPORT_DATE >=?
                                        AND PATCH_QUEUE.REPORT_DATE <= ? GROUP BY "+duration+"(PATCH_QUEUE.REPORT_DATE),MONTH(REPORT_DATE),QUARTER(REPORT_DATE),YEAR(PATCH_QUEUE.REPORT_DATE)
                                        order by YEAR,MONTH,QUARTER,TYPE", params);
        jsonResOfReportedPatches, _ = <json>dt;

        jsonResOfReportedPatchesLength = lengthof jsonResOfReportedPatches;

        while(loop<jsonResOfReportedPatchesLength){
            sql:Parameter p5 = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].TYPE};
            sql:Parameter p6 = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].MONTH};
            sql:Parameter p7 = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].QUARTER};
            sql:Parameter p8 = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].YEAR};
            params = [p5,p6,p7,p8,p1,p2,p3,p4];
            datatable dt2 = dbConnection.select("SELECT COUNT(PATCH_QUEUE.PRODUCT_NAME) AS total, PATCH_QUEUE.PRODUCT_NAME FROM PATCH_QUEUE WHERE "+duration+"(PATCH_QUEUE.REPORT_DATE) = ?
                                            AND MONTH(PATCH_QUEUE.REPORT_DATE)= ? AND QUARTER(PATCH_QUEUE.REPORT_DATE)= ? AND YEAR(PATCH_QUEUE.REPORT_DATE)= ? AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?) AND
                                            PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
                                            GROUP BY PATCH_QUEUE.PRODUCT_NAME ORDER BY COUNT(PATCH_QUEUE.PRODUCT_NAME) DESC", params);
            reportedPatchDrillDown[loop],_ = <json>dt2;
            loop=loop+1;
        }


    }else{
        datatable dt = dbConnection.select("SELECT count("+duration+"(PATCH_QUEUE.REPORT_DATE)) as COUNTS,"+duration+"(REPORT_DATE) as TYPE, YEAR(REPORT_DATE) AS YEAR
                                        FROM PATCH_QUEUE WHERE (PATCH_QUEUE.ACTIVE=? OR PATCH_QUEUE.ACTIVE=?) AND PATCH_QUEUE.REPORT_DATE >=?
                                        AND PATCH_QUEUE.REPORT_DATE <= ? GROUP BY "+duration+"(PATCH_QUEUE.REPORT_DATE),YEAR(PATCH_QUEUE.REPORT_DATE)
                                        order by YEAR,TYPE", params);
        jsonResOfReportedPatches, _ = <json>dt;

        jsonResOfReportedPatchesLength = lengthof jsonResOfReportedPatches;


        while(loop<jsonResOfReportedPatchesLength){
            sql:Parameter p5 = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].TYPE};
            sql:Parameter p8 = {sqlType:"varchar", value:jsonResOfReportedPatches[loop].YEAR};
            params = [p5,p8,p1,p2,p3,p4];
            datatable dt2 = dbConnection.select("SELECT COUNT(PATCH_QUEUE.PRODUCT_NAME) AS total, PATCH_QUEUE.PRODUCT_NAME FROM PATCH_QUEUE WHERE "+duration+"(PATCH_QUEUE.REPORT_DATE) = ?
                                            AND YEAR(PATCH_QUEUE.REPORT_DATE)= ? AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?) AND
                                            PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
                                            GROUP BY PATCH_QUEUE.PRODUCT_NAME ORDER BY COUNT(PATCH_QUEUE.PRODUCT_NAME) DESC", params);
            reportedPatchDrillDown[loop],_ = <json>dt2;
            loop=loop+1;
        }

        if(duration == "week"){
            weekFirstDate = getFirstDateFromWeekNumber(start,end);
        }
    }


    if(jsonResOfReportedPatchesLength == 0){
        isEmpty = true;
    }

    json mainArray = [];
    loop = 0;
    system:println(weekFirstDate);
    while(loop<jsonResOfReportedPatchesLength){
        json dump={name:"x",y:2016,drilldown:"y"};
        dump.y = jsonResOfReportedPatches[loop].COUNTS;
        var patchCount, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
        if(duration == "month"){
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var patchName, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            dump.name = patchYear+"-"+months[patchName-1];
            dump.drilldown = patchYear+"-"+months[patchName-1];
        }else if(duration == "quarter"){
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var quarter, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            dump.name = patchYear+"-"+quarter;
            dump.drilldown = patchYear+"-"+quarter;
        }else if(duration == "day"){
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var patchMonth, castErr = (int)jsonResOfReportedPatches[loop].MONTH;
            var date, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            dump.name = patchYear+"-"+months[patchMonth-1]+"-"+date;
            dump.drilldown = patchYear+"-"+months[patchMonth-1]+"-"+date;
        }else if(duration == "week"){
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var week, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            var weekDate, castErr = (string)weekFirstDate[loop].FIRSTWEEK;
            dump.name = weekDate;
            dump.drilldown = weekDate;
        }else{
            dump.name = jsonResOfReportedPatches[loop].TYPE;
            dump.drilldown = jsonResOfReportedPatches[loop].TYPE;
        }
        mainArray[loop] = dump;
        loop = loop +1;
    }

    json chartData = [];
    int reportedPatchesDrillDownLength = lengthof reportedPatchDrillDown;
    loop = 0;

    while(loop<reportedPatchesDrillDownLength){
        json temps = [];
        int loop2 = 0;
        int index = 0;
        int innerElementLength = lengthof reportedPatchDrillDown[loop];
        while(loop2< innerElementLength){
            json temp = [];
            var patchCount , castErr = (int) reportedPatchDrillDown[loop][loop2].total;
            var patchName , castErr = (string) reportedPatchDrillDown[loop][loop2].PRODUCT_NAME;
            temp[0] = patchName;
            temp[1] = patchCount;
            temps[index] = temp;
            loop2 = loop2 +1;
            index = index +1;
        }
        chartData[loop] = temps;
        loop = loop +1;
    }

    json drillDown = [];
    loop =0;
    while(loop<jsonResOfReportedPatchesLength){
        json temp={name:"x",id:2016,data:"y"};
        if(duration == "month"){
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var patchName, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            temp.name = patchYear+"-"+months[patchName-1];
            temp.id = patchYear+"-"+months[patchName-1];
        }else if(duration == "quarter"){
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var quarter, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            temp.name = patchYear+"-"+quarter;
            temp.id = patchYear+"-"+quarter;
        }else if(duration == "day"){
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var patchMonth, castErr = (int)jsonResOfReportedPatches[loop].MONTH;
            var date, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            temp.name = patchYear+"-"+months[patchMonth-1]+"-"+date;
            temp.id = patchYear+"-"+months[patchMonth-1]+"-"+date;
        }else if(duration == "week"){
            var patchYear, castErr = (int)jsonResOfReportedPatches[loop].YEAR;
            var week, castErr = (int)jsonResOfReportedPatches[loop].TYPE;
            var weekDate, castErr = (string)weekFirstDate[loop].FIRSTWEEK;
            temp.name = weekDate;
            temp.id = weekDate;
        }else{
            temp.name = jsonResOfReportedPatches[loop].TYPE;
            temp.id = jsonResOfReportedPatches[loop].TYPE;
        }
        temp.data = chartData[loop];
        drillDown[loop] = temp;
        loop = loop +1;
    }

    json reportedPatches = {"isEmpty":isEmpty,"graphMainData":mainArray,"graphDrillDownData":drillDown};
   
    return reportedPatches;
}

function totalProductSummaryCounts(string product,string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"varchar", value:"No"};
    sql:Parameter p3 = {sqlType:"varchar", value:product};
    sql:Parameter p4 = {sqlType:"varchar", value:"Bug"};
    sql:Parameter p5 = {sqlType:"date", value:start};
    sql:Parameter p6 = {sqlType:"date", value:end};
    params = [p1,p2,p3,p4,p5,p6];
    datatable dt = dbConnection.select("SELECT count(ISSUE_TYPE) as bugs FROM PATCH_QUEUE WHERE (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?)
                                            AND PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.ISSUE_TYPE=? AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?", params);
    var jsonResOfBugCount, _ = <json>dt;

    sql:Parameter p00 = {sqlType:"varchar", value:product};
    sql:Parameter p01 = {sqlType:"date", value:start};
    sql:Parameter p02 = {sqlType:"date", value:end};
    sql:Parameter p03 = {sqlType:"varchar", value:"No"};
    sql:Parameter p04 = {sqlType:"varchar", value:"Yes"};

    params = [p00,p01,p02,p03,p02,p00,p04,p01,p02];
    datatable dt1 = dbConnection.select("select count(*) as total  from (SELECT PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.LC_STATE
            FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.PRODUCT_NAME=? AND  PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
            AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
            UNION ALL select PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,null as DEVELOPMENT_STARTED_ON, null as LC_STATE FROM PATCH_QUEUE WHERE  PATCH_QUEUE.PRODUCT_NAME=? AND  PATCH_QUEUE.ACTIVE = ?
            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t", params);
    var jsonResOfQueuedCounts, _ = <json>dt1;

    sql:Parameter p17 = {sqlType:"varchar", value:"1"};
    sql:Parameter p18 = {sqlType:"varchar", value:product};
    sql:Parameter p19 = {sqlType:"date", value:start};
    sql:Parameter p11 = {sqlType:"date", value:end};
    params = [p17,p18,p19,p11];
    datatable dt2 = dbConnection.select("select count(distinct(PATCH_ETA.PATCH_NAME)) as total from PATCH_ETA JOIN PATCH_QUEUE ON PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID
                                            where PATCH_ETA.STATUS=? AND PATCH_QUEUE.PRODUCT_NAME=? AND
                                            PATCH_ETA.RELEASED_ON >= ? AND
                                            PATCH_ETA.RELEASED_ON <= ?", params);
    var jsonResOfCompleteCounts, _ = <json>dt2;

    sql:Parameter p31 = {sqlType:"date", value:start};
    sql:Parameter p32 = {sqlType:"date", value:end};
    sql:Parameter p33 = {sqlType:"varchar", value:"No"};
    sql:Parameter p34 = {sqlType:"integer", value:0};
    sql:Parameter p35 = {sqlType:"integer", value:1};

    params = [p00,p31,p32,p33,p34,p33,p35,p32,p32,p32,p32];
    datatable dt3 = dbConnection.select("select count(*) as total from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))", params);
    var jsonResOfDevCounts, _ = <json>dt3;

    json totalProductSummaryCount = {"jsonResOfQueuedCounts":jsonResOfQueuedCounts,"jsonResOfDevCounts":jsonResOfDevCounts,"jsonResOfCompleteCounts":jsonResOfCompleteCounts,"jsonResOfBugCount":jsonResOfBugCount};
   
    return totalProductSummaryCount;
}

function productTotalReleaseTrend(string product,string duration,string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:product};
    sql:Parameter p2 = {sqlType:"varchar", value:"1"};
    sql:Parameter p3 = {sqlType:"varchar", value:start};
    sql:Parameter p4 = {sqlType:"varchar", value:end};

    params = [p1,p2,p3,p4];
    boolean isEmpty = false;
    int jsonResOfReleaseTrendLength=0;
    int loop = 0;
    json jsonResOfReleaseTrend ={};
    json weekFirstDate = {};

    if(duration !="year" && duration !="quarter" && duration !="week"){
        datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR, month(PATCH_ETA.RELEASED_ON) AS MONTH  FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON),month(PATCH_ETA.RELEASED_ON)
                                            order by year,month,type", params);
        jsonResOfReleaseTrend, _ = <json>dt;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;


    }else if(duration == "week"){
        datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR  FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON)
                                            order by year,type", params);
        jsonResOfReleaseTrend, _ = <json>dt;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        weekFirstDate = getReleaseFirstDateFromWeekNumber(start,end);
        system:println(jsonResOfReleaseTrend);

    }else{
        datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR
                                            FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON)
                                            order by year,type", params);
        jsonResOfReleaseTrend, _ = <json>dt;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

    }


    if(jsonResOfReleaseTrendLength == 0){
        isEmpty = true;
    }

    system:println(jsonResOfReleaseTrend);
    json mainArray = [];
    loop = 0;

    while(loop<jsonResOfReleaseTrendLength){
        json dump={name:"x",y:2016};
        dump.y = jsonResOfReleaseTrend[loop].total;
        var patchCount, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
        if(duration == "month"){
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var patchName, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear+"-"+months[patchName-1];
        }else if(duration == "quarter"){
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var quarter, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear+"-"+quarter;
        }else if(duration == "day"){
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var patchMonth, castErr = (int)jsonResOfReleaseTrend[loop].MONTH;
            var date, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear+"-"+months[patchMonth-1]+"-"+date;
        }else if(duration == "week"){
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var week, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            var weekDate, castErr = (string)weekFirstDate[loop].FIRSTWEEK;
            dump.name = weekDate;
        }else{
            dump.name = jsonResOfReleaseTrend[loop].TYPE;
        }
        mainArray[loop] = dump;
        loop = loop +1;
    }

    json reportedPatches = {"isEmpty":isEmpty,"totalReleaseTrend":mainArray};
   
    return reportedPatches;
}

function loadProductVersionCounts(string product,string version,string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p0 ={sqlType:"varchar", value:version};
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"varchar", value:"No"};
    sql:Parameter p3 = {sqlType:"varchar", value:product};
    sql:Parameter p4 = {sqlType:"varchar", value:"Bug"};
    sql:Parameter p5 = {sqlType:"date", value:start};
    sql:Parameter p6 = {sqlType:"date", value:end};
    params = [p1,p2,p3,p0,p4,p5,p6];
    datatable dt = dbConnection.select("SELECT count(ISSUE_TYPE) as bugs FROM PATCH_QUEUE WHERE (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?)
                                            AND PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.PRODUCT_VERSION=? AND PATCH_QUEUE.ISSUE_TYPE=? AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?", params);
    var jsonResOfBugCount, _ = <json>dt;

    sql:Parameter p00 = {sqlType:"varchar", value:product};
    sql:Parameter p01 = {sqlType:"date", value:start};
    sql:Parameter p02 = {sqlType:"date", value:end};
    sql:Parameter p03 = {sqlType:"varchar", value:"No"};
    sql:Parameter p04 = {sqlType:"varchar", value:"Yes"};

    params = [p00,p0,p01,p02,p03,p02,p00,p0,p04,p01,p02];
    datatable dt1 = dbConnection.select("select count(*) as total  from (SELECT PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.LC_STATE
            FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.PRODUCT_VERSION=? AND  PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
            AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
            UNION ALL select PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,null as DEVELOPMENT_STARTED_ON, null as LC_STATE FROM PATCH_QUEUE WHERE  PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.PRODUCT_VERSION=? AND  PATCH_QUEUE.ACTIVE = ?
            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t", params);
    var jsonResOfQueuedCounts, _ = <json>dt1;

    sql:Parameter p17 = {sqlType:"varchar", value:"1"};
    sql:Parameter p18 = {sqlType:"varchar", value:product};
    sql:Parameter p19 = {sqlType:"date", value:start};
    sql:Parameter p11 = {sqlType:"date", value:end};
    params = [p17,p18,p0,p19,p11];
    datatable dt2 = dbConnection.select("select count(distinct(PATCH_ETA.PATCH_NAME)) as total from PATCH_ETA JOIN PATCH_QUEUE ON PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID
                                            where PATCH_ETA.STATUS=? AND PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.PRODUCT_VERSION=? AND
                                            PATCH_ETA.RELEASED_ON >= ? AND
                                            PATCH_ETA.RELEASED_ON <= ?", params);
    var jsonResOfCompleteCounts, _ = <json>dt2;

    sql:Parameter p31 = {sqlType:"date", value:start};
    sql:Parameter p32 = {sqlType:"date", value:end};
    sql:Parameter p33 = {sqlType:"varchar", value:"No"};
    sql:Parameter p34 = {sqlType:"integer", value:0};
    sql:Parameter p35 = {sqlType:"integer", value:1};

    params = [p00,p0,p31,p32,p33,p34,p33,p35,p32,p32,p32,p32];
    datatable dt3 = dbConnection.select("select count(*) as total from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                    WHERE PATCH_QUEUE.PRODUCT_NAME=? AND  PATCH_QUEUE.PRODUCT_VERSION=? AND PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND ((PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL
                    AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                    OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                     (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))", params);
    var jsonResOfDevCounts, _ = <json>dt3;

    json versionProductSummaryCount = {"jsonResOfQueuedCounts":jsonResOfQueuedCounts,"jsonResOfDevCounts":jsonResOfDevCounts,"jsonResOfCompleteCounts":jsonResOfCompleteCounts,"jsonResOfBugCount":jsonResOfBugCount};
   
    return versionProductSummaryCount;
}

function productVersionReleaseTrend(string product,string version,string duration,string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p0 = {sqlType:"varchar", value:product};
    sql:Parameter p1 = {sqlType:"varchar", value:version};
    sql:Parameter p2 = {sqlType:"varchar", value:"1"};
    sql:Parameter p3 = {sqlType:"varchar", value:start};
    sql:Parameter p4 = {sqlType:"varchar", value:end};

    params = [p0,p1,p2,p3,p4];
    boolean isEmpty = false;
    int jsonResOfReleaseTrendLength=0;
    int loop = 0;
    json jsonResOfReleaseTrend ={};
    json weekFirstDate ={};

    if(duration !="year" && duration !="quarter" && duration !="week"){
        datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR, month(PATCH_ETA.RELEASED_ON) AS MONTH  FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON),month(PATCH_ETA.RELEASED_ON)
                                            order by year,month,type", params);
        jsonResOfReleaseTrend, _ = <json>dt;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;


    }else if(duration == "week"){
        datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON)
                                            order by year,type", params);
        jsonResOfReleaseTrend, _ = <json>dt;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        weekFirstDate = getReleaseFirstDateFromWeekNumber(start,end);
    }else{
        datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR
                                            FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON)
                                            order by year,type", params);
        jsonResOfReleaseTrend, _ = <json>dt;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

    }


    if(jsonResOfReleaseTrendLength == 0){
        isEmpty = true;
    }
    system:println(jsonResOfReleaseTrend);
    json mainArray = [];
    loop = 0;

    while(loop<jsonResOfReleaseTrendLength){
        json dump={name:"x",y:2016};
        dump.y = jsonResOfReleaseTrend[loop].total;
        var patchCount, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
        if(duration == "month"){
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var patchName, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear+"-"+months[patchName-1];
        }else if(duration == "quarter"){
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var quarter, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear+"-"+quarter;
        }else if(duration == "day"){
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var patchMonth, castErr = (int)jsonResOfReleaseTrend[loop].MONTH;
            var date, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            dump.name = patchYear+"-"+months[patchMonth-1]+"-"+date;
        }else if(duration == "week"){
            var patchYear, castErr = (int)jsonResOfReleaseTrend[loop].YEAR;
            var week, castErr = (int)jsonResOfReleaseTrend[loop].TYPE;
            var weekDate, castErr = (string)weekFirstDate[loop].FIRSTWEEK;
            dump.name = weekDate;
        }else{
            dump.name = jsonResOfReleaseTrend[loop].TYPE;
        }
        mainArray[loop] = dump;
        loop = loop +1;
    }

    json reportedPatches = {"isEmpty":isEmpty,"versionReleaseTrend":mainArray};
   
    return reportedPatches;
}

function allProductVersionReleaseTrend(string product,string version,string duration,string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    string[] versionArray = strings:split(version, "-");
    int versionLength = lengthof versionArray;
    sql:Parameter[] params = [];
    int loop = 0;
    boolean isEmpty = false;
    int jsonResOfReleaseTrendLength=0;
    json jsonResOfReleaseTrend =[];
    json weekFirstDate ={};

    while(loop < versionLength){
        sql:Parameter p0 = {sqlType:"varchar", value:product};
        sql:Parameter p1 = {sqlType:"varchar", value:versionArray[loop]};
        sql:Parameter p2 = {sqlType:"varchar", value:"1"};
        sql:Parameter p3 = {sqlType:"varchar", value:start};
        sql:Parameter p4 = {sqlType:"varchar", value:end};

        params = [p0,p1,p2,p3,p4];

        if(duration !="year" && duration !="quarter" && duration !="week"){
            datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR, month(PATCH_ETA.RELEASED_ON) AS MONTH  FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON),month(PATCH_ETA.RELEASED_ON)
                                            order by year,month,type", params);
            jsonResOfReleaseTrend[loop], _ = <json>dt;

        }else if(duration == "week"){
            datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR  FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON)
                                            order by year,type", params);
            jsonResOfReleaseTrend[loop], _ = <json>dt;

        }else{
            datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR
                                            FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON)
                                            order by year,type", params);
            jsonResOfReleaseTrend[loop], _ = <json>dt;

        }

        loop = loop +1;
    }

    jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;
    if(jsonResOfReleaseTrendLength == 0){
        isEmpty = true;
    }

    json reportedPatches = {"isEmpty":isEmpty,"versionReleaseTrend":jsonResOfReleaseTrend};
   
    return reportedPatches;
}

function allCategoryReleaseTrendGraph(string product,string duration,string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:product};
    sql:Parameter p2 = {sqlType:"varchar", value:"1"};
    sql:Parameter p3 = {sqlType:"date", value:start};
    sql:Parameter p4 = {sqlType:"date", value:end};
    params = [p1,p2,p3,p4];
    json jsonResOfcategory = {};

    if(duration !="year" && duration !="quarter" && duration != "week"){
        datatable dt = dbConnection.select("SELECT "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,YEAR(PATCH_ETA.RELEASED_ON) as YEAR,MONTH(PATCH_ETA.RELEASED_ON) as MONTH FROM
                                            PATCH_ETA RIGHT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.PRODUCT_NAME = ?
                                            AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=? GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),YEAR(PATCH_ETA.RELEASED_ON),
                                            MONTH(PATCH_ETA.RELEASED_ON) order by year,month,type", params);
        jsonResOfcategory, _ = <json>dt;

    }else if(duration == "week"){
        datatable dt = dbConnection.select("SELECT "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,YEAR(PATCH_ETA.RELEASED_ON) as YEAR FROM
                                            PATCH_ETA RIGHT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.PRODUCT_NAME = ?
                                            AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=? GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),YEAR(PATCH_ETA.RELEASED_ON)order by year,type", params);
        jsonResOfcategory, _ = <json>dt;

    }else{
        datatable dt = dbConnection.select("SELECT "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,YEAR(PATCH_ETA.RELEASED_ON) as YEAR FROM
                                            PATCH_ETA RIGHT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.PRODUCT_NAME = ?
                                            AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=? GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),
                                            YEAR(PATCH_ETA.RELEASED_ON) order by year,type", params);
        jsonResOfcategory, _ = <json>dt;

    }
   
    return jsonResOfcategory;
}

function queuedAgeGraphGenerator_OLD(string duration,string lastMonth)(json){

    if(dbConnection == null){
        dbConnectivity();
    }
    lastQueuedMonth = lastMonth;
    string[] monthLimit = strings:split(duration, ">");
    int monthLimitLength = lengthof monthLimit;
    int loop = 0;
    int loop2 = 0;
    json fetchData = [];

    sql:Parameter[] params = [];
    sql:Parameter p2 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"varchar", value:"0"};
    sql:Parameter p5 = {sqlType:"varchar", value:"1"};
    params = [p3,p4,p3,p5,p2];

    datatable dt = dbConnection.select("SELECT PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.ACTIVE,PATCH_ETA.STATUS,PATCH_ETA.RELEASED_ON,PATCH_ETA.LC_STATE FROM PATCH_QUEUE LEFT OUTER JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                        WHERE (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' ,'Released','ReleasedNotInPublicSVN', 'ReleasedNotAutomated','Broken', 'N/A'))
                                        OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_QUEUE.REPORT_DATE >= '2014-01-01' OR PATCH_ETA.RELEASED_ON >= '2014-01-01' OR PATCH_ETA.RELEASED_ON IS NULL) AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A'))
                                        UNION ALL
                                        SELECT
                                          PATCH_QUEUE.ID,
                                          PATCH_QUEUE.REPORT_DATE,
                                          PATCH_QUEUE.ACTIVE,
                                          NULL as STATUS,
                                          NULL as RELEASED_ON,
                                          NULL as LC_STATE
                                        FROM
                                          PATCH_QUEUE
                                        WHERE
                                          PATCH_QUEUE.ACTIVE = ?", params);
    fetchData, _ = <json>dt;

    int fetchLength = lengthof fetchData;
    json ageGroup = [[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0]];
    string date = "2016-09-12";
    //time:Time reportDate = time:parse(date,"yyyy-MM-dd");
    //system:println(reportDate);
    while(loop < fetchLength){
        var reportD,_ = (string)fetchData[loop].REPORT_DATE;
        var id,_ = (int)fetchData[loop].ID;
        time:Time reportDate = time:parse(reportD+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        time:Time releaseDate = null;

        if(fetchData[loop].RELEASED_ON != null){
            var rel,_ = (string)fetchData[loop].RELEASED_ON;
            string[] array = strings:split(rel, " ");
            string releaseD = array[0];
            releaseDate = time:parse(releaseD+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }

        loop2 =0;
        var ststus,_ = (int)fetchData[loop].STATUS;

        if(!(fetchData[loop].RELEASED_ON == null && ststus == 1)){
            while(loop2 < monthLimitLength){

                time:Time activeMonth = time:parse(monthLimit[loop2]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");

                if((reportDate.time <= activeMonth.time) && ((releaseDate == null || releaseDate.time >= activeMonth.time) )){
                    system:println("YES");
                    system:println(id);
                    int dayCount = (activeMonth.time - reportDate.time)/86400000;
                    system:println(dayCount);
                    if(dayCount >= 90){

                        var val1,_ = (int)ageGroup[0][loop2];
                        ageGroup[0][loop2] =  val1 + 1;
                    }else if(dayCount >=60){
                        var val2,_ = (int)ageGroup[1][loop2];
                        ageGroup[1][loop2] =  val2 + 1;
                    }else if(dayCount >=30){
                        var val3,_ = (int)ageGroup[2][loop2];
                        ageGroup[2][loop2] =  val3 + 1;
                    }else if(dayCount >=14){
                        var val4,_ = (int)ageGroup[3][loop2];
                        ageGroup[3][loop2] =  val4 + 1;
                    }else if(dayCount >=7){
                        var val5,_ = (int)ageGroup[4][loop2];
                        ageGroup[4][loop2] =  val5 + 1;
                    }else if(dayCount >= 0){

                        var val6,_ = (int)ageGroup[5][loop2];
                        ageGroup[5][loop2] = val6 + 1;
                    }
                }
                loop2 = loop2 +1;
            }
        }

        loop = loop +1;
    }

    system:println("DONE");

    //json reportedPatches = {"isEmpty":1,"versionReleaseTrend":2};
    //return fetchData;
   
    return ageGroup;
}

function queuedAgeGraphGenerator(string firstMonthDate,string lastMonthDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }

    string[] firstDateOfMonthArray = strings:split(firstMonthDate, ">");
    string[] lastDateOfMonthArray = strings:split(lastMonthDate, ">");
    system:println(firstDateOfMonthArray);
    system:println(lastDateOfMonthArray);
    int monthLimitLength = lengthof firstDateOfMonthArray;
    int loop = 0;
    json ageGroup = [[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0]];

    while(loop<monthLimitLength){
        sql:Parameter[] params = [];
        sql:Parameter p1 = {sqlType:"varchar", value:"2014-01-01"};
        sql:Parameter p2 = {sqlType:"varchar", value:lastDateOfMonthArray[loop]};
        sql:Parameter p3 = {sqlType:"varchar", value:"No"};
        sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};
        sql:Parameter p5 = {sqlType:"varchar", value:"0"};
        sql:Parameter p6 = {sqlType:"varchar", value:"1"};
        params = [p1,p2,p3,p2,p4,p1,p2,p1,p2,p3,p5,p3,p6,p2,p2,p2,p2];

        datatable dt = dbConnection.select("select REPORT_DATE  from (SELECT PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.LC_STATE FROM PATCH_QUEUE JOIN
            PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
            AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
            UNION ALL select PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,null as DEVELOPMENT_STARTED_ON, null as LC_STATE FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.REPORT_DATE from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
            WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
            (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
            PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
            OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
             (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))", params);
        var fetchMonthData,_ = <json>dt;

        int fetchLength = lengthof fetchMonthData;
        int loop2 = 0;

        while(loop2<fetchLength){
            var reportD,_ = (string)fetchMonthData[loop2].REPORT_DATE;
            time:Time reportDate = time:parse(reportD+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            time:Time activeMonthEnd = time:parse(lastDateOfMonthArray[loop]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            int dayCount = (activeMonthEnd.time - reportDate.time)/86400000;

            if(dayCount >= 90){
                var val1,_ = (int)ageGroup[0][loop];
                ageGroup[0][loop] =  val1 + 1;
            }else if(dayCount >=60){
                var val2,_ = (int)ageGroup[1][loop];
                ageGroup[1][loop] =  val2 + 1;
            }else if(dayCount >=30){
                var val3,_ = (int)ageGroup[2][loop];
                ageGroup[2][loop] =  val3 + 1;
            }else if(dayCount >=14){
                var val4,_ = (int)ageGroup[3][loop];
                ageGroup[3][loop] =  val4 + 1;
            }else if(dayCount >=7){
                var val5,_ = (int)ageGroup[4][loop];
                ageGroup[4][loop] =  val5 + 1;
            }else if(dayCount >= 0){
                var val6,_ = (int)ageGroup[5][loop];
                ageGroup[5][loop] = val6 + 1;
            }

            loop2 = loop2 + 1;
        }
        system:println(loop);
        loop = loop + 1;
    }
    system:println(ageGroup);
    return ageGroup;
}

function ageDrillDownGraph(string group,string month)(json){
    if(dbConnection == null){
        dbConnectivity();
    }

    json fetchData = [];
    json fetchDrillDownData = [];
    int currentGroupIndex = 0;
    int[][] groupLimits = [[90,60],[60,30],[30,14],[14,7],[7,0]];

    if(group == "60"){
        currentGroupIndex = 0;
    }else if(group == "30"){
        currentGroupIndex = 1;
    }else if(group == "14"){
        currentGroupIndex = 2;
    }else if(group == "7"){
        currentGroupIndex = 3;
    }else if(group == "0"){
        currentGroupIndex = 4;
    }
    system:println(month);

    if(group != "90"){
        sql:Parameter[] params = [];
        sql:Parameter p1 = {sqlType:"varchar", value:"2014-01-01"};
        sql:Parameter p2 = {sqlType:"varchar", value:month};
        sql:Parameter p3 = {sqlType:"varchar", value:"No"};
        sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};
        sql:Parameter p5 = {sqlType:"varchar", value:"0"};
        sql:Parameter p6 = {sqlType:"varchar", value:"1"};
        sql:Parameter p7 = {sqlType:"varchar", value:groupLimits[currentGroupIndex][0]};
        sql:Parameter p8 = {sqlType:"varchar", value:groupLimits[currentGroupIndex][1]};
        params = [p1,p2,p3,p2,p4,p1,p2,p1,p2,p3,p5,p3,p6,p2,p2,p2,p2,p2,p7,p2,p8];

        datatable dt = dbConnection.select("select PRODUCT_NAME,count(REPORT_DATE) as AGE from (select PRODUCT_NAME,REPORT_DATE  from (SELECT PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.LC_STATE FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
                AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,null as DEVELOPMENT_STARTED_ON, null as LC_STATE FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.REPORT_DATE from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))) as y where
                 datediff(?,REPORT_DATE) < ? and datediff(?,REPORT_DATE) >= ? group by PRODUCT_NAME", params);
        fetchData,_ = <json>dt;


        datatable dt2 = dbConnection.select("select PRODUCT_NAME,PRODUCT_VERSION,count(REPORT_DATE) as AGE from (select PRODUCT_NAME,PRODUCT_VERSION,REPORT_DATE  from (SELECT PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.LC_STATE FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
                AND (PATCH_QUEUE.ACTIVE =? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,null as DEVELOPMENT_STARTED_ON, null as LC_STATE FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.REPORT_DATE from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))) as y where
                 datediff(?,REPORT_DATE) < ? and datediff(?,REPORT_DATE) >= ? group by PRODUCT_NAME,PRODUCT_VERSION", params);
        fetchDrillDownData, _ = <json>dt2;
    }else{
        sql:Parameter[] params = [];
        sql:Parameter p1 = {sqlType:"varchar", value:"2014-01-01"};
        sql:Parameter p2 = {sqlType:"varchar", value:month};
        sql:Parameter p3 = {sqlType:"varchar", value:"No"};
        sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};
        sql:Parameter p5 = {sqlType:"varchar", value:"0"};
        sql:Parameter p6 = {sqlType:"varchar", value:"1"};
        sql:Parameter p8 = {sqlType:"varchar", value:"90"};
        params = [p1,p2,p3,p2,p4,p1,p2,p1,p2,p3,p5,p3,p6,p2,p2,p2,p2,p2,p8];

        datatable dt = dbConnection.select("select PRODUCT_NAME,count(REPORT_DATE) as AGE from (select PRODUCT_NAME,REPORT_DATE  from (SELECT PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.LC_STATE FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
                AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,null as DEVELOPMENT_STARTED_ON, null as LC_STATE FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.REPORT_DATE from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))) as y where
                 datediff(?,REPORT_DATE) >= ? group by PRODUCT_NAME", params);
        fetchData,_ = <json>dt;


        datatable dt2 = dbConnection.select("select PRODUCT_NAME,PRODUCT_VERSION,count(REPORT_DATE) as AGE from (select PRODUCT_NAME,PRODUCT_VERSION,REPORT_DATE  from (SELECT PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.LC_STATE FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?
                AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.ID,PATCH_QUEUE.REPORT_DATE, PATCH_QUEUE.ACTIVE,null as DEVELOPMENT_STARTED_ON, null as LC_STATE FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.REPORT_DATE from PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))) as y where
                datediff(?,REPORT_DATE) >= ? group by PRODUCT_NAME,PRODUCT_VERSION", params);
        fetchDrillDownData, _ = <json>dt2;
    }


    json mainArray = [];
    json drillDownArray = [];
    int loop = 0;
    int mainLength = lengthof fetchData;

    while(loop<mainLength){
        json dump={name:"x",y:2016,drilldown:"y"};
        var patchCount,_ = (int)fetchData[loop].AGE;
        dump.y = patchCount;
        dump.name = fetchData[loop].PRODUCT_NAME;
        dump.drilldown = fetchData[loop].PRODUCT_NAME;

        mainArray[loop] = dump;
        loop = loop +1;
    }

    int mainArrayLength = lengthof mainArray;
    loop = 0;
    int loop2 = 0;
    int tempCount =0;
    json versionData = [];

    while(loop<mainArrayLength){
        var val,_ = (int)mainArray[loop].y;
        int midLength = val;
        tempCount = loop2;
        json temp = [];
        int indexOf = 0;
        int totalVersions = 0;
        while(loop2<tempCount+midLength){
            if(totalVersions !=midLength){
                json temp2 = [];
                var versionCount , castErr = (int) fetchDrillDownData[loop2].AGE;
                totalVersions = totalVersions + versionCount;
                var versionName , castErr = (string) fetchDrillDownData[loop2].PRODUCT_VERSION;
                temp2[0] = versionName;
                temp2[1] = versionCount;
                temp[indexOf] = temp2;
                indexOf = indexOf + 1;
                loop2 = loop2 + 1;
            }else{
                break;
            }

        }
        versionData[loop] = temp;
        loop = loop + 1;
    }

    loop =0;
    while(loop<mainLength){
        json temp={name:"x",id:2016,data:"y"};
        temp.name = fetchData[loop].PRODUCT_NAME;
        temp.id = fetchData[loop].PRODUCT_NAME;
        temp.data = versionData[loop];
        drillDownArray[loop] = temp;
        loop = loop +1;
    }

    json ageDrillDownGraphJSON = {"mainData":mainArray,"drillDown":drillDownArray};
   
    return ageDrillDownGraphJSON;
}

function lifeCycleStackGraph_OLD(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    json states = [];
    json currentSnapShotOfStates = [];
    json currentSnapShotProducts = [];
    json feedProducts = [];
    json allStates = ["Queued"];

    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"No"};
    sql:Parameter p2 = {sqlType:"varchar", value:start};
    sql:Parameter p3 = {sqlType:"varchar", value:end};
    params = [p1,p2,p3];

    datatable dt = dbConnection.select("SELECT
                                            distinct(PATCH_ETA.LC_STATE) as STATES
                                        FROM
                                            PATCH_QUEUE
                                                JOIN
                                            PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                        WHERE
                                            PATCH_QUEUE.ACTIVE = ?
                                                AND PATCH_ETA.LC_STATE NOT IN ('N/A')
                                                AND (PATCH_QUEUE.REPORT_DATE >= ?
                                                AND PATCH_QUEUE.REPORT_DATE <= ?)
                                        ORDER BY PATCH_ETA.LC_STATE", params);
    states, _ = <json>dt;

    int loop = 1;
    int stateLength = lengthof states;
    while(loop<stateLength){
        var val,_ = (string)states[loop-1].STATES;
        allStates[loop] =val;
        loop = loop + 1;
    }
    //system:println(allStates);

    sql:Parameter p4 = {sqlType:"varchar", value:"No"};
    sql:Parameter p5 = {sqlType:"varchar", value:start};
    sql:Parameter p6 = {sqlType:"varchar", value:end};
    sql:Parameter p7 = {sqlType:"varchar", value:"Yes"};
    params = [p4,p5,p6,p7,p5,p6];

    datatable dt2 = dbConnection.select("SELECT DISTINCT (PATCH_ETA.LC_STATE) as state,COUNT(PATCH_ETA.LC_STATE) AS COUNT,PATCH_QUEUE.PRODUCT_NAME FROM PATCH_QUEUE
                                        JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.LC_STATE NOT IN ('N/A') AND (PATCH_QUEUE.REPORT_DATE >= ?
                                        AND PATCH_QUEUE.REPORT_DATE <= ?) GROUP BY PATCH_QUEUE.PRODUCT_NAME , state UNION ALL SELECT NULL as state,COUNT(PATCH_QUEUE.ACTIVE) AS COUNT,
                                        PATCH_QUEUE.PRODUCT_NAME FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE=? AND (PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?)
                                        GROUP BY PATCH_QUEUE.PRODUCT_NAME,state", params);
    currentSnapShotOfStates, _ = <json>dt2;

    sql:Parameter p8 = {sqlType:"varchar", value:"No"};
    sql:Parameter p10 = {sqlType:"varchar", value:start};
    sql:Parameter p11 = {sqlType:"varchar", value:end};
    sql:Parameter p9 = {sqlType:"varchar", value:"Yes"};
    params = [p8,p9,p10,p11];

    datatable dt3 = dbConnection.select("SELECT distinct(PATCH_QUEUE.PRODUCT_NAME) FROM PATCH_QUEUE
                                        LEFT OUTER JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?) AND (PATCH_ETA.LC_STATE NOT IN ('N/A')OR PATCH_ETA.LC_STATE IS NULL) AND (PATCH_QUEUE.REPORT_DATE >= ?
                                        AND PATCH_QUEUE.REPORT_DATE <= ?) GROUP BY PATCH_QUEUE.PRODUCT_NAME", params);
    currentSnapShotProducts, _ = <json>dt3;

    //system:println(currentSnapShotProducts);

    loop = 0;
    int loop2 =0;
    int loop3 =0;
    int allLength = lengthof currentSnapShotOfStates;
    int productLength = lengthof currentSnapShotProducts;
    int statesLength = lengthof allStates;

    json feedData = [];
    while(loop<statesLength){
        json temp = [];
        loop2 = 0;
        while(loop2<productLength){
            string flag = "false";
            loop3 = 0;
            while(loop3<allLength){
                var product,_ = (string)currentSnapShotProducts[loop2].PRODUCT_NAME;
                var product2,_ = (string)currentSnapShotOfStates[loop3].PRODUCT_NAME;
                var state2,_ = (string)allStates[loop];
                if(currentSnapShotOfStates[loop3].state == null){
                    if( state2== "Queued"){
                        if( product== product2){
                            temp[loop2] = currentSnapShotOfStates[loop3].COUNT;
                            flag = "true";
                        }
                    }
                }else{
                    var state,_ = (string)currentSnapShotOfStates[loop3].state;

                    if(state == state2){
                        if(product == product2){
                            temp[loop2] = currentSnapShotOfStates[loop3].COUNT;
                            flag = "true";
                        }
                    }
                }
                loop3 = loop3 +1;
            }
            if(flag == "false"){
                temp[loop2] = 0;
            }
            loop2 = loop2 + 1;
        }
        feedData[loop] = temp;
        loop = loop + 1;
        //system:println(feedData);
    }

    loop = 0;
    while(loop<productLength){
        var val,_ = (string)currentSnapShotProducts[loop].PRODUCT_NAME;
        feedProducts[loop] =val;
        loop = loop + 1;
    }
    //system:println(feedData);
    json stackArray = {"category":allStates,"products":feedProducts,"counts":feedData};
   
    return stackArray;
}

function lifeCycleStackGraph(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    string[] allStates = ["Queued","PreQADevelopment","Development","ReadyForQA","ReleasedNotInPublicSVN","ReleasedNotAutomated","Released","Broken","Regression"];
    json countsInStates = [0,0,0,0,0,0,0,0,0];
    json statesOfDuration = [];
    json products = [];
    json dayCountAndNumbersOfPatches = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]];
    json movementAverages = [[0,0],[0,0]];

    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:start};
    sql:Parameter p2 = {sqlType:"varchar", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p5 = {sqlType:"varchar", value:"0"};
    sql:Parameter p6 = {sqlType:"varchar", value:"1"};
    params = [p1,p2,p3,p2,p4,p1,p2,p1,p2,p3,p5,p3,p6,p2,p2,p2,p2,p1,p2,p1,p2,p1,p2];

    datatable dt = dbConnection.select("select distinct(ID),eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON from(select ID,eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON  from
                (SELECT PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?
                AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.ID,null as eID,null as LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,null as PRE_QA_STARTED_ON,null as DEVELOPMENT_STARTED_ON,null as QA_STARTED_ON,null as RELEASED_NOT_IN_PUBLIC_SVN_ON,null as RELEASED_NOT_AUTOMATED_ON,null as RELEASED_ON,null as BROKEN_ON,null as REGRESSION_ON FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))
                 UNION all select PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE (PATCH_ETA.RELEASED_ON>=? AND PATCH_ETA.RELEASED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_AUTOMATED_ON>=? AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON>=? AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON<=?)) as x group by ID,eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON", params);
    var fetchAllPatchData,_ = <json>dt;

    datatable dt1 = dbConnection.select("select distinct(PRODUCT_NAME) FROM ( select REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON  from
                (SELECT PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?
                AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,null as PRE_QA_STARTED_ON,null as DEVELOPMENT_STARTED_ON,null as QA_STARTED_ON,null as RELEASED_NOT_IN_PUBLIC_SVN_ON,null as RELEASED_NOT_AUTOMATED_ON,null as RELEASED_ON,null as BROKEN_ON,null as REGRESSION_ON FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))
                 UNION all select PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE (PATCH_ETA.RELEASED_ON>=? AND PATCH_ETA.RELEASED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_AUTOMATED_ON>=? AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON>=? AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON<=?)) as z", params);
    var fetchAllProducts,_ = <json>dt1;

    int loop = 0;
    int loop2 = 0;
    int fetchProductLength = lengthof fetchAllProducts;
    int allStatesCount = lengthof allStates;
    json finalStatesCounts = [];

    while(loop<allStatesCount){
        json temp = [];
        loop2 = 0;
        while(loop2<fetchProductLength){
            temp[loop2] = 0;
            loop2 = loop2 + 1;
        }
        finalStatesCounts[loop] = temp;
        loop = loop + 1;
    }

    loop = 0;
    while(loop<fetchProductLength){
        var product,_ = (string)fetchAllProducts[loop].PRODUCT_NAME;
        products[loop] = product;
        loop = loop +1;
    }

    loop = 0;
    loop2 = 0;
    int allPatchesLength = lengthof fetchAllPatchData;
    while(loop<fetchProductLength){
        loop2 = 0;
        while(loop2<allPatchesLength){
            var product,_ = (string)products[loop];
            var getProduct,_ = (string)fetchAllPatchData[loop2].PRODUCT_NAME;
            if(product == getProduct){
                time:Time durationLastDate = time:parse(end+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");

                time:Time regressionDateTime = null;
                time:Time brokenDateTime = null;
                time:Time releasedDateTime = null;
                time:Time rnaDateTime = null;
                time:Time rnipsDateTime = null;
                time:Time QADateTime = null;
                time:Time devDateTime = null;
                time:Time preQADateTime = null;

                if(fetchAllPatchData[loop2].REGRESSION_ON != null){
                    var regressionDate,_ = (string)fetchAllPatchData[loop2].REGRESSION_ON;
                    string[] temp = strings:split(regressionDate, " ");
                    regressionDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop2].BROKEN_ON != null){
                    var brokenDate,_ = (string)fetchAllPatchData[loop2].BROKEN_ON;
                    string[] temp = strings:split(brokenDate, " ");
                    brokenDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop2].RELEASED_ON != null){
                    var releasedDate,_ = (string)fetchAllPatchData[loop2].RELEASED_ON;
                    string[] temp = strings:split(releasedDate, " ");
                    releasedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop2].RELEASED_NOT_AUTOMATED_ON != null){
                    var rnaDate,_ = (string)fetchAllPatchData[loop2].RELEASED_NOT_AUTOMATED_ON;
                    string[] temp = strings:split(rnaDate, " ");
                    rnaDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop2].RELEASED_NOT_IN_PUBLIC_SVN_ON != null){
                    var rnipsDate,_ = (string)fetchAllPatchData[loop2].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                    string[] temp = strings:split(rnipsDate, " ");
                    rnipsDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop2].QA_STARTED_ON != null){
                    var QADate,_ = (string)fetchAllPatchData[loop2].QA_STARTED_ON;
                    string[] temp = strings:split(QADate, " ");
                    QADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop2].DEVELOPMENT_STARTED_ON != null){
                    var devDate,_ = (string)fetchAllPatchData[loop2].DEVELOPMENT_STARTED_ON;
                    string[] temp = strings:split(devDate, " ");
                    devDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop2].PRE_QA_STARTED_ON != null){
                    var preQADate,_ = (string)fetchAllPatchData[loop2].PRE_QA_STARTED_ON;
                    string[] temp = strings:split(preQADate, " ");
                    preQADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }

                if(regressionDateTime != null && regressionDateTime.time<=durationLastDate.time){
                    var sCount,_ = (int)countsInStates[8];
                    countsInStates[8] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[8][loop];
                    finalStatesCounts[8][loop]= count + 1;
                }else if(brokenDateTime != null && brokenDateTime.time<=durationLastDate.time){
                    var sCount,_ = (int)countsInStates[7];
                    countsInStates[7] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[7][loop];
                    finalStatesCounts[7][loop] = count + 1;
                }else if(releasedDateTime != null && releasedDateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[6];
                    countsInStates[6] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[6][loop];
                    finalStatesCounts[6][loop] = count + 1;
                }else if(rnaDateTime != null && rnaDateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[5];
                    countsInStates[5] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[5][loop];
                    finalStatesCounts[5][loop] = count + 1;
                }else if(rnipsDateTime != null && rnipsDateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[4];
                    countsInStates[4] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[4][loop];
                    finalStatesCounts[4][loop] = count + 1;
                }else if(QADateTime != null && QADateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[3];
                    countsInStates[3] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[3][loop];
                    finalStatesCounts[3][loop] = count + 1;
                }else if(devDateTime != null && devDateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[2];
                    countsInStates[2] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[2][loop];
                    finalStatesCounts[2][loop] = count + 1;
                }else if(preQADateTime != null && preQADateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[2];
                    countsInStates[1] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[1][loop];
                    finalStatesCounts[1][loop] = count + 1;
                }else{
                    var sCount,_ = (int)countsInStates[0];
                    countsInStates[0] = sCount + 1;
                    var count,_ = (int)finalStatesCounts[0][loop];
                    finalStatesCounts[0][loop] = count + 1;
                }

            }
            loop2 = loop2 + 1;
        }

        loop = loop + 1;
    }

    loop = 0;
    while(loop<allStatesCount){
        statesOfDuration[loop] = allStates[loop];
        loop = loop + 1;
    }

    loop = 0;
    while(loop<allPatchesLength){
        time:Time releasedDateTime = null;
        time:Time rnaDateTime = null;
        time:Time rnipsDateTime = null;
        time:Time QADateTime = null;
        time:Time devDateTime = null;
        time:Time preQADateTime = null;
        time:Time queuedDateTime = null;


        if(fetchAllPatchData[loop].RELEASED_ON != null){
            var releasedDate,_ = (string)fetchAllPatchData[loop].RELEASED_ON;
            string[] temp = strings:split(releasedDate, " ");
            releasedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if(fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON != null){
            var rnaDate,_ = (string)fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON;
            string[] temp = strings:split(rnaDate, " ");
            rnaDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if(fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON != null){
            var rnipsDate,_ = (string)fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON;
            string[] temp = strings:split(rnipsDate, " ");
            rnipsDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if(fetchAllPatchData[loop].QA_STARTED_ON != null){
            var QADate,_ = (string)fetchAllPatchData[loop].QA_STARTED_ON;
            string[] temp = strings:split(QADate, " ");
            QADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if(fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON != null){
            var devDate,_ = (string)fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON;
            string[] temp = strings:split(devDate, " ");
            devDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if(fetchAllPatchData[loop].PRE_QA_STARTED_ON != null){
            var preQADate,_ = (string)fetchAllPatchData[loop].PRE_QA_STARTED_ON;
            string[] temp = strings:split(preQADate, " ");
            preQADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }
        if(fetchAllPatchData[loop].REPORT_DATE != null){
            var qDate,_ = (string)fetchAllPatchData[loop].REPORT_DATE;
            string[] temp = strings:split(qDate, " ");
            queuedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        }

        if(queuedDateTime!=null && preQADateTime!=null){
            int dayCount = (preQADateTime.time - queuedDateTime.time)/86400000;
            var count1,_ = (int)dayCountAndNumbersOfPatches[0][0];
            var count2,_ = (int)dayCountAndNumbersOfPatches[0][1];
            var count3,_ = (int)movementAverages[0][0];
            var count4,_ = (int)movementAverages[0][1];
            dayCountAndNumbersOfPatches[0][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[0][1] = count2 + 1;
            movementAverages[0][0] = count3 + dayCount;
            movementAverages[0][1] = count4 + 1;
        }
        if(preQADateTime!=null && devDateTime!=null){
            int dayCount = (devDateTime.time - preQADateTime.time)/86400000;
            var count1,_ = (int)dayCountAndNumbersOfPatches[1][0];
            var count2,_ = (int)dayCountAndNumbersOfPatches[1][1];
            dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[1][1] = count2 + 1;
        }
        if(queuedDateTime!=null && preQADateTime==null && devDateTime!=null){
            int dayCount = (devDateTime.time - queuedDateTime.time)/86400000;
            var count1,_ = (int)dayCountAndNumbersOfPatches[1][0];
            var count2,_ = (int)dayCountAndNumbersOfPatches[1][1];
            var count3,_ = (int)movementAverages[0][0];
            var count4,_ = (int)movementAverages[0][1];
            dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[1][1] = count2 + 1;
            movementAverages[0][0] = count3 + dayCount;
            movementAverages[0][1] = count4 + 1;
        }
        if(QADateTime!=null && devDateTime!=null){
            int dayCount = (QADateTime.time - devDateTime.time)/86400000;
            var count1,_ = (int)dayCountAndNumbersOfPatches[2][0];
            var count2,_ = (int)dayCountAndNumbersOfPatches[2][1];
            dayCountAndNumbersOfPatches[2][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[2][1] = count2 + 1;
        }
        if(QADateTime!=null && rnipsDateTime!=null){
            int dayCount = (rnipsDateTime.time - QADateTime.time)/86400000;
            var count1,_ = (int)dayCountAndNumbersOfPatches[3][0];
            var count2,_ = (int)dayCountAndNumbersOfPatches[3][1];
            var count3,_ = (int)movementAverages[1][0];
            var count4,_ = (int)movementAverages[1][1];
            dayCountAndNumbersOfPatches[3][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[3][1] = count2 + 1;
            movementAverages[1][0] = count3 + dayCount;
            movementAverages[1][1] = count4 + 1;
        }
        if(rnipsDateTime!=null && rnaDateTime!=null){
            int dayCount = (rnaDateTime.time - rnipsDateTime.time)/86400000;
            var count1,_ = (int)dayCountAndNumbersOfPatches[4][0];
            var count2,_ = (int)dayCountAndNumbersOfPatches[4][1];
            dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[4][1] = count2 + 1;
        }
        //if(releasedDateTime!=null && rnaDateTime!=null){
        //    int dayCount = (releasedDateTime.time - rnaDateTime.time)/86400000;
        //    var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
        //    var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
        //    dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
        //    dayCountAndNumbersOfPatches[5][1] = count2 + 1;
        //}
        //if(releasedDateTime!=null && rnaDateTime==null && rnipsDateTime!=null ){
        //    int dayCount = (releasedDateTime.time - rnipsDateTime.time)/86400000;
        //    var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
        //    var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
        //    dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
        //    dayCountAndNumbersOfPatches[5][1] = count2 + 1;
        //}
        if(QADateTime!=null && rnipsDateTime==null && rnaDateTime!=null){
            int dayCount = (rnaDateTime.time - QADateTime.time)/86400000;
            var count1,_ = (int)dayCountAndNumbersOfPatches[4][0];
            var count2,_ = (int)dayCountAndNumbersOfPatches[4][1];
            var count3,_ = (int)movementAverages[1][0];
            var count4,_ = (int)movementAverages[1][1];
            dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[4][1] = count2 + 1;
            movementAverages[1][0] = count3 + dayCount;
            movementAverages[1][1] = count4 + 1;
        }
        if(releasedDateTime!=null && rnaDateTime==null && rnipsDateTime==null && QADateTime!=null ){
            int dayCount = (releasedDateTime.time - QADateTime.time)/86400000;
            var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
            var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
            var count3,_ = (int)movementAverages[1][0];
            var count4,_ = (int)movementAverages[1][1];
            dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
            dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            movementAverages[1][0] = count3 + dayCount;
            movementAverages[1][1] = count4 + 1;

        }
        loop = loop + 1;
    }

    //system:println(countsInStates);
    json stackArray = {"category":statesOfDuration,"products":products,"counts":finalStatesCounts,"stateCounts":countsInStates,"patchDetails":fetchAllPatchData,"averageSummary":dayCountAndNumbersOfPatches,"mainSumamry":movementAverages };
    return stackArray;
}

function getFirstDateFromWeekNumber(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    json weekFirstDate = {};
    sql:Parameter[] params = [];
    sql:Parameter p001 = {sqlType:"varchar", value:start};
    sql:Parameter p002 = {sqlType:"varchar", value:end};
    params = [p001,p002];
    datatable dt00 = dbConnection.select("select DATE_SUB(DATE_ADD(MAKEDATE((year(PATCH_QUEUE.REPORT_DATE)), 1), INTERVAL (week(PATCH_QUEUE.REPORT_DATE)) WEEK),
  INTERVAL WEEKDAY(DATE_ADD(MAKEDATE((year(PATCH_QUEUE.REPORT_DATE)), 1), INTERVAL (week(PATCH_QUEUE.REPORT_DATE)) WEEK)
) -1 DAY) as FIRSTWEEK FROM PATCH_QUEUE WHERE PATCH_QUEUE.REPORT_DATE >=? AND PATCH_QUEUE.REPORT_DATE <= ?  GROUP BY FIRSTWEEK", params);
    weekFirstDate, _ = <json>dt00;
   
    return weekFirstDate;
}

function getReleaseFirstDateFromWeekNumber(string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    json weekFirstDate = {};
    sql:Parameter[] params = [];
    sql:Parameter p001 = {sqlType:"varchar", value:start};
    sql:Parameter p002 = {sqlType:"varchar", value:end};
    params = [p001,p002];
    datatable dt00 = dbConnection.select("select DATE_SUB(DATE_ADD(MAKEDATE((year(PATCH_ETA.RELEASED_ON)), 1), INTERVAL (week(PATCH_ETA.RELEASED_ON)) WEEK),
  INTERVAL WEEKDAY(DATE_ADD(MAKEDATE((year(PATCH_ETA.RELEASED_ON)), 1), INTERVAL (week(PATCH_ETA.RELEASED_ON)) WEEK)
) -1 DAY) as FIRSTWEEK FROM PATCH_ETA WHERE PATCH_ETA.RELEASED_ON >=? AND PATCH_ETA.RELEASED_ON <= ?  GROUP BY FIRSTWEEK", params);
    weekFirstDate, _ = <json>dt00;
   
    return weekFirstDate;
}

function stateTransitionGraphOfLifeCycle(string product,string start,string end)(json){
    if(dbConnection == null){
        dbConnectivity();
    }

    json countsInStates = [0,0,0,0,0,0,0,0,0];
    json dayCountAndNumbersOfPatches = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]];
    json movementAverages = [[0,0],[0,0]];
    json products = [];
    json fetchAllPatchData = [];


    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:start};
    sql:Parameter p2 = {sqlType:"varchar", value:end};
    sql:Parameter p3 = {sqlType:"varchar", value:"No"};
    sql:Parameter p4 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p5 = {sqlType:"varchar", value:"0"};
    sql:Parameter p6 = {sqlType:"varchar", value:"1"};
    sql:Parameter p7 = {sqlType:"varchar", value:product};

    if(product == "all"){
        params = [p1,p2,p3,p2,p4,p1,p2,p1,p2,p3,p5,p3,p6,p2,p2,p2,p2,p1,p2,p1,p2,p1,p2];

        datatable dt = dbConnection.select("select distinct(ID),eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON from(select ID,eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON  from
                (SELECT PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?
                AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.ID,null as eID,null as LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,null as PRE_QA_STARTED_ON,null as DEVELOPMENT_STARTED_ON,null as QA_STARTED_ON,null as RELEASED_NOT_IN_PUBLIC_SVN_ON,null as RELEASED_NOT_AUTOMATED_ON,null as RELEASED_ON,null as BROKEN_ON,null as REGRESSION_ON FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))
                 UNION all select PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE (PATCH_ETA.RELEASED_ON>=? AND PATCH_ETA.RELEASED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_AUTOMATED_ON>=? AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON>=? AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON<=?))
                 as x group by ID,eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON", params);
        fetchAllPatchData,_ = <json>dt;

        datatable dt1 = dbConnection.select("select distinct(PRODUCT_NAME) FROM ( select REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON  from
                (SELECT PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?
                AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,null as PRE_QA_STARTED_ON,null as DEVELOPMENT_STARTED_ON,null as QA_STARTED_ON,null as RELEASED_NOT_IN_PUBLIC_SVN_ON,null as RELEASED_NOT_AUTOMATED_ON,null as RELEASED_ON,null as BROKEN_ON,null as REGRESSION_ON FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))
                 UNION all select PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE (PATCH_ETA.RELEASED_ON>=? AND PATCH_ETA.RELEASED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_AUTOMATED_ON>=? AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON>=? AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON<=?)) as z", params);
        var fetchAllProducts,_ = <json>dt1;

        int loop = 0;
        int loop2 = 0;
        int fetchProductLength = lengthof fetchAllProducts;

        loop = 0;
        while(loop<fetchProductLength){
            var cproduct,_ = (string)fetchAllProducts[loop].PRODUCT_NAME;
            products[loop] = cproduct;
            loop = loop +1;
        }

        loop = 0;
        loop2 = 0;

        int allPatchesLength = lengthof fetchAllPatchData;
        while(loop<fetchProductLength){
            loop2 = 0;
            while(loop2<allPatchesLength){
                var cproduct,_ = (string)products[loop];
                var getProduct,_ = (string)fetchAllPatchData[loop2].PRODUCT_NAME;

                if(cproduct == getProduct){
                    time:Time durationLastDate = time:parse(end+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");

                    time:Time regressionDateTime = null;
                    time:Time brokenDateTime = null;
                    time:Time releasedDateTime = null;
                    time:Time rnaDateTime = null;
                    time:Time rnipsDateTime = null;
                    time:Time QADateTime = null;
                    time:Time devDateTime = null;
                    time:Time preQADateTime = null;

                    if(fetchAllPatchData[loop2].REGRESSION_ON != null){
                        var regressionDate,_ = (string)fetchAllPatchData[loop2].REGRESSION_ON;
                        string[] temp = strings:split(regressionDate, " ");
                        regressionDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if(fetchAllPatchData[loop2].BROKEN_ON != null){
                        var brokenDate,_ = (string)fetchAllPatchData[loop2].BROKEN_ON;
                        string[] temp = strings:split(brokenDate, " ");
                        brokenDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if(fetchAllPatchData[loop2].RELEASED_ON != null){
                        var releasedDate,_ = (string)fetchAllPatchData[loop2].RELEASED_ON;
                        string[] temp = strings:split(releasedDate, " ");
                        releasedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if(fetchAllPatchData[loop2].RELEASED_NOT_AUTOMATED_ON != null){
                        var rnaDate,_ = (string)fetchAllPatchData[loop2].RELEASED_NOT_AUTOMATED_ON;
                        string[] temp = strings:split(rnaDate, " ");
                        rnaDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if(fetchAllPatchData[loop2].RELEASED_NOT_IN_PUBLIC_SVN_ON != null){
                        var rnipsDate,_ = (string)fetchAllPatchData[loop2].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                        string[] temp = strings:split(rnipsDate, " ");
                        rnipsDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if(fetchAllPatchData[loop2].QA_STARTED_ON != null){
                        var QADate,_ = (string)fetchAllPatchData[loop2].QA_STARTED_ON;
                        string[] temp = strings:split(QADate, " ");
                        QADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if(fetchAllPatchData[loop2].DEVELOPMENT_STARTED_ON != null){
                        var devDate,_ = (string)fetchAllPatchData[loop2].DEVELOPMENT_STARTED_ON;
                        string[] temp = strings:split(devDate, " ");
                        devDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }
                    if(fetchAllPatchData[loop2].PRE_QA_STARTED_ON != null){
                        var preQADate,_ = (string)fetchAllPatchData[loop2].PRE_QA_STARTED_ON;
                        string[] temp = strings:split(preQADate, " ");
                        preQADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                    }

                    if(regressionDateTime != null && regressionDateTime.time<=durationLastDate.time){
                        var sCount,_ = (int)countsInStates[8];
                        countsInStates[8] = sCount + 1;

                    }else if(brokenDateTime != null && brokenDateTime.time<=durationLastDate.time){
                        var sCount,_ = (int)countsInStates[7];
                        countsInStates[7] = sCount + 1;

                    }else if(releasedDateTime != null && releasedDateTime.time<=durationLastDate.time) {
                        var sCount,_ = (int)countsInStates[6];
                        countsInStates[6] = sCount + 1;

                    }else if(rnaDateTime != null && rnaDateTime.time<=durationLastDate.time) {
                        var sCount,_ = (int)countsInStates[5];
                        countsInStates[5] = sCount + 1;

                    }else if(rnipsDateTime != null && rnipsDateTime.time<=durationLastDate.time) {
                        var sCount,_ = (int)countsInStates[4];
                        countsInStates[4] = sCount + 1;

                    }else if(QADateTime != null && QADateTime.time<=durationLastDate.time) {
                        var sCount,_ = (int)countsInStates[3];
                        countsInStates[3] = sCount + 1;

                    }else if(devDateTime != null && devDateTime.time<=durationLastDate.time) {
                        var sCount,_ = (int)countsInStates[2];
                        countsInStates[2] = sCount + 1;

                    }else if(preQADateTime != null && preQADateTime.time<=durationLastDate.time) {
                        var sCount,_ = (int)countsInStates[2];
                        countsInStates[1] = sCount + 1;

                    }else{
                        var sCount,_ = (int)countsInStates[0];
                        countsInStates[0] = sCount + 1;

                    }

                }
                loop2 = loop2 + 1;
            }
            loop = loop + 1;
        }

        loop = 0;

        while(loop<allPatchesLength){

            time:Time releasedDateTime = null;
            time:Time rnaDateTime = null;
            time:Time rnipsDateTime = null;
            time:Time QADateTime = null;
            time:Time devDateTime = null;
            time:Time preQADateTime = null;
            time:Time queuedDateTime = null;


            if(fetchAllPatchData[loop].RELEASED_ON != null){
                var releasedDate,_ = (string)fetchAllPatchData[loop].RELEASED_ON;
                string[] temp = strings:split(releasedDate, " ");
                releasedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON != null){
                var rnaDate,_ = (string)fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON;
                string[] temp = strings:split(rnaDate, " ");
                rnaDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON != null){
                var rnipsDate,_ = (string)fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                string[] temp = strings:split(rnipsDate, " ");
                rnipsDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].QA_STARTED_ON != null){
                var QADate,_ = (string)fetchAllPatchData[loop].QA_STARTED_ON;
                string[] temp = strings:split(QADate, " ");
                QADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON != null){
                var devDate,_ = (string)fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON;
                string[] temp = strings:split(devDate, " ");
                devDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].PRE_QA_STARTED_ON != null){
                var preQADate,_ = (string)fetchAllPatchData[loop].PRE_QA_STARTED_ON;
                string[] temp = strings:split(preQADate, " ");
                preQADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].REPORT_DATE != null){
                var qDate,_ = (string)fetchAllPatchData[loop].REPORT_DATE;
                string[] temp = strings:split(qDate, " ");
                queuedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }

            if(queuedDateTime!=null && preQADateTime!=null){
                int dayCount = (preQADateTime.time - queuedDateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[0][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[0][1];
                var count3,_ = (int)movementAverages[0][0];
                var count4,_ = (int)movementAverages[0][1];
                dayCountAndNumbersOfPatches[0][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[0][1] = count2 + 1;
                movementAverages[0][0] = count3 + dayCount;
                movementAverages[0][1] = count4 + 1;
            }
            if(preQADateTime!=null && devDateTime!=null){
                int dayCount = (devDateTime.time - preQADateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[1][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[1][1];
                dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[1][1] = count2 + 1;
            }
            if(queuedDateTime!=null && preQADateTime==null && devDateTime!=null){
                int dayCount = (devDateTime.time - queuedDateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[1][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[1][1];
                var count3,_ = (int)movementAverages[0][0];
                var count4,_ = (int)movementAverages[0][1];
                dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[1][1] = count2 + 1;
                movementAverages[0][0] = count3 + dayCount;
                movementAverages[0][1] = count4 + 1;
            }
            if(QADateTime!=null && devDateTime!=null){
                int dayCount = (QADateTime.time - devDateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[2][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[2][1];
                dayCountAndNumbersOfPatches[2][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[2][1] = count2 + 1;
            }
            if(QADateTime!=null && rnipsDateTime!=null){
                int dayCount = (rnipsDateTime.time - QADateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[3][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[3][1];
                var count3,_ = (int)movementAverages[1][0];
                var count4,_ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[3][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[3][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;
            }
            if(rnipsDateTime!=null && rnaDateTime!=null){
                int dayCount = (rnaDateTime.time - rnipsDateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[4][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[4][1];
                dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[4][1] = count2 + 1;
            }
            //if(releasedDateTime!=null && rnaDateTime!=null){
            //    int dayCount = (releasedDateTime.time - rnaDateTime.time)/86400000;
            //    var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
            //    var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
            //    dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
            //    dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            //}
            //if(releasedDateTime!=null && rnaDateTime==null && rnipsDateTime!=null ){
            //    int dayCount = (releasedDateTime.time - rnipsDateTime.time)/86400000;
            //    var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
            //    var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
            //    dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
            //    dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            //}
            if(QADateTime!=null && rnipsDateTime==null && rnaDateTime!=null){
                int dayCount = (rnaDateTime.time - QADateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[4][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[4][1];
                var count3,_ = (int)movementAverages[1][0];
                var count4,_ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[4][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;
            }
            if(releasedDateTime!=null && rnaDateTime==null && rnipsDateTime==null && QADateTime!=null ){
                int dayCount = (releasedDateTime.time - QADateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
                var count3,_ = (int)movementAverages[1][0];
                var count4,_ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[5][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;

            }
            loop = loop + 1;
        }


    }else{
        params = [p1,p2,p3,p2,p4,p1,p2,p1,p2,p3,p5,p3,p6,p2,p2,p2,p2,p1,p2,p1,p2,p1,p2,p7];

        datatable dt = dbConnection.select("select distinct(ID),eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON from(select ID,eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON  from
                (SELECT PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON FROM PATCH_QUEUE JOIN
                PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?
                AND (PATCH_QUEUE.ACTIVE = ? AND date(PATCH_ETA.DEVELOPMENT_STARTED_ON) > ?) AND  PATCH_ETA.LC_STATE NOT IN ('Broken','OnHold','N/A')
                UNION ALL select PATCH_QUEUE.ID,null as eID,null as LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,null as PRE_QA_STARTED_ON,null as DEVELOPMENT_STARTED_ON,null as QA_STARTED_ON,null as RELEASED_NOT_IN_PUBLIC_SVN_ON,null as RELEASED_NOT_AUTOMATED_ON,null as RELEASED_ON,null as BROKEN_ON,null as REGRESSION_ON FROM PATCH_QUEUE WHERE PATCH_QUEUE.ACTIVE = ?
                AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?) as t union all select PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.REPORT_DATE>=? AND PATCH_QUEUE.REPORT_DATE<=? AND (
                (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON IS NULL AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON IS NULL AND
                PATCH_ETA.LC_STATE NOT IN ('Broken','Released' ,'ReleasedNotInPublicSVN', 'ReleasedNotAutomated','OnHold','N/A'))
                OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS=? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A') AND PATCH_ETA.DEVELOPMENT_STARTED_ON < ? AND
                 (date(PATCH_ETA.RELEASED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_AUTOMATED_ON)>? OR date(PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON)>?)))
                 UNION all select PATCH_QUEUE.ID,PATCH_ETA.ID as eID,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON from
                 PATCH_QUEUE JOIN PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE (PATCH_ETA.RELEASED_ON>=? AND PATCH_ETA.RELEASED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_AUTOMATED_ON>=? AND PATCH_ETA.RELEASED_NOT_AUTOMATED_ON<=?) OR (PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON>=? AND PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON<=?))
                 as x WHERE PRODUCT_NAME = ?  group by ID,eID,LC_STATE,REPORT_DATE,PRODUCT_NAME,PRE_QA_STARTED_ON,DEVELOPMENT_STARTED_ON,QA_STARTED_ON,RELEASED_NOT_IN_PUBLIC_SVN_ON,RELEASED_NOT_AUTOMATED_ON,RELEASED_ON,BROKEN_ON,REGRESSION_ON", params);
        fetchAllPatchData,_ = <json>dt;

        int loop = 0;
        int allPatchesLength = lengthof fetchAllPatchData;
        while(loop<allPatchesLength){
            var cproduct,_ = (string)product;
            var getProduct,_ = (string)fetchAllPatchData[loop].PRODUCT_NAME;

            if(cproduct == getProduct){
                time:Time durationLastDate = time:parse(end+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");

                time:Time regressionDateTime = null;
                time:Time brokenDateTime = null;
                time:Time releasedDateTime = null;
                time:Time rnaDateTime = null;
                time:Time rnipsDateTime = null;
                time:Time QADateTime = null;
                time:Time devDateTime = null;
                time:Time preQADateTime = null;

                if(fetchAllPatchData[loop].REGRESSION_ON != null){
                    var regressionDate,_ = (string)fetchAllPatchData[loop].REGRESSION_ON;
                    string[] temp = strings:split(regressionDate, " ");
                    regressionDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop].BROKEN_ON != null){
                    var brokenDate,_ = (string)fetchAllPatchData[loop].BROKEN_ON;
                    string[] temp = strings:split(brokenDate, " ");
                    brokenDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop].RELEASED_ON != null){
                    var releasedDate,_ = (string)fetchAllPatchData[loop].RELEASED_ON;
                    string[] temp = strings:split(releasedDate, " ");
                    releasedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON != null){
                    var rnaDate,_ = (string)fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON;
                    string[] temp = strings:split(rnaDate, " ");
                    rnaDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON != null){
                    var rnipsDate,_ = (string)fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                    string[] temp = strings:split(rnipsDate, " ");
                    rnipsDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop].QA_STARTED_ON != null){
                    var QADate,_ = (string)fetchAllPatchData[loop].QA_STARTED_ON;
                    string[] temp = strings:split(QADate, " ");
                    QADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON != null){
                    var devDate,_ = (string)fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON;
                    string[] temp = strings:split(devDate, " ");
                    devDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }
                if(fetchAllPatchData[loop].PRE_QA_STARTED_ON != null){
                    var preQADate,_ = (string)fetchAllPatchData[loop].PRE_QA_STARTED_ON;
                    string[] temp = strings:split(preQADate, " ");
                    preQADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                }

                if(regressionDateTime != null && regressionDateTime.time<=durationLastDate.time){
                    var sCount,_ = (int)countsInStates[8];
                    countsInStates[8] = sCount + 1;

                }else if(brokenDateTime != null && brokenDateTime.time<=durationLastDate.time){
                    var sCount,_ = (int)countsInStates[7];
                    countsInStates[7] = sCount + 1;

                }else if(releasedDateTime != null && releasedDateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[6];
                    countsInStates[6] = sCount + 1;

                }else if(rnaDateTime != null && rnaDateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[5];
                    countsInStates[5] = sCount + 1;

                }else if(rnipsDateTime != null && rnipsDateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[4];
                    countsInStates[4] = sCount + 1;

                }else if(QADateTime != null && QADateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[3];
                    countsInStates[3] = sCount + 1;

                }else if(devDateTime != null && devDateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[2];
                    countsInStates[2] = sCount + 1;

                }else if(preQADateTime != null && preQADateTime.time<=durationLastDate.time) {
                    var sCount,_ = (int)countsInStates[2];
                    countsInStates[1] = sCount + 1;

                }else{
                    var sCount,_ = (int)countsInStates[0];
                    countsInStates[0] = sCount + 1;

                }

            }
            loop = loop + 1;
        }

        loop = 0;
        while(loop<allPatchesLength){

            time:Time releasedDateTime = null;
            time:Time rnaDateTime = null;
            time:Time rnipsDateTime = null;
            time:Time QADateTime = null;
            time:Time devDateTime = null;
            time:Time preQADateTime = null;
            time:Time queuedDateTime = null;


            if(fetchAllPatchData[loop].RELEASED_ON != null){
                var releasedDate,_ = (string)fetchAllPatchData[loop].RELEASED_ON;
                string[] temp = strings:split(releasedDate, " ");
                releasedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON != null){
                var rnaDate,_ = (string)fetchAllPatchData[loop].RELEASED_NOT_AUTOMATED_ON;
                string[] temp = strings:split(rnaDate, " ");
                rnaDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON != null){
                var rnipsDate,_ = (string)fetchAllPatchData[loop].RELEASED_NOT_IN_PUBLIC_SVN_ON;
                string[] temp = strings:split(rnipsDate, " ");
                rnipsDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].QA_STARTED_ON != null){
                var QADate,_ = (string)fetchAllPatchData[loop].QA_STARTED_ON;
                string[] temp = strings:split(QADate, " ");
                QADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON != null){
                var devDate,_ = (string)fetchAllPatchData[loop].DEVELOPMENT_STARTED_ON;
                string[] temp = strings:split(devDate, " ");
                devDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].PRE_QA_STARTED_ON != null){
                var preQADate,_ = (string)fetchAllPatchData[loop].PRE_QA_STARTED_ON;
                string[] temp = strings:split(preQADate, " ");
                preQADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }
            if(fetchAllPatchData[loop].REPORT_DATE != null){
                var qDate,_ = (string)fetchAllPatchData[loop].REPORT_DATE;
                string[] temp = strings:split(qDate, " ");
                queuedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }

            if(queuedDateTime!=null && preQADateTime!=null){
                int dayCount = (preQADateTime.time - queuedDateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[0][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[0][1];
                var count3,_ = (int)movementAverages[0][0];
                var count4,_ = (int)movementAverages[0][1];
                dayCountAndNumbersOfPatches[0][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[0][1] = count2 + 1;
                movementAverages[0][0] = count3 + dayCount;
                movementAverages[0][1] = count4 + 1;
            }
            if(preQADateTime!=null && devDateTime!=null){
                int dayCount = (devDateTime.time - preQADateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[1][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[1][1];
                dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[1][1] = count2 + 1;
            }
            if(queuedDateTime!=null && preQADateTime==null && devDateTime!=null){
                int dayCount = (devDateTime.time - queuedDateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[1][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[1][1];
                var count3,_ = (int)movementAverages[0][0];
                var count4,_ = (int)movementAverages[0][1];
                dayCountAndNumbersOfPatches[1][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[1][1] = count2 + 1;
                movementAverages[0][0] = count3 + dayCount;
                movementAverages[0][1] = count4 + 1;
            }
            if(QADateTime!=null && devDateTime!=null){
                int dayCount = (QADateTime.time - devDateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[2][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[2][1];
                dayCountAndNumbersOfPatches[2][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[2][1] = count2 + 1;
            }
            if(QADateTime!=null && rnipsDateTime!=null){
                int dayCount = (rnipsDateTime.time - QADateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[3][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[3][1];
                var count3,_ = (int)movementAverages[1][0];
                var count4,_ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[3][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[3][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;
            }
            if(rnipsDateTime!=null && rnaDateTime!=null){
                int dayCount = (rnaDateTime.time - rnipsDateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[4][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[4][1];
                dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[4][1] = count2 + 1;
            }
            //if(releasedDateTime!=null && rnaDateTime!=null){
            //    int dayCount = (releasedDateTime.time - rnaDateTime.time)/86400000;
            //    var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
            //    var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
            //    dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
            //    dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            //}
            //if(releasedDateTime!=null && rnaDateTime==null && rnipsDateTime!=null ){
            //    int dayCount = (releasedDateTime.time - rnipsDateTime.time)/86400000;
            //    var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
            //    var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
            //    dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
            //    dayCountAndNumbersOfPatches[5][1] = count2 + 1;
            //}
            if(QADateTime!=null && rnipsDateTime==null && rnaDateTime!=null){
                int dayCount = (rnaDateTime.time - QADateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[4][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[4][1];
                var count3,_ = (int)movementAverages[1][0];
                var count4,_ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[4][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[4][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;
            }
            if(releasedDateTime!=null && rnaDateTime==null && rnipsDateTime==null && QADateTime!=null ){
                int dayCount = (releasedDateTime.time - QADateTime.time)/86400000;
                var count1,_ = (int)dayCountAndNumbersOfPatches[5][0];
                var count2,_ = (int)dayCountAndNumbersOfPatches[5][1];
                var count3,_ = (int)movementAverages[1][0];
                var count4,_ = (int)movementAverages[1][1];
                dayCountAndNumbersOfPatches[5][0] = count1 + dayCount;
                dayCountAndNumbersOfPatches[5][1] = count2 + 1;
                movementAverages[1][0] = count3 + dayCount;
                movementAverages[1][1] = count4 + 1;

            }
            loop = loop + 1;
        }
    }

    json response = {"stateCounts":countsInStates,"averageDates":dayCountAndNumbersOfPatches,"patchDetails":fetchAllPatchData,"mainSumamry":movementAverages};
    return response;
}

function getSpecificPatchLifeCycle(string patchID,string eID)(json){
    if(dbConnection == null){
        dbConnectivity();
    }

    json fetchPatchData = [];
    json dayCountAndNumbersOfPatches = [0,0,0,0,0,0];

    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:patchID};
    sql:Parameter p2 = {sqlType:"varchar", value:eID};


    if(eID != "0"){
        params = [p1,p2];
        datatable dt = dbConnection.select("SELECT PATCH_ETA.PATCH_NAME,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON FROM PATCH_QUEUE LEFT OUTER JOIN
                    PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.ID=? AND PATCH_ETA.ID=?", params);
        fetchPatchData, _ = <json>dt;
    }else{
        params = [p1];
        datatable dt = dbConnection.select("SELECT PATCH_ETA.PATCH_NAME,PATCH_ETA.LC_STATE,PATCH_QUEUE.REPORT_DATE,PATCH_QUEUE.PRODUCT_NAME,PATCH_ETA.PRE_QA_STARTED_ON,PATCH_ETA.DEVELOPMENT_STARTED_ON,PATCH_ETA.QA_STARTED_ON,PATCH_ETA.RELEASED_NOT_IN_PUBLIC_SVN_ON,PATCH_ETA.RELEASED_NOT_AUTOMATED_ON,PATCH_ETA.RELEASED_ON,PATCH_ETA.BROKEN_ON,PATCH_ETA.REGRESSION_ON FROM PATCH_QUEUE LEFT OUTER JOIN
                    PATCH_ETA ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.ID=? ", params);
        fetchPatchData, _ = <json>dt;
    }


    time:Time releasedDateTime = null;
    time:Time rnaDateTime = null;
    time:Time rnipsDateTime = null;
    time:Time QADateTime = null;
    time:Time devDateTime = null;
    time:Time preQADateTime = null;
    time:Time queuedDateTime = null;


    if(fetchPatchData[0].RELEASED_ON != null){
        var releasedDate,_ = (string)fetchPatchData[0].RELEASED_ON;
        string[] temp = strings:split(releasedDate, " ");
        releasedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if(fetchPatchData[0].RELEASED_NOT_AUTOMATED_ON != null){
        var rnaDate,_ = (string)fetchPatchData[0].RELEASED_NOT_AUTOMATED_ON;
        string[] temp = strings:split(rnaDate, " ");
        rnaDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if(fetchPatchData[0].RELEASED_NOT_IN_PUBLIC_SVN_ON != null){
        var rnipsDate,_ = (string)fetchPatchData[0].RELEASED_NOT_IN_PUBLIC_SVN_ON;
        string[] temp = strings:split(rnipsDate, " ");
        rnipsDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if(fetchPatchData[0].QA_STARTED_ON != null){
        var QADate,_ = (string)fetchPatchData[0].QA_STARTED_ON;
        string[] temp = strings:split(QADate, " ");
        QADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if(fetchPatchData[0].DEVELOPMENT_STARTED_ON != null){
        var devDate,_ = (string)fetchPatchData[0].DEVELOPMENT_STARTED_ON;
        string[] temp = strings:split(devDate, " ");
        devDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if(fetchPatchData[0].PRE_QA_STARTED_ON != null){
        var preQADate,_ = (string)fetchPatchData[0].PRE_QA_STARTED_ON;
        string[] temp = strings:split(preQADate, " ");
        preQADateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }
    if(fetchPatchData[0].REPORT_DATE != null){
        var qDate,_ = (string)fetchPatchData[0].REPORT_DATE;
        string[] temp = strings:split(qDate, " ");
        queuedDateTime = time:parse(temp[0]+"T00:00:00.000-0000","yyyy-MM-dd'T'HH:mm:ss.SSSZ");
    }

    if(queuedDateTime!=null && preQADateTime!=null){
        int dayCount = (preQADateTime.time - queuedDateTime.time)/86400000;
        var count1,_ = (int)dayCountAndNumbersOfPatches[0];
        dayCountAndNumbersOfPatches[0] = count1 + dayCount;
    }
    if(preQADateTime!=null && devDateTime!=null){
        int dayCount = (devDateTime.time - preQADateTime.time)/86400000;
        var count1,_ = (int)dayCountAndNumbersOfPatches[1];
        dayCountAndNumbersOfPatches[1] = count1 + dayCount;
    }
    if(queuedDateTime!=null && preQADateTime==null && devDateTime!=null){
        int dayCount = (devDateTime.time - queuedDateTime.time)/86400000;
        var count1,_ = (int)dayCountAndNumbersOfPatches[1];
        dayCountAndNumbersOfPatches[1] = count1 + dayCount;
    }
    if(QADateTime!=null && devDateTime!=null){
        int dayCount = (QADateTime.time - devDateTime.time)/86400000;
        var count1,_ = (int)dayCountAndNumbersOfPatches[2];
        dayCountAndNumbersOfPatches[2] = count1 + dayCount;
    }
    if(QADateTime!=null && rnipsDateTime!=null){
        int dayCount = (rnipsDateTime.time - QADateTime.time)/86400000;
        var count1,_ = (int)dayCountAndNumbersOfPatches[3];
        dayCountAndNumbersOfPatches[3] = count1 + dayCount;
    }
    if(rnipsDateTime!=null && rnaDateTime!=null){
        int dayCount = (rnaDateTime.time - rnipsDateTime.time)/86400000;
        var count1,_ = (int)dayCountAndNumbersOfPatches[4];
        dayCountAndNumbersOfPatches[4] = count1 + dayCount;
    }
    if(releasedDateTime!=null && rnaDateTime==null && rnipsDateTime==null && QADateTime!=null ){
        int dayCount = (releasedDateTime.time - QADateTime.time)/86400000;
        var count1,_ = (int)dayCountAndNumbersOfPatches[5];
        dayCountAndNumbersOfPatches[5] = count1 + dayCount;
    }


    json response = {"dateCounts":dayCountAndNumbersOfPatches,"patchDetails":fetchPatchData};
    return response;
}