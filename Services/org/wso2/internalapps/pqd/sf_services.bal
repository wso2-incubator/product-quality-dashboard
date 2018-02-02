package org.wso2.internalapps.pqd;

import ballerina.net.http;
import ballerina.lang.messages;

import ballerina.utils.logger;

@http:configuration {basePath:"/salesForceCustomerDetailsServices",httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> Service1 {

    @http:POST{}
    @http:Path {value:"/getOppProductAreas"}

    resource getOppKeys (message m){


        message response = {};
        json send = [];

        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
            send = getProductOppAreaKeys();
        }
        logger:info("/getOppProductAreas Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST{}
    @http:Path {value:"/getAccProductAreas"}

    resource getAccKeys (message m){


        message response = {};
        json send = [];

        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
        send = getProductAccAreaKeys();
        }
        logger:info("/getAccProductAreas Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST{}
    @http:Path {value:"/getOppLineItemProductAreas"}

    resource getOppLineItemKeys (message m){


        message response = {};
        json send = [];

        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
        send = getProductOppLineItemAreaKeys();
        }
        logger:info("/getOppLineItemProductAreas Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }


    @http:POST{}
    @http:Path {value:"/years"}

    resource getYears (message m){
        // This resource for get the distinct years of the database  which  has opportunities.

        message response = {};
        json send = [];

        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
            send = getYears();
        }
        logger:info("/years Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/byyear/{productArea}"}

    resource getWonsAndLostsByYearAndArea(message m,@http:PathParam {value:"productArea"} string productArea){
        message response = {};
        json send = [];
        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
            send = getWonsAndLostsByYearAndArea(productArea);
        }

        logger:info("/byyear/{productArea} Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/bymonth/{productArea}/{year}"}

    resource getWonsAndLostsByMonthAndArea (message m,@http:PathParam {value:"productArea"} string productArea,@http:PathParam {value:"year"} string year){
        message response = {};
        json send = [];
        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
            send = getWonsAndLostsByMonthAndArea(productArea, year);
        }

        logger:info("/bymonth/{productArea}/{year} Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/byquarter/{productArea}/{year}"}

    resource getWonsAndLostsByQuarterAndArea (message m,@http:PathParam {value:"productArea"} string productArea,@http:PathParam {value:"year"} string year){
        message response = {};
        json send = [];
        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
            send = getWonsAndLostsByQuarterAndArea(productArea, year);
        }

        logger:info("/byquarter/{productArea}/{year} Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/customer/{productArea}"}
    resource getActiveCustomers (message m,@http:PathParam {value:"productArea"} string productArea){

        message response = {};
        json send = [];
        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
            if(productArea=="All"){
                send=getAllActiveCustomers();
            }else{
                send=getActiveCustomers(productArea);
            }
        }

        logger:info("/customer/{productArea} Rest call triggered");
        messages:setJsonPayload(response, send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;

    }

    @http:POST {}
    @http:Path {value:"/byyearlogos/{year1}/{year2}/{productArea}"}

    resource getNewLogosByYearAndArea (message m,@http:PathParam {value:"year1"} string year1,@http:PathParam {value:"year2"} string year2,@http:PathParam {value:"productArea"} string productArea){
        message response = {};
        json send = [];
        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
            send = getNewLogosByYearAndArea(productArea, year1, year2);
        }

        logger:info("/byyearlogos/{year1}/{year2}/{productArea} Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/byquarterlogos/{year1}/{year2}/{productArea}"}

    resource getNewLogosByQuarterAndArea (message m,@http:PathParam {value:"year1"} string year1,@http:PathParam {value:"year2"} string year2,@http:PathParam {value:"productArea"} string productArea){
        message response = {};
        json send = [];
        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){

            send = getNewLogosByQuarterAndArea(productArea, year1, year2);
        }

        logger:info("/byquarterlogos/{year1}/{year2}/{productArea} Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/bymonthlogos/{year1}/{year2}/{productArea}"}

    resource getNewLogosByMonthAndArea (message m,@http:PathParam {value:"year1"} string year1,@http:PathParam {value:"year2"} string year2,@http:PathParam {value:"productArea"} string productArea){
        message response = {};
        json send = [];
        var tokenBluePrint = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";
        var tokenJson  = messages:getJsonPayload(m);
        var token, _ = (string)tokenJson.TOKEN;

        if(tokenBluePrint==token){
            send = getNewLogosByMonthAndArea(productArea, year1, year2);
        }

        logger:info("/bymonthlogos/{year1}/{year2}/{productArea} Rest call triggered");
        messages:setJsonPayload(response,send);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }




}
