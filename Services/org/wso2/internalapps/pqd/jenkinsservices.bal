package org.wso2.internalapps.pqd;

import ballerina.lang.messages;
import ballerina.net.http;


@http:configuration {
    basePath:"/jenkins-get-build-data",
    httpsPort:9092,
    keyStoreFile:"${ballerina.home}/bre/security/wso2carbon.jks",
    keyStorePass:"wso2carbon",
    certPass:"wso2carbon"
}

service<http> jenkinsServices {

    @http:GET {}
    @http:Path {value:"/daily-job"}

    resource publishDataToStreamProcessor (message m) {
        json publishMessage = getBuildDataFromJenkinsAndGithub();

        message response = {};
        messages:setJsonPayload(response, publishMessage);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/new-component/{product}/{component}/{organization}"}

    resource newJobCreatedInJenkins (message m, @http:PathParam {value:"product"} string product, @http:PathParam {value:"component"} string component, @http:PathParam {value:"organization"} string organization) {
        json payload = messages:getJsonPayload(m);
        var token,_ = (string)payload.TOKEN;

        if(token == "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8") {
            insertNewComponent(product, component, organization);
        }
        message response = {};
        messages:setStringPayload(response, "NEW COMPONENT "+component+" ADDED TO THE DATABASE");
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/new-folder-map/{component}/{folder}"}

    resource folderMapInJenkins (message m, @http:PathParam {value:"component"} string component, @http:PathParam {value:"folder"} string folder) {
        json payload = messages:getJsonPayload(m);
        var token,_ = (string)payload.TOKEN;

        if(token == "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8") {
            insertNewFolderComponentMapping(component, folder);
        }

        message response = {};
        messages:setStringPayload(response, "NEW FOLDER-COMPONENT MAPPING of "+component+" ADDED TO THE DATABASE");
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/load-jenkins-dashboard/{startDate}/{endDate}"}

    resource loadJenkinsDashboard (message m, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {

        message response = {};
        json mainJson = loadJenkinsBuildDataDashboard(startDate,endDate);

        messages:setJsonPayload(response, mainJson);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/area-popup/{area}/{startDate}/{endDate}"}

    resource loadDataForArea (message m,  @http:PathParam {value:"area"} string area, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json mainJson = loadDataForProductArea(startDate,endDate,area);

        message response = {};
        messages:setJsonPayload(response, mainJson);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/component-culprits/{area}/{component}/{startDate}/{endDate}"}

    resource loadCulpritsForComponent (message m,  @http:PathParam {value:"area"} string area,@http:PathParam {value:"component"} string component, @http:PathParam {value:"startDate"} string startDate, @http:PathParam {value:"endDate"} string endDate) {
        json mainJson = loadDataOfCulpritsForComponent(startDate,endDate,area,component);

        message response = {};
        messages:setJsonPayload(response, mainJson);
        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

    @http:POST {}
    @http:Path {value:"/update-folder-mapping/{component}/{folderBefore}/{folderAfter}"}

    resource updateFolderMapInJenkins (message m, @http:PathParam {value:"component"} string component, @http:PathParam {value:"folderBefore"} string folderBefore, @http:PathParam {value:"folderAfter"} string folderAfter) {
        json payload = messages:getJsonPayload(m);
        var token,_ = (string)payload.TOKEN;
        message response = {};

        if(token == "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8"){
            updateFolderComponentMapping(component,folderBefore,folderAfter);
            messages:setStringPayload(response, "UPDATE FOLDER-COMPONENT MAPPING of "+component+" UPDATED IN THE DATABASE\n");
        }else{
            messages:setStringPayload(response, "SENT TOKEN IS INVALID \n");
        }

        messages:setHeader(response, "Access-Control-Allow-Origin", "*");
        reply response;
    }

}
