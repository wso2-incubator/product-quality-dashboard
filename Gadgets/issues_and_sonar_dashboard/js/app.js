


var WSO2_PRODUCT_COMPONENT_ISSUES_DATA;

var currentState;

var currentArea;
var currentProduct;
var currentVersion;
var currentComponent;
var currentIssueType;
var currentSeverity;

var currentProductId;
var currentComponentId;

var currentMainChartData;
var currentIssueTypeChartData;
var currentSeverityChartData;
var currentPlatformChartData;

var currentMainChartTitle;
var currentIssueTypeChartTitle;
var currentSeverityChartTitle;
var currentPlatformChartTitle;

var currentMainChartSubtitle;
var currentIssueTypeChartSubtitle;
var currentSeverityChartSubtitle;
var currentPlatformChartSubtitle;

var dummyArea = ["Integration", "Identity and Access Management", "API Management", "Data Analytics"];

//sajinie work ---------------
var currentTrendDummyData;
var subTitle = 'For Last 30 Days';
var startDate;
var endDate;
var both;

//sajinie---------------------


//this is the callback function for state change
function callbackForStateChange(state){
    // 
    switch(state){

        case '0':

            //sajinie-----------------------------
            currentIssueType = "no";
            currentSeverity = "no";
            both = "no";
            //sajinie-----------------------------


            //set the data for main chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;

            mainSeriesData = [];
            totalMainIssues = 0;

            for(var i = 0; i < productData.length; i++){
                name = dummyArea[i];
                y = productData[i].issues;
                totalMainIssues += y

                mainSeriesData.push({name: name, y: y});
            }

            currentMainChartTitle = "Total : " + totalMainIssues;
            currentMainChartSubtitle = null;

            currentMainChartData = [{
                name: "Products",
                colorByPoint: true, data: mainSeriesData,
                // events: {
                //     click: function(e){
                //         currentProduct = e.point.name;
                //         currentState = "12";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]




            //set the data for the issuetype chart
            issuetypeData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                events: {
                    click: function(e){
                        currentIssueType = e.point.name;
                        currentState = "05";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = "Click on the slices to view severity breakdown";


            //set the data for the severity chart
            severityData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                events: {
                    click: function(e){
                        currentSeverity = e.point.name;
                        currentState = "06";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = "Click on the slices to view issue type breakdown";

            //set the data for the platform chart


            createCharts();



            console.log("testing1");
            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            console.log("testing");
            console.log(dateTo);
            console.log(dateFrom);
            console.log(this.period);
            getHistoryForAll("day");
            console.log(getHistoryForAll("day"));

            //sajinie's work-------------------------------------------------------------

            break;

        case '05':

            //sajinie-----------------------------

            currentSeverity = "no";
            both = "no";
            //sajinie-----------------------------


            //set the data for the severity chart
            issueTypeData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.issuetype;
            issueTypeIndex = issueTypeData.map(function(d){return d['name']}).indexOf(currentIssueType);

            severityData = issueTypeData[issueTypeIndex].severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                // events: {
                //     click: function(e){
                //         currentSeverity = e.point.name;
                //         currentState = "16";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = null;

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalSeverityIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalSeverityIssues;
            currentPlatformChartSubtitle = null;

            createSeverityChart();
            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistoryForAll("day");

            //sajinie's work-------------------------------------------------------------

            break;

        case '06':

            //sajinie-----------------------------
            currentIssueType = "no";

            both = "no";
            //sajinie-----------------------------

            //set the data for the issuetype chart
            severityData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.severity;
            severityIndex = severityData.map(function(d){return d['name']}).indexOf(currentSeverity);
            issuetypeData = severityData[severityIndex].issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                // events: {
                //     click: function(e){
                //         currentIssueType = e.point.name;
                //         currentState = "05";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = null;

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalIssuetypeIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalIssuetypeIssues;
            currentPlatformChartSubtitle = null;

            createIssueTypeChart();
            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistoryForAll("day");

            //sajinie's work-------------------------------------------------------------

            break;

        case '1':

            //sajinie-----------------------------
            currentIssueType = "no";
            currentSeverity = "no";
            both = "no";
            //sajinie-----------------------------

            //set the data for main chart
            productIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentArea);
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.slice(productIndex, productIndex+1);

            mainSeriesData = [];
            totalMainIssues = 0;

            for(var i = 0; i < productData.length; i++){
                name = productData[i].name;
                y = productData[i].issues;
                totalMainIssues += y

                mainSeriesData.push({name: name, y: y});
            }

            currentMainChartData = [{
                name: "Products",
                colorByPoint: true, data: mainSeriesData,
                // events: {
                //     click: function(e){
                //         currentProduct = e.point.name;
                //         currentState = "12";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]


            currentMainChartTitle = "Total : " + totalMainIssues;
            currentMainChartSubtitle = null;

            //set the data for the issuetype chart



            issuetypeData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products[productIndex].issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                events: {
                    click: function(e){
                        currentIssueType = e.point.name;
                        currentState = "15";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = "Click on the slices to view severity breakdown";


            //set the data for the severity chart
            severityData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products[productIndex].severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                events: {
                    click: function(e){
                        currentSeverity = e.point.name;
                        currentState = "16";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = "Click on the slices to view issue type breakdown";

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalMainIssues, 0]
            }];



            currentPlatformChartTitle = "Total : " + totalMainIssues;
            currentPlatformChartSubtitle = null;

            createCharts();

            document.getElementById("version-choice").innerHTML = "<option value='none'>Select a product</option>"

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistoryForArea("day");

            //sajinie's work-------------------------------------------------------------

            break;

        case '12':

            //sajinie-----------------------------
            currentIssueType = "no";
            currentSeverity = "no";
            currentComponent = 0;
            currentVersion = "null";
            both = "no";
            //sajinie-----------------------------


            //set the data for main chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            versionData = productData[productIndex].version;

            mainSeriesData = [];
            totalMainIssues = 0;

            for(var i = 0; i < versionData.length; i++){
                name = versionData[i].name;
                y = versionData[i].issues;
                totalMainIssues += y

                mainSeriesData.push({name: name, y: y});
            }

            currentMainChartData = [{
                name: "Products",
                colorByPoint: true, data: mainSeriesData,
                // events: {
                //     click: function(e){
                //         currentVersion = e.point.name;
                //         currentState = "123";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]


            currentMainChartTitle = "Total : " + totalMainIssues;
            currentMainChartSubtitle = null;

            //set the data for the issuetype chart

            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            issuetypeData = productData[productIndex].issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                // events: {
                //     click: function(e){
                //         currentIssueType = e.point.name;
                //         currentState = "125";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = "Click on the slices to view severity breakdown";


            //set the data for the severity chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            severityData = productData[productIndex].severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                // events: {
                //     click: function(e){
                //         currentSeverity = e.point.name;
                //         currentState = "126";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = "Click on the slices to view issue type breakdown";

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalMainIssues, 0]
            }];


            currentPlatformChartTitle = "Total : " + totalMainIssues;
            currentPlatformChartSubtitle = null;

            createCharts();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistory("day");

            //sajinie's work-------------------------------------------------------------

            break;

        case '15':

            //sajinie-----------------------------

            currentSeverity = "no";
            both = "no";
            //sajinie-----------------------------



            //set the data for the severity chart
            productIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentArea);
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.slice(productIndex, productIndex+1);

            currentProductData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products[productIndex];

            issueTypeData = currentProductData.issuetype;
            issueTypeIndex = issueTypeData.map(function(d){return d['name']}).indexOf(currentIssueType);

            severityData = issueTypeData[issueTypeIndex].severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                // events: {
                //     click: function(e){
                //         currentSeverity = e.point.name;
                //         currentState = "16";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = null;

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalSeverityIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalSeverityIssues;
            currentPlatformChartSubtitle = null;

            createSeverityChart();
            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistoryForArea("day");

            //sajinie's work-------------------------------------------------------------


            break;

        case '16':

            //sajinie-----------------------------
            currentIssueType = "no";

            both = "no";
            //sajinie-----------------------------

            //set the data for the issuetype chart

            productIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentArea);
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.slice(productIndex, productIndex+1);

            currentProductData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products[productIndex];

            severityData = currentProductData.severity;
            severityIndex = severityData.map(function(d){return d['name']}).indexOf(currentSeverity);
            issuetypeData = severityData[severityIndex].issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                // events: {
                //     click: function(e){
                //         currentIssueType = e.point.name;
                //         currentState = "05";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = null;

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalIssuetypeIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalIssuetypeIssues;
            currentPlatformChartSubtitle = null;

            createIssueTypeChart();
            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistoryForArea("day");

            //sajinie's work-------------------------------------------------------------


            break;

        case '123':

            //sajinie-----------------------------
            currentIssueType = "no";
            currentSeverity = "no";
            both = "no";
            currentComponent = 0;

            //sajinie-----------------------------



            //set the data for main chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);



            componentData = productData[productIndex].components;
            componentIndex = componentData.map(function(d){return d['name']}).indexOf(currentComponent);



            mainSeriesData = [];
            totalMainIssues = 0;

            for(var i = 0; i < componentData.length; i++){
                name = componentData[i].name;
                y = componentData[i].issues;
                totalMainIssues += y

                mainSeriesData.push({name: name, y: y});
            }

            currentMainChartData = [{
                name: "Products",
                colorByPoint: true, data: mainSeriesData,
                events: {
                    click: function(e){
                        currentComponent = e.point.name;
                        componentIndex = componentData.map(function(d){return d['name']}).indexOf(currentComponent);
                        currentComponentId = componentData[componentIndex].id;
                        currentState = "1234";
                        callbackForStateChange(currentState);
                    }
                }
            }]


            currentMainChartTitle = "Total : " + totalMainIssues;
            currentMainChartSubtitle = "Click on the columns to view issue types and severity breakdown";


            //set the data for the issuetype chart

            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            versionData = productData[productIndex].version;
            versionIndex = versionData.map(function(d){return d['name']}).indexOf(currentVersion);

            issuetypeData = versionData[versionIndex].issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                events: {
                    click: function(e){
                        currentIssueType = e.point.name;
                        currentState = "1235";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = "Click on the slices to view severity breakdown";


            //set the data for the severity chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            versionData = productData[productIndex].version;
            versionIndex = versionData.map(function(d){return d['name']}).indexOf(currentVersion);

            severityData = versionData[versionIndex].severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                events: {
                    click: function(e){
                        currentSeverity = e.point.name;
                        currentState = "1236";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = "Click on the slices to view issue type breakdown";

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalSeverityIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalSeverityIssues;
            currentPlatformChartSubtitle = null;

            createCharts();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistory("day");

            //sajinie's work-------------------------------------------------------------


            break;

        case '1235':
            //sajinie-----------------------------

            currentSeverity = "no";
            currentComponent = 0;

            both = "no";
            //sajinie-----------------------------

            //set the data for the severity chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            versionData = productData[productIndex].version;
            versionIndex = versionData.map(function(d){return d['name']}).indexOf(currentVersion);

            issueTypeData = versionData[versionIndex].issuetype;
            issueTypeIndex = issueTypeData.map(function(d){return d['name']}).indexOf(currentIssueType);

            severityData = issueTypeData[issueTypeIndex].severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                // events: {
                //     click: function(e){
                //         currentSeverity = e.point.name;
                //         currentState = "16";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = null;

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalSeverityIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalSeverityIssues;
            currentPlatformChartSubtitle = null;

            createSeverityChart();
            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistory("day");

            //sajinie's work-------------------------------------------------------------


            break;

        case '1236':
            //sajinie-----------------------------
            currentIssueType = "no";

            currentComponent = 0;

            both = "no";
            //sajinie-----------------------------
            //set the data for the issuetype chart

            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            versionData = productData[productIndex].version;
            versionIndex = versionData.map(function(d){return d['name']}).indexOf(currentVersion);

            severityData = versionData[versionIndex].severity;
            severityIndex = severityData.map(function(d){return d['name']}).indexOf(currentSeverity);

            issuetypeData = severityData[severityIndex].issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                // events: {
                //     click: function(e){
                //         currentIssueType = e.point.name;
                //         currentState = "05";
                //         callbackForStateChange(currentState);
                //     }
                // }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = null;

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalIssuetypeIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalIssuetypeIssues;
            currentPlatformChartSubtitle = null;

            createIssueTypeChart();
            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistory("day");

            //sajinie's work-------------------------------------------------------------

            break;

        case '1234':

            //sajinie-----------------------------
            currentIssueType = "no";
            currentSeverity = "no";
            currentVersion = "null";
            both = "no";
            //sajinie-----------------------------

            //set the titles for the chart
            currentMainChartTitle = "Products";
            currentIssueTypeChartTitle = "Issue types";
            currentSeverityChartTitle = "Severity";
            currentPlatformChartTitle = "Platform";

            //set the data for main chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            componentData = productData[productIndex].components;
            componentIndex = componentData.map(function(d){return d['name']}).indexOf(currentComponent);



            mainSeriesData = [];
            totalMainIssues = 0;

            for(var i = 0; i < componentData.length; i++){
                name = componentData[i].name;
                y = componentData[i].issues;
                totalMainIssues += y

                mainSeriesData.push({name: name, y: y});
            }

            currentMainChartData = [{
                name: "Components",
                data: mainSeriesData,
                events: {
                    click: function(e){

                        currentComponent = e.point.name;
                        currentState = "1234";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentMainChartSubtitle = "Click on the columns to view issue types and severity breakdown";

            //set the data for the issuetype chart

            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            componentData = productData[productIndex].components;
            componentIndex = componentData.map(function(d){return d['name']}).indexOf(currentComponent);

            issuetypeData = componentData[componentIndex].issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                events: {
                    click: function(e){
                        currentIssueType = e.point.name;
                        currentState = "12345";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = "Click on the slices to view severity breakdown";


            //set the data for the severity chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            componentData = productData[productIndex].components;
            componentIndex = componentData.map(function(d){return d['name']}).indexOf(currentComponent);

            severityData = componentData[componentIndex].severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                events: {
                    click: function(e){
                        currentSeverity = e.point.name;
                        currentState = "12346";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = "Click on the slices to view issue type breakdown";

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalIssuetypeIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalIssuetypeIssues;
            currentPlatformChartSubtitle = null;

            createIssueTypeChart();
            createSeverityChart();
            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistory("day");

            //sajinie's work-------------------------------------------------------------

            break;



        case '12345':

            //sajinie-----------------------------
            currentSeverity = "no";
            both = "no";
            //sajinie-----------------------------


            //set the data for the severity chart
            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            componentData = productData[productIndex].components;
            componentIndex = componentData.map(function(d){return d['name']}).indexOf(currentComponent);

            issuetypeData = componentData[componentIndex].issuetype;
            issuetypeIndex = issuetypeData.map(function(d){return d['name']}).indexOf(currentIssueType);

            severityData = issuetypeData[issuetypeIndex].severity;

            severitySeriesData = [];
            totalSeverityIssues = 0;

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                y = severityData[i].issues;

                totalSeverityIssues += y;

                severitySeriesData.push({name: name, y: y});
            }

            currentSeverityChartData = [{
                name: "Severity",
                colorByPoint: true, data: severitySeriesData,
                events: {
                    click: function(e){
                        currentSeverity = e.point.name;
                        currentState = "126";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentSeverityChartTitle = "Total : " + totalSeverityIssues;
            currentSeverityChartSubtitle = null;

            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalSeverityIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalSeverityIssues;
            currentPlatformChartSubtitle = null;


            createSeverityChart();
            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistory("day");

            //sajinie's work-------------------------------------------------------------


            break;

        case '12346':
            //sajinie-----------------------------
            currentIssueType = "no";
            both = "no";
            //sajinie-----------------------------

            //set the titles for the chart
            currentMainChartTitle = "Products";
            currentIssueTypeChartTitle = "Issue types";
            currentSeverityChartTitle = "Severity";
            currentPlatformChartTitle = "Platform";



            //set the data for the issuetype chart

            productData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
            productIndex = productData.map(function(d){return d['name']}).indexOf(currentProduct);

            componentData = productData[productIndex].components;
            componentIndex = componentData.map(function(d){return d['name']}).indexOf(currentComponent);

            severityData = componentData[componentIndex].severity;
            severityIndex = severityData.map(function(d){return d['name']}).indexOf(currentSeverity);

            issuetypeData = severityData[severityIndex].issuetype;

            issuetypeSeriesData = [];
            totalIssuetypeIssues = 0;

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                y = issuetypeData[i].issues;

                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, y: y});
            }

            currentIssueTypeChartData = [{
                name: "Issue type",
                colorByPoint: true, data: issuetypeSeriesData,
                events: {
                    click: function(e){
                        currentIssueType = e.point.name;
                        currentState = "12345";
                        callbackForStateChange(currentState);
                    }
                }
            }]

            currentIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
            currentIssueTypeChartSubtitle = null;




            //set the data for the platform chart


            currentPlatformChartData = [{
                name: 'Platform',
                data: [totalIssuetypeIssues, 0]
            }];

            currentPlatformChartTitle = "Total : " + totalIssuetypeIssues;
            currentPlatformChartSubtitle = null;

            createIssueTypeChart();

            createPlatformChart();

            //sajinie's work-------------------------------------------------------------
            var dateFrom = moment().subtract(29, 'days');
            var dateTo= moment();
            this.startDate = dateFrom.format('YYYY-MM-DD');
            this.endDate = dateTo.format('YYYY-MM-DD');
            this.period = "day";

            getHistory("day");

            //sajinie's work-------------------------------------------------------------


            break;

        case '123456':
            break;

        case '123465':
            break;

    }

}


//this is the main function that iniatates all the functions and charts
function initCharts(responseData){


    this.WSO2_PRODUCT_COMPONENT_ISSUES_DATA = responseData;
    currentState = '0';
    callbackForStateChange(currentState);




}

function createCharts(){
    createMainChart();
    createIssueTypeChart();
    createSeverityChart();
    // createPlatformChart();

}


//this will create the main graph with areas, products, product versions and components
//graph type : bar
function createMainChart(){
    //Create the chart

    if (currentState == '123'){

        Highcharts.chart('main-chart-container', {
            chart: {
                type: 'column'
            },
            title: {
                text: currentMainChartTitle
            },
            subtitle: {
                text: currentMainChartSubtitle
            },
            credits: {
                enabled: false
            },
            xAxis: {
                type: 'category'
            },
            yAxis: {
                title: {
                    text: 'Total open issues'
                }

            },
            legend: {
                enabled: false
            },
            plotOptions: {
                series: {
                    borderWidth: 0,
                    dataLabels: {
                        enabled: true,
                        format: '{point.y}'
                    },
                    allowPointSelect: true,
                    states: {
                        select: {
                            color: null,
                            borderWidth:5,
                            borderColor:'Black'
                        }
                    }
                }, column: {
                    maxPointWidth: 100
                }
            },

            tooltip: {
                headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
                pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b>'
            },

            series: currentMainChartData,

            exporting: {
                enabled: true
            }
        });
        Highcharts.chart('main-chart-container-sonar', {
            chart: {
                type: 'column'
            },
            title: {
                text: currentMainChartTitle
            },
            subtitle: {
                text: currentMainChartSubtitle
            },
            credits: {
                enabled: false
            },
            xAxis: {
                type: 'category'
            },
            yAxis: {
                title: {
                    text: 'Total open issues'
                }

            },
            legend: {
                enabled: false
            },
            plotOptions: {
                series: {
                    borderWidth: 0,
                    dataLabels: {
                        enabled: true,
                        format: '{point.y}'
                    },
                    allowPointSelect: true,
                    states: {
                        select: {
                            color: null,
                            borderWidth:5,
                            borderColor:'Black'
                        }
                    }
                }, column: {
                    maxPointWidth: 100
                }
            },

            tooltip: {
                headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
                pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b>'
            },

            series: currentMainChartData,

            exporting: {
                enabled: true
            }
        });

    } else {

        Highcharts.chart('main-chart-container', {
            chart: {
                type: 'column'
            },
            title: {
                text: currentMainChartTitle
            },
            subtitle: {
                text: currentMainChartSubtitle
            },
            credits: {
                enabled: false
            },
            xAxis: {
                type: 'category'
            },
            yAxis: {
                title: {
                    text: 'Total open issues'
                }

            },
            legend: {
                enabled: false
            },
            plotOptions: {
                series: {
                    borderWidth: 0,
                    dataLabels: {
                        enabled: true,
                        format: '{point.y}'
                    }
                }, column: {
                    maxPointWidth: 100
                }
            },

            tooltip: {
                headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
                pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b>'
            },

            series: currentMainChartData,

            exporting: {
                enabled: true
            }
        });

        Highcharts.chart('main-chart-container-sonar', {
            chart: {
                type: 'column'
            },
            title: {
                text: currentMainChartTitle
            },
            subtitle: {
                text: currentMainChartSubtitle
            },
            credits: {
                enabled: false
            },
            xAxis: {
                type: 'category'
            },
            yAxis: {
                title: {
                    text: 'Total open issues'
                }

            },
            legend: {
                enabled: false
            },
            plotOptions: {
                series: {
                    borderWidth: 0,
                    dataLabels: {
                        enabled: true,
                        format: '{point.y}'
                    }
                }, column: {
                    maxPointWidth: 100
                }
            },

            tooltip: {
                headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
                pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b>'
            },

            series: currentMainChartData,

            exporting: {
                enabled: true
            }
        });

    }



}

//this will create the issue type pie graph
//graph type : pie
function createIssueTypeChart(){
    // Create the chart

    Highcharts.chart('issuetype-chart-container', {
        chart: {
            type: 'pie',
        },
        credits: {
            enabled: false
        },
        title: {
            text: currentIssueTypeChartTitle

        },
        legend: {
            // layout: 'vertical',
            // align: 'right',
            // verticalAlign: 'top',
            // y: 50,
            // width: 100
            itemWidth: 150
        },
        subtitle: {
            text: currentIssueTypeChartSubtitle
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '{point.y}',
                    distance: 5
                },
                showInLegend: true,
            }
        },

        tooltip: {
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },

        series: currentIssueTypeChartData,
        exporting: {
            enabled: true
        }

    });
    Highcharts.chart('issuetype-chart-container-sonar', {
        chart: {
            type: 'pie',
        },
        credits: {
            enabled: false
        },
        title: {
            text: currentIssueTypeChartTitle

        },
        legend: {
            // layout: 'vertical',
            // align: 'right',
            // verticalAlign: 'top',
            // y: 50,
            // width: 100
            itemWidth: 150
        },
        subtitle: {
            text: currentIssueTypeChartSubtitle
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '{point.y}',
                    distance: 5
                },
                showInLegend: true,
            }
        },

        tooltip: {
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },

        series: currentIssueTypeChartData,
        exporting: {
            enabled: true
        }

    });


}


/**
 * this will create the severity pie graph
 * graph type : pie
 */
function createSeverityChart(){
    // Create the chart

    Highcharts.chart('severity-chart-container', {
        chart: {
            type: 'pie',
        },
        credits: {
            enabled: false
        },
        legend: {
            // layout: 'vertical',
            // align: 'right',
            // verticalAlign: 'top',
            // y: 50,
            itemWidth: 150
            // floating: false,
            // backgroundColor: '#FCFFC5'
        },
        title: {
            text: currentSeverityChartTitle

        },
        subtitle: {
            text: currentSeverityChartSubtitle
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '{point.y}',
                    distance: 5
                },
                showInLegend: true
            }
        },

        tooltip: {
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },

        series: currentSeverityChartData,
        exporting: {
            enabled: true
        }

    });
    Highcharts.chart('severity-chart-container-sonar', {
        chart: {
            type: 'pie',
        },
        credits: {
            enabled: false
        },
        legend: {
            // layout: 'vertical',
            // align: 'right',
            // verticalAlign: 'top',
            // y: 50,
            itemWidth: 150
            // floating: false,
            // backgroundColor: '#FCFFC5'
        },
        title: {
            text: currentSeverityChartTitle

        },
        subtitle: {
            text: currentSeverityChartSubtitle
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '{point.y}',
                    distance: 5
                },
                showInLegend: true
            }
        },

        tooltip: {
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },

        series: currentSeverityChartData,
        exporting: {
            enabled: true
        }

    });

}

/**
 * this will create the platform graph which is JIRA and Github for now
 * graph type : horizontal bar
 */


function setCurrentState(state){
    currentState = state;
}

function setCurrentArea(area){
    currentArea = area;
}

function setCurrentProduct(product){
    currentProduct = product;
    currentProductIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentProduct);

    currentProductId = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products[currentProductIndex].id;
}

function setCurrentVersion(version){
    currentVersion = version;
}

function setCurrentComponent(component){
    currentComponent = component;

    currentProductIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentProduct);
    currentProductData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products[currentProductIndex];

    currentComponentIndex = currentProductData.components.map(function(d){return d['name']}).indexOf(currentComponent);
    currentComponentId = currentProductData.components[currentComponentIndex].id;
}

function setCurrentIssueType(issuetype){
    currentIssueType = issuetype;
}

function setCurrentSeverity(severity){
    currentSeverity = severity;
}

// sajinie-----------------------------------------------------------------------
function setDate(start, end) {
    this.startDate = start;
    this.endDate = end;
    subTitle =  startDate + " - " + endDate;
    console.log(startDate);
    console.log(endDate);
}

function history(period) {
    if (currentState === "0"){
        getHistoryForAll(period);
    }else if (currentState === "05"){
        getHistoryForAll(period);
    }else if (currentState === "06"){
        getHistoryForAll(period);
    }else if (currentState === "1"){
        getHistoryForArea(period);
    }else if (currentState === "15"){
        getHistoryForArea(period);
    }else if (currentState === "16"){
        getHistoryForArea(period);
    }else {
        getHistory(period);
    }
}

function getHistoryForAll(period) {
    debugger;
    var historyForAll;
    $.ajax({
        type: "GET",
        // beforeSend: function(request) {
        //     request.setRequestHeader("Authorization", "Bearer 6831161b-0fe8-33cb-b4cb-df38e9acf924");
        // },
        // url: 'https://10.100.4.110:9092/internal/product-quality/v1.0/jira/issues/history/all',
        url: 'https://192.168.8.100:9092/internal/product-quality/v1.0/jira/issues/history/all',
        data:{
            both: both,
            issuetype: currentIssueType,
            severity: currentSeverity,
            dateFrom : this.startDate,
            dateTo : this.endDate,
            period: period
        },
        async: false,
        success: function(data){
            historyForAll = data.data.data;
            console.log(historyForAll);
        }
    });
    debugger;
    historySeriesData = [];

    for(var i = 0; i < historyForAll.length; i++){
        name = historyForAll[i].date;
        var y;
        if (period !== "day"){
            y = historyForAll[i].count / 10;
        }else{
            y = historyForAll[i].count;
        }
        historySeriesData.push({name: name, y: y});
    }
    debugger;
    createTrendChart(historySeriesData);
    // return historyForAll;

}

function getHistoryForArea(period) {
    var historyForAll;
    console.log("getHistoryForArea");
    $.ajax({
        type: "GET",
        beforeSend: function(request) {
            request.setRequestHeader("Authorization", "Bearer 6831161b-0fe8-33cb-b4cb-df38e9acf924");
        },
        // url: 'https://10.100.4.110:8246/internal/product-quality/v1.0/jira/issues/history/area',
        url: 'https://192.168.8.100:8246/internal/product-quality/v1.0/jira/issues/history/area',
        data:{
            area: currentArea,
            both: both,
            issuetype: currentIssueType,
            severity: currentSeverity,
            dateFrom : this.startDate,
            dateTo : this.endDate,
            period: period
        },
        async: false,
        success: function(data){
            historyForAll = data.data.data;
            console.log(historyForAll);
        }
    });
    historySeriesData = [];

    for(var i = 0; i < historyForAll.length; i++){
        name = historyForAll[i].date;
        var y;
        if (period !== "day"){
            y = historyForAll[i].count / 6;
        }else{
            y = historyForAll[i].count;
        }
        historySeriesData.push({name: name, y: y});
    }
    createTrendChart(historySeriesData);
    // return historyForAll;

}

function getHistory(period) {

    var historyForAll;
    console.log("getHistoryForArea");
    $.ajax({
        type: "GET",
        beforeSend: function(request) {
            request.setRequestHeader("Authorization", "Bearer 6831161b-0fe8-33cb-b4cb-df38e9acf924");
        },
        // url: 'https://10.100.4.110:8246/internal/product-quality/v1.0/jira/issues/history',
        url: 'https://192.168.8.100:8246/internal/product-quality/v1.0/jira/issues/history',
        data:{
            product: currentProductId,
            component: currentComponentId,
            version: currentVersion,
            both: both,
            issuetype: currentIssueType,
            severity: currentSeverity,
            dateFrom : this.startDate,
            dateTo : this.endDate,
            period: period
        },
        async: false,
        success: function(data){
            historyForAll = data.data.data;
            console.log(historyForAll);
        }
    });
    historySeriesData = [];

    for(var i = 0; i < historyForAll.length; i++){
        name = historyForAll[i].date;
        var y;
        if (period !== "day"){
            y = historyForAll[i].count / 8;
        }else{
            y = historyForAll[i].count;
        }
        historySeriesData.push({name: name, y: y});
    }
    createTrendChart(historySeriesData);
    // return historyForAll;

}

function callbackForDummy(startDate, endDate) {

    this.startDate = startDate;
    this.endDate = endDate;
    this.subTitle = startDate + "  to  " + endDate;

    switch(startDate){
        case '2017-09-15':
            currentTrendDummyData = last7Days;
            createTrendChart();
            break;

        case '2017-08-23':
            currentTrendDummyData = last30Days;
            createTrendChart();
            break;

        case '2017-09-01':
            currentTrendDummyData = thisMonth;
            createTrendChart();
            break;

        case '2017-08-01':
            currentTrendDummyData = lastMonth;
            createTrendChart();
            break
    }
}
function callbackForDummyMonthly() {
    currentTrendDummyData = monthly;

    createTrendChart();
}
function callbackForDummyQuarterly() {
    console.log("quarterly");
}
function callbackForDummyYearly() {
    currentTrendDummyData = yearly;

    createTrendChart();
}


function createTrendChart(data){

    Highcharts.chart('trend-chart-container', {
        chart: {
            zoomType: 'x'
        },
        title: {
            text: subTitle
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Number of Issues'
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle'
        },
        plotOptions: {
            series: {
                borderWidth: 0,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}'
                }
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b> of total<br/>'
        },
        series: [{
            type: 'line',
            // name: 'USD to EUR',
            data: data
        }]

    });

    Highcharts.chart('trend-chart-container-sonar', {
        chart: {
            zoomType: 'x'
        },
        title: {
            text: subTitle
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Number of Issues'
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle'
        },
        plotOptions: {
            series: {
                borderWidth: 0,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}'
                }
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b> of total<br/>'
        },
        series: [{
            type: 'line',
            // name: 'USD to EUR',
            data: data
        }]

    });
}

// function initChart(responseData){
//     this.WSO2_PRODUCT_COMPONENT_ISSUES_DATA = responseData;
//     currentState = '0';
//     callbackForStateChannel(currentState);
// }


// function callbackForStateChannel(state){
//     switch(state){
//         case '0':
//             severityData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.severity;
//             seriesData = [];
//             for (var i = 0; i < severityData.length; i++){
//                 name = severityData[i].name;
//                 y = severityData[i].issues;

//                 seriesData.push({name: name, y: y});
//             }

//             currentSeriesData = [{
//                                     name: "Severity", 
//                                     colorByPoint: true, data: seriesData,
//                                     events: {
//                                     click: function(e){
//                                         gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                         gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "5");
//                                         currentSeverity = e.point.name;
//                                         currentState = "5";
//                                         callbackForStateChannel(currentState);
//                                     }
//                                 }}];

//             currentChartTitle = "";
//             createChart();
//             break;

//         case '1':
//             if (currentProduct){
//                 productsData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
//                 var index = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentProduct);

//                 var productSeverityData = productsData[index].severity;
//                 seriesData = [];
//                 for (var i = 0; i < productSeverityData.length; i++){
//                     name = productSeverityData[i].name;
//                     y = productSeverityData[i].issues;

//                     seriesData.push({name: name, y: y});
//                 }

//                 currentSeriesData = [{
//                                         name: "Severity", 
//                                         colorByPoint: true, data: seriesData,
//                                         events: {
//                                             click: function(e){
//                                                 gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                                 gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "15");
//                                                 currentState = "15";
//                                                 currentSeverity = e.point.name;
//                                         }
//                                     }}];

//                 currentChartTitle = "under " + currentProduct;
//                 createChart();
//             }
//             break;

//         case '4':
//             if (currentIssueType){
//                 issuetypeData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.issuetype;
//                 var index = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.issuetype.map(function(d){return d['name']}).indexOf(currentIssueType);

//                 var issuetypeSeverityData = issuetypeData[index].severity;
//                 seriesData = [];
//                 for (var i = 0; i < issuetypeSeverityData.length; i++){
//                     name = issuetypeSeverityData[i].name;
//                     y = issuetypeSeverityData[i].issues;

//                     seriesData.push({name: name, y: y});
//                 }

//                 currentSeriesData = [{
//                                         name: "Severity", 
//                                         colorByPoint: true, data: seriesData,
//                                         events: {
//                                             click: function(e){
//                                                 gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                                 gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "45");
//                                                 currentState = "45";
//                                                 currentSeverity = e.point.name;
//                                         }
//                                     }}];

//                 currentChartTitle = "of type '" + currentIssueType + "'";
//                 createChart();
//             }
//             break;
//         case '12':
//             if (currentProduct && currentProductVersion){
//                 productsData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
//                 var productIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentProduct);

//                 var productVersionData = productsData[productIndex].version;
//                 var productVersionIndex = productVersionData.map(function(d){return d['name']}).indexOf(currentProductVersion);

//                 var productVersionSeverityData = productVersionData[productVersionIndex].severity;
//                 seriesData = [];
//                 for (var i = 0; i < productVersionSeverityData.length; i++){
//                     name = productVersionSeverityData[i].name;
//                     y = productVersionSeverityData[i].issues;

//                     seriesData.push({name: name, y: y});
//                 }

//                 currentSeriesData = [{
//                                         name: "Severity", 
//                                         colorByPoint: true, data: seriesData,
//                                         events: {
//                                             click: function(e){
//                                                 gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                                 gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "125");
//                                                 currentState = "125";
//                                                 currentSeverity = e.point.name;
//                                         }
//                                     }}];

//                 currentChartTitle = "under " + currentProduct + "-" + currentProductVersion;
//                 createChart();
//             }
//             break;
//         case '13':
//             if (currentProduct && currentComponent){
//                 productsData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
//                 var productIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentProduct);

//                 var productComponentData = productsData[productIndex].components;
//                 var productComponentIndex = productComponentData.map(function(d){return d['name']}).indexOf(currentComponent);

//                 var productComponentSeverityData = productComponentData[productComponentIndex].severity;
//                 seriesData = [];
//                 for (var i = 0; i < productComponentSeverityData.length; i++){
//                     name = productComponentSeverityData[i].name;
//                     y = productComponentSeverityData[i].issues;

//                     seriesData.push({name: name, y: y});
//                 }

//                 currentSeriesData = [{
//                                 name: "Severity", 
//                                 colorByPoint: true, data: seriesData,
//                                 events: {
//                                             click: function(e){
//                                                 gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                                 gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "135");
//                                                 currentState = "135";
//                                                 currentSeverity = e.point.name;
//                                         }
//                                     }}];

//                 currentChartTitle = "under " + currentProduct + "-" + currentComponent;
//                 createChart();
//             }
//             break;
//         case '14':
//             if (currentProduct && currentIssueType){
//                     productsData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
//                     var productIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentProduct);

//                     var productIssueTypeData = productsData[productIndex].issuetype;
//                     var productIssueTypeIndex = productIssueTypeData.map(function(d){return d['name']}).indexOf(currentIssueType);

//                     var productIssueTypeSeverityData = productIssueTypeData[productIssueTypeIndex].severity;
//                     seriesData = [];
//                     for (var i = 0; i < productIssueTypeSeverityData.length; i++){
//                         name = productIssueTypeSeverityData[i].name;
//                         y = productIssueTypeSeverityData[i].issues;

//                         seriesData.push({name: name, y: y});
//                     }

//                     currentSeriesData = [{
//                                     name: "Severity", 
//                                     colorByPoint: true, data: seriesData,
//                                     events: {
//                                                 click: function(e){
//                                                     gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                                     gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "145");
//                                                     currentState = "145";
//                                                     currentSeverity = e.point.name;
//                                             }
//                                         }}];

//                     currentChartTitle = "of type '" + currentIssueType + "'' under " + currentProduct;
//                     createChart();
//                 }
//             break;
//         case '41':
//             if (currentIssueType && currentProduct){
//                 issueTypeData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.issuetype;
//                 var issuetypeIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.issuetype.map(function(d){return d['name']}).indexOf(currentIssueType);

//                 var issueTypeProductData = issueTypeData[issuetypeIndex].products;
//                 var issueTypeProductIndex = issueTypeProductData.map(function(d){return d['name']}).indexOf(currentProduct);

//                 var issueTypeProductSeverityData = issueTypeProductData[issueTypeProductIndex].severity;
//                 seriesData = [];
//                 for (var i = 0; i < issueTypeProductSeverityData.length; i++){
//                     name = issueTypeProductSeverityData[i].name;
//                     y = issueTypeProductSeverityData[i].issues;

//                     seriesData.push({name: name, y: y});
//                 }

//                 currentSeriesData = [{
//                                 name: "Severity", 
//                                 colorByPoint: true, data: seriesData,
//                                 events: {
//                                             click: function(e){
//                                                 gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                                 gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "415");
//                                                 currentState = "415";
//                                                 currentSeverity = e.point.name;
//                                         }
//                                     }}];

//                     currentChartTitle = "of type '" + currentIssueType + "'' under " + currentProduct;
//                     createChart();
//             }
//             break;
//         case '124':
//             if (currentProduct && currentProductVersion && currentIssueType){
//                 productsData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
//                 var productIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentProduct);

//                 var productVersionData = productsData[productIndex].version;
//                 var productVersionIndex = productVersionData.map(function(d){return d['name']}).indexOf(currentProductVersion);

//                 var productVersionIssueTypeData = productsVersionData[productVersionIndex].issuetype;
//                 var productVersionIssueTypeIndex = productVersionIssueTypeData.map(function(d){return d['name']}).indexOf(currentIssueType);

//                 var productVersionIssueTypeSeverityData = productVersionIssueTypeData[productVersionIssueTypeIndex].severity;

//                 seriesData = [];
//                 for (var i = 0; i < productVersionIssueTypeSeverityData.length; i++){
//                     name = productVersionIssueTypeSeverityData[i].name;
//                     y = productVersionIssueTypeSeverityData[i].issues;

//                     seriesData.push({name: name, y: y});
//                 }

//                 currentSeriesData = [{
//                                         name: "Severity", 
//                                         colorByPoint: true, data: seriesData,
//                                         events: {
//                                             click: function(e){
//                                                 gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                                 gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "1245");
//                                                 currentState = "1245";
//                                                 currentSeverity = e.point.name;
//                                         }
//                                     }}];

//                 currentChartTitle = "under " + currentProduct + "-" + currentProductVersion + " of type '" + currentIssueType + "'";
//                 createChart();
//             }
//             break;
//         case '134':

//             if (currentProduct && currentComponent && currentIssueType){
//                     productsData = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products;
//                     var productIndex = WSO2_PRODUCT_COMPONENT_ISSUES_DATA.products.map(function(d){return d['name']}).indexOf(currentProduct);

//                     var productComponentData = productsData[productIndex].components;
//                     var productComponentIndex = productComponentData.map(function(d){return d['name']}).indexOf(currentComponent);

//                     var productComponentIssueTypeData = productComponentData[productComponentIndex].issuetype;
//                     var productComponentIssueTypeIndex = productComponentIssueTypeData.map(function(d){return d['name']}).indexOf(currentIssueType);

//                     var productComponentIssueTypeSeverityData = productComponentIssueTypeData[productComponentIssueTypeIndex].severity;

//                     seriesData = [];
//                     for (var i = 0; i < productComponentIssueTypeSeverityData.length; i++){
//                         name = productComponentIssueTypeSeverityData[i].name;
//                         y = productComponentIssueTypeSeverityData[i].issues;

//                         seriesData.push({name: name, y: y});
//                     }

//                     currentSeriesData = [{
//                                             name: "Severity", 
//                                             colorByPoint: true, data: seriesData,
//                                             events: {
//                                                 click: function(e){
//                                                     gadgets.Hub.publish(SEVERITY_CHANNEL, e.point.name);
//                                                     gadgets.Hub.publish(SEVERITY_STATE_CHANNEL, "1345");
//                                                     currentState = "1345";
//                                                     currentSeverity = e.point.name;
//                                             }
//                                         }}];

//                     currentChartTitle = "under " + currentProduct + "-" + currentComponent + " of type '" + currentIssueType + "'";
//                     createChart();
//                 }
//             break;
//         case '154':
//             break;
//         case '412':
//             break;
//         case '413':
//             break;

//     }
// }


// function createChart(data){


//     // Create the chart
//     Highcharts.chart('container', {
//         chart: {
//             type: 'pie',
//         },
//         credits: {
//             text: "source : jira"
//         },
//         title: {
//             text: currentChartTitle,
//             widthAdjust: -100,
//             style: {
//                 fontSize : '14px'
//             }
//         },
//         plotOptions: {
//             pie: {
//                     allowPointSelect: true,
//                     cursor: 'pointer',
//                     dataLabels: {
//                         enabled: false
//                     },
//                     showInLegend: true
//                 }
//         },

//         tooltip: {
//             headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
//             pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
//         },

//         series: currentSeriesData,
//         exporting: {
//             buttons: {
//                 customButton: {
//                     symbol: 'circle',
//                     symbolStrokeWidth: 1,
//                     symbolFill: '#a4edba',
//                     symbolStroke: '#330033',
//                     _titleKey: 'backTitle',
//                     onclick: function() {
//                         initChart();
//                         gadgets.Hub.publish(COMPONENT_STATE_CHANNEL, "0");
//                     }
//                 }
//             }   
//         }

//     });


// }


