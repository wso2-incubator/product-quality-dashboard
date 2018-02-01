package org.wso2.internalapps.pqd957;

import ballerina.net.http;



@http:configuration {
    basePath:"/internal/product-quality/v1.0/coverage",
    httpsPort:9096,
    keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword:"ballerina",
    certPassword:"ballerina",
    trustStoreFile:"${ballerina.home}/bre/security/ballerinaTruststore.p12",
    trustStorePassword:"ballerina",
    ciphers:"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
    sslEnabledProtocols:"TLSv1.2,TLSv1.1"
}
service<http> CoverageService {
    json configData = getConfigData(CONFIG_PATH);

    @http:resourceConfig {
        methods:["GET"],
        path:"/{category}/{categoryId}"
    }
    resource getCoverage(http:Request request, http:Response response,string category, string categoryId){
        var selected,_=<int>categoryId;
        json returnJson;
        if(category=="all"){
            returnJson = getAllAreaCoverage();
        }else if(category=="area"){
            returnJson=getSelectedAreaCoverage(selected);
        }else if(category=="product"){
            returnJson=getSelectedProductCoverage(selected);
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
    resource getCoverageHistory(http:Request request,http:Response response, string category, string categoryId){
        json returnJson;
        map params = request.getQueryParams();
        var start,_=(string)params.dateFrom;
        var end,_=(string)params.dateTo;
        var period,_=(string)params.period;
        var selected,_=<int>categoryId;
        if(category=="all"){
            if(period=="day"){
                returnJson=getDailyCoverageHistoryForAllArea(start,end);
            }else if(period=="Month"){
                returnJson=getMonthlyCoverageHistoryForAllArea(start,end);
            }else if(period=="Quarter"){
                returnJson=getQuarterlyCoverageHistoryForAllArea(start,end);
            }else if(period=="Year"){
                returnJson=getYearlyCoverageHistoryForAllArea(start,end);
            }else{
                returnJson={"error":true};
            }
        }else if(category=="area"){
            if(period=="day"){
                returnJson=getDailyCoverageHistoryForSelectedArea(selected,start,end);
            }else if(period=="Month"){
                returnJson=getMonthlyCoverageHistoryForSelectedArea(selected,start,end);
            }else if(period=="Quarter"){
                returnJson=getQuarterlyCoverageHistoryForSelectedArea(selected,start,end);
            }else if(period=="Year"){
                returnJson=getYearlyCoverageHistoryForSelectedArea(selected,start,end);
            }else{
                returnJson={"error":true};
            }
        }else if(category=="product"){
            if(period=="day"){
                returnJson=getDailyCoverageHistoryForSelectedProduct(selected,start,end);
            }else if(period=="Month"){
                returnJson=getMonthlyCoverageHistoryForSelectedProduct(selected,start,end);
            }else if(period=="Quarter"){
                returnJson=getQuarterlyCoverageHistoryForSelectedProduct(selected,start,end);
            }else if(period=="Year"){
                returnJson=getYearlyCoverageHistoryForSelectedProduct(selected,start,end);
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


