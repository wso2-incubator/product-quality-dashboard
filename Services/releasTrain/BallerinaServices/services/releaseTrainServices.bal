package releaseTrainpkg;


import ballerina.net.http;
import ballerina.data.sql;
import ballerina.lang.messages;
import org.wso2.ballerina.connectors.basicauth;
import ballerina.lang.time;
import ballerina.utils.logger;



@http:configuration {basePath:"/base",httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks",
                     keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> releaseTrainService {

    json confJson = readConfig("config.json");

    basicauth:ClientConnector redmineConnector = setRedmineConfig(confJson);
    map props = setDatabaseConfig(confJson);
    sql:ClientConnector rmDB = create sql:ClientConnector(props);

    sql:Parameter[] params = [];



    @http:GET {}
    @http:Path{value:"/"}
    resource resource1 (message m) {

        message send={};

        logger:info("test");



        messages:setJsonPayload(send,"test");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/project"}
    resource resource2 (message m) {

        m -> updateProjectTable;

        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;

        worker updateProjectTable {
            logger:info("RM_PROJECT TABLE SYNC STARTED...");
            message  context;
            context <- default;
            message response ={};
            sql:Parameter[] params1 = [];
            sql:Parameter[] params2 = [];
            sql:Parameter[] params3 = [];

            var offset = 0;
            var limit = 100;
            var cycles = getCycles("/projects.json?", limit);

            var insertrows=0;
            var updaterows=0;
            var i = 0;
            while (i < cycles) {

                message n = {};
                json jsn1 = {};
                response = redmineConnector.get("/projects.json?offset=" + offset + "&limit=" + limit, n);
                jsn1 = messages:getJsonPayload(response);

                var projectsCount = lengthof jsn1.projects;
                var j = 0;
                while (j < projectsCount) {

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
                    datatable dt = rmDB.select("SELECT COUNT(*) rowCount, ROW_UPDATE_EPOCH_TIME_STAMP epochTime from RM_PROJECT WHERE PROJECT_ID=?", params1);
                    var jsonRes1, err = <json>dt;
                    var rows1, err = (int)jsonRes1[0].rowCount;
                    var epochTime = 0;

                    if (jsonRes1[0].epochTime != null) {
                        var epochTime1, err = (string)jsonRes1[0].epochTime;
                        epochTime, _ = <int>epochTime1;
                    }
                    transaction {

                        if (rows1 == 0) { //if rows ==0,this record is new one.
                            logger:info("NEW RECORD INSERTED");
                            insertrows = insertrows + 1;
                            int ret1 = rmDB.update("Insert into RM_PROJECT (PROJECT_ID,PROJECT_NAME,PROJECT_IDENTIFIER,PROJECT_DESCRIPTION,PROJECT_STATUS,PROJECT_IS_PUBLIC,PROJECT_CREATED_ON,PROJECT_UPDATE_ON,ROW_UPDATE_EPOCH_TIME_STAMP) values (?,?,?,?,?,?,?,?,?)", params2);

                        } else { // else ,this record is not new one

                            if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                                logger:info("OLD RECORD UPDATED");
                                updaterows = updaterows +1;

                                int ret2 = rmDB.update("Update RM_PROJECT SET PROJECT_NAME=?, PROJECT_IDENTIFIER=?, PROJECT_DESCRIPTION=?, PROJECT_STATUS=?, PROJECT_IS_PUBLIC=?, PROJECT_CREATED_ON=?, PROJECT_UPDATE_ON=?, ROW_UPDATE_EPOCH_TIME_STAMP=? WHERE PROJECT_ID=?", params3);

                            }
                        }
                    }

                    j = j + 1;
                }

                offset = offset + limit;
                i = i + 1;


            }


            if(insertrows>0){
                logger:info(insertrows +" RECORDS ARE INSERTED... PLEASE UPDATE THE MAPPING OF PROJECT/S IN RM_MAPPING TABLE MANUALLY...");
            }else{
                logger:info(insertrows + " RECORDS ARE INSERTED");
            }
            logger:info(updaterows + " RECORDS ARE UPDATED");
            logger:info("RM_PROJECT TABLE SYNC DONE.");

        }




    }


    @http:GET {}
    @http:Path{value:"/user"}
    resource resource3 (message m) {
        m -> updateUserTable;

        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;

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

                message n = {};
                json jsn1 = {};

                response = redmineConnector.get("/users.json?offset=" + offset + "&limit=" + limit, n);
                jsn1 = messages:getJsonPayload(response);

                var usersCount = lengthof jsn1.users;

                var j = 0;
                while (j < usersCount) {



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
                    datatable dt = rmDB.select("SELECT COUNT(*) rowCount from RM_USER WHERE USER_ID=?", params1);
                    var jsonRes1, err = <json>dt;
                    var rows1, err = (int)jsonRes1[0].rowCount;

                    transaction {

                        if (rows1 == 0) { //if rows ==0,this record is new one.
                            //insert
                            logger:info("NEW RECORD INSERTED");
                            insertrows = insertrows + 1;
                            int ret1 = rmDB.update("Insert into RM_USER (USER_ID,USER_FIRST_NAME,USER_LAST_NAME,USER_EMAIL,USER_CREATED_ON,USER_LAST_LOGIN_ON) values (?,?,?,?,?,?)", params2);
                        }
                    }

                    j = j + 1;
                }

                offset = offset + limit;
                i = i + 1;


            }
            logger:info(insertrows + " RECORDS ARE INSERTED");
            logger:info("RM_USER TABLE SYNC DONE.");

        }



    }


    @http:GET {}
    @http:Path{value:"/version"}
    resource resource4 (message m) {
        m -> updateVersionTable;

        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;

        worker updateVersionTable {
            logger:info("RM_VERSION TABLE SYNC STARTED...");
            message  context;
            context <- default;
            message response = {};

            sql:Parameter[] params1 = [];
            sql:Parameter[] params2 = [];
            sql:Parameter[] params3 = [];




            datatable dt = rmDB.select("SELECT PROJECT_ID ID from RM_PROJECT", params);
            var jsonResPro, err = <json>dt;

            var projectCount = lengthof jsonResPro;


            var insertrows=0;
            var updaterows=0;
            var l = 0;

            while (l < projectCount) {



                var projectId, _ = (int)jsonResPro[l].ID;

                message checkres1 = {};
                message checkres2 = redmineConnector.get("/projects/" + projectId + "/versions.json", checkres1);
                int statusCode = http:getStatusCode(checkres2);


                if (statusCode == 200) {

                    //message response = {};
                    var offset = 0;
                    var limit = 100;
                    var cycles = getCycles("/projects/" + projectId + "/versions.json?", limit);





                    var i = 0;

                    while (i < cycles) {

                        message n = {};
                        json jsn1 = {};

                        response = redmineConnector.get("/projects/" + projectId + "/versions.json?offset=" + offset + "&limit=" + limit, n);
                        jsn1 = messages:getJsonPayload(response);

                        var versionsCount = lengthof jsn1.versions;

                        var j = 0;
                        while (j < versionsCount) {



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
                            datatable dtversion = rmDB.select("SELECT ROW_UPDATE_EPOCH_TIME_STAMP epochTime from RM_VERSION WHERE VERSION_ID=? and PARENT_PROJECT_ID=?", params1);

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
                                    int ret1 = rmDB.update("Insert into RM_VERSION (VERSION_ID,PROJECT_ID,PARENT_PROJECT_ID,VERSION_NAME,VERSION_DESCRIPTION,VERSION_STATUS,VERSION_DUE_DATE,VERSION_SHARING,VERSION_MARKETING_DESCRIPTION,VERSION_CARBON_VERSION,VERSION_DEPENDS_ON,VERSION_VISION_DOCUMENT,VERSION_START_DATE,VERSION_RELEASE_MANAGER,VERSION_WARRANTY_MANAGER,VERSION_CREATED_ON,VERSION_UPDATED_ON,ROW_UPDATE_EPOCH_TIME_STAMP)
                                values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", params2);

                                } else { // else ,this record is not new one



                                    if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                                        logger:info("OLD RECORD UPDATED");
                                        updaterows = updaterows + 1;

                                        int ret2 = rmDB.update("Update RM_VERSION SET VERSION_NAME=?,VERSION_DESCRIPTION=?, VERSION_STATUS=?,VERSION_DUE_DATE=?, VERSION_SHARING=?, VERSION_MARKETING_DESCRIPTION=?, VERSION_CARBON_VERSION=?,  VERSION_DEPENDS_ON=?,VERSION_VISION_DOCUMENT=?, VERSION_START_DATE=?, VERSION_RELEASE_MANAGER=?, VERSION_WARRANTY_MANAGER=?, VERSION_CREATED_ON=?, VERSION_UPDATED_ON=?, ROW_UPDATE_EPOCH_TIME_STAMP=? WHERE VERSION_ID=? and PARENT_PROJECT_ID=?", params3);
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
        }


    }


    @http:GET {}
    @http:Path{value:"/issue"}
    resource resource5 (message m) {
        m -> updateIssueTable;

        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;

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
            var cycles = getCycles("/issues.json?", limit);

            var insertrows=0;
            var updaterows=0;
            var i = 0;
            while (i < cycles) {

                message n = {};
                json jsn1 = {};

                response = redmineConnector.get("/issues.json?offset=" + offset + "&limit=" + limit, n);
                jsn1 = messages:getJsonPayload(response);

                var issuesCount = lengthof jsn1.issues;

                totaldataCount = totaldataCount + issuesCount;
                var j = 0;

                while (j < issuesCount) {



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
                    params3 = [para8, para11, para1];
                    //last update time on redmine
                    time:Time lastTimeUpdateStamp = time:parse(updatedOn, "yyyy-MM-dd'T'HH:mm:ssz");



                    //get the row count of the RM_PROJECT table
                    datatable dtissue = rmDB.select("SELECT ROW_UPDATE_EPOCH_TIME_STAMP epochTime from RM_ISSUE WHERE ISSUE_ID=?", params1);

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

                            int ret1 = rmDB.update("Insert into RM_ISSUE (ISSUE_ID,ISSUE_PROJECT_ID,ISSUE_PROJECT_NAME,ISSUE_TRACKER_ID,ISSUE_TRACKER_NAME,ISSUE_FIXED_VERSION_ID,ISSUE_FIXED_VERSION_NAME,ISSUE_TRACKER_SUBJECT,ISSUE_CREATED_ON,ISSUE_UPDATED_ON, ROW_UPDATE_EPOCH_TIME_STAMP)
                                values (?,?,?,?,?,?,?,?,?,?,?)", params2);

                        } else { // else ,this record is not new one



                            if (lastTimeUpdateStamp.time > epochTime) { // checking the record which is already in the table got updated or not.
                                logger:info("OLD RECORD UPDATED");
                                updaterows = updaterows + 1;

                                int ret2 = rmDB.update("Update RM_ISSUE SET ISSUE_TRACKER_SUBJECT=?, ROW_UPDATE_EPOCH_TIME_STAMP=? WHERE ISSUE_ID=?", params3);

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

        }
    }


    @http:GET {}
    @http:Path{value:"/getAllReleases"}
    resource resource6 (message m) {

        message send={};

        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];
        sql:Parameter[] params3 = [];
        sql:Parameter[] params4 = [];

        sql:Parameter para1 = {sqlType:"varchar", value:""};
        params1=[para1];
        datatable q1= rmDB.select("SELECT VERSION_DUE_DATE AS releaseDate FROM RM_VERSION where VERSION_DUE_DATE !=? and VERSION_DUE_DATE  group by VERSION_DUE_DATE asc;", params1);

        var jsonRes1, err = <json>q1;

        json dataSet1=[];
        var distinctDates=lengthof jsonRes1;
        var i=0;
        var unicId=0;
        while (i<distinctDates){
            //system:println(jsonRes1[i].releaseDate);
            json data={};

            var id=i+1;
            var date, _=(string )jsonRes1[i].releaseDate;

            sql:Parameter para2 = {sqlType:"varchar", value:date};
            params2=[para2];

            datatable q2= rmDB.select("select a.VERSION_ID,c.PROJECT_ID,c.PROJECT_NAME,c.PRODUCT_AREA,a.VERSION_NAME as releaseProduct,d.USER_FIRST_NAME as releaseManagerF,d.USER_LAST_NAME as releaseManagerL,e.USER_FIRST_NAME as warrantyManagerF,e.USER_LAST_NAME as warrantyManagerL,a.VERSION_DUE_DATE as start from RM_VERSION as a left join  RM_MAPPING as c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER as d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER as e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID
 where a.VERSION_DUE_DATE=?;", params2);
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


                datatable q3= rmDB.select("select count(*) as featureCount from RM_VERSION a left join RM_ISSUE b  ON  a.VERSION_ID = b.ISSUE_FIXED_VERSION_ID left join RM_MAPPING c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID where a.VERSION_ID=? and b.ISSUE_TRACKER_ID=?;",params3);
                var jsonFeatureCount, _= <json>q3;
                var featuresCount, _=(int)jsonFeatureCount[0].featureCount;

                datatable q4= rmDB.select("select count(*) as storyCount from RM_VERSION a left join RM_ISSUE b  ON  a.VERSION_ID = b.ISSUE_FIXED_VERSION_ID left join RM_MAPPING c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID where a.VERSION_ID=? and b.ISSUE_TRACKER_ID=?;",params4);
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





        messages:setJsonPayload(send,dataSet1);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/getProductWiseReleases/{product}"}
    resource resource7 (message m,@http:PathParam {value:"product"} string product) {

        message send={};

        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];
        sql:Parameter[] params3 = [];
        sql:Parameter[] params4 = [];

        sql:Parameter para1 = {sqlType:"varchar", value:""};
        sql:Parameter para2 = {sqlType:"varchar", value:product};
        params1=[para1,para2];
        datatable q1= rmDB.select("SELECT a.VERSION_DUE_DATE AS releaseDate FROM RM_VERSION as a left join  RM_MAPPING as c ON a.PARENT_PROJECT_ID=c.PROJECT_ID where a.VERSION_DUE_DATE !=? and c.PRODUCT_AREA=? and VERSION_DUE_DATE  group by VERSION_DUE_DATE asc;", params1);

        var jsonRes1, err = <json>q1;

        json dataSet1=[];
        var distinctDates=lengthof jsonRes1;
        var i=0;
        var unicId=0;
        while (i<distinctDates){
            //system:println(jsonRes1[i].releaseDate);
            json data={};

            var id=i+1;
            var date, _=(string )jsonRes1[i].releaseDate;

            sql:Parameter para3 = {sqlType:"varchar", value:date};
            params2=[para3,para2];

            datatable q2= rmDB.select("select a.VERSION_ID,c.PROJECT_ID,c.PROJECT_NAME,c.PRODUCT_AREA,a.VERSION_NAME as releaseProduct,d.USER_FIRST_NAME as releaseManagerF,d.USER_LAST_NAME as releaseManagerL,e.USER_FIRST_NAME as warrantyManagerF,e.USER_LAST_NAME as warrantyManagerL,a.VERSION_DUE_DATE as start from RM_VERSION as a left join  RM_MAPPING as c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER as d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER as e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID
 where a.VERSION_DUE_DATE=? and c.PRODUCT_AREA=?;", params2);
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


                datatable q3= rmDB.select("select count(*) as featureCount from RM_VERSION a left join RM_ISSUE b  ON  a.VERSION_ID = b.ISSUE_FIXED_VERSION_ID left join RM_MAPPING c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID where a.VERSION_ID=? and b.ISSUE_TRACKER_ID=? and c.PRODUCT_AREA=?;",params3);
                var jsonFeatureCount, _= <json>q3;
                var featuresCount, _=(int)jsonFeatureCount[0].featureCount;

                datatable q4= rmDB.select("select count(*) as storyCount from RM_VERSION a left join RM_ISSUE b  ON  a.VERSION_ID = b.ISSUE_FIXED_VERSION_ID left join RM_MAPPING c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID where a.VERSION_ID=? and b.ISSUE_TRACKER_ID=? and c.PRODUCT_AREA=?;",params4);
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



        messages:setJsonPayload(send,dataSet1);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/manager/{product}/{startDate}/{endDate}"}
    resource resource8 (message m, @http:PathParam {value:"product"} string product,
                        @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {

        message send={};

        json manager=[];

        sql:Parameter[] params1 = [];
        sql:Parameter[] params2 = [];

        sql:Parameter para1 = {sqlType:"varchar", value:product};
        sql:Parameter para2 = {sqlType:"varchar", value:startDate};
        sql:Parameter para3 = {sqlType:"varchar", value:endDate};

        params1 =[para2,para3];
        params2 =[para2,para3,para1];

        if (product=="all"){
            datatable q1= rmDB.select("select a.VERSION_ID,c.PROJECT_ID,c.PROJECT_NAME,c.PRODUCT_AREA,a.VERSION_NAME as releaseProduct,d.USER_FIRST_NAME as releaseManagerF,d.USER_LAST_NAME as releaseManagerL,e.USER_FIRST_NAME as warrantyManagerF,e.USER_LAST_NAME as warrantyManagerL,a.VERSION_DUE_DATE as start from RM_VERSION as a left join  RM_MAPPING as c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER as d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER as e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID
 where a.VERSION_DUE_DATE between ? and ? ORDER BY a.VERSION_DUE_DATE ASC;", params1);
            manager, _ = <json>q1;


        }else{
            datatable q2= rmDB.select("select a.VERSION_ID,c.PROJECT_ID,c.PROJECT_NAME,c.PRODUCT_AREA,a.VERSION_NAME as releaseProduct,d.USER_FIRST_NAME as releaseManagerF,d.USER_LAST_NAME as releaseManagerL,e.USER_FIRST_NAME as warrantyManagerF,e.USER_LAST_NAME as warrantyManagerL,a.VERSION_DUE_DATE as start from RM_VERSION as a left join RM_MAPPING as c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER as d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER as e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID
 where a.VERSION_DUE_DATE between ? and ? and c.PRODUCT_AREA =? ORDER BY a.VERSION_DUE_DATE ASC;", params2);
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


            datatable q3= rmDB.select("select count(*) as featureCount from RM_VERSION a left join RM_ISSUE b  ON  a.VERSION_ID = b.ISSUE_FIXED_VERSION_ID left join RM_MAPPING c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID where a.VERSION_ID=? and b.ISSUE_TRACKER_ID=?;",params3);
            var jsonFeatureCount, _= <json>q3;
            var featuresCount, _=(int)jsonFeatureCount[0].featureCount;

            datatable q4= rmDB.select("select count(*) as storyCount from RM_VERSION a left join RM_ISSUE b  ON  a.VERSION_ID = b.ISSUE_FIXED_VERSION_ID left join RM_MAPPING c ON a.PARENT_PROJECT_ID=c.PROJECT_ID left join RM_USER d ON a.VERSION_RELEASE_MANAGER=d.USER_ID left join RM_USER e ON a.VERSION_WARRANTY_MANAGER=e.USER_ID where a.VERSION_ID=? and b.ISSUE_TRACKER_ID=?;",params4);
            var jsonStoryCount, _= <json>q4;
            var storiesCount, _=(int)jsonStoryCount[0].storyCount;

            manager[j].featuresCount=featuresCount;
            manager[j].storiesCount=storiesCount;

                j=j+1;
        }



        messages:setJsonPayload(send,manager);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");


        reply send;

    }


    @http:GET {}
    @http:Path{value:"/tracker/{trackerId}/{versionId}"}
    resource resource9 (message m, @http:PathParam {value:"trackerId"} int trackerId, @http:PathParam {value:"versionId"} int versionId) {

        message send={};

        json trackerSubjects=[];


        sql:Parameter[] params1 = [];


        sql:Parameter para1 = {sqlType:"integer", value:trackerId};
        sql:Parameter para2 = {sqlType:"integer", value:versionId};


        params1 =[para1,para2];



        datatable q1= rmDB.select("select ISSUE_TRACKER_SUBJECT as subject ,ISSUE_ID as issueId FROM RM_ISSUE
        where ISSUE_TRACKER_ID=? and ISSUE_FIXED_VERSION_ID=?;", params1);

        trackerSubjects, _ = <json>q1;


        messages:setJsonPayload(send,trackerSubjects);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");


        reply send;

    }


}
