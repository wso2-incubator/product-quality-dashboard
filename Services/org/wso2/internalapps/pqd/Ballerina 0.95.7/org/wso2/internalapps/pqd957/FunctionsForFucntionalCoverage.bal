package org.wso2.internalapps.pqd957;

import ballerina.data.sql;

struct TestProjects{
    int pqd_product_id;
    string pqd_product_name;
    string testlink_project_name;
}

struct FunctionalCoverageDetails{
    string project_name;
    string test_plan_name;
    int total_features;
    int passed_features;
    int failed_features;
    int blocked_features;
    int not_run_features;
    float functional_coverage;
}

struct DailyFunctionalCoverage{
    string date;
    float total_features;
    float passed_features;
    float functional_coverage;
}

struct MonthlyFunctionalCoverage{
    int year;
    int month;
    float total_features;
    float passed_features;
    float functional_coverage;
}

struct QuarterlyFunctionalCoverage{
    int year;
    int quarter;
    float total_features;
    float passed_features;
    float functional_coverage;
}

struct YearlyFunctionalCoverage{
    int year;
    float total_features;
    float passed_features;
    float functional_coverage;
}



function getAllAreaFuncCoverage () (json) {
    endpoint<sql:ClientConnector> sqlEndPoint{}
    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json funcCoverage = {"items":[], "func_cov":{}};
    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_FUNCCOVERAGE_SNAPSHOT_ID,params,typeof CoverageSnapshots);
    CoverageSnapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (CoverageSnapshots)row;
        snapshot_id= ss.snapshot_id;
    }
    ssdt.close();

    int totalFeatures = 0; int passedFeatures = 0; float functionalCoverage = 0.0;

    datatable dt = sqlEndPoint.select(GET_ALL_AREAS, params,typeof Areas);
    Areas area;

    while(dt.hasNext()) {
        any row1 =dt.getNext();
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;

        int total_features = 0; int passed_features = 0; float functional_coverage = 0.0;

        sql:Parameter pqd_area_id_para = {sqlType:sql:Type.INTEGER, value:area_id};
        params = [pqd_area_id_para];
        datatable pdt = sqlEndPoint.select(GET_TESTLINKPRODUCT_OF_AREA, params,typeof TestProjects);
        TestProjects testProjects;
        while (pdt.hasNext()) {
            any row0 = pdt.getNext();
            testProjects, err = (TestProjects)row0;

            string test_project_name = testProjects.testlink_project_name;
            string product_name = testProjects.pqd_product_name;

            sql:Parameter test_project_name_para = {sqlType:sql:Type.VARCHAR, value:test_project_name};
            sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
            params = [test_project_name_para, snapshot_id_para];
            datatable fcdt = sqlEndPoint.select(GET_FUNC_COVERAGE_DETAILS, params,typeof FunctionalCoverageDetails);
            FunctionalCoverageDetails fcd;
            while (fcdt.hasNext()) {
                any row2 = fcdt.getNext();
                fcd, err = (FunctionalCoverageDetails)row2;
                total_features = fcd.total_features+ total_features;
                passed_features = fcd.passed_features + passed_features;
            }
            fcdt.close();
        }
        pdt.close();
        if(total_features != 0) {
            functional_coverage = ((float)passed_features / (float)total_features) * 100;
        }
        totalFeatures = totalFeatures + total_features;
        passedFeatures = passedFeatures + passed_features;

        json area_line_coverage = {"name":area_name, "id":area_id, "fc":{"total_features":total_features, "passed_features":passed_features,
                                                                            "functional_coverage":functional_coverage}};
        funcCoverage.items[lengthof funcCoverage.items] = area_line_coverage;
    }
    dt.close();
    if(totalFeatures != 0) {
        functionalCoverage = ((float)passedFeatures / (float)totalFeatures) * 100;
    }
    funcCoverage.func_cov = {"total_features":totalFeatures, "passed_features":passedFeatures, "functional_coverage":functionalCoverage};

    data.data= funcCoverage;
    sqlEndPoint.close();
    return data;
}

function getSelectedAreaFuncCoverage (int areaId) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint{}
    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json funcCoverage = {"items":[], "func_cov":{}};
    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_FUNCCOVERAGE_SNAPSHOT_ID,params,typeof CoverageSnapshots);
    CoverageSnapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (CoverageSnapshots)row;
        snapshot_id= ss.snapshot_id;
    }
    ssdt.close();

    int totalFeatures = 0; int passedFeatures = 0; float functionalCoverage = 0.0;

    sql:Parameter areaIdPara={sqlType:sql:Type.INTEGER,value:areaId};
    params=[areaIdPara];

    datatable pdt = sqlEndPoint.select(GET_TESTLINKPRODUCT_OF_AREA, params,typeof TestProjects);
    TestProjects projects;
    while (pdt.hasNext()) {
        any row0 = pdt.getNext();
        projects, err = (TestProjects)row0;
        int product_id = projects.pqd_product_id;
        string test_project_name = projects.testlink_project_name;
        string product_name = projects.pqd_product_name;

        int total_features = 0; int passed_features = 0; float functional_coverage = 0.0;

        sql:Parameter test_project_name_para = {sqlType:sql:Type.VARCHAR, value:test_project_name};
        sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
        params = [test_project_name_para, snapshot_id_para];
        datatable fcdt = sqlEndPoint.select(GET_FUNC_COVERAGE_DETAILS, params,typeof FunctionalCoverageDetails);
        FunctionalCoverageDetails fcd;
        while (fcdt.hasNext()) {
            any row2 = fcdt.getNext();
            fcd, err = (FunctionalCoverageDetails)row2;
            total_features = fcd.total_features + total_features;
            passed_features = fcd.passed_features + passed_features;
        }
        fcdt.close();
        if(total_features != 0) {
            functional_coverage = ((float)passed_features / (float)total_features) * 100;
        }
        totalFeatures = totalFeatures + total_features;
        passedFeatures = passedFeatures + passed_features;
        json product_line_coverage = {"name":product_name, "id":product_id, "fc":{"total_features":total_features, "passed_features":passed_features,
                                                                            "functional_coverage":functional_coverage}};
        funcCoverage.items[lengthof funcCoverage.items] = product_line_coverage;
    }
    pdt.close();
    if(totalFeatures != 0) {
        functionalCoverage = ((float)passedFeatures / (float)totalFeatures) * 100;
    }
    funcCoverage.func_cov = {"total_features":totalFeatures, "passed_features":passedFeatures, "functional_coverage":functionalCoverage};

    data.data= funcCoverage;
    sqlEndPoint.close();
    return data;
}

function getSelectedProductFuncCoverage (int productId) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint{}
    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json funcCoverage = {"items":[], "func_cov":{}};
    sql:Parameter[] params = [];

    datatable ssdt = sqlEndPoint.select(GET_FUNCCOVERAGE_SNAPSHOT_ID,params,typeof CoverageSnapshots);
    CoverageSnapshots ss;
    int snapshot_id;
    TypeCastError err;
    while (ssdt.hasNext()) {
        any row = ssdt.getNext();
        ss, err = (CoverageSnapshots)row;
        snapshot_id= ss.snapshot_id;
    }
    ssdt.close();

    int totalFeatures = 0; int passedFeatures = 0; float functionalCoverage = 0.0;
    string test_project_name;
    string product_name;
    sql:Parameter areaIdPara={sqlType:sql:Type.INTEGER,value:productId};
    params=[areaIdPara];

    datatable pdt = sqlEndPoint.select(GET_TESTLINKPRODUCT_OF_PRODUCT, params,typeof TestProjects);
    TestProjects projects;
    while (pdt.hasNext()) {
        any row0 = pdt.getNext();
        projects, err = (TestProjects)row0;

        test_project_name = projects.testlink_project_name;
        product_name = projects.pqd_product_name;
    }
    pdt.close();

    sql:Parameter test_project_name_para = {sqlType:sql:Type.VARCHAR, value:test_project_name};
    sql:Parameter snapshot_id_para = {sqlType:sql:Type.INTEGER, value:snapshot_id};
    params = [test_project_name_para, snapshot_id_para];
    datatable fcdt = sqlEndPoint.select(GET_FUNC_COVERAGE_DETAILS, params,typeof FunctionalCoverageDetails);
    FunctionalCoverageDetails fcd;
    while (fcdt.hasNext()) {
        any row2 = fcdt.getNext();
        fcd, err = (FunctionalCoverageDetails)row2;
        string test_plan_name=fcd.test_plan_name;
        int total_features = fcd.total_features;
        int passed_features = fcd.passed_features;
        float functional_coverage=0;
        if(total_features != 0) {
            functional_coverage = ((float)passed_features / (float)total_features) * 100;
        }
        totalFeatures = totalFeatures + total_features;
        passedFeatures = passedFeatures + passed_features;
        json product_line_coverage = {"name":test_plan_name, "id":test_project_name, "fc":{"total_features":total_features, "passed_features":passed_features,
                                                                                            "functional_coverage":functional_coverage}};
        funcCoverage.items[lengthof funcCoverage.items] = product_line_coverage;
    }
    fcdt.close();

    if(totalFeatures != 0) {
        functionalCoverage = ((float)passedFeatures / (float)totalFeatures) * 100;
    }
    funcCoverage.func_cov = {"total_features":totalFeatures, "passed_features":passedFeatures, "functional_coverage":functionalCoverage};

    data.data= funcCoverage;
    sqlEndPoint.close();
    return data;
}



function getDailyFuncCoverageHistoryForAllArea(string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreasFuncCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_ALL_AREA_DAILY_FUNC_COVERAGE, params,typeof DailyFunctionalCoverage);
    DailyFunctionalCoverage dfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        dfc, err = (DailyFunctionalCoverage)row;
        string date= dfc.date;
        float total_features= dfc.total_features;
        float passed_features= dfc.passed_features;
        float functional_coverage= dfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        allAreasFuncCoverage.data[lengthof allAreasFuncCoverage.data] = history;
    }
    fcdt.close();

    data.data= allAreasFuncCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyFuncCoverageHistoryForAllArea(string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreasFuncCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_ALL_AREA_MONTHLY_FUNC_COVERAGE, params,typeof MonthlyFunctionalCoverage);
    MonthlyFunctionalCoverage mfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        mfc, err = (MonthlyFunctionalCoverage )row;
        string date= mfc.year + "-" + mfc.month;
        float total_features = mfc.total_features;
        float passed_features = mfc.passed_features;
        float functional_coverage = mfc.functional_coverage;
        json history={"date":date,"total_features":total_features, "passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        allAreasFuncCoverage.data[lengthof allAreasFuncCoverage.data] = history;
    }
    fcdt.close();

    data.data= allAreasFuncCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyFuncCoverageHistoryForAllArea(string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreasFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_ALL_AREA_QUARTERLY_FUNC_COVERAGE, params,typeof QuarterlyFunctionalCoverage);
    QuarterlyFunctionalCoverage qfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        qfc, err = (QuarterlyFunctionalCoverage )row;
        string date= qfc.year + "-Q" + qfc.quarter;
        float total_features = qfc.total_features;
        float passed_features = qfc.passed_features;
        float functional_coverage = qfc.functional_coverage;
        json history={"date":date,"total_features":total_features, "passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        allAreasFunctionalCoverage.data[lengthof allAreasFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= allAreasFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyFuncCoverageHistoryForAllArea(string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreasFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_ALL_AREA_YEARLY_FUNC_COVERAGE, params,typeof YearlyFunctionalCoverage);
    YearlyFunctionalCoverage yfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        yfc, err = (YearlyFunctionalCoverage)row;
        var date=<string>yfc.year;
        float total_features = yfc.total_features;
        float passed_features = yfc.passed_features;
        float functional_coverage = yfc.functional_coverage;
        json history={"date":date,"total_features":total_features, "passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        allAreasFunctionalCoverage.data[lengthof allAreasFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= allAreasFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getDailyFuncCoverageHistoryForSelectedArea(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json areaFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_SELECTED_AREA_DAILTY_FUNC_COVERAGE, params,typeof DailyFunctionalCoverage);
    DailyFunctionalCoverage dfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        dfc, err = (DailyFunctionalCoverage)row;
        string date= dfc.date;
        float total_features= dfc.total_features;
        float passed_features= dfc.passed_features;
        float functional_coverage= dfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        areaFunctionalCoverage.data[lengthof areaFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= areaFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyFuncCoverageHistoryForSelectedArea(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json areaFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_SELECTED_AREA_MONTHLY_FUNC_COVERAGE, params,typeof MonthlyFunctionalCoverage);
    MonthlyFunctionalCoverage mfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        mfc, err = (MonthlyFunctionalCoverage)row;
        string date= mfc.year + "-" + mfc.month;
        float total_features= mfc.total_features;
        float passed_features= mfc.passed_features;
        float functional_coverage= mfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        areaFunctionalCoverage.data[lengthof areaFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= areaFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyFuncCoverageHistoryForSelectedArea(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json areaFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_SELECTED_AREA_QUARTERLY_FUNC_COVERAGE, params,typeof QuarterlyFunctionalCoverage);
    QuarterlyFunctionalCoverage qfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        qfc, err = (QuarterlyFunctionalCoverage)row;
        string date= qfc.year + "-Q" + qfc.quarter;
        float total_features= qfc.total_features;
        float passed_features= qfc.passed_features;
        float functional_coverage= qfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        areaFunctionalCoverage.data[lengthof areaFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= areaFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyFuncCoverageHistoryForSelectedArea(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json areaFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_SELECTED_AREA_YEARLY_FUNC_COVERAGE, params,typeof YearlyFunctionalCoverage);
    YearlyFunctionalCoverage yfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        yfc, err = (YearlyFunctionalCoverage)row;
        var date=<string>yfc.year;
        float total_features= yfc.total_features;
        float passed_features= yfc.passed_features;
        float functional_coverage= yfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        areaFunctionalCoverage.data[lengthof areaFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= areaFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getDailyFuncCoverageHistoryForSelectedProduct(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json productFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_SELECTED_PRODUCT_DAILTY_FUNC_COVERAGE, params,typeof DailyFunctionalCoverage);
    DailyFunctionalCoverage dfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        dfc, err = (DailyFunctionalCoverage )row;
        string date= dfc.date;
        float total_features= dfc.total_features;
        float passed_features= dfc.passed_features;
        float functional_coverage= dfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        productFunctionalCoverage.data[lengthof productFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= productFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyFuncCoverageHistoryForSelectedProduct(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json productFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_SELECTED_PRODUCT_MONTHLY_FUNC_COVERAGE, params,typeof MonthlyFunctionalCoverage);
    DailyFunctionalCoverage dfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        dfc, err = (DailyFunctionalCoverage)row;
        string date= dfc.date;
        float total_features= dfc.total_features;
        float passed_features= dfc.passed_features;
        float functional_coverage= dfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        productFunctionalCoverage.data[lengthof productFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= productFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyFuncCoverageHistoryForSelectedProduct(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json productFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_SELECTED_PRODUCT_QUARTERLY_FUNC_COVERAGE, params,typeof QuarterlyFunctionalCoverage);
    QuarterlyFunctionalCoverage qfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        qfc, err = (QuarterlyFunctionalCoverage)row;
        string date= qfc.year + "-Q" + qfc.quarter;
        float total_features= qfc.total_features;
        float passed_features= qfc.passed_features;
        float functional_coverage= qfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        productFunctionalCoverage.data[lengthof productFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= productFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyFuncCoverageHistoryForSelectedProduct(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json productFunctionalCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable fcdt = sqlEndPoint.select(GET_SELECTED_PRODUCT_YEARLY_FUNC_COVERAGE, params,typeof YearlyFunctionalCoverage);
    YearlyFunctionalCoverage yfc;
    while(fcdt.hasNext()) {
        any row= fcdt.getNext();
        yfc, err = (YearlyFunctionalCoverage)row;
        var date=<string>yfc.year;
        float total_features= yfc.total_features;
        float passed_features= yfc.passed_features;
        float functional_coverage= yfc.functional_coverage;
        json history={"date":date,"total_features":total_features,"passed_features":passed_features,
                         "functional_coverage":functional_coverage};
        productFunctionalCoverage.data[lengthof productFunctionalCoverage.data] = history;
    }
    fcdt.close();

    data.data= productFunctionalCoverage.data;
    sqlEndPoint.close();
    return data;
}
