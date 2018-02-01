package org.wso2.internalapps.pqd;



import ballerina.lang.jsons;
import ballerina.utils.logger;
import ballerina.lang.errors;
import ballerina.lang.files;
import ballerina.lang.blobs;
import ballerina.data.sql;
import ballerina.lang.datatables;





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

function getWUMDatabaseMap (json configData) (map) {

    string dbIP;
    int dbPort;
    string dbName;
    string dbUsername;
    string dbPassword;
    int poolSize;

    try {
        dbIP = jsons:getString(configData, "$.WUM_JDBC.DB_HOST");
        dbPort = jsons:getInt(configData, "$.WUM_JDBC.DB_PORT");
        dbName = jsons:getString(configData, "$.WUM_JDBC.DB_NAME");
        dbUsername = jsons:getString(configData, "$.WUM_JDBC.DB_USERNAME");
        dbPassword = jsons:getString(configData, "$.WUM_JDBC.DB_PASSWORD");
        poolSize = jsons:getInt(configData, "$.WUM_JDBC.MAXIMUM_POOL_SIZE");

    } catch (errors:Error err) {
        logger:error("Properties not defined in config.json: " + err.msg );
        dbIP = jsons:getString(configData, "$.WUM_JDBC.DB_HOST");
        dbPort = jsons:getInt(configData, "$.WUM_JDBC.DB_PORT");
        dbName = jsons:getString(configData, "$.WUM_JDBC.DB_NAME");
        dbUsername = jsons:getString(configData, "$.WUM_JDBC.DB_USERNAME");
        dbPassword = jsons:getString(configData, "$.WUM_JDBC.DB_PASSWORD");
        poolSize = jsons:getInt(configData, "$.WUM_JDBC.MAXIMUM_POOL_SIZE");

    }


    map propertiesMap={"jdbcUrl":"jdbc:mysql://"+dbIP+":"+dbPort+"/"+dbName, "username":dbUsername, "password":dbPassword, "maximumPoolSize":poolSize};

    return propertiesMap;

}
function createWUMDBConnection () (sql:ClientConnector) {

    map props = getWUMDatabaseMap(confJson);
    sql:ClientConnector rmDB = create sql:ClientConnector(props);
    return rmDB;
}

function getPqdDatabaseMap (json configData)(map) {

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
function createPqdDBConnection()(sql:ClientConnector) {

    map props = getPqdDatabaseMap(confJson);
    sql:ClientConnector rmDB = create sql:ClientConnector(props);
    return rmDB;
}

function getAllWUMReleases (int startFormat, int endFormat) (json) {


    sql:ClientConnector wumDB = createWUMDBConnection();

    sql:Parameter[] params = [];
    sql:Parameter[] params1 = [];


    sql:Parameter startTimeStamp = {sqlType:"varchar", value:startFormat};
    sql:Parameter endTimeStamp = {sqlType:"varchar", value:endFormat};

    params1=[startTimeStamp,endTimeStamp];


    datatable dtWUMReleaseDetails = wumDB.select("SELECT  update_no AS updateNo, kernel_version AS kernalVersion, platform_version AS platformVersion, date(from_unixtime(floor(timestamp/1000))) AS releaseDate, product_name AS productName, product_version AS productVersion, description AS description, applies_to AS appliesTo, bug_fixes AS bugFixesJson FROM updates where timestamp >= ?  AND timestamp <= ? order by date(from_unixtime(floor(timestamp/1000))), product_name, product_version  ;", params1);
    var wumReleaseDetailsJson, err = <json>dtWUMReleaseDetails;
    logger:info(wumReleaseDetailsJson);
    logger:debug(wumReleaseDetailsJson);
    datatables:close(dtWUMReleaseDetails);
    wumDB.close();

    sql:ClientConnector pqdDB = createPqdDBConnection();
    datatable dtProductAreas = pqdDB.select("SELECT PRODUCT_NAME AS productName, PRODUCT_AREA_NAME AS productArea, PRODUCT_AREA_COLOR AS productColor FROM  WUM_PRODUCT_TO_AREA_MAPPING;", params);
    var productAreasJson, err = <json>dtProductAreas;
    logger:info(productAreasJson);
    logger:debug(productAreasJson);
    datatables:close(dtProductAreas);
    pqdDB.close();
    var productAreasJsonCount = lengthof productAreasJson;


    json allReleases = [];

    string releaseDateMem ="";
    string productNameMem ="";
    string productVersionMem ="";


    var cardId=0;
    var labelDataArrayIndex =0;
    json labelDataArray =[];
    json data ={};
    json labelData ={};

    json details =[];
    var dataRowIndex = 0;


    var labelndex=1;

    var releasesCount=0;

    var detailsIndex=0;
    while(detailsIndex<lengthof wumReleaseDetailsJson){
        json dataRow = {};
        var releaseDate, _ = (string)wumReleaseDetailsJson[detailsIndex].releaseDate;
        var productName, _ = (string)wumReleaseDetailsJson[detailsIndex].productName;
        var productVersion, _ = (string)wumReleaseDetailsJson[detailsIndex].productVersion;

        if(releaseDateMem != releaseDate){



            if(releaseDateMem != ""){


                data.labelDataArray=labelDataArray;
                allReleases[cardId-1]=data;


            }
            releaseDateMem=releaseDate;

            cardId=cardId + 1;

            data={};
            data.id= cardId;
            data.start= releaseDateMem;

            if(productNameMem != "" && productVersionMem != ""){


                labelData.releasesCount = releasesCount;
                labelData.details = details;
                labelDataArray[labelDataArrayIndex]=labelData;
                labelDataArrayIndex = labelDataArrayIndex +1;
            }

            productNameMem ="";
            productVersionMem="";

            labelDataArray =[];
            labelDataArrayIndex=0;



        }




        if(productNameMem != productName || productVersionMem != productVersion){

            if(productNameMem != "" && productVersionMem != ""){


                labelData.releasesCount = releasesCount;
                labelData.details = details;
                labelDataArray[labelDataArrayIndex]=labelData;
                labelDataArrayIndex = labelDataArrayIndex +1;
            }

            releasesCount=1;

            labelData={};
            labelData.id = labelndex;
            labelData.releaseDate = releaseDateMem;
            labelData.productName = productName;
            labelData.productVersion = productVersion;

            var productAreaIndex=0;
            while(productAreaIndex<productAreasJsonCount){
                var productArea_m, _ = (string)productAreasJson[productAreaIndex].productArea;
                var productName_m, _ = (string)productAreasJson[productAreaIndex].productName;
                var productColor_m, _ = (string)productAreasJson[productAreaIndex].productColor;

                if(productName==productName_m){
                    labelData.productArea = productArea_m;
                    labelData.productColor = productColor_m;
                }

                productAreaIndex = productAreaIndex + 1;
            }

            details =[];
            dataRowIndex=0;


            productNameMem = productName;
            productVersionMem = productVersion;

            labelndex = labelndex +1;

        }else{
            releasesCount =releasesCount+1;
        }

        dataRow.id=dataRowIndex +1;
        dataRow.releaseDate=releaseDate;
        dataRow.productName=productName;
        dataRow.productVersion=productVersion;
        dataRow.kernalVersion=wumReleaseDetailsJson[detailsIndex].kernalVersion;
        dataRow.platformVersion=wumReleaseDetailsJson[detailsIndex].platformVersion;
        dataRow.appliesTo=wumReleaseDetailsJson[detailsIndex].appliesTo;
        dataRow.description=wumReleaseDetailsJson[detailsIndex].description;

        var bugFixesString, _=(string )wumReleaseDetailsJson[detailsIndex].bugFixesJson;
        var bugFixesJson=jsons:parse(bugFixesString);

        var key ="-";
        var url ="-";
        var desc ="-";

        if(lengthof bugFixesJson > 0){

            key, _ = (string)bugFixesJson[0].key;
            url, _ = (string)bugFixesJson[0].url;
            desc, _ = (string)bugFixesJson[0].desc;
        }

        dataRow.bugKey = key;
        dataRow.bugUrl = url;
        dataRow.bugDescription = desc;

        details[dataRowIndex]=dataRow;


        dataRowIndex = dataRowIndex +1;





        detailsIndex = detailsIndex +1;
        if(detailsIndex== lengthof wumReleaseDetailsJson){
            if(productNameMem != "" && productVersionMem != ""){


                labelData.releasesCount = releasesCount;
                labelData.details = details;
                labelDataArray[labelDataArrayIndex]=labelData;
                labelDataArrayIndex = labelDataArrayIndex +1;
            }

            data.labelDataArray=labelDataArray;
            allReleases[cardId-1]=data;

        }



    }


    logger:info(allReleases);
    return allReleases;
}
function getWUMReleasesByProductArea (string productArea, int startFormat, int endFormat) (json) {

    sql:Parameter[] params3 = [];
    sql:ClientConnector pqdDB = createPqdDBConnection();

    sql:Parameter productAreaName = {sqlType:"varchar", value:productArea};
    params3=[productAreaName];
    datatable dtProductNames = pqdDB.select("SELECT PRODUCT_NAME AS productName, PRODUCT_AREA_COLOR AS productColor FROM  WUM_PRODUCT_TO_AREA_MAPPING Where PRODUCT_AREA_NAME=? ;", params3);
    var productNamesJson, err = <json>dtProductNames;
    logger:debug(productNamesJson);
    datatables:close(dtProductNames);


    logger:info(productNamesJson);

    pqdDB.close();


    string productArray = "\'";


    var productLength =lengthof productNamesJson;
    var productIndex = 0;
    while (productIndex<productLength ){
        var currentProduct, _=(string )productNamesJson[productIndex].productName;
        if(productIndex != (productLength -1)){
            productArray = productArray + currentProduct + "\',\'";
        }else{
            productArray = productArray + currentProduct + "\'";
        }

        productIndex = productIndex +1;
    }


    var productColor, _=(string )productNamesJson[0].productColor;

    logger:info(productArray);


    sql:ClientConnector wumDB = createWUMDBConnection();


    sql:Parameter[] params1 = [];

    sql:Parameter startTimeStamp = {sqlType:"varchar", value:startFormat};
    sql:Parameter endTimeStamp = {sqlType:"varchar", value:endFormat};

    params1=[startTimeStamp,endTimeStamp];

    datatable dtWUMReleaseDetails = wumDB.select("SELECT  update_no AS updateNo, kernel_version AS kernalVersion, platform_version AS platformVersion, date(from_unixtime(floor(timestamp/1000))) AS releaseDate, product_name AS productName, product_version AS productVersion, description AS description, applies_to AS appliesTo, bug_fixes AS bugFixesJson FROM updates where product_name in ("+ productArray +") AND timestamp >= ?  AND timestamp <= ? order by date(from_unixtime(floor(timestamp/1000))), product_name, product_version  ;", params1);
    var wumReleaseDetailsJson, err = <json>dtWUMReleaseDetails;
    logger:info(wumReleaseDetailsJson);
    logger:debug(wumReleaseDetailsJson);
    datatables:close(dtWUMReleaseDetails);

    wumDB.close();

    json allReleases = [];

    string releaseDateMem ="";
    string productNameMem ="";
    string productVersionMem ="";


    var cardId=0;
    var labelDataArrayIndex =0;
    json labelDataArray =[];
    json data ={};
    json labelData ={};

    json details =[];
    var dataRowIndex = 0;


    var labelndex=1;

    var releasesCount=0;

    var detailsIndex=0;
    while(detailsIndex<lengthof wumReleaseDetailsJson){
        json dataRow = {};
        var releaseDate, _ = (string)wumReleaseDetailsJson[detailsIndex].releaseDate;
        var productName, _ = (string)wumReleaseDetailsJson[detailsIndex].productName;
        var productVersion, _ = (string)wumReleaseDetailsJson[detailsIndex].productVersion;

        if(releaseDateMem != releaseDate){



            if(releaseDateMem != ""){


                data.labelDataArray=labelDataArray;
                allReleases[cardId-1]=data;


            }
            releaseDateMem=releaseDate;

            cardId=cardId + 1;

            data={};
            data.id= cardId;
            data.start= releaseDateMem;

            if(productNameMem != "" && productVersionMem != ""){


                labelData.releasesCount = releasesCount;
                labelData.details = details;
                labelDataArray[labelDataArrayIndex]=labelData;
                labelDataArrayIndex = labelDataArrayIndex +1;
            }

            productNameMem ="";
            productVersionMem="";

            labelDataArray =[];
            labelDataArrayIndex=0;



        }




        if(productNameMem != productName || productVersionMem != productVersion){

            if(productNameMem != "" && productVersionMem != ""){


                labelData.releasesCount = releasesCount;
                labelData.details = details;
                labelDataArray[labelDataArrayIndex]=labelData;
                labelDataArrayIndex = labelDataArrayIndex +1;
            }

            releasesCount=1;

            labelData={};
            labelData.id = labelndex;
            labelData.releaseDate = releaseDateMem;
            labelData.productName = productName;
            labelData.productVersion = productVersion;
            labelData.productArea = productArea;
            labelData.productColor = productColor;


            details =[];
            dataRowIndex=0;


            productNameMem = productName;
            productVersionMem = productVersion;

            labelndex = labelndex +1;

        }else{
            releasesCount =releasesCount+1;
        }

        dataRow.id=dataRowIndex +1;

        dataRow.releaseDate=releaseDate;
        dataRow.productName=productName;
        dataRow.productVersion=productVersion;
        dataRow.kernalVersion=wumReleaseDetailsJson[detailsIndex].kernalVersion;
        dataRow.platformVersion=wumReleaseDetailsJson[detailsIndex].platformVersion;
        dataRow.appliesTo=wumReleaseDetailsJson[detailsIndex].appliesTo;
        dataRow.description=wumReleaseDetailsJson[detailsIndex].description;

        var bugFixesString, _=(string )wumReleaseDetailsJson[detailsIndex].bugFixesJson;
        var bugFixesJson=jsons:parse(bugFixesString);

        var key ="-";
        var url ="-";
        var desc ="-";

        if(lengthof bugFixesJson > 0){

            key, _ = (string)bugFixesJson[0].key;
            url, _ = (string)bugFixesJson[0].url;
            desc, _ = (string)bugFixesJson[0].desc;
        }

        dataRow.bugKey = key;
        dataRow.bugUrl = url;
        dataRow.bugDescription = desc;

        details[dataRowIndex]=dataRow;


        dataRowIndex = dataRowIndex +1;





        detailsIndex = detailsIndex +1;
        if(detailsIndex== lengthof wumReleaseDetailsJson){
            if(productNameMem != "" && productVersionMem != ""){

                labelData.releasesCount = releasesCount;
                labelData.details = details;
                labelDataArray[labelDataArrayIndex]=labelData;
                labelDataArrayIndex = labelDataArrayIndex +1;
            }

            data.labelDataArray=labelDataArray;
            allReleases[cardId-1]=data;

        }



    }
    logger:info(allReleases);
    return allReleases;
}




