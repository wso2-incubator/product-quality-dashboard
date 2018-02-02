/*
 * Copyright (c) 2016, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
var authorizationUtil = Packages.org.wso2.carbon.dashboard.authorization.util.AuthorizationUtil;
var log = new Log();

/**
 * To check whether the given user has the required permission access a specific section
 * @param permission
 * @returns {boolean} true if the user has the required permission otherwise false
 */
var isAllowed = function (permission) {
    log.info("UPPER ONE - isAllowed");
    log.info(user.tenantId);
    log.info(user.username);
    log.info(permission);
    log.info(authorizationUtil.isUserAuthorized(user.tenantId, user.username, permission));

    //bellow return is need to comment due to no any LDAP connected
    //return authorizationUtil.isUserAuthorized(user.tenantId, user.username, permission);

    //since there is no any LDAP connection by pass above return
    return true;
};

/**
 * To check whether the given user has the required permission access a specific section
 * @param permission
 * @returns {boolean} true if the user has the required permission otherwise false
 */
var isAllowedUser = function (userObj, permission) {
    log.info("LOWER ONE - isAllowedUser");
    log.info(userObj.tenantId);
    log.info(userObj.username);
    log.info(permission);
    log.info(authorizationUtil.isUserAuthorized(userObj.tenantId, userObj.username, permission));

    //bellow return is need to comment due to no any LDAP connected
    //return authorizationUtil.isUserAuthorized(userObj.tenantId, userObj.username, permission);

    //since there is no any LDAP connection by pass above return
    return true;
};
