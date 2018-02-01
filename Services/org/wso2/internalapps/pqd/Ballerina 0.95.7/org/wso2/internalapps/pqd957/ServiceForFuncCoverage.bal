package org.wso2.internalapps.pqd957;

import ballerina.net.http;

@http:configuration {
    basePath:"/internal/product-quality/v1.0/functional-coverage",
    httpsPort:9096,
    keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword:"ballerina",
    certPassword:"ballerina",
    trustStoreFile:"${ballerina.home}/bre/security/ballerinaTruststore.p12",
    trustStorePassword:"ballerina",
    ciphers:"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
    sslEnabledProtocols:"TLSv1.2,TLSv1.1"
}
service<http> FunctionalCoverageService {
    json configData = getConfigData(CONFIG_PATH);

    @http:resourceConfig {
        methods:["GET"],
        path:"/{category}/{categoryId}"
    }
    resource getFunctionalCoverage(http:Request request, http:Response response,string category, string categoryId){
        var selected,_=<int>categoryId;
        json returnJson;
        if(category=="all"){
            returnJson = getAllAreaFuncCoverage();
        }else if(category=="area"){
            returnJson=getSelectedAreaFuncCoverage(selected);
        }else if(category=="product"){
            returnJson=getSelectedProductFuncCoverage(selected);
        }else{
            returnJson={"error":true};
        }

        response.setJsonPayload(returnJson);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/history/{category}/{categoryId}"
    }
    resource getFunctionalCoverageHistory(http:Request request,http:Response response, string category, string categoryId){
        json returnJson;
        map params = request.getQueryParams();
        var start,_=(string)params.dateFrom;
        var end,_=(string)params.dateTo;
        var period,_=(string)params.period;
        var selected,_=<int>categoryId;
        if(category=="all"){
            if(period=="day"){
                returnJson=getDailyFuncCoverageHistoryForAllArea(start,end);
            }else if(period=="Month"){
                returnJson=getMonthlyFuncCoverageHistoryForAllArea(start,end);
            }else if(period=="Quarter"){
                returnJson=getQuarterlyFuncCoverageHistoryForAllArea(start,end);
            }else if(period=="Year"){
                returnJson=getYearlyFuncCoverageHistoryForAllArea(start,end);
            }else{
                returnJson={"error":true};
            }
        }else if(category=="area"){
            if(period=="day"){
                returnJson=getDailyFuncCoverageHistoryForSelectedArea(selected,start,end);
            }else if(period=="Month"){
                returnJson=getMonthlyFuncCoverageHistoryForSelectedArea(selected,start,end);
            }else if(period=="Quarter"){
                returnJson=getQuarterlyFuncCoverageHistoryForSelectedArea(selected,start,end);
            }else if(period=="Year"){
                returnJson=getYearlyFuncCoverageHistoryForSelectedArea(selected,start,end);
            }else{
                returnJson={"error":true};
            }
        }else if(category=="product"){
            if(period=="day"){
                returnJson=getDailyFuncCoverageHistoryForSelectedProduct(selected,start,end);
            }else if(period=="Month"){
                returnJson=getMonthlyFuncCoverageHistoryForSelectedProduct(selected,start,end);
            }else if(period=="Quarter"){
                returnJson=getQuarterlyFuncCoverageHistoryForSelectedProduct(selected,start,end);
            }else if(period=="Year"){
                returnJson=getYearlyFuncCoverageHistoryForSelectedProduct(selected,start,end);
            }else{
                returnJson={"error":true};
            }
        }else{
            returnJson={"error":true};
        }

        response.setJsonPayload(returnJson);
        response.setHeader("Access-Control-Allow-Origin", "*");
        _ = response.send();
    }
}