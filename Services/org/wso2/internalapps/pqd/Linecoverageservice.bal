package org.wso2.internalapps.pqd;

import ballerina.lang.time;
import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.lang.jsons;
import ballerina.lang.errors;
import ballerina.utils.logger;
import ballerina.data.sql;
import ballerina.lang.datatables;

struct ComponentNames{
    int pqd_component_id;
    string pqd_component_name;
}

struct Folders{
    string Folder;
}

json configData = getConfigData(CONFIG_PATH);

map propertiesMap = getSQLconfigData(configData);

http:ClientConnector jenkinsCon=null;

@http:configuration {basePath:"/internal/product-quality/v1.0/line-coverage", httpsPort: 9092,
                     keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks",
                     keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> LineCoverageService {
    @http:GET {}
    @http:Path {value:"/fetch-data"}
    resource saveLineCoveragetoDB (message m) {
        message response = {};
        if(jenkinsCon==null){
            getHttpClientForJenkins(configData);
        }
        saveLineCoverageIntoDatabase(configData);
        messages:setStringPayload(response, "Data fetching from Jenkins has begun...");
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/save-history"}
    resource saveLineCoverageHitroy (message m) {
        message response = {};
        if(jenkinsCon==null){
            getHttpClientForJenkins(configData);
        }
        string returnString= saveLineCoverageHistoryIntoDatabase();
        messages:setStringPayload(response, returnString);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }
}

function saveLineCoverageIntoDatabase (json configData) {
    worker saveLineCoverage{
        sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
        sql:Parameter[] params = [];

        string customStartTimeString = time:format(time:currentTime(), "yyyy-MM-dd  HH:mm:ss");
        logger:info("--------------------------------------------------------");

        json returnJson=[];
        json foldersofComponents=[];
        datatable compDt=sql:ClientConnector.select(dbConnector,GET_ALL_COMPONENTS,params);
        ComponentNames cn;
        errors:TypeCastError err;
        while(datatables:hasNext(compDt)){
            any row = datatables:next(compDt);
            cn, err =(ComponentNames)row;
            string component_name=cn.pqd_component_name;
            int component_id=cn.pqd_component_id;
            string folder_name="unknown";
            sql:Parameter componentNamePara={sqlType:"varchar",value:component_name};
            params=[componentNamePara];
            try{
                datatable fdt=sql:ClientConnector.select(dbConnector,GET_FOLDER_OF_COMPONENT,params);
                Folders folder;
                while (datatables:hasNext(fdt)) {
                    any frow=datatables:next(fdt);
                    folder,err=(Folders)frow;
                    folder_name=folder.Folder;
                }
                datatables:close(fdt);
                if(folder_name!="unknown"){
                    json folderComponent={"component_id":component_id,"component_name":component_name,"folder_name":folder_name};
                    foldersofComponents[lengthof foldersofComponents]=folderComponent;
                }

            }catch (errors:Error Conerr) {
                logger:error(Conerr.msg);
            }
        }
        datatables:close(compDt);
        dbConnector.close();

        int loopSize = lengthof foldersofComponents;
        int index = 0;
        logger:info("Fetching data from Jenkins started at " + time:format(time:currentTime(), "yyyy-MM-dd  HH:mm:ss") +". There are "+loopSize+" components for today.");
        while(index<loopSize){
            var folderName,_=(string)foldersofComponents[index].folder_name;
            var component_id,_=(int)foldersofComponents[index].component_id;
            var component_name,_=(string)foldersofComponents[index].component_name;

            string path;
            string buildPath;
            string api="/api/json";
            if(folderName=="none"){
                buildPath="/job/"+component_name;
                path=buildPath+api+"?tree=lastSuccessfulBuild[number]";
            }else{
                buildPath="/job/"+folderName+"/job/"+component_name;
                path=buildPath+api+"?tree=lastSuccessfulBuild[number]";
            }
            json jenkinsbuildJson=getDataFromJenkins(path,configData);
            try{
                var buildId,_=(int)jenkinsbuildJson.lastSuccessfulBuild.number;
                path=buildPath+"/"+buildId+"/jacoco"+api+"?tree=lineCoverage[covered,missed,total,percentageFloat]";
                logger:info(index+1+". Fetching line coverage details for build " + buildId+" of component " +component_name);
                json jacocoCoverageJson;
                try{
                    jacocoCoverageJson=getDataFromJenkins(path,configData);
                }catch (errors:Error jerr) {
                    logger:error(jerr.msg);
                }
                if(lengthof jsons:getKeys(jacocoCoverageJson)>0) {
                    var lines_to_cover, _ = (int)jacocoCoverageJson.lineCoverage.total;
                    var covered_lines, _ = (int)jacocoCoverageJson.lineCoverage.covered;
                    var uncovered_lines, _ = (int)jacocoCoverageJson.lineCoverage.missed;
                    var line_coverage, _ = (float)jacocoCoverageJson.lineCoverage.percentageFloat;

                    returnJson[lengthof returnJson]={"todayDate":customStartTimeString,"componentIdPara":component_id,
                                                        "componentNamePara":component_name,"lines_to_cover_para":lines_to_cover,"covered_lines_para":covered_lines,
                                                        "uncovered_linese_para":uncovered_lines,"line_coverage_para":line_coverage};
                }
            }catch(errors:Error err){
                logger:error("Invalid URL");
            }


            index=index+1;
        }
        logger:info("Data fetching from Jenkins finished at " + time:format(time:currentTime(), "yyyy-MM-dd  HH:mm:ss"));
        insertLiveLineCoverageDataIntoDatabase(returnJson);

    }
}

function getDataFromJenkins(string path,json configData)(json){
    logger:info("getDataFromJenkins function got invoked for path : " + path);
    message req = {};
    message resp = {};
    if(jenkinsCon!=null){
        getHttpClientForJenkins(configData);
    }
    authJenkinsHeader(req);
    resp= http:ClientConnector.get(jenkinsCon,path, req);

    json returnJson={};
    try {
        returnJson = messages:getJsonPayload(resp);
    }catch(errors:Error err){
        logger:error(err.msg);
    }
    return returnJson;
}

function insertLiveLineCoverageDataIntoDatabase (json dataJson) {
    sql:ClientConnector sqlCon = create sql:ClientConnector(propertiesMap);
    int loopSize=lengthof dataJson;
    logger:debug(jsons:toString(dataJson));
    logger:info("Storing line coverage data to db has being started. There are "+loopSize+" components with line coverage details.");
    int index=0;
    sql:Parameter[] params=[];
    int ret=sql:ClientConnector.update(sqlCon,DELETE_LIVE_LINE_COVERAGE_DETAILS,params);
    logger:info("live line coverage details were deleted Successfully.");
    while(index<loopSize){
        logger:debug(jsons:toString(dataJson));
        try{
            var today_date,_ = (string)dataJson[index].todayDate;
            var component_id,_= (int)dataJson[index].componentIdPara;
            var component_name,_ = (string)dataJson[index].componentNamePara;
            var lines_to_cover,_ = (int)dataJson[index].lines_to_cover_para;
            var covered_lines, _ = (int)dataJson[index].covered_lines_para;
            var uncovered_lines, _ = (int)dataJson[index].uncovered_linese_para;
            var line_coverage, _ = (float)dataJson[index].line_coverage_para;
            sql:Parameter todayDate = {sqlType:"varchar", value:today_date};
            sql:Parameter componentIdPara = {sqlType:"integer", value:component_id};
            sql:Parameter componentNamePara = {sqlType:"varchar", value:component_name};
            sql:Parameter lines_to_cover_para = {sqlType:"integer", value:lines_to_cover};
            sql:Parameter covered_lines_para = {sqlType:"integer", value:covered_lines};
            sql:Parameter uncovered_linese_para = {sqlType:"integer", value:uncovered_lines};
            sql:Parameter line_coverage_para = {sqlType:"float", value:line_coverage};
            params = [todayDate, componentIdPara, componentNamePara, lines_to_cover_para, covered_lines_para, uncovered_linese_para, line_coverage_para];
            int ret1 = sql:ClientConnector.update(sqlCon, INSERT_LIVE_LINE_COVERAGE_DETAILS, params);
            logger:info("Line coverage details for "+component_name+" were recoded successfully..");
        }catch(errors:Error err){
            logger:error("Error occured while inserting data "+err.msg );
        }
        index=index+1;
    }
    sqlCon.close();
    logger:info("Line Coverage data stored to database successfully.");
    logger:info("--------------------------------------------------------");
}

function saveLineCoverageHistoryIntoDatabase()(string){
    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] params = [];
    string returnstring="";
    string customStartTimeString = time:format(time:currentTime(), "yyyy-MM-dd");
    logger:info("--------------------------------------------------------");
    sql:Parameter todayDate = {sqlType:"varchar", value:customStartTimeString};
    params=[todayDate];
    int ret =0;
    try{
        ret=sql:ClientConnector.update(dbConnector,INSERT_LINECOVERAGE_SNAPSHOT_DETAILS, params);
    }catch(errors:Error conErr){
        logger:error(conErr.msg);
        returnstring="Line coverage data for today already exist.";
    }
    if(ret != 0){
        params = [];
        datatable dt = sql:ClientConnector.select(dbConnector,GET_LINECOVERAGE_SNAPSHOT_ID, params);
        json snapshot;
        snapshot,_=<json>dt;
        logger:info(jsons:toString(snapshot));
        var snapshot_id,_ =(int)snapshot[0].snapshot_id;
        var date,_=(string)snapshot[0].date;
        datatables:close(dt);
        string query="INSERT INTO line_coverage_history (snapshot_id,date,component_id,component_name,lines_to_cover,"+
                     "covered_lines,uncovered_lines,line_coverage) SELECT "+snapshot_id+",'"+date+"',component_id,"+
                     "component_name,lines_to_cover,covered_lines,uncovered_lines,line_coverage FROM live_line_coverage";
        logger:info(query);
        try{
            int ret1 = sql:ClientConnector.update(dbConnector, query, params);
            returnstring="Data insert successfully into line_coverage_history table.";
        }catch (errors:Error err) {
            logger:error(err.msg);
            returnstring="Error while inserting data into line_coverage_history table.";
        }

    }
    logger:info("--------------------------------------------------------");
    dbConnector.close();
    return returnstring;
}

function getHttpClientForJenkins(json configData){
    string basicurl =jsons:getString(configData,"$.JENKINS.BASE_URL");
    jenkinsCon=create http:ClientConnector(basicurl);
}

function authJenkinsHeader (message req){
    string jenkinsAccessToken = jsons:getString(configData,"$.JENKINS.ACCESS_TOKEN");
    string passingToken = "Basic "+jenkinsAccessToken;
    messages:setHeader(req,"Authorization", passingToken);
    messages:setHeader(req,"Content-Type", "application/json");
}

