package salesForcepkg;

import salesForceConf;
import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.data.sql;


@http:configuration {basePath:"/base1",httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks",
keyStorePass: "wso2carbon", certPass: "wso2carbon"}

service<http> Service1 {


    map props = {"jdbcUrl":"jdbc:mysql://"+salesForceConf:dbIP+":"+salesForceConf:dbPort+"/"+salesForceConf:dbName+"?useSSL=false",
                    "username":salesForceConf:dbUsername, "password":salesForceConf:dbPassword};
    sql:ClientConnector sfDB = create sql:ClientConnector(props);

    sql:Parameter[] params = [];

    @http:Path {value:"/customer/{product}"}
    resource resource1 (message m, @http:PathParam {value:"product"} string product) {

        message response = {};
        json send = [];


        datatable query1;
        if (product == "All") {
            query1 = sql:ClientConnector.select(sfDB, "SELECT a.Name as Name ,m.ProductArea as Product  from  SF_OPPORTUNITY o
                                                    join SF_OPPOLINEITEM l on l.OpportunityId = o.Id
                                                    join SF_ACCOUNT a on a.Id = o.AccountId
                                                    join SF_PRODUCT_TO_ENTRY_VECTOR_MAP m on m.EntryVector = o.Entry_Vector__c
                                                    where o.PS_Support_Account_End_Date_Roll_Up__c >= current_date() and
                                                         o.PS_Support_Account_Start_Date_Roll_Up__c <= current_date() and
                                                         (l.Classification__c = 'PS' or l.Classification__c = 'LI') and
                                                         o.Entry_Vector__c != ' NULL'
                                                    Group by a.Name, o.Entry_Vector__c, m.EntryVector ; ", params);
        } else {
            sql:Parameter[] params1 = [];
            sql:Parameter para1 = {sqlType:"varchar", value:product};
            params1 = [para1];
            query1 = sql:ClientConnector.select(sfDB, "SELECT a.Name as Name ,m.ProductArea as Product  from  SF_OPPORTUNITY o
                                                                join SF_OPPOLINEITEM l on l.OpportunityId = o.Id
                                                                join SF_ACCOUNT a on a.Id = o.AccountId
                                                                join SF_PRODUCT_TO_ENTRY_VECTOR_MAP m on m.EntryVector = o.Entry_Vector__c
                                                                where o.PS_Support_Account_End_Date_Roll_Up__c >= current_date() and
                                                                     o.PS_Support_Account_Start_Date_Roll_Up__c <= current_date() and
                                                                     (l.Classification__c = 'PS' or l.Classification__c = 'LI') and
                                                                     o.Entry_Vector__c != ' NULL' and
                                                                     m.ProductArea=?
                                                                Group by a.Name, o.Entry_Vector__c, m.EntryVector ; ", params1);
        }




        var queryresult1, _ = <json>query1;


        messages:setJsonPayload(response, queryresult1);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

}