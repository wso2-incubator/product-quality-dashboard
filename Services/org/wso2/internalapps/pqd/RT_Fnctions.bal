package org.wso2.internalapps.pqd;


import ballerina.lang.messages;

import ballerina.lang.jsons;
import ballerina.utils.logger;
import ballerina.lang.errors;
import ballerina.lang.files;
import ballerina.lang.blobs;
import ballerina.net.http;
import ballerina.data.sql;
import ballerina.lang.time;


sql:ClientConnector rmDB = null;
http:ClientConnector redmineConn = null;
http:ClientConnector gitHubConn = null;


function getConfData (string filePath) (json) {

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
function getDatabaseMap (json configData) (map) {

    string dbIP;
    int dbPort;
    string dbName;
    string dbUsername;
    string dbPassword;
    int poolSize;

    try {
        dbIP = jsons:getString(configData, "$.PQD_JDBC.DB_HOST");
        dbPort = jsons:getInt(configData, "$.PQD_JDBC.DB_PORT");
        dbName = jsons:getString(configData, "$.PQD_JDBC.DB_NAME");
        dbUsername = jsons:getString(configData, "$.PQD_JDBC.DB_USERNAME");
        dbPassword = jsons:getString(configData, "$.PQD_JDBC.DB_PASSWORD");
        poolSize = jsons:getInt(configData, "$.PQD_JDBC.MAXIMUM_POOL_SIZE");

    } catch (errors:Error err) {
        logger:error("Properties not defined in config.json: " + err.msg );
        dbIP = jsons:getString(configData, "$.PQD_JDBC.DB_HOST");
        dbPort = jsons:getInt(configData, "$.PQD_JDBC.DB_PORT");
        dbName = jsons:getString(configData, "$.PQD_JDBC.DB_NAME");
        dbUsername = jsons:getString(configData, "$.PQD_JDBC.DB_USERNAME");
        dbPassword = jsons:getString(configData, "$.PQD_JDBC.DB_PASSWORD");
        poolSize = jsons:getInt(configData, "$.PQD_JDBC.MAXIMUM_POOL_SIZE");

    }


    map propertiesMap={"jdbcUrl":"jdbc:mysql://"+dbIP+":"+dbPort+"/"+dbName, "username":dbUsername, "password":dbPassword, "maximumPoolSize":poolSize};

    return propertiesMap;

}
function createDBConnection () {
    json confJson = getConfData("config.json");
    map props = getDatabaseMap(confJson);
    rmDB = create sql:ClientConnector(props);
}
function createRMConnection(){
    json configData = getConfData("config.json");
    string rmUrl;
    rmUrl = jsons:getString(configData, "$.REDMINE.RM_URL");
    redmineConn = create http:ClientConnector(rmUrl);
}
function getRedmineRequest()(message){
    json confJson = getConfData("config.json");
    string rmApiKey;
    try{
        rmApiKey, _= (string)confJson.REDMINE.RM_API_KEY;
    }catch(errors:Error err){
        logger:error("Properties not defined in config.json: " + err.msg );
        rmApiKey, _= (string)confJson.REDMINE.RM_API_KEY;
    }

    message req = {};
    messages:setHeader(req,"X-Redmine-API-Key",rmApiKey);
    return req;
}

function createtGitHubConnection(){
    json confJson = getConfData("config.json");
    string gitHubUrl;

    try{
        gitHubUrl, _= (string)confJson.GITHUB.GITHUB_URL;
    }catch(errors:Error err){
        logger:error ("Properties not defined in config.json: " + err.msg );
        gitHubUrl, _= (string)confJson.GITHUB.GITHUB_URL;
    }

    gitHubConn = create http:clientConnector(gitHubUrl);

}
function getGitHubRequest()(message){
    json confJson = getConfData("config.json");
    string gitHubToken;
    try{
        gitHubToken, _= (string)confJson.GITHUB.GITHUB_TOKEN;
    }catch(errors:Error err){
        logger:error("Properties not defined in config.json: " + err.msg );
        gitHubToken, _= (string)confJson.GITHUB.GITHUB_TOKEN;
    }

    message req = {};
    messages:setHeader(req,"Authorization",gitHubToken);
    return req;

}

function getCycles(string path, int limit)(int){


    if (redmineConn == null) {
        createRMConnection();
    }


    message msg1=getRedmineRequest();
    message res1={};
    res1 = redmineConn.get(path, msg1);
    json jsn1=messages:getJsonPayload(res1);
    var count,_ =(int)jsn1.total_count;

    var remainder= count%limit;
    var cycles= (int)(count/limit);


    if(remainder==0){
        return cycles;
    }else{
        return cycles+1;
    }

}

function updateProject() {

    if (rmDB == null) {
        createDBConnection();
    }

    if (redmineConn == null) {
        createRMConnection();
    }
    message z;
    z -> updateProjectTable;

    worker updateProjectTable {
        logger:info("RM_PROJECT TABLE SYNC STARTED...");
        message context;
        context <- default;
        message response = {};
        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];
        sql:Parameter[] params3 = [];

        var offset = 0;
        var limit = 100;
        var cycles = getCycles("/projects.json?", limit);

        var insertrows = 0;
        var updaterows = 0;
        var i = 0;
        while (i < cycles) {

            message n = getRedmineRequest();
            json jsn1 = {};
            response = redmineConn.get("/projects.json?offset=" + offset + "&limit=" + limit, n);
            jsn1 = messages:getJsonPayload(response);

            var projectsCount = lengthof jsn1.projects;
            var j = 0;
            while (j < projectsCount) {
                logger:info("RM_PROJECT SYNCING...");
                //insert data
                time:Time dbUpdatedTimeStamp = time:currentTime();
                var id, _ = (int)(jsn1.projects[j].id);
                var name, _ = (string)(jsn1.projects[j].name);
                var identifier, _ = (string)(jsn1.projects[j].identifier);
                var description, _ = (string)(jsn1.projects[j].description);
                var status, _ = (int)(jsn1.projects[j].status);
                var isPublic, _ = (boolean)(jsn1.projects[j].is_public);
                var createdOn, _ = (string)(jsn1.projects[j].created_on);
                var updatedOn, _ = (string)(jsn1.projects[j].updated_on);
                var rowUpdateOn, _ = <string>dbUpdatedTimeStamp.time;

                sql:Parameter para1 = {sqlType:"integer", value:id};
                sql:Parameter para2 = {sqlType:"varchar", value:name};
                sql:Parameter para3 = {sqlType:"varchar", value:identifier};
                sql:Parameter para4 = {sqlType:"varchar", value:description};
                sql:Parameter para5 = {sqlType:"integer", value:status};
                sql:Parameter para6 = {sqlType:"varchar", value:isPublic};
                sql:Parameter para7 = {sqlType:"varchar", value:createdOn};
                sql:Parameter para8 = {sqlType:"varchar", value:updatedOn};
                sql:Parameter para9 = {sqlType:"varchar", value:rowUpdateOn};

                params1 = [para1];
                params2 = [para1, para2, para3, para4, para5, para6, para7, para8, para9];
                params3 = [para2, para3, para4, para5, para6, para7, para8, para9, para1];

                //last update time on redmine
                time:Time lastTimeUpdateStamp = time:parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");

                //get the row count of the RM_PROJECT table
                datatable dtProject = rmDB.select(RT_PROJECT_ID_CHECK, params1);
                var jsonRes1, _ = <json>dtProject;
                var rows1 = lengthof jsonRes1;
                var epochTime = 0;

                if (jsonRes1[0].epochTime != null) {
                    var epochTime1, _ = (string)jsonRes1[0].epochTime;
                    epochTime, _ = <int>epochTime1;
                }
                transaction {

                    if (rows1 == 0) { //if rows ==0,this record is new one.
                        logger:info("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;
                        int ret1 = rmDB.update(RT_PROJECT_INSERT, params2);

                    } else { // else ,this record is not new one

                        if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                            logger:info("OLD RECORD UPDATED");
                            updaterows = updaterows + 1;

                            int ret2 = rmDB.update(RT_PROJECT_UPDATE, params3);

                        }
                    }
                }

                j = j + 1;
            }

            offset = offset + limit;
            i = i + 1;


        }


        if (insertrows > 0) {
            logger:info(insertrows + " RECORDS ARE INSERTED... PLEASE UPDATE THE MAPPING OF PROJECT/S IN RM_MAPPING TABLE MANUALLY...");
        } else {
            logger:info(insertrows + " RECORDS ARE INSERTED");
        }
        logger:info(updaterows + " RECORDS ARE UPDATED");
        logger:info("RM_PROJECT TABLE SYNC DONE.");

    }}
function updateUser(){
    if (rmDB == null) {
        createDBConnection();
    }

    if (redmineConn == null) {
        createRMConnection();
    }
    message z;
    z -> updateUserTable;

    worker updateUserTable {
        logger:info("RM_USER TABLE SYNC STARTED...");
        message  context;
        context <- default;
        message response = {};

        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];

        var offset = 0;
        var limit = 100;
        var cycles = getCycles("/users.json?", limit);

        var insertrows=0;
        var i = 0;
        while (i < cycles) {

            message n = getRedmineRequest();
            json jsn1 = {};

            response = redmineConn.get("/users.json?offset=" + offset + "&limit=" + limit, n);
            jsn1 = messages:getJsonPayload(response);

            var usersCount = lengthof jsn1.users;

            var j = 0;
            while (j < usersCount) {
                logger:info("RM_USER SYNCING...");
                //insert data


                var id, _ = (int)(jsn1.users[j].id);
                var firstname, _ = (string)(jsn1.users[j].firstname);
                var lastname, _ = (string)(jsn1.users[j].lastname);
                var mail, _ = (string)(jsn1.users[j].mail);
                var createdOn, _ = (string)(jsn1.users[j].created_on);
                var lastLoginOn, _ = (string)(jsn1.users[j].last_login_on);


                sql:Parameter para1 = {sqlType:"integer", value:id};
                sql:Parameter para2 = {sqlType:"varchar", value:firstname};
                sql:Parameter para3 = {sqlType:"varchar", value:lastname};
                sql:Parameter para4 = {sqlType:"varchar", value:mail};
                sql:Parameter para5 = {sqlType:"varchar", value:createdOn};
                sql:Parameter para6 = {sqlType:"varchar", value:lastLoginOn};

                params1 = [para1];
                params2 = [para1, para2, para3, para4, para5, para6];





                //get the row count of the RM_PROJECT table
                datatable dtUser = rmDB.select(RT_USER_ID_CHECK, params1);
                var jsonRes1, _ = <json>dtUser;
                var rows1, _ = (int)jsonRes1[0].rowCount;

                transaction {

                    if (rows1 == 0) { //if rows ==0,this record is new one.
                        //insert
                        logger:info("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;
                        int ret1 = rmDB.update(RT_USER_INSERT, params2);
                    }
                }

                j = j + 1;
            }

            offset = offset + limit;
            i = i + 1;


        }
        logger:info(insertrows + " RECORDS ARE INSERTED");
        logger:info("RM_USER TABLE SYNC DONE.");
    }}
function updateVersion (){
    if (rmDB == null) {
        createDBConnection();
    }
    if (redmineConn == null) {
        createRMConnection();
    }


    message z;
    z -> updateVersionTable;



    worker updateVersionTable {
        logger:info("RM_VERSION TABLE SYNC STARTED...");
        message  context;
        context <- default;
        message response = {};

        sql:Parameter[] params0 = [];
        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];
        sql:Parameter[] params3 = [];




        datatable dt = rmDB.select(RT_VERSION_HELP, params0);
        var jsonResPro, err = <json>dt;

        var projectCount = lengthof jsonResPro;


        var insertrows=0;
        var updaterows=0;
        var l = 0;

        while (l < projectCount) {



            var projectId, _ = (int)jsonResPro[l].ID;

            message checkres1 = getRedmineRequest();
            message checkres2 = redmineConn.get("/projects/" + projectId + "/versions.json", checkres1);
            int statusCode = http:getStatusCode(checkres2);


            if (statusCode == 200) {

                //message response = {};
                var offset = 0;
                var limit = 100;
                var cycles = getCycles("/projects/" + projectId + "/versions.json?", limit);





                var i = 0;

                while (i < cycles) {

                    message n = getRedmineRequest();
                    json jsn1 = {};

                    response = redmineConn.get("/projects/" + projectId + "/versions.json?offset=" + offset + "&limit=" + limit, n);
                    jsn1 = messages:getJsonPayload(response);

                    var versionsCount = lengthof jsn1.versions;

                    var j = 0;
                    while (j < versionsCount) {

                        logger:info("RM_VERSION SYNCING...");
                        //insert data pre process start
                        time:Time dbUpdatedTimeStamp = time:currentTime();


                        var id = 0;
                        var versionProjectId = 0;
                        var parentProjectId = projectId;
                        var versionName = "";
                        var versionDescription = "";
                        var versionStatus = "";
                        var versionDueDate = "";
                        var versionSharing = "";
                        var versionMarketingDes = "";
                        var versionCarbonVersion = "";
                        var versionDependsOn = "";
                        var versionVisionDoc = "";
                        var versionStartDate = "";
                        var versionReleaseManagerId = 0;
                        var versionWarrantyManagerId = 0;

                        var versionCreatedOn, _ = (string)(jsn1.versions[j].created_on);
                        var versionUpdatedOn, _ = (string)(jsn1.versions[j].updated_on);

                        //var versionUpdatedOn="2017-10-17T05:08:44Z";
                        var rowUpdateOn, _ = <string>dbUpdatedTimeStamp.time;


                        if (jsn1.versions[j].id != null) {
                            id, _ = (int)(jsn1.versions[j].id);
                        }


                        if (jsn1.versions[j].project.id != null) {
                            versionProjectId, _ = (int)(jsn1.versions[j].project.id);
                        }

                        if (jsn1.versions[j].name != null) {
                            versionName, _ = (string)(jsn1.versions[j].name);
                        }

                        if (jsn1.versions[j].description != null) {
                            versionDescription, _ = (string)(jsn1.versions[j].description);
                        }

                        if (jsn1.versions[j].status != null) {
                            versionStatus, _ = (string)(jsn1.versions[j].status);
                        }

                        if (jsn1.versions[j].due_date != null) {
                            versionDueDate, _ = (string)(jsn1.versions[j].due_date);
                        }

                        if (jsn1.versions[j].sharing != null) {
                            versionSharing, _ = (string)(jsn1.versions[j].sharing);
                        }

                        var customFieldLength = lengthof jsn1.versions[j].custom_fields;
                        var z = 0;
                        while (z < customFieldLength) { //switch case for identify the custom fields
                            var customFieldId, _ = (int)(jsn1.versions[j].custom_fields[z].id);

                            if (customFieldId == 20) {
                                if (jsn1.versions[j].custom_fields[z].value != null) {
                                    versionMarketingDes, _ = (string)(jsn1.versions[j].custom_fields[z].value);
                                }
                            } else if (customFieldId == 22) {
                                if (jsn1.versions[j].custom_fields[z].value != null) {
                                    versionCarbonVersion, _ = (string)(jsn1.versions[j].custom_fields[z].value);
                                }
                            } else if (customFieldId == 25) {
                                if (jsn1.versions[j].custom_fields[z].value != null) {
                                    versionDependsOn, _ = (string)(jsn1.versions[j].custom_fields[z].value);
                                }
                            } else if (customFieldId == 26) {
                                if (jsn1.versions[j].custom_fields[z].value != null) {
                                    versionVisionDoc, _ = (string)(jsn1.versions[j].custom_fields[z].value);
                                }
                            } else if (customFieldId == 31) {
                                if (jsn1.versions[j].custom_fields[z].value != null) {
                                    versionStartDate, _ = (string)(jsn1.versions[j].custom_fields[z].value);
                                }
                            } else if (customFieldId == 65) {
                                if (jsn1.versions[j].custom_fields[z].value != null) {
                                    var rm, _=(string)(jsn1.versions[j].custom_fields[z].value);
                                    versionReleaseManagerId, _ = <int>rm;


                                }
                            } else if (customFieldId == 66) {
                                if (jsn1.versions[j].custom_fields[z].value != null) {
                                    var wm, _= (string)(jsn1.versions[j].custom_fields[z].value);
                                    versionWarrantyManagerId, _ =<int>wm;
                                }
                            }
                            z = z + 1;
                        }//insert data pre process end



                        sql:Parameter para1 = {sqlType:"integer", value:id};
                        sql:Parameter para2 = {sqlType:"integer", value:versionProjectId};
                        sql:Parameter para3 = {sqlType:"integer", value:parentProjectId};
                        sql:Parameter para4 = {sqlType:"varchar", value:versionName};
                        sql:Parameter para5 = {sqlType:"varchar", value:versionDescription};
                        sql:Parameter para6 = {sqlType:"varchar", value:versionStatus};
                        sql:Parameter para7 = {sqlType:"varchar", value:versionDueDate};
                        sql:Parameter para8 = {sqlType:"varchar", value:versionSharing};
                        sql:Parameter para9 = {sqlType:"varchar", value:versionMarketingDes};
                        sql:Parameter para10 = {sqlType:"varchar", value:versionCarbonVersion};
                        sql:Parameter para11 = {sqlType:"varchar", value:versionDependsOn};
                        sql:Parameter para12 = {sqlType:"varchar", value:versionVisionDoc};
                        sql:Parameter para13 = {sqlType:"varchar", value:versionStartDate};
                        sql:Parameter para14 = {sqlType:"integer", value:versionReleaseManagerId};
                        sql:Parameter para15 = {sqlType:"integer", value:versionWarrantyManagerId};
                        sql:Parameter para16 = {sqlType:"varchar", value:versionCreatedOn};
                        sql:Parameter para17 = {sqlType:"varchar", value:versionUpdatedOn};
                        sql:Parameter para18 = {sqlType:"varchar", value:rowUpdateOn};
                        params1 = [para1, para3];
                        params2 = [para1, para2, para3, para4, para5, para6, para7, para8, para9, para10, para11, para12, para13, para14, para15, para16, para17, para18];
                        params3 = [para4, para5, para6, para7, para8, para9, para10, para11, para12, para13, para14, para15, para16, para17, para18, para1, para3];


                        //last update time on redmine
                        time:Time lastTimeUpdateStamp = time:parse(versionUpdatedOn, "yyyy-MM-dd'T'HH:mm:ssz");



                        //get the row count of the RM_PROJECT table
                        //datatable dtversion1 = rmDB.select("SELECT COUNT(*) rowCount from redmine_dump.RM_VERSION WHERE VERSION_ID=? and PARENT_PROJECT_ID=?", params1);
                        datatable dtversion = rmDB.select(RT_VERSION_ID_CHECK, params1);

                        var jsonRes1, err = <json>dtversion;

                        var rows1 = lengthof jsonRes1;
                        var epochTime = 0;

                        if (rows1 != 0) {
                            var epochTime1, err = (string)jsonRes1[0].epochTime;
                            epochTime, _ = <int>epochTime1;
                        }
                        transaction {

                            if (rows1 == 0) { //if rows ==0,this record is new one.
                                //insert
                                logger:info("NEW RECORD INSERTED");
                                insertrows = insertrows + 1;
                                int ret1 = rmDB.update(RT_VERSION_INSERT, params2);

                            } else { // else ,this record is not new one



                                if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                                    logger:info("OLD RECORD UPDATED");
                                    updaterows = updaterows + 1;

                                    int ret2 = rmDB.update(RT_VERSION_UPDATE, params3);
                                }
                            }
                        }
                        j = j + 1;
                    }

                    offset = offset + limit;
                    i = i + 1;


                }

            }





            l = l + 1;
        }
        logger:info(insertrows + " RECORDS ARE INSERTED");
        logger:info(updaterows + " RECORDS ARE UPDATED");
        logger:info("RM_VERSION TABLE SYNC DONE.");
    }}
function updateIssue (){
    if (rmDB == null) {
        createDBConnection();
    }
    if (redmineConn == null) {
        createRMConnection();
    }
    message z;
    z -> updateIssueTable;



    worker updateIssueTable {
        logger:info("RM_ISSUE TABLE SYNC STARTED...");
        message  context;
        context <- default;
        message response = {};

        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];
        sql:Parameter[] params3 = [];
        var totaldataCount = 0;

        var offset = 0;
        var limit = 100;
        var cycles = getCycles("/issues.json?status_id=*", limit);

        var insertrows=0;
        var updaterows=0;
        var i = 0;
        while (i < cycles) {

            message n = getRedmineRequest();
            json jsn1 = {};

            response = redmineConn.get("/issues.json?status_id=*&offset=" + offset + "&limit=" + limit, n);

            jsn1 = messages:getJsonPayload(response);



            var issuesCount = lengthof jsn1.issues;

            totaldataCount = totaldataCount + issuesCount;
            var j = 0;

            while (j < issuesCount) {

                logger:info("RM_ISSUE SYNCING...");
                //insert data
                time:Time dbUpdatedTimeStamp = time:currentTime();
                var issueId, _ = (int)(jsn1.issues[j].id);
                var projectId, _ = (int)(jsn1.issues[j].project.id);
                var projectName, _ = (string)(jsn1.issues[j].project.name);
                var trackerId, _ = (int)(jsn1.issues[j].tracker.id);
                var trackerName, _ = (string)(jsn1.issues[j].tracker.name);
                var targetVersionId = 0;
                var targetName = "";
                if (jsn1.issues[j].fixed_version != null) {
                    targetVersionId, _ = (int)(jsn1.issues[j].fixed_version.id);
                    targetName, _ = (string)(jsn1.issues[j].fixed_version.name);
                }

                var subject, _ = (string)(jsn1.issues[j].subject);
                var createdOn, _ = (string)(jsn1.issues[j].created_on);
                var updatedOn, _ = (string)(jsn1.issues[j].updated_on);
                var rowUpdateOn, _ = <string>dbUpdatedTimeStamp.time;


                sql:Parameter para1 = {sqlType:"integer", value:issueId};
                sql:Parameter para2 = {sqlType:"integer", value:projectId};
                sql:Parameter para3 = {sqlType:"varchar", value:projectName};
                sql:Parameter para4 = {sqlType:"integer", value:trackerId};
                sql:Parameter para5 = {sqlType:"varchar", value:trackerName};
                sql:Parameter para6 = {sqlType:"integer", value:targetVersionId};
                sql:Parameter para7 = {sqlType:"varchar", value:targetName};
                sql:Parameter para8 = {sqlType:"varchar", value:subject};
                sql:Parameter para9 = {sqlType:"varchar", value:createdOn};
                sql:Parameter para10 = {sqlType:"varchar", value:updatedOn};
                sql:Parameter para11 = {sqlType:"varchar", value:rowUpdateOn};


                params1 = [para1];
                params2 = [para1, para2, para3, para4, para5, para6, para7, para8, para9, para10, para11];
                params3 = [para2, para3, para4, para5, para6, para7, para8, para9, para10, para11, para1];
                //last update time on redmine

                time:Time lastTimeUpdateStamp = time:parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");



                //get the row count of the RM_PROJECT table
                datatable dtissue = rmDB.select(RT_ISSUE_ID_CHECK, params1);

                var jsonRes1, err = <json>dtissue;

                var rows1 = lengthof jsonRes1;


                var epochTime = 0;

                if (rows1 != 0) {
                    var epochTime1, err = (string)jsonRes1[0].epochTime;
                    epochTime, _ = <int>epochTime1;
                }
                transaction {

                    if (rows1 == 0) { //if rows ==0,this record is new one.
                        //insert
                        logger:info("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;

                        int ret1 = rmDB.update(RT_ISSUE_INSERT, params2);

                    } else { // else ,this record is not new one



                        if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                            logger:info("OLD RECORD UPDATED");
                            updaterows = updaterows + 1;

                            int ret2 = rmDB.update(RT_ISSUE_UPDATE, params3);

                        }
                    }
                }

                j = j + 1;
            }

            offset = offset + limit;
            i = i + 1;


        }

        logger:info(insertrows + " RECORDS ARE INSERTED");
        logger:info(updaterows + " RECORDS ARE UPDATED");
        logger:info("RM_ISSUE TABLE SYNC DONE.");

    }}

function getAllReleases()(json){

    if (rmDB == null) {
        createDBConnection();
    }

    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];
    sql:Parameter[] params3 = [];
    sql:Parameter[] params4 = [];

    sql:Parameter para1 = {sqlType:"varchar", value:""};
    params1=[para1];
    datatable q1= rmDB.select(GET_ALL_RELEASES_Q_1, params1);

    var jsonRes1, err = <json>q1;

    json dataSet1=[];
    var distinctDates=lengthof jsonRes1;
    var i=0;
    var unicId=0;
    while (i<distinctDates){

        json data={};

        var id=i+1;
        var date, _=(string )jsonRes1[i].releaseDate;

        sql:Parameter para2 = {sqlType:"varchar", value:date};
        params2=[para2];

        datatable q2= rmDB.select(GET_ALL_RELEASES_Q_2, params2);
        var releases, err = <json>q2;


        var releasesLength=lengthof releases;
        var j=0;


        while (j<releasesLength){
            unicId=unicId + 1;
            releases[j].id=unicId;//create a unic number
            var color="";
            var area, _=(string)releases[j].PRODUCT_AREA;
            var versionId, _=(int)releases[j].VERSION_ID;

            if (area=="apim"){
                color="green";
            }else if(area=="analytics"){
                color="red";
            }else if(area=="cloud"){
                color="blue";
            }else if(area=="integration"){
                color="purple";
            }else if(area=="iot"){
                color="skyblue";
            }else if(area=="identity"){
                color="orange";
            }else if(area=="other"){
                color="black";
            }

            releases[j].color=color;

            sql:Parameter para3 = {sqlType:"integer", value:versionId};
            sql:Parameter para4 = {sqlType:"integer", value:2};//Feature
            sql:Parameter para5 = {sqlType:"integer", value:30};//Story
            params3=[para3,para4];
            params4=[para3,para5];


            datatable q3= rmDB.select(GET_ALL_RELEASES_Q_3,params3);
            var jsonFeatureCount, _= <json>q3;
            var featuresCount, _=(int)jsonFeatureCount[0].featureCount;

            datatable q4= rmDB.select(GET_ALL_RELEASES_Q_4,params4);
            var jsonStoryCount, _= <json>q4;
            var storiesCount, _=(int)jsonStoryCount[0].storyCount;

            releases[j].featuresCount=featuresCount;
            releases[j].storiesCount=storiesCount;

            j=j+1;
        }

        data.id=id;
        data.releases=releases;
        data.start=date;
        data.class="blue";

        dataSet1[i]=data;


        i=i+1;
    }
    return dataSet1;
}
function getReleasesByProduct(string product)(json){

    if (rmDB == null) {
        createDBConnection();
    }
    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];
    sql:Parameter[] params3 = [];
    sql:Parameter[] params4 = [];

    sql:Parameter para1 = {sqlType:"varchar", value:""};
    sql:Parameter para2 = {sqlType:"varchar", value:product};
    params1=[para1,para2];
    datatable q1= rmDB.select(GET_RELEASES_BY_PRODUCT_Q_1, params1);

    var jsonRes1, err = <json>q1;

    json dataSet1=[];
    var distinctDates=lengthof jsonRes1;
    var i=0;
    var unicId=0;
    while (i<distinctDates){

        json data={};

        var id=i+1;
        var date, _=(string )jsonRes1[i].releaseDate;

        sql:Parameter para3 = {sqlType:"varchar", value:date};
        params2=[para3,para2];

        datatable q2= rmDB.select(GET_RELEASES_BY_PRODUCT_Q_2, params2);
        var releases, err = <json>q2;


        var releasesLength=lengthof releases;
        var j=0;


        while (j<releasesLength){
            unicId=unicId + 1;
            releases[j].id=unicId;//create a unic number
            var color="";
            var area, _=(string)releases[j].PRODUCT_AREA;
            var versionId, _=(int)releases[j].VERSION_ID;

            if (area=="apim"){
                color="green";
            }else if(area=="analytics"){
                color="red";
            }else if(area=="cloud"){
                color="blue";
            }else if(area=="integration"){
                color="purple";
            }else if(area=="iot"){
                color="skyblue";
            }else if(area=="identity"){
                color="orange";
            }else if(area=="other"){
                color="black";
            }

            releases[j].color=color;

            sql:Parameter para4 = {sqlType:"integer", value:versionId};
            sql:Parameter para5 = {sqlType:"integer", value:2};//Feature
            sql:Parameter para6 = {sqlType:"integer", value:30};//Story
            params3=[para4,para5,para2];
            params4=[para4,para6,para2];


            datatable q3= rmDB.select(GET_RELEASES_BY_PRODUCT_Q_3,params3);
            var jsonFeatureCount, _= <json>q3;
            var featuresCount, _=(int)jsonFeatureCount[0].featureCount;

            datatable q4= rmDB.select(GET_RELEASES_BY_PRODUCT_Q_4,params4);
            var jsonStoryCount, _= <json>q4;
            var storiesCount, _=(int)jsonStoryCount[0].storyCount;

            releases[j].featuresCount=featuresCount;
            releases[j].storiesCount=storiesCount;

            j=j+1;
        }

        data.id=id;
        data.releases=releases;
        data.start=date;
        data.class="blue";

        dataSet1[i]=data;


        i=i+1;
    }
    return dataSet1;
}
function getManagers(string product, string startDate, string endDate)(json){
    if (rmDB == null) {
        createDBConnection();
    }

    json manager=[];

    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];

    sql:Parameter para1 = {sqlType:"varchar", value:product};
    sql:Parameter para2 = {sqlType:"varchar", value:startDate};
    sql:Parameter para3 = {sqlType:"varchar", value:endDate};

    params1 =[para2,para3];
    params2 =[para2,para3,para1];

    if (product=="all"){
        datatable q1= rmDB.select(GET_MANAGERS_Q_1, params1);
        manager, _ = <json>q1;


    }else{
        datatable q2= rmDB.select(GET_MANAGERS_Q_2, params2);
        manager, _ = <json>q2;

    }


    sql:Parameter[] params3 = [];
    sql:Parameter[] params4 = [];

    var releasesLength=lengthof manager;
    var j=0;

    while (j<releasesLength){


        manager[j].id=j;//create a unic number
        var versionId, _=(int)manager[j].VERSION_ID;

        sql:Parameter para4 = {sqlType:"integer", value:versionId};
        sql:Parameter para5= {sqlType:"integer", value:2};//Feature
        sql:Parameter para6= {sqlType:"integer", value:30};//Story
        params3=[para4,para5];
        params4=[para4,para6];


        datatable q3= rmDB.select(GET_MANAGERS_Q_3,params3);
        var jsonFeatureCount, _= <json>q3;
        var featuresCount, _=(int)jsonFeatureCount[0].featureCount;

        datatable q4= rmDB.select(GET_MANAGERS_Q_4,params4);
        var jsonStoryCount, _= <json>q4;
        var storiesCount, _=(int)jsonStoryCount[0].storyCount;

        manager[j].featuresCount=featuresCount;
        manager[j].storiesCount=storiesCount;

        j=j+1;
    }
    return manager;

}
function getTrackerSubjects(int trackerId, int versionId)(json){
    if (rmDB == null) {
        createDBConnection();
    }

    json trackerSubjects=[];
    sql:Parameter[] params1 = [];
    sql:Parameter para1 = {sqlType:"integer", value:trackerId};
    sql:Parameter para2 = {sqlType:"integer", value:versionId};


    params1 =[para1,para2];


    datatable q1= rmDB.select(GET_TRACKER_SUBJECTS_Q_1, params1);

    trackerSubjects, _ = <json>q1;

    return trackerSubjects;
}

function getGitHubPages(string repoName, string versionName, string states, int pageLimit)(int){
    if(gitHubConn!=null){
        createtGitHubConnection();
    }

    message req = {};
    message resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGitHubRequest();
    json variables = { "loginName": "wso2", "repoName": repoName,  "issueStates": states, "versionName": versionName};
    string query = "query ($loginName:String! $repoName:String! $issueStates:[IssueState!] $versionName:[String!]){ organization(login: $loginName) { repository(name:$repoName) { name, issues(first: 10, states:$issueStates, labels:$versionName) { totalCount } } } }";

    jsonPost.query = query;
    jsonPost.variables =variables;

    messages:setJsonPayload(req,jsonPost);
    resp= gitHubConn.post("/graphql", req);
    jsonRes = messages:getJsonPayload(resp);

    var count, _ =(int)jsonRes.data.organization.repository.issues.totalCount;

    var remainder= count%pageLimit;
    var pages= (int)(count/pageLimit);

    if(remainder==0){
        return pages;
    }else{
        return pages+1;
    }

}
function getInitialIssues(string repoName, string versionName, string states, int pageLimit)(json){
    if(gitHubConn==null){
        createtGitHubConnection();
    }

    message req = {};
    message resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGitHubRequest();
    json variables = { "loginName": "wso2", "repoName": repoName,  "pageLimit":pageLimit, "issueStates": states, "versionName": versionName};
    string query = "query ($loginName:String! $repoName:String! $pageLimit:Int! $issueStates:[IssueState!] $versionName:[String!]){ organization(login: $loginName) { repository(name:$repoName) { name, issues(first: $pageLimit, states:$issueStates, labels:$versionName) { totalCount,pageInfo{ hasNextPage,endCursor }, nodes{ title,url } } } } }";

    jsonPost.query = query;
    jsonPost.variables =variables;

    messages:setJsonPayload(req,jsonPost);
    resp= gitHubConn.post("/graphql", req);
    jsonRes = messages:getJsonPayload(resp);

    var count, _ = (int)jsonRes.data.organization.repository.issues.totalCount;
    if (count > 0){
        return jsonRes;
    }else {

        return null;
    }

}
function getNextIssues(string repoName, string versionName, string states, int pageLimit, string nextPageLink)(json){
    if(gitHubConn==null){
        createtGitHubConnection();
    }

    message req = {};
    message resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGitHubRequest();
    json variables = { "loginName": "wso2", "repoName": repoName,  "pageLimit":pageLimit, "nextPageLink":nextPageLink, "issueStates": states, "versionName": versionName};
    string query = "query ($loginName:String! $repoName:String! $nextPageLink:String! $pageLimit:Int! $issueStates:[IssueState!] $versionName:[String!]){ organization(login: $loginName) { repository(name:$repoName) { name, issues(first: $pageLimit, after:$nextPageLink, states:$issueStates, labels:$versionName) { totalCount,pageInfo{ hasNextPage,endCursor }, nodes{ title,url } } } } }";

    jsonPost.query = query;
    jsonPost.variables =variables;

    messages:setJsonPayload(req,jsonPost);
    resp= gitHubConn.post("/graphql", req);
    jsonRes = messages:getJsonPayload(resp);
    return jsonRes;
}
function getFixedGitIssues(string repoName , string versionName)(json){

    json jsonFinal=[];

    string states = "CLOSED";
    int pageLimit = 100; // maximum page limit is 100.


    json jsonRes = getInitialIssues(repoName, versionName, states, pageLimit);
    int count;
    boolean hasNextPage;
    string nextPageLink;
    json nodes;


    if (jsonRes != null) {
        count, _ = (int)jsonRes.data.organization.repository.issues.totalCount;
        hasNextPage, _ = (boolean)jsonRes.data.organization.repository.issues.pageInfo.hasNextPage;
        nextPageLink, _ = (string)jsonRes.data.organization.repository.issues.pageInfo.endCursor;
        nodes = jsonRes.data.organization.repository.issues.nodes;

        jsonFinal[0] = nodes;
    }else{
        jsonFinal=[];
    }

    int i = 1;
    while(hasNextPage){
        jsonRes = getNextIssues(repoName, versionName, states, pageLimit, nextPageLink);
        count, _ =(int)jsonRes.data.organization.repository.issues.totalCount;
        hasNextPage, _ =(boolean)jsonRes.data.organization.repository.issues.pageInfo.hasNextPage;
        nextPageLink, _=(string )jsonRes.data.organization.repository.issues.pageInfo.endCursor;
        nodes = jsonRes.data.organization.repository.issues.nodes;

        jsonFinal[i]=nodes;

        i = i + 1;
    }


    return jsonFinal;



}
function getReportedGitIssues(string repoName , string versionName)(json){

    json jsonFinal=[];

    string states = "OPEN";
    int pageLimit = 100; // maximum page limit is 100.


    json jsonRes = getInitialIssues(repoName, versionName, states, pageLimit);
    int count;
    boolean hasNextPage;
    string nextPageLink;
    json nodes;



    if (jsonRes!= null) {
        count, _ = (int)jsonRes.data.organization.repository.issues.totalCount;
        hasNextPage, _ = (boolean)jsonRes.data.organization.repository.issues.pageInfo.hasNextPage;
        nextPageLink, _ = (string)jsonRes.data.organization.repository.issues.pageInfo.endCursor;
        nodes = jsonRes.data.organization.repository.issues.nodes;

        jsonFinal[0] = nodes;
    }else{
        jsonFinal=[];
    }

    int i = 1;
    while(hasNextPage){
        jsonRes = getNextIssues(repoName, versionName, states, pageLimit, nextPageLink);
        count, _ =(int)jsonRes.data.organization.repository.issues.totalCount;
        hasNextPage, _ =(boolean)jsonRes.data.organization.repository.issues.pageInfo.hasNextPage;
        nextPageLink, _=(string )jsonRes.data.organization.repository.issues.pageInfo.endCursor;
        nodes = jsonRes.data.organization.repository.issues.nodes;

        jsonFinal[i]=nodes;

        i = i + 1;
    }


    return jsonFinal;


}

function getRepoAndVersion(int projectId, int versionId)(json){
    if (rmDB == null) {
        createDBConnection();
    }


    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];//https://localhost:9092/base/getRepoAndVersion/119/688

    sql:Parameter para1 = {sqlType:"integer", value:projectId};
    sql:Parameter para2 = {sqlType:"integer", value:versionId};
    params1=[para1];
    params2=[para2];

    datatable q1= rmDB.select(GET_REPO_AND_VERSION_Q_1, params1);
    var jsonRepo, _= <json>q1;




    datatable q2= rmDB.select(GET_REPO_AND_VERSION_Q_2, params2);
    var jsonVersion, _= <json>q2;
    var versionName, _=(string)jsonVersion[0].versionName;

    json dataSet1 ={"repoNames":jsonRepo, "versionName":versionName};
    return dataSet1;


}
