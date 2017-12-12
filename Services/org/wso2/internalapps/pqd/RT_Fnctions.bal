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
import ballerina.lang.strings;
import ballerina.lang.datatables;




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
json confJson = getConfData("config.json");

function getDatabaseMap (json configData)(map) {

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
function createDBConnection()(sql:ClientConnector) {

    map props = getDatabaseMap(confJson);
    sql:ClientConnector rmDB = create sql:ClientConnector(props);
    return rmDB;
}

function createRMConnection(){
    string rmUrl;
    rmUrl = jsons:getString(confJson, "$.REDMINE.RM_URL");
    redmineConn = create http:ClientConnector(rmUrl);
}
function getRedmineRequest()(message){
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


    message request = getRedmineRequest();
    message response = {};
    response = redmineConn.get(path, request);
    json jsonResponse = messages:getJsonPayload(response);
    var count,_ =(int)jsonResponse.total_count;

    var remainder= count%limit;
    var cycles= (int)(count/limit);

    var finalCycles=0;
    if(remainder==0){
        finalCycles = cycles;

    }else{
        finalCycles = cycles+1;
    }
    return finalCycles;

}
function updateProject() {



    if (redmineConn == null) {
        createRMConnection();
    }
    message z;
    z -> updateProjectTable;

    worker updateProjectTable {
        sql:ClientConnector rmDB = createDBConnection();
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
        var loopIndex = 0;
        while (loopIndex < cycles) {

            message request = getRedmineRequest();
            json projectJson = {};
            response = redmineConn.get("/projects.json?offset=" + offset + "&limit=" + limit, request);
            projectJson = messages:getJsonPayload(response);

            var projectsCount = lengthof projectJson.projects;
            var projectIndex = 0;
            while (projectIndex < projectsCount) {
                logger:info("RM_PROJECT SYNCING...");
                //insert data
                time:Time dbUpdatedTimeStamp = time:currentTime();
                var id, _ = (int)(projectJson.projects[projectIndex].id);
                var name, _ = (string)(projectJson.projects[projectIndex].name);
                var identifier, _ = (string)(projectJson.projects[projectIndex].identifier);
                var description, _ = (string)(projectJson.projects[projectIndex].description);
                var status, _ = (int)(projectJson.projects[projectIndex].status);
                var isPublic, _ = (boolean)(projectJson.projects[projectIndex].is_public);
                var createdOn, _ = (string)(projectJson.projects[projectIndex].created_on);
                var updatedOn, _ = (string)(projectJson.projects[projectIndex].updated_on);
                var rowUpdatedOn, _ = <string>dbUpdatedTimeStamp.time;

                sql:Parameter projectId = {sqlType:"integer", value:id};
                sql:Parameter projectName = {sqlType:"varchar", value:name};
                sql:Parameter projectIdentifier = {sqlType:"varchar", value:identifier};
                sql:Parameter projectDescription = {sqlType:"varchar", value:description};
                sql:Parameter projectStatus = {sqlType:"integer", value:status};
                sql:Parameter projectIsPublic = {sqlType:"varchar", value:isPublic};
                sql:Parameter projectCreatedOn = {sqlType:"varchar", value:createdOn};
                sql:Parameter projectUpdatedOn = {sqlType:"varchar", value:updatedOn};
                sql:Parameter projectRowUpdatedOn = {sqlType:"varchar", value:rowUpdatedOn};

                params1 = [projectId];
                params2 = [projectId, projectName, projectIdentifier, projectDescription, projectStatus, projectIsPublic, projectCreatedOn, projectUpdatedOn, projectRowUpdatedOn];
                params3 = [projectName, projectIdentifier, projectDescription, projectStatus, projectIsPublic, projectCreatedOn, projectUpdatedOn, projectRowUpdatedOn, projectId];

                //last update time on redmine
                time:Time lastTimeUpdateStamp = time:parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");

                //get the row count of the RM_PROJECT table
                datatable dtProject = rmDB.select(GET_REDMINE_PROJECT_ID, params1);
                var idJson, _ = <json>dtProject;
                var idJsonLength = lengthof idJson;
                var epochTime = 0;

                if (idJson[0].epochTime != null) {
                    var epochTimeString, _ = (string)idJson[0].epochTime;
                    epochTime, _ = <int>epochTimeString;
                }
                transaction {

                    if (idJsonLength == 0) { //if rows ==0,this record is new one.
                        logger:info("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;
                        int insertResult = rmDB.update(INSERT_REDMINE_PROJECT, params2);

                    } else { // else ,this record is not new one

                        if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                            logger:info("OLD RECORD UPDATED");
                            updaterows = updaterows + 1;

                            int updateResult = rmDB.update(UPDATE_REDMINE_PROJECT, params3);

                        }
                    }
                }

                projectIndex = projectIndex + 1;
            }

            offset = offset + limit;
            loopIndex = loopIndex + 1;


        }


        if (insertrows > 0) {
            logger:info(insertrows + " RECORDS ARE INSERTED... PLEASE UPDATE THE MAPPING OF PROJECT/S IN RM_MAPPING,RM_PROJECT_TO_GITREPO_MAPPING TABLE MANUALLY...");
        } else {
            logger:info(insertrows + " RECORDS ARE INSERTED");
        }
        logger:info(updaterows + " RECORDS ARE UPDATED");
        logger:info("RM_PROJECT TABLE SYNC DONE.");
        rmDB.close();

    }}
function updateUser(){



    if (redmineConn == null) {
        createRMConnection();
    }
    message z;
    z -> updateUserTable;

    worker updateUserTable {
        sql:ClientConnector rmDB = createDBConnection();
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
        var loopIndex = 0;
        while (loopIndex < cycles) {

            message request = getRedmineRequest();
            json userJson = {};

            response = redmineConn.get("/users.json?offset=" + offset + "&limit=" + limit, request);
            userJson = messages:getJsonPayload(response);

            var usersCount = lengthof userJson.users;

            var userIndex = 0;
            while (userIndex < usersCount) {
                logger:info("RM_USER SYNCING...");
                //insert data


                var id, _ = (int)(userJson.users[userIndex].id);
                var firstName, _ = (string)(userJson.users[userIndex].firstname);
                var lastName, _ = (string)(userJson.users[userIndex].lastname);
                var mail, _ = (string)(userJson.users[userIndex].mail);
                var createdOn, _ = (string)(userJson.users[userIndex].created_on);
                var lastLoginOn, _ = (string)(userJson.users[userIndex].last_login_on);


                sql:Parameter userId = {sqlType:"integer", value:id};
                sql:Parameter userFirstName = {sqlType:"varchar", value:firstName};
                sql:Parameter userLastName = {sqlType:"varchar", value:lastName};
                sql:Parameter userMailId = {sqlType:"varchar", value:mail};
                sql:Parameter userCreatedOn = {sqlType:"varchar", value:createdOn};
                sql:Parameter userLastLoginOn = {sqlType:"varchar", value:lastLoginOn};

                params1 = [userId];
                params2 = [userId, userFirstName, userLastName, userMailId, userCreatedOn, userLastLoginOn];





                //get the row count of the RM_PROJECT table
                datatable dtUser = rmDB.select(GET_REDMINE_USER_ID, params1);
                var idJson, _ = <json>dtUser;
                var idJsonLength, _ = (int)idJson[0].rowCount;

                transaction {

                    if (idJsonLength == 0) { //if idJsonLength ==0,this record is new one.
                        //insert
                        logger:info("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;
                        int insertResult = rmDB.update(INSERT_REDMINE_USER, params2);
                    }
                }

                userIndex = userIndex + 1;
            }

            offset = offset + limit;
            loopIndex = loopIndex + 1;


        }
        logger:info(insertrows + " RECORDS ARE INSERTED");
        logger:info("RM_USER TABLE SYNC DONE.");
        rmDB.close();
    }}
function updateVersion (){



    if (redmineConn == null) {
        createRMConnection();
    }


    message z;
    z -> updateVersionTable;



    worker updateVersionTable {
        sql:ClientConnector rmDB = createDBConnection();
        logger:info("RM_VERSION TABLE SYNC STARTED...");
        message  context;
        context <- default;
        message response = {};

        sql:Parameter[] params0 = [];
        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];
        sql:Parameter[] params3 = [];




        datatable dtProject = rmDB.select(GET_ALL_REDMINE_PROJECTS_IDS, params0);
        var projectJson, err = <json>dtProject;

        var projectCount = lengthof projectJson;


        var insertrows=0;
        var updaterows=0;
        var projectIndex = 0;

        while (projectIndex < projectCount) {



            var projectId, _ = (int)projectJson[projectIndex].ID;

            message req = getRedmineRequest();
            message resp = redmineConn.get("/projects/" + projectId + "/versions.json", req);
            int statusCode = http:getStatusCode(resp);


            if (statusCode == 200) {

                //message response = {};
                var offset = 0;
                var limit = 100;
                var cycles = getCycles("/projects/" + projectId + "/versions.json?", limit);

                var loopIndex = 0;

                while (loopIndex < cycles) {

                    message request = getRedmineRequest();
                    json versionJson = {};

                    response = redmineConn.get("/projects/" + projectId + "/versions.json?offset=" + offset + "&limit=" + limit, request);
                    versionJson = messages:getJsonPayload(response);

                    var versionsCount = lengthof versionJson.versions;

                    var versionIndex = 0;
                    while (versionIndex < versionsCount) {

                        logger:info("RM_VERSION SYNCING...");
                        //insert data pre process start
                        time:Time dbUpdatedTimeStamp = time:currentTime();


                        var id = 0;
                        var project_Id = 0;
                        var parentProjectId = projectId;
                        var name = "";
                        var description = "";
                        var status = "";
                        var dueDate = "";
                        var sharing = "";
                        var marketingDescription = "";
                        var carbonVersion = "";
                        var dependsOn = "";
                        var visionDoc = "";
                        var startDate = "";
                        var releaseManagerId = 0;
                        var warrantyManagerId = 0;

                        var createdOn, _ = (string)(versionJson.versions[versionIndex].created_on);
                        var updatedOn, _ = (string)(versionJson.versions[versionIndex].updated_on);


                        var rowUpdatedOn, _ = <string>dbUpdatedTimeStamp.time;


                        if (versionJson.versions[versionIndex].id != null) {
                            id, _ = (int)(versionJson.versions[versionIndex].id);
                        }


                        if (versionJson.versions[versionIndex].project.id != null) {
                            project_Id, _ = (int)(versionJson.versions[versionIndex].project.id);
                        }

                        if (versionJson.versions[versionIndex].name != null) {
                            name, _ = (string)(versionJson.versions[versionIndex].name);
                        }

                        if (versionJson.versions[versionIndex].description != null) {
                            description, _ = (string)(versionJson.versions[versionIndex].description);
                        }

                        if (versionJson.versions[versionIndex].status != null) {
                            status, _ = (string)(versionJson.versions[versionIndex].status);
                        }

                        if (versionJson.versions[versionIndex].due_date != null) {
                            dueDate, _ = (string)(versionJson.versions[versionIndex].due_date);
                        }

                        if (versionJson.versions[versionIndex].sharing != null) {
                            sharing, _ = (string)(versionJson.versions[versionIndex].sharing);
                        }

                        var customFieldLength = lengthof versionJson.versions[versionIndex].custom_fields;
                        var customFieldIndex = 0;
                        while (customFieldIndex < customFieldLength) { //switch case for identify the custom fields
                            var customFieldId, _ = (int)(versionJson.versions[versionIndex].custom_fields[customFieldIndex].id);

                            if (customFieldId == 20) {
                                if (versionJson.versions[versionIndex].custom_fields[customFieldIndex].value != null) {
                                    marketingDescription, _ = (string)(versionJson.versions[versionIndex].custom_fields[customFieldIndex].value);
                                }
                            } else if (customFieldId == 22) {
                                if (versionJson.versions[versionIndex].custom_fields[customFieldIndex].value != null) {
                                    carbonVersion, _ = (string)(versionJson.versions[versionIndex].custom_fields[customFieldIndex].value);
                                }
                            } else if (customFieldId == 25) {
                                if (versionJson.versions[versionIndex].custom_fields[customFieldIndex].value != null) {
                                    dependsOn, _ = (string)(versionJson.versions[versionIndex].custom_fields[customFieldIndex].value);
                                }
                            } else if (customFieldId == 26) {
                                if (versionJson.versions[versionIndex].custom_fields[customFieldIndex].value != null) {
                                    visionDoc, _ = (string)(versionJson.versions[versionIndex].custom_fields[customFieldIndex].value);
                                }
                            } else if (customFieldId == 31) {
                                if (versionJson.versions[versionIndex].custom_fields[customFieldIndex].value != null) {
                                    startDate, _ = (string)(versionJson.versions[versionIndex].custom_fields[customFieldIndex].value);
                                }
                            } else if (customFieldId == 65) {
                                if (versionJson.versions[versionIndex].custom_fields[customFieldIndex].value != null) {
                                    var releaseManagerIdString, _ = (string)(versionJson.versions[versionIndex].custom_fields[customFieldIndex].value);
                                    releaseManagerId, _ = <int>releaseManagerIdString;
                                }
                            } else if (customFieldId == 66) {
                                if (versionJson.versions[versionIndex].custom_fields[customFieldIndex].value != null) {
                                    var warrantyManagerIdString, _ = (string)(versionJson.versions[versionIndex].custom_fields[customFieldIndex].value);
                                    warrantyManagerId, _ = <int>warrantyManagerIdString;
                                }
                            }
                            customFieldIndex = customFieldIndex + 1;
                        }//insert data pre process end



                        sql:Parameter versionId = {sqlType:"integer", value:id};
                        sql:Parameter versionProject_Id = {sqlType:"integer", value:project_Id};
                        sql:Parameter versionParentProjectId = {sqlType:"integer", value:parentProjectId};
                        sql:Parameter versionName = {sqlType:"varchar", value:name};
                        sql:Parameter versionDescription = {sqlType:"varchar", value:description};
                        sql:Parameter versionStatus = {sqlType:"varchar", value:status};
                        sql:Parameter versionDueDate = {sqlType:"varchar", value:dueDate};
                        sql:Parameter versionSharing = {sqlType:"varchar", value:sharing};
                        sql:Parameter versionMarketingDescription = {sqlType:"varchar", value:marketingDescription};
                        sql:Parameter versionCarbonVersion = {sqlType:"varchar", value:carbonVersion};
                        sql:Parameter versionDependsOn = {sqlType:"varchar", value:dependsOn};
                        sql:Parameter versionVisionDoc = {sqlType:"varchar", value:visionDoc};
                        sql:Parameter versionStartDate = {sqlType:"varchar", value:startDate};
                        sql:Parameter versionReleaseManagerId = {sqlType:"integer", value:releaseManagerId};
                        sql:Parameter versionWarrantyManagerId = {sqlType:"integer", value:warrantyManagerId};
                        sql:Parameter versionCreatedOn = {sqlType:"varchar", value:createdOn};
                        sql:Parameter versionUpdatedOn = {sqlType:"varchar", value:updatedOn};
                        sql:Parameter versionRowUpdatedOn = {sqlType:"varchar", value:rowUpdatedOn};
                        params1 = [versionId, versionParentProjectId];
                        params2 = [versionId, versionProject_Id, versionParentProjectId, versionName, versionDescription, versionStatus, versionDueDate, versionSharing, versionMarketingDescription, versionCarbonVersion, versionDependsOn, versionVisionDoc, versionStartDate, versionReleaseManagerId, versionWarrantyManagerId, versionCreatedOn, versionUpdatedOn, versionRowUpdatedOn];
                        params3 = [versionName, versionDescription, versionStatus, versionDueDate, versionSharing, versionMarketingDescription, versionCarbonVersion, versionDependsOn, versionVisionDoc, versionStartDate, versionReleaseManagerId, versionWarrantyManagerId, versionCreatedOn, versionUpdatedOn, versionRowUpdatedOn, versionId, versionParentProjectId];


                        //last update time on redmine
                        time:Time lastTimeUpdateStamp = time:parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");



                        //get the row count of the RM_PROJECT table
                        datatable dtversion = rmDB.select(GET_REDMINE_VERSION_ID, params1);

                        var idJson, err = <json>dtversion;

                        var idJsonLength = lengthof idJson;
                        var epochTime = 0;

                        if (idJsonLength != 0) {
                            var epochTimeString, err = (string)idJson[0].epochTime;
                            epochTime, _ = <int>epochTimeString;
                        }
                        transaction {

                            if (idJsonLength == 0) { //if rows ==0,this record is new one.
                                //insert
                                logger:info("NEW RECORD INSERTED");
                                insertrows = insertrows + 1;
                                int insertResult = rmDB.update(INSERT_REDMINE_VERSION, params2);

                            } else { // else ,this record is not new one



                                if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                                    logger:info("OLD RECORD UPDATED");
                                    updaterows = updaterows + 1;

                                    int updateResult = rmDB.update(UPDATE_REDMINE_VERSION, params3);
                                }
                            }
                        }
                        versionIndex = versionIndex + 1;
                    }

                    offset = offset + limit;
                    loopIndex = loopIndex + 1;


                }

            }





            projectIndex = projectIndex + 1;
        }
        logger:info(insertrows + " RECORDS ARE INSERTED");
        logger:info(updaterows + " RECORDS ARE UPDATED");
        logger:info("RM_VERSION TABLE SYNC DONE.");
        rmDB.close();
    }}
function updateIssue (){



    if (redmineConn == null) {
        createRMConnection();
    }
    message z;
    z -> updateIssueTable;



    worker updateIssueTable {
        sql:ClientConnector rmDB = createDBConnection();
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
        var loopIndex = 0;
        while (loopIndex < cycles) {

            message request = getRedmineRequest();
            json issueJson = {};

            response = redmineConn.get("/issues.json?status_id=*&offset=" + offset + "&limit=" + limit, request);

            issueJson = messages:getJsonPayload(response);



            var issuesCount = lengthof issueJson.issues;

            totaldataCount = totaldataCount + issuesCount;
            var issueIndex = 0;

            while (issueIndex < issuesCount) {

                logger:info("RM_ISSUE SYNCING...");
                //insert data
                time:Time dbUpdatedTimeStamp = time:currentTime();
                var id, _ = (int)(issueJson.issues[issueIndex].id);
                var projectId, _ = (int)(issueJson.issues[issueIndex].project.id);
                var projectName, _ = (string)(issueJson.issues[issueIndex].project.name);
                var trackerId, _ = (int)(issueJson.issues[issueIndex].tracker.id);
                var trackerName, _ = (string)(issueJson.issues[issueIndex].tracker.name);
                var targetVersionId = 0;
                var targetName = "";
                if (issueJson.issues[issueIndex].fixed_version != null) {
                    targetVersionId, _ = (int)(issueJson.issues[issueIndex].fixed_version.id);
                    targetName, _ = (string)(issueJson.issues[issueIndex].fixed_version.name);
                }

                var subject, _ = (string)(issueJson.issues[issueIndex].subject);
                var createdOn, _ = (string)(issueJson.issues[issueIndex].created_on);
                var updatedOn, _ = (string)(issueJson.issues[issueIndex].updated_on);
                var rowUpdatedOn, _ = <string>dbUpdatedTimeStamp.time;


                sql:Parameter issueId = {sqlType:"integer", value:id};
                sql:Parameter issueProjectId = {sqlType:"integer", value:projectId};
                sql:Parameter issueProjectName = {sqlType:"varchar", value:projectName};
                sql:Parameter issueTrackerId = {sqlType:"integer", value:trackerId};
                sql:Parameter issueTrackerName = {sqlType:"varchar", value:trackerName};
                sql:Parameter issueTargetVersionId = {sqlType:"integer", value:targetVersionId};
                sql:Parameter issueTargetName = {sqlType:"varchar", value:targetName};
                sql:Parameter issueSubject = {sqlType:"varchar", value:subject};
                sql:Parameter issueCreatedOn = {sqlType:"varchar", value:createdOn};
                sql:Parameter issueUpdatedOn = {sqlType:"varchar", value:updatedOn};
                sql:Parameter issueRowUpdatedOn = {sqlType:"varchar", value:rowUpdatedOn};


                params1 = [issueId];
                params2 = [issueId, issueProjectId, issueProjectName, issueTrackerId, issueTrackerName, issueTargetVersionId, issueTargetName, issueSubject, issueCreatedOn, issueUpdatedOn, issueRowUpdatedOn];
                params3 = [issueProjectId, issueProjectName, issueTrackerId, issueTrackerName, issueTargetVersionId, issueTargetName, issueSubject, issueCreatedOn, issueUpdatedOn, issueRowUpdatedOn, issueId];
                //last update time on redmine

                time:Time lastTimeUpdateStamp = time:parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");



                //get the row count of the RM_PROJECT table
                datatable dtissue = rmDB.select(GET_REDMINE_ISSUE_ID, params1);

                var idJson, err = <json>dtissue;

                var idJsonLength = lengthof idJson;


                var epochTime = 0;

                if (idJsonLength != 0) {
                    var epochTimeString, err = (string)idJson[0].epochTime;
                    epochTime, _ = <int>epochTimeString;
                }
                transaction {

                    if (idJsonLength == 0) { //if rows ==0,this record is new one.
                        //insert
                        logger:info("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;

                        int ret1 = rmDB.update(INSERT_REDMINE_ISSUE, params2);

                    } else { // else ,this record is not new one



                        if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                            logger:info("OLD RECORD UPDATED");
                            updaterows = updaterows + 1;

                            int ret2 = rmDB.update(UPDATE_REDMINE_ISSUE, params3);

                        }
                    }
                }

                issueIndex = issueIndex + 1;
            }

            offset = offset + limit;
            loopIndex = loopIndex + 1;


        }

        logger:info(insertrows + " RECORDS ARE INSERTED");
        logger:info(updaterows + " RECORDS ARE UPDATED");
        logger:info("RM_ISSUE TABLE SYNC DONE.");
        rmDB.close();

    }}

function getAllReleases()(json){


    sql:ClientConnector rmDB = createDBConnection();

    sql:Parameter[] params = [];
    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];
    sql:Parameter[] params3 = [];
    sql:Parameter[] params4 = [];
    sql:Parameter[] params5 = [];
    sql:Parameter[] params6 = [];
    sql:Parameter[] params7 = [];
    sql:Parameter[] params8 = [];
    sql:Parameter[] params9 = [];

    sql:Parameter emptyString = {sqlType:"varchar", value:""};
    params1=[emptyString];
    datatable dtRedmineReleaseDates = rmDB.select(GET_ALL_REDMINE_RELEASE_DATES, params1);

    var redmineReleaseDatesJson, err = <json>dtRedmineReleaseDates;
    logger:debug(redmineReleaseDatesJson);
    datatables:close(dtRedmineReleaseDates);

    json allReleases = [];
    var redmineReleaseDatesCount = lengthof redmineReleaseDatesJson;
    var redmineLoopIndex = 0;
    var unicId=0;


    while (redmineLoopIndex < redmineReleaseDatesCount) {

        json data={};

        var id= redmineLoopIndex + 1;

        var date, _=(string )redmineReleaseDatesJson[redmineLoopIndex].releaseDate;

        sql:Parameter redmineReleaseDate = {sqlType:"varchar", value:date};
        params2=[redmineReleaseDate];

        datatable dtRedmineReleaseDetails = rmDB.select(GET_REDMINE_RELEASE_DETAILS, params2);
        var redmineReleaseDetailsJson, err = <json>dtRedmineReleaseDetails;
        logger:debug(redmineReleaseDetailsJson);
        datatables:close(dtRedmineReleaseDetails);

        var redmineReleaseDetailsLength = lengthof redmineReleaseDetailsJson;
        var redmineReleaseIndex = 0;



        while (redmineReleaseIndex < redmineReleaseDetailsLength) {
            unicId=unicId + 1;

            redmineReleaseDetailsJson[redmineReleaseIndex].id = unicId;//create a unic number
            var color="";
            var area, _=(string)redmineReleaseDetailsJson[redmineReleaseIndex].productArea;
            var versionId, _=(int)redmineReleaseDetailsJson[redmineReleaseIndex].versionId;

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

            redmineReleaseDetailsJson[redmineReleaseIndex].color = color;
            redmineReleaseDetailsJson[redmineReleaseIndex].gitVersionId = 0;

            sql:Parameter redmineVersionId = {sqlType:"integer", value:versionId};
            sql:Parameter redmineFeatureId = {sqlType:"integer", value:2};//Feature
            sql:Parameter redmineStoryId = {sqlType:"integer", value:30};//Story
            params3=[redmineVersionId, redmineFeatureId];
            params4=[redmineVersionId, redmineStoryId];


            datatable dtRedmineFeatures = rmDB.select(GET_REDMINE_FEATURE_COUNT, params3);
            var jsonRedmineFeature, _ = <json>dtRedmineFeatures;
            logger:debug(jsonRedmineFeature);
            datatables:close(dtRedmineFeatures);
            var featuresCount, _=(int)jsonRedmineFeature[0].featureCount;

            datatable dtRedmineStories = rmDB.select(GET_REDMINE_STORY_COUNT, params4);
            var jsonRedmineStory, _ = <json>dtRedmineStories;
            logger:debug(jsonRedmineStory);
            datatables:close(dtRedmineStories);
            var storiesCount, _=(int)jsonRedmineStory[0].storyCount;

            redmineReleaseDetailsJson[redmineReleaseIndex].featuresCount = featuresCount;
            redmineReleaseDetailsJson[redmineReleaseIndex].storiesCount = storiesCount;

            redmineReleaseIndex = redmineReleaseIndex + 1;
        }

        data.id=id;
        data.releases= redmineReleaseDetailsJson;
        data.start=date;
        data.class="blue";

        allReleases[redmineLoopIndex] = data;


        redmineLoopIndex = redmineLoopIndex + 1;
    }

    //GitHub release details


    datatable dtGitHubReleaseDates = rmDB.select(GET_ALL_GITHUB_RELEASE_DATES, params);
    var gitHubReleaseDatesJson, err = <json>dtGitHubReleaseDates;
    logger:debug(gitHubReleaseDatesJson);
    datatables:close(dtGitHubReleaseDates);
    var gitHubReleaseDatesCount = lengthof gitHubReleaseDatesJson;
    var gitHubLoopIndex = 0;


    while(gitHubLoopIndex < gitHubReleaseDatesCount) {

        json data={};
        var date, _=(string )gitHubReleaseDatesJson[gitHubLoopIndex].RELEASE_DATE;
        var color="";
        sql:Parameter gitHubReleaseDate = {sqlType:"varchar", value:date};
        params5=[gitHubReleaseDate];

        datatable dtGitHubReleaseDetails = rmDB.select(GET_GITHUB_RELEASE_DETAILS, params5);
        var gitHubReleaseDetailsJson, err = <json>dtGitHubReleaseDetails;
        logger:debug(gitHubReleaseDetailsJson);
        datatables:close(dtGitHubReleaseDetails);

        var gitHubReleaseDetailsLength = lengthof gitHubReleaseDetailsJson;
        var gitHubReleaseIndex = 0;



        while (gitHubReleaseIndex < gitHubReleaseDetailsLength) {
            unicId=unicId + 1;
            gitHubReleaseDetailsJson[gitHubReleaseIndex].id = unicId;//create a unic number
            var area, _ = (string)gitHubReleaseDetailsJson[gitHubReleaseIndex].productArea;
            var gitReleasedVersionName, _ = (string)gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseVersion;
            var redmineProjectId, _ = (int)gitHubReleaseDetailsJson[gitHubReleaseIndex].projectId;


            if (area == "apim") {
                color = "green";
            } else if (area == "analytics") {
                color = "red";
            } else if (area == "cloud") {
                color = "blue";
            } else if (area == "integration") {
                color = "purple";
            } else if (area == "iot") {
                color = "skyblue";
            } else if (area == "identity") {
                color = "orange";
            } else if (area == "other") {
                color = "black";
            }
            gitHubReleaseDetailsJson[gitHubReleaseIndex].color = color;
            gitHubReleaseDetailsJson[gitHubReleaseIndex].start = date;

            sql:Parameter gitHubVersionName = {sqlType:"varchar", value:gitReleasedVersionName};
            sql:Parameter gitHubRedmineProjectId = {sqlType:"integer", value:redmineProjectId};
            params6=[gitHubVersionName, gitHubRedmineProjectId];
            datatable dtRedmineVersionId = rmDB.select(GET_GITHUB_TO_REDMINE_VERSION_ID, params6);
            var redmineVersion, _ = <json>dtRedmineVersionId;
            logger:debug(redmineVersion);
            datatables:close(dtRedmineVersionId);
            var redmineVersionLength= lengthof redmineVersion;



            if(redmineVersionLength>0){

                var redmineVersionId, _ =(int)redmineVersion[0].versionId;



                gitHubReleaseDetailsJson[gitHubReleaseIndex].versionId = redmineVersionId;


                sql:Parameter gitHubRedmineVersionId = {sqlType:"integer", value:redmineVersionId};

                params7=[gitHubRedmineVersionId, gitHubRedmineProjectId];
                datatable dtManagers = rmDB.select(GET_REDMINE_MANAGERS, params7);
                var redmineManagers, _ = <json>dtManagers;
                logger:debug(redmineManagers);
                datatables:close(dtManagers);
                var redmineManagersLength= lengthof redmineManagers;

                gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerF = redmineManagers[0].releaseManagerF;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerL = redmineManagers[0].releaseManagerL;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerF = redmineManagers[0].warrantyManagerF;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerL = redmineManagers[0].warrantyManagerL;


                sql:Parameter redmineStoryId = {sqlType:"integer", value:30};//Story
                sql:Parameter redmineFeatureId = {sqlType:"integer", value:2};//Feature

                params8=[gitHubRedmineVersionId, gitHubRedmineProjectId, redmineStoryId];
                params9=[gitHubRedmineVersionId, gitHubRedmineProjectId, redmineFeatureId];

                datatable dtRedmineStories = rmDB.select(GET_GITHUB_REDMINE_STORY_COUNT, params8);
                var redmineStroyCount, _ = <json>dtRedmineStories;
                logger:debug(redmineStroyCount);
                datatables:close(dtRedmineStories);
                gitHubReleaseDetailsJson[gitHubReleaseIndex].storiesCount = redmineStroyCount[0].storiesCount;

                datatable dtRedmineFeatures = rmDB.select(GET_GITHUB_REDMINE_FEATURE_COUNT, params9);
                var redmineFeatureCount, _ = <json>dtRedmineFeatures;
                logger:debug(redmineFeatureCount);
                datatables:close(dtRedmineFeatures);
                gitHubReleaseDetailsJson[gitHubReleaseIndex].featuresCount = redmineFeatureCount[0].featuresCount;



            }else{
                gitHubReleaseDetailsJson[gitHubReleaseIndex].versionId = 0;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerF = null;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerL = null;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerF = null;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerL = null;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].storiesCount = 0;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].featuresCount = 0;

            }


            gitHubReleaseIndex = gitHubReleaseIndex + 1;
        }

        data.id= redmineLoopIndex + 1;
        data.releases= gitHubReleaseDetailsJson;
        data.start=date;
        allReleases[redmineLoopIndex] = data;
        redmineLoopIndex = redmineLoopIndex + 1;
        gitHubLoopIndex = gitHubLoopIndex + 1;
    }

    rmDB.close();
    return allReleases;
}
function getReleasesByProductArea (string productArea) (json) {

    sql:ClientConnector rmDB = createDBConnection();

    sql:Parameter[] params = [];
    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];
    sql:Parameter[] params3 = [];
    sql:Parameter[] params4 = [];
    sql:Parameter[] params5 = [];
    sql:Parameter[] params6 = [];
    sql:Parameter[] params7 = [];
    sql:Parameter[] params8 = [];
    sql:Parameter[] params9 = [];






    sql:Parameter empty = {sqlType:"varchar", value:""};
    sql:Parameter mainProductArea = {sqlType:"varchar", value:productArea};
    params1=[empty, mainProductArea];
    datatable dtRedmineReleaseDates = rmDB.select(GET_ALL_REDMINE_RELEASE_DATES_BY_PRODUCT_AREA, params1);

    var redmineReleaseDatesJson, err = <json>dtRedmineReleaseDates;
    logger:debug(redmineReleaseDatesJson);
    datatables:close(dtRedmineReleaseDates);

    json allReleases = [];
    var redmineReleaseDatesCount = lengthof redmineReleaseDatesJson;
    var redmineLoopIndex = 0;
    var unicId=0;
    while (redmineLoopIndex < redmineReleaseDatesCount) {

        json data={};

        var id= redmineLoopIndex + 1;
        var date, _=(string )redmineReleaseDatesJson[redmineLoopIndex].releaseDate;

        sql:Parameter redmineReleaseDate = {sqlType:"varchar", value:date};
        params2=[redmineReleaseDate, mainProductArea];

        datatable dtRedmineReleaseDetails = rmDB.select(GET_REDMINE_RELEASE_DETAILS_BY_PRODUCT_AREA, params2);
        var redmineReleaseDetailsJson, err = <json>dtRedmineReleaseDetails;
        logger:debug(redmineReleaseDetailsJson);
        datatables:close(dtRedmineReleaseDetails);

        var redmineReleaseDetailsLength = lengthof redmineReleaseDetailsJson;
        var redmineReleaseIndex = 0;


        while (redmineReleaseIndex < redmineReleaseDetailsLength) {
            unicId=unicId + 1;
            redmineReleaseDetailsJson[redmineReleaseIndex].id = unicId;//create a unic number
            var color="";
            var area, _=(string)redmineReleaseDetailsJson[redmineReleaseIndex].productArea;
            var versionId, _=(int)redmineReleaseDetailsJson[redmineReleaseIndex].versionId;

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

            redmineReleaseDetailsJson[redmineReleaseIndex].color = color;

            sql:Parameter redmineVersionId = {sqlType:"integer", value:versionId};
            sql:Parameter redmineFeatureId = {sqlType:"integer", value:2};//Feature
            sql:Parameter redmineStoryId = {sqlType:"integer", value:30};//Story
            params3=[redmineVersionId, redmineFeatureId, mainProductArea];
            params4=[redmineVersionId, redmineStoryId, mainProductArea];


            datatable dtRedmineFeatures = rmDB.select(GET_REDMINE_FEATURE_COUNT_BY_PRODUCT_AREA, params3);
            var jsonRedmineFeature, _ = <json>dtRedmineFeatures;
            logger:debug(jsonRedmineFeature);
            datatables:close(dtRedmineFeatures);
            var featuresCount, _=(int)jsonRedmineFeature[0].featureCount;

            datatable dtRedmineStories = rmDB.select(GET_REDMINE_STORY_COUNT_BY_PRODUCT_AREA, params4);
            var jsonRedmineStory, _ = <json>dtRedmineStories;
            logger:debug(jsonRedmineStory);
            datatables:close(dtRedmineStories);
            var storiesCount, _=(int)jsonRedmineStory[0].storyCount;

            redmineReleaseDetailsJson[redmineReleaseIndex].featuresCount = featuresCount;
            redmineReleaseDetailsJson[redmineReleaseIndex].storiesCount = storiesCount;

            redmineReleaseIndex = redmineReleaseIndex + 1;
        }

        data.id=id;
        data.releases= redmineReleaseDetailsJson;
        data.start=date;
        data.class="blue";

        allReleases[redmineLoopIndex] = data;


        redmineLoopIndex = redmineLoopIndex + 1;
    }

    //GitHub release details

        params = [mainProductArea];
        datatable dtGitHubReleaseDates = rmDB.select(GET_ALL_GITHUB_RELEASE_DATES_BY_PRODUCT_AREA, params);
        var gitHubReleaseDatesJson, err = <json>dtGitHubReleaseDates;
        logger:debug(gitHubReleaseDatesJson);
        datatables:close(dtGitHubReleaseDates);

        var gitHubReleaseDatesCount = lengthof gitHubReleaseDatesJson;
        var gitHubLoopIndex = 0;
        while(gitHubLoopIndex < gitHubReleaseDatesCount) {

            json data={};
            var date, _=(string )gitHubReleaseDatesJson[gitHubLoopIndex].RELEASE_DATE;
            var color="";
            sql:Parameter gitHubReleaseDate = {sqlType:"varchar", value:date};
           
            params5=[gitHubReleaseDate, mainProductArea];

            datatable dtGitHubReleaseDetails = rmDB.select(GET_GITHUB_RELEASE_DETAILS_BY_PRODUCT_AREA, params5);
            var gitHubReleaseDetailsJson, err = <json>dtGitHubReleaseDetails;
            logger:debug(gitHubReleaseDetailsJson);
            datatables:close(dtGitHubReleaseDetails);
            var gitHubReleaseDetailsLength = lengthof gitHubReleaseDetailsJson;
            var gitHubReleaseIndex = 0;


            while (gitHubReleaseIndex < gitHubReleaseDetailsLength) {
                unicId=unicId + 1;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].id = unicId;//create a unic number
                var area, _ = (string)gitHubReleaseDetailsJson[gitHubReleaseIndex].productArea;
                var gitReleasedVersionName, _ = (string)gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseVersion;
                var redmineProjectId, _ = (int)gitHubReleaseDetailsJson[gitHubReleaseIndex].projectId;


                if (area == "apim") {
                    color = "green";
                } else if (area == "analytics") {
                    color = "red";
                } else if (area == "cloud") {
                    color = "blue";
                } else if (area == "integration") {
                    color = "purple";
                } else if (area == "iot") {
                    color = "skyblue";
                } else if (area == "identity") {
                    color = "orange";
                } else if (area == "other") {
                    color = "black";
                }
                gitHubReleaseDetailsJson[gitHubReleaseIndex].color = color;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].start = date;

                sql:Parameter gitHubVersionName = {sqlType:"varchar", value:gitReleasedVersionName};
                sql:Parameter gitHubRedmineProjectId = {sqlType:"integer", value:redmineProjectId};
                params6=[gitHubVersionName, gitHubRedmineProjectId];
                datatable dtRedmineVersionId = rmDB.select(GET_GITHUB_TO_REDMINE_VERSION_ID_BY_PRODUCT_AREA, params6);
                var redmineVersion, _ = <json>dtRedmineVersionId;
                logger:debug(redmineVersion);
                datatables:close(dtRedmineVersionId);
                var redmineVersionLength= lengthof redmineVersion;



                if(redmineVersionLength>0){

                    var redmineVersionId, _ =(int)redmineVersion[0].versionId;

                    gitHubReleaseDetailsJson[gitHubReleaseIndex].versionId = redmineVersionId;

                    sql:Parameter gitHubRedmineVersionId = {sqlType:"integer", value:redmineVersionId};

                    params7=[gitHubRedmineVersionId, gitHubRedmineProjectId];
                    datatable dtManagers = rmDB.select(GET_REDMINE_MANAGERS_BY_PRODUCT_AREA, params7);
                    var redmineManagers, _ = <json>dtManagers;
                    logger:debug(redmineManagers);
                    datatables:close(dtManagers);
                    var redmineManagersLength= lengthof redmineManagers;

                    gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerF = redmineManagers[0].releaseManagerF;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerL = redmineManagers[0].releaseManagerL;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerF = redmineManagers[0].warrantyManagerF;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerL = redmineManagers[0].warrantyManagerL;


                    sql:Parameter redmineFeatureId = {sqlType:"integer", value:2};//Feature
                    sql:Parameter redmineStoryId = {sqlType:"integer", value:30};//Story
                    params8=[gitHubRedmineVersionId, gitHubRedmineProjectId, redmineStoryId];
                    params9=[gitHubRedmineVersionId, gitHubRedmineProjectId, redmineFeatureId];

                    datatable dtRedmineStories = rmDB.select(GET_GITHUB_REDMINE_STORY_COUNT_PRODUCT_AREA, params8);
                    var redmineStroyCount, _ = <json>dtRedmineStories;
                    logger:debug(redmineStroyCount);
                    datatables:close(dtRedmineStories);
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].storiesCount = redmineStroyCount[0].storiesCount;

                    datatable dtRedmineFeatures = rmDB.select(GET_GITHUB_REDMINE_FEATURE_COUNT_BY_PRODUCT_AREA, params9);
                    var redmineFeatureCount, _ = <json>dtRedmineFeatures;
                    logger:debug(redmineFeatureCount);
                    datatables:close(dtRedmineFeatures);
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].featuresCount = redmineFeatureCount[0].featuresCount;



                }else{
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].versionId = 0;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerF = null;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerL = null;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerF = null;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerL = null;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].storiesCount = 0;
                    gitHubReleaseDetailsJson[gitHubReleaseIndex].featuresCount = 0;

                }


                gitHubReleaseIndex = gitHubReleaseIndex + 1;
            }

            data.id= redmineLoopIndex + 1;
            data.releases= gitHubReleaseDetailsJson;
            data.start=date;
            allReleases[redmineLoopIndex] = data;
            redmineLoopIndex = redmineLoopIndex + 1;
            gitHubLoopIndex = gitHubLoopIndex + 1;
        }

    rmDB.close();
    return allReleases;
}
function getManagers(string productArea, string startDate, string endDate) (json) {

    sql:ClientConnector rmDB = createDBConnection();

    json managerJson = [];

    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];

    sql:Parameter filterArea = {sqlType:"varchar", value:productArea};
    sql:Parameter filterStartDate = {sqlType:"varchar", value:startDate};
    sql:Parameter filterEndDate = {sqlType:"varchar", value:endDate};

    params1 =[filterStartDate, filterEndDate];
    params2 =[filterStartDate, filterEndDate, filterArea];

    if (productArea == "all") {
        datatable dtAllProductAreasDetails = rmDB.select(GET_MANAGER_ALL_REDMINE_RELEASES_DETAILS, params1);
        managerJson, _ = <json>dtAllProductAreasDetails;
        logger:debug(managerJson);
        datatables:close(dtAllProductAreasDetails);


    }else{
        datatable dtSingleProductAreaDetails = rmDB.select(GET_MANAGER_SINGLE_REDMINE_RELEASE_DETAILS, params2);
        managerJson, _ = <json>dtSingleProductAreaDetails;
        logger:debug(managerJson);
        datatables:close(dtSingleProductAreaDetails);

    }


    sql:Parameter[] params3 = [];
    sql:Parameter[] params4 = [];

    var managerJsonLength = lengthof managerJson;
    var loopIndex = 0;

    while (loopIndex < managerJsonLength) {


        managerJson[loopIndex].id = loopIndex;//create a unic number
        var versionId, _=(int)managerJson[loopIndex].versionId;

        sql:Parameter redmineVersionID = {sqlType:"integer", value:versionId};
        sql:Parameter redmineFeatureId = {sqlType:"integer", value:2};//Feature
        sql:Parameter redmineStoryId = {sqlType:"integer", value:30};//Story
        params3=[redmineVersionID, redmineFeatureId];
        params4=[redmineVersionID, redmineStoryId];


        datatable dtRedmineFeature = rmDB.select(GET_MANAGER_REDMINE_FEATURE_COUNT, params3);
        var redmineFeatureCount, _ = <json>dtRedmineFeature;
        logger:debug(redmineFeatureCount);
        datatables:close(dtRedmineFeature);
        var featuresCount, _=(int)redmineFeatureCount[0].featureCount;

        datatable dtRedmineStory = rmDB.select(GET_MANAGER_REDMINE_STORY_COUNT, params4);
        var redmineStoryCount, _ = <json>dtRedmineStory;
        logger:debug(redmineStoryCount);
        datatables:close(dtRedmineStory);
        var storiesCount, _=(int)redmineStoryCount[0].storyCount;

        managerJson[loopIndex].featuresCount = featuresCount;
        managerJson[loopIndex].storiesCount = storiesCount;
        managerJson[loopIndex].gitVersionId = 0;

        loopIndex = loopIndex + 1;
    }

    rmDB.close();
    return managerJson;

}
function getTrackerSubjects(int trackerId, int versionId)(json){

    sql:ClientConnector rmDB = createDBConnection();

    json trackerSubjects=[];
    sql:Parameter[] params1 = [];
    sql:Parameter redmineTrackerId = {sqlType:"integer", value:trackerId};
    sql:Parameter redmineVersionId = {sqlType:"integer", value:versionId};


    params1 =[redmineTrackerId, redmineVersionId];


    datatable dtRedmineTrackerSubjects = rmDB.select(GET_TRACKER_SUBJECTS, params1);
    trackerSubjects, _ = <json>dtRedmineTrackerSubjects;
    logger:debug(trackerSubjects);
    datatables:close(dtRedmineTrackerSubjects);

    rmDB.close();
    return trackerSubjects;
}

function getGitHubPages(string repoName, string versionName, string states, int pageLimit)(int){
    if(gitHubConn==null){
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
    var finalPages=0;

    if(remainder==0){
        finalPages=pages;
    }else{
        finalPages=pages+1;
    }
    return finalPages;

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

    if (count <= 0){
        jsonRes=null;
    }
    return jsonRes;

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

    sql:ClientConnector rmDB = createDBConnection();

    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];

    sql:Parameter redmineProjectId = {sqlType:"integer", value:projectId};
    sql:Parameter redmineVersionId = {sqlType:"integer", value:versionId};
    params1=[redmineProjectId];
    params2=[redmineVersionId];

    datatable dtGitHubRepoNames = rmDB.select(GET_GITHUB_REPO_NAMES, params1);
    var jsonRepo, _= <json>dtGitHubRepoNames;
    logger:debug(jsonRepo);
    datatables:close(dtGitHubRepoNames);




    datatable dtRedmoneVersionName = rmDB.select(GET_REDMINE_VERSION_NAMES, params2);
    var jsonVersion, _= <json>dtRedmoneVersionName;
    logger:debug(jsonVersion);
    datatables:close(dtRedmoneVersionName);

    var versionName, _=(string)jsonVersion[0].versionName;

    json jsonFinal ={"repoNames":jsonRepo, "versionName":versionName};

    rmDB.close();
    return jsonFinal;


}
function getRepoAndGitVersionByGitId(int gitVersionId)(json) {

    sql:ClientConnector rmDB = createDBConnection();
    sql:Parameter[] params1 = [];

    sql:Parameter gitHubVersionId = {sqlType:"integer", value:gitVersionId};

    params1=[gitHubVersionId];

    datatable dtGitHubRepoAndVersioNames = rmDB.select(GET_GITHUB_REPO_NAME_AND_VERSION_NAME, params1);
    var jsonRepo, _= <json>dtGitHubRepoAndVersioNames;
    logger:debug(jsonRepo);
    datatables:close(dtGitHubRepoAndVersioNames);

    var versionName, _ = (string)jsonRepo[0].gitVersionName;
    int stringLength= strings:length(versionName);
    var subStringVersionName= strings:subString(versionName,1,stringLength);
    jsonRepo[0].gitVersionName =  subStringVersionName;

    rmDB.close();
    return jsonRepo;

}

function updateGitHubReleases(){



    if(gitHubConn==null){
        createtGitHubConnection();
    }

    message z;
    z -> updateGit;

    worker updateGit {
        sql:ClientConnector rmDB = createDBConnection();
        logger:info("GH_RELEASES TABLE SYNC STARTED...");
        message  context;
        context <- default;

        sql:Parameter[] params1 = [];
        sql:Parameter empty = {sqlType:"varchar", value:""};
        params1 = [empty];
        datatable dtAllRepos = rmDB.select(GET_ALL_REPOSITORIES, params1);
        var repoJson, _ = <json>dtAllRepos;
        logger:debug(repoJson);
        datatables:close(dtAllRepos);


        int loopIndex = 0;
        while (loopIndex < lengthof repoJson) {
            var repoName, _ = (string)repoJson[loopIndex].GITHUB_REPO_NAME;

            sql:Parameter[] params2 = [];
            sql:Parameter gitHubRepoName = {sqlType:"varchar", value:repoName};
            params2 = [gitHubRepoName];
            datatable dtGitVersionCount = rmDB.select(GITHUB_VERSION_CHECK, params2);
            var gitVersionCountJson, _ = <json>dtGitVersionCount;
            logger:debug(gitVersionCountJson);
            datatables:close(dtGitVersionCount);
            var count, _ = (int)gitVersionCountJson[0].count;



            if (count > 0) {

                sql:Parameter[] params4 = [];


                params4 = [gitHubRepoName];
                datatable dtGitLastCursor = rmDB.select(GET_LAST_CURSOR_NAME, params4);
                var gitLstCursorJson, _ = <json>dtGitLastCursor;
                logger:debug(gitLstCursorJson);
                datatables:close(dtGitLastCursor);
                var lastInsertedLink, _=(string)gitLstCursorJson[0].CURSOR_NAME;

                json gitHubReleasesJson = getGitHubReleases(repoName, lastInsertedLink);

                var repoPageCount = lengthof gitHubReleasesJson;
                int pageIndex = 0;
                while (pageIndex < repoPageCount) {
                    var releaseCount= lengthof gitHubReleasesJson[pageIndex];
                    int releaseIndex = 0;
                    while(releaseIndex < releaseCount) {

                        var cursor="";
                        var versionName="";
                        var releaseDate ="";



                        if(gitHubReleasesJson[pageIndex][releaseIndex].node.tag != null) {
                            cursor, _ = (string)gitHubReleasesJson[pageIndex][releaseIndex].cursor;
                            versionName, _ = (string)gitHubReleasesJson[pageIndex][releaseIndex].node.tag.name;
                            releaseDate, _ =(string)gitHubReleasesJson[pageIndex][releaseIndex].node.publishedAt;
                            insertGitHubReleases(repoName,versionName,releaseDate,cursor);
                            logger:info("NEW RECORD INSERTED.");

                        }


                        releaseIndex = releaseIndex + 1;

                    }
                    pageIndex = pageIndex + 1;
                }
            } else {

                json gitHubInitialReleasesJson = getinitialGiHubReleases(repoName);

                var repoPageCount = lengthof gitHubInitialReleasesJson;
                int pageIndex = 0;
                while (pageIndex < repoPageCount) {
                    var releaseCount= lengthof gitHubInitialReleasesJson[pageIndex];
                    int releaseIndex = 0;
                    while(releaseIndex < releaseCount) {

                        var cursor="";
                        var versionName="";
                        var releaseDate ="";



                        if(gitHubInitialReleasesJson[pageIndex][releaseIndex].node.tag != null) {
                            cursor, _ = (string)gitHubInitialReleasesJson[pageIndex][releaseIndex].cursor;
                            versionName, _ = (string)gitHubInitialReleasesJson[pageIndex][releaseIndex].node.tag.name;
                            releaseDate, _ =(string)gitHubInitialReleasesJson[pageIndex][releaseIndex].node.publishedAt;
                            insertGitHubReleases(repoName,versionName,releaseDate,cursor);
                            logger:info("NEW RECORD INSERTED.");

                        }

                        releaseIndex = releaseIndex + 1;

                    }
                    pageIndex = pageIndex + 1;
                }


            }

            loopIndex = loopIndex + 1;
        }

    logger:info("GH_RELEASES TABLE SYNC DONE.");
    rmDB.close();

    }}
function insertGitHubReleases(string repoName, string versionName, string releaseDate, string cursor){

    sql:ClientConnector rmDB = createDBConnection();

    time:Time releaseDateAndTime = time:parse(releaseDate, "yyyy-MM-dd'T'HH:mm:ssz");
    time:Time localReleaseDateAndTime = time:toTimezone(releaseDateAndTime, "Asia/Colombo");
    string localReleaseDateAndTimeString = time:toString(localReleaseDateAndTime);


    sql:Parameter[] params1 = [];
    sql:Parameter gitHubRepoName = {sqlType:"varchar", value:repoName};
    sql:Parameter gitHubVersionName = {sqlType:"varchar", value:versionName};
    sql:Parameter gitHubReleaseDate = {sqlType:"varchar", value:localReleaseDateAndTimeString};
    sql:Parameter gitHubReleaseCursor = {sqlType:"varchar", value:cursor};
    params1 = [gitHubRepoName, gitHubVersionName, gitHubReleaseDate, gitHubReleaseCursor];

    int insertResult = rmDB.update(GITHUB_RELEASES_INSERT, params1);
    rmDB.close();

}

function getinitialGiHubReleases(string repoName)(json){
    int pageLimit = 100;
    json jsonRes =  getfirstReleases(repoName, pageLimit);

    json jsonFinal=[];

    int count;
    boolean hasNextPage;
    string nextPageLink;
    json edges;
    count, _ =(int)jsonRes.data.repository.releases.totalCount;
    if (count > 0) {

        edges = jsonRes.data.repository.releases.edges;

        hasNextPage, _ = (boolean)jsonRes.data.repository.releases.pageInfo.hasNextPage;
        nextPageLink, _ = (string)jsonRes.data.repository.releases.pageInfo.endCursor;
        count, _ =(int)jsonRes.data.repository.releases.totalCount;

        jsonFinal[0] = edges;
    }else{
        jsonFinal=[];
    }


    int loopIndex = 1;
    while(hasNextPage){


        jsonRes = getNextReleases(repoName, nextPageLink, pageLimit);
        edges = jsonRes.data.repository.releases.edges;
        hasNextPage, _ = (boolean)jsonRes.data.repository.releases.pageInfo.hasNextPage;
        nextPageLink, _ = (string)jsonRes.data.repository.releases.pageInfo.endCursor;
        count, _ =(int)jsonRes.data.repository.releases.totalCount;

        jsonFinal[loopIndex] = edges;

        loopIndex = loopIndex + 1;
    }

    return jsonFinal;

}
function getGitHubReleases(string repoName, string lastInsertedLink)(json){
    int pageLimit = 100;
    json jsonFinal=[];
    int count;
    boolean hasNextPage=true ;
    string nextPageLink = lastInsertedLink;
    json edges;
    json jsonRes;

    int loopIndex = 0;
    while(hasNextPage){

        jsonRes = getNextReleases(repoName, nextPageLink, pageLimit);

        hasNextPage, _ = (boolean)jsonRes.data.repository.releases.pageInfo.hasNextPage;


        if(jsonRes.data.repository.releases.pageInfo.endCursor != null) {
            edges = jsonRes.data.repository.releases.edges;
            nextPageLink, _ = (string)jsonRes.data.repository.releases.pageInfo.endCursor;
            count, _ = (int)jsonRes.data.repository.releases.totalCount;


            if (count > 0) {
                jsonFinal[loopIndex] = edges;
            } else {
                jsonFinal = [];
            }
        }

        loopIndex = loopIndex + 1;
    }

    return jsonFinal;

}
function getfirstReleases(string repoName, int pageLimit)(json){
    if(gitHubConn==null){
        createtGitHubConnection();
    }


    message req = {};
    message resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGitHubRequest();

    json variables = {"loginName": "wso2", "repoName": repoName, "pageLimit": pageLimit, "sort": {"field": "CREATED_AT","direction": "ASC"}};
    string query="query($loginName:String!,$repoName:String!,$pageLimit:Int!$sort:ReleaseOrder){ repository(owner: $loginName, name: $repoName) { releases(first: $pageLimit,orderBy:$sort) { edges { cursor node { name tag{ name id } publishedAt }} pageInfo { hasNextPage endCursor } totalCount }}}";

    jsonPost.query = query;
    jsonPost.variables =variables;

    messages:setJsonPayload(req,jsonPost);
    resp= gitHubConn.post("/graphql", req);
    jsonRes = messages:getJsonPayload(resp);


    var count, _ =(int)jsonRes.data.repository.releases.totalCount;
    return jsonRes;


}
function getNextReleases(string repoName, string nextPageLink, int pageLimit)(json){
    if(gitHubConn==null){
        createtGitHubConnection();
    }

    message req = {};
    message resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGitHubRequest();


    json variables = {"loginName": "wso2", "repoName": repoName, "pageLimit": pageLimit,"nextPageLink": nextPageLink, "sort": {"field": "CREATED_AT","direction": "ASC"}};
    string query="query($loginName:String!,$repoName:String!,$pageLimit:Int!,$nextPageLink:String!,$sort:ReleaseOrder){ repository(owner: $loginName, name: $repoName) { releases(first: $pageLimit,after:$nextPageLink,orderBy:$sort) { edges { cursor node { name tag{ name id } publishedAt }} pageInfo { hasNextPage endCursor } totalCount }}}";
    jsonPost.query = query;
    jsonPost.variables =variables;

    messages:setJsonPayload(req,jsonPost);
    resp= gitHubConn.post("/graphql", req);
    jsonRes = messages:getJsonPayload(resp);

    var count, _ =(int)jsonRes.data.repository.releases.totalCount;
    return jsonRes;

}

function getFixedGitIssuesCount(string repoName , string versionName)(json){

    json jsonFinal={};

    string states = "CLOSED";
    int pageLimit = 1; // maximum page limit is 100.

    json jsonRes = getInitialIssues(repoName, versionName, states, pageLimit);
    int count = 0;

    if (jsonRes!= null) {
        count, _ = (int)jsonRes.data.organization.repository.issues.totalCount;

        jsonFinal["count"] = count;
    }else{
        jsonFinal["count"] = count;
    }



    return jsonFinal;


}
function getReportedGitIssuesCount(string repoName , string versionName)(json){

    json jsonFinal={};

    string states = "OPEN";
    int pageLimit = 1; // maximum page limit is 100.

    json jsonRes = getInitialIssues(repoName, versionName, states, pageLimit);
    int count = 0;

    if (jsonRes!= null) {
        count, _ = (int)jsonRes.data.organization.repository.issues.totalCount;

        jsonFinal["count"] = count;
    }else{
        jsonFinal["count"] = count;
    }



    return jsonFinal;


}
