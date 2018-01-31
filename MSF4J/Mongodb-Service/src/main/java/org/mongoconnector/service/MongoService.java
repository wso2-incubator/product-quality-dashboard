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

package org.mongoconnector.service;


import org.slf4j.LoggerFactory;
import org.wso2.msf4j.MicroservicesRunner;

import javax.ws.rs.GET;
import javax.ws.rs.Path;


/**
 * This is the Microservice resource class.
 * See <a href="https://github.com/wso2/msf4j#getting-started">https://github.com/wso2/msf4j#getting-started</a>
 * for the usage of annotations.
 *
 * @since 0.1-SNAPSHOT
 */
@Path("/jenkins-get-build-data")
public class MongoService {

    private static final org.slf4j.Logger log = LoggerFactory.getLogger(MicroservicesRunner.class);
    DatabaseConnector databaseCon = new DatabaseConnector();
//    MongoDbConnector mongo = new MongoDbConnector();

    @GET
    @Path("/get-failure-reasons")
    public String get() {
        log.info("FAILURE REASONS UPDATE FROM MONGODB JOB STARTED");
        databaseCon.getJobDatafromDatabase();
//          String db = mongo.getReasongsFromDatabase("carbon-analytics",2198);

        log.info("FAILURE REASONS UPDATE FROM MONGODB JOB FINISHED");
        return "Process Completed \n";
    }
}
