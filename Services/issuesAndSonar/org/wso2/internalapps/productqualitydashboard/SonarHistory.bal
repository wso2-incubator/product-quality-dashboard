package org.wso2.internalapps.productqualitydashboard;

import ballerina.data.sql;
import ballerina.lang.datatables;
import ballerina.lang.jsons;
import ballerina.lang.errors;



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
        int date= dsi.year;
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
        int date=dsi.year;
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
        int date= dsi.year;
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
        int date= dsi.year;
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
        int date= dsi.year;
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
        int date=dsi.year;
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
        int date= dsi.year;
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
        int date= dsi.year;
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
        int date= dsi.year;
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
        int date=dsi.year;
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
        int date= dsi.year;
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
        int date= dsi.year;
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
        int date= dsi.year;
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
        int date=dsi.year;
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
        int date= dsi.year;
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
        int date= dsi.year;
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