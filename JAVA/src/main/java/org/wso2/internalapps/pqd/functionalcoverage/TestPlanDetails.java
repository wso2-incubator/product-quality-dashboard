package org.wso2.internalapps.pqd.functionalcoverage;

public class TestPlanDetails {
    private String projectName;
    private String testPlanName;
    private int numberofPassedTestCases;
    private int numberofFailedTestCases;
    private int numberofBlockedTestCases;
    private int numberofNotRunTestCases;
    private int totalNumberofTestCases;

    public TestPlanDetails(String projectName, String testPlanName, int numberofPassedTestCases,
                           int numberofFailedTestCases, int numberofBlockedTestCases, int numberofNotRunTestCases,
                           int totalNumberofTestCases) {
        this.projectName = projectName;
        this.testPlanName = testPlanName;
        this.numberofPassedTestCases = numberofPassedTestCases;
        this.numberofFailedTestCases = numberofFailedTestCases;
        this.numberofBlockedTestCases = numberofBlockedTestCases;
        this.numberofNotRunTestCases = numberofNotRunTestCases;
        this.totalNumberofTestCases = totalNumberofTestCases;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getTestPlanName() {
        return testPlanName;
    }

    public void setTestPlanName(String testPlanName) {
        this.testPlanName = testPlanName;
    }

    public int getNumberofPassedTestCases() {
        return numberofPassedTestCases;
    }

    public void setNumberofPassedTestCases(int numberofPassedTestCases) {
        this.numberofPassedTestCases = numberofPassedTestCases;
    }

    public int getNumberofFailedTestCases() {
        return numberofFailedTestCases;
    }

    public void setNumberofFailedTestCases(int numberofFailedTestCases) {
        this.numberofFailedTestCases = numberofFailedTestCases;
    }

    public int getNumberofBlockedTestCases() {
        return numberofBlockedTestCases;
    }

    public void setNumberofBlockedTestCases(int numberofBlockedTestCases) {
        this.numberofBlockedTestCases = numberofBlockedTestCases;
    }

    public int getNumberofNotRunTestCases() {
        return numberofNotRunTestCases;
    }

    public void setNumberofNotRunTestCases(int numberofNotRunTestCases) {
        this.numberofNotRunTestCases = numberofNotRunTestCases;
    }

    public int getTotalNumberofTestCases() {
        return totalNumberofTestCases;
    }

    public void setTotalNumberofTestCases(int totalNumberofTestCases) {
        this.totalNumberofTestCases = totalNumberofTestCases;
    }


}
