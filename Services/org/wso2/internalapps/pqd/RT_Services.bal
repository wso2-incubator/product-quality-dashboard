package org.wso2.internalapps.pqd;


import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.utils.logger;



@http:configuration {basePath:"/releaseTrainServices",httpsPort: 9092, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks",
                     keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> releaseTrainService {


    @http:GET {}
    @http:Path{value:"/"}
    resource test (message m) {




        message send={};

        logger:info("test");



        messages:setJsonPayload(send,"test");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/updateRedmineProjects"}
    resource updateRedmineProjects (message m) {
        updateProject();
        logger:info("/updateRedmineProjects Rest call triggered");
        http:setStatusCode(m, 202);
        messages:setStringPayload(m, "Request Accepted");
        reply m;
    }

    @http:GET {}
    @http:Path{value:"/updateRedmineUsers"}
    resource updateRedmineUsers (message m) {
        updateUser();
        logger:info("/updateRedmineUsers Rest call triggered");
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }


    @http:GET {}
    @http:Path{value:"/updateRedmineVersions"}
    resource updateRedmineVersions (message m) {
        updateVersion();
        logger:info("/updateRedmineVersions Rest call triggered");
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }


    @http:GET {}
    @http:Path{value:"/updateRedmineIssues"}
    resource updateRedmineIssues (message m) {
        updateIssue();
        logger:info("/updateRedmineIssues Rest call triggered");
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }



    @http:GET {}
    @http:Path{value:"/getAllReleases"}
    resource getAllReleases (message m) {
        message send={};
        json sendData = getAllReleases();
        logger:info("/getAllReleases Rest call triggered");
        messages:setJsonPayload(send, sendData);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/getProductWiseReleases/{productArea}"}
    resource getAllReleasesByProductArea (message m,@http:PathParam {value:"productArea"} string productArea) {

        message send={};
        json sendData = getReleasesByProductArea(productArea);
        logger:info("/getProductWiseReleases/{productArea} Rest call triggered");
        messages:setJsonPayload(send, sendData);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }


    @http:GET {}
    @http:Path{value:"/manager/{productArea}/{startDate}/{endDate}"}
    resource getManagerDetails (message m, @http:PathParam {value:"productArea"} string productArea,
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
    resource getRedmineTrackers (message m, @http:PathParam {value:"trackerId"} int trackerId, @http:PathParam {value:"versionId"} int versionId) {

        message send={};
        json trackerSubjects = getTrackerSubjects(trackerId,versionId);
        logger:info("/tracker/{trackerId}/{versionId} Rest call triggered");
        messages:setJsonPayload(send,trackerSubjects);
        messages:setHeader(send,"Access-Control-Allow-Origin","*");
        reply send;

    }

    @http:GET {}
    @http:Path{value:"/getFixedGitIssues/{repoOrganizationName}/{repoName}"}
    resource getGitHubFixedIssues (message m, @http:PathParam {value:"repoOrganizationName"} string repoOrganizationName, @http:PathParam {value:"repoName"} string repoName, @http:QueryParam {value:"versionName"} string versionName){

        message response={};

        json fixedIssues = getFixedGitIssues(repoOrganizationName, repoName, versionName);
        logger:info("/getFixedGitIssues/{repoName} Rest call triggered");
        messages:setJsonPayload(response, fixedIssues);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/getReportedGitIssues/{repoOrganizationName}/{repoName}"}
    resource getGitHubReportedIssues (message m, @http:PathParam {value:"repoOrganizationName"} string repoOrganizationName, @http:PathParam {value:"repoName"} string repoName, @http:QueryParam {value:"versionName"} string versionName){

        message response={};

        json reportedIssues = getReportedGitIssues(repoOrganizationName, repoName, versionName);
        logger:info("/getReportedGitIssues/{repoName} Rest call triggered");
        messages:setJsonPayload(response, reportedIssues);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/getRepoAndVersion/{projectId}/{versionId}"}
    resource getGitHubRepoNameAndRedmineVersionName (message m, @http:PathParam {value:"projectId"} int projectId, @http:PathParam {value:"versionId"} int versionId){

        message response={};

        json sendData = getRepoAndVersion(projectId, versionId);
        logger:info("/getRepoAndVersion/{projectId}/{versionId} Rest call triggered");
        messages:setJsonPayload(response, sendData);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/getRepoAndGitVersionByGitId/{gitVersionId}"}
    resource getGitHubRepoNameAndVersionName (message m, @http:PathParam {value:"gitVersionId"} int gitVersionId) {
        message response={};
        json sendData = getRepoAndGitVersionByGitId(gitVersionId);
        logger:info("/getRepoAndGitVersionByGitId/{gitVersionId} Rest call triggered");
        messages:setJsonPayload(response, sendData);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;

    }

    @http:GET {}
    @http:Path{value:"/updateGitHubReleases"}
    resource updateGitHubReleases(message m) {
        updateGitHubReleases();
        logger:info("/updateGitHubReleases Rest call triggered");
        http:setStatusCode(m,202);
        messages:setStringPayload(m,"Request Accepted");
        reply m;
    }

    @http:GET {}
    @http:Path{value:"/getFixedGitIssuesCount/{repoOrganizationName}/{repoName}"}
    resource getGitHubFixedIssueCount (message m, @http:PathParam {value:"repoOrganizationName"} string repoOrganizationName,@http:PathParam {value:"repoName"} string repoName, @http:QueryParam {value:"versionName"} string versionName){

        message response={};

        json fixedIssuesCount = getFixedGitIssuesCount(repoOrganizationName, repoName, versionName);
        logger:info("/getFixedGitIssuesCount/{repoName} Rest call triggered");
        messages:setJsonPayload(response, fixedIssuesCount);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

    @http:GET {}
    @http:Path{value:"/getReportedGitIssuesCount/{repoOrganizationName}/{repoName}"}
    resource getGitHubReportedIssueCount(message m, @http:PathParam {value:"repoOrganizationName"} string repoOrganizationName, @http:PathParam {value:"repoName"} string repoName, @http:QueryParam {value:"versionName"} string versionName){

        message response={};

        json reportedIssuesCount = getReportedGitIssuesCount(repoOrganizationName, repoName, versionName);
        logger:info("/getRepotedGitIssuesCount/{repoName} Rest call triggered");
        messages:setJsonPayload(response, reportedIssuesCount);
        messages:setHeader(response,"Access-Control-Allow-Origin","*");
        reply response;
    }

}
