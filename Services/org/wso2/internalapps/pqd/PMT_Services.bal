package org.wso2.internalapps.pqd;
import ballerina.net.http;
import ballerina.data.sql;


@http:configuration {
    basePath:"/pmt-dashboard-serives",
    httpsPort:9092,
    keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword:"ballerina",
    certPassword:"ballerina",
    trustStoreFile:"${ballerina.home}/bre/security/ballerinaTruststore.p12",
    trustStorePassword:"ballerina",
    ciphers:"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
    sslEnabledProtocols:"TLSv1.2,TLSv1.1"
}

service<http> pmtserives {
    http:HttpClient jiraConnection = getJiraConnector();

    @http:resourceConfig {
        methods:["GET"],
        path:"/loaddashboard/{startDate}/{endDate}"
    }
    resource loadInitialsCounts (http:Request request, http:Response response,string startDate,string endDate ) {
        json loadCounts = loadDashboardWithHistory(jiraConnection,startDate,endDate);

        response.setJsonPayload(loadCounts);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/get-queue-details/{startDate}/{endDate}"
    }
    resource getQueueDetails (http:Request request, http:Response response,string startDate,string endDate ) {
        json jsonResOfQueueDetails = queuedDetails(startDate,endDate);

        response.setJsonPayload(jsonResOfQueueDetails);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/get-dev-details/{startDate}/{endDate}"
    }
    resource getDevDetails (http:Request request, http:Response response,string startDate,string endDate ) {
        json jsonResOfDevDetails = devDetails(startDate,endDate);

        response.setJsonPayload(jsonResOfDevDetails);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/get-complete-details/{startDate}/{endDate}"
    }
    resource getCompleteDetails (http:Request request, http:Response response,string startDate,string endDate ) {
        json jsonResOfCompleteDetails = completeDetails(startDate,endDate);

        response.setJsonPayload(jsonResOfCompleteDetails);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-reportedPatchGraph/{duration}/{startDate}/{endDate}"
    }
    resource loadReportedPatchGraph (http:Request request, http:Response response,string duration,string startDate,string endDate ) {
        json reportedPatchJSON = reportedPatchGraph(duration,startDate,endDate);

        response.setJsonPayload(reportedPatchJSON);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-menu-badgeCounts/{startDate}/{endDate}"
    }
    resource getMenuBadgeCounts (http:Request request, http:Response response,string startDate,string endDate ) {
        json menuBadgeCount = menuBadgesCounts(startDate,endDate);

        response.setJsonPayload(menuBadgeCount);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-menu-version-badgeCounts/{startDate}/{endDate}"
    }
    resource getMenuVersionBadgeCounts (http:Request request, http:Response response,string startDate,string endDate ) {
        json menuVersionBadgeCount = menuVersionBadgesCounts(startDate,endDate);

        response.setJsonPayload(menuVersionBadgeCount);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-total-product-summary/{product}/{startDate}/{endDate}"
    }
    resource loadProductSummaryCounts (http:Request request, http:Response response,string product,string startDate,string endDate ) {
        json totalProductSummaryCount = totalProductSummaryCounts(product,startDate,endDate);

        response.setJsonPayload(totalProductSummaryCount);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-total-release-trend/{product}/{duration}/{startDate}/{endDate}"
    }
    resource totalProductReleaseTrendGraph (http:Request request, http:Response response,string product,string duration,string startDate,string endDate ) {
        json totalReleaseTrendJSON = selectedProductTotalReleaseTrend(product,duration,startDate,endDate);

        response.setJsonPayload(totalReleaseTrendJSON);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-version-product-version-summary/{product}/{versions}/{startDate}/{endDate}"
    }
    resource loadProductVersionSummaryCounts (http:Request request, http:Response response,string product,string versions,string startDate,string endDate ) {
        json versionProductSummaryCount = selectedProductVersionSummaryCounts(product,versions,startDate,endDate);

        response.setJsonPayload(versionProductSummaryCount);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-version-release-trend/{product}/{versions}/{duration}/{startDate}/{endDate}"
    }
    resource versionProductReleaseTrendGraph(http:Request request, http:Response response,string product,string versions,string duration,string startDate,string endDate ) {
        json versionReleaseTrendJSON = selectedProductVersionReleaseTrend(product,versions,duration,startDate,endDate);

        response.setJsonPayload(versionReleaseTrendJSON);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-all-version-release-trend/{product}/{versions}/{duration}/{startDate}/{endDate}"
    }
    resource allVersionProductReleaseTrendGraph(http:Request request, http:Response response,string product,string versions,string duration,string startDate,string endDate ) {
        json allVersionReleaseTrendJSON = selectedProductAllVersionReleaseTrend(product,versions,duration,startDate,endDate);

        response.setJsonPayload(allVersionReleaseTrendJSON);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-category-alltrend/{product}/{duration}/{startDate}/{endDate}"
    }
    resource categoryAllReleaseTrendGraph(http:Request request, http:Response response,string product,string duration,string startDate,string endDate ) {
        json jsonResOfcategory = getCategoryDatesForSelectedAllProductVersions(product,duration,startDate,endDate);

        response.setJsonPayload(jsonResOfcategory);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-queued-age-graph"
    }
    resource queuedAgeGraph(http:Request request, http:Response response) {
        map params = request.getQueryParams();

        var lastMonthDate, _ = (string)params.lastMonthDate;

        json queuedAgeGraph = queuedAgeGraphGenerator(lastMonthDate);

        response.setJsonPayload(queuedAgeGraph);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-drilldown-age-graph/{group}/{month}"
    }
    resource drillDownQueuedAgeGraph(http:Request request, http:Response response,string group,string month) {
        json drillDownQueuedAgeGraph = ageDrillDownGraph(group,month);

        response.setJsonPayload(drillDownQueuedAgeGraph);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-lifecycle-stack/{start}/{end}"
    }

    resource lifeCycleStack(http:Request request, http:Response response,string start,string end) {
        json lifeCycleStackGraphs = lifeCycleStackGraph(start,end);

        response.setJsonPayload(lifeCycleStackGraphs);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-lifecycle-states/{product}/{start}/{end}"
    }

    resource lifeCycleTransitionGraph(http:Request request, http:Response response,string product,string start,string end) {
        json lifeCycleStatesResponse = stateTransitionGraphOfLifeCycle(product,start,end);

        response.setJsonPayload(lifeCycleStatesResponse);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/load-lifecycle-states-patch/{patchID}/{eID}"
    }

    resource getSpecificPatchDetails(http:Request request, http:Response response,string patchID,string eID) {
        json onePatchLifeCycleStatesResponse = getSpecificPatchLifeCycle(patchID,eID);

        response.setJsonPayload(onePatchLifeCycleStatesResponse);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

}
