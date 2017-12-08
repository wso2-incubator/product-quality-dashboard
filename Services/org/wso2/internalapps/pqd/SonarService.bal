package org.wso2.internalapps.pqd;

import ballerina.net.http;
import ballerina.data.sql;
import ballerina.util;
import ballerina.log;

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

@http:configuration {
    basePath:"/internal/product-quality/v1.0/sonar",
    httpsPort:9092,
    keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword:"ballerina",
    certPassword:"ballerina",
    trustStoreFile:"${ballerina.home}/bre/security/ballerinaTruststore.p12",
    trustStorePassword:"ballerina",
    ciphers:"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
    sslEnabledProtocols:"TLSv1.2,TLSv1.1"
}
service<http> SonarService {
    json configData = getConfigData(CONFIG_PATH);

    @http:resourceConfig {
        methods:["GET"],
        path:"/get-total-issues"
    }
    resource SonarTotalIsuueCount (http:Request req, http:Response res){
        http:HttpClient sonarCon=getHttpClientForSonar(configData);
        string path="/api/issues/search?resolved=no";
        json sonarResponse=getDataFromSonar(sonarCon,path,configData);
        int total;
        total,_=(int) sonarResponse.total;
        string tot=<string >total;
        string customTimeString = currentTime().format("yyyy-MM-dd  HH:mm:ss");
        json sonarPayload = {"Date":customTimeString, "TotalIssues":tot};
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setJsonPayload(sonarPayload);
         _ = res.send();

    }
    @http:resourceConfig {
         methods:["GET"],
         path:"/fetch-data"
    }
    resource saveIssuestoDB (http:Request req, http:Response res){
        http:HttpClient sonarCon=getHttpClientForSonar(configData);
        string path="/api/projects";
        json sonarResponse=getDataFromSonar(sonarCon,path,configData);
        saveIssuesToDatabase(sonarResponse, sonarCon, configData);
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setStringPayload("Data fetching from sonar began at "+currentTime().format("yyyy-MM-dd  HH:mm:ss"));
         _ = res.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/get-all-area-issues"
    }
    resource SonarAllAreaIssues (http:Request req, http:Response res){
        json data = getAllAreaSonarIssues();
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setJsonPayload(data);
         _ = res.send();

    }


    @http:resourceConfig {
        methods:["GET"],
        path:"/issues/issuetype/{issuetype}/severity/{severity}"
    }
    resource SonarGetIssuesFiltered (http:Request req,http:Response res, string issuetype, string severity) {
        map params = req.getQueryParams();
        var category, _ = (string)params.category;
        var categoryId, _=(string)params.categoryId;
        var catId,_=<int>categoryId;
        var issueTypeId,_=<int>issuetype;
        var severityId,_=<int>severity;
        json data = getSelectionResult(category,catId,issueTypeId,severityId);
        res.setJsonPayload(data);
        res.setHeader("Access-Control-Allow-Origin", "*");
         _ = res.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"issues/history/{category}/{categoryId}"
    }
    resource SonarGetHistory(http:Request req,http:Response res, string category, string categoryId){
        map params = req.getQueryParams();
        var start,_=(string)params.dateFrom;
        var end,_=(string)params.dateTo;
        var period,_=(string)params.period;
        var issueTypeId,_=(string)params.issuetypeId;
        var severityId,_=(string)params.severityId;
        var issueType,_=<int>issueTypeId;
        var severity,_=<int>severityId;
        var selected,_=<int>categoryId;
        json data = getSelectionHistory(start,end,period,category,selected,issueType,severity);
        res.setJsonPayload(data);
        res.setHeader("Access-Control-Allow-Origin", "*");
         _ = res.send();
    }
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

function getAllAreaSonarIssues () (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allAreas = {"items":[], "sonarIssuetype":[], "sonarSeverity":[]};
    sql:Parameter[] params = [];
    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;
    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    datatable dt = sqlEndPoint.select(GET_ALL_AREAS, params);
    Areas area;
    while(dt.hasNext()) {
        any row1 =dt.getNext();
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;


        int sonars=0;
        sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER, value:area_id};
        params = [pqd_area_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_AREA , params);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (idt.hasNext()) {
                any row2 = idt.getNext();
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
            idt.close();
        }
        cdt.close();

        json area_issues = {"name":area_name, "id":area_id, "sonar":sonars};
        allAreas.items[lengthof allAreas.items]=area_issues;


    }
    dt.close();
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    allAreas.sonarIssuetype[lengthof allAreas.sonarIssuetype]=bugs;
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    allAreas.sonarIssuetype[lengthof allAreas.sonarIssuetype]=codesmells;
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    allAreas.sonarIssuetype[lengthof allAreas.sonarIssuetype]=vulnerabilities;
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=blocker;
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=critical;
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=major;
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=minor;
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=info;

    data.data=allAreas;
    sqlEndPoint.close();
    return data;
}

function getAllAreaSonarIssuesForTypeAndSeverity (int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allAreas = {"items":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    datatable dt = sqlEndPoint.select(GET_ALL_AREAS, params);
    Areas area;
    while (dt.hasNext()) {
        any row1 = dt.getNext();
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;


        int sonars=0;
        sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER, value:area_id};
        params = [pqd_area_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_AREA , params);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (idt.hasNext()) {
                any row2 = idt.getNext();
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
                    data.error=true;

                }

                sonars=sonars+tot;
            }
            idt.close();
        }
        cdt.close();

        json area_issues = {"name":area_name, "id":area_id, "sonar":sonars};
        allAreas.items[lengthof allAreas.items]= area_issues;


    }
    dt.close();

    data.data=allAreas;
    sqlEndPoint.close();
    return data;
}

function getAllAreaSonarIssuesForSeverity (int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allAreas = {"items":[], "sonarIssuetype":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;

    datatable dt = sqlEndPoint.select(GET_ALL_AREAS, params);
    Areas area;
    while (dt.hasNext()) {
        any row1 = dt.getNext();
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;

        int sonars=0;
        sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER, value:area_id};
        params = [pqd_area_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_AREA , params);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (idt.hasNext()) {
                any row2 = idt.getNext();
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
                    data.error=true;

                }

                sonars=sonars+tot;
            }
            idt.close();
        }
        cdt.close();

        json area_issues = {"name":area_name, "id":area_id, "sonar":sonars};
        allAreas.items[lengthof allAreas.items]=area_issues;

    }
    dt.close();
    
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    allAreas.sonarIssuetype[lengthof allAreas.sonarIssuetype]=bugs;
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    allAreas.sonarIssuetype[lengthof allAreas.sonarIssuetype]=codesmells;
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    allAreas.sonarIssuetype[lengthof allAreas.sonarIssuetype]=vulnerabilities;

    data.data=allAreas;
    sqlEndPoint.close();
    return data;
}

function getAllAreaSonarIssuesForType (int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allAreas = {"items":[],"sonarSeverity":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BLOCKER=0;
    int CRITICAL=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    datatable dt = sqlEndPoint.select(GET_ALL_AREAS, params);
    Areas area;
    while (dt.hasNext()) {
        any row1 = dt.getNext();
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;

        int sonars=0;
        sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER, value:area_id};
        params = [pqd_area_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_AREA , params);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (idt.hasNext()) {
                any row2 = idt.getNext();
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
                    data.error=true;

                }
                sonars=sonars+tot;
            }
            idt.close();
        }
        cdt.close();

        json area_issues = {"name":area_name, "id":area_id, "sonar":sonars};
        allAreas.items[lengthof allAreas.items]=area_issues;


    }
    dt.close();
    
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=blocker;
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=critical;
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=major;
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=minor;
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    allAreas.sonarSeverity[lengthof allAreas.sonarSeverity]=info;

    data.data=allAreas;
    sqlEndPoint.close();
    return data;
}

function getSelectedAreaSonarIssues (int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allProducts = {"name":selected,"items":[], "sonarIssuetype":[], "sonarSeverity":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;
    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER , value:selected};
    params = [pqd_area_id_para];
    datatable pdt = sqlEndPoint.select(GET_PRODUCTS_OF_AREA, params);
    Products product;
    while (pdt.hasNext()) {
        int sonars=0;
        any rowp = pdt.getNext();
        product,err = (Products)rowp;

        int product_id = product.pqd_product_id;
        string product_name = product.pqd_product_name;

        sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER,value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT , params);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;

            sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (idt.hasNext()) {
                any row2 = idt.getNext();
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
            idt.close();
        }
        cdt.close();

        json product_issues = {"name":product_name, "id":product_id, "sonar":sonars};
        allProducts.items[lengthof allProducts.items]=product_issues;
    }
    pdt.close();

    
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    allProducts.sonarIssuetype[lengthof allProducts.sonarIssuetype]=bugs;
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    allProducts.sonarIssuetype[lengthof allProducts.sonarIssuetype]=codesmells;
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    allProducts.sonarIssuetype[lengthof allProducts.sonarIssuetype]=vulnerabilities;
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=blocker;
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=critical;
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=major;
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=minor;
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=info;

    data.data=allProducts;
    sqlEndPoint.close();
    return data;
}

function getSelectedAreaSonarIssuesForTypeAndSeverity (int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allProducts = {"name":selected,"items":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER , value:selected};
    params = [pqd_area_id_para];
    datatable pdt = sqlEndPoint.select(GET_PRODUCTS_OF_AREA, params);
    Products product;
    while (pdt.hasNext()) {
        int sonars=0;
        any rowp = pdt.getNext();
        product,err = (Products)rowp;

        int product_id = product.pqd_product_id;
        string product_name = product.pqd_product_name;

        sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER,value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT , params);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;

            sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (idt.hasNext()) {
                any row2 = idt.getNext();
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
                    data.error=true;

                }

                sonars=sonars+tot;
            }
            idt.close();
        }
        cdt.close();

        json product_issues = {"name":product_name, "id":product_id, "sonar":sonars};
        allProducts.items[lengthof allProducts.items]=product_issues;
    }
    pdt.close();

    data.data=allProducts;
    sqlEndPoint.close();
    return data;
}

function getSelectedAreaSonarIssuesForSeverity(int selected,int severity)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allProducts = {"name":"","items":[], "sonarIssuetype":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;

    int area_id;
    sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER , value:selected};
    params = [pqd_area_id_para];
    datatable pdt = sqlEndPoint.select(GET_PRODUCTS_OF_AREA, params);
    Products product;
    while (pdt.hasNext()) {
        int sonars=0;
        any rowp = pdt.getNext();
        product,err = (Products)rowp;

        int product_id = product.pqd_product_id;
        string product_name = product.pqd_product_name;

        sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER,value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT , params);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;

            sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (idt.hasNext()) {
                any row2 = idt.getNext();
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
                    data.error=true;

                }

                sonars=sonars+tot;
            }
            idt.close();
        }
        cdt.close();

        json product_issues = {"name":product_name, "id":product_id, "sonar":sonars};
        allProducts.items[lengthof allProducts.items]=product_issues;
    }
    pdt.close();

    
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    allProducts.sonarIssuetype[lengthof allProducts.sonarIssuetype]=bugs;
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    allProducts.sonarIssuetype[lengthof allProducts.sonarIssuetype]=codesmells;
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    allProducts.sonarIssuetype[lengthof allProducts.sonarIssuetype]=vulnerabilities;

    data.data=allProducts;
    sqlEndPoint.close();
    return data;
}

function getSelectedAreaSonarIssuesForType(int selected, int issueType)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allProducts = {"name":"","items":[],"sonarSeverity":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BLOCKER=0;
    int CRITICAL=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    int area_id;
    sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER , value:selected};
    params = [pqd_area_id_para];
    datatable pdt = sqlEndPoint.select(GET_PRODUCTS_OF_AREA, params);
    Products product;
    while (pdt.hasNext()) {
        int sonars=0;
        any rowp = pdt.getNext();
        product,err = (Products)rowp;

        int product_id = product.pqd_product_id;
        string product_name = product.pqd_product_name;
        sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER,value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT , params);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string project_key = comps.sonar_project_key;
            int component_id = comps.pqd_component_id;

            sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [sonar_project_key_para,snapshot_id_para];
            datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
            SonarIssues si;
            while (idt.hasNext()) {
                any row2 = idt.getNext();
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
                    data.error=true;

                }
                sonars=sonars+tot;
            }
            idt.close();
        }
        cdt.close();

        json product_issues = {"name":product_name, "id":product_id, "sonar":sonars};
        allProducts.items[lengthof allProducts.items]=product_issues;
    }
    pdt.close();

    
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=blocker;
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=critical;
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=major;
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=minor;
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    allProducts.sonarSeverity[lengthof allProducts.sonarSeverity]=info;

    data.data=allProducts;
    sqlEndPoint.close();
    return data;
}

function getSelectedProductSonarIssues (int selected)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allComponent = {"items":[], "sonarIssuetype":[], "sonarSeverity":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;
    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER, value:selected};
    params = [pqd_product_id_para];
    datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT , params);
    Components comps;
    boolean first_component_read=true;
    while (cdt.hasNext()) {
        int sonars=0;
        any row0 = cdt.getNext();
        comps, err = (Components)row0;

        string project_key = comps.sonar_project_key;
        int component_id = comps.pqd_component_id;
        string component_name=comps.pqd_component_name;

        sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
        sql:Parameter snapshot_id_para= {sqlType:sql:Type.INTEGER, value:snapshot_id};
        params = [sonar_project_key_para,snapshot_id_para];
        datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
        SonarIssues si;
        while (idt.hasNext()) {
            any row2 = idt.getNext();
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
        idt.close();

        json component_issues = {"name":component_name, "id":component_id, "sonar":sonars};
        allComponent.items[lengthof allComponent.items]=component_issues;
    }
    cdt.close();


    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=bugs;
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=codesmells;
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=vulnerabilities;
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=blocker;
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=critical;
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=major;
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=minor;
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=info;

    data.data=allComponent;
    sqlEndPoint.close();
    return data;
}

function getSelectedProductSonarIssuesForTypeAndSeverity(int selected, int issueType, int severity)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allComponent = {"items":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER, value:selected};
    params = [pqd_product_id_para];
    boolean first_component_read=true;
    datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT, params);
    Components comps;
    while (cdt.hasNext()) {
        int sonars=0;
        any row0 = cdt.getNext();
        comps, err = (Components)row0;

        string project_key = comps.sonar_project_key;
        int component_id = comps.pqd_component_id;
        string component_name=comps.pqd_component_name;

        sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
        sql:Parameter snapshot_id_para= {sqlType:sql:Type.INTEGER, value:snapshot_id};
        params = [sonar_project_key_para,snapshot_id_para];
        datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
        SonarIssues si;
        while (idt.hasNext()) {
            any row2 = idt.getNext();
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
                data.error=true;

            }
            sonars=sonars+tot;
        }
        idt.close();

        json component_issues = {"name":component_name, "id":component_id, "sonar":sonars};
        allComponent.items[lengthof allComponent.items]=component_issues;
    }
    cdt.close();

    

    data.data=allComponent;
    sqlEndPoint.close();
    return data;
}

function getSelectedProductSonarIssuesForSeverity(int selected, int severity)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allComponent = {"items":[], "sonarIssuetype":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;

    sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER, value:selected};
    params = [pqd_product_id_para];
    datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT, params);
    Components comps;
    while (cdt.hasNext()) {
        int sonars=0;
        any row0 = cdt.getNext();
        comps, err = (Components)row0;

        string project_key = comps.sonar_project_key;
        int component_id = comps.pqd_component_id;
        string component_name=comps.pqd_component_name;

        sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
        sql:Parameter snapshot_id_para= {sqlType:sql:Type.INTEGER, value:snapshot_id};
        params = [sonar_project_key_para,snapshot_id_para];
        datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
        SonarIssues si;
        while (idt.hasNext()) {
            any row2 = idt.getNext();
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
                data.error=true;

            }

            sonars=sonars+tot;
        }
        idt.close();

        json component_issues = {"name":component_name, "id":component_id, "sonar":sonars};
        allComponent.items[lengthof allComponent.items]=component_issues;
    }
    cdt.close();

    

    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=bugs;
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=codesmells;
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=vulnerabilities;

    data.data=allComponent;
    sqlEndPoint.close();
    return data;
}

function getSelectedProductSonarIssuesForType(int selected, int issueType)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allComponent = {"items":[],"sonarSeverity":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BLOCKER=0;
    int CRITICAL=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;

    sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER, value:selected};
    params = [pqd_product_id_para];
    datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT, params);
    Components comps;
    while (cdt.hasNext()) {
        int sonars=0;
        any row0 = cdt.getNext();
        comps, err = (Components)row0;

        string project_key = comps.sonar_project_key;
        int component_id = comps.pqd_component_id;
        string component_name=comps.pqd_component_name;

        sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
        sql:Parameter snapshot_id_para= {sqlType:sql:Type.INTEGER, value:snapshot_id};
        params = [sonar_project_key_para,snapshot_id_para];
        datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
        SonarIssues si;
        while (idt.hasNext()) {
            any row2 = idt.getNext();
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
                data.error=true;

            }
            sonars=sonars+tot;
        }
        idt.close();
        json component_issues = {"name":component_name, "id":component_id, "sonar":sonars};
        allComponent.items[lengthof allComponent.items]=component_issues;
    }
    cdt.close();


    
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=blocker;
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=critical;
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=major;
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=minor;
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=info;

    data.data=allComponent;
    sqlEndPoint.close();
    return data;
}

function getSelectedComponentSonarIssues(int selected)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allComponent = {"items":[],"sonarIssuetype":[], "sonarSeverity":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

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
    sql:Parameter pqd_selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    params=[pqd_selected_id_para];
    datatable cdt = sqlEndPoint.select(GET_DETAILS_OF_COMPONENT , params);
    Components comps;
    while (cdt.hasNext()){
        any row0 = cdt.getNext();
        comps, err = (Components)row0;
        project_key = comps.sonar_project_key;
        product_id= comps.pqd_product_id;
    }
    cdt.close();
    json returnjson = getSelectedProductSonarIssues(product_id);
    allComponent.items=returnjson.data.items;
    sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
    sql:Parameter snapshot_id_para= {sqlType:sql:Type.INTEGER, value:snapshot_id};
    params = [sonar_project_key_para,snapshot_id_para];
    datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
    SonarIssues si;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
    idt.close();

    
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=bugs;
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=codesmells;
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=vulnerabilities;
    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=blocker;
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=critical;
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=major;
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=minor;
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=info;

    data.data=allComponent;
    sqlEndPoint.close();
    return data;
}

function getSelectedComponentSonarIssuesForTypeAndSeverity(int selected,int issueType, int severity)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allComponent = {"items":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int product_id;
    sql:Parameter pqd_selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    params=[pqd_selected_id_para];
    datatable cdt = sqlEndPoint.select(GET_DETAILS_OF_COMPONENT , params);
    Components comps;
    while (cdt.hasNext()){
        any row0 = cdt.getNext();
        comps, err = (Components)row0;
        product_id= comps.pqd_product_id;
    }
    cdt.close();
    json returnjson = getSelectedProductSonarIssuesForTypeAndSeverity(product_id,issueType,severity);
    allComponent.items=returnjson.data.items;
    data.data=allComponent;
    sqlEndPoint.close();
    return data;
}

function getSelectedComponentSonarIssuesForSeverity(int selected,int severity)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allComponent = {"items":[], "sonarIssuetype":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int BUGS=0;
    int CODESMELLS=0;
    int VULNERABILITIES=0;

    string project_key;
    int product_id;
    sql:Parameter pqd_selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    params=[pqd_selected_id_para];
    datatable cdt = sqlEndPoint.select(GET_DETAILS_OF_COMPONENT , params);
    Components comps;
    while (cdt.hasNext()){
        any row0 = cdt.getNext();
        comps, err = (Components)row0;
        project_key = comps.sonar_project_key;
        product_id= comps.pqd_product_id;
    }
    cdt.close();
    json returnjson = getSelectedProductSonarIssuesForSeverity(product_id,severity);
    allComponent.items=returnjson.data.items;
    sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
    sql:Parameter snapshot_id_para= {sqlType:sql:Type.INTEGER, value:snapshot_id};
    params = [sonar_project_key_para,snapshot_id_para];
    datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
    SonarIssues si;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
    }
    idt.close();

    
    json bugs = {"name":"BUG","id":1, "sonar":BUGS};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=bugs;
    json codesmells = {"name":"CODE SMELL","id":2, "sonar":CODESMELLS};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=codesmells;
    json vulnerabilities = {"name":"VULNERABILITY","id":3, "sonar":VULNERABILITIES};
    allComponent.sonarIssuetype[lengthof allComponent.sonarIssuetype]=vulnerabilities;

    data.data=allComponent;
    sqlEndPoint.close();
    return data;
}

function getSelectedComponentSonarIssuesForType(int selected,int issueType)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json allComponent = {"items":[], "sonarSeverity":[]};

    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_SNAPSHOT_ID,params);
    Snapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (Snapshots )row;

        snapshot_id= ss.snapshot_id;

    }
    ssdt.close();

    int CRITICAL=0;
    int BLOCKER=0;
    int MAJOR=0;
    int MINOR=0;
    int INFO=0;
    string project_key;
    int product_id;
    sql:Parameter pqd_selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    params=[pqd_selected_id_para];
    datatable cdt = sqlEndPoint.select(GET_DETAILS_OF_COMPONENT , params);
    Components comps;
    while (cdt.hasNext()){
        any row0 = cdt.getNext();
        comps, err = (Components)row0;
        project_key = comps.sonar_project_key;
        product_id= comps.pqd_product_id;
    }
    cdt.close();
    json returnjson = getSelectedProductSonarIssuesForType(product_id,issueType);
    allComponent.items=returnjson.data.items;
    sql:Parameter sonar_project_key_para = {sqlType:sql:Type.VARCHAR, value:project_key};
    sql:Parameter snapshot_id_para= {sqlType:sql:Type.INTEGER, value:snapshot_id};
    params = [sonar_project_key_para,snapshot_id_para];
    datatable idt = sqlEndPoint.select(GET_ALL_OF_SONAR_ISSUES, params);
    SonarIssues si;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
    }
    idt.close();

    

    json blocker = {"name":"BLOCKER", "id":1 ,"sonar":BLOCKER};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=blocker;
    json critical = {"name":"CRITICAL", "id":2, "sonar":CRITICAL};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=critical;
    json major = {"name":"MAJOR","id":3, "sonar":MAJOR};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=major;
    json minor = {"name":"MINOR","id":4, "sonar":MINOR};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=minor;
    json info = {"name":"INFO","id":5 , "sonar":INFO};
    allComponent.sonarSeverity[lengthof allComponent.sonarSeverity]=info;

    data.data=allComponent;
    sqlEndPoint.close();
    return data;
}




function getSelectionHistory(string start, string end, string period, string category,int selected, int issueType , int severity)(json){
    json ret={};
    if(period=="day"){
        if(category=="all"){
            if(issueType!=0 && severity==0){
                ret= getDailyHistoryForAllAreaForType(start, end, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getDailyHistoryForAllAreaForSeverity(start, end, severity);
            }else if(issueType==0 && severity==0){
                ret= getDailyHistoryForAllArea(start, end);
            }else{
                ret= getDailyHistoryForAllAreaForTypeAndSeverity(start, end, issueType, severity);
            }
        }else if(category=="area"){
            if(issueType!=0 && severity==0){
                ret= getDailyHistoryForSelectedAreaForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getDailyHistoryForSelectedAreaForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getDailyHistoryForSelectedArea(start, end, selected);
            }else{
                ret= getDailyHistoryForSelectedAreaForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }else if(category=="product"){
            if(issueType!=0 && severity==0){
                ret= getDailyHistoryForSelectedProductForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getDailyHistoryForSelectedProductForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getDailyHistoryForSelectedProduct(start, end, selected);
            }else{
                ret= getDailyHistoryForSelectedProductForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }else if(category=="component"){
            if(issueType!=0 && severity==0){
                ret= getDailyHistoryForSelectedComponentForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getDailyHistoryForSelectedComponentForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getDailyHistoryForSelectedComponent(start, end, selected);
            }else{
                ret= getDailyHistoryForSelectedComponentForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }
    }else if(period=="Month"){
        if(category=="all"){
            if(issueType!=0 && severity==0){
                ret= getMonthlyHistoryForAllAreaForType(start, end, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getMonthlyHistoryForAllAreaForSeverity(start, end, severity);
            }else if(issueType==0 && severity==0){
                ret= getMonthlyHistoryForAllArea(start, end);
            }else{
                ret= getMonthlyHistoryForAllAreaForTypeAndSeverity(start, end, issueType, severity);
            }
        }else if(category=="area"){
            if(issueType!=0 && severity==0){
                ret= getMonthlyHistoryForSelectedAreaForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getMonthlyHistoryForSelectedAreaForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getMonthlyHistoryForSelectedArea(start, end, selected);
            }else{
                ret= getMonthlyHistoryForSelectedAreaForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }else if(category=="product"){
            if(issueType!=0 && severity==0){
                ret= getMonthlyHistoryForSelectedProductForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getMonthlyHistoryForSelectedProductForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getMonthlyHistoryForSelectedProduct(start, end, selected);
            }else{
                ret= getMonthlyHistoryForSelectedProductForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }else if(category=="component"){
            if(issueType!=0 && severity==0){
                ret= getMonthlyHistoryForSelectedComponentForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getMonthlyHistoryForSelectedComponentForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getMonthlyHistoryForSelectedComponent(start, end, selected);
            }else{
                ret= getMonthlyHistoryForSelectedComponentForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }
    }else if(period=="Quarter"){
        if(category=="all"){
            if(issueType!=0 && severity==0){
                ret= getQuarterlyHistoryForAllAreaForType(start, end, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getQuarterlyHistoryForAllAreaForSeverity(start, end, severity);
            }else if(issueType==0 && severity==0){
                ret= getQuarterlyHistoryForAllArea(start, end);
            }else{
                ret= getQuarterlyHistoryForAllAreaForTypeAndSeverity(start, end, issueType, severity);
            }
        }else if(category=="area"){
            if(issueType!=0 && severity==0){
                ret= getQuarterlyHistoryForSelectedAreaForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getQuarterlyHistoryForSelectedAreaForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getQuarterlyHistoryForSelectedArea(start, end, selected);
            }else{
                ret= getQuarterlyHistoryForSelectedAreaForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }else if(category=="product"){
            if(issueType!=0 && severity==0){
                ret= getQuarterlyHistoryForSelectedProductForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getQuarterlyHistoryForSelectedProductForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getQuarterlyHistoryForSelectedProduct(start, end, selected);
            }else{
                ret= getQuarterlyHistoryForSelectedProductForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }else if(category=="component"){
            if(issueType!=0 && severity==0){
                ret= getQuarterlyHistoryForSelectedComponentForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getQuarterlyHistoryForSelectedComponentForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getQuarterlyHistoryForSelectedComponent(start, end, selected);
            }else{
                ret= getQuarterlyHistoryForSelectedComponentForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }

    }else if(period=="Year"){
        if(category=="all"){
            if(issueType!=0 && severity==0){
                ret= getYearlyHistoryForAllAreaForType(start, end, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getYearlyHistoryForAllAreaForSeverity(start, end, severity);
            }else if(issueType==0 && severity==0){
                ret= getYearlyHistoryForAllArea(start, end);
            }else{
                ret= getYearlyHistoryForAllAreaForTypeAndSeverity(start, end, issueType, severity);
            }
        }else if(category=="area"){
            if(issueType!=0 && severity==0){
                ret= getYearlyHistoryForSelectedAreaForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getYearlyHistoryForSelectedAreaForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getYearlyHistoryForSelectedArea(start, end, selected);
            }else{
                ret= getYearlyHistoryForSelectedAreaForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }else if(category=="product"){
            if(issueType!=0 && severity==0){
                ret= getYearlyHistoryForSelectedProductForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getYearlyHistoryForSelectedProductForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getYearlyHistoryForSelectedProduct(start, end, selected);
            }else{
                ret= getYearlyHistoryForSelectedProductForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }else if(category=="component"){
            if(issueType!=0 && severity==0){
                ret= getYearlyHistoryForSelectedComponentForType(start, end, selected, issueType);
            }else if(severity!=0 && issueType==0){
                ret= getYearlyHistoryForSelectedComponentForSeverity(start, end, selected, severity);
            }else if(issueType==0 && severity==0){
                ret= getYearlyHistoryForSelectedComponent(start, end, selected);
            }else{
                ret= getYearlyHistoryForSelectedComponentForTypeAndSeverity(start, end, selected, issueType, severity);
            }
        }
    }

    return ret;
}

function getDailyHistoryForAllArea (string start, string end) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_ALL_AREA, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (DailySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.date;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForAllAreaForSeverity (string start, string end, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};
    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_ALL_AREA, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForAllAreaForType (string start, string end, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};
    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_ALL_AREA, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForAllAreaForTypeAndSeverity (string start, string end, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};
    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_ALL_AREA, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForAllArea (string start, string end) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_ALL_AREA, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (MonthlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-"+dsi.month;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForAllAreaForSeverity (string start, string end, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_ALL_AREA, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForAllAreaForType (string start, string end, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_ALL_AREA, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForAllAreaForTypeAndSeverity (string start, string end, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_ALL_AREA, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForAllArea (string start, string end) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_ALL_AREA, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (QuarterlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-Q"+dsi.quarter;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForAllAreaForSeverity (string start, string end, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_ALL_AREA, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForAllAreaForType (string start, string end, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_ALL_AREA, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForAllAreaForTypeAndSeverity (string start, string end, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_ALL_AREA, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForAllArea (string start, string end) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_ALL_AREA, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        float tot = dsi.total;
        var date=<string> dsi.year;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForAllAreaForSeverity (string start, string end, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_ALL_AREA, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues )row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForAllAreaForType (string start, string end, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_ALL_AREA, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForAllAreaForTypeAndSeverity (string start, string end, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_ALL_AREA, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}


function getDailyHistoryForSelectedArea (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_AREA, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (DailySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.date;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedAreaForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_AREA, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedAreaForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_AREA, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedAreaForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_AREA, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedArea (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_AREA, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (MonthlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-"+dsi.month;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedAreaForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_AREA, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedAreaForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_AREA, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedAreaForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_AREA, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedArea (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (QuarterlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-Q"+dsi.quarter;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedAreaForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedAreaForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedAreaForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_AREA, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedArea (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_AREA, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        float tot = dsi.total;
        var date=<string> dsi.year;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedAreaForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_AREA, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues )row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedAreaForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_AREA, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedAreaForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_AREA, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}


function getDailyHistoryForSelectedProduct (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (DailySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.date;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedProductForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedProductForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedProductForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_PRODUCT, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedProduct (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (MonthlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-"+dsi.month;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedProductForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedProductForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedProductForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedProduct (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (QuarterlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-Q"+dsi.quarter;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedProductForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedProductForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedProductForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedProduct (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        float tot = dsi.total;
        var date=<string> dsi.year;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedProductForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues )row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedProductForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedProductForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_PRODUCT, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}


function getDailyHistoryForSelectedComponent (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (DailySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.date;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedComponentForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedComponentForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getDailyHistoryForSelectedComponentForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_DAILY_HISTORY_FOR_SELECTED_COMPONENT, params);
    DailySonarIssues dsi;

    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedComponent (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (MonthlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-"+dsi.month;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedComponentForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedComponentForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyHistoryForSelectedComponentForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_MONTHLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    MonthlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedComponent (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (QuarterlySonarIssues)row2;
        float tot = dsi.total;
        string date= dsi.year+"-Q"+dsi.quarter;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedComponentForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedComponentForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyHistoryForSelectedComponentForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_QUARTERLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    QuarterlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedComponent (string start, string end, int selected) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        float tot = dsi.total;
        var date=<string> dsi.year;
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedComponentForSeverity (string start, string end, int selected, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues )row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedComponentForType (string start, string end, int selected, int issueType) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyHistoryForSelectedComponentForTypeAndSeverity (string start, string end, int selected, int issueType, int severity) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;
    
    json data = {"error":false,"data":[]};
    json allAreas = {"data":[]};

    
    sql:Parameter[] params = [];
    TypeCastError err;
    sql:Parameter selected_id_para={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [selected_id_para,start_date_para,end_date_para];
    datatable idt = sqlEndPoint.select(GET_YEARLY_HISTORY_FOR_SELECTED_COMPONENT, params);
    YearlySonarIssues dsi;
    while (idt.hasNext()) {
        any row2 = idt.getNext();
        dsi, err = (YearlySonarIssues)row2;
        var date=<string> dsi.year;
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
            data.error=true;

        }
        json history={"date":date,"count":tot};
        allAreas.data[lengthof allAreas.data]=history;
    }
    idt.close();

    data.data=allAreas.data;
    sqlEndPoint.close();
    return data;
}




function saveIssuesToDatabase (json projects, http:HttpClient sonarcon, json configData) {
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    worker issuesRecordingWorker {

        sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();

        bind sqlCon with sqlEndPoint;

        int lengthOfProjectList = lengthof projects;

        sql:Parameter[] params = [];

        string customStartTimeString = currentTime().format("yyyy-MM-dd");
        log:printInfo("Fetching data from SonarQube started at " + currentTime().format("yyyy-MM-dd  HH:mm:ss")+". There are "+ lengthOfProjectList + " sonar projectts for this time.");
        sql:Parameter todayDate = {sqlType:sql:Type.VARCHAR, value:customStartTimeString};
        params = [todayDate];

        int ret =0;
        try{
            ret=sqlEndPoint.update(INSERT_SNAPSHOT_DETAILS, params);
        }catch(error conErr){
            log:printError(conErr.msg);
        }
        if (ret != 0) {
            params = [];
            datatable dt = sqlEndPoint.select(GET_SNAPSHOT_ID, params);
            Snapshots ss;
            int snapshot_id;
            TypeCastError err;
            while (dt.hasNext()) {
                any row = dt.getNext();
                ss, err = (Snapshots)row;

                snapshot_id = ss.snapshot_id;

            }
            dt.close();
            sql:Parameter snapshotid = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            int index = 0;

            transaction {
                while (index < lengthOfProjectList) {
                    var project_key, _ = (string)projects[index].k;
                    sql:Parameter projectkey = {sqlType:sql:Type.VARCHAR, value:project_key};
                    log:printInfo(index + 1 + ":" + "Fetching data for project " + project_key);
                    json sumaryofProjectJson = getSonarIssuesForProject(project_key, sonarcon, configData);

                    var bb = sumaryofProjectJson.bb;
                    sql:Parameter bb1 = {sqlType:sql:Type.INTEGER, value:bb};

                    var cb = sumaryofProjectJson.cb;
                    sql:Parameter cb1 = {sqlType:sql:Type.INTEGER, value:cb};

                    var mab = sumaryofProjectJson.mab;
                    sql:Parameter mab1 = {sqlType:sql:Type.INTEGER, value:mab};

                    var mib = sumaryofProjectJson.mib;
                    sql:Parameter mib1 = {sqlType:sql:Type.INTEGER, value:mib};

                    var ib = sumaryofProjectJson.ib;
                    sql:Parameter ib1 = {sqlType:sql:Type.INTEGER, value:ib};

                    var bc = sumaryofProjectJson.bc;
                    sql:Parameter bc1 = {sqlType:sql:Type.INTEGER, value:bc};

                    var cc = sumaryofProjectJson.cc;
                    sql:Parameter cc1 = {sqlType:sql:Type.INTEGER, value:cc};

                    var mac = sumaryofProjectJson.mac;
                    sql:Parameter mac1 = {sqlType:sql:Type.INTEGER, value:mac};

                    var mic = sumaryofProjectJson.mic;
                    sql:Parameter mic1 = {sqlType:sql:Type.INTEGER, value:mic};

                    var ic = sumaryofProjectJson.ic;
                    sql:Parameter ic1 = {sqlType:sql:Type.INTEGER, value:ic};

                    var bv = sumaryofProjectJson.bv;
                    sql:Parameter bv1 = {sqlType:sql:Type.INTEGER, value:bv};

                    var cv = sumaryofProjectJson.cv;
                    sql:Parameter cv1 = {sqlType:sql:Type.INTEGER, value:cv};

                    var mav = sumaryofProjectJson.mav;
                    sql:Parameter mav1 = {sqlType:sql:Type.INTEGER, value:mav};

                    var miv = sumaryofProjectJson.miv;
                    sql:Parameter miv1 = {sqlType:sql:Type.INTEGER, value:miv};

                    var iv = sumaryofProjectJson.iv;
                    sql:Parameter iv1 = {sqlType:sql:Type.INTEGER, value:iv};

                    var total = sumaryofProjectJson.Total;
                    sql:Parameter total1 = {sqlType:sql:Type.INTEGER, value:total};

                    params = [snapshotid, todayDate, projectkey, bb1, cb1, mab1, mib1, ib1, bc1, cc1, mac1, mic1, ic1, bv1, cv1, mav1, miv1, iv1, total1];
                    log:printInfo("Issues were recoded successfully..");
                    int ret1 = sqlEndPoint.update(INSERT_SONAR_ISSUES, params);
                    index = index + 1;
                }

            }committed {
                string customEndTimeString = currentTime().format("yyyy-MM-dd  HH:mm:ss");
                log:printInfo("Data fetching from sonar finished at " + customEndTimeString);
            }
        }
        sqlEndPoint.close();
    }
}

function getSonarIssuesForProject (string project_key, http:HttpClient sonarcon, json configdata) (json) {

    int pageNumber = 1;
    int pageSize = 500;
    string path = "/api/issues/search?resolved=no&ps=500&projectKeys=" + project_key+"&p="+ pageNumber;
    log:printInfo("Getting issues for "+path);
    json sonarJSONResponse = getDataFromSonar(sonarcon,path,configdata);
    json returnJson={};
    var total,_ =(int)sonarJSONResponse.total;
    int index = 0;
    int bb=0; int cb=0; int mab=0; int mib=0; int ib=0;
    int bc=0; int cc=0; int mac=0; int mic=0; int ic=0;
    int bv=0; int cv=0; int mav=0; int miv=0; int iv=0;
    while (index < lengthof sonarJSONResponse.issues){
        json issueJson= sonarJSONResponse.issues[index];
        xml issueXml = sonarJSONResponse.issues[index].toXML({});
        string issueType= issueXml.select("type").getTextValue();
        string severity= issueXml.select("severity").getTextValue();
        if (issueType == "BUG" && severity=="BLOCKER"){
            bb=bb+1;
        }else if(issueType == "BUG" && severity=="CRITICAL"){
            cb=cb+1;
        }else if(issueType=="BUG" && severity=="MAJOR"){
            mab=mab+1;
        }else if(issueType=="BUG" && severity=="MINOR"){
            mib=mib+1;
        }else if(issueType=="BUG" && severity=="INFO"){
            ib=ib+1;
        }else if (issueType == "CODE_SMELL" && severity=="BLOCKER"){
            bc=bc+1;
        }else if(issueType == "CODE_SMELL" && severity=="CRITICAL"){
            cc=cc+1;
        }else if(issueType=="CODE_SMELL" && severity=="MAJOR"){
            mac=mac+1;
        }else if(issueType=="CODE_SMELL" && severity=="MINOR"){
            mic=mic+1;
        }else if(issueType=="CODE_SMELL" && severity=="INFO"){
            ic=ic+1;
        }else if (issueType == "VULNERABILITY" && severity=="BLOCKER"){
            bv=bv+1;
        }else if(issueType == "VULNERABILITY" && severity=="CRITICAL"){
            cv=cv+1;
        }else if(issueType=="VULNERABILITY" && severity=="MAJOR"){
            mav=mav+1;
        }else if(issueType=="VULNERABILITY" && severity=="MINOR"){
            miv=miv+1;
        }else if(issueType=="VULNERABILITY" && severity=="INFO"){
            iv=iv+1;
        }
        index = index + 1;

    }
    while (total> pageSize) {
        pageNumber = pageNumber + 1;
        total=total-pageSize;
        path = "/api/issues/search?resolved=no&ps=500&projectKeys=" + project_key+"&p="+ pageNumber;
        log:printInfo("Getting issues for "+path);
        sonarJSONResponse=getDataFromSonar(sonarcon,path,configdata);
        int index1=0;
        while (index1 < lengthof sonarJSONResponse.issues){
            json issueJson= sonarJSONResponse.issues[index1];
            xml issueXml = sonarJSONResponse.issues[index1].toXML({});
            string issueType= issueXml.select("type").getTextValue();
            string severity= issueXml.select("severity").getTextValue();
            if (issueType == "BUG" && severity=="BLOCKER"){
                bb=bb+1;
            }else if(issueType == "BUG" && severity=="CRITICAL"){
                cb=cb+1;
            }else if(issueType=="BUG" && severity=="MAJOR"){
                mab=mab+1;
            }else if(issueType=="BUG" && severity=="MINOR"){
                mib=mib+1;
            }else if(issueType=="BUG" && severity=="INFO"){
                ib=ib+1;
            }else if (issueType == "CODE_SMELL" && severity=="BLOCKER"){
                bc=bc+1;
            }else if(issueType == "CODE_SMELL" && severity=="CRITICAL"){
                cc=cc+1;
            }else if(issueType=="CODE_SMELL" && severity=="MAJOR"){
                mac=mac+1;
            }else if(issueType=="CODE_SMELL" && severity=="MINOR"){
                mic=mic+1;
            }else if(issueType=="CODE_SMELL" && severity=="INFO"){
                ic=ic+1;
            }else if (issueType == "VULNERABILITY" && severity=="BLOCKER"){
                bv=bv+1;
            }else if(issueType == "VULNERABILITY" && severity=="CRITICAL"){
                cv=cv+1;
            }else if(issueType=="VULNERABILITY" && severity=="MAJOR"){
                mav=mav+1;
            }else if(issueType=="VULNERABILITY" && severity=="MINOR"){
                miv=miv+1;
            }else if(issueType=="VULNERABILITY" && severity=="INFO"){
                iv=iv+1;
            }
            index1 = index1 + 1;

        }

    }
    total,_=(int)sonarJSONResponse.total;
    returnJson={"Total":total,"bb":bb,"cb":cb,"mab":mab,"mib":mib,"ib":ib,"bc":bc,"cc":cc,"mac":mac,"mic":mic,"ic":ic,"bv":bv,"cv":cv,"mav":mav,"miv":miv,"iv":iv};
    return returnJson;
}

function insertDataIntodatabase(string sqlQuery, sql:Parameter[] paramsForQuery)(int){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }
    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();

    bind sqlCon with sqlEndPoint;

    log:printDebug("insertDataIntodatabase function got invoked for sqlQuery : " + sqlQuery);
    int ret=0;
    try{
        ret=sqlEndPoint.update(sqlQuery,paramsForQuery);
    }catch(error err){
        log:printError(err.msg);
    }
    sqlEndPoint.close();
    return ret;
}

function getDataFromSonar(http:HttpClient httpCon, string path,json configData)(json){
    endpoint<http:HttpClient> httpEndPoint {
        httpCon;
    }
    log:printDebug("getDataFromSonar function got invoked for path : " + path);
    http:Request req = {};
    http:Response resp = {};
    http:HttpConnectorError conErr;
    authHeader(req,configData);
    resp, conErr = httpEndPoint.get(path, req);
    if(conErr != null){
        log:printError(conErr.msg);
    }
    json returnJson={};
    try {
        returnJson = resp.getJsonPayload();
    }catch(error err){
        log:printError(err.msg);
    }
    return returnJson;
}

function getHttpClientForSonar(json configData)(http:HttpClient){
    var basicurl,_=(string)configData.SONAR.SONAR_URL;
    http:HttpClient sonarCon=create http:HttpClient(basicurl,{});
    return sonarCon;
}

function authHeader (http:Request req,json configData) {
    string sonarAccessToken;
    sonarAccessToken, _ = (string)configData.SONAR.SONAR_ACCESS_TOKEN;
    string token=sonarAccessToken+":";
    string encodedToken = util:base64Encode(token);
    string passingToken = "Basic "+encodedToken;
    req.setHeader("Authorization", passingToken);
    req.setHeader("Content-Type", "application/json");

}
