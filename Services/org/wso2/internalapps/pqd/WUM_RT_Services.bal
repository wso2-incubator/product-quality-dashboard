package org.wso2.internalapps.pqd;


import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.utils.logger;




@http:configuration {basePath:"/wumReleaseTrainServices",httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks",
                     keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> releaseTrainService {

    @http:GET {}
    @http:Path{value:"/getAllReleases/{startEpochTime}/{endEpochTime}"}
    resource getAllReleases (message m,@http:PathParam {value:"startEpochTime"} int startEpochTime,@http:PathParam {value:"endEpochTime"} int endEpochTime) {
        message send={};
        logger:info("/getAllReleases/{startEpochTime}/{endEpochTime} Rest call triggered");
        logger:info(startEpochTime);
        logger:info(endEpochTime);
        json sendData = getAllWUMReleases(startEpochTime, endEpochTime);

        messages:setJsonPayload(send, sendData);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/getProductWiseReleases/{productArea}/{startEpochTime}/{endEpochTime}"}
    resource getAllReleasesByProductArea (message m, @http:PathParam {value:"productArea"} string productArea, @http:PathParam {value:"startEpochTime"} int startEpochTime, @http:PathParam {value:"endEpochTime"} int endEpochTime) {

        message send={};
        logger:info("/getProductWiseReleases/{productArea}/{startEpochTime}/{endEpochTime} Rest call triggered");
        logger:info(startEpochTime);
        logger:info(endEpochTime);
        json sendData = getWUMReleasesByProductArea(productArea, startEpochTime, endEpochTime);

        messages:setJsonPayload(send, sendData);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }

}
