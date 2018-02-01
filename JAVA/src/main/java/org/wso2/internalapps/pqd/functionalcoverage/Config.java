package org.wso2.internalapps.pqd.functionalcoverage;

public class Config {
    private String testLinkUrl;
    private String devKey;
    private String dbUrl;
    private String dbName;
    private String dbUserName;
    private String dbPassword;

    public String getTestLinkUrl() {
        return testLinkUrl;
    }

    public void setTestLinkUrl(String testLinkUrl) {
        this.testLinkUrl = testLinkUrl;
    }

    public String getDevKey() {
        return devKey;
    }

    public void setDevKey(String devKey) {
        this.devKey = devKey;
    }

    public String getDbUrl() {
        return dbUrl;
    }

    public void setDbUrl(String dbUrl) {
        this.dbUrl = dbUrl;
    }

    public String getDbName() {
        return dbName;
    }

    public void setDbName(String dbName) {
        this.dbName = dbName;
    }

    public String getDbUserName() {
        return dbUserName;
    }

    public void setDbUserName(String dbUserName) {
        this.dbUserName = dbUserName;
    }

    public String getDbPassword() {
        return dbPassword;
    }

    public void setDbPassword(String dbPassword) {
        this.dbPassword = dbPassword;
    }
}
