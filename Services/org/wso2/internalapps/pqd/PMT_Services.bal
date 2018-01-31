package org.wso2.internalapps.pqd;

import ballerina.lang.messages;
import ballerina.net.http;

@http:configuration {
    basePath:"/pmt-dashboard-serives",
    httpsPort:9092,
    keyStoreFile:"${ballerina.home}/bre/security/wso2carbon.jks",
    keyStorePass:"wso2carbon",
    certPass:"wso2carbon"
}

service<http> pmtserives {

    @http:GET {}
    @http:Path {value:"/loaddashboard/{startDate}/{endDate}"}

    resource loadInitialPatchCounts (message m, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json loadCounts = loadDashboardWithHistory(startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, loadCounts);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-reportedPatchGraph/{duration}/{startDate}/{endDate}"}

    resource loadReportedPatchGraph (message m, @http:PathParam {value:"duration"} string duration, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json reportedPatchJSON = reportedPatchGraph(duration, startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, reportedPatchJSON);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/get-queue-details/{startDate}/{endDate}"}

    resource getQueueDetails (message m, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json jsonResOfQueueDetails = queuedDetails(startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, jsonResOfQueueDetails);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/get-dev-details/{startDate}/{endDate}"}

    resource getDevDetails (message m, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json jsonResOfDevDetails = devDetails(startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, jsonResOfDevDetails);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/get-complete-details/{startDate}/{endDate}"}

    resource getCompleteDetails (message m, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json jsonResOfCompleteDetails = completeDetails(startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, jsonResOfCompleteDetails);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-menu-badgeCounts/{startDate}/{endDate}"}

    resource getMenuBadgeCounts (message m, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json menuBadgeCount = menuBadgesCounts(startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, menuBadgeCount);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-menu-version-badgeCounts/{startDate}/{endDate}"}

    resource getMenuVersionBadgeCounts (message m, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json menuVersionBadgeCount = menuVersionBadgesCounts(startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, menuVersionBadgeCount);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }


    @http:GET {}
    @http:Path {value:"/load-total-product-summary/{product}/{startDate}/{endDate}"}

    resource loadProductSummaryCounts (message m, @http:PathParam {value:"product"} string product, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json totalProductSummaryCount = totalProductSummaryCounts(product, startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, totalProductSummaryCount);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-total-release-trend/{product}/{duration}/{startDate}/{endDate}"}

    resource totalProductReleaseTrendGraph (message m, @http:PathParam {value:"product"} string product, @http:PathParam {value:"duration"} string duration, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json totalReleaseTrendJSON = selectedProductTotalReleaseTrend(product, duration, startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, totalReleaseTrendJSON);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-version-product-version-summary/{product}/{version}/{startDate}/{endDate}"}

    resource loadProductVersionSummaryCounts (message m, @http:PathParam {value:"product"} string product, @http:PathParam {value:"version"} string version, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json versionProductSummaryCount = selectedProductVersionSummaryCounts(product, version, startDate, endDate);
        message response = {};
        messages:setJsonPayload(response, versionProductSummaryCount);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-version-release-trend/{product}/{version}/{duration}/{startDate}/{endDate}"}

    resource versionProductReleaseTrendGraph (message m, @http:PathParam {value:"product"} string product, @http:PathParam {value:"version"} string version, @http:PathParam {value:"duration"} string duration, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json versionReleaseTrendJSON = selectedProductVersionReleaseTrend(product, version, duration, startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, versionReleaseTrendJSON);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-all-version-release-trend/{product}/{version}/{duration}/{startDate}/{endDate}"}

    resource allVersionProductReleaseTrendGraph (message m, @http:PathParam {value:"product"} string product, @http:PathParam {value:"version"} string version, @http:PathParam {value:"duration"} string duration, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json allVersionReleaseTrendJSON = selectedProductAllVersionReleaseTrend(product, version, duration, startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, allVersionReleaseTrendJSON);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-category-alltrend/{product}/{duration}/{startDate}/{endDate}"}

    resource categoryAllReleaseTrendGraph (message m, @http:PathParam {value:"product"} string product, @http:PathParam {value:"duration"} string duration, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json jsonResOfcategory = getCategoryDatesForSelectedAllProductVersions(product, duration, startDate, endDate);

        message response = {};
        messages:setJsonPayload(response, jsonResOfcategory);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-queued-age-graph"}

    resource queuedAgeGraph (message m,@http:QueryParam {value:"lastMonthDate"} string lastMonthDate) {
        json queuedAgeGraph = queuedAgeGraphGenerator(lastMonthDate);

        message response = {};
        messages:setJsonPayload(response, queuedAgeGraph);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-drilldown-age-graph/{group}/{month}"}

    resource drillDownQueuedAgeGraph (message m, @http:PathParam {value:"group"} string group, @http:PathParam {value:"month"} string month) {
        json drillDownQueuedAgeGraph = ageDrillDownGraph(group, month);

        message response = {};
        messages:setJsonPayload(response, drillDownQueuedAgeGraph);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-lifecycle-stack/{start}/{end}"}

    resource lifeCycleStack (message m, @http:PathParam {value:"start"} string start, @http:PathParam {value:"end"} string end) {
        json lifeCycleStackGraphs = lifeCycleStackGraph(start, end);

        message response = {};
        messages:setJsonPayload(response, lifeCycleStackGraphs);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-lifecycle-states/{product}/{start}/{end}"}

    resource lifeCycleTransitionGraph (message m, @http:PathParam {value:"product"} string product, @http:PathParam {value:"start"} string start, @http:PathParam {value:"end"} string end) {
        json lifeCycleStatesResponse = stateTransitionGraphOfLifeCycle(product, start, end);

        message response = {};
        messages:setJsonPayload(response, lifeCycleStatesResponse);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-lifecycle-states-patch/{patchID}/{eID}"}

    resource getSpecificPatchDetails (message m, @http:PathParam {value:"patchID"} string patchID, @http:PathParam {value:"eID"} string eID) {
        json onePatchLifeCycleStatesResponse = getSpecificPatchLifeCycle(patchID, eID);

        message response = {};
        messages:setJsonPayload(response, onePatchLifeCycleStatesResponse);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }
}

