package source;

import configuration;
import ballerina.data.sql;
import ballerina.lang.system;
import ballerina.lang.messages;
import ballerina.lang.strings;
import ballerina.lang.time;
import org.wso2.ballerina.connectors.jira;



string[] monthLimit = null;
string lastQueuedMonth = "";
sql:ClientConnector dbConnection = null;
jira:ClientConnector JIRA_Connector = null;
sql:Parameter[] params = [];
string[] months = ["January", "February", "March", "April", "May","June", "July", "August", "September", "October", "November","December"];


function dbConnectivity() {
    map props = {"jdbcUrl":"jdbc:mysql://" + configuration:DB_HOST + ":" + configuration:DB_PORT + "/"+configuration:DB_NAME+"", "username":configuration:DB_USERNAME, "password":configuration:DB_PASSWORD,"maximumPoolSize":50};
    dbConnection = create sql:ClientConnector(props);
}

function jiraConnector(){
    JIRA_Connector = create jira:ClientConnector(configuration:baseURL,"sajithal@wso2.com","Capn@sv12");
}

function loadDashboard(string startDate,string endDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }

    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"date", value:startDate};
    sql:Parameter p3 = {sqlType:"date", value:endDate};
    params = [p1,p2,p3];
    datatable dt = dbConnection.select("SELECT count(ACTIVE) as qtotal FROM PATCH_QUEUE WHERE ACTIVE =? AND REPORT_DATE >= ? AND REPORT_DATE <=?", params);
    var jsonResOfYetToStartCount, _ = <json>dt;

    sql:Parameter p4 = {sqlType:"varchar", value:"No"};
    sql:Parameter p5 = {sqlType:"date", value:startDate};
    sql:Parameter p6 = {sqlType:"date", value:endDate};
    params = [p4,p5,p6];
    datatable dt1 = dbConnection.select("
                select count(distinct(PATCH_ETA.PATCH_NAME)) as ctotal from PATCH_ETA join PATCH_QUEUE on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID where
                PATCH_QUEUE.ACTIVE=? AND
                PATCH_ETA.STATUS=1  AND PATCH_ETA.RELEASED_ON >= ? AND
                PATCH_ETA.RELEASED_ON <= ? AND (PATCH_ETA.LC_STATE IN ('ReleasedNotInPublicSVN','Released','ReleasedNotAutomated'))", params);
    var jsonResOfCompletedCount, _ = <json>dt1;

    sql:Parameter p7 = {sqlType:"varchar", value:"No"};
    sql:Parameter p8 = {sqlType:"integer", value:0};
    sql:Parameter p9 = {sqlType:"date", value:startDate};
    sql:Parameter p10 = {sqlType:"date", value:endDate};
    params = [p7,p8,p9,p10];
    datatable dt3 = dbConnection.select("
                select count(distinct(PATCH_ETA.PATCH_NAME)) as dtotal from PATCH_ETA join PATCH_QUEUE on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID where
                PATCH_QUEUE.ACTIVE=? AND PATCH_ETA.STATUS=?  AND PATCH_ETA.RELEASED_ON IS null AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ? AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','ReleasedNotInPublicSVN','ReleasedNotAutomated','N/A'))", params);
    var jsonResOfInProgressCount, _ = <json>dt3;

    sql:Parameter p11 = {sqlType:"varchar", value:"No"};
    sql:Parameter p12= {sqlType:"integer", value:0};
    sql:Parameter p13= {sqlType:"date", value:startDate};
    sql:Parameter p14 = {sqlType:"date", value:endDate};
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
    sql:Parameter p20 = {sqlType:"date", value:startDate};
    sql:Parameter p21 = {sqlType:"date", value:endDate};
    params = [p18,p19,p20,p21];
    datatable dt7 = dbConnection.select("SELECT count(PATCH_QUEUE.SUPPORT_JIRA) as total FROM PATCH_QUEUE JOIN PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID  WHERE (PATCH_QUEUE.SUPPORT_JIRA NOT LIKE '%/DEVINTERNAL-%'
                                            AND PATCH_QUEUE.SUPPORT_JIRA NOT LIKE '%/SECURITYINTERNAL-%') AND (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?)
                                            AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A')) AND PATCH_QUEUE.REPORT_DATE >=? AND PATCH_QUEUE.REPORT_DATE <=?", params);
    var jsonResOfReactive, _ = <json>dt7;
    var reactiveCount,castErr = (int)jsonResOfReactive[0].total;


    sql:Parameter p22 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p23 = {sqlType:"varchar", value:"No"};
    sql:Parameter p24 = {sqlType:"date", value:startDate};
    sql:Parameter p25 = {sqlType:"date", value:endDate};
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

        string[] startDateArray = strings:split(startDate, "-");
        string[] endDateArray = strings:split(endDate, "-");

        if(JIRA_Connector == null){
            jiraConnector();
        }

        json payload = {"jql":"created>='"+startDateArray[0]+"/"+startDateArray[1]+"/"+startDateArray[2]+" 00:00' and  created<='"+endDateArray[0]+"/"+endDateArray[1]+"/"+endDateArray[2]+" 23:59' AND issuekey in ("+finalSecurityIds+") AND labels in (CustFoundVuln,ExtFoundVuln,IntFoundVuln)"};
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

function queuedDetails(string startDate,string endDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"date", value:startDate};
    sql:Parameter p3 = {sqlType:"date", value:endDate};
    params = [p1,p2,p3];
    datatable dt = dbConnection.select("select PRODUCT_NAME,PRODUCT_VERSION,CLIENT,REPORTER,ASSIGNED_TO,REPORT_DATE from PATCH_QUEUE WHERE ACTIVE=? AND PATCH_QUEUE.REPORT_DATE >= ?
                                            AND PATCH_QUEUE.REPORT_DATE <=?", params);
    var jsonResOfQueueDetails, _ = <json>dt;
   
    return jsonResOfQueueDetails;
}

function devDetails(string startDate,string endDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p0 = {sqlType:"varchar", value:"0"};
    sql:Parameter p1 = {sqlType:"varchar", value:"No"};
    sql:Parameter p2 = {sqlType:"date", value:startDate};
    sql:Parameter p3 = {sqlType:"date", value:endDate};
    params = [p0,p1,p2,p3];
    datatable dt = dbConnection.select("select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.CLIENT,PATCH_QUEUE.REPORTER,PATCH_QUEUE.ASSIGNED_TO,PATCH_QUEUE.REPORT_DATE,PATCH_ETA.WORST_CASE_ESTIMATE from PATCH_ETA
                                            JOIN PATCH_QUEUE on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID WHERE PATCH_ETA.STATUS=? AND
                                            PATCH_QUEUE.ACTIVE=?  AND PATCH_ETA.RELEASED_ON IS null AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ? AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) group by PATCH_ETA.PATCH_NAME", params);
    var jsonResOfDevDetails, _ = <json>dt;
   
    return jsonResOfDevDetails;
}

function completeDetails(string startDate,string endDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"1"};
    sql:Parameter p2 = {sqlType:"varchar", value:"No"};
    sql:Parameter p3 = {sqlType:"date", value:startDate};
    sql:Parameter p4 = {sqlType:"date", value:endDate};
    params = [p1,p2,p3,p4];
    datatable dt = dbConnection.select("select PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION,PATCH_QUEUE.CLIENT,PATCH_QUEUE.REPORTER,PATCH_QUEUE.ASSIGNED_TO,PATCH_QUEUE.REPORT_DATE from
                                            PATCH_ETA JOIN PATCH_QUEUE on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID WHERE PATCH_ETA.STATUS=? AND PATCH_QUEUE.ACTIVE=? AND
                                            PATCH_ETA.RELEASED_ON >= ? AND
                                            PATCH_ETA.RELEASED_ON <= ?", params);
    var jsonResOfCompleteDetails, _ = <json>dt;
   
    return jsonResOfCompleteDetails;
}

function menuBadgesCounts(string startDate,string endDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"date", value:startDate};
    sql:Parameter p3 = {sqlType:"date", value:endDate};
    params = [p1,p2,p3];
    datatable dt = dbConnection.select("select COUNT(PATCH_QUEUE.PRODUCT_NAME) as total,PATCH_QUEUE.PRODUCT_NAME FROM PATCH_QUEUE left outer join PATCH_ETA on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE PATCH_QUEUE.ACTIVE=? AND REPORT_DATE >= ? AND REPORT_DATE <= ?
                                                group by PATCH_QUEUE.PRODUCT_NAME", params);
    var jsonResOfQueuedCount, _ = <json>dt;

    sql:Parameter p4 = {sqlType:"varchar", value:"No"};
    sql:Parameter p5 = {sqlType:"varchar", value:"0"};
    sql:Parameter p6 = {sqlType:"date", value:startDate};
    sql:Parameter p7 = {sqlType:"date", value:endDate};
    params = [p4,p5,p6,p7];
    datatable dt2 = dbConnection.select("select COUNT(PATCH_QUEUE.PRODUCT_NAME) as total,PATCH_QUEUE.PRODUCT_NAME FROM PATCH_QUEUE left outer join PATCH_ETA on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID  WHERE
                                            PATCH_QUEUE.ACTIVE = ?  AND PATCH_ETA.RELEASED_ON IS null AND PATCH_ETA.STATUS=? AND PATCH_ETA.WORST_CASE_ESTIMATE<CURDATE() AND REPORT_DATE >= ? AND
                                            REPORT_DATE <= ?  AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) group by PATCH_QUEUE.PRODUCT_NAME", params);
    var jsonResOfETACounts, _ = <json>dt2;

    sql:Parameter p8 = {sqlType:"varchar", value:"0"};
    sql:Parameter p9 = {sqlType:"varchar", value:"No"};
    sql:Parameter p10 = {sqlType:"date", value:startDate};
    sql:Parameter p11 = {sqlType:"date", value:endDate};
    params = [p8,p9,p10,p11];
    datatable dt3 = dbConnection.select("select COUNT(distinct(PATCH_ETA.PATCH_NAME)) as total,PATCH_QUEUE.PRODUCT_NAME FROM PATCH_QUEUE left outer join PATCH_ETA on PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID
                                             WHERE  PATCH_ETA.STATUS=?  AND PATCH_ETA.RELEASED_ON IS null AND PATCH_QUEUE.ACTIVE=? AND REPORT_DATE >= ? AND REPORT_DATE <= ?  AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))
                                             group by PATCH_QUEUE.PRODUCT_NAME", params);
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

function totalProductSummaryCounts(string product,string startDate,string endDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"varchar", value:"No"};
    sql:Parameter p3 = {sqlType:"varchar", value:product};
    sql:Parameter p4 = {sqlType:"varchar", value:"Bug"};
    sql:Parameter p5 = {sqlType:"date", value:startDate};
    sql:Parameter p6 = {sqlType:"date", value:endDate};
    params = [p1,p2,p3,p4,p5,p6];
    datatable dt = dbConnection.select("SELECT count(ISSUE_TYPE) as bugs FROM PATCH_QUEUE WHERE (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?)
                                            AND PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.ISSUE_TYPE=? AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?", params);
    var jsonResOfBugCount, _ = <json>dt;

    sql:Parameter p7 = {sqlType:"varchar", value:product};
    sql:Parameter p8 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p9 = {sqlType:"date", value:startDate};
    sql:Parameter p10 = {sqlType:"date", value:endDate};
    params = [p7,p8,p9,p10];
    datatable dt2 = dbConnection.select("select count(ACTIVE) as total FROM PATCH_QUEUE where PRODUCT_NAME =?
                                            AND ACTIVE=? AND REPORT_DATE >= ? AND REPORT_DATE <= ?", params);
    var jsonResOfQueuedCounts, _ = <json>dt2;

    sql:Parameter p17 = {sqlType:"varchar", value:"1"};
    sql:Parameter p18 = {sqlType:"varchar", value:product};
    sql:Parameter p19 = {sqlType:"date", value:startDate};
    sql:Parameter p11 = {sqlType:"date", value:endDate};
    params = [p17,p18,p19,p11];
    datatable dt3 = dbConnection.select("select count(distinct(PATCH_ETA.PATCH_NAME)) as total from PATCH_ETA JOIN PATCH_QUEUE ON PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID
                                            where PATCH_ETA.STATUS=? AND PATCH_QUEUE.PRODUCT_NAME=? AND
                                            PATCH_ETA.RELEASED_ON >= ? AND
                                            PATCH_ETA.RELEASED_ON <= ?", params);
    var jsonResOfCompleteCounts, _ = <json>dt3;

    sql:Parameter p12 = {sqlType:"varchar", value:"0"};
    sql:Parameter p13 = {sqlType:"varchar", value:"No"};
    sql:Parameter p14 = {sqlType:"varchar", value:product};
    sql:Parameter p15 = {sqlType:"date", value:startDate};
    sql:Parameter p16 = {sqlType:"date", value:endDate};
    params = [p12,p13,p14,p15,p16];
    datatable dt4 = dbConnection.select("select count(distinct(PATCH_ETA.PATCH_NAME)) as total from PATCH_ETA JOIN PATCH_QUEUE ON PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID
                                            where PATCH_ETA.STATUS=? AND PATCH_QUEUE.ACTIVE=? AND PATCH_QUEUE.PRODUCT_NAME=?
                                            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ?  AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))", params);
    var jsonResOfDevCounts, _ = <json>dt4;

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

    if(duration !="year" && duration !="quarter"){
        datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR, month(PATCH_ETA.RELEASED_ON) AS MONTH  FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON),month(PATCH_ETA.RELEASED_ON)
                                            order by year,month,type", params);
        jsonResOfReleaseTrend, _ = <json>dt;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        if(duration == "week"){
            weekFirstDate = getReleaseFirstDateFromWeekNumber(start,end);
        }
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

function loadProductVersionCounts(string product,string version,string startDate,string endDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p0 ={sqlType:"varchar", value:version};
    sql:Parameter p1 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p2 = {sqlType:"varchar", value:"No"};
    sql:Parameter p3 = {sqlType:"varchar", value:product};
    sql:Parameter p4 = {sqlType:"varchar", value:"Bug"};
    sql:Parameter p5 = {sqlType:"date", value:startDate};
    sql:Parameter p6 = {sqlType:"date", value:endDate};
    params = [p1,p2,p3,p0,p4,p5,p6];
    datatable dt = dbConnection.select("SELECT count(ISSUE_TYPE) as bugs FROM PATCH_QUEUE WHERE (PATCH_QUEUE.ACTIVE = ? OR PATCH_QUEUE.ACTIVE = ?)
                                            AND PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.PRODUCT_VERSION=? AND PATCH_QUEUE.ISSUE_TYPE=? AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <=?", params);
    var jsonResOfBugCount, _ = <json>dt;

    sql:Parameter p7 = {sqlType:"varchar", value:product};
    sql:Parameter p8 = {sqlType:"varchar", value:"Yes"};
    sql:Parameter p9 = {sqlType:"date", value:startDate};
    sql:Parameter p10 = {sqlType:"date", value:endDate};
    params = [p7,p0,p8,p9,p10];
    datatable dt2 = dbConnection.select("select count(ACTIVE) as total FROM PATCH_QUEUE where PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION=?
                                            AND ACTIVE=? AND REPORT_DATE >= ? AND REPORT_DATE <= ?", params);
    var jsonResOfQueuedCounts, _ = <json>dt2;

    sql:Parameter p17 = {sqlType:"varchar", value:"1"};
    sql:Parameter p18 = {sqlType:"varchar", value:product};
    sql:Parameter p19 = {sqlType:"date", value:startDate};
    sql:Parameter p11 = {sqlType:"date", value:endDate};
    params = [p17,p18,p0,p19,p11];
    datatable dt3 = dbConnection.select("select count(distinct(PATCH_ETA.PATCH_NAME)) as total from PATCH_ETA JOIN PATCH_QUEUE ON PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID
                                            where PATCH_ETA.STATUS=? AND PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.PRODUCT_VERSION=? AND
                                            PATCH_ETA.RELEASED_ON >= ? AND
                                            PATCH_ETA.RELEASED_ON <= ?", params);
    var jsonResOfCompleteCounts, _ = <json>dt3;

    sql:Parameter p12 = {sqlType:"varchar", value:"0"};
    sql:Parameter p13 = {sqlType:"varchar", value:"No"};
    sql:Parameter p14 = {sqlType:"varchar", value:product};
    sql:Parameter p15 = {sqlType:"date", value:startDate};
    sql:Parameter p16 = {sqlType:"date", value:endDate};
    params = [p12,p13,p14,p0,p15,p16];
    datatable dt4 = dbConnection.select("select count(distinct(PATCH_ETA.PATCH_NAME)) as total from PATCH_ETA JOIN PATCH_QUEUE ON PATCH_QUEUE.ID=PATCH_ETA.PATCH_QUEUE_ID
                                            where PATCH_ETA.STATUS=? AND PATCH_QUEUE.ACTIVE=? AND PATCH_QUEUE.PRODUCT_NAME=? AND PATCH_QUEUE.PRODUCT_VERSION=?
                                            AND PATCH_QUEUE.REPORT_DATE >= ? AND PATCH_QUEUE.REPORT_DATE <= ? AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))", params);
    var jsonResOfDevCounts, _ = <json>dt4;

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

    if(duration !="year" && duration !="quarter"){
        datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR, month(PATCH_ETA.RELEASED_ON) AS MONTH  FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON),month(PATCH_ETA.RELEASED_ON)
                                            order by year,month,type", params);
        jsonResOfReleaseTrend, _ = <json>dt;

        jsonResOfReleaseTrendLength = lengthof jsonResOfReleaseTrend;

        if(duration == "week"){
            weekFirstDate = getReleaseFirstDateFromWeekNumber(start,end);
        }
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

        if(duration !="year" && duration !="quarter"){
            datatable dt = dbConnection.select("SELECT COUNT(distinct(PATCH_ETA.PATCH_NAME)) AS total, "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,year(PATCH_ETA.RELEASED_ON) AS YEAR, month(PATCH_ETA.RELEASED_ON) AS MONTH  FROM PATCH_ETA LEFT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID
                                            WHERE PATCH_QUEUE.PRODUCT_NAME =? AND PATCH_QUEUE.PRODUCT_VERSION =? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=?
                                            GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),year(PATCH_ETA.RELEASED_ON),month(PATCH_ETA.RELEASED_ON)
                                            order by year,month,type", params);
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

function allCategoryReleaseTrendGraph(string product,string duration,string startDate,string endDate)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    sql:Parameter[] params = [];
    sql:Parameter p1 = {sqlType:"varchar", value:product};
    sql:Parameter p2 = {sqlType:"varchar", value:"1"};
    sql:Parameter p3 = {sqlType:"date", value:startDate};
    sql:Parameter p4 = {sqlType:"date", value:endDate};
    params = [p1,p2,p3,p4];
    json jsonResOfcategory = {};

    if(duration !="year" && duration !="quarter"){
        datatable dt = dbConnection.select("SELECT "+duration+"(PATCH_ETA.RELEASED_ON) AS TYPE,YEAR(PATCH_ETA.RELEASED_ON) as YEAR,MONTH(PATCH_ETA.RELEASED_ON) as MONTH FROM
                                            PATCH_ETA RIGHT JOIN PATCH_QUEUE ON PATCH_ETA.PATCH_QUEUE_ID = PATCH_QUEUE.ID WHERE PATCH_QUEUE.PRODUCT_NAME = ?
                                            AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON >=?
                                            AND PATCH_ETA.RELEASED_ON <=? GROUP BY "+duration+"(PATCH_ETA.RELEASED_ON),YEAR(PATCH_ETA.RELEASED_ON),
                                            MONTH(PATCH_ETA.RELEASED_ON) order by year,month,type", params);
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

function queuedAgeGraphGenerator1(string duration,string lastMonth)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    lastQueuedMonth = lastMonth;
    monthLimit = strings:split(duration, ">");
    int monthLimitLength = lengthof monthLimit;
    int loop = 10;
    json fetchData = [];
    json mainfetchData = [];

    while(loop<monthLimitLength){
        if(loop == monthLimitLength-1){
            sql:Parameter[] params = [];
            sql:Parameter p2 = {sqlType:"varchar", value:"Yes"};
            sql:Parameter p3 = {sqlType:"varchar", value:"No"};
            sql:Parameter p4 = {sqlType:"varchar", value:"0"};
            params = [p2,p3,p4];

            datatable dt = dbConnection.select("SELECT
                                                DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE) as AGE,
                                                DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>90 AS MORE90,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<90 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=60) AS MORE60,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<60 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=30) AS MORE30,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<30 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=14) AS MORE14,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<14 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=7) AS MORE7,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<7 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=0) AS MORE0
                                            FROM
                                               PATCH_QUEUE
                                                left outer JOIN
                                                PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                            WHERE
                                                (PATCH_QUEUE.ACTIVE = ?)
                                                OR
                                                ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ?
                                                    AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')))
                                            ", params);
            fetchData[loop], _ = <json>dt;

        }else if(loop == 0){
            sql:Parameter[] params = [];
            sql:Parameter p2 = {sqlType:"varchar", value:"Yes"};
            sql:Parameter p3 = {sqlType:"varchar", value:"No"};
            sql:Parameter p4 = {sqlType:"varchar", value:"0"};
            sql:Parameter p5 = {sqlType:"varchar", value:"1"};
            params = [p2,p3,p4,p3,p5];

            datatable dt = dbConnection.select("SELECT
                                               DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE) as AGE,
                                               DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>90 AS MORE90,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<90 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=60) AS MORE60,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<60 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=30) AS MORE30,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<30 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=14) AS MORE14,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<14 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=7) AS MORE7,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<7 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=0) AS MORE0
                                            FROM
                                               PATCH_QUEUE
                                                left outer JOIN
                                                PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                            WHERE
                                                (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= "+monthLimit[loop]+")
                                                OR
                                                ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_QUEUE.REPORT_DATE <= '"+monthLimit[loop]+"' AND
                                                (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')))
                                                OR
                                                ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+lastMonth+"' AND PATCH_ETA.RELEASED_ON <= '"+monthLimit[loop]+"' ))
                                            ", params);
            fetchData[loop], _ = <json>dt;
        }else{
            sql:Parameter[] params = [];
            sql:Parameter p2 = {sqlType:"varchar", value:"Yes"};
            sql:Parameter p3 = {sqlType:"varchar", value:"No"};
            sql:Parameter p4 = {sqlType:"varchar", value:"0"};
            sql:Parameter p5 = {sqlType:"varchar", value:"1"};
            params = [p2,p3,p4,p3,p5];
            datatable dt = dbConnection.select("SELECT
                                               DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE) as AGE,
                                               DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>90 AS MORE90,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<90 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=60) AS MORE60,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<60 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=30) AS MORE30,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<30 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=14) AS MORE14,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<14 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=7) AS MORE7,
                                               (DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)<7 AND DATEDIFF('"+monthLimit[loop]+"',PATCH_QUEUE.REPORT_DATE)>=0) AS MORE0
                                            FROM
                                               PATCH_QUEUE
                                                left outer JOIN
                                                PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                            WHERE
                                                (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+monthLimit[loop]+"')
                                                OR
                                                ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_QUEUE.REPORT_DATE <= '"+monthLimit[loop]+"' AND
                                                (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')))
                                                OR
                                                ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+monthLimit[loop-1]+"' AND PATCH_ETA.RELEASED_ON <= '"+monthLimit[loop]+"' ))
                                            ", params);
            fetchData[loop], _ = <json>dt;
        }
        system:println(loop);
        //system:println(monthLimit[loop]);
        mainfetchData[loop] = fetchData[loop];
        loop = loop +1;
    }

    json ageGroup = [[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0]];
    loop = 11;

    while(loop < monthLimitLength){

        int midLength = lengthof mainfetchData[loop];
        int loop2 = 0;
        while(loop2<midLength){
            var currentMore90,err = (int)ageGroup[0][loop];
            var currentMore60,err = (int)ageGroup[1][loop];
            var currentMore30,err = (int)ageGroup[2][loop];
            var currentMore14,err = (int)ageGroup[3][loop];
            var currentMore7,err = (int)ageGroup[4][loop];
            var currentMore0,err = (int)ageGroup[5][loop];

            var more90,er = (int)mainfetchData[loop][loop2].MORE90;
            var more60,er = (int)mainfetchData[loop][loop2].MORE60;
            var more30,er = (int)mainfetchData[loop][loop2].MORE30;
            var more14,er = (int)mainfetchData[loop][loop2].MORE14;
            var more7,er = (int)mainfetchData[loop][loop2].MORE7;
            var more0,er = (int)mainfetchData[loop][loop2].MORE0;

            ageGroup[0][loop] = currentMore90 + more90;
            ageGroup[1][loop] = currentMore60 + more60;
            ageGroup[2][loop] = currentMore30 + more30;
            ageGroup[3][loop] = currentMore14 + more14;
            ageGroup[4][loop] = currentMore7 + more7;
            ageGroup[5][loop] = currentMore0 + more0;

            loop2 = loop2 +1;
        }
        //system:println(ageGroup);
        loop = loop +1;
    }


    system:println("DONE");



    //json reportedPatches = {"isEmpty":1,"versionReleaseTrend":ageGroup};
   
    return ageGroup;
}

function queuedAgeGraphGenerator(string duration,string lastMonth)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    lastQueuedMonth = lastMonth;
    monthLimit = strings:split(duration, ">");
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
                                        WHERE (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.LC_STATE NOT IN ('OnHold' ,'Released','Broken', 'N/A'))
                                        OR (PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_QUEUE.REPORT_DATE >= '"+monthLimit[0]+"' OR PATCH_ETA.RELEASED_ON >= '"+monthLimit[0]+"') AND PATCH_ETA.LC_STATE NOT IN ('OnHold' , 'Broken', 'N/A'))
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

function ageDrillDownGraph1(string group,string month,string isToday,string index)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    var indexes, _ = <int>index;
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


    if(isToday == "true"){
        sql:Parameter[] params = [];
        sql:Parameter p2 = {sqlType:"varchar", value:"Yes"};
        sql:Parameter p3 = {sqlType:"varchar", value:"No"};
        sql:Parameter p4 = {sqlType:"varchar", value:"0"};

        if(group != "90"){
            params = [p2,p3,p4];
            datatable dt = dbConnection.select("SELECT
                                                            count(DATEDIFF('"+month+"',
                                                                    PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                            PATCH_QUEUE.PRODUCT_NAME
                                                        FROM
                                                            PATCH_QUEUE
                                                            left outer JOIN
                                                            PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                        WHERE
                                                            (PATCH_QUEUE.ACTIVE = ? AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+") )
                                                            OR
                                                            ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ?
                                                                AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))  AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND
                                                                DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                        group by PATCH_QUEUE.PRODUCT_NAME", params);
            fetchData, _ = <json>dt;

            datatable dt2 = dbConnection.select("SELECT
                                                            count(DATEDIFF('"+month+"',
                                                                    PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                            PATCH_QUEUE.PRODUCT_NAME,
                                                            PATCH_QUEUE.PRODUCT_VERSION
                                                        FROM
                                                            PATCH_QUEUE
                                                            left outer JOIN
                                                            PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                        WHERE
                                                            (PATCH_QUEUE.ACTIVE = ? AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+") )
                                                            OR
                                                            ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ?
                                                                AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))  AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND
                                                                DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                        group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
            fetchDrillDownData, _ = <json>dt2;
        }else{
            params = [p2,p3,p4];
            datatable dt = dbConnection.select("SELECT
                                                            count(DATEDIFF('"+month+"',
                                                                    PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                            PATCH_QUEUE.PRODUCT_NAME
                                                        FROM
                                                            PATCH_QUEUE
                                                            left outer JOIN
                                                            PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                        WHERE
                                                            (PATCH_QUEUE.ACTIVE = ? AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90 )
                                                            OR
                                                            ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ?
                                                                AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))  AND
                                                                DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                        group by PATCH_QUEUE.PRODUCT_NAME", params);
            fetchData, _ = <json>dt;

            datatable dt2 = dbConnection.select("SELECT
                                                            count(DATEDIFF('"+month+"',
                                                                    PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                            PATCH_QUEUE.PRODUCT_NAME,
                                                            PATCH_QUEUE.PRODUCT_VERSION
                                                        FROM
                                                            PATCH_QUEUE
                                                            left outer JOIN
                                                            PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                        WHERE
                                                            (PATCH_QUEUE.ACTIVE = ? AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90 )
                                                            OR
                                                            ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ?
                                                                AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))  AND
                                                                DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                        group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
            fetchDrillDownData, _ = <json>dt2;
        }
    }else{
        var activeLastQueuedMonth = "";
        if(indexes == 0){
            activeLastQueuedMonth = lastQueuedMonth;
        }else{
            activeLastQueuedMonth = monthLimit[indexes -1];
        }

        sql:Parameter[] params = [];
        sql:Parameter p2 = {sqlType:"varchar", value:"Yes"};
        sql:Parameter p3 = {sqlType:"varchar", value:"No"};
        sql:Parameter p4 = {sqlType:"varchar", value:"0"};
        sql:Parameter p5 = {sqlType:"varchar", value:"1"};

        if(group != "90"){
            params = [p2,p3,p4,p3,p5];
            datatable dt = dbConnection.select("SELECT
                                                    count(DATEDIFF('"+month+"',
                                                            PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                    PATCH_QUEUE.PRODUCT_NAME
                                                FROM
                                                    PATCH_QUEUE
                                                    left outer JOIN
                                                    PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE
                                                    (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND
                                                    (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+activeLastQueuedMonth+"'
                                                    AND PATCH_ETA.RELEASED_ON <= '"+month+"' ) AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                group by PATCH_QUEUE.PRODUCT_NAME", params);
            fetchData, _ = <json>dt;

            datatable dt2 = dbConnection.select("SELECT
                                                    count(DATEDIFF('"+month+"',
                                                            PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                    PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION
                                                FROM
                                                    PATCH_QUEUE
                                                    left outer JOIN
                                                    PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE
                                                    (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND
                                                    (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+activeLastQueuedMonth+"'
                                                    AND PATCH_ETA.RELEASED_ON <= '"+month+"' ) AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
            fetchDrillDownData, _ = <json>dt2;
        }else{
            params = [p2,p3,p4,p3,p5];
            datatable dt = dbConnection.select("SELECT
                                                    count(DATEDIFF('"+month+"',
                                                            PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                    PATCH_QUEUE.PRODUCT_NAME
                                                FROM
                                                    PATCH_QUEUE
                                                    left outer JOIN
                                                    PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE
                                                    (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND
                                                    (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+activeLastQueuedMonth+"'
                                                    AND PATCH_ETA.RELEASED_ON <= '"+month+"' ) AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                group by PATCH_QUEUE.PRODUCT_NAME", params);
            fetchData, _ = <json>dt;

            datatable dt2 = dbConnection.select("SELECT
                                                    count(DATEDIFF('"+month+"',
                                                            PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                    PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION
                                                FROM
                                                    PATCH_QUEUE
                                                    left outer JOIN
                                                    PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE
                                                    (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND
                                                    (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+activeLastQueuedMonth+"'
                                                    AND PATCH_ETA.RELEASED_ON <= '"+month+"' ) AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
            fetchDrillDownData, _ = <json>dt2;
        }
    }


    json mainArray = [];
    json drillDownArray = [];
    int loop = 0;
    int mainLength = lengthof fetchData;

    while(loop<mainLength){
        json dump={name:"x",y:2016,drilldown:"y"};
        var patchCount, castErr = (int)fetchData[loop].AGE;
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
        var val,err = (int)mainArray[loop].y;
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

function ageDrillDownGraph(string group,string month,string isToday,string index)(json){
    if(dbConnection == null){
        dbConnectivity();
    }
    var indexes, _ = <int>index;
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


    if(isToday == "true"){
        sql:Parameter[] params = [];
        sql:Parameter p2 = {sqlType:"varchar", value:"Yes"};
        sql:Parameter p3 = {sqlType:"varchar", value:"No"};
        sql:Parameter p4 = {sqlType:"varchar", value:"0"};

        if(group != "90"){
            params = [p2,p3,p4];
            datatable dt = dbConnection.select("SELECT
                                                            count(DATEDIFF('"+month+"',
                                                                    PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                            PATCH_QUEUE.PRODUCT_NAME
                                                        FROM
                                                            PATCH_QUEUE
                                                            left outer JOIN
                                                            PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                        WHERE
                                                            (PATCH_QUEUE.ACTIVE = ? AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+") )
                                                            OR
                                                            ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON IS NULL
                                                                AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))  AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND
                                                                DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                        group by PATCH_QUEUE.PRODUCT_NAME", params);
            fetchData, _ = <json>dt;

            datatable dt2 = dbConnection.select("SELECT
                                                            count(DATEDIFF('"+month+"',
                                                                    PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                            PATCH_QUEUE.PRODUCT_NAME,
                                                            PATCH_QUEUE.PRODUCT_VERSION
                                                        FROM
                                                            PATCH_QUEUE
                                                            left outer JOIN
                                                            PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                        WHERE
                                                            (PATCH_QUEUE.ACTIVE = ? AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+") )
                                                            OR
                                                            ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON IS NULL
                                                                AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))  AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND
                                                                DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                        group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
            fetchDrillDownData, _ = <json>dt2;
        }else{
            params = [p2,p3,p4];
            datatable dt = dbConnection.select("SELECT
                                                            count(DATEDIFF('"+month+"',
                                                                    PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                            PATCH_QUEUE.PRODUCT_NAME
                                                        FROM
                                                            PATCH_QUEUE
                                                            left outer JOIN
                                                            PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                        WHERE
                                                            (PATCH_QUEUE.ACTIVE = ? AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90 )
                                                            OR
                                                            ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ?
                                                                AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))  AND
                                                                DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                        group by PATCH_QUEUE.PRODUCT_NAME", params);
            fetchData, _ = <json>dt;

            datatable dt2 = dbConnection.select("SELECT
                                                            count(DATEDIFF('"+month+"',
                                                                    PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                            PATCH_QUEUE.PRODUCT_NAME,
                                                            PATCH_QUEUE.PRODUCT_VERSION
                                                        FROM
                                                            PATCH_QUEUE
                                                            left outer JOIN
                                                            PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                        WHERE
                                                            (PATCH_QUEUE.ACTIVE = ? AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90 )
                                                            OR
                                                            ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ?
                                                                AND (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A'))  AND
                                                                DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                        group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
            fetchDrillDownData, _ = <json>dt2;
        }
    }else{
        var activeLastQueuedMonth = "";
        if(indexes == 0){
            activeLastQueuedMonth = lastQueuedMonth;
        }else{
            activeLastQueuedMonth = monthLimit[indexes -1];
        }

        sql:Parameter[] params = [];
        sql:Parameter p2 = {sqlType:"varchar", value:"Yes"};
        sql:Parameter p3 = {sqlType:"varchar", value:"No"};
        sql:Parameter p4 = {sqlType:"varchar", value:"0"};
        sql:Parameter p5 = {sqlType:"varchar", value:"1"};

        if(group != "90"){
            params = [p2,p3,p4,p3,p5];
            datatable dt = dbConnection.select("SELECT
                                                    count(DATEDIFF('"+month+"',
                                                            PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                    PATCH_QUEUE.PRODUCT_NAME
                                                FROM
                                                    PATCH_QUEUE
                                                    left outer JOIN
                                                    PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE
                                                    (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON IS NULL  AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND
                                                    (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+activeLastQueuedMonth+"'
                                                    AND PATCH_ETA.RELEASED_ON >= '"+month+"' ) AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+") AND PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A'))
                                                group by PATCH_QUEUE.PRODUCT_NAME", params);
            fetchData, _ = <json>dt;

            datatable dt2 = dbConnection.select("SELECT
                                                    count(DATEDIFF('"+month+"',
                                                            PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                    PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION
                                                FROM
                                                    PATCH_QUEUE
                                                    left outer JOIN
                                                    PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE
                                                    (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND
                                                    (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+"))
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+activeLastQueuedMonth+"'
                                                    AND PATCH_ETA.RELEASED_ON >= '"+month+"' ) AND (DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) < "+groupLimits[currentGroupIndex][0]+" AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= "+groupLimits[currentGroupIndex][1]+") AND PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A'))
                                                group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
            fetchDrillDownData, _ = <json>dt2;
        }else{
            params = [p2,p3,p4,p3,p5];
            datatable dt = dbConnection.select("SELECT
                                                    count(DATEDIFF('"+month+"',
                                                            PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                    PATCH_QUEUE.PRODUCT_NAME
                                                FROM
                                                    PATCH_QUEUE
                                                    left outer JOIN
                                                    PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE
                                                    (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND
                                                    (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+activeLastQueuedMonth+"'
                                                    AND PATCH_ETA.RELEASED_ON >= '"+month+"' ) AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90 AND PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A'))
                                                group by PATCH_QUEUE.PRODUCT_NAME", params);
            fetchData, _ = <json>dt;

            datatable dt2 = dbConnection.select("SELECT
                                                    count(DATEDIFF('"+month+"',
                                                            PATCH_QUEUE.REPORT_DATE)) as AGE,
                                                    PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION
                                                FROM
                                                    PATCH_QUEUE
                                                    left outer JOIN
                                                    PATCH_ETA ON PATCH_QUEUE.ID = PATCH_ETA.PATCH_QUEUE_ID
                                                WHERE
                                                    (PATCH_QUEUE.ACTIVE = ? AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND PATCH_ETA.RELEASED_ON IS NULL AND PATCH_QUEUE.REPORT_DATE <= '"+month+"' AND
                                                    (PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','Released','N/A')) AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90)
                                                    OR
                                                    ( PATCH_QUEUE.ACTIVE = ? AND PATCH_ETA.STATUS = ? AND (PATCH_ETA.RELEASED_ON >= '"+activeLastQueuedMonth+"'
                                                    AND PATCH_ETA.RELEASED_ON >= '"+month+"' ) AND DATEDIFF('"+month+"',PATCH_QUEUE.REPORT_DATE) >= 90 AND PATCH_ETA.LC_STATE NOT IN ('OnHold','Broken','N/A'))
                                                group by PATCH_QUEUE.PRODUCT_NAME,PATCH_QUEUE.PRODUCT_VERSION", params);
            fetchDrillDownData, _ = <json>dt2;
        }
    }


    json mainArray = [];
    json drillDownArray = [];
    int loop = 0;
    int mainLength = lengthof fetchData;

    while(loop<mainLength){
        json dump={name:"x",y:2016,drilldown:"y"};
        var patchCount, castErr = (int)fetchData[loop].AGE;
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
        var val,err = (int)mainArray[loop].y;
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

    system:println(versionData);
    system:println(drillDownArray);
    json ageDrillDownGraphJSON = {"mainData":mainArray,"drillDown":drillDownArray};
   
    return ageDrillDownGraphJSON;
}

function lifeCycleStackGraph(string start,string end)(json){
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