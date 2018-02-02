package org.wso2.internalapps.pqd957;

import ballerina.util;
import ballerina.data.sql;
import ballerina.log;
import ballerina.net.http;


struct Components{
    int pqd_component_id;
    string pqd_component_name;
    int pqd_product_id;
    string sonar_project_key;
}

struct Products{
    int pqd_product_id;
    string pqd_product_name;
}


struct LineCoverageDetails{
    int lines_to_cover;
    int covered_lines;
    int uncovered_lines;
    float line_coverage;
}
struct DailyLineCoverage{
    string date;
    float lines_to_cover;
    float covered_lines;
    float uncovered_lines;
    float line_coverage;
}

struct MonthlyLineCoverage{
    int year;
    int month;
    float lines_to_cover;
    float covered_lines;
    float uncovered_lines;
    float line_coverage;
}

struct QuarterlyLineCoverage{
    int year;
    int quarter;
    float lines_to_cover;
    float covered_lines;
    float uncovered_lines;
    float line_coverage;
}

struct YearlyLineCoverage{
    int year;
    float lines_to_cover;
    float covered_lines;
    float uncovered_lines;
    float line_coverage;
}

function getAllAreaLineCoverage () (json) {
    endpoint<sql:ClientConnector> sqlEndPoint{}
    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json lineCoverage = {"items":[],"line_cov":{}};
    sql:Parameter[] params = [];

    TypeCastError err;

    int allAreaLinesToCover=0; int allAreaCoveredLines=0; int allAreaUncoveredLines=0; float allAreaLineCoverage=0.0;

    Areas area;
    datatable dt = sqlEndPoint.select(GET_ALL_AREAS, params,typeof Areas);
    while(dt.hasNext()) {
        any row1 =dt.getNext();
        area, err = (Areas)row1;

        string area_name = area.pqd_area_name;
        int area_id = area.pqd_area_id;

        int lines_to_cover=0; int covered_lines=0; int uncovered_lines=0; float line_coevrage=0.0;

        sql:Parameter area_id_para = {sqlType:sql:Type.INTEGER, value:area_id};
        params = [area_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_AREA , params,typeof Components);
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string component_name = comps.pqd_component_name;
            int component_id = comps.pqd_component_id;

            sql:Parameter component_name_para = {sqlType:sql:Type.VARCHAR, value:component_name};
            sql:Parameter component_id_para = {sqlType:sql:Type.INTEGER, value:component_id};
            params = [component_name_para,component_id_para];
            datatable ldt = sqlEndPoint.select(GET_LINE_COVERAGE_DETAILS, params,typeof LineCoverageDetails);
            LineCoverageDetails lcd;
            while (ldt.hasNext()) {
                any row2 = ldt.getNext();
                lcd, err = (LineCoverageDetails )row2;
                lines_to_cover=lcd.lines_to_cover+lines_to_cover;
                covered_lines=lcd.covered_lines+covered_lines;
                uncovered_lines=lcd.uncovered_lines+uncovered_lines;
            }
            ldt.close();
        }
        cdt.close();
        if(lines_to_cover!=0){
            line_coevrage=((float)covered_lines/(float)lines_to_cover)*100;
        }
        allAreaLinesToCover=allAreaLinesToCover+lines_to_cover;
        allAreaCoveredLines=allAreaCoveredLines+covered_lines;
        allAreaUncoveredLines=allAreaUncoveredLines+uncovered_lines;

        json area_line_coverage = {"name":area_name, "id":area_id, "lc":{"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                                                                            "uncovered_lines":uncovered_lines,"line_coverage":line_coevrage}};
        lineCoverage.items[lengthof lineCoverage.items]=area_line_coverage;
    }
    dt.close();
    if(allAreaLinesToCover!=0){
        allAreaLineCoverage=((float)allAreaCoveredLines /(float)allAreaLinesToCover) * 100;
    }
    lineCoverage.line_cov= {"lines_to_cover":allAreaLinesToCover,"covered_lines":allAreaCoveredLines,
                               "uncovered_lines":allAreaUncoveredLines,"line_coverage":allAreaLineCoverage};


    data.data=lineCoverage;
    sqlEndPoint.close();
    return data;
}

function getSelectedAreaLineCoverage (int areaId) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint{}
    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json lineCoverage = {"items":[],"line_cov":{}};
    sql:Parameter[] params = [];

    TypeCastError err;

    sql:Parameter areaIdPara={sqlType:sql:Type.INTEGER,value:areaId};
    params=[areaIdPara];

    int selectedAreaLinesToCover = 0; int selectedAreaCoveredLines = 0;
    int selectedAreaUncoveredLines = 0; float selectedAreaLineCoverage = 0.0;

    datatable dt = sqlEndPoint.select(GET_PRODUCTS_OF_AREA, params,typeof Products);
    Products product;

    while(dt.hasNext()) {
        any row1 =dt.getNext();
        product, err = (Products)row1;

        string product_name = product.pqd_product_name;
        int product_id = product.pqd_product_id;

        int lines_to_cover=0; int covered_lines=0; int uncovered_lines=0; float line_coevrage=0.0;

        sql:Parameter pqd_product_id_para = {sqlType:sql:Type.INTEGER, value:product_id};
        params = [pqd_product_id_para];
        datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT , params,typeof Components );
        Components comps;
        while (cdt.hasNext()) {
            any row0 = cdt.getNext();
            comps, err = (Components)row0;

            string component_name = comps.pqd_component_name;
            int component_id = comps.pqd_component_id;

            sql:Parameter component_name_para = {sqlType:sql:Type.VARCHAR, value:component_name};
            sql:Parameter component_id_para = {sqlType:sql:Type.INTEGER, value:component_id};
            params = [component_name_para,component_id_para];
            datatable ldt = sqlEndPoint.select(GET_LINE_COVERAGE_DETAILS, params,typeof LineCoverageDetails);
            LineCoverageDetails lcd;
            while (ldt.hasNext()) {
                any row2 = ldt.getNext();
                lcd, err = (LineCoverageDetails )row2;
                lines_to_cover=lcd.lines_to_cover+lines_to_cover;
                covered_lines=lcd.covered_lines+covered_lines;
                uncovered_lines=lcd.uncovered_lines+uncovered_lines;
            }
            ldt.close();
        }
        cdt.close();
        if(lines_to_cover!=0){
            line_coevrage=((float)covered_lines/(float)lines_to_cover)*100;
        }
        selectedAreaLinesToCover = selectedAreaLinesToCover + lines_to_cover;
        selectedAreaCoveredLines = selectedAreaCoveredLines + covered_lines;
        selectedAreaUncoveredLines = selectedAreaUncoveredLines + uncovered_lines;

        json product_line_coverage = {"name":product_name, "id":product_id, "lc":{"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                                                                                     "uncovered_lines":uncovered_lines,"line_coverage":line_coevrage}};
        lineCoverage.items[lengthof lineCoverage.items]=product_line_coverage;
    }
    dt.close();
    if(selectedAreaLinesToCover != 0) {
        selectedAreaLineCoverage = ((float)selectedAreaCoveredLines / (float)selectedAreaLinesToCover) * 100;
    }
    lineCoverage.line_cov= {"lines_to_cover":selectedAreaLinesToCover, "covered_lines":selectedAreaCoveredLines,
                               "uncovered_lines":selectedAreaUncoveredLines, "line_coverage":selectedAreaLineCoverage};


    data.data=lineCoverage;
    sqlEndPoint.close();
    return data;
}

function getSelectedProductLineCoverage (int productId) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint{}
    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json lineCoverage = {"items":[],"line_cov":{}};
    sql:Parameter[] params = [];

    TypeCastError err;

    int selectedProductLinesToCover = 0; int selectedProductCoveredLines = 0;
    int selectedProductUncoveredLines = 0; float selectedProductLineCoverage = 0.0;

    sql:Parameter product_id_para = {sqlType:sql:Type.INTEGER, value:productId};
    params = [product_id_para];
    datatable cdt = sqlEndPoint.select(GET_COMPONENT_OF_PRODUCT , params,typeof Components);
    Components comps;
    while (cdt.hasNext()) {
        any row0 = cdt.getNext();
        comps, err = (Components)row0;

        string component_name = comps.pqd_component_name;
        int component_id = comps.pqd_component_id;

        int lines_to_cover=0; int covered_lines=0; int uncovered_lines=0; float line_coevrage=0.0;

        sql:Parameter component_name_para = {sqlType:sql:Type.VARCHAR, value:component_name};
        sql:Parameter component_id_para = {sqlType:sql:Type.VARCHAR, value:component_id};
        params = [component_name_para,component_id_para];
        datatable ldt = sqlEndPoint.select(GET_LINE_COVERAGE_DETAILS, params,typeof LineCoverageDetails);
        LineCoverageDetails lcd;
        while (ldt.hasNext()) {
            any row2 = ldt.getNext();
            lcd, err = (LineCoverageDetails )row2;
            lines_to_cover=lcd.lines_to_cover;
            covered_lines=lcd.covered_lines;
            uncovered_lines=lcd.uncovered_lines;
        }
        ldt.close();
        if(lines_to_cover!=0){
            line_coevrage=((float)covered_lines/(float)lines_to_cover)*100;
        }
        json component_line_coverage = {"name":component_name, "id":component_id, "lc":{"lines_to_cover":lines_to_cover, "covered_lines":covered_lines,
                                                                                           "uncovered_lines":uncovered_lines,"line_coverage":line_coevrage}};
        lineCoverage.items[lengthof lineCoverage.items]= component_line_coverage;
        selectedProductLinesToCover = selectedProductLinesToCover + lines_to_cover;
        selectedProductCoveredLines = selectedProductCoveredLines + covered_lines;
        selectedProductUncoveredLines = selectedProductUncoveredLines + uncovered_lines;
    }
    cdt.close();

    if(selectedProductLinesToCover != 0) {
        selectedProductLineCoverage = ((float)selectedProductCoveredLines / (float)selectedProductLinesToCover) * 100;
    }

    lineCoverage.line_cov= {"lines_to_cover":selectedProductLinesToCover, "covered_lines":selectedProductCoveredLines,
                               "uncovered_lines":selectedProductUncoveredLines, "line_coverage":selectedProductLineCoverage};

    data.data=lineCoverage;
    sqlEndPoint.close();
    return data;
}

function getSelectedComponentLineCoverage (int componentId) (json) {
    endpoint<sql:ClientConnector> sqlEndPoint{}
    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false};
    json lineCoverage = {"items":[],"line_cov":{}};
    sql:Parameter[] params = [];

    TypeCastError err;

    int selectedComponentLinesToCover = 0; int selectedComponentCoveredLines = 0;
    int selectedComponentUncoveredLines = 0; float selectedComponentLineCoverage = 0.0;

    sql:Parameter pqd_component_id_para = {sqlType:sql:Type.INTEGER, value:componentId};
    params = [pqd_component_id_para];
    datatable cdt = sqlEndPoint.select(GET_DETAILS_OF_COMPONENT , params,typeof Components );
    Components comps;
    while (cdt.hasNext()) {
        any row0 = cdt.getNext();
        comps, err = (Components)row0;

        string component_name = comps.pqd_component_name;
        int component_id = comps.pqd_component_id;

        sql:Parameter component_name_para = {sqlType:sql:Type.VARCHAR, value:component_name};
        sql:Parameter component_id_para = {sqlType:sql:Type.VARCHAR, value:component_id};

        params = [component_name_para,component_id_para];
        datatable ldt = sqlEndPoint.select(GET_LINE_COVERAGE_DETAILS, params,typeof LineCoverageDetails);
        LineCoverageDetails lcd;
        while (ldt.hasNext()) {
            any row2 = ldt.getNext();
            lcd, err = (LineCoverageDetails )row2;
            selectedComponentLinesToCover=lcd.lines_to_cover;
            selectedComponentCoveredLines=lcd.covered_lines;
            selectedComponentUncoveredLines=lcd.uncovered_lines;
        }
        ldt.close();
        if(selectedComponentLinesToCover != 0) {
            selectedComponentLineCoverage = ((float)selectedComponentCoveredLines / (float)selectedComponentLinesToCover) * 100;
        }
    }
    cdt.close();

    lineCoverage.line_cov= {"lines_to_cover":selectedComponentLinesToCover, "covered_lines":selectedComponentCoveredLines,
                               "uncovered_lines":selectedComponentUncoveredLines, "line_coverage":selectedComponentLineCoverage};

    data.data=lineCoverage;
    sqlEndPoint.close();
    return data;
}



function getDailyLineCoverageHistoryForAllArea(string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreasLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_ALL_AREA_DAILY_LINE_COVERAGE, params,typeof DailyLineCoverage);
    DailyLineCoverage dlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        dlc,err=(DailyLineCoverage )row;
        string date= dlc.date;
        float lines_to_cover=dlc.lines_to_cover;
        float covered_lines=dlc.covered_lines;
        float uncovered_lines=dlc.uncovered_lines;
        float line_coverage=dlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        allAreasLineCoverage.data[lengthof allAreasLineCoverage.data]=history;
    }
    ldt.close();

    data.data=allAreasLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyLineCoverageHistoryForAllArea(string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreasLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_ALL_AREA_MONTHLY_LINE_COVERAGE, params,typeof MonthlyLineCoverage);
    MonthlyLineCoverage mlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        mlc,err=(MonthlyLineCoverage)row;
        string date= mlc.year+"-"+mlc.month;
        float lines_to_cover=mlc.lines_to_cover;
        float covered_lines=mlc.covered_lines;
        float uncovered_lines=mlc.uncovered_lines;
        float line_coverage=mlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        allAreasLineCoverage.data[lengthof allAreasLineCoverage.data]=history;
    }
    ldt.close();

    data.data=allAreasLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyLineCoverageHistoryForAllArea(string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreasLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_ALL_AREA_QUARTERLY_LINE_COVERAGE, params,typeof QuarterlyLineCoverage);
    QuarterlyLineCoverage qlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        qlc,err=(QuarterlyLineCoverage)row;
        string date= qlc.year+"-Q"+qlc.quarter;
        float lines_to_cover=qlc.lines_to_cover;
        float covered_lines=qlc.covered_lines;
        float uncovered_lines=qlc.uncovered_lines;
        float line_coverage=qlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        allAreasLineCoverage.data[lengthof allAreasLineCoverage.data]=history;
    }
    ldt.close();

    data.data=allAreasLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyLineCoverageHistoryForAllArea(string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json allAreasLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_ALL_AREA_YEARLY_LINE_COVERAGE, params,typeof YearlyLineCoverage);
    YearlyLineCoverage ylc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        ylc, err = (YearlyLineCoverage)row;
        var date=<string> ylc.year;
        float lines_to_cover= ylc.lines_to_cover;
        float covered_lines= ylc.covered_lines;
        float uncovered_lines= ylc.uncovered_lines;
        float line_coverage= ylc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        allAreasLineCoverage.data[lengthof allAreasLineCoverage.data]=history;
    }
    ldt.close();

    data.data=allAreasLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getDailyLineCoverageHistoryForSelectedArea(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json areaLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_AREA_DAILY_LINE_COVERAGE, params,typeof DailyLineCoverage);
    DailyLineCoverage dlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        dlc,err=(DailyLineCoverage )row;
        string date= dlc.date;
        float lines_to_cover=dlc.lines_to_cover;
        float covered_lines=dlc.covered_lines;
        float uncovered_lines=dlc.uncovered_lines;
        float line_coverage=dlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        areaLineCoverage.data[lengthof areaLineCoverage.data] = history;
    }
    ldt.close();

    data.data= areaLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyLineCoverageHistoryForSelectedArea(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json areaLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_AREA_MONTHLY_LINE_COVERAGE, params,typeof MonthlyLineCoverage);
    MonthlyLineCoverage mlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        mlc,err=(MonthlyLineCoverage)row;
        string date= mlc.year+"-"+mlc.month;
        float lines_to_cover=mlc.lines_to_cover;
        float covered_lines=mlc.covered_lines;
        float uncovered_lines=mlc.uncovered_lines;
        float line_coverage=mlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        areaLineCoverage.data[lengthof areaLineCoverage.data] = history;
    }
    ldt.close();

    data.data= areaLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyLineCoverageHistoryForSelectedArea(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json areaLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_AREA_QUARTERLY_LINE_COVERAGE, params,typeof QuarterlyLineCoverage);
    QuarterlyLineCoverage qlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        qlc,err=(QuarterlyLineCoverage)row;
        string date= qlc.year+"-Q"+qlc.quarter;
        float lines_to_cover=qlc.lines_to_cover;
        float covered_lines=qlc.covered_lines;
        float uncovered_lines=qlc.uncovered_lines;
        float line_coverage=qlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        areaLineCoverage.data[lengthof areaLineCoverage.data] = history;
    }
    ldt.close();

    data.data= areaLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyLineCoverageHistoryForSelectedArea(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json areaLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_AREA_YEARLY_LINE_COVERAGE, params,typeof YearlyLineCoverage);
    YearlyLineCoverage ylc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        ylc, err = (YearlyLineCoverage)row;
        var date=<string> ylc.year;
        float lines_to_cover= ylc.lines_to_cover;
        float covered_lines= ylc.covered_lines;
        float uncovered_lines= ylc.uncovered_lines;
        float line_coverage= ylc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        areaLineCoverage.data[lengthof areaLineCoverage.data] = history;
    }
    ldt.close();

    data.data= areaLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getDailyLineCoverageHistoryForSelectedProduct(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json productLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_PRODUCT_DAILY_LINE_COVERAGE, params,typeof DailyLineCoverage);
    DailyLineCoverage dlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        dlc,err=(DailyLineCoverage )row;
        string date= dlc.date;
        float lines_to_cover=dlc.lines_to_cover;
        float covered_lines=dlc.covered_lines;
        float uncovered_lines=dlc.uncovered_lines;
        float line_coverage=dlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        productLineCoverage.data[lengthof productLineCoverage.data] = history;
    }
    ldt.close();

    data.data= productLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyLineCoverageHistoryForSelectedProduct(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json productLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_PRODUCT_MONTHLY_LINE_COVERAGE, params,typeof MonthlyLineCoverage);
    MonthlyLineCoverage mlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        mlc,err=(MonthlyLineCoverage)row;
        string date= mlc.year+"-"+mlc.month;
        float lines_to_cover=mlc.lines_to_cover;
        float covered_lines=mlc.covered_lines;
        float uncovered_lines=mlc.uncovered_lines;
        float line_coverage=mlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        productLineCoverage.data[lengthof productLineCoverage.data] = history;
    }
    ldt.close();

    data.data= productLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyLineCoverageHistoryForSelectedProduct(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json productLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_PRODUCT_QUARTERLY_LINE_COVERAGE, params,typeof QuarterlyLineCoverage);
    QuarterlyLineCoverage qlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        qlc,err=(QuarterlyLineCoverage)row;
        string date= qlc.year+"-Q"+qlc.quarter;
        float lines_to_cover=qlc.lines_to_cover;
        float covered_lines=qlc.covered_lines;
        float uncovered_lines=qlc.uncovered_lines;
        float line_coverage=qlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        productLineCoverage.data[lengthof productLineCoverage.data] = history;
    }
    ldt.close();

    data.data= productLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyLineCoverageHistoryForSelectedProduct(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json productLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_PRODUCT_YEARLY_LINE_COVERAGE, params,typeof YearlyLineCoverage);
    YearlyLineCoverage ylc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        ylc, err = (YearlyLineCoverage)row;
        var date=<string> ylc.year;
        float lines_to_cover= ylc.lines_to_cover;
        float covered_lines= ylc.covered_lines;
        float uncovered_lines= ylc.uncovered_lines;
        float line_coverage= ylc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        productLineCoverage.data[lengthof productLineCoverage.data] = history;
    }
    ldt.close();

    data.data= productLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getDailyLineCoverageHistoryForSelectedComponent(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json compLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_COMPONENT_DAILY_LINE_COVERAGE, params,typeof DailyLineCoverage);
    DailyLineCoverage dlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        dlc,err=(DailyLineCoverage )row;
        string date= dlc.date;
        float lines_to_cover=dlc.lines_to_cover;
        float covered_lines=dlc.covered_lines;
        float uncovered_lines=dlc.uncovered_lines;
        float line_coverage=dlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        compLineCoverage.data[lengthof compLineCoverage.data] = history;
    }
    ldt.close();

    data.data= compLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getMonthlyLineCoverageHistoryForSelectedComponent(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json compLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_COMPONENT_MONTHLY_LINE_COVERAGE, params,typeof MonthlyLineCoverage);
    MonthlyLineCoverage mlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        mlc,err=(MonthlyLineCoverage)row;
        string date= mlc.year+"-"+mlc.month;
        float lines_to_cover=mlc.lines_to_cover;
        float covered_lines=mlc.covered_lines;
        float uncovered_lines=mlc.uncovered_lines;
        float line_coverage=mlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        compLineCoverage.data[lengthof compLineCoverage.data] = history;
    }
    ldt.close();

    data.data= compLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getQuarterlyLineCoverageHistoryForSelectedComponent(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json compLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_COMPONENT_QUARTERLY_LINE_COVERAGE, params,typeof QuarterlyLineCoverage);
    QuarterlyLineCoverage qlc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        qlc,err=(QuarterlyLineCoverage)row;
        string date= qlc.year+"-Q"+qlc.quarter;
        float lines_to_cover=qlc.lines_to_cover;
        float covered_lines=qlc.covered_lines;
        float uncovered_lines=qlc.uncovered_lines;
        float line_coverage=qlc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        compLineCoverage.data[lengthof compLineCoverage.data] = history;
    }
    ldt.close();

    data.data= compLineCoverage.data;
    sqlEndPoint.close();
    return data;
}

function getYearlyLineCoverageHistoryForSelectedComponent(int selected,string start,string end)(json){
    endpoint<sql:ClientConnector> sqlEndPoint {
    }

    sql:ClientConnector sqlCon = getSQLConnectorForIssuesSonarRelease();
    bind sqlCon with sqlEndPoint;

    json data = {"error":false,"data":[]};
    json compLineCoverage = {"data":[]};
    sql:Parameter[] params = [];
    TypeCastError err;

    sql:Parameter area_id={sqlType:sql:Type.INTEGER,value:selected};
    sql:Parameter start_date_para = {sqlType:sql:Type.VARCHAR, value:start};
    sql:Parameter end_date_para = {sqlType:sql:Type.VARCHAR, value:end};
    params = [area_id,start_date_para,end_date_para];
    datatable ldt = sqlEndPoint.select(GET_SELECTED_COMPONENT_YEARLY_LINE_COVERAGE, params,typeof YearlyLineCoverage);
    YearlyLineCoverage ylc;
    while(ldt.hasNext()){
        any row=ldt.getNext();
        ylc, err = (YearlyLineCoverage)row;
        var date=<string> ylc.year;
        float lines_to_cover= ylc.lines_to_cover;
        float covered_lines= ylc.covered_lines;
        float uncovered_lines= ylc.uncovered_lines;
        float line_coverage= ylc.line_coverage;
        json history={"date":date,"lines_to_cover":lines_to_cover,"covered_lines":covered_lines,
                         "uncovered_lines":uncovered_lines,"line_coverage":line_coverage};
        compLineCoverage.data[lengthof compLineCoverage.data] = history;
    }
    ldt.close();

    data.data= compLineCoverage.data;
    sqlEndPoint.close();
    return data;
}






