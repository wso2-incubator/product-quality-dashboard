/*
 * Copyright (c) 2016, WSO2 Inc. (http://wso2.com) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.jenkinsdashboard.service;

import com.google.gson.JsonObject;
import org.slf4j.LoggerFactory;
import org.wso2.msf4j.MicroservicesRunner;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 * This is the Microservice resource class.
 * See <a href="https://github.com/wso2/msf4j#getting-started">https://github.com/wso2/msf4j#getting-started</a>
 * for the usage of annotations.
 *
 * @since 0.1
 */
@Path("/jenkins-get-build-data")
public class MainService {

    private static final org.slf4j.Logger log = LoggerFactory.getLogger(MicroservicesRunner.class);
    DatabaseConnectivity databaseCon = new DatabaseConnectivity();

    @POST
    @Path("/update-jenkins-dashboard-db/{productArea}/{component}")
    public String get(@PathParam("productArea") String productArea, @PathParam("component") String component, JsonObject payload) {

        log.info("NEW COMPONENT INSERT JOB STARTED");

        String TOKEN = payload.get("TOKEN").getAsString();
        String result = "";

        if(TOKEN.equals("7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8")){
            result = databaseCon.insertDBWithComponent(productArea, component);
        }

        if(result.equals("done")){
            log.info(component+"- ADDED TO DATABASE SUCCESSFULLY");
        }else{
            log.info(component+"- ADDING TO DATABASE FAILED");
        }
        log.info("NEW COMPONENT INSERT JOB FINISHED");

        return "Process Completed \n";

    }

}
