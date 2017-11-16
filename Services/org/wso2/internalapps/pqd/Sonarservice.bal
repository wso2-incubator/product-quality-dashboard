package org.wso2.internalapps.pqd;

import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.lang.jsons;
import ballerina.lang.time;
import ballerina.utils;
import ballerina.data.sql;
import ballerina.lang.errors;
import ballerina.lang.datatables;
import ballerina.utils.logger;

struct Snapshots{
    int snapshot_id;
}

struct Areas{
    int pqd_area_id;
    string pqd_area_name;
}

struct Products{
    int pqd_product_id;
    string pqd_product_name;
}

struct Totals{
    int total;
}

struct SonarIssues{
    int sonar_component_issue_id;
    int snapshot_id;
    string date;
    string project_key;
    int BLOCKER_BUG; int CRITICAL_BUG; int MAJOR_BUG; int MINOR_BUG; int INFO_BUG;
    int BLOCKER_CODE_SMELL; int CRITICAL_CODE_SMELL; int MAJOR_CODE_SMELL; int MINOR_CODE_SMELL; int INFO_CODE_SMELL;
    int BLOCKER_VULNERABILITY; int CRITICAL_VULNERABILITY; int MAJOR_VULNERABILITY; int MINOR_VULNERABILITY; int INFO_VULNERABILITY;
    int total;
}

struct Components{
    int pqd_component_id;
    string pqd_component_name;
    int pqd_product_id;
    string sonar_project_key;
}

struct DailySonarIssues {
    string date;
    float BLOCKER_BUG; float CRITICAL_BUG; float MAJOR_BUG; float MINOR_BUG; float INFO_BUG;
    float BLOCKER_CODE_SMELL; float CRITICAL_CODE_SMELL; float MAJOR_CODE_SMELL; float MINOR_CODE_SMELL; float INFO_CODE_SMELL;
    float BLOCKER_VULNERABILITY; float CRITICAL_VULNERABILITY; float MAJOR_VULNERABILITY; float MINOR_VULNERABILITY; float INFO_VULNERABILITY;
    float total;
}
struct MonthlySonarIssues {
    int year;
    int month;
    float BLOCKER_BUG; float CRITICAL_BUG; float MAJOR_BUG; float MINOR_BUG; float INFO_BUG;
    float BLOCKER_CODE_SMELL; float CRITICAL_CODE_SMELL; float MAJOR_CODE_SMELL; float MINOR_CODE_SMELL; float INFO_CODE_SMELL;
    float BLOCKER_VULNERABILITY; float CRITICAL_VULNERABILITY; float MAJOR_VULNERABILITY; float MINOR_VULNERABILITY; float INFO_VULNERABILITY;
    float total;
}
struct QuarterlySonarIssues{
    int year;
    int quarter;
    float BLOCKER_BUG; float CRITICAL_BUG; float MAJOR_BUG; float MINOR_BUG; float INFO_BUG;
    float BLOCKER_CODE_SMELL; float CRITICAL_CODE_SMELL; float MAJOR_CODE_SMELL; float MINOR_CODE_SMELL; float INFO_CODE_SMELL;
    float BLOCKER_VULNERABILITY; float CRITICAL_VULNERABILITY; float MAJOR_VULNERABILITY; float MINOR_VULNERABILITY; float INFO_VULNERABILITY;
    float total;
}
struct YearlySonarIssues{
    int year;
    float BLOCKER_BUG; float CRITICAL_BUG; float MAJOR_BUG; float MINOR_BUG; float INFO_BUG;
    float BLOCKER_CODE_SMELL; float CRITICAL_CODE_SMELL; float MAJOR_CODE_SMELL; float MINOR_CODE_SMELL; float INFO_CODE_SMELL;
    float BLOCKER_VULNERABILITY; float CRITICAL_VULNERABILITY; float MAJOR_VULNERABILITY; float MINOR_VULNERABILITY; float INFO_VULNERABILITY;
    float total;
}

json configData = getConfigData(CONFIG_PATH);

map propertiesMap = getSQLconfigData(configData);

string basicurl = jsons:getString(configData, "$.SONAR.SONAR_URL");
string version =  API_VERSION;

@http:configuration {basePath:"/internal/product-quality/v1.0/sonar"}
service<http> SonarService {

    @http:GET {}
    @http:Path {value:"/get-total-issues"}
    resource SonarTotalIsuueCount (message m) {

        http:ClientConnector sonarcon = create http:ClientConnector(basicurl);

        message request = {};
        message requestH = {};
        message sonarResponse = {};
        json sonarJSONResponse = {};
        message response = {};

        string Path = "/api/issues/search?resolved=no";
        requestH = authHeader(request);
        sonarResponse = http:ClientConnector.get(sonarcon, Path, requestH);
        sonarJSONResponse = messages:getJsonPayload(sonarResponse);
        int total = jsons:getInt(sonarJSONResponse, "$.total");

        string tot = <string>total;

        time:Time currentTime = time:currentTime();
        string customTimeString = time:format(currentTime, "yyyy-MM-dd--HH:mm:ss");
        json sonarPayload = {"Date":customTimeString, "TotalIssues":tot};
        logger:info(customTimeString+":"+tot);
        messages:setJsonPayload(response, sonarPayload);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;

    }

    @http:GET {}
    @http:Path {value:"/fetch-data"}
    resource saveIssuestoDB (message m) {
        message response = {};
        message request = {};
        message requestH = {};
        message sonarResponse = {};

        http:ClientConnector sonarcon = create http:ClientConnector(basicurl);
        string Path="/api/projects";
        requestH = authHeader(request);

        sonarResponse = http:ClientConnector.get(sonarcon, Path, requestH);
        json sonarJsonResponse = messages:getJsonPayload(sonarResponse);
        logger:info(sonarJsonResponse);
        json projects=jsons:getJson(sonarJsonResponse,"$.[?(@.k)].k");
        saveIssues(projects);

        messages:setJsonPayload(response, projects);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/get-all-area-issues"}
    resource SonarAllAreaIssues (message m) {
        json data = getAllAreaSonarIssues();
        message response = {};
        messages:setJsonPayload(response,data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;

    }

    @http:GET {}
    @http:Path {value:"/get-issues/{category}/{selected}/{issueType}/{severity}"}
    resource SonarGetIssues (message m, @http:PathParam {value:"category"} string category,
                             @http:PathParam {value:"selected"} int selected,
                             @http:PathParam {value:"sonarIssuetype"} int issueType,
                             @http:PathParam {value:"sonarSeverity"} int severity) {
        json data = getSelectionResult(category,selected,issueType,severity);
        message response = {};
        messages:setJsonPayload(response,data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;

    }

    @http:GET {}
    @http:Path {value:"/issues/issuetype/{issuetypeId}/severity/{severityId}"}
    resource SonarGetIssuesFiltered (message m, @http:PathParam {value:"issuetypeId"} int issueTypeId,
                                     @http:PathParam {value:"severityId"} int severityId,
                                     @http:QueryParam {value:"category"} string category,
                                     @http:QueryParam {value:"categoryId"} int categoryId) {
        json data = getSelectionResult(category,categoryId,issueTypeId,severityId);
        message response = {};
        messages:setJsonPayload(response,data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;

    }

    @http:GET {}
    @http:Path {value:"get-history/{start}/{end}/{period}/{category}/{selected}/{issueType}/{severity}"}
    resource SonarGetHistory(message m, @http:PathParam {value:"start"} string start,
                             @http:PathParam {value:"end"} string end,
                             @http:PathParam {value:"period"} string period,
                             @http:PathParam {value:"category"} string category,
                             @http:PathParam {value:"selected"} int selected,
                             @http:PathParam {value:"sonarIssuetype"} int issueType,
                             @http:PathParam {value:"sonarSeverity"} int severity){
        json data = getSelectionHistory(start,end,period,category,selected,issueType,severity);
        message response = {};
        messages:setJsonPayload(response,data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"issues/history/{category}/{categoryId}"}
    resource SonarGetHistory2(message m, @http:QueryParam {value:"dateFrom"} string start,
                              @http:QueryParam {value:"dateTo"} string end,
                              @http:QueryParam {value:"period"} string period,
                              @http:PathParam {value:"category"} string category,
                              @http:PathParam {value:"categoryId"} int selected,
                              @http:QueryParam {value:"issuetypeId"} int issueType,
                              @http:QueryParam {value:"severityId"} int severity){
        json data = getSelectionHistory(start,end,period,category,selected,issueType,severity);
        message response = {};
        messages:setJsonPayload(response,data);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

}

function saveIssues (json projects)  {
    int ls=lengthof projects;
    logger:info(ls);
    ls -> w1;

    worker w1 {
        int loopsize;
        loopsize<-default;

        sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
        sql:Parameter[] params = [];

        string customStartTimeString = time:format(time:currentTime(), "yyyy-MM-dd");
        logger:info("Start time: " + customStartTimeString);

        sql:Parameter todayDate = {sqlType:"varchar", value:customStartTimeString};
        params = [todayDate];
        int ret = sql:ClientConnector.update(dbConnector, INSERT_SNAPSHOT_DETAILS , params);

        params = [];
        datatable dt = sql:ClientConnector.select(dbConnector,  GET_SNAPSHOT_ID, params);

        Snapshots ss;
        int snapshot_id;
        errors:TypeCastError err;
        while (datatables:hasNext(dt)) {
            any row = datatables:next(dt);
            ss, err = (Snapshots)row;

            snapshot_id = ss.snapshot_id;

        }
        datatables:close(dt);
        //transaction {

            sql:Parameter snapshotid = {sqlType:"integer", value:snapshot_id};
            int i = 0;
            while (i < loopsize) {

                var project_key, er = (string)projects[i];
                logger:info(i + "|" + project_key);
                json sumaryofProjectJson = componentSonarIssueCount(project_key);
                logger:info(sumaryofProjectJson);

                sql:Parameter projectkey = {sqlType:"varchar", value:project_key};

                int bb = jsons:getInt(sumaryofProjectJson, "$.bb");
                sql:Parameter bb1 = {sqlType:"integer", value:bb};

                int cb = jsons:getInt(sumaryofProjectJson, "$.cb");
                sql:Parameter cb1 = {sqlType:"integer", value:cb};

                int mab = jsons:getInt(sumaryofProjectJson, "$.mab");
                sql:Parameter mab1 = {sqlType:"integer", value:mab};

                int mib = jsons:getInt(sumaryofProjectJson, "$.mib");
                sql:Parameter mib1 = {sqlType:"integer", value:mib};

                int ib = jsons:getInt(sumaryofProjectJson, "$.ib");
                sql:Parameter ib1 = {sqlType:"integer", value:ib};

                int bc = jsons:getInt(sumaryofProjectJson, "$.bc");
                sql:Parameter bc1 = {sqlType:"integer", value:bc};

                int cc = jsons:getInt(sumaryofProjectJson, "$.cc");
                sql:Parameter cc1 = {sqlType:"integer", value:cc};

                int mac = jsons:getInt(sumaryofProjectJson, "$.mac");
                sql:Parameter mac1 = {sqlType:"integer", value:mac};

                int mic = jsons:getInt(sumaryofProjectJson, "$.mic");
                sql:Parameter mic1 = {sqlType:"integer", value:mic};

                int ic = jsons:getInt(sumaryofProjectJson, "$.ic");
                sql:Parameter ic1 = {sqlType:"integer", value:ic};

                int bv = jsons:getInt(sumaryofProjectJson, "$.bv");
                sql:Parameter bv1 = {sqlType:"integer", value:bv};

                int cv = jsons:getInt(sumaryofProjectJson, "$.cv");
                sql:Parameter cv1 = {sqlType:"integer", value:cv};

                int mav = jsons:getInt(sumaryofProjectJson, "$.mav");
                sql:Parameter mav1 = {sqlType:"integer", value:mav};

                int miv = jsons:getInt(sumaryofProjectJson, "$.miv");
                sql:Parameter miv1 = {sqlType:"integer", value:miv};

                int iv = jsons:getInt(sumaryofProjectJson, "$.iv");
                sql:Parameter iv1 = {sqlType:"integer", value:iv};

                int total = jsons:getInt(sumaryofProjectJson, "$.Total");
                sql:Parameter total1 = {sqlType:"integer", value:total};

                params = [snapshotid, todayDate,projectkey, bb1, cb1, mab1, mib1, ib1, bc1, cc1, mac1, mic1, ic1, bv1, cv1, mav1, miv1, iv1,total1];
                int ret1 = sql:ClientConnector.update(dbConnector, INSERT_SONAR_ISSUES, params);
                i = i + 1;
            }
        //}
        string customEndTimeString = time:format(time:currentTime(), "yyyy-MM-dd");
        logger:info("End time: " + customEndTimeString);
        dbConnector.close();
    }
}

function componentSonarIssueCount (string project_key) (json) {
    http:ClientConnector sonarcon = create http:ClientConnector(basicurl);

    message request = {};
    message requestH = {};
    message sonarResponse = {};
    json sonarJSONResponse = {};
    int p=1;
    int ps = 500;

    string Path = "/api/issues/search?resolved=no&ps=500&projectKeys=" + project_key+"&p="+p;
    requestH = authHeader(request);
    logger:info(basicurl+Path);
    sonarResponse = http:ClientConnector.get(sonarcon, Path, requestH);

    sonarJSONResponse = messages:getJsonPayload(sonarResponse);

    int total =jsons:getInt(sonarJSONResponse,"$.total");

    json blockerBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='BLOCKER')]");
    int totalBlockerBugs=jsons:getInt(blockerBugs,"$.length()");

    json criticalBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='CRITICAL')]");
    int totalCriticalBugs=jsons:getInt(criticalBugs,"$.length()");

    json majorBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='MAJOR')]");
    int totalMajorBugs=jsons:getInt(majorBugs,"$.length()");

    json minorBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='MINOR')]");
    int totalMinorBugs=jsons:getInt(minorBugs,"$.length()");

    json infoBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='INFO')]");
    int totalInfoBugs=jsons:getInt(infoBugs,"$.length()");

    json blockerCodeSmells = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='BLOCKER')]");
    int totalBlockerCodeSmells=jsons:getInt(blockerCodeSmells,"$.length()");

    json criticalCodeSmells = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='CRITICAL')]");
    int totalCriticalCodeSmells=jsons:getInt(criticalCodeSmells,"$.length()");

    json majorCodeSmells = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='MAJOR')]");
    int totalMajorCodeSmells=jsons:getInt(majorCodeSmells,"$.length()");

    json minorCodeSmells = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='MINOR')]");
    int totalMinorCodeSmells=jsons:getInt(minorCodeSmells,"$.length()");

    json infoCodeSmell = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='INFO')]");
    int totalInfoCodeSmell=jsons:getInt(infoCodeSmell,"$.length()");

    json blockerVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='BLOCKER')]");
    int totalBlockerVulnerabilities=jsons:getInt(blockerVulnerabilities,"$.length()");

    json criticalVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='CRITICAL')]");
    int totalCriticalVulnerabilities=jsons:getInt(criticalVulnerabilities,"$.length()");

    json majorVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='MAJOR')]");
    int totalMajorVulnerabilities=jsons:getInt(majorVulnerabilities,"$.length()");

    json minorVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='MINOR')]");
    int totalMinorVulnerabilities=jsons:getInt(minorVulnerabilities,"$.length()");

    json infoVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='INFO')]");
    int totalInfoVulnerabilities=jsons:getInt(infoVulnerabilities,"$.length()");


    while (total>ps){
        p=p+1;
        total=total-500;
        logger:info(total+"|"+p);
        Path = "/api/issues/search?resolved=no&ps=500&projectKeys=" + project_key+"&p="+p;
        logger:info(basicurl+Path);
        sonarResponse = http:ClientConnector.get(sonarcon, Path, requestH);

        sonarJSONResponse = messages:getJsonPayload(sonarResponse);

        blockerBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='BLOCKER')]");
        totalBlockerBugs=totalBlockerBugs+jsons:getInt(blockerBugs,"$.length()");

        criticalBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='CRITICAL')]");
        totalCriticalBugs=totalCriticalBugs+jsons:getInt(criticalBugs,"$.length()");

        majorBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='MAJOR')]");
        totalMajorBugs=totalMajorBugs+jsons:getInt(majorBugs,"$.length()");

        minorBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='MINOR')]");
        totalMinorBugs=totalMinorBugs+jsons:getInt(minorBugs,"$.length()");

        infoBugs = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='BUG')][?(@.severity=='INFO')]");
        totalInfoBugs=totalInfoBugs+jsons:getInt(infoBugs,"$.length()");

        blockerCodeSmells = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='BLOCKER')]");
        totalBlockerCodeSmells=totalBlockerCodeSmells+jsons:getInt(blockerCodeSmells,"$.length()");

        criticalCodeSmells = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='CRITICAL')]");
        totalCriticalCodeSmells=totalCriticalCodeSmells+jsons:getInt(criticalCodeSmells,"$.length()");

        majorCodeSmells = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='MAJOR')]");
        totalMajorCodeSmells=totalMajorCodeSmells+jsons:getInt(majorCodeSmells,"$.length()");

        minorCodeSmells = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='MINOR')]");
        totalMinorCodeSmells=totalMinorCodeSmells+jsons:getInt(minorCodeSmells,"$.length()");

        infoCodeSmell = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='CODE_SMELL')][?(@.severity=='INFO')]");
        totalInfoCodeSmell=totalInfoCodeSmell+jsons:getInt(infoCodeSmell,"$.length()");

        blockerVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='BLOCKER')]");
        totalBlockerVulnerabilities=totalBlockerVulnerabilities+jsons:getInt(blockerVulnerabilities,"$.length()");

        criticalVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='CRITICAL')]");
        totalCriticalVulnerabilities=totalCriticalVulnerabilities+jsons:getInt(criticalVulnerabilities,"$.length()");

        majorVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='MAJOR')]");
        totalMajorVulnerabilities=totalMajorVulnerabilities+jsons:getInt(majorVulnerabilities,"$.length()");

        minorVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='MINOR')]");
        totalMinorVulnerabilities=totalMinorVulnerabilities+jsons:getInt(minorVulnerabilities,"$.length()");

        infoVulnerabilities = jsons:getJson(sonarJSONResponse, "$.issues.[?(@.type=='VULNERABILITY')][?(@.severity=='INFO')]");
        totalInfoVulnerabilities=totalInfoVulnerabilities+jsons:getInt(infoVulnerabilities,"$.length()");


    }
    total=jsons:getInt(sonarJSONResponse,"$.total");

    json returnJson={"Total":total,"bb":totalBlockerBugs,"cb":totalCriticalBugs,"mab":totalMajorBugs,"mib":totalMinorBugs,"ib":totalInfoBugs,"bc":totalBlockerCodeSmells,
                        "cc":totalCriticalCodeSmells,"mac":totalMajorCodeSmells,"mic":totalMinorCodeSmells,"ic":totalInfoCodeSmell,"bv":totalBlockerVulnerabilities,"cv":totalCriticalVulnerabilities,
                        "mav":totalMajorVulnerabilities,"miv":totalMinorVulnerabilities,"iv":totalInfoVulnerabilities};
    return returnJson;
}

function getSelectionResult(string category,int selected, int issueType , int severity)(json){
    json ret={};
    if(category=="all"){
        if(issueType!=0 && severity==0){
            ret= getAllAreaSonarIssuesForType(issueType);
        }else if(severity!=0 && issueType==0){
            ret= getAllAreaSonarIssuesForSeverity(severity);
        }else if(issueType==0 && severity==0){
            ret= getAllAreaSonarIssues();
        }else{
            ret= getAllAreaSonarIssuesForTypeAndSeverity(issueType, severity);
        }
    }else if(category=="area"){
        if(issueType!=0 && severity==0){
            ret= getSelectedAreaSonarIssuesForType(selected,issueType);
        }else if(severity!=0 && issueType==0){
            ret= getSelectedAreaSonarIssuesForSeverity(selected,severity);
        }else if(issueType==0 && severity==0){
            ret= getSelectedAreaSonarIssues(selected);
        }else{
            ret= getSelectedAreaSonarIssuesForTypeAndSeverity(selected, issueType, severity);
        }
    }else if(category=="product"){
        if(issueType!=0 && severity==0){
            ret= getSelectedProductSonarIssuesForType(selected,issueType);
        }else if(severity!=0 && issueType==0){
            ret= getSelectedProductSonarIssuesForSeverity(selected,severity);
        }else if(issueType==0 && severity==0){
            ret= getSelectedProductSonarIssues(selected);
        }else{
            ret= getSelectedProductSonarIssuesForTypeAndSeverity(selected, issueType, severity);
        }
    }else if(category=="component"){
        if(issueType!=0 && severity==0){
            ret= getSelectedComponentSonarIssuesForType(selected,issueType);
        }else if(severity!=0 && issueType==0){
            ret= getSelectedComponentSonarIssuesForSeverity(selected,severity);
        }else if(issueType==0 && severity==0){
            ret= getSelectedComponentSonarIssues(selected);
        }else{
            ret= getSelectedComponentSonarIssuesForTypeAndSeverity(selected, issueType, severity);
        }
    }

    return ret;
}

function getSelectionHistory(string start, string end, string period, string category,int selected, int issueType , int severity)(json){
    json ret={};
    if(period=="day"){
        if(category=="all"){
            if(issueType!=0 && severity==0){
                ret= getDailyHistoryAllAreaForType(start, end, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getDailyHistoryAllAreaForSeverity(start,end,severity);
            }else if(issueType==0 && severity==0){
                ret= getDailyHistoryAllArea(start,end);
            }else{
                ret= getDailyHistoryAllAreaForTypeAndSeverity(start, end, issueType, severity);
            }
        }else if(category=="area"){
            if(issueType!=0 && severity==0){
                ret= getDailyHistorySelectedAreaForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getDailyHistorySelectedAreaForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getDailyHistorySelectedArea(start,end,selected);
            }else{
                ret= getDailyHistorySelectedAreaForTypeAndSeverity(start, end, selected ,issueType, severity);
            }
        }else if(category=="product"){
            if(issueType!=0 && severity==0){
                ret= getDailyHistorySelectedProductForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getDailyHistorySelectedProductForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getDailyHistorySelectedProduct(start,end,selected);
            }else{
                ret= getDailyHistorySelectedProductForTypeAndSeverity(start, end, selected ,issueType, severity);
            }
        }else if(category=="component"){
            if(issueType!=0 && severity==0){
                ret= getDailyHistorySelectedComponentForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getDailyHistorySelectedComponentForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getDailyHistorySelectedComponent(start,end,selected);
            }else{
                ret= getDailyHistorySelectedComponentForTypeAndSeverity(start, end,  selected ,issueType, severity);
            }
        }
    }else if(period=="Month"){
        if(category=="all"){
            if(issueType!=0 && severity==0){
                ret= getMonthlyHistoryAllAreaForType(start, end, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getMonthlyHistoryAllAreaForSeverity(start,end,severity);
            }else if(issueType==0 && severity==0){
                ret= getMonthlyHistoryAllArea(start,end);
            }else{
                ret= getMonthlyHistoryAllAreaForTypeAndSeverity(start, end, issueType, severity);
            }
        }else if(category=="area"){
            if(issueType!=0 && severity==0){
                ret= getMonthlyHistorySelectedAreaForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getMonthlyHistorySelectedAreaForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getMonthlyHistorySelectedArea(start,end,selected);
            }else{
                ret= getMonthlyHistorySelectedAreaForTypeAndSeverity(start, end,selected ,issueType, severity);
            }
        }else if(category=="product"){
            if(issueType!=0 && severity==0){
                ret= getMonthlyHistorySelectedProductForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getMonthlyHistorySelectedProductForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getMonthlyHistorySelectedProduct(start,end,selected);
            }else{
                ret= getMonthlyHistorySelectedProductForTypeAndSeverity(start, end,selected ,issueType, severity);
            }
        }else if(category=="component"){
            if(issueType!=0 && severity==0){
                ret= getMonthlyHistorySelectedComponentForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getMonthlyHistorySelectedComponentForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getMonthlyHistorySelectedComponent(start,end,selected);
            }else{
                ret= getMonthlyHistorySelectedComponentForTypeAndSeverity(start, end,selected ,issueType, severity);
            }
        }
    }else if(period=="Quarter"){
        if(category=="all"){
            if(issueType!=0 && severity==0){
                ret= getQuarterlyHistoryAllAreaForType(start, end, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getQuarterlyHistoryAllAreaForSeverity(start,end,severity);
            }else if(issueType==0 && severity==0){
                ret= getQuarterlyHistoryAllArea(start,end);
            }else{
                ret= getQuarterlyHistoryAllAreaForTypeAndSeverity(start, end, issueType, severity);
            }
        }else if(category=="area"){
            if(issueType!=0 && severity==0){
                ret= getQuarterlyHistorySelectedAreaForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getQuarterlyHistorySelectedAreaForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getQuarterlyHistorySelectedArea(start,end,selected);
            }else{
                ret= getQuarterlyHistorySelectedAreaForTypeAndSeverity(start, end,selected ,issueType, severity);
            }
        }else if(category=="product"){
            if(issueType!=0 && severity==0){
                ret= getQuarterlyHistorySelectedProductForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getQuarterlyHistorySelectedProductForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getQuarterlyHistorySelectedProduct(start,end,selected);
            }else{
                ret= getQuarterlyHistorySelectedProductForTypeAndSeverity(start, end,selected ,issueType, severity);
            }
        }else if(category=="component"){
            if(issueType!=0 && severity==0){
                ret= getQuarterlyHistorySelectedComponentForType(start, end,selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getQuarterlyHistorySelectedComponentForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getQuarterlyHistorySelectedComponent(start,end,selected);
            }else{
                ret= getQuarterlyHistorySelectedComponentForTypeAndSeverity(start, end,selected ,issueType, severity);
            }
        }

    }else if(period=="Year"){
        if(category=="all"){
            if(issueType!=0 && severity==0){
                ret= getYearlyHistoryAllAreaForType(start, end, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getYearlyHistoryAllAreaForSeverity(start,end,severity);
            }else if(issueType==0 && severity==0){
                ret= getYearlyHistoryAllArea(start,end);
            }else{
                ret= getYearlyHistoryAllAreaForTypeAndSeverity(start, end, issueType, severity);
            }
        }else if(category=="area"){
            if(issueType!=0 && severity==0){
                ret= getYearlyHistorySelectedAreaForType(start, end,selected ,issueType);
            }else if(severity!=0 && issueType==0){
                ret= getYearlyHistorySelectedAreaForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getYearlyHistorySelectedArea(start,end,selected);
            }else{
                ret= getYearlyHistorySelectedAreaForTypeAndSeverity(start, end,selected,issueType, severity);
            }
        }else if(category=="product"){
            if(issueType!=0 && severity==0){
                ret= getYearlyHistorySelectedProductForType(start, end,selected ,issueType);
            }else if(severity!=0 && issueType==0){
                ret= getYearlyHistorySelectedProductForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getYearlyHistorySelectedProduct(start,end,selected);
            }else{
                ret= getYearlyHistorySelectedProductForTypeAndSeverity(start, end,selected,issueType, severity);
            }
        }else if(category=="component"){
            if(issueType!=0 && severity==0){
                ret= getYearlyHistorySelectedComponentForType(start, end,selected ,issueType);
            }else if(severity!=0 && issueType==0){
                ret= getYearlyHistorySelectedComponentForSeverity(start,end,selected,severity);
            }else if(issueType==0 && severity==0){
                ret= getYearlyHistorySelectedComponent(start,end,selected);
            }else{
                ret= getYearlyHistorySelectedComponentForTypeAndSeverity(start, end,selected,issueType, severity);
            }
        }
    }

    return ret;
}

function getAllAreaSonarIssues () (json) {
    json data = {"error":false};
    json allAreas = {"items":[], "sonarIssuetype":[], "sonarSeverity":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;
    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    datatable dt = sql:ClientConnector.select(dbConnector,GET_ALL_AREAS, params);
    Areas area;
    while (datatables:hasNext(dt)) {
        any row1 = datatables:next(dt);
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;


        int sonars=0;
        sql:Parameter pqd_area_id_para = {sqlType:"integer", value:area_id};
        params = [pqd_area_id_para];
        datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_AREA , params);
        Components comps;
        while (datatables:hasNext(cdt)) {
            any row0 = datatables:next(cdt);
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:"integer", value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (datatables:hasNext(idt)) {
                any row2 = datatables:next(idt);
                si, err = (SonarIssues )row2;

                int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
                int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
                int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
                int tot = si.total;

                BUGS= BUGS +bb+cb+mab+mib+ib;
                CODESMELLS= CODESMELLS +bc+cc+mac+mic+ic;
                VULNERABILITIES= VULNERABILITIES +bv+cv+mav+miv+iv;
                BLOCKER = BLOCKER + bb+bc+bv;
                CRITICAL = CRITICAL + cb+cc+cv;
                MAJOR = MAJOR + mab+mac+mav;
                MINOR = MINOR + mib+mic+miv;
                INFO = INFO + ib+ic+iv;
                sonars=sonars+tot;
            }
            datatables:close(idt);
        }
        datatables:close(cdt);

        json area_issues = {"name":area_name, "id":area_id, "sonar":sonars};
        jsons:addToArray(allAreas, "$.items", area_issues);


    }
    datatables:close(dt);
    dbConnector.close();
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    jsons:addToArray(allAreas, "$.sonarIssuetype",bugs );
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    jsons:addToArray(allAreas, "$.sonarIssuetype",codesmells );
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    jsons:addToArray(allAreas, "$.sonarIssuetype",vulnerabilities);
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    jsons:addToArray(allAreas, "$.sonarSeverity",blocker);
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    jsons:addToArray(allAreas, "$.sonarSeverity",critical);
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    jsons:addToArray(allAreas, "$.sonarSeverity",major);
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    jsons:addToArray(allAreas, "$.sonarSeverity",minor);
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    jsons:addToArray(allAreas, "$.sonarSeverity",info);

    jsons:addToObject(data, "$", "data",allAreas);
    return data;
}

function getAllAreaSonarIssuesForTypeAndSeverity (int issueType, int severity) (json) {
    json data = {"error":false};
    json allAreas = {"items":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    datatable dt = sql:ClientConnector.select(dbConnector,GET_ALL_AREAS, params);
    Areas area;
    while (datatables:hasNext(dt)) {
        any row1 = datatables:next(dt);
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;


        int sonars=0;
        sql:Parameter pqd_area_id_para = {sqlType:"integer", value:area_id};
        params = [pqd_area_id_para];
        datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_AREA , params);
        Components comps;
        while (datatables:hasNext(cdt)) {
            any row0 = datatables:next(cdt);
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:"integer", value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (datatables:hasNext(idt)) {
                any row2 = datatables:next(idt);
                si, err = (SonarIssues )row2;

                int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
                int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
                int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
                int tot=0;
                if(severity==1 && issueType==1){
                    tot = bb;
                }else if(severity==1 && issueType==2){
                    tot = bc;
                }else if(severity==1 && issueType==3){
                    tot = bv;
                }else if(severity==2 && issueType==1){
                    tot = cb;
                }else if(severity==2 && issueType==2){
                    tot = cc;
                }else if(severity==2 && issueType==3){
                    tot = cv;
                }else if(severity==3 && issueType==1){
                    tot = mab;
                }else if(severity==3 && issueType==2){
                    tot = mac;
                }else if(severity==3 && issueType==3){
                    tot = mav;
                }else if(severity==4 && issueType==1){
                    tot = mib;
                }else if(severity==4 && issueType==2){
                    tot = mic;
                }else if(severity==4 && issueType==3){
                    tot = miv;
                }else if(severity==5 && issueType==1){
                    tot = ib;
                }else if(severity==5 && issueType==2){
                    tot = ic;
                }else if(severity==5 && issueType==3){
                    tot = iv;
                }else{
                    jsons:set(data,"$.error",true);
                    return data;
                }

                sonars=sonars+tot;
            }
            datatables:close(idt);
        }
        datatables:close(cdt);

        json area_issues = {"name":area_name, "id":area_id, "sonar":sonars};
        jsons:addToArray(allAreas, "$.items", area_issues);


    }
    datatables:close(dt);
    dbConnector.close();

    jsons:addToObject(data, "$", "data",allAreas);
    return data;
}

function getAllAreaSonarIssuesForSeverity (int severity) (json) {
    json data = {"error":false};
    json allAreas = {"items":[], "sonarIssuetype":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;

    datatable dt = sql:ClientConnector.select(dbConnector,GET_ALL_AREAS, params);
    Areas area;
    while (datatables:hasNext(dt)) {
        any row1 = datatables:next(dt);
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;

        int sonars=0;
        sql:Parameter pqd_area_id_para = {sqlType:"integer", value:area_id};
        params = [pqd_area_id_para];
        datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_AREA , params);
        Components comps;
        while (datatables:hasNext(cdt)) {
            any row0 = datatables:next(cdt);
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:"integer", value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (datatables:hasNext(idt)) {
                any row2 = datatables:next(idt);
                si, err = (SonarIssues )row2;

                int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
                int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
                int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
                int tot=0;
                if(severity==1){
                    tot = bb+bc+bv;
                    BUGS= BUGS +bb;
                    CODESMELLS= CODESMELLS +bc;
                    VULNERABILITIES= VULNERABILITIES +bv;
                }else if(severity==2){
                    tot = cb+cc+cv;
                    BUGS= BUGS +cb;
                    CODESMELLS= CODESMELLS +cc;
                    VULNERABILITIES= VULNERABILITIES +cv;
                }else if(severity==3){
                    tot = mab+mac+mav;
                    BUGS= BUGS +mab;
                    CODESMELLS= CODESMELLS + mac;
                    VULNERABILITIES= VULNERABILITIES + mav;
                }else if(severity==4){
                    tot = mib+mic+miv;
                    BUGS= BUGS +mib;
                    CODESMELLS= CODESMELLS + mic;
                    VULNERABILITIES= VULNERABILITIES + miv;
                }else if(severity==5){
                    tot = ib+ic+iv;
                    BUGS= BUGS +ib;
                    CODESMELLS= CODESMELLS + ic;
                    VULNERABILITIES= VULNERABILITIES + iv;
                }else{
                    jsons:set(data,"$.error",true);
                    return data;
                }

                sonars=sonars+tot;
            }
            datatables:close(idt);
        }
        datatables:close(cdt);

        json area_issues = {"name":area_name, "id":area_id, "sonar":sonars};
        jsons:addToArray(allAreas, "$.items", area_issues);


    }
    datatables:close(dt);
    dbConnector.close();
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    jsons:addToArray(allAreas, "$.sonarIssuetype",bugs );
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    jsons:addToArray(allAreas, "$.sonarIssuetype",codesmells );
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    jsons:addToArray(allAreas, "$.sonarIssuetype",vulnerabilities);

    jsons:addToObject(data, "$", "data",allAreas);
    return data;
}

function getAllAreaSonarIssuesForType (int issueType) (json) {
    json data = {"error":false};
    json allAreas = {"items":[],"sonarSeverity":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BLOCKER=0;
    int CRITICAL=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    datatable dt = sql:ClientConnector.select(dbConnector,GET_ALL_AREAS, params);
    Areas area;
    while (datatables:hasNext(dt)) {
        any row1 = datatables:next(dt);
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;

        int sonars=0;
        sql:Parameter pqd_area_id_para = {sqlType:"integer", value:area_id};
        params = [pqd_area_id_para];
        datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_AREA , params);
        Components comps;
        while (datatables:hasNext(cdt)) {
            any row0 = datatables:next(cdt);
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:"integer", value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (datatables:hasNext(idt)) {
                any row2 = datatables:next(idt);
                si, err = (SonarIssues )row2;

                int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
                int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
                int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
                int tot=0;
                if(issueType==1){
                    tot=bb+cb+mab+mib+ib;
                    BLOCKER = BLOCKER + bb;
                    CRITICAL = CRITICAL + cb;
                    MAJOR = MAJOR + mab;
                    MINOR = MINOR + mib;
                    INFO = INFO + ib;
                }else if(issueType==2){
                    tot=bc+cc+mac+mic+ic;
                    BLOCKER = BLOCKER + bc;
                    CRITICAL = CRITICAL + cc;
                    MAJOR = MAJOR + mac;
                    MINOR = MINOR + mic;
                    INFO = INFO + ic;
                }else if(issueType==3){
                    tot=bv+cv+mav+miv+iv;
                    BLOCKER = BLOCKER + bv;
                    CRITICAL = CRITICAL + cv;
                    MAJOR = MAJOR + mav;
                    MINOR = MINOR + miv;
                    INFO = INFO + iv;
                }else{
                    jsons:set(data,"$.error",true);
                    return data;
                }
                sonars=sonars+tot;
            }
            datatables:close(idt);
        }
        datatables:close(cdt);

        json area_issues = {"name":area_name, "id":area_id, "sonar":sonars};
        jsons:addToArray(allAreas, "$.items", area_issues);


    }
    datatables:close(dt);
    dbConnector.close();
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    jsons:addToArray(allAreas, "$.sonarSeverity",blocker);
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    jsons:addToArray(allAreas, "$.sonarSeverity",critical);
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    jsons:addToArray(allAreas, "$.sonarSeverity",major);
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    jsons:addToArray(allAreas, "$.sonarSeverity",minor);
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    jsons:addToArray(allAreas, "$.sonarSeverity",info);

    jsons:addToObject(data, "$", "data",allAreas);
    return data;
}

function getSelectedAreaSonarIssues (int selected) (json) {
    json data = {"error":false};
    json allProducts = {"name":selected,"items":[], "sonarIssuetype":[], "sonarSeverity":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;
    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    sql:Parameter pqd_area_id_para = {sqlType:"integer" , value:selected};
    params = [pqd_area_id_para];
    datatable pdt = sql:ClientConnector.select(dbConnector,GET_PRODUCTS_OF_AREA, params);
    Products product;
    while (datatables:hasNext(pdt)) {
        int sonars=0;
        any rowp = datatables:next(pdt);
        product,err = (Products)rowp;

        int product_id = product.pqd_product_id;
        string product_name = product.pqd_product_name;

        sql:Parameter pqd_product_id_para = {sqlType:"integer",value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_PRODUCT , params);
        Components comps;
        while (datatables:hasNext(cdt)) {
            any row0 = datatables:next(cdt);
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;

            sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:"integer", value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (datatables:hasNext(idt)) {
                any row2 = datatables:next(idt);
                si, err = (SonarIssues )row2;

                int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
                int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
                int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
                int tot = si.total;

                BUGS= BUGS +bb+cb+mab+mib+ib;
                CODESMELLS= CODESMELLS +bc+cc+mac+mic+ic;
                VULNERABILITIES= VULNERABILITIES +bv+cv+mav+miv+iv;
                BLOCKER = BLOCKER + bb+bc+bv;
                CRITICAL = CRITICAL + cb+cc+cv;
                MAJOR = MAJOR + mab+mac+mav;
                MINOR = MINOR + mib+mic+miv;
                INFO = INFO + ib+ic+iv;
                sonars=sonars+tot;
            }
            datatables:close(idt);
        }
        datatables:close(cdt);

        json product_issues = {"name":product_name, "id":product_id, "sonar":sonars};
        jsons:addToArray( allProducts, "$.items", product_issues);
    }
    datatables:close(pdt);

    dbConnector.close();
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    jsons:addToArray( allProducts, "$.sonarIssuetype",bugs );
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    jsons:addToArray( allProducts, "$.sonarIssuetype",codesmells );
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    jsons:addToArray( allProducts, "$.sonarIssuetype",vulnerabilities);
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    jsons:addToArray( allProducts, "$.sonarSeverity",blocker);
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    jsons:addToArray( allProducts, "$.sonarSeverity",critical);
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    jsons:addToArray( allProducts, "$.sonarSeverity",major);
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    jsons:addToArray( allProducts, "$.sonarSeverity",minor);
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    jsons:addToArray( allProducts, "$.sonarSeverity",info);

    jsons:addToObject(data, "$", "data", allProducts);
    return data;
}

function getSelectedAreaSonarIssuesForTypeAndSeverity (int selected, int issueType, int severity) (json) {
    json data = {"error":false};
    json allProducts = {"name":selected,"items":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    sql:Parameter pqd_area_id_para = {sqlType:"integer" , value:selected};
    params = [pqd_area_id_para];
    datatable pdt = sql:ClientConnector.select(dbConnector,GET_PRODUCTS_OF_AREA, params);
    Products product;
    while (datatables:hasNext(pdt)) {
        int sonars=0;
        any rowp = datatables:next(pdt);
        product,err = (Products)rowp;

        int product_id = product.pqd_product_id;
        string product_name = product.pqd_product_name;

        sql:Parameter pqd_product_id_para = {sqlType:"integer",value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_PRODUCT , params);
        Components comps;
        while (datatables:hasNext(cdt)) {
            any row0 = datatables:next(cdt);
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;

            sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:"integer", value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (datatables:hasNext(idt)) {
                any row2 = datatables:next(idt);
                si, err = (SonarIssues )row2;

                int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
                int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
                int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
                int tot=0;
                if(severity==1 && issueType==1){
                    tot = bb;
                }else if(severity==1 && issueType==2){
                    tot = bc;
                }else if(severity==1 && issueType==3){
                    tot = bv;
                }else if(severity==2 && issueType==1){
                    tot = cb;
                }else if(severity==2 && issueType==2){
                    tot = cc;
                }else if(severity==2 && issueType==3){
                    tot = cv;
                }else if(severity==3 && issueType==1){
                    tot = mab;
                }else if(severity==3 && issueType==2){
                    tot = mac;
                }else if(severity==3 && issueType==3){
                    tot = mav;
                }else if(severity==4 && issueType==1){
                    tot = mib;
                }else if(severity==4 && issueType==2){
                    tot = mic;
                }else if(severity==4 && issueType==3){
                    tot = miv;
                }else if(severity==5 && issueType==1){
                    tot = ib;
                }else if(severity==5 && issueType==2){
                    tot = ic;
                }else if(severity==5 && issueType==3){
                    tot = iv;
                }else{
                    jsons:set(data,"$.error",true);
                    return data;
                }

                sonars=sonars+tot;
            }
            datatables:close(idt);
        }
        datatables:close(cdt);

        json product_issues = {"name":product_name, "id":product_id, "sonar":sonars};
        jsons:addToArray( allProducts, "$.items", product_issues);
    }
    datatables:close(pdt);

    dbConnector.close();

    jsons:addToObject(data, "$", "data", allProducts);
    return data;
}

function getSelectedAreaSonarIssuesForSeverity(int selected,int severity)(json){
    json data = {"error":false};
    json allProducts = {"name":"","items":[], "sonarIssuetype":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;

    int area_id;
    sql:Parameter pqd_area_id_para = {sqlType:"integer" , value:selected};
    params = [pqd_area_id_para];
    datatable pdt = sql:ClientConnector.select(dbConnector,GET_PRODUCTS_OF_AREA, params);
    Products product;
    while (datatables:hasNext(pdt)) {
        int sonars=0;
        any rowp = datatables:next(pdt);
        product,err = (Products)rowp;

        int product_id = product.pqd_product_id;
        string product_name = product.pqd_product_name;

        sql:Parameter pqd_product_id_para = {sqlType:"integer",value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_PRODUCT , params);
        Components comps;
        while (datatables:hasNext(cdt)) {
            any row0 = datatables:next(cdt);
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;

            sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:"integer", value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (datatables:hasNext(idt)) {
                any row2 = datatables:next(idt);
                si, err = (SonarIssues )row2;

                int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
                int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
                int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
                int tot=0;
                if(severity==1){
                    tot = bb+bc+bv;
                    BUGS= BUGS +bb;
                    CODESMELLS= CODESMELLS +bc;
                    VULNERABILITIES= VULNERABILITIES +bv;
                }else if(severity==2){
                    tot = cb+cc+cv;
                    BUGS= BUGS +cb;
                    CODESMELLS= CODESMELLS +cc;
                    VULNERABILITIES= VULNERABILITIES +cv;
                }else if(severity==3){
                    tot = mab+mac+mav;
                    BUGS= BUGS +mab;
                    CODESMELLS= CODESMELLS + mac;
                    VULNERABILITIES= VULNERABILITIES + mav;
                }else if(severity==4){
                    tot = mib+mic+miv;
                    BUGS= BUGS +mib;
                    CODESMELLS= CODESMELLS + mic;
                    VULNERABILITIES= VULNERABILITIES + miv;
                }else if(severity==5){
                    tot = ib+ic+iv;
                    BUGS= BUGS +ib;
                    CODESMELLS= CODESMELLS + ic;
                    VULNERABILITIES= VULNERABILITIES + iv;
                }else{
                    jsons:set(data,"$.error",true);
                    return data;
                }

                sonars=sonars+tot;
            }
            datatables:close(idt);
        }
        datatables:close(cdt);

        json product_issues = {"name":product_name, "id":product_id, "sonar":sonars};
        jsons:addToArray( allProducts, "$.items", product_issues);
    }
    datatables:close(pdt);

    dbConnector.close();
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    jsons:addToArray( allProducts, "$.sonarIssuetype",bugs );
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    jsons:addToArray( allProducts, "$.sonarIssuetype",codesmells );
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    jsons:addToArray( allProducts, "$.sonarIssuetype",vulnerabilities);

    jsons:addToObject(data, "$", "data", allProducts);
    return data;
}

function getSelectedAreaSonarIssuesForType(int selected, int issueType)(json){
    json data = {"error":false};
    json allProducts = {"name":"","items":[],"sonarSeverity":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BLOCKER=0;
    int CRITICAL=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    int area_id;
    sql:Parameter pqd_area_id_para = {sqlType:"integer" , value:selected};
    params = [pqd_area_id_para];
    datatable pdt = sql:ClientConnector.select(dbConnector,GET_PRODUCTS_OF_AREA, params);
    Products product;
    while (datatables:hasNext(pdt)) {
        int sonars=0;
        any rowp = datatables:next(pdt);
        product,err = (Products)rowp;

        int product_id = product.pqd_product_id;
        string product_name = product.pqd_product_name;
        sql:Parameter pqd_product_id_para = {sqlType:"integer",value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_PRODUCT , params);
        Components comps;
        while (datatables:hasNext(cdt)) {
            any row0 = datatables:next(cdt);
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:"integer", value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (datatables:hasNext(idt)) {
                any row2 = datatables:next(idt);
                si, err = (SonarIssues )row2;

                int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
                int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
                int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
                int tot=0;
                if(issueType==1){
                    tot=bb+cb+mab+mib+ib;
                    BLOCKER = BLOCKER + bb;
                    CRITICAL = CRITICAL + cb;
                    MAJOR = MAJOR + mab;
                    MINOR = MINOR + mib;
                    INFO = INFO + ib;
                }else if(issueType==2){
                    tot=bc+cc+mac+mic+ic;
                    BLOCKER = BLOCKER + bc;
                    CRITICAL = CRITICAL + cc;
                    MAJOR = MAJOR + mac;
                    MINOR = MINOR + mic;
                    INFO = INFO + ic;
                }else if(issueType==3){
                    tot=bv+cv+mav+miv+iv;
                    BLOCKER = BLOCKER + bv;
                    CRITICAL = CRITICAL + cv;
                    MAJOR = MAJOR + mav;
                    MINOR = MINOR + miv;
                    INFO = INFO + iv;
                }else{
                    jsons:set(data,"$.error",true);
                    return data;
                }
                sonars=sonars+tot;
            }
            datatables:close(idt);
        }
        datatables:close(cdt);

        json product_issues = {"name":product_name, "id":product_id, "sonar":sonars};
        jsons:addToArray( allProducts, "$.items", product_issues);
    }
    datatables:close(pdt);

    dbConnector.close();
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    jsons:addToArray( allProducts, "$.sonarSeverity",blocker);
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    jsons:addToArray( allProducts, "$.sonarSeverity",critical);
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    jsons:addToArray( allProducts, "$.sonarSeverity",major);
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    jsons:addToArray( allProducts, "$.sonarSeverity",minor);
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    jsons:addToArray( allProducts, "$.sonarSeverity",info);

    jsons:addToObject(data, "$", "data", allProducts);
    return data;
}

function getSelectedProductSonarIssues (int selected)(json){
    json data = {"error":false};
    json allComponent = {"items":[], "sonarIssuetype":[], "sonarSeverity":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;
    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    sql:Parameter pqd_product_id_para = {sqlType:"integer", value:selected};
    params = [pqd_product_id_para];
    datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_PRODUCT , params);
    Components comps;
    boolean first_component_read=true;
    while (datatables:hasNext(cdt)) {
        int sonars=0;
        any row0 = datatables:next(cdt);
        comps, err = (Components)row0;

        string project_key = comps.sonar_project_key;
        int component_id = comps.pqd_component_id;
        string component_name=comps.pqd_component_name;

        sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
        sql:Parameter snapshot_id_para= {sqlType:"integer", value:snapshot_id};
        params = [sonar_project_key_para,snapshot_id_para];
        datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
        SonarIssues si;
        while (datatables:hasNext(idt)) {
            any row2 = datatables:next(idt);
            si, err = (SonarIssues )row2;

            int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
            int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
            int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
            int tot = si.total;

            BUGS= BUGS +bb+cb+mab+mib+ib;
            CODESMELLS= CODESMELLS +bc+cc+mac+mic+ic;
            VULNERABILITIES= VULNERABILITIES +bv+cv+mav+miv+iv;
            BLOCKER = BLOCKER + bb+bc+bv;
            CRITICAL = CRITICAL + cb+cc+cv;
            MAJOR = MAJOR + mab+mac+mav;
            MINOR = MINOR + mib+mic+miv;
            INFO = INFO + ib+ic+iv;
            sonars=sonars+tot;
        }
        datatables:close(idt);

        json component_issues = {"name":component_name, "id":component_id, "sonar":sonars};
        jsons:addToArray( allComponent, "$.items", component_issues);
    }
    datatables:close(cdt);


    dbConnector.close();
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    jsons:addToArray( allComponent, "$.sonarIssuetype",bugs );
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    jsons:addToArray( allComponent, "$.sonarIssuetype",codesmells );
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    jsons:addToArray( allComponent, "$.sonarIssuetype",vulnerabilities);
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    jsons:addToArray( allComponent, "$.sonarSeverity",blocker);
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    jsons:addToArray( allComponent, "$.sonarSeverity",critical);
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    jsons:addToArray( allComponent, "$.sonarSeverity",major);
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    jsons:addToArray( allComponent, "$.sonarSeverity",minor);
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    jsons:addToArray( allComponent, "$.sonarSeverity",info);

    jsons:addToObject(data, "$", "data", allComponent);
    return data;
}

function getSelectedProductSonarIssuesForTypeAndSeverity(int selected, int issueType, int severity)(json){
    json data = {"error":false};
    json allComponent = {"items":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    sql:Parameter pqd_product_id_para = {sqlType:"integer", value:selected};
    params = [pqd_product_id_para];
    boolean first_component_read=true;
    datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_PRODUCT, params);
    Components comps;
    while (datatables:hasNext(cdt)) {
        int sonars=0;
        any row0 = datatables:next(cdt);
        comps, err = (Components)row0;

        string project_key = comps.sonar_project_key;
        int component_id = comps.pqd_component_id;
        string component_name=comps.pqd_component_name;

        sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
        sql:Parameter snapshot_id_para= {sqlType:"integer", value:snapshot_id};
        params = [sonar_project_key_para,snapshot_id_para];
        datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
        SonarIssues si;
        while (datatables:hasNext(idt)) {
            any row2 = datatables:next(idt);
            si, err = (SonarIssues )row2;

            int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
            int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
            int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
            int tot=0;
            if(severity==1 && issueType==1){
                tot = bb;
            }else if(severity==1 && issueType==2){
                tot = bc;
            }else if(severity==1 && issueType==3){
                tot = bv;
            }else if(severity==2 && issueType==1){
                tot = cb;
            }else if(severity==2 && issueType==2){
                tot = cc;
            }else if(severity==2 && issueType==3){
                tot = cv;
            }else if(severity==3 && issueType==1){
                tot = mab;
            }else if(severity==3 && issueType==2){
                tot = mac;
            }else if(severity==3 && issueType==3){
                tot = mav;
            }else if(severity==4 && issueType==1){
                tot = mib;
            }else if(severity==4 && issueType==2){
                tot = mic;
            }else if(severity==4 && issueType==3){
                tot = miv;
            }else if(severity==5 && issueType==1){
                tot = ib;
            }else if(severity==5 && issueType==2){
                tot = ic;
            }else if(severity==5 && issueType==3){
                tot = iv;
            }else{
                jsons:set(data,"$.error",true);
                return data;
            }
            sonars=sonars+tot;
        }
        datatables:close(idt);

        json component_issues = {"name":component_name, "id":component_id, "sonar":sonars};
        jsons:addToArray( allComponent, "$.items", component_issues);
    }
    datatables:close(cdt);

    dbConnector.close();

    jsons:addToObject(data, "$", "data", allComponent);
    return data;
}

function getSelectedProductSonarIssuesForSeverity(int selected, int severity)(json){
    json data = {"error":false};
    json allComponent = {"items":[], "sonarIssuetype":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;

    sql:Parameter pqd_product_id_para = {sqlType:"integer", value:selected};
    params = [pqd_product_id_para];
    datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_PRODUCT, params);
    Components comps;
    while (datatables:hasNext(cdt)) {
        int sonars=0;
        any row0 = datatables:next(cdt);
        comps, err = (Components)row0;

        string project_key = comps.sonar_project_key;
        int component_id = comps.pqd_component_id;
        string component_name=comps.pqd_component_name;

        sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
        sql:Parameter snapshot_id_para= {sqlType:"integer", value:snapshot_id};
        params = [sonar_project_key_para,snapshot_id_para];
        datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
        SonarIssues si;
        while (datatables:hasNext(idt)) {
            any row2 = datatables:next(idt);
            si, err = (SonarIssues )row2;

            int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
            int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
            int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
            int tot=0;
            if(severity==1){
                tot = bb+bc+bv;
                BUGS= BUGS +bb;
                CODESMELLS= CODESMELLS +bc;
                VULNERABILITIES= VULNERABILITIES +bv;
            }else if(severity==2){
                tot = cb+cc+cv;
                BUGS= BUGS +cb;
                CODESMELLS= CODESMELLS +cc;
                VULNERABILITIES= VULNERABILITIES +cv;
            }else if(severity==3){
                tot = mab+mac+mav;
                BUGS= BUGS +mab;
                CODESMELLS= CODESMELLS + mac;
                VULNERABILITIES= VULNERABILITIES + mav;
            }else if(severity==4){
                tot = mib+mic+miv;
                BUGS= BUGS +mib;
                CODESMELLS= CODESMELLS + mic;
                VULNERABILITIES= VULNERABILITIES + miv;
            }else if(severity==5){
                tot = ib+ic+iv;
                BUGS= BUGS +ib;
                CODESMELLS= CODESMELLS + ic;
                VULNERABILITIES= VULNERABILITIES + iv;
            }else{
                jsons:set(data,"$.error",true);
                return data;
            }

            sonars=sonars+tot;
        }
        datatables:close(idt);

        json component_issues = {"name":component_name, "id":component_id, "sonar":sonars};
        jsons:addToArray( allComponent, "$.items", component_issues);
    }
    datatables:close(cdt);

    dbConnector.close();

    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    jsons:addToArray( allComponent, "$.sonarIssuetype",bugs );
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    jsons:addToArray( allComponent, "$.sonarIssuetype",codesmells );
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    jsons:addToArray( allComponent, "$.sonarIssuetype",vulnerabilities);

    jsons:addToObject(data, "$", "data", allComponent);
    return data;
}

function getSelectedProductSonarIssuesForType(int selected, int issueType)(json){
    json data = {"error":false};
    json allComponent = {"items":[],"sonarSeverity":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BLOCKER=0;
    int CRITICAL=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    sql:Parameter pqd_product_id_para = {sqlType:"integer", value:selected};
    params = [pqd_product_id_para];
    datatable cdt = sql:ClientConnector.select(dbConnector,GET_COMPONENT_OF_PRODUCT, params);
    Components comps;
    while (datatables:hasNext(cdt)) {
        int sonars=0;
        any row0 = datatables:next(cdt);
        comps, err = (Components)row0;

        string project_key = comps.sonar_project_key;
        int component_id = comps.pqd_component_id;
        string component_name=comps.pqd_component_name;

        sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
        sql:Parameter snapshot_id_para= {sqlType:"integer", value:snapshot_id};
        params = [sonar_project_key_para,snapshot_id_para];
        datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
        SonarIssues si;
        while (datatables:hasNext(idt)) {
            any row2 = datatables:next(idt);
            si, err = (SonarIssues )row2;

            int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
            int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
            int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
            int tot=0;
            if(issueType==1){
                tot=bb+cb+mab+mib+ib;
                BLOCKER = BLOCKER + bb;
                CRITICAL = CRITICAL + cb;
                MAJOR = MAJOR + mab;
                MINOR = MINOR + mib;
                INFO = INFO + ib;
            }else if(issueType==2){
                tot=bc+cc+mac+mic+ic;
                BLOCKER = BLOCKER + bc;
                CRITICAL = CRITICAL + cc;
                MAJOR = MAJOR + mac;
                MINOR = MINOR + mic;
                INFO = INFO + ic;
            }else if(issueType==3){
                tot=bv+cv+mav+miv+iv;
                BLOCKER = BLOCKER + bv;
                CRITICAL = CRITICAL + cv;
                MAJOR = MAJOR + mav;
                MINOR = MINOR + miv;
                INFO = INFO + iv;
            }else{
                jsons:set(data,"$.error",true);
                return data;
            }
            sonars=sonars+tot;
        }
        datatables:close(idt);
        json component_issues = {"name":component_name, "id":component_id, "sonar":sonars};
        jsons:addToArray( allComponent, "$.items", component_issues);
    }
    datatables:close(cdt);


    dbConnector.close();
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    jsons:addToArray( allComponent, "$.sonarSeverity",blocker);
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    jsons:addToArray( allComponent, "$.sonarSeverity",critical);
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    jsons:addToArray( allComponent, "$.sonarSeverity",major);
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    jsons:addToArray( allComponent, "$.sonarSeverity",minor);
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    jsons:addToArray( allComponent, "$.sonarSeverity",info);

    jsons:addToObject(data, "$", "data", allComponent);
    return data;
}

function getSelectedComponentSonarIssues(int selected)(json){
    json data = {"error":false};
    json allComponent = {"items":[],"sonarIssuetype":[], "sonarSeverity":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;
    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;
    string project_key;
    int product_id;
    sql:Parameter pqd_selected_id_para={sqlType:"integer",value:selected};
    params=[pqd_selected_id_para];
    datatable cdt = sql:ClientConnector.select(dbConnector,GET_DETAILS_OF_COMPONENT , params);
    Components comps;
    while (datatables:hasNext(cdt)){
        any row0 = datatables:next(cdt);
        comps, err = (Components)row0;
        project_key = comps.sonar_project_key;
        product_id= comps.pqd_product_id;
    }
    datatables:close(cdt);
    json returnjson = getSelectedProductSonarIssues(product_id);
    jsons:set(allComponent,"$.items",jsons:getJson(returnjson,"$.data.items"));
    sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
    sql:Parameter snapshot_id_para= {sqlType:"integer", value:snapshot_id};
    params = [sonar_project_key_para,snapshot_id_para];
    datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
    SonarIssues si;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        si, err = (SonarIssues )row2;

        int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
        int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
        int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
        int tot = si.total;

        BUGS= BUGS +bb+cb+mab+mib+ib;
        CODESMELLS= CODESMELLS +bc+cc+mac+mic+ic;
        VULNERABILITIES= VULNERABILITIES +bv+cv+mav+miv+iv;
        BLOCKER = BLOCKER + bb+bc+bv;
        CRITICAL = CRITICAL + cb+cc+cv;
        MAJOR = MAJOR + mab+mac+mav;
        MINOR = MINOR + mib+mic+miv;
        INFO = INFO + ib+ic+iv;
    }
    datatables:close(idt);

    dbConnector.close();
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    jsons:addToArray( allComponent, "$.sonarIssuetype",bugs );
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    jsons:addToArray( allComponent, "$.sonarIssuetype",codesmells );
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    jsons:addToArray( allComponent, "$.sonarIssuetype",vulnerabilities);
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    jsons:addToArray( allComponent, "$.sonarSeverity",blocker);
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    jsons:addToArray( allComponent, "$.sonarSeverity",critical);
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    jsons:addToArray( allComponent, "$.sonarSeverity",major);
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    jsons:addToArray( allComponent, "$.sonarSeverity",minor);
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    jsons:addToArray( allComponent, "$.sonarSeverity",info);

    jsons:addToObject(data, "$", "data", allComponent);
    return data;
}

function getSelectedComponentSonarIssuesForTypeAndSeverity(int selected,int issueType, int severity)(json){
    json data = {"error":false};
    json allComponent = {"items":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int product_id;
    sql:Parameter pqd_selected_id_para={sqlType:"integer",value:selected};
    params=[pqd_selected_id_para];
    datatable cdt = sql:ClientConnector.select(dbConnector,GET_DETAILS_OF_COMPONENT , params);
    Components comps;
    while (datatables:hasNext(cdt)){
        any row0 = datatables:next(cdt);
        comps, err = (Components)row0;
        product_id= comps.pqd_product_id;
    }
    datatables:close(cdt);
    json returnjson = getSelectedProductSonarIssuesForTypeAndSeverity(product_id,issueType,severity);
    jsons:set(allComponent,"$.items",jsons:getJson(returnjson,"$.data.items"));
    jsons:addToObject(data, "$", "data", allComponent);
    return data;
}

function getSelectedComponentSonarIssuesForSeverity(int selected,int severity)(json){
    json data = {"error":false};
    json allComponent = {"items":[], "sonarIssuetype":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;

    string project_key;
    int product_id;
    sql:Parameter pqd_selected_id_para={sqlType:"integer",value:selected};
    params=[pqd_selected_id_para];
    datatable cdt = sql:ClientConnector.select(dbConnector,GET_DETAILS_OF_COMPONENT , params);
    Components comps;
    while (datatables:hasNext(cdt)){
        any row0 = datatables:next(cdt);
        comps, err = (Components)row0;
        project_key = comps.sonar_project_key;
        product_id= comps.pqd_product_id;
    }
    datatables:close(cdt);
    json returnjson = getSelectedProductSonarIssuesForSeverity(product_id,severity);
    jsons:set(allComponent,"$.items",jsons:getJson(returnjson,"$.data.items"));
    sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
    sql:Parameter snapshot_id_para= {sqlType:"integer", value:snapshot_id};
    params = [sonar_project_key_para,snapshot_id_para];
    datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
    SonarIssues si;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        si, err = (SonarIssues )row2;

        int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
        int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
        int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
        if(severity==1){
            BUGS= BUGS +bb;
            CODESMELLS= CODESMELLS +bc;
            VULNERABILITIES= VULNERABILITIES +bv;
        }else if(severity==2){
            BUGS= BUGS +cb;
            CODESMELLS= CODESMELLS +cc;
            VULNERABILITIES= VULNERABILITIES +cv;
        }else if(severity==3){
            BUGS= BUGS +mab;
            CODESMELLS= CODESMELLS + mac;
            VULNERABILITIES= VULNERABILITIES + mav;
        }else if(severity==4){
            BUGS= BUGS +mib;
            CODESMELLS= CODESMELLS + mic;
            VULNERABILITIES= VULNERABILITIES + miv;
        }else if(severity==5){
            BUGS= BUGS +ib;
            CODESMELLS= CODESMELLS + ic;
            VULNERABILITIES= VULNERABILITIES + iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
    }
    datatables:close(idt);

    dbConnector.close();
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    jsons:addToArray( allComponent, "$.sonarIssuetype",bugs );
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    jsons:addToArray( allComponent, "$.sonarIssuetype",codesmells );
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    jsons:addToArray( allComponent, "$.sonarIssuetype",vulnerabilities);

    jsons:addToObject(data, "$", "data", allComponent);
    return data;
}

function getSelectedComponentSonarIssuesForType(int selected,int issueType)(json){
    json data = {"error":false};
    json allComponent = {"items":[], "sonarSeverity":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    sql:Parameter[] params = [];

    datatable ssdt = sql:ClientConnector.select(dbConnector,GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    errors:TypeCastError err;
    while (datatables:hasNext(ssdt)) {
        any row = datatables:next(ssdt);
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    datatables:close(ssdt);

    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;
    string project_key;
    int product_id;
    sql:Parameter pqd_selected_id_para={sqlType:"integer",value:selected};
    params=[pqd_selected_id_para];
    datatable cdt = sql:ClientConnector.select(dbConnector,GET_DETAILS_OF_COMPONENT , params);
    Components comps;
    while (datatables:hasNext(cdt)){
        any row0 = datatables:next(cdt);
        comps, err = (Components)row0;
        project_key = comps.sonar_project_key;
        product_id= comps.pqd_product_id;
    }
    datatables:close(cdt);
    json returnjson = getSelectedProductSonarIssuesForType(product_id,issueType);
    jsons:set(allComponent,"$.items",jsons:getJson(returnjson,"$.data.items"));
    sql:Parameter sonar_project_key_para = {sqlType:"varchar", value:project_key};
    sql:Parameter snapshot_id_para= {sqlType:"integer", value:snapshot_id};
    params = [sonar_project_key_para,snapshot_id_para];
    datatable idt = sql:ClientConnector.select(dbConnector,GET_ALL_OF_SONAR_ISSUES, params);
    SonarIssues si;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        si, err = (SonarIssues )row2;

        int bb = si.BLOCKER_BUG; int cb = si.CRITICAL_BUG; int mab = si.MAJOR_BUG; int mib = si.MINOR_BUG; int ib = si.INFO_BUG;
        int bc = si.BLOCKER_CODE_SMELL; int cc = si.CRITICAL_CODE_SMELL;int mac = si.MAJOR_CODE_SMELL;int mic = si.MINOR_CODE_SMELL;int ic = si.INFO_CODE_SMELL;
        int bv = si.BLOCKER_VULNERABILITY; int cv = si.CRITICAL_VULNERABILITY; int mav = si.MAJOR_VULNERABILITY; int miv = si.MINOR_VULNERABILITY;int iv = si.INFO_VULNERABILITY;
        if(issueType==1){
            BLOCKER = BLOCKER + bb;
            CRITICAL = CRITICAL + cb;
            MAJOR = MAJOR + mab;
            MINOR = MINOR + mib;
            INFO = INFO + ib;
        }else if(issueType==2){
            BLOCKER = BLOCKER + bc;
            CRITICAL = CRITICAL + cc;
            MAJOR = MAJOR + mac;
            MINOR = MINOR + mic;
            INFO = INFO + ic;
        }else if(issueType==3){
            BLOCKER = BLOCKER + bv;
            CRITICAL = CRITICAL + cv;
            MAJOR = MAJOR + mav;
            MINOR = MINOR + miv;
            INFO = INFO + iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
    }
    datatables:close(idt);

    dbConnector.close();

    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    jsons:addToArray( allComponent, "$.sonarSeverity",blocker);
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    jsons:addToArray( allComponent, "$.sonarSeverity",critical);
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    jsons:addToArray( allComponent, "$.sonarSeverity",major);
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    jsons:addToArray( allComponent, "$.sonarSeverity",minor);
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    jsons:addToArray( allComponent, "$.sonarSeverity",info);

    jsons:addToObject(data, "$", "data", allComponent);
    return data;
}

function authHeader (message req) (message) {
    string sonarAccessToken=jsons:getString(configData,"$.SONAR.SONAR_ACCESS_TOKEN");
    string token=sonarAccessToken+":";
    string encodedToken = utils:base64encode(token);
    string passingToken = "Basic "+encodedToken;
    messages:setHeader(req, "Authorization", passingToken);
    messages:setHeader(req, "Content-Type", "application/json");
    return req;

}

function getDailyHistoryAllArea (string start, string end) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_ALL_AREA, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.date;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistoryAllAreaForSeverity(string start,string end,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_ALL_AREA, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistoryAllAreaForType (string start, string end, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_ALL_AREA, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistoryAllAreaForTypeAndSeverity (string start, string end, int issueType, int severity) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_ALL_AREA, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistoryAllArea(string start, string end)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_ALL_AREA, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-"+dsi.month;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getMonthlyHistoryAllAreaForSeverity(string start, string end, int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_ALL_AREA, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistoryAllAreaForType (string start, string end, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_ALL_AREA, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistoryAllAreaForTypeAndSeverity (string start, string end, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_ALL_AREA, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistoryAllArea(string start, string end)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_ALL_AREA, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-Q"+dsi.quarter;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getQuarterlyHistoryAllAreaForSeverity(string start, string end, int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_ALL_AREA, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        string date=dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistoryAllAreaForType (string start, string end, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_ALL_AREA, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        string date= dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistoryAllAreaForTypeAndSeverity (string start, string end, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_ALL_AREA, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues )row2;
        string date= dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistoryAllArea(string start, string end)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_ALL_AREA, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        float tot = dsi.total;
        var date,_=<string> dsi.year;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getYearlyHistoryAllAreaForSeverity(string start, string end, int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_ALL_AREA, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues )row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistoryAllAreaForType (string start, string end, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_ALL_AREA, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistoryAllAreaForTypeAndSeverity (string start, string end, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_ALL_AREA, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}


function getDailyHistorySelectedArea (string start, string end,int selected) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_AREA, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.date;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedAreaForSeverity(string start,string end,int selected,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_AREA, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;

        string date= dsi.date;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedAreaForType (string start, string end, int selected,int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_AREA, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedAreaForTypeAndSeverity (string start, string end,int selected ,int issueType, int severity) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_AREA, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedArea(string start, string end,int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_AREA, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-"+dsi.month;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getMonthlyHistorySelectedAreaForSeverity(string start, string end,int selected ,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_AREA, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedAreaForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_AREA, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedAreaForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_AREA, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedArea(string start, string end,int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-Q"+dsi.quarter;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getQuarterlyHistorySelectedAreaForSeverity(string start, string end,int selected, int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        string date=dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedAreaForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        string date= dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedAreaForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues )row2;
        string date= dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedArea(string start, string end, int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_AREA, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        float tot = dsi.total;
        var date,_=<string> dsi.year;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getYearlyHistorySelectedAreaForSeverity(string start, string end,int selected ,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_AREA, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues )row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedAreaForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_AREA, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedAreaForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_AREA, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}


function getDailyHistorySelectedProduct (string start, string end,int selected) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.date;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedProductForSeverity(string start,string end,int selected,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedProductForType (string start, string end, int selected,int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedProductForTypeAndSeverity (string start, string end,int selected ,int issueType, int severity) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedProduct(string start, string end,int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-"+dsi.month;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getMonthlyHistorySelectedProductForSeverity(string start, string end,int selected ,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedProductForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedProductForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedProduct(string start, string end,int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-Q"+dsi.quarter;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getQuarterlyHistorySelectedProductForSeverity(string start, string end,int selected, int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        string date=dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedProductForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        string date= dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedProductForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues )row2;
        string date= dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedProduct(string start, string end, int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        float tot = dsi.total;
        var date,_=<string> dsi.year;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getYearlyHistorySelectedProductForSeverity(string start, string end,int selected ,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues )row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedProductForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedProductForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}


function getDailyHistorySelectedComponent (string start, string end,int selected) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.date;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedComponentForSeverity(string start,string end,int selected,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedComponentForType (string start, string end, int selected,int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getDailyHistorySelectedComponentForTypeAndSeverity (string start, string end,int selected ,int issueType, int severity) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT, params);
    DailySonarIssues dsi;

    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (DailySonarIssues)row2;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        string date= dsi.date;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedComponent(string start, string end,int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-"+dsi.month;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getMonthlyHistorySelectedComponentForSeverity(string start, string end,int selected ,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedComponentForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getMonthlyHistorySelectedComponentForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    MonthlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (MonthlySonarIssues)row2;
        string date= dsi.year+"-"+dsi.month;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedComponent(string start, string end,int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-Q"+dsi.quarter;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getQuarterlyHistorySelectedComponentForSeverity(string start, string end,int selected, int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        string date=dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedComponentForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues)row2;
        string date= dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getQuarterlyHistorySelectedComponentForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    QuarterlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (QuarterlySonarIssues )row2;
        string date= dsi.year+"-Q"+dsi.quarter;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedComponent(string start, string end, int selected)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        float tot = dsi.total;
        var date,_=<string> dsi.year;
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;

}

function getYearlyHistorySelectedComponentForSeverity(string start, string end,int selected ,int severity)(json){
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues )row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1){
            tot=bb+bc+bv;
        }else if(severity==2) {
            tot=cb+cc+cv;
        }else if(severity==3){
            tot=mab+mac+mav;
        }else if(severity==4){
            tot=mib+mic+miv;
        }else if(severity==5){
            tot=ib+ic+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedComponentForType (string start, string end,int selected, int issueType) (json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(issueType==1){
            tot=bb+cb+mab+mib+ib;
        }else if(issueType==2) {
            tot=bc+cc+mac+mic+ic;
        }else if(issueType==3){
            tot=bv+cv+mav+miv+iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}

function getYearlyHistorySelectedComponentForTypeAndSeverity (string start, string end,int selected, int issueType, int severity)(json) {
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    errors:TypeCastError err;
    sql:Parameter selected_id_para={sqlType:"integer",value:selected};
    sql:Parameter start_date_para = {sqlType:"varchar", value:start};
    sql:Parameter end_date_para = {sqlType:"varchar", value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sql:ClientConnector.select(dbConnector, GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    YearlySonarIssues dsi;
    while (datatables:hasNext(idt)) {
        any row2 = datatables:next(idt);
        dsi, err = (YearlySonarIssues)row2;
        var date,_=<string> dsi.year;
        float bb = dsi.BLOCKER_BUG; float cb = dsi.CRITICAL_BUG; float mab = dsi.MAJOR_BUG; float mib = dsi.MINOR_BUG; float ib = dsi.INFO_BUG;
        float bc = dsi.BLOCKER_CODE_SMELL; float cc = dsi.CRITICAL_CODE_SMELL;float mac = dsi.MAJOR_CODE_SMELL;float mic = dsi.MINOR_CODE_SMELL;float ic = dsi.INFO_CODE_SMELL;
        float bv = dsi.BLOCKER_VULNERABILITY; float cv = dsi.CRITICAL_VULNERABILITY; float mav = dsi.MAJOR_VULNERABILITY; float miv = dsi.MINOR_VULNERABILITY;float iv = dsi.INFO_VULNERABILITY;
        float tot=0;
        if(severity==1 && issueType==1){
            tot = bb;
        }else if(severity==1 && issueType==2){
            tot = bc;
        }else if(severity==1 && issueType==3){
            tot = bv;
        }else if(severity==2 && issueType==1){
            tot = cb;
        }else if(severity==2 && issueType==2){
            tot = cc;
        }else if(severity==2 && issueType==3){
            tot = cv;
        }else if(severity==3 && issueType==1){
            tot = mab;
        }else if(severity==3 && issueType==2){
            tot = mac;
        }else if(severity==3 && issueType==3){
            tot = mav;
        }else if(severity==4 && issueType==1){
            tot = mib;
        }else if(severity==4 && issueType==2){
            tot = mic;
        }else if(severity==4 && issueType==3){
            tot = miv;
        }else if(severity==5 && issueType==1){
            tot = ib;
        }else if(severity==5 && issueType==2){
            tot = ic;
        }else if(severity==5 && issueType==3){
            tot = iv;
        }else{
            jsons:set(data,"$.error",true);
            return data;
        }
        json history={"date":date,"count":tot};
        jsons:addToArray(allAreas,"$.data",history);
    }
    datatables:close(idt);
    dbConnector.close();

    jsons:set(data,"$.data",allAreas.data);
    return data;
}