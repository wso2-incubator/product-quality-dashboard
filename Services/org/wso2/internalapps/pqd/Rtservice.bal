package org.wso2.internalapps.pqd;

import ballerina.net.http;
import ballerina.data.sql;
import ballerina.log;

@http:configuration {
    basePath:"/releaseTrainServices",
    httpsPort:9095,
    keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword:"ballerina",
    certPassword:"ballerina",
    trustStoreFile:"${ballerina.home}/bre/security/ballerinaTruststore.p12",
    trustStorePassword:"ballerina",
    ciphers:"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
    sslEnabledProtocols:"TLSv1.2,TLSv1.1"
}
service<http> helloWorld {

    http:HttpClient rmConn = getRedmineConnector();
    http:HttpClient gitConn = getGitHubConnector();


    @http:resourceConfig {
        methods:["GET"],
        path:"/"
    }
    resource test (http:Request request, http:Response response) {

        response.setStringPayload("Hello World !!!");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/updateRedmineProjects"
    }
    resource updateRedmineProjects (http:Request request, http:Response response) {
        log:printInfo("/updateRedmineProjects Rest call triggered");
        response.setStatusCode(202);
        response.setStringPayload("Request Accepted");
        _ =response.send();
        updateProject(rmConn);

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/updateRedmineUsers"
    }
    resource updateRedmineUsers (http:Request request, http:Response response) {
        log:printInfo("/updateRedmineUsers Rest call triggered");
        response.setStatusCode(202);
        response.setStringPayload("Request Accepted");
        _ =response.send();
        updateUser(rmConn);

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/updateRedmineVersions"
    }
    resource updateRedmineVersions (http:Request request, http:Response response) {
        log:printInfo("/updateRedmineVersions Rest call triggered");
        response.setStatusCode(202);
        response.setStringPayload("Request Accepted");
        _ =response.send();
        updateVersion(rmConn);

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/updateRedmineIssues"
    }
    resource updateRedmineIssues (http:Request request, http:Response response) {
        log:printInfo("/updateRedmineIssues Rest call triggered");
        response.setStatusCode(202);
        response.setStringPayload("Request Accepted");
        _ =response.send();
        updateIssue(rmConn);

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/getAllReleases"
    }
    resource getAllReleases (http:Request request, http:Response response) {
        log:printInfo("/getAllReleases Rest call triggered");
        json jsonRes = {};
        jsonRes=getAllReleases();
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/getProductWiseReleases/{productArea}"
    }
    resource getAllReleasesByProductArea (http:Request request, http:Response response, string productArea) {
        log:printInfo("/getProductWiseReleases/{productArea} Rest call triggered");
        json jsonRes = {};
        jsonRes=getReleasesByProduct(productArea);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/manager/{productArea}/{startDate}/{endDate}"
    }
    resource getManagerDetails (http:Request request, http:Response response, string productArea, string startDate, string endDate) {
        log:printInfo("/manager/{productArea}/{startDate}/{endDate} Rest call triggered");
        json jsonRes = {};
        jsonRes=getManagers(productArea, startDate, endDate);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/tracker/{trackerId}/{versionId}"
    }
    resource getRedmineTrackers (http:Request request, http:Response response, string trackerId, string versionId) {
        log:printInfo("/tracker/{trackerId}/{versionId} Rest call triggered");
        json jsonRes = {};
        jsonRes=getTrackerSubjects(trackerId, versionId);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/getFixedGitIssues/{repoName}"
    }
    resource getGitHubFixedIssues (http:Request request, http:Response response, string repoName){
        log:printInfo("/getFixedGitIssues/{repoName} Rest call triggered");
        map params = request.getQueryParams();
        var versionName, _ = (string)params.versionName;
        json jsonRes = getFixedGitIssues(gitConn,repoName, versionName);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/getReportedGitIssues/{repoName}"
    }
    resource getGitHubReportedIssues (http:Request request, http:Response response, string repoName){
        log:printInfo("/getReportedGitIssues/{repoName} Rest call triggered");
        map params = request.getQueryParams();
        var versionName, _ = (string)params.versionName;
        json jsonRes = getReportedGitIssues(gitConn,repoName, versionName);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/getRepoAndVersion/{projectId}/{versionId}"
    }
    resource getGitHubRepoNameAndRedmineVersionName (http:Request request, http:Response response, string projectId, string versionId) {
        log:printInfo("/getRepoAndVersion/{projectId}/{versionId} Rest call triggered");
        json jsonRes = {};
        jsonRes=getRepoAndVersion(projectId, versionId);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/getRepoAndGitVersionByGitId/{gitVersionId}"
    }
    resource getGitHubRepoNameAndVersionName (http:Request request, http:Response response, string gitVersionId) {
        log:printInfo("/getRepoAndGitVersionByGitId/{gitVersionId} Rest call triggered");
        json jsonRes = {};
        jsonRes=getRepoAndGitVersionByGitId(gitVersionId);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/updateGitHubReleases"
    }
    resource updateGitHubReleases (http:Request request, http:Response response) {
        log:printInfo("/updateGitHubReleases Rest call triggered");
        response.setStatusCode(202);
        response.setStringPayload("Request Accepted");
        _ =response.send();
        updateGitHubReleases(rmConn,gitConn);

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/getFixedGitIssuesCount/{repoName}"
    }
    resource getFixedGitIssuesCount (http:Request request, http:Response response, string repoName){
        log:printInfo("/getFixedGitIssuesCount/{repoName} Rest call triggered");
        map params = request.getQueryParams();
        var versionName, _ = (string)params.versionName;
        json jsonRes = getFixedGitIssuesCount(gitConn,repoName, versionName);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/getReportedGitIssuesCount/{repoName}"
    }
    resource getReportedGitIssuesCount (http:Request request, http:Response response, string repoName){
        log:printInfo("/getReportedGitIssuesCount/{repoName} Rest call triggered");
        map params = request.getQueryParams();
        var versionName, _ = (string)params.versionName;
        json jsonRes = getReportedGitIssuesCount(gitConn,repoName, versionName);
        log:printDebug(jsonRes.toString());
        response.setJsonPayload(jsonRes);
        response.setHeader("Access-Control-Allow-Origin","*");
        _ =response.send();
    }
}
