package org.wso2.internalapps.pqd957;

struct CoverageSnapshots {
    int snapshot_id;
}
struct Areas{
    int pqd_area_id;
    string pqd_area_name;
}

function getAllAreaCoverage()(json){
    json lineCoverageJson=getAllAreaLineCoverage();
    json functionalCoverageJson=getAllAreaFuncCoverage();
    json data = {"error":false, "data":{}};
    json coverageJson = {"items":[], "line_cov":{}, "func_cov":{}};
    int loopSize =lengthof lineCoverageJson.data.items;
    int index=0;

    while (index<loopSize) {
        json item={"name":lineCoverageJson.data.items[index].name,"id":lineCoverageJson.data.items[index].id,
                  "lc":lineCoverageJson.data.items[index].lc,"fc":functionalCoverageJson.data.items[index].fc};
        coverageJson.items[index] = item;

        index=index+1;
    }
    coverageJson.line_cov =lineCoverageJson.data.line_cov;
    coverageJson.func_cov=functionalCoverageJson.data.func_cov;
    data.data = coverageJson;
    return data;
}

function getSelectedAreaCoverage(int areaId)(json){
    json lineCoverageJson=getSelectedAreaLineCoverage(areaId);
    json functionalCoverageJson=getSelectedAreaFuncCoverage(areaId);
    json data={"error":false,"data":{}};
    json coverageJson = {"items":[], "line_cov":{}, "func_cov":{}};
    int loopSize =lengthof lineCoverageJson.data.items;
    int index=0;

    while (index<loopSize) {
        json item={"name":lineCoverageJson.data.items[index].name,"id":lineCoverageJson.data.items[index].id,
                      "lc":lineCoverageJson.data.items[index].lc,"fc":functionalCoverageJson.data.items[index].fc};
        coverageJson.items[index] = item;

        index=index+1;
    }
    coverageJson.line_cov =lineCoverageJson.data.line_cov;
    coverageJson.func_cov=functionalCoverageJson.data.func_cov;
    data.data = coverageJson;
    return data;
}

function getSelectedProductCoverage(int productId)(json){
    json lineCoverageJson=getSelectedProductLineCoverage(productId);
    json functionalCoverageJson=getSelectedProductFuncCoverage(productId);
    json data = {"error":false, "data":{}};
    json coverageJson = {"lc_items":[], "fc_items":[], "line_cov":{}, "func_cov":{}};
    coverageJson.lc_items = lineCoverageJson.data.items;
    coverageJson.fc_items = functionalCoverageJson.data.items;
    coverageJson.line_cov = lineCoverageJson.data.line_cov;
    coverageJson.func_cov = functionalCoverageJson.data.func_cov;
    data.data = coverageJson;
    return data;
}


function getDailyCoverageHistoryForAllArea (string start, string end) (json) {
    json lineCoverageJson=getDailyLineCoverageHistoryForAllArea(start,end);
    json functionalCoverageJson=getDailyFuncCoverageHistoryForAllArea(start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getMonthlyCoverageHistoryForAllArea (string start, string end) (json) {
    json lineCoverageJson=getMonthlyLineCoverageHistoryForAllArea(start,end);
    json functionalCoverageJson=getMonthlyFuncCoverageHistoryForAllArea(start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getQuarterlyCoverageHistoryForAllArea (string start, string end) (json) {
     json lineCoverageJson=getQuarterlyLineCoverageHistoryForAllArea(start,end);
     json functionalCoverageJson=getQuarterlyFuncCoverageHistoryForAllArea(start,end);
     json data = {"error":false, "data":[]};
     json coverageJson={"lc":[],"fc":[]};
     coverageJson.lc=lineCoverageJson.data;
     coverageJson.fc=functionalCoverageJson.data;
     data.data=coverageJson;
     return data;
}

function getYearlyCoverageHistoryForAllArea (string start, string end) (json) {
    json lineCoverageJson=getYearlyLineCoverageHistoryForAllArea(start,end);
    json functionalCoverageJson=getYearlyFuncCoverageHistoryForAllArea(start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getDailyCoverageHistoryForSelectedArea (int selected,string start, string end) (json) {
    json lineCoverageJson=getDailyLineCoverageHistoryForSelectedArea(selected,start,end);
    json functionalCoverageJson=getDailyFuncCoverageHistoryForSelectedArea(selected,start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getMonthlyCoverageHistoryForSelectedArea (int selected,string start, string end) (json) {
    json lineCoverageJson=getMonthlyLineCoverageHistoryForSelectedArea(selected,start,end);
    json functionalCoverageJson=getMonthlyFuncCoverageHistoryForSelectedArea(selected,start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getQuarterlyCoverageHistoryForSelectedArea (int selected,string start, string end) (json) {
    json lineCoverageJson=getQuarterlyLineCoverageHistoryForSelectedArea(selected,start,end);
    json functionalCoverageJson=getQuarterlyFuncCoverageHistoryForSelectedArea(selected,start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getYearlyCoverageHistoryForSelectedArea (int selected,string start, string end) (json) {
    json lineCoverageJson=getYearlyLineCoverageHistoryForSelectedArea(selected,start,end);
    json functionalCoverageJson=getYearlyFuncCoverageHistoryForSelectedArea(selected,start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getDailyCoverageHistoryForSelectedProduct (int selected,string start, string end) (json) {
    json lineCoverageJson=getDailyLineCoverageHistoryForSelectedProduct(selected,start,end);
    json functionalCoverageJson=getDailyFuncCoverageHistoryForSelectedProduct(selected,start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getMonthlyCoverageHistoryForSelectedProduct (int selected,string start, string end) (json) {
    json lineCoverageJson=getMonthlyLineCoverageHistoryForSelectedProduct(selected,start,end);
    json functionalCoverageJson=getMonthlyFuncCoverageHistoryForSelectedProduct(selected,start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getQuarterlyCoverageHistoryForSelectedProduct (int selected,string start, string end) (json) {
    json lineCoverageJson=getQuarterlyLineCoverageHistoryForSelectedProduct(selected,start,end);
    json functionalCoverageJson=getQuarterlyFuncCoverageHistoryForSelectedProduct(selected,start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}

function getYearlyCoverageHistoryForSelectedProduct (int selected,string start, string end) (json) {
    json lineCoverageJson=getYearlyLineCoverageHistoryForSelectedProduct(selected,start,end);
    json functionalCoverageJson=getYearlyFuncCoverageHistoryForSelectedProduct(selected,start,end);
    json data = {"error":false, "data":[]};
    json coverageJson={"lc":[],"fc":[]};
    coverageJson.lc=lineCoverageJson.data;
    coverageJson.fc=functionalCoverageJson.data;
    data.data=coverageJson;
    return data;
}
