package org.wso2.internalapps.pqd;

import ballerina.data.sql;
import ballerina.log;
import ballerina.net.http;
import ballerina.file;
import ballerina.io;



json CONFIG_JSON = getConfData("config.json");

function getConfData(string filePath)(json){

    file:File fileSrc = {path:filePath};

    io:ByteChannel channel;

    try{
        channel = fileSrc.openChannel("r");
        log:printDebug(filePath + " file found");

    } catch (error err) {
        log:printError(filePath + " file not found. " + err.msg);
        return null;
    }

    string content;

    if (channel != null){
        io:CharacterChannel characterChannel = channel.toCharacterChannel("UTF-8");

        content = characterChannel.readCharacters(100000);
        log:printDebug(filePath + " content read");

        characterChannel.closeCharacterChannel();
        log:printDebug(filePath + " characterChannel closed");

        var configJson, _ = <json>content;
        return configJson;

    }
    return null;

}

function getSqlClientConnector()(sql:ClientConnector){

    string dbIP;
    int dbPort;
    string dbName;
    string dbUsername;
    string dbPassword;
    int poolSize;

    try {
            dbIP, _ = (string )CONFIG_JSON.PQD_JDBC.DB_HOST;
            dbPort, _ = (int )CONFIG_JSON.PQD_JDBC.DB_PORT;
            dbName, _ = (string )CONFIG_JSON.PQD_JDBC.DB_NAME;
            dbUsername, _ = (string )CONFIG_JSON.PQD_JDBC.DB_USERNAME;
            dbPassword, _ = (string )CONFIG_JSON.PQD_JDBC.DB_PASSWORD;
            poolSize, _ = (int )CONFIG_JSON.PQD_JDBC.MAXIMUM_POOL_SIZE;


    } catch (error err) {

        log:printError ("Properties not defined in config.json: " + err.msg );
        dbIP, _ = (string )CONFIG_JSON.PQD_JDBC.DB_HOST;
        dbPort, _ = (int )CONFIG_JSON.PQD_JDBC.DB_PORT;
        dbName, _ = (string )CONFIG_JSON.PQD_JDBC.DB_NAME;
        dbUsername, _ = (string )CONFIG_JSON.PQD_JDBC.DB_USERNAME;
        dbPassword, _ = (string )CONFIG_JSON.PQD_JDBC.DB_PASSWORD;
        poolSize, _ = (int )CONFIG_JSON.PQD_JDBC.MAXIMUM_POOL_SIZE;

    }

    sql:ClientConnector dbConn = create sql:ClientConnector(sql:DB.MYSQL, dbIP,  dbPort, dbName, dbUsername, dbPassword, {maximumPoolSize:poolSize});
    return dbConn;
}
function getRedmineConnector()(http:HttpClient){

    string rmUrl;

    try{
        rmUrl, _= (string)CONFIG_JSON.REDMINE.RM_URL;
    }catch(error err){
        log:printError ("Properties not defined in config.json: " + err.msg );
        rmUrl, _= (string)CONFIG_JSON.REDMINE.RM_URL;
    }

    http:HttpClient redmineConn = create http:HttpClient(rmUrl,{});
    return  redmineConn;

}
function getRedmineRequest()(http:Request){
    string rmApiKey;
    try{
        rmApiKey, _= (string)CONFIG_JSON.REDMINE.RM_API_KEY;
    }catch(error err){
        log:printError ("Properties not defined in config.json: " + err.msg );
        rmApiKey, _= (string)CONFIG_JSON.REDMINE.RM_API_KEY;
    }

    http:Request req = {};
    req.addHeader("X-Redmine-API-Key",rmApiKey);
    return req;
}
function getGitHubConnector()(http:HttpClient){
    string gitHubUrl;

    try{
        gitHubUrl, _= (string)CONFIG_JSON.GITHUB.GITHUB_URL;
    }catch(error err){
        log:printError ("Properties not defined in config.json: " + err.msg );
        gitHubUrl, _= (string)CONFIG_JSON.GITHUB.GITHUB_URL;
    }

    http:HttpClient gitHubConn = create http:HttpClient(gitHubUrl,{});
    return  gitHubConn;
}
function getGithubRequest()(http:Request){
    string gitHubToken;
    try{
        gitHubToken, _= (string)CONFIG_JSON.GITHUB.GITHUB_TOKEN;
    }catch(error err){
        log:printError ("Properties not defined in config.json: " + err.msg );
        gitHubToken, _= (string)CONFIG_JSON.GITHUB.GITHUB_TOKEN;
    }

    http:Request req = {};
    req.addHeader("Authorization",gitHubToken);
    return req;
}

function getCycles(string path, int limit)(int){

    endpoint<http:HttpClient> rmEndPoint {}
    worker x {
        http:HttpClient rmConn = getRedmineConnector();
        bind rmConn with rmEndPoint;

        http:Request req = {};
        http:Response resp = {};
        json jsonRes;
        int count;
        int remainder;
        int cycles;

        req = getRedmineRequest();
        resp, _ = rmEndPoint.get(path, req);
        jsonRes = resp.getJsonPayload();
        count, _ = (int)jsonRes.total_count;
        remainder = count % limit;
        cycles = (int)(count / limit);

        if (remainder == 0) {
            return cycles;
        } else {
            int i = cycles + 1;
            return i ;
        }
    }
}

function updateProject(http:HttpClient httpClientConn) {

    endpoint<http:HttpClient> rmEndPoint {}
    endpoint<sql:ClientConnector> rmDB {}
    worker updateProject {
        http:HttpClient rmConn = httpClientConn;
        sql:ClientConnector dbConn = getSqlClientConnector();
        bind rmConn with rmEndPoint;
        bind dbConn with rmDB;

        http:Request request = {};
        http:Response response = {};

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

            request = getRedmineRequest();
            json projectJson = {};
            response, _ = rmEndPoint.get("/projects.json?offset=" + offset + "&limit=" + limit, request);
            projectJson = response.getJsonPayload();

            var projectsCount = lengthof projectJson.projects;
            var projectIndex = 0;
            while (projectIndex < projectsCount) {
                log:printInfo("RM_PROJECT SYNCING...");
                //insert data

                Time dbUpdatedTimeStamp = currentTime();

                var id, _ = (int)(projectJson.projects[projectIndex].id);
                var name, _ = (string)(projectJson.projects[projectIndex].name);
                var identifier, _ = (string)(projectJson.projects[projectIndex].identifier);
                var description, _ = (string)(projectJson.projects[projectIndex].description);
                var status, _ = (int)(projectJson.projects[projectIndex].status);
                var isPublic, _ = (boolean)(projectJson.projects[projectIndex].is_public);
                var createdOn, _ = (string)(projectJson.projects[projectIndex].created_on);
                var updatedOn, _ = (string)(projectJson.projects[projectIndex].updated_on);
                var rowUpdatedOn, _ = <int>dbUpdatedTimeStamp.time;

                sql:Parameter projectId = {sqlType:sql:Type.INTEGER, value:id};
                sql:Parameter projectName = {sqlType:sql:Type.VARCHAR, value:name};
                sql:Parameter projectIdentifier = {sqlType:sql:Type.VARCHAR, value:identifier};
                sql:Parameter projectDescription = {sqlType:sql:Type.VARCHAR, value:description};
                sql:Parameter projectStatus = {sqlType:sql:Type.INTEGER, value:status};
                sql:Parameter projectIsPublic = {sqlType:sql:Type.VARCHAR, value:isPublic};
                sql:Parameter projectCreatedOn = {sqlType:sql:Type.VARCHAR, value:createdOn};
                sql:Parameter projectUpdatedOn = {sqlType:sql:Type.VARCHAR, value:updatedOn};
                sql:Parameter projectRowUpdatedOn = {sqlType:sql:Type.VARCHAR, value:rowUpdatedOn};

                params1 = [projectId];
                params2 = [projectId, projectName, projectIdentifier, projectDescription, projectStatus, projectIsPublic, projectCreatedOn, projectUpdatedOn, projectRowUpdatedOn];
                params3 = [projectName, projectIdentifier, projectDescription, projectStatus, projectIsPublic, projectCreatedOn, projectUpdatedOn, projectRowUpdatedOn, projectId];

                //last update time on redmine
                Time lastTimeUpdateStamp = parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");

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
                        log:printInfo("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;
                        int insertResult = rmDB.update(INSERT_REDMINE_PROJECT, params2);

                    } else { // else ,this record is not new one

                        if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                            log:printInfo("OLD RECORD UPDATED");
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
            log:printInfo(insertrows + " RECORDS ARE INSERTED... PLEASE UPDATE THE MAPPING OF PROJECT/S IN RM_MAPPING,RM_PROJECT_TO_GITREPO_MAPPING TABLE MANUALLY...");
        } else {
            log:printInfo(insertrows + " RECORDS ARE INSERTED");
        }
        log:printInfo(updaterows + " RECORDS ARE UPDATED");
        log:printInfo("RM_PROJECT TABLE SYNC DONE.");

        
        rmDB.close();


    }


}
function updateUser(http:HttpClient httpClientConn){
    endpoint<http:HttpClient> rmEndPoint {}
    endpoint<sql:ClientConnector> rmDB {}
    worker updateUser{
        http:HttpClient rmConn = httpClientConn;
        sql:ClientConnector dbConn = getSqlClientConnector();
        bind rmConn with rmEndPoint;
        bind dbConn with rmDB;

        http:Request request = {};
        http:Response response = {};

        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];

        var offset = 0;
        var limit = 100;
        var cycles = getCycles("/users.json?", limit);

        var insertrows=0;
        var loopIndex = 0;
        while (loopIndex < cycles) {

            request = getRedmineRequest();
            json userJson = {};

            response, _ = rmEndPoint.get("/users.json?offset=" + offset + "&limit=" + limit, request);
            userJson = response.getJsonPayload();

            var usersCount = lengthof userJson.users;

            var userIndex = 0;
            while (userIndex < usersCount) {
                log:printInfo("RM_USER SYNCING...");
                //insert data


                var id, _ = (int)(userJson.users[userIndex].id);
                var firstName, _ = (string)(userJson.users[userIndex].firstname);
                var lastName, _ = (string)(userJson.users[userIndex].lastname);
                var mail, _ = (string)(userJson.users[userIndex].mail);
                var createdOn, _ = (string)(userJson.users[userIndex].created_on);
                var lastLoginOn, _ = (string)(userJson.users[userIndex].last_login_on);


                sql:Parameter userId = {sqlType:sql:Type.INTEGER, value:id};
                sql:Parameter userFirstName = {sqlType:sql:Type.VARCHAR, value:firstName};
                sql:Parameter userLastName = {sqlType:sql:Type.VARCHAR, value:lastName};
                sql:Parameter userMailId = {sqlType:sql:Type.VARCHAR, value:mail};
                sql:Parameter userCreatedOn = {sqlType:sql:Type.VARCHAR, value:createdOn};
                sql:Parameter userLastLoginOn = {sqlType:sql:Type.VARCHAR, value:lastLoginOn};

                params1 = [userId];
                params2 = [userId, userFirstName, userLastName, userMailId, userCreatedOn, userLastLoginOn];





                //get the row count of the RM_PROJECT table
                datatable dtUser = rmDB.select(GET_REDMINE_USER_ID, params1);
                var idJson, _ = <json>dtUser;
                var idJsonLength, _ = (int)idJson[0].rowCount;

                transaction {

                    if (idJsonLength == 0) { //if idJsonLength ==0,this record is new one.
                        //insert
                        log:printInfo("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;
                        int insertResult = rmDB.update(INSERT_REDMINE_USER, params2);
                    }
                }

                userIndex = userIndex + 1;
            }

            offset = offset + limit;
            loopIndex = loopIndex + 1;


        }
        log:printInfo(insertrows + " RECORDS ARE INSERTED");
        log:printInfo("RM_USER TABLE SYNC DONE.");
        rmDB.close();

    }
}
function updateVersion(http:HttpClient httpClientConn){
    endpoint<http:HttpClient> rmEndPoint {}
    endpoint<sql:ClientConnector> rmDB {}
    worker updateVersion {
        http:HttpClient rmConn = httpClientConn;
        sql:ClientConnector dbConn = getSqlClientConnector();
        bind rmConn with rmEndPoint;
        bind dbConn with rmDB;

        http:Request request1 = {};
        http:Request request2 = {};
        http:Response response1 = {};
        http:Response response2 = {};

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

            request1 = getRedmineRequest();
            response1, _ = rmEndPoint.get("/projects/" + projectId + "/versions.json", request1);
            int statusCode = response1.getStatusCode();


            if (statusCode == 200) {

                //message response = {};
                var offset = 0;
                var limit = 100;
                var cycles = getCycles("/projects/" + projectId + "/versions.json?", limit);

                var loopIndex = 0;

                while (loopIndex < cycles) {

                    request2 = getRedmineRequest();
                    json versionJson = {};

                    response2, _ = rmEndPoint.get("/projects/" + projectId + "/versions.json?offset=" + offset + "&limit=" + limit, request2);
                    versionJson = response2.getJsonPayload();

                    var versionsCount = lengthof versionJson.versions;

                    var versionIndex = 0;
                    while (versionIndex < versionsCount) {

                        log:printInfo("RM_VERSION SYNCING...");
                        //insert data pre process start
                        Time dbUpdatedTimeStamp = currentTime();


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


                        var rowUpdatedOn, _ = <int>dbUpdatedTimeStamp.time;


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



                        sql:Parameter versionId = {sqlType:sql:Type.INTEGER, value:id};
                        sql:Parameter versionProject_Id = {sqlType:sql:Type.INTEGER, value:project_Id};
                        sql:Parameter versionParentProjectId = {sqlType:sql:Type.INTEGER, value:parentProjectId};
                        sql:Parameter versionName = {sqlType:sql:Type.VARCHAR, value:name};
                        sql:Parameter versionDescription = {sqlType:sql:Type.VARCHAR, value:description};
                        sql:Parameter versionStatus = {sqlType:sql:Type.VARCHAR, value:status};
                        sql:Parameter versionDueDate = {sqlType:sql:Type.VARCHAR, value:dueDate};
                        sql:Parameter versionSharing = {sqlType:sql:Type.VARCHAR, value:sharing};
                        sql:Parameter versionMarketingDescription = {sqlType:sql:Type.VARCHAR, value:marketingDescription};
                        sql:Parameter versionCarbonVersion = {sqlType:sql:Type.VARCHAR, value:carbonVersion};
                        sql:Parameter versionDependsOn = {sqlType:sql:Type.VARCHAR, value:dependsOn};
                        sql:Parameter versionVisionDoc = {sqlType:sql:Type.VARCHAR, value:visionDoc};
                        sql:Parameter versionStartDate = {sqlType:sql:Type.VARCHAR, value:startDate};
                        sql:Parameter versionReleaseManagerId = {sqlType:sql:Type.INTEGER, value:releaseManagerId};
                        sql:Parameter versionWarrantyManagerId = {sqlType:sql:Type.INTEGER, value:warrantyManagerId};
                        sql:Parameter versionCreatedOn = {sqlType:sql:Type.VARCHAR, value:createdOn};
                        sql:Parameter versionUpdatedOn = {sqlType:sql:Type.VARCHAR, value:updatedOn};
                        sql:Parameter versionRowUpdatedOn = {sqlType:sql:Type.VARCHAR, value:rowUpdatedOn};
                        params1 = [versionId, versionParentProjectId];
                        params2 = [versionId, versionProject_Id, versionParentProjectId, versionName, versionDescription, versionStatus, versionDueDate, versionSharing, versionMarketingDescription, versionCarbonVersion, versionDependsOn, versionVisionDoc, versionStartDate, versionReleaseManagerId, versionWarrantyManagerId, versionCreatedOn, versionUpdatedOn, versionRowUpdatedOn];
                        params3 = [versionName, versionDescription, versionStatus, versionDueDate, versionSharing, versionMarketingDescription, versionCarbonVersion, versionDependsOn, versionVisionDoc, versionStartDate, versionReleaseManagerId, versionWarrantyManagerId, versionCreatedOn, versionUpdatedOn, versionRowUpdatedOn, versionId, versionParentProjectId];


                        //last update time on redmine
                        Time lastTimeUpdateStamp = parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");



                        //get the row count of the RM_PROJECT table
                        datatable dtversion = rmDB.select(GET_REDMINE_VERSION_ID, params1);

                        var idJson, err = <json>dtversion;

                        var idJsonLength = lengthof idJson;
                        var epochTime = 0;

                        if (idJsonLength != 0) {
                            var epochTimeString, _ = (string)idJson[0].epochTime;
                            epochTime, _ = <int>epochTimeString;
                        }
                        transaction {

                            if (idJsonLength == 0) { //if rows ==0,this record is new one.
                                //insert
                                log:printInfo("NEW RECORD INSERTED");
                                insertrows = insertrows + 1;
                                int insertResult = rmDB.update(INSERT_REDMINE_VERSION, params2);

                            } else { // else ,this record is not new one



                                if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                                    log:printInfo("OLD RECORD UPDATED");
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
        log:printInfo(insertrows + " RECORDS ARE INSERTED");
        log:printInfo(updaterows + " RECORDS ARE UPDATED");
        log:printInfo("RM_VERSION TABLE SYNC DONE.");
        rmDB.close();

    }
}
function updateIssue(http:HttpClient httpClientConn){
    endpoint<http:HttpClient> rmEndPoint {}
    endpoint<sql:ClientConnector> rmDB {}
    worker updateIssue {
        http:HttpClient rmConn = httpClientConn;
        sql:ClientConnector dbConn = getSqlClientConnector();
        bind rmConn with rmEndPoint;
        bind dbConn with rmDB;

        http:Request request = {};
        http:Response response = {};

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

            request = getRedmineRequest();
            json issueJson = {};

            response, _ = rmEndPoint.get("/issues.json?status_id=*&offset=" + offset + "&limit=" + limit, request);

            issueJson = response.getJsonPayload();



            var issuesCount = lengthof issueJson.issues;

            totaldataCount = totaldataCount + issuesCount;
            var issueIndex = 0;

            while (issueIndex < issuesCount) {

                log:printInfo("RM_ISSUE SYNCING...");
                //insert data
                Time dbUpdatedTimeStamp = currentTime();
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
                var rowUpdatedOn, _ = <int>dbUpdatedTimeStamp.time;


                sql:Parameter issueId = {sqlType:sql:Type.INTEGER, value:id};
                sql:Parameter issueProjectId = {sqlType:sql:Type.INTEGER, value:projectId};
                sql:Parameter issueProjectName = {sqlType:sql:Type.VARCHAR, value:projectName};
                sql:Parameter issueTrackerId = {sqlType:sql:Type.INTEGER, value:trackerId};
                sql:Parameter issueTrackerName = {sqlType:sql:Type.VARCHAR, value:trackerName};
                sql:Parameter issueTargetVersionId = {sqlType:sql:Type.INTEGER, value:targetVersionId};
                sql:Parameter issueTargetName = {sqlType:sql:Type.VARCHAR, value:targetName};
                sql:Parameter issueSubject = {sqlType:sql:Type.VARCHAR, value:subject};
                sql:Parameter issueCreatedOn = {sqlType:sql:Type.VARCHAR, value:createdOn};
                sql:Parameter issueUpdatedOn = {sqlType:sql:Type.VARCHAR, value:updatedOn};
                sql:Parameter issueRowUpdatedOn = {sqlType:sql:Type.VARCHAR, value:rowUpdatedOn};


                params1 = [issueId];
                params2 = [issueId, issueProjectId, issueProjectName, issueTrackerId, issueTrackerName, issueTargetVersionId, issueTargetName, issueSubject, issueCreatedOn, issueUpdatedOn, issueRowUpdatedOn];
                params3 = [issueProjectId, issueProjectName, issueTrackerId, issueTrackerName, issueTargetVersionId, issueTargetName, issueSubject, issueCreatedOn, issueUpdatedOn, issueRowUpdatedOn, issueId];
                //last update time on redmine

                Time lastTimeUpdateStamp = parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");



                //get the row count of the RM_PROJECT table
                datatable dtissue = rmDB.select(GET_REDMINE_ISSUE_ID, params1);

                var idJson, err = <json>dtissue;

                var idJsonLength = lengthof idJson;


                var epochTime = 0;

                if (idJsonLength != 0) {
                    var epochTimeString, _ = (string)idJson[0].epochTime;
                    epochTime, _ = <int>epochTimeString;
                }
                transaction {

                    if (idJsonLength == 0) { //if rows ==0,this record is new one.
                        //insert
                        log:printInfo("NEW RECORD INSERTED");
                        insertrows = insertrows + 1;

                        int ret1 = rmDB.update(INSERT_REDMINE_ISSUE, params2);

                    } else { // else ,this record is not new one



                        if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                            log:printInfo("OLD RECORD UPDATED");
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

        log:printInfo(insertrows + " RECORDS ARE INSERTED");
        log:printInfo(updaterows + " RECORDS ARE UPDATED");
        log:printInfo("RM_ISSUE TABLE SYNC DONE.");
        rmDB.close();
    }
}

function getAllReleases()(json){

    endpoint<sql:ClientConnector> rmDB {}
    sql:ClientConnector dbConn = getSqlClientConnector();
    bind dbConn with rmDB;

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

    sql:Parameter emptyString = {sqlType:sql:Type.VARCHAR, value:""};
    params1=[emptyString];
    datatable dtRedmineReleaseDates = rmDB.select(GET_ALL_REDMINE_RELEASE_DATES, params1);

    var redmineReleaseDatesJson, err = <json>dtRedmineReleaseDates;
    log:printDebug(redmineReleaseDatesJson.toString());
    dtRedmineReleaseDates.close();

    json allReleases = [];
    var redmineReleaseDatesCount = lengthof redmineReleaseDatesJson;
    var redmineLoopIndex = 0;
    var unicId=0;

    while (redmineLoopIndex < redmineReleaseDatesCount) {

        json data={};

        var id= redmineLoopIndex + 1;

        var date, _=(string )redmineReleaseDatesJson[redmineLoopIndex].releaseDate;

        sql:Parameter redmineReleaseDate = {sqlType:sql:Type.VARCHAR, value:date};
        params2=[redmineReleaseDate];

        datatable dtRedmineReleaseDetails = rmDB.select(GET_REDMINE_RELEASE_DETAILS, params2);
        var redmineReleaseDetailsJson, err = <json>dtRedmineReleaseDetails;
        log:printDebug(redmineReleaseDetailsJson.toString());
        dtRedmineReleaseDetails.close();

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

            sql:Parameter redmineVersionId = {sqlType:sql:Type.INTEGER, value:versionId};
            sql:Parameter redmineFeatureId = {sqlType:sql:Type.INTEGER, value:2};//Feature
            sql:Parameter redmineStoryId = {sqlType:sql:Type.INTEGER, value:30};//Story
            params3=[redmineVersionId, redmineFeatureId];
            params4=[redmineVersionId, redmineStoryId];


            datatable dtRedmineFeatures = rmDB.select(GET_REDMINE_FEATURE_COUNT, params3);
            var jsonRedmineFeature, _ = <json>dtRedmineFeatures;
            log:printDebug(jsonRedmineFeature.toString());
            dtRedmineFeatures.close();
            var featuresCount, _=(int)jsonRedmineFeature[0].featureCount;

            datatable dtRedmineStories = rmDB.select(GET_REDMINE_STORY_COUNT, params4);
            var jsonRedmineStory, _ = <json>dtRedmineStories;
            log:printDebug(jsonRedmineStory.toString());
            dtRedmineStories.close();
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
    log:printDebug(gitHubReleaseDatesJson.toString());
    dtGitHubReleaseDates.close();
    var gitHubReleaseDatesCount = lengthof gitHubReleaseDatesJson;
    var gitHubLoopIndex = 0;
    while(gitHubLoopIndex < gitHubReleaseDatesCount) {

        json data={};
        var date, _=(string )gitHubReleaseDatesJson[gitHubLoopIndex].RELEASE_DATE;
        var color="";
        sql:Parameter gitHubReleaseDate = {sqlType:sql:Type.VARCHAR, value:date};
        params5=[gitHubReleaseDate];

        datatable dtGitHubReleaseDetails = rmDB.select(GET_GITHUB_RELEASE_DETAILS, params5);
        var gitHubReleaseDetailsJson, err = <json>dtGitHubReleaseDetails;
        log:printDebug(gitHubReleaseDetailsJson.toString());
        dtGitHubReleaseDetails.close();

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

            sql:Parameter gitHubVersionName = {sqlType:sql:Type.VARCHAR, value:gitReleasedVersionName};
            sql:Parameter gitHubRedmineProjectId = {sqlType:sql:Type.INTEGER, value:redmineProjectId};
            params6=[gitHubVersionName, gitHubRedmineProjectId];
            datatable dtRedmineVersionId = rmDB.select(GET_GITHUB_TO_REDMINE_VERSION_ID, params6);
            var redmineVersion, _ = <json>dtRedmineVersionId;
            log:printDebug(redmineVersion.toString());
            dtRedmineVersionId.close();
            var redmineVersionLength= lengthof redmineVersion;



            if(redmineVersionLength>0){

                var redmineVersionId, _ =(int)redmineVersion[0].versionId;



                gitHubReleaseDetailsJson[gitHubReleaseIndex].versionId = redmineVersionId;


                sql:Parameter gitHubRedmineVersionId = {sqlType:sql:Type.INTEGER, value:redmineVersionId};

                params7=[gitHubRedmineVersionId, gitHubRedmineProjectId];
                datatable dtManagers = rmDB.select(GET_REDMINE_MANAGERS, params7);
                var redmineManagers, _ = <json>dtManagers;
                log:printDebug(redmineManagers.toString());
                dtManagers.close();
                var redmineManagersLength= lengthof redmineManagers;

                gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerF = redmineManagers[0].releaseManagerF;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerL = redmineManagers[0].releaseManagerL;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerF = redmineManagers[0].warrantyManagerF;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerL = redmineManagers[0].warrantyManagerL;


                sql:Parameter redmineStoryId = {sqlType:sql:Type.INTEGER, value:30};//Story
                sql:Parameter redmineFeatureId = {sqlType:sql:Type.INTEGER, value:2};//Feature

                params8=[gitHubRedmineVersionId, gitHubRedmineProjectId, redmineStoryId];
                params9=[gitHubRedmineVersionId, gitHubRedmineProjectId, redmineFeatureId];

                datatable dtRedmineStories = rmDB.select(GET_GITHUB_REDMINE_STORY_COUNT, params8);
                var redmineStroyCount, _ = <json>dtRedmineStories;
                log:printDebug(redmineStroyCount.toString());
                dtRedmineStories.close();
                gitHubReleaseDetailsJson[gitHubReleaseIndex].storiesCount = redmineStroyCount[0].storiesCount;

                datatable dtRedmineFeatures = rmDB.select(GET_GITHUB_REDMINE_FEATURE_COUNT, params9);
                var redmineFeatureCount, _ = <json>dtRedmineFeatures;
                log:printDebug(redmineFeatureCount.toString());
                dtRedmineFeatures.close();
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
function getReleasesByProduct(string productArea)(json){
    endpoint<sql:ClientConnector> rmDB {}
    sql:ClientConnector dbConn = getSqlClientConnector();
    bind dbConn with rmDB;

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


    sql:Parameter empty = {sqlType:sql:Type.VARCHAR, value:""};
    sql:Parameter mainProductArea = {sqlType:sql:Type.VARCHAR, value:productArea};
    params1=[empty, mainProductArea];
    datatable dtRedmineReleaseDates = rmDB.select(GET_ALL_REDMINE_RELEASE_DATES_BY_PRODUCT_AREA, params1);

    var redmineReleaseDatesJson, err = <json>dtRedmineReleaseDates;
    log:printDebug(redmineReleaseDatesJson.toString());
    dtRedmineReleaseDates.close();

    json allReleases = [];
    var redmineReleaseDatesCount = lengthof redmineReleaseDatesJson;
    var redmineLoopIndex = 0;
    var unicId=0;
    while (redmineLoopIndex < redmineReleaseDatesCount) {

        json data={};

        var id= redmineLoopIndex + 1;
        var date, _=(string )redmineReleaseDatesJson[redmineLoopIndex].releaseDate;

        sql:Parameter redmineReleaseDate = {sqlType:sql:Type.VARCHAR, value:date};
        params2=[redmineReleaseDate, mainProductArea];

        datatable dtRedmineReleaseDetails = rmDB.select(GET_REDMINE_RELEASE_DETAILS_BY_PRODUCT_AREA, params2);
        var redmineReleaseDetailsJson, err = <json>dtRedmineReleaseDetails;
        log:printDebug(redmineReleaseDetailsJson.toString());
        dtRedmineReleaseDetails.close();

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

            sql:Parameter redmineVersionId = {sqlType:sql:Type.INTEGER, value:versionId};
            sql:Parameter redmineFeatureId = {sqlType:sql:Type.INTEGER, value:2};//Feature
            sql:Parameter redmineStoryId = {sqlType:sql:Type.INTEGER, value:30};//Story
            params3=[redmineVersionId, redmineFeatureId, mainProductArea];
            params4=[redmineVersionId, redmineStoryId, mainProductArea];


            datatable dtRedmineFeatures = rmDB.select(GET_REDMINE_FEATURE_COUNT_BY_PRODUCT_AREA, params3);
            var jsonRedmineFeature, _ = <json>dtRedmineFeatures;
            log:printDebug(jsonRedmineFeature.toString());
            dtRedmineFeatures.close();
            var featuresCount, _=(int)jsonRedmineFeature[0].featureCount;

            datatable dtRedmineStories = rmDB.select(GET_REDMINE_STORY_COUNT_BY_PRODUCT_AREA, params4);
            var jsonRedmineStory, _ = <json>dtRedmineStories;
            log:printDebug(jsonRedmineStory.toString());
            dtRedmineStories.close();
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
    log:printDebug(gitHubReleaseDatesJson.toString());
    dtGitHubReleaseDates.close();

    var gitHubReleaseDatesCount = lengthof gitHubReleaseDatesJson;
    var gitHubLoopIndex = 0;
    while(gitHubLoopIndex < gitHubReleaseDatesCount) {

        json data={};
        var date, _=(string )gitHubReleaseDatesJson[gitHubLoopIndex].RELEASE_DATE;
        var color="";
        sql:Parameter gitHubReleaseDate = {sqlType:sql:Type.VARCHAR, value:date};

        params5=[gitHubReleaseDate, mainProductArea];

        datatable dtGitHubReleaseDetails = rmDB.select(GET_GITHUB_RELEASE_DETAILS_BY_PRODUCT_AREA, params5);
        var gitHubReleaseDetailsJson, err = <json>dtGitHubReleaseDetails;
        log:printDebug(gitHubReleaseDetailsJson.toString());
        dtGitHubReleaseDetails.close();
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

            sql:Parameter gitHubVersionName = {sqlType:sql:Type.VARCHAR, value:gitReleasedVersionName};
            sql:Parameter gitHubRedmineProjectId = {sqlType:sql:Type.INTEGER, value:redmineProjectId};
            params6=[gitHubVersionName, gitHubRedmineProjectId];
            datatable dtRedmineVersionId = rmDB.select(GET_GITHUB_TO_REDMINE_VERSION_ID_BY_PRODUCT_AREA, params6);
            var redmineVersion, _ = <json>dtRedmineVersionId;
            log:printDebug(redmineVersion.toString());
            dtRedmineVersionId.close();
            var redmineVersionLength= lengthof redmineVersion;



            if(redmineVersionLength>0){

                var redmineVersionId, _ =(int)redmineVersion[0].versionId;

                gitHubReleaseDetailsJson[gitHubReleaseIndex].versionId = redmineVersionId;

                sql:Parameter gitHubRedmineVersionId = {sqlType:sql:Type.INTEGER, value:redmineVersionId};

                params7=[gitHubRedmineVersionId, gitHubRedmineProjectId];
                datatable dtManagers = rmDB.select(GET_REDMINE_MANAGERS_BY_PRODUCT_AREA, params7);
                var redmineManagers, _ = <json>dtManagers;
                log:printDebug(redmineManagers.toString());
                dtManagers.close();
                var redmineManagersLength= lengthof redmineManagers;

                gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerF = redmineManagers[0].releaseManagerF;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].releaseManagerL = redmineManagers[0].releaseManagerL;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerF = redmineManagers[0].warrantyManagerF;
                gitHubReleaseDetailsJson[gitHubReleaseIndex].warrantyManagerL = redmineManagers[0].warrantyManagerL;


                sql:Parameter redmineFeatureId = {sqlType:sql:Type.INTEGER, value:2};//Feature
                sql:Parameter redmineStoryId = {sqlType:sql:Type.INTEGER, value:30};//Story
                params8=[gitHubRedmineVersionId, gitHubRedmineProjectId, redmineStoryId];
                params9=[gitHubRedmineVersionId, gitHubRedmineProjectId, redmineFeatureId];

                datatable dtRedmineStories = rmDB.select(GET_GITHUB_REDMINE_STORY_COUNT_PRODUCT_AREA, params8);
                var redmineStroyCount, _ = <json>dtRedmineStories;
                log:printDebug(redmineStroyCount.toString());
                dtRedmineStories.close();
                gitHubReleaseDetailsJson[gitHubReleaseIndex].storiesCount = redmineStroyCount[0].storiesCount;

                datatable dtRedmineFeatures = rmDB.select(GET_GITHUB_REDMINE_FEATURE_COUNT_BY_PRODUCT_AREA, params9);
                var redmineFeatureCount, _ = <json>dtRedmineFeatures;
                log:printDebug(redmineFeatureCount.toString());
                dtRedmineFeatures.close();
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
function getManagers(string productArea, string startDate, string endDate)(json){
    endpoint<sql:ClientConnector> rmDB {}
    sql:ClientConnector dbConn = getSqlClientConnector();
    bind dbConn with rmDB;

    json managerJson = [];

    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];

    sql:Parameter filterArea = {sqlType:sql:Type.VARCHAR, value:productArea};
    sql:Parameter filterStartDate = {sqlType:sql:Type.VARCHAR, value:startDate};
    sql:Parameter filterEndDate = {sqlType:sql:Type.VARCHAR, value:endDate};

    params1 =[filterStartDate, filterEndDate];
    params2 =[filterStartDate, filterEndDate, filterArea];

    if (productArea == "all") {
        datatable dtAllProductAreasDetails = rmDB.select(GET_MANAGER_ALL_REDMINE_RELEASES_DETAILS, params1);
        managerJson, _ = <json>dtAllProductAreasDetails;
        log:printDebug(managerJson.toString());
        dtAllProductAreasDetails.close();


    }else{
        datatable dtSingleProductAreaDetails = rmDB.select(GET_MANAGER_SINGLE_REDMINE_RELEASE_DETAILS, params2);
        managerJson, _ = <json>dtSingleProductAreaDetails;
        log:printDebug(managerJson.toString());
        dtSingleProductAreaDetails.close();

    }


    sql:Parameter[] params3 = [];
    sql:Parameter[] params4 = [];

    var managerJsonLength = lengthof managerJson;
    var loopIndex = 0;

    while (loopIndex < managerJsonLength) {


        managerJson[loopIndex].id = loopIndex;//create a unic number
        var versionId, _=(int)managerJson[loopIndex].versionId;

        sql:Parameter redmineVersionID = {sqlType:sql:Type.INTEGER, value:versionId};
        sql:Parameter redmineFeatureId = {sqlType:sql:Type.INTEGER, value:2};//Feature
        sql:Parameter redmineStoryId = {sqlType:sql:Type.INTEGER, value:30};//Story
        params3=[redmineVersionID, redmineFeatureId];
        params4=[redmineVersionID, redmineStoryId];


        datatable dtRedmineFeature = rmDB.select(GET_MANAGER_REDMINE_FEATURE_COUNT, params3);
        var redmineFeatureCount, _ = <json>dtRedmineFeature;
        log:printDebug(redmineFeatureCount.toString());
        dtRedmineFeature.close();
        var featuresCount, _=(int)redmineFeatureCount[0].featureCount;

        datatable dtRedmineStory = rmDB.select(GET_MANAGER_REDMINE_STORY_COUNT, params4);
        var redmineStoryCount, _ = <json>dtRedmineStory;
        log:printDebug(redmineStoryCount.toString());
        dtRedmineStory.close();
        var storiesCount, _=(int)redmineStoryCount[0].storyCount;

        managerJson[loopIndex].featuresCount = featuresCount;
        managerJson[loopIndex].storiesCount = storiesCount;
        managerJson[loopIndex].gitVersionId = 0;

        loopIndex = loopIndex + 1;
    }
    rmDB.close();
    return managerJson;
}
function getTrackerSubjects(string trackerId, string versionId)(json){
    endpoint<sql:ClientConnector> rmDB {}
    sql:ClientConnector dbConn = getSqlClientConnector();
    bind dbConn with rmDB;

    var trackerIdInt, _ = <int>trackerId;
    var versionIdInt, _ = <int>versionId;

    json trackerSubjects=[];

    sql:Parameter[] params1 = [];

    sql:Parameter redmineTrackerId = {sqlType:sql:Type.INTEGER, value:trackerIdInt};
    sql:Parameter redmineVersionId = {sqlType:sql:Type.INTEGER, value:versionIdInt};

    params1 =[redmineTrackerId, redmineVersionId];

    datatable dtRedmineTrackerSubjects = rmDB.select(GET_TRACKER_SUBJECTS, params1);

    trackerSubjects, _ = <json>dtRedmineTrackerSubjects;
    log:printDebug(trackerSubjects.toString());
    dtRedmineTrackerSubjects.close();

    rmDB.close();
    return trackerSubjects;

}

function getGitHubPages(string repoName, string versionName, string states, int pageLimit)(int){
    endpoint<http:HttpClient> gitHubEnd {}
    http:HttpClient gitConn = getGitHubConnector();
    bind gitConn with gitHubEnd;

    http:Request req = {};
    http:Response resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGithubRequest();
    json variables = { "loginName": "wso2", "repoName": repoName,  "issueStates": states, "versionName": versionName};
    string query = "query ($loginName:String! $repoName:String! $issueStates:[IssueState!] $versionName:[String!]){ organization(login: $loginName) { repository(name:$repoName) { name, issues(first: 10, states:$issueStates, labels:$versionName) { totalCount } } } }";

    jsonPost.query = query;
    jsonPost.variables =variables;

    req.setJsonPayload(jsonPost);
    resp, _= gitHubEnd.post("/graphql", req);
    jsonRes = resp.getJsonPayload();

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


function getInitialIssues(http:HttpClient httpClientConn, string repoName, string versionName, string states, int pageLimit)(json){
    endpoint<http:HttpClient> gitHubEnd {}
    http:HttpClient  gitConn = httpClientConn;
    bind gitConn with gitHubEnd;

    http:Request req = {};
    http:Response resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGithubRequest();
    json variables = { "loginName": "wso2", "repoName": repoName,  "pageLimit":pageLimit, "issueStates": states, "versionName": versionName};
    string query = "query ($loginName:String! $repoName:String! $pageLimit:Int! $issueStates:[IssueState!] $versionName:[String!]){ organization(login: $loginName) { repository(name:$repoName) { name, issues(first: $pageLimit, states:$issueStates, labels:$versionName) { totalCount,pageInfo{ hasNextPage,endCursor }, nodes{ title,url } } } } }";

    jsonPost.query = query;
    jsonPost.variables =variables;

    req.setJsonPayload(jsonPost);
    resp, _= gitHubEnd.post("/graphql", req);
    jsonRes = resp.getJsonPayload();
    var count, _ = (int)jsonRes.data.organization.repository.issues.totalCount;
    if (count <= 0){
        jsonRes=null;
    }
    return jsonRes;

}
function getNextIssues(http:HttpClient httpClientConn, string repoName, string versionName, string states, int pageLimit, string nextPageLink)(json){
    endpoint<http:HttpClient> gitHubEnd {}
    http:HttpClient  gitConn = httpClientConn;
    bind gitConn with gitHubEnd;

    http:Request req = {};
    http:Response resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGithubRequest();
    json variables = { "loginName": "wso2", "repoName": repoName,  "pageLimit":pageLimit, "nextPageLink":nextPageLink, "issueStates": states, "versionName": versionName};
    string query = "query ($loginName:String! $repoName:String! $nextPageLink:String! $pageLimit:Int! $issueStates:[IssueState!] $versionName:[String!]){ organization(login: $loginName) { repository(name:$repoName) { name, issues(first: $pageLimit, after:$nextPageLink, states:$issueStates, labels:$versionName) { totalCount,pageInfo{ hasNextPage,endCursor }, nodes{ title,url } } } } }";

    jsonPost.query = query;
    jsonPost.variables =variables;

    req.setJsonPayload(jsonPost);
    resp, _= gitHubEnd.post("/graphql", req);
    jsonRes = resp.getJsonPayload();
    return jsonRes;
}
function getFixedGitIssues(http:HttpClient httpClientConn, string repoName , string versionName)(json){

    json jsonFinal=[];

    string states = "CLOSED";
    int pageLimit = 100; // maximum page limit is 100.


    json jsonRes = getInitialIssues(httpClientConn, repoName, versionName, states, pageLimit);
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
        jsonRes = getNextIssues(httpClientConn, repoName, versionName, states, pageLimit, nextPageLink);
        count, _ =(int)jsonRes.data.organization.repository.issues.totalCount;
        hasNextPage, _ =(boolean)jsonRes.data.organization.repository.issues.pageInfo.hasNextPage;
        nextPageLink, _=(string )jsonRes.data.organization.repository.issues.pageInfo.endCursor;
        nodes = jsonRes.data.organization.repository.issues.nodes;

        jsonFinal[i]=nodes;

        i = i + 1;
    }


    return jsonFinal;



}
function getReportedGitIssues(http:HttpClient httpClientConn, string repoName , string versionName)(json){

    json jsonFinal=[];

    string states = "OPEN";
    int pageLimit = 100; // maximum page limit is 100.


    json jsonRes = getInitialIssues(httpClientConn, repoName, versionName, states, pageLimit);
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
        jsonRes = getNextIssues(httpClientConn, repoName, versionName, states, pageLimit, nextPageLink);
        count, _ =(int)jsonRes.data.organization.repository.issues.totalCount;
        hasNextPage, _ =(boolean)jsonRes.data.organization.repository.issues.pageInfo.hasNextPage;
        nextPageLink, _=(string )jsonRes.data.organization.repository.issues.pageInfo.endCursor;
        nodes = jsonRes.data.organization.repository.issues.nodes;

        jsonFinal[i]=nodes;

        i = i + 1;
    }


    return jsonFinal;


}

function getRepoAndVersion(string projectId, string versionId)(json){

    endpoint<sql:ClientConnector> rmDB {}
    sql:ClientConnector dbConn = getSqlClientConnector();
    bind dbConn with rmDB;

    var trackerIdInt, _ = <int>projectId;
    var versionIdInt, _ = <int>versionId;
    
    sql:Parameter[] params1 = [];
    sql:Parameter[] params2 = [];

    sql:Parameter redmineProjectId = {sqlType:sql:Type.INTEGER, value:trackerIdInt};
    sql:Parameter redmineVersionId = {sqlType:sql:Type.INTEGER, value:versionIdInt};
    params1=[redmineProjectId];
    params2=[redmineVersionId];

    datatable dtGitHubRepoNames = rmDB.select(GET_GITHUB_REPO_NAMES, params1);
    var jsonRepo, _= <json>dtGitHubRepoNames;
    log:printDebug(jsonRepo.toString());
    dtGitHubRepoNames.close();




    datatable dtRedmoneVersionName = rmDB.select(GET_REDMINE_VERSION_NAMES, params2);
    var jsonVersion, _= <json>dtRedmoneVersionName;
    log:printDebug(jsonVersion.toString());
    dtRedmoneVersionName.close();

    var versionName, _=(string)jsonVersion[0].versionName;

    json jsonFinal ={"repoNames":jsonRepo, "versionName":versionName};

    rmDB.close();
    return jsonFinal;


}
function getRepoAndGitVersionByGitId(string gitVersionId)(json) {
    endpoint<sql:ClientConnector> rmDB {}
    sql:ClientConnector dbConn = getSqlClientConnector();
    bind dbConn with rmDB;

    var gitVersionIdInt, _ = <int>gitVersionId;
    sql:Parameter[] params1 = [];

    sql:Parameter gitHubVersionId = {sqlType:sql:Type.INTEGER, value:gitVersionIdInt};

    params1=[gitHubVersionId];

    datatable dtGitHubRepoAndVersioNames = rmDB.select(GET_GITHUB_REPO_NAME_AND_VERSION_NAME, params1);
    var jsonRepo, _= <json>dtGitHubRepoAndVersioNames;
    log:printDebug(jsonRepo.toString());
    dtGitHubRepoAndVersioNames.close();

    var versionName, _ = (string)jsonRepo[0].gitVersionName;
    int stringLength= versionName.length();
    var subStringVersionName= versionName.subString(1,stringLength);
    jsonRepo[0].gitVersionName =  subStringVersionName;

    rmDB.close();
    return jsonRepo;

}

function updateGitHubReleases(http:HttpClient httpRedmineClientConn,http:HttpClient httpGitHubClientConn){
    endpoint<http:HttpClient> rmEndPoint {}
    endpoint<sql:ClientConnector> rmDB {}
    
    worker updateGit {
        http:HttpClient rmConn = httpRedmineClientConn;
        sql:ClientConnector dbConn = getSqlClientConnector();
        bind rmConn with rmEndPoint;
        bind dbConn with rmDB;

        http:Request request = {};
        http:Response response = {};
        
        
        sql:Parameter[] params1 = [];
        sql:Parameter empty = {sqlType:sql:Type.VARCHAR, value:""};
        params1 = [empty];
        datatable dtAllRepos = rmDB.select(GET_ALL_REPOSITORIES, params1);
        var repoJson, _ = <json>dtAllRepos;
        log:printDebug(repoJson.toString());
        dtAllRepos.close();
    
    
        int loopIndex = 0;
        while (loopIndex < lengthof repoJson) {
            var repoName, _ = (string)repoJson[loopIndex].GITHUB_REPO_NAME;
    
            sql:Parameter[] params2 = [];
            sql:Parameter gitHubRepoName = {sqlType:sql:Type.VARCHAR, value:repoName};
            params2 = [gitHubRepoName];
            datatable dtGitVersionCount = rmDB.select(GITHUB_VERSION_CHECK, params2);
            var gitVersionCountJson, _ = <json>dtGitVersionCount;
            log:printDebug(gitVersionCountJson.toString());
            dtGitVersionCount.close();
            var count, _ = (int)gitVersionCountJson[0].count;
    
    
    
            if (count > 0) {
    
                sql:Parameter[] params4 = [];
    
    
                params4 = [gitHubRepoName];
                datatable dtGitLastCursor = rmDB.select(GET_LAST_CURSOR_NAME, params4);
                var gitLstCursorJson, _ = <json>dtGitLastCursor;
                log:printDebug(gitLstCursorJson.toString());
                dtGitLastCursor.close();
                var lastInsertedLink, _=(string)gitLstCursorJson[0].CURSOR_NAME;
    
                json gitHubReleasesJson = getGitHubReleases(httpGitHubClientConn, repoName, lastInsertedLink);
    
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
                            log:printInfo("NEW RECORD INSERTED.");
    
                        }
    
    
                        releaseIndex = releaseIndex + 1;
    
                    }
                    pageIndex = pageIndex + 1;
                }
            } else {
    
                json gitHubInitialReleasesJson = getinitialGiHubReleases(httpGitHubClientConn, repoName);
    
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
                            log:printInfo("NEW RECORD INSERTED.");
    
                        }
    
                        releaseIndex = releaseIndex + 1;
    
                    }
                    pageIndex = pageIndex + 1;
                }
    
    
            }
    
            loopIndex = loopIndex + 1;
        }
    
        log:printInfo("GH_RELEASES TABLE SYNC DONE.");
        rmDB.close();
    }
}
function insertGitHubReleases(string repoName, string versionName, string releaseDate, string cursor){
    endpoint<sql:ClientConnector> rmDB {}
    sql:ClientConnector dbConn = getSqlClientConnector();
    bind dbConn with rmDB;

    Time releaseDateAndTime = parse(releaseDate, "yyyy-MM-dd'T'HH:mm:ssz");
    Time localReleaseDateAndTime = releaseDateAndTime.toTimezone("Asia/Colombo");
    string localReleaseDateAndTimeString = localReleaseDateAndTime.toString();


    sql:Parameter[] params1 = [];
    sql:Parameter gitHubRepoName = {sqlType:sql:Type.VARCHAR, value:repoName};
    sql:Parameter gitHubVersionName = {sqlType:sql:Type.VARCHAR, value:versionName};
    sql:Parameter gitHubReleaseDate = {sqlType:sql:Type.VARCHAR, value:localReleaseDateAndTimeString};
    sql:Parameter gitHubReleaseCursor = {sqlType:sql:Type.VARCHAR, value:cursor};
    params1 = [gitHubRepoName, gitHubVersionName, gitHubReleaseDate, gitHubReleaseCursor];

    int insertResult = rmDB.update(GITHUB_RELEASES_INSERT, params1);
    rmDB.close();

}

function getinitialGiHubReleases(http:HttpClient httpClientConn, string repoName)(json){
    int pageLimit = 100;
    json jsonRes =  getfirstReleases(httpClientConn, repoName, pageLimit);

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


        jsonRes = getNextReleases(httpClientConn, repoName, nextPageLink, pageLimit);
        edges = jsonRes.data.repository.releases.edges;
        hasNextPage, _ = (boolean)jsonRes.data.repository.releases.pageInfo.hasNextPage;
        nextPageLink, _ = (string)jsonRes.data.repository.releases.pageInfo.endCursor;
        count, _ =(int)jsonRes.data.repository.releases.totalCount;

        jsonFinal[loopIndex] = edges;

        loopIndex = loopIndex + 1;
    }

    return jsonFinal;

}
function getGitHubReleases(http:HttpClient httpClientConn, string repoName, string lastInsertedLink)(json){
    int pageLimit = 100;
    json jsonFinal=[];
    int count;
    boolean hasNextPage=true ;
    string nextPageLink = lastInsertedLink;
    json edges;
    json jsonRes;

    int loopIndex = 0;
    while(hasNextPage){

        jsonRes = getNextReleases(httpClientConn, repoName, nextPageLink, pageLimit);

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
function getfirstReleases(http:HttpClient httpClientConn, string repoName, int pageLimit)(json){
    endpoint<http:HttpClient> gitHubEnd {}
    http:HttpClient  gitConn = httpClientConn;
    bind gitConn with gitHubEnd;

    http:Request req = {};
    http:Response resp = {};

    json jsonPost = {};
    json jsonRes ={};

    req = getGithubRequest();

    json variables = {"loginName": "wso2", "repoName": repoName, "pageLimit": pageLimit, "sort": {"field": "CREATED_AT","direction": "ASC"}};
    string query="query($loginName:String!,$repoName:String!,$pageLimit:Int!$sort:ReleaseOrder){ repository(owner: $loginName, name: $repoName) { releases(first: $pageLimit,orderBy:$sort) { edges { cursor node { name tag{ name id } publishedAt }} pageInfo { hasNextPage endCursor } totalCount }}}";

    jsonPost.query = query;
    jsonPost.variables =variables;

    req.setJsonPayload(jsonPost);
    resp, _= gitHubEnd.post("/graphql", req);
    jsonRes = resp.getJsonPayload();


    var count, _ =(int)jsonRes.data.repository.releases.totalCount;
    return jsonRes;


}
function getNextReleases(http:HttpClient httpClientConn, string repoName, string nextPageLink, int pageLimit)(json){
    endpoint<http:HttpClient> gitHubEnd {}
    http:HttpClient  gitConn = httpClientConn;
    bind gitConn with gitHubEnd;

    http:Request req = {};
    http:Response resp = {};
    json jsonPost = {};
    json jsonRes ={};

    req = getGithubRequest();


    json variables = {"loginName": "wso2", "repoName": repoName, "pageLimit": pageLimit,"nextPageLink": nextPageLink, "sort": {"field": "CREATED_AT","direction": "ASC"}};
    string query="query($loginName:String!,$repoName:String!,$pageLimit:Int!,$nextPageLink:String!,$sort:ReleaseOrder){ repository(owner: $loginName, name: $repoName) { releases(first: $pageLimit,after:$nextPageLink,orderBy:$sort) { edges { cursor node { name tag{ name id } publishedAt }} pageInfo { hasNextPage endCursor } totalCount }}}";
    jsonPost.query = query;
    jsonPost.variables =variables;

    req.setJsonPayload(jsonPost);
    resp, _= gitHubEnd.post("/graphql", req);
    jsonRes = resp.getJsonPayload();

    var count, _ =(int)jsonRes.data.repository.releases.totalCount;
    return jsonRes;

}

function getFixedGitIssuesCount(http:HttpClient httpClientConn, string repoName , string versionName)(json){

    json jsonFinal={};

    string states = "CLOSED";
    int pageLimit = 1; // maximum page limit is 100.

    json jsonRes = getInitialIssues(httpClientConn, repoName, versionName, states, pageLimit);
    int count = 0;

    if (jsonRes!= null) {
        count, _ = (int)jsonRes.data.organization.repository.issues.totalCount;

        jsonFinal["count"] = count;
    }else{
        jsonFinal["count"] = count;
    }



    return jsonFinal;


}
function getReportedGitIssuesCount(http:HttpClient httpClientConn, string repoName , string versionName)(json){

    json jsonFinal={};

    string states = "OPEN";
    int pageLimit = 1; // maximum page limit is 100.

    json jsonRes = getInitialIssues(httpClientConn, repoName, versionName, states, pageLimit);
    int count = 0;

    if (jsonRes!= null) {
        count, _ = (int)jsonRes.data.organization.repository.issues.totalCount;

        jsonFinal["count"] = count;
    }else{
        jsonFinal["count"] = count;
    }



    return jsonFinal;


}