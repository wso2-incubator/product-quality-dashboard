package org.wso2.internalapps.pqd;

import ballerina.lang.jsons;
import ballerina.utils.logger;
import ballerina.lang.errors;
import ballerina.lang.files;
import ballerina.lang.blobs;
import ballerina.lang.system;


import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.lang.time;
import ballerina.lang.strings;


http:ClientConnector sfConn = null;

json SFconfJson = getSFConfData("config.json");
function getSFConfData (string filePath) (json) {

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



json mappingConfJson = getAreaMappinConfData("mapping.json");
function getAreaMappinConfData (string filePath) (json) {

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

function getProductOppAreaKeys () (json) {
    json products= {};
    json keys = [];
    products = jsons:getJson(mappingConfJson, "$.OPP");
    var x  = jsons:getKeys(products);


    int i = 0;
    while(i< lengthof x ){
        keys[i]=x[i];
        i=i+1;
    }

    return keys;
}
function getProductAccAreaKeys () (json) {
    json products= {};
    json keys = [];
    products = jsons:getJson(mappingConfJson, "$.ACC");
    var x  = jsons:getKeys(products);


    int i = 0;
    while(i< lengthof x ){
        keys[i]=x[i];
        i=i+1;
    }

    return keys;
}
function getProductOppLineItemAreaKeys () (json) {
    json products= {};
    json keys = [];
    products = jsons:getJson(mappingConfJson, "$.OPPLINEITEM");
    var x  = jsons:getKeys(products);


    int i = 0;
    while(i< lengthof x ){
        keys[i]=x[i];
        i=i+1;
    }

    return keys;
}


function createSFConnection(){
    string sfUrl;
    sfUrl = jsons:getString(SFconfJson, "$.SF.SF_URL");
    sfConn = create http:ClientConnector(sfUrl);
}
function getSFRequest()(message){
    string sfApiKey;
    try{
        sfApiKey, _= (string)SFconfJson.SF.SF_API_KEY;
    }catch(errors:Error err){
        logger:error("Properties not defined in config.json: " + err.msg );
        sfApiKey, _= (string)SFconfJson.SF.SF_API_KEY;
    }

    message req = {};
    messages:setHeader(req,"Authorization",sfApiKey);

    return req;
}




function getAllActiveCustomers()(json){

    if (sfConn == null) {
        createSFConnection();
    }

    time:Time t = time:currentTime();
    string currentDate = time:format(t,"YYYY-MM-dd");
    logger:info(currentDate);

    message request = {};
    message response = {};
    json projectJson = {};

    request = getSFRequest();


    response = sfConn.get("/getAccountAndOpportunityAndOppLineItemDetails?accountStatus=Customer&PSSupportAccountEndDateRollUpDate="+currentDate+"&PSSupportAccountEndDateRollUpDateOperator=gt&orderByCustomerId=true&orderByOpportunityId=true",request);
    projectJson = messages:getJsonPayload(response);

    json result= [];
    json nameAndArrJson= [];

    int accountIndex =0;
    while(accountIndex< lengthof projectJson ){

        json jsonObject = {};
        var totalArr = 0;

        if(projectJson[accountIndex].Opportunities != null){


            int opportunityIndex = 0;
            while(opportunityIndex< lengthof projectJson[accountIndex].Opportunities){

                if(projectJson[accountIndex].Opportunities[opportunityIndex].OpportunityLineItems != null){








                    var arrString, _ =(string)projectJson[accountIndex].Opportunities[opportunityIndex].ARR_Opportunity__c;
                    var arrArray = strings:split(arrString,"\\.");
                    var arr, _ = <int>arrArray[0];


                    totalArr = totalArr + arr;


                }


                opportunityIndex = opportunityIndex +1;
            }

        }
        jsonObject.Name=projectJson[accountIndex].Name;
        jsonObject.Arr= totalArr;

        nameAndArrJson[accountIndex]=jsonObject;
        accountIndex = accountIndex + 1;
    }

    result[0]=nameAndArrJson;
    result[1]=lengthof projectJson;
    return result;
}
function getActiveCustomers(string customerProductArea)(json){

    if (sfConn == null) {
        createSFConnection();
    }

    time:Time t = time:currentTime();
    string currentDate = time:format(t,"YYYY-MM-dd");
    logger:info(currentDate);

    message request = {};
    message response = {};
    json projectJson = {};

    request = getSFRequest();


    response = sfConn.get("/getAccountAndOpportunityAndOppLineItemDetails?productUnit="+customerProductArea+"&accountStatus=Customer&PSSupportAccountEndDateRollUpDate="+currentDate+"&PSSupportAccountEndDateRollUpDateOperator=gt&orderByCustomerId=true&orderByOpportunityId=true",request);
    projectJson = messages:getJsonPayload(response);


    json result= [];
    json nameAndArrJson= [];

    int accountIndex =0;
    while(accountIndex< lengthof projectJson ){
        if(projectJson[accountIndex].Opportunities != null){


            json jsonObject = {};
            var productArr = 0;


            int opportunityIndex = 0;
            while(opportunityIndex< lengthof projectJson[accountIndex].Opportunities){

                if(projectJson[accountIndex].Opportunities[opportunityIndex].OpportunityLineItems != null){


                    var productCount = 0;




                    if( lengthof projectJson[accountIndex].Opportunities[opportunityIndex].OpportunityLineItems > 0){
                        productCount = 1;
                    }



                    var arrString, _ =(string)projectJson[accountIndex].Opportunities[opportunityIndex].ARR_Opportunity__c;
                    var arrArray = strings:split(arrString,"\\.");
                    var arr, _ = <int>arrArray[0];


                    productArr = productArr + (arr * productCount);





                }


                opportunityIndex = opportunityIndex +1;
            }

            jsonObject.Name = projectJson[accountIndex].Name;
            jsonObject.Arr = productArr;
            jsonObject.Area = customerProductArea;

            nameAndArrJson[accountIndex] = jsonObject;

        }

        accountIndex = accountIndex + 1;
    }

    result[0]=nameAndArrJson;
    result[1]=lengthof projectJson;
    return result;
}

function getNewLogosByMonthAndArea(string area,string year1,string year2)(json){

    if (sfConn == null) {
        createSFConnection();
    }

    json send=[];
    json newLogosYear1 = [{m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}];
    json newLogosYear2 = [{m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}];

    message request1 = {};
    message request2 = {};
    message response1 = {};
    message response2 = {};
    json projectJson1 = {};
    json projectJson2 = {};

    request1 = getSFRequest();
    request2 = getSFRequest();




    json  payload1 = {};
    json  payload2 = {};

    if(area == "overall"){


        payload1 = {"entryVector":"null","newLogosByYear":year1,"orderByActivationDate":"ASC" };
        payload2 = {"entryVector":"null","newLogosByYear":year2,"orderByActivationDate":"ASC" };
        messages:setJsonPayload(request1,payload1);
        messages:setJsonPayload(request2,payload2);

        logger:info(area);
        logger:info(payload1);
        logger:info(payload2);


        response1 = sfConn.post("/getAccountDetails",request1);
        response2 = sfConn.post("/getAccountDetails",request2);

        projectJson1 = messages:getJsonPayload(response1);
        projectJson2 = messages:getJsonPayload(response2);



    }else{


        json products= {};
        products = jsons:getJson(mappingConfJson, "$.ACC");

        var productString, _ = (string)products[area];
        var product = "'"+productString+"'";

        System.out.println(product);

        payload1 = {"entryVector":product,"newLogosByYear":year1,"orderByActivationDate":"ASC" };
        payload2 = {"entryVector":product,"newLogosByYear":year2,"orderByActivationDate":"ASC" };
        messages:setJsonPayload(request1,payload1);
        messages:setJsonPayload(request2,payload2);


        response1 = sfConn.post("/getAccountDetails",request1);
        response2 = sfConn.post("/getAccountDetails",request2);

        projectJson1 = messages:getJsonPayload(response1);
        projectJson2 = messages:getJsonPayload(response2);

    }

    projectJson1 = messages:getJsonPayload(response1);
    projectJson2 = messages:getJsonPayload(response2);

    int i=0;
    var memMonth=0;
    var count = 0;
    while(i<lengthof projectJson1){

        var date, _ = (string)projectJson1[i].Activation_Date__c;
        string monthString = strings:subString(date,5,7);
        var month, _ = <int>monthString;

        if(memMonth == 0) {
            count = 1;
        }else if(memMonth != month && memMonth != 0){
            newLogosYear1[memMonth-1].m=count;
            count = 1;
        }else{
            count = count +1;
        }


        memMonth = month;




        i=i+1;
        if(i==lengthof projectJson1){
            newLogosYear1[memMonth-1].m=count;
            count=0;
            memMonth=0;
        }
    }


    int j=0;
    while(j<lengthof projectJson2){

        var date, _ = (string)projectJson2[j].Activation_Date__c;
        string monthString = strings:subString(date,5,7);
        var month, _ = <int>monthString;

        if(memMonth == 0) {
            count = 1;
        }else if(memMonth != month && memMonth != 0){
            newLogosYear2[memMonth-1].m=count;
            count = 1;
        }else{
            count = count +1;
        }


        memMonth = month;




        j=j+1;
        if(j==lengthof projectJson2){
            newLogosYear2[memMonth-1].m=count;
        }
    }
    logger:info(newLogosYear1);
    logger:info(newLogosYear2);
    logger:info(projectJson1);
    logger:info(projectJson2);

    send[0]=newLogosYear1;
    send[1]=newLogosYear2;

    return send;
}
function getNewLogosByQuarterAndArea(string area,string year1,string year2)(json){


    if (sfConn == null) {
        createSFConnection();
    }


    json send=[];
    json newLogosYear1 = [{q:0}, {q:0}, {q:0}, {q:0}];
    json newLogosYear2 = [{q:0}, {q:0}, {q:0}, {q:0}];





    message request1 = {};
    message request2 = {};
    message response1 = {};
    message response2 = {};
    json projectJson1 = {};
    json projectJson2 = {};

    request1 = getSFRequest();
    request2 = getSFRequest();

    logger:info(area);
    logger:info(year1);
    logger:info(year2);



    json  payload1 = {};
    json  payload2 = {};
    if(area == "overall"){


        payload1 = {"entryVector":"null","newLogosByYear":year1,"orderByActivationDate":"ASC" };
        payload2 = {"entryVector":"null","newLogosByYear":year2,"orderByActivationDate":"ASC" };
        messages:setJsonPayload(request1,payload1);
        messages:setJsonPayload(request2,payload2);

        logger:info(area);
        logger:info(payload1);
        logger:info(payload2);


        response1 = sfConn.post("/getAccountDetails",request1);
        response2 = sfConn.post("/getAccountDetails",request2);

        projectJson1 = messages:getJsonPayload(response1);
        projectJson2 = messages:getJsonPayload(response2);


    }else{

        json products= {};
        products = jsons:getJson(mappingConfJson, "$.ACC");

        var productString, _ = (string)products[area];
        var product = "'"+productString+"'";

        System.out.println(product);


        payload1 = {"entryVector":product,"newLogosByYear":year1,"orderByActivationDate":"ASC" };
        payload2 = {"entryVector":product,"newLogosByYear":year2,"orderByActivationDate":"ASC" };
        messages:setJsonPayload(request1,payload1);
        messages:setJsonPayload(request2,payload2);


        response1 = sfConn.post("/getAccountDetails",request1);
        response2 = sfConn.post("/getAccountDetails",request2);

        projectJson1 = messages:getJsonPayload(response1);
        projectJson2 = messages:getJsonPayload(response2);

    }




    int i=0;
    var memQuarter=0;
    var count = 0;
    while(i<lengthof projectJson1){

        var date, _ = (string)projectJson1[i].Activation_Date__c;
        string monthString = strings:subString(date,5,7);
        var month, _ = <int>monthString;

        var quarter=0;

        if (month <= 3) {
            quarter = 1;
        } else if (month <= 6) {
            quarter = 2;
        } else if (month <= 9) {
            quarter = 3;
        } else {
            quarter = 4;
        }

        if(memQuarter == 0) {
            count = 1;
        }else if(memQuarter != quarter && memQuarter != 0){
            newLogosYear1[memQuarter-1].q=count;
            count = 1;
        }else{
            count = count +1;
        }


        memQuarter = quarter;




        i=i+1;
        if(i==lengthof projectJson1){
            newLogosYear1[memQuarter-1].q=count;
            count=0;
            memQuarter=0;
        }
    }


    int j=0;
    while(j<lengthof projectJson2){

        var date, _ = (string)projectJson2[j].Activation_Date__c;
        string monthString = strings:subString(date,5,7);
        var month, _ = <int>monthString;

        var quarter=0;
        if (month <= 3) {
            quarter = 1;
        } else if (month <= 6) {
            quarter = 2;
        } else if (month <= 9) {
            quarter = 3;
        } else {
            quarter = 4;
        }


        if(memQuarter == 0) {
            count = 1;
        }else if(memQuarter != quarter && memQuarter != 0){
            newLogosYear2[memQuarter-1].q=count;
            count = 1;
        }else{
            count = count +1;
        }


        memQuarter = quarter;




        j=j+1;
        if(j==lengthof projectJson2){
            newLogosYear2[memQuarter-1].q=count;
            count=0;
            memQuarter=0;
        }
    }
    logger:info(newLogosYear1);
    logger:info(newLogosYear2);
    logger:info(projectJson1);
    logger:info(projectJson2);

    send[0]=newLogosYear1;
    send[1]=newLogosYear2;

    return send;
}
function getNewLogosByYearAndArea(string area,string year1,string year2)(json){

    if (sfConn == null) {
        createSFConnection();
    }

    json send=[];
    message request1 = {};
    message request2 = {};
    message response1 = {};
    message response2 = {};
    json projectJson1 = {};
    json projectJson2 = {};

    request1 = getSFRequest();
    request2 = getSFRequest();
    json json1=[{"y":0}];
    json json2=[{"y":0}];




    json  payload1 = {};
    json  payload2 = {};

    if(area == "overall"){



        payload1 = {"entryVector":"null","newLogosByYear":year1,"orderByActivationDate":"ASC" };
        payload2 = {"entryVector":"null","newLogosByYear":year2,"orderByActivationDate":"ASC" };
        messages:setJsonPayload(request1,payload1);
        messages:setJsonPayload(request2,payload2);

        logger:info(area);
        logger:info(payload1);
        logger:info(payload2);


        response1 = sfConn.post("/getAccountDetails",request1);
        response2 = sfConn.post("/getAccountDetails",request2);

        projectJson1 = messages:getJsonPayload(response1);
        projectJson2 = messages:getJsonPayload(response2);
    }else{
        //response1 = sfConn.get("/getAccountDetails?entryVector="+area+"&newLogosByYear="+year1+"&orderByActivationDate=ASC", request);
        //response2 = sfConn.get("/getAccountDetails?entryVector="+area+"&newLogosByYear="+year2+"&orderByActivationDate=ASC", request);
        json products= {};
        products = jsons:getJson(mappingConfJson, "$.ACC");

        var productString, _ = (string)products[area];
        var product = "'"+productString+"'";

        System.out.println(product);



        payload1 = {"entryVector":product,"newLogosByYear":year1,"orderByActivationDate":"ASC" };
        payload2 = {"entryVector":product,"newLogosByYear":year2,"orderByActivationDate":"ASC" };
        messages:setJsonPayload(request1,payload1);
        messages:setJsonPayload(request2,payload2);


        response1 = sfConn.post("/getAccountDetails",request1);
        response2 = sfConn.post("/getAccountDetails",request2);

        projectJson1 = messages:getJsonPayload(response1);
        projectJson2 = messages:getJsonPayload(response2);
    }
    //projectJson1 = messages:getJsonPayload(response1);
    //projectJson2 = messages:getJsonPayload(response2);
    logger:info("year1: " + lengthof projectJson1);
    logger:info("year2: " + lengthof projectJson2);

    json1[0].y=lengthof projectJson1;
    json2[0].y=lengthof projectJson2;

    send[0]=json1;
    send[1]=json2;
    return send;
}

function getWonsAndLostsByMonthAndArea (string area, string year)(json){

    json products= {};
    products = jsons:getJson(mappingConfJson, "$.OPP");

    var productString, _ = (string)products[area];
    var product = "'"+productString+"'";

    system:println(product);


    if (sfConn == null) {
        createSFConnection();
    }

    json send=[];
    json won = [{m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}];
    json lost = [{m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}, {m:0}];

    message request1 = {};
    message request2 = {};
    message response1 = {};
    message response2 = {};
    json projectJson1 = {};
    json projectJson2 = {};

    request1 = getSFRequest();
    request2 = getSFRequest();


    json  payload1 = {"entryVector":product,"isClosed":"true","isWon":"true","closeDateYear":year,"orderByClosedDate":"ASC","orderByEntryVector":"null" };
    json  payload2 = {"entryVector":product,"isClosed":"true","isWon":"false","closeDateYear":year,"orderByClosedDate":"ASC","orderByEntryVector":"null"};
    messages:setJsonPayload(request1,payload1);
    messages:setJsonPayload(request2,payload2);
    response1 = sfConn.post("/getOpportunityDetails",request1);
    response2 = sfConn.post("/getOpportunityDetails",request2);
    projectJson1 = messages:getJsonPayload(response1);
    projectJson2 = messages:getJsonPayload(response2);


    //response1 = sfConn.get("/getOpportunityDetails?entryVector="+product+"&isClosed=true&isWon=true&closeDateYear="+year+"&orderByClosedDate=ASC", request);
    //response2 = sfConn.get("/getOpportunityDetails?entryVector="+product+"&isClosed=true&isWon=false&closeDateYear="+year+"&orderByClosedDate=ASC", request);
    //projectJson1 = messages:getJsonPayload(response1);
    //projectJson2 = messages:getJsonPayload(response2);


    int i=0;
    var memMonth=0;
    var count = 0;
    while(i<lengthof projectJson1){

        var date, _ = (string)projectJson1[i].CloseDate;
        string monthString = strings:subString(date,5,7);
        var month, _ = <int>monthString;

        if(memMonth == 0) {
            count = 1;
        }else if(memMonth != month && memMonth != 0){
            won[memMonth - 1].m = count;
            count = 1;
        }else{
            count = count +1;
        }


        memMonth = month;




        i=i+1;
        if(i==lengthof projectJson1){
            won[memMonth - 1].m = count;
            count=0;
            memMonth=0;
        }
    }


    int j=0;
    while(j<lengthof projectJson2){

        var date, _ = (string)projectJson2[j].CloseDate;
        string monthString = strings:subString(date,5,7);
        var month, _ = <int>monthString;

        if(memMonth == 0) {
            count = 1;
        }else if(memMonth != month && memMonth != 0){
            lost[memMonth - 1].m = count;
            count = 1;
        }else{
            count = count +1;
        }


        memMonth = month;




        j=j+1;
        if(i==lengthof projectJson1){
            lost[memMonth - 1].m = count;
        }
    }
    logger:info(won);
    logger:info(lost);
    logger:info(projectJson1);
    logger:info(projectJson2);

    send[0]= won;
    send[1]= lost;

    return send;
}
function getWonsAndLostsByQuarterAndArea (string area, string year)(json){
    json products= {};
    products = jsons:getJson(mappingConfJson, "$.OPP");

    var productString, _ = (string)products[area];
    var product = "'"+productString+"'";



    if (sfConn == null) {
        createSFConnection();
    }

    json send=[];
    json won = [{q:0}, {q:0}, {q:0}, {q:0}];
    json lost = [{q:0}, {q:0}, {q:0}, {q:0}];

    message request1 = {};
    message request2 = {};
    message response1 = {};
    message response2 = {};
    json projectJson1 = {};
    json projectJson2 = {};

    request1 = getSFRequest();
    request2 = getSFRequest();

    //response1 = sfConn.get("/getOpportunityDetails?entryVector='API Management (true OAuth)'&isClosed=true&isWon=true&closeDateYear="+year+"&orderByClosedDate=ASC", request);
    //response2 = sfConn.get("/getOpportunityDetails?entryVector='API Management (true OAuth)'&isClosed=true&isWon=false&closeDateYear="+year+"&orderByClosedDate=ASC", request);

    json  payload1 = {"entryVector":product,"isClosed":"true","isWon":"true","closeDateYear":year,"orderByClosedDate":"ASC","orderByEntryVector":"null" };
    json  payload2 = {"entryVector":product,"isClosed":"true","isWon":"false","closeDateYear":year,"orderByClosedDate":"ASC","orderByEntryVector":"null"};
    messages:setJsonPayload(request1,payload1);
    messages:setJsonPayload(request2,payload2);
    response1 = sfConn.post("/getOpportunityDetails",request1);
    response2 = sfConn.post("/getOpportunityDetails",request2);
    //response1 = sfConn.post("/getOpportunityDetails?isClosed=true&isWon=true&closeDateYear="+year+"&orderByClosedDate=ASC", request);
    //response2 = sfConn.post("/getOpportunityDetails?isClosed=true&isWon=false&closeDateYear="+year+"&orderByClosedDate=ASC", request);




    projectJson1 = messages:getJsonPayload(response1);
    projectJson2 = messages:getJsonPayload(response2);

    int i=0;
    var memQuarter=0;
    var count = 0;
    while(i<lengthof projectJson1){

        var date, _ = (string)projectJson1[i].CloseDate;
        string monthString = strings:subString(date,5,7);
        var month, _ = <int>monthString;

        var quarter=0;

        if (month <= 3) {
            quarter = 1;
        } else if (month <= 6) {
            quarter = 2;
        } else if (month <= 9) {
            quarter = 3;
        } else {
            quarter = 4;
        }

        if(memQuarter == 0) {
            count = 1;
        }else if(memQuarter != quarter && memQuarter != 0){
            won[memQuarter - 1].q = count;
            count = 1;
        }else{
            count = count +1;
        }


        memQuarter = quarter;




        i=i+1;
        if(i==lengthof projectJson1){
            won[memQuarter - 1].q = count;
            count=0;
            memQuarter=0;
        }
    }


    int j=0;
    while(j<lengthof projectJson2){

        var date, _ = (string)projectJson2[j].CloseDate;
        string monthString = strings:subString(date,5,7);
        var month, _ = <int>monthString;

        var quarter=0;
        if (month <= 3) {
            quarter = 1;
        } else if (month <= 6) {
            quarter = 2;
        } else if (month <= 9) {
            quarter = 3;
        } else {
            quarter = 4;
        }


        if(memQuarter == 0) {
            count = 1;
        }else if(memQuarter != quarter && memQuarter != 0){
            lost[memQuarter - 1].q = count;
            count = 1;
        }else{
            count = count +1;
        }


        memQuarter = quarter;




        j=j+1;
        if(j==lengthof projectJson2){
            lost[memQuarter - 1].q = count;
            count=0;
            memQuarter=0;
        }
    }
    logger:info(won);
    logger:info(lost);
    logger:info(projectJson1);
    logger:info(projectJson2);

    send[0]= won;
    send[1]= lost;

    return send;
}
function getWonsAndLostsByYearAndArea (string area)(json){

    json products= {};
    products = jsons:getJson(mappingConfJson, "$.OPP");

    var productString, _ = (string)products[area];
    var product = "'"+productString+"'";

    if (sfConn == null) {
        createSFConnection();
    }

    json send=[];

    var startyear=0;
    var endyear=0;

    json wons = {won:[]};
    json losts = {lost:[]};
    json years = {year:[]};

    json wonsJson = [];
    json lostsJson = [];

    message request1 = {};
    message request2 = {};
    message response1 = {};
    message response2 = {};
    json projectJson1 = {};
    json projectJson2 = {};

    request1 = getSFRequest();
    request2 = getSFRequest();

    json  payload1 = {"entryVector":product,"isClosed":"true","isWon":"true","closeDateYear":"null","orderByClosedDate":"ASC","orderByEntryVector":"null" };
    json  payload2 = {"entryVector":product,"isClosed":"true","isWon":"false","closeDateYear":"null","orderByClosedDate":"ASC","orderByEntryVector":"null"};
    messages:setJsonPayload(request1,payload1);
    messages:setJsonPayload(request2,payload2);
    response1 = sfConn.post("/getOpportunityDetails",request1);
    response2 = sfConn.post("/getOpportunityDetails",request2);

    projectJson1 = messages:getJsonPayload(response1);
    projectJson2 = messages:getJsonPayload(response2);

    //response1 = sfConn.get("/getOpportunityDetails?entryVector="+area+"&isClosed=true&isWon=true&orderByClosedDate=ASC", request);
    //response2 = sfConn.get("/getOpportunityDetails?entryVector="+area+"&isClosed=true&isWon=false&orderByClosedDate=ASC", request);
    //projectJson1 = messages:getJsonPayload(response1);
    //projectJson2 = messages:getJsonPayload(response2);


    int wonYearMem=0;
    var wonCount = 0;
    int wonIndex=0;
    int i=0;
    while(i<lengthof projectJson1){
        json won={year:0,Number_of_Opportunities:0};
        var date, _ = (string)projectJson1[i].CloseDate;
        string yearString = strings:subString(date,0,4);
        var year, _ = <int>yearString;


        if(wonYearMem == 0) {
            wonCount = 1;
        }else if(wonYearMem != year && wonYearMem != 0){

            won.year=wonYearMem;
            won.Number_of_Opportunities=wonCount;
            wonsJson[wonIndex]=won;
            wonIndex =wonIndex+1;
            wonCount = 1;
        }else{
            wonCount = wonCount +1;
        }

        wonYearMem = year;
        i=i+1;
        if(i==lengthof projectJson1){
            won.year=wonYearMem;
            won.Number_of_Opportunities=wonCount;
            wonsJson[wonIndex]=won;

        }

    }

    int lostYearMem=0;
    var lostCount = 0;
    int lostIndex=0;
    int j=0;
    while(j<lengthof projectJson2){
        json lost={year:0,Number_of_Opportunities:0};
        var date, _ = (string)projectJson2[j].CloseDate;
        string yearString = strings:subString(date,0,4);
        var year, _ = <int>yearString;

        if(lostYearMem == 0) {
            lostCount = 1;
        }else if(lostYearMem != year && lostYearMem != 0){

            lost.year=lostYearMem;
            lost.Number_of_Opportunities=lostCount;
            lostsJson[lostIndex]=lost;
            lostIndex =lostIndex+1;
            lostCount = 1;
        }else{
            lostCount = lostCount +1;
        }

        lostYearMem = year;
        j=j+1;
        if(j==lengthof projectJson2){
            lost.year=lostYearMem;
            lost.Number_of_Opportunities=lostCount;
            lostsJson[lostIndex]=lost;

        }

    }



    var wonsStartYear, _ = (int)wonsJson[0].year;
    var lostsStartYear, _ = (int)lostsJson[0].year;

    if(wonsStartYear <= lostsStartYear) {
        startyear= wonsStartYear;
    }else{
        startyear= lostsStartYear;
    }


    var wonsEndYear, _ = (int)wonsJson[lengthof wonsJson - 1].year;
    var lostsEndYear, _ = (int)lostsJson[lengthof lostsJson - 1].year;


    if(wonsEndYear >= lostsEndYear) {
        endyear= wonsEndYear;
    }else{
        endyear= lostsEndYear;
    }


    int index = 0;
    var startYearIndex = startyear;

    int wonsCount = lengthof wonsJson;
    int wonsIndex = 0;
    int lostsCount = lengthof lostsJson;
    int lostsIndex = 0;


    while(startYearIndex <= endyear) {

        wons.won[index] = 0;
        losts.lost[index] = 0;
        years.year[index] = startYearIndex;

        var currentLoopYear, _ = (int)years.year[index];

        if(wonsIndex < wonsCount) {
            var wonYear, _ = (int)wonsJson[wonsIndex].year;
            if(wonYear == currentLoopYear && wonsIndex < wonsCount) {
                wons.won[index] = wonsJson[wonsIndex].Number_of_Opportunities;
                wonsIndex = wonsIndex + 1;
            }
        }
        if(lostsIndex < lostsCount) {
            var lostYear, _ = (int)lostsJson[lostsIndex].year;
            if(lostYear == currentLoopYear && lostsIndex < lostsCount) {
                losts.lost[index] = lostsJson[lostsIndex].Number_of_Opportunities;
                lostsIndex = lostsIndex + 1;

            }
        }

        index = index + 1;
        startYearIndex = startYearIndex + 1;

    }

    logger:info(wons);
    logger:info(losts);
    logger:info(years);

    send[0]= wons;
    send[1]= losts;
    send[2]= years;

    return send;
}

function getYears()(json){

    if (sfConn == null) {
        createSFConnection();
    }


    json send = [];
    message request1 = {};
    message response1 = {};

    json projectJson1 = {};

    json yearsJson = [];

    request1 = getSFRequest();


    json  payload1 = {"entryVector":"null","isClosed":"true","isWon":"null","closeDateYear":"null","orderByClosedDate":"ASC","orderByEntryVector":"null" };

    messages:setJsonPayload(request1,payload1);

    response1 = sfConn.post("/getOpportunityDetails",request1);

    //response1 = sfConn.post("/getOpportunityDetails?&isClosed=true&orderByClosedDate=ASC", request);

    projectJson1 = messages:getJsonPayload(response1);

    int yearMem = 0;

    int yearsIndex = 0;
    int i=0;
    while(i<lengthof projectJson1){
        json yearObject = {};
        var date, _ = (string)projectJson1[i].CloseDate;
        string yearString = strings:subString(date,0,4);
        var year, _ = <int>yearString;


        if(yearMem != year && yearMem != 0) {

            yearObject.Year = yearMem;

            yearsJson[yearsIndex] = yearObject;
            yearsIndex = yearsIndex + 1;

        }

        yearMem = year;
        i=i+1;
        if(i==lengthof projectJson1){
            yearObject.Year = yearMem;

            yearsJson[yearsIndex] = yearObject;

        }

    }

    logger:info(yearsJson);


    send[0]= yearsJson;
    return send;

}
function getProducts()(json){

    if (sfConn == null) {
        createSFConnection();
    }



    message request = {};
    message response1 = {};

    json projectJson1 = {};

    json productJson = [];

    request = getSFRequest();
    response1 = sfConn.get("/getOpportunityDetails?&isClosed=true&orderByEntryVector=true", request);

    projectJson1 = messages:getJsonPayload(response1);

    string productMem = "";

    int productIndex = 0;
    int loopIndex = 0;
    while(loopIndex < lengthof projectJson1) {
        json productObject = {};
        var product, _ = (string)projectJson1[loopIndex].Entry_Vector__c;


        if(productMem == "") {

        }else if(productMem != product && productMem != "") {

            productObject.Product = productMem;

            productJson[productIndex] = productObject;
            productIndex = productIndex + 1;

        }else{

        }

        productMem = product;
        loopIndex = loopIndex + 1;
        if(loopIndex == lengthof projectJson1) {
            productObject.Product = productMem;

            productJson[productIndex] = productObject;

        }

    }

    logger:info(productJson);



    return productJson;

}








