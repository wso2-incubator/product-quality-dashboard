package org.wso2.internalapps.pqd;

import ballerina.file;
import ballerina.log;
import ballerina.io;
import ballerina.data.sql;

function getConfigData(string filePath)(json){

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

function getSQLConnectorForIssuesSonarRelease()(sql:ClientConnector){
    json configData = getConfigData(CONFIG_PATH);
    var dbHost, _ = (string)configData.PQD_JDBC.DB_HOST;
    var dbPort, _ = (int)configData.PQD_JDBC.DB_PORT;
    var dbName, _ = (string)configData.PQD_JDBC.DB_NAME;
    var dbUsername, _ = (string)configData.PQD_JDBC.DB_USERNAME;
    var dbPassword, _ = (string)configData.PQD_JDBC.DB_PASSWORD;
    var maxPoolSize, _ = (int)configData.PQD_JDBC.MAXIMUM_POOL_SIZE;

    sql:ClientConnector sqlCon = create sql:ClientConnector(sql:DB.MYSQL, dbHost, dbPort, dbName,dbUsername, dbPassword, {maximumPoolSize:maxPoolSize});

    return sqlCon;
}

function filterJson(json source, string key, string value)(json){

    json returnJson = [];
    int index = 0;
    while (index < lengthof source){
        string valueString;
        valueString, _ = (string)source[index].name;
        if (valueString == value){
            returnJson[lengthof returnJson] = source[index];
        }
        index = index + 1;
    }

    return returnJson;
}


