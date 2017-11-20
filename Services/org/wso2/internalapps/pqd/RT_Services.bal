package org.wso2.internalapps.pqd;


import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.utils.logger;



@http:configuration {basePath:"/base",httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks",
                     keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> releaseTrainService {


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
        updateProject();
        http:setStatusCode(m, 202);
        messages:setStringPayload(m, "Request Accepted");
        reply m;
    }

    @http:GET {}
    @http:Path{value:"/user"}
    resource resource3 (message m) {
        updateUser();
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }


    @http:GET {}
    @http:Path{value:"/version"}
    resource resource4 (message m) {
        updateVersion();
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }


    @http:GET {}
    @http:Path{value:"/issue"}
    resource resource5 (message m) {
        updateIssue();
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }



    @http:GET {}
    @http:Path{value:"/getAllReleases"}
    resource resource6 (message m) {
        message send={};
        json dataSet1 = getAllReleases();
        messages:setJsonPayload(send,dataSet1);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/getProductWiseReleases/{product}"}
    resource resource7 (message m,@http:PathParam {value:"product"} string product) {

        message send={};
        json dataSet1 = getReleasesByProduct(product);
        messages:setJsonPayload(send,dataSet1);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/manager/{product}/{startDate}/{endDate}"}
    resource resource8 (message m, @http:PathParam {value:"product"} string product,
                        @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {

        message send={};
        json manager = getManagers(product,startDate,endDate);
        messages:setJsonPayload(send,manager);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/tracker/{trackerId}/{versionId}"}
    resource resource9 (message m, @http:PathParam {value:"trackerId"} int trackerId, @http:PathParam {value:"versionId"} int versionId) {

        message send={};
        json trackerSubjects = getTrackerSubjects(trackerId,versionId);
        messages:setJsonPayload(send,trackerSubjects);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }

    @http:GET {}
    @http:Path{value:"/getFixedGitIssues/{repoName}"}
    resource resource10 (message m, @http:PathParam {value:"repoName"} string repoName, @http:QueryParam {value:"versionName"} string versionName){

        message response={};

        json jsonRes = getFixedGitIssues(repoName, versionName);

        messages:setJsonPayload(response,jsonRes);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/getReportedGitIssues/{repoName}"}
    resource resource11 (message m, @http:PathParam {value:"repoName"} string repoName, @http:QueryParam {value:"versionName"} string versionName){

        message response={};

        json jsonRes = getReportedGitIssues(repoName, versionName);

        messages:setJsonPayload(response,jsonRes);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/getRepoAndVersion/{projectId}/{versionId}"}
    resource resource12 (message m, @http:PathParam {value:"projectId"} int projectId, @http:PathParam {value:"versionId"} int versionId){

        message response={};

        json jsonRes = getRepoAndVersion(projectId, versionId);

        messages:setJsonPayload(response,jsonRes);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }



}
