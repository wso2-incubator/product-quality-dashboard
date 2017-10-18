package services;


import ballerina.lang.messages;
import org.wso2.ballerina.connectors.basicauth;



function getCycles(string path, int limit)(int){
    basicauth:ClientConnector redmineConnector = create basicauth:ClientConnector("https://redmine.wso2.com/",
                                                                                  conf:rmUsername,conf:rmPassword);

    message msg1={};
    message res1={};
    res1 = redmineConnector.get(path, msg1);
    json jsn1=messages:getJsonPayload(res1);
    var count,_ =(int)jsn1.total_count;

    var remainder= count%limit;
    var cycles= (int)(count/limit);


    if(remainder==0){
        return cycles;
    }else{
        return cycles+1;
    }

}


