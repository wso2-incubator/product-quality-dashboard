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
        logger:info("/project Rest call triggered");
        http:setStatusCode(m, 202);
        messages:setStringPayload(m, "Request Accepted");
        reply m;
    }

    @http:GET {}
    @http:Path{value:"/user"}
    resource resource3 (message m) {
        updateUser();
        logger:info("/user Rest call triggered");
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }


    @http:GET {}
    @http:Path{value:"/version"}
    resource resource4 (message m) {
        updateVersion();
        logger:info("/version Rest call triggered");
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }


    @http:GET {}
    @http:Path{value:"/issue"}
    resource resource5 (message m) {
        updateIssue();
        logger:info("/issue Rest call triggered");
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }



    @http:GET {}
    @http:Path{value:"/getAllReleases"}
    resource resource6 (message m) {
        message send={};
        json sendData = getAllReleases();
        logger:info("/getAllReleases Rest call triggered");
        messages:setJsonPayload(send, sendData);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/getProductWiseReleases/{productArea}"}
    resource resource7 (message m,@http:PathParam {value:"productArea"} string productArea) {

        message send={};
        json sendData = getReleasesByProductArea(productArea);
        logger:info("/getProductWiseReleases/{productArea} Rest call triggered");
        messages:setJsonPayload(send, sendData);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/manager/{productArea}/{startDate}/{endDate}"}
    resource resource8 (message m, @http:PathParam {value:"productArea"} string productArea,
                        @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {

        message send={};
        json manager = getManagers(productArea,startDate,endDate);
        logger:info("/manager/{productArea}/{startDate}/{endDate} Rest call triggered");
        messages:setJsonPayload(send,manager);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/tracker/{trackerId}/{versionId}"}
    resource resource9 (message m, @http:PathParam {value:"trackerId"} int trackerId, @http:PathParam {value:"versionId"} int versionId) {

        message send={};
        json trackerSubjects = getTrackerSubjects(trackerId,versionId);
        logger:info("/tracker/{trackerId}/{versionId} Rest call triggered");
        messages:setJsonPayload(send,trackerSubjects);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }

    @http:GET {}
    @http:Path{value:"/getFixedGitIssues/{repoName}"}
    resource resource10 (message m, @http:PathParam {value:"repoName"} string repoName, @http:QueryParam {value:"versionName"} string versionName){

        message response={};

        json fixedIssues = getFixedGitIssues(repoName, versionName);
        logger:info("/getFixedGitIssues/{repoName} Rest call triggered");
        messages:setJsonPayload(response, fixedIssues);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/getReportedGitIssues/{repoName}"}
    resource resource11 (message m, @http:PathParam {value:"repoName"} string repoName, @http:QueryParam {value:"versionName"} string versionName){

        message response={};

        json reportedIssues = getReportedGitIssues(repoName, versionName);
        logger:info("/getReportedGitIssues/{repoName} Rest call triggered");
        messages:setJsonPayload(response, reportedIssues);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/getRepoAndVersion/{projectId}/{versionId}"}
    resource resource12 (message m, @http:PathParam {value:"projectId"} int projectId, @http:PathParam {value:"versionId"} int versionId){

        message response={};

        json sendData = getRepoAndVersion(projectId, versionId);
        logger:info("/getRepoAndVersion/{projectId}/{versionId} Rest call triggered");
        messages:setJsonPayload(response, sendData);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/updateGitHubReleases"}
    resource resource13 (message m) {
        updateGitHubReleases();
        logger:info("/updateGitHubReleases Rest call triggered");
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }

    @http:GET {}
    @http:Path{value:"/getRepoAndGitVersionByGitId/{gitVersionId}"}
    resource resource14 (message m, @http:PathParam {value:"gitVersionId"} int gitVersionId) {
        message response={};
        json sendData = getRepoAndGitVersionByGitId(gitVersionId);
        logger:info("/getRepoAndGitVersionByGitId/{gitVersionId} Rest call triggered");
        messages:setJsonPayload(response, sendData);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;

    }

}
