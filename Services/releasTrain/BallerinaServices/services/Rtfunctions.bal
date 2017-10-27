package org.wso2.internalapps.pqd;


import ballerina.lang.messages;
import org.wso2.ballerina.connectors.basicauth;
import ballerina.lang.jsons;
import ballerina.utils.logger;
import ballerina.lang.errors;
import ballerina.lang.files;
import ballerina.lang.blobs;

basicauth:ClientConnector redmineConnector = null;

function redmineConnectivity(){
    json configData = readConfig("config.json");

    string rmUsername;
    string rmPassword;
    string rmUrl;

    rmUsername = jsons:getString(configData, "$.REDMINE.RM_USERNAME");
    rmPassword = jsons:getString(configData, "$.REDMINE.RM_PASSWORD");
    rmUrl = jsons:getString(configData, "$.REDMINE.RM_URL");

    redmineConnector = create basicauth:ClientConnector(rmUrl,rmUsername,rmPassword);

}

function getCycles(string path, int limit)(int){

    json configData = readConfig("config.json");

    string rmUsername;
    string rmPassword;
    string rmUrl;

    rmUsername = jsons:getString(configData, "$.REDMINE.RM_USERNAME");
    rmPassword = jsons:getString(configData, "$.REDMINE.RM_PASSWORD");
    rmUrl = jsons:getString(configData, "$.REDMINE.RM_URL");


    basicauth:ClientConnector redmineConnector = create basicauth:ClientConnector(rmUrl,rmUsername,rmPassword);

    message msg1={};
    message res1={};
    res1 = redmineConnector.get(path, msg1);
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

function readConfig(string filePath)(json){

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

function setDatabaseConfig(json configData)(map){

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






