var totalProducts = 0;
var versionCount = 0;
var firstdate = "";
var today = new Date();
var startDate = "";
var endDate = "";
var diffDays =0;
var yearGapFlag = false;
var monthGapFlag = false;
var menuDrillDown = [];
var menuVersionDrillDown = [];
var queuedDetails = [];
var queuedVersionDetails = [];
var devDetails = [];
var devVersionDetails = [];
var etaDetails = [];
var etaVersionDetails = [];
var target = "";
var dataSet2 = [];

var BALLERINA_URL = "digitalops.services.wso2.com:9092";
// var BALLERINA_URL = "localhost:9092";
// var BALLERINA_URL = "203.94.95.237:9092";
initLoadDashboard();
var flag1 = true;
var flag2 = true;

//load Queue age graph when requested
$('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    target = $(e.target).attr("href"); // activated tab

    if(target === '#lc'){
        document.getElementById('fullDiv').style.height = '1930px';
    }else if(target == '#age'){
        document.getElementById('fullDiv').style.height = '730px';
    }else{
        document.getElementById('fullDiv').style.height = '730px';
    }
    if(target === '#age' && flag1){
        ageGraph();
        flag1 = false;
    }else if(target === '#lc' && flag2){
        loadStackQueuedGraph();
        flag2 = false;

    }
});

function initLoadDashboard() {
    setDate();
    changeDurationButtonCSS('week');
    patchSummaryGraph('week',firstdate,today);
    showTotal(firstdate,today);
    // console.log(menuDrillDown);
    // console.log(menuVersionDrillDown);
    document.getElementById('product').innerHTML = "";

    for (var x = 0; x < totalProducts; x++) {
        document.getElementById('product').innerHTML += "<a href='#collapseProduct"+(parseInt(x)+1)+"' data-toggle='collapse' id='product"+(parseInt(x)+1)+"' class='list-group-item' style='font-size:1vw;'>"
            + menuDrillDown[x].products +
            "<span id='productETACount"+(parseInt(x)+1)+"' class='badge' style='background-color:#DC143C;display:none;'></span>" +
            "<span id='productDevCount"+(parseInt(x)+1)+"' class='badge' style='background-color:#4BC2DE;padding:3px 6px;'></span>" +
            "<span id='productCount"+(parseInt(x)+1)+"' class='badge' style='background-color:#F4A94E; padding:3px 6px;'></span></a>" +
            "<div id='collapseProduct"+(parseInt(x)+1)+"' class='panel-collapse collapse' role='tabpanel' aria-labelledby='headingOne'>" +
            "<div>" +
            "<ul id='productVersion"+(parseInt(x)+1)+"' style='font-size:1vw;'>"+
            ""+
            "</ul>"+
            "</div>" +
            "</div>"
    }

    //get versions to left side drill down
    for(var x=0;x<totalProducts;x++){
        //set first option as All versions
        document.getElementById('productVersion'+(parseInt(x)+1)).innerHTML +=
            "<button onclick='leftMenuClick("+(parseInt(x)+1)+","+1+")'  class='list-group-item list-group-item-info' style='width:100%; text-align: left;' id='subVersion1'>Total Summary"+
            "</button>" +
            "<button onclick='leftMenuClick("+(parseInt(x)+1)+","+0+")'  class='list-group-item list-group-item-info' style='width:100%;text-align: left;' id='subVersion0'>All Versions"+
            "</button>";
        for(var y=0;y<versionCount;y++){
            var element =  document.getElementById('product'+(parseInt(x)+1)).innerHTML;
            if(element.split("<span")[0].trim() === menuVersionDrillDown[y].PRODUCT_NAME){
                document.getElementById('productVersion' + (parseInt(x) + 1)).innerHTML +=
                    "<button onclick='leftMenuClick(" + (parseInt(x) + 1) + "," + (parseInt(y) + 1) + ")'  class='list-group-item list-group-item-info' style='width:100%;text-align: left;' id='subVersion" + (parseInt(y) + 1) + "'>Version " +
                    menuVersionDrillDown[y].VERSION +
                    "<span id='productVersionETACount"+(parseInt(y)+1)+"' class='badge' style='background-color:#DC143C;display:none;'></span>" +
                    "<span id='productVersionDevCount"+(parseInt(y)+1)+"' class='badge' style='background-color:#4BC2DE;padding:3px 6px;'></span>" +
                    "<span id='productVersionCount"+(parseInt(y)+1)+"' class='badge' style='background-color:#F4A94E; padding:3px 6px;'></span>"+
                    "</button>";
            }
        }
    }

    document.getElementById('day').style.display = 'block';
    document.getElementById('week').style.display = 'block';
    document.getElementById('month').style.display = 'none';
    document.getElementById('quarter').style.display = 'none';
    document.getElementById('year').style.display = 'none';

    loadPatchCountDrillDown(firstdate,today);
    loadPatchCountVersionDrillDown(firstdate,today);
}

function setDate(){
    //get dashboard-top div element counts
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();

    if(dd<10) {
        dd = '0'+dd;
    }

    if(mm<10) {
        mm = '0'+mm;
    }

    today = yyyy + '-' + mm + '-' + dd;
    var date = new Date();
    date.setDate(date.getDate() - 30);
    firstdate= date.toISOString().split('T')[0];

    var date1 = new Date(firstdate);
    var date2 = new Date(today);
    var timeDiff = Math.abs(date2.getTime() - date1.getTime());
    diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24)) +1 ;
}

function globalSubmit(){

    var dateRange = document.getElementById("date-picker").value;
    var dateArray = dateRange.split(' - ');
    startDate=dateArray[0];
    endDate = dateArray[1];

    //show total patch count in dashboard
    showTotal(startDate,endDate);
    loadPatchCountDrillDown(startDate,endDate);
    loadPatchCountVersionDrillDown(startDate,endDate);

    //generate graphs related to date range
    var date1 = new Date(startDate);
    var date2 = new Date(endDate);
    var timeDiff = Math.abs(date2.getTime() - date1.getTime());
    diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24)) +1 ;

    const YEAR = 365;
    const MONTH = 30;
    const WEEK = 7;

    document.getElementById('day').style.display = 'none';
    document.getElementById('week').style.display = 'none';
    document.getElementById('month').style.display = 'none';
    document.getElementById('quarter').style.display = 'none';
    document.getElementById('year').style.display = 'none';

    if(diffDays > YEAR || date1.getFullYear() !== date2.getFullYear()){
        document.getElementById('day').style.display = 'none';
        document.getElementById('week').style.display = 'block';
        document.getElementById('month').style.display = 'block';
        document.getElementById('quarter').style.display = 'block';
        document.getElementById('year').style.display = 'block';
        changeDurationButtonCSS('year');
        patchSummaryGraph('year',startDate,endDate);
    }else if(diffDays >= MONTH *3){
        document.getElementById('day').style.display = 'block';
        document.getElementById('week').style.display = 'block';
        document.getElementById('month').style.display = 'block';
        document.getElementById('quarter').style.display = 'block';
        changeDurationButtonCSS('month');
        patchSummaryGraph('month',startDate,endDate);
    }else if(diffDays > MONTH ){
        document.getElementById('day').style.display = 'block';
        document.getElementById('week').style.display = 'block';
        patchSummaryGraph('week',startDate,endDate);
    }else if(diffDays > WEEK){
        document.getElementById('day').style.display = 'block';
        document.getElementById('week').style.display = 'block';
        changeDurationButtonCSS('week');
        patchSummaryGraph('week',startDate,endDate);
    }else{
        document.getElementById('day').style.display = 'block';
        patchSummaryGraph('day',startDate,endDate);
    }

    //change left Side Bar Patch Count
    submitAndLeftBar(startDate,endDate);

    if(target === '#lc'){
        loadStackQueuedGraph();
        document.getElementById('fullDiv').style.height = '1630px';
    }

    loadingIcon();
}

//runs when clicks the product and version
function leftMenuClick(x,y) {
    var sDate = '';
    var eDate = '';
    //get startdate and enddate
    if(startDate === ''){
        sDate=firstdate;
        eDate=today;
    }else{
        sDate=startDate;
        eDate=endDate;
    }

    //set global variables
    listID = x;
    versionID=y;
    // alert(listID+'-'+versionID);

    product = document.getElementById('product' + x).innerHTML.split("<span")[0].trim(); //product name
    version = document.getElementById('subVersion' + y).innerHTML.split("<span")[0].trim(); //full version name
    passVersion = version.split(" ")[1]; //query version name


    //show product details
    document.getElementById('prodcutDetails').style.display = 'block';
    document.getElementById('fullDiv').style.height = '1500px';
    //console.log(version);

    //add header to the div
    document.getElementById('productName').innerHTML = product + " - " + version;

    //get details for each product and version
    submitAndLeftBar(sDate,eDate);
}

function submitAndLeftBar(sDate,eDate){
    var date1 = new Date(sDate);
    var date2 = new Date(eDate);

    if(version === 'All Versions'){
        getAllVersionCount(sDate,eDate);
        if(startDate !== '' && date1.getFullYear() !== date2.getFullYear()){
            changeDurationButtonCSS2('year');
            allProductDetails('year',sDate,eDate);
        }else{
            changeDurationButtonCSS2('week');
            allProductDetails('week',sDate,eDate);
        }

    }else if(version === 'Total Summary'){
        getCountsTotal(sDate,eDate);
        if(startDate !== '' && date1.getFullYear() !== date2.getFullYear()){
            changeDurationButtonCSS2('year');
            totalProductDetails('year',sDate,eDate);
        }else{
            changeDurationButtonCSS2('week');
            totalProductDetails('week',sDate,eDate);
        }

    }else{
        getCountVersion(sDate,eDate);
        if(startDate !== '' && date1.getFullYear() !== date2.getFullYear()){
            changeDurationButtonCSS2('year');
            versionDetails('year',sDate,eDate);
        }else{
            changeDurationButtonCSS2('week');
            versionDetails('week',sDate,eDate);
        }
    }

    loadingIcon();
}

function changeDuration(val){
    changeDurationButtonCSS(val);

    if(startDate === ""){
        patchSummaryGraph(val,firstdate,today);
    }else{
        patchSummaryGraph(val,startDate,endDate);
    }

    loadingIcon();

}

//generate different charts such as PIE,BAR, COLUMN charts from drop down
function changePattern(val) {
    var type = val;
    var summaryArray3 =[];
    var drillDown3=[];
    if(yearGapFlag | monthGapFlag){
        summaryArray3 = summaryArray2;
        drillDown3 = drillDown2;
    }else{
        summaryArray3 = summaryArray;
        drillDown3 = drillDown;
    }

    // console.log(summaryArray3);
    if(type !== 'line'){
        var chart = new Highcharts.chart({
            chart: {
                defaultSeriesType: type,
                renderTo: 'graphDiv',
                events: {
                    drilldown: function (e) {
                        chart.setTitle({text: drilldownTitle + e.point.name});
                        chart.setSubtitle("");
                    },
                    drillup: function(e) {
                        chart.setTitle({ text: defaultTitle });
                    }
                }
            },
            title: {
                text: defaultTitle
            },
            subtitle: {
                text: 'Click the columns to view more details..'
            },
            xAxis: {
                type: 'category'
            },
            yAxis: {
                title: {
                    text: 'Total patch count'
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
                }
            },

            tooltip: {
                headerFormat: '<span style="font-size:11px">{series.name} Summary</span><br>',
                pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b> of Total<br/>'
            },

            series: [{
                name: 'Patch',
                colorByPoint: true,
                data: summaryArray3
            }],
            drilldown: {
                series: drillDown3
            }
        });
    }else{
        var chart = new Highcharts.chart({
            chart: {
                defaultSeriesType: type,
                renderTo: 'graphDiv',
                events: {
                    drilldown: function (e) {
                        chart.setTitle({text: drilldownTitle + e.point.name});
                        chart.setSubtitle("");
                    },
                    drillup: function(e) {
                        chart.setTitle({ text: defaultTitle });
                    }
                }
            },
            title: {
                text: defaultTitle
            },
            subtitle: {
                text: 'Click the columns to view more details..'
            },
            xAxis: {
                type: 'category'
            },
            yAxis: {
                title: {
                    text: 'Total patch count'
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
                }
            },

            tooltip: {
                headerFormat: '<span style="font-size:11px">{series.name} Summary</span><br>',
                pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b> of Total<br/>'
            },

            series: [{
                name: 'Patch',
                color:'Black',
                data: summaryArray3
            }],
            drilldown: {
                series: drillDown3
            }
        });
    }

}

//function of dashboard top count card
function showTotal(start,end){
    $.ajax({
        type: "GET",
        async:false,
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/loaddashboard/'+start+'/'+end,
        success: function(jsonResponse){
            document.getElementById('proactive').innerHTML = jsonResponse.proactiveCount;
            document.getElementById('reactive').innerHTML = jsonResponse.reactiveCount;
            document.getElementById('unCategory').innerHTML = jsonResponse.uncategorizedCount;
            document.getElementById('queuedPatchCount').innerHTML = jsonResponse.yetToStartCount;
            document.getElementById('completePatchCount').innerHTML = jsonResponse.completedCount;
            document.getElementById('partiallyCompletePatchCount').innerHTML = jsonResponse.partiallyCompletedCount;
            document.getElementById('inProcessPatchCount').innerHTML = jsonResponse.inProgressCount;
            document.getElementById('overETAcount').innerHTML = '('+jsonResponse.ETACount+'<span style="font-size:12px;"> over ETA</span>)';
            totalProducts = jsonResponse.menuDetails.allProducts.length;
            menuDrillDown = jsonResponse.menuDetails.allProducts;
            versionCount = jsonResponse.menuDetails.allVersions.length;
            menuVersionDrillDown = jsonResponse.menuDetails.allVersions;

        }
    });
}

function loadPatchCountDrillDown(start,end){

    //show the number of patches exceed the ETA to drill down
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-menu-badgeCounts/'+start+'/'+end,
        async:false,
        success: function (data) {
            queuedDetails = data.jsonResOfQueuedCount;
            etaDetails = data.jsonResOfETACounts;
            devDetails = data.jsonResOfDEVCounts;
        }
    });


    if(!jQuery.isEmptyObject(queuedDetails)){
        var count = queuedDetails.length;
        for(var x=0;x<totalProducts;x++){
            document.getElementById('productCount'+(parseInt(x)+1)).innerHTML = '';
        }

        if(count === undefined){
            for(var x=0;x<totalProducts;x++){
                var element =  document.getElementById('product'+(parseInt(x)+1)).innerHTML;
                if(element.split("<span")[0].trim() === queuedDetails.PRODUCT_NAME.trim()){
                    document.getElementById('productCount'+(parseInt(x)+1)).innerHTML = queuedDetails.total;
                }
            }
        }else{
            for(var x=0;x<totalProducts;x++){
                for(var y=0;y<count;y++){
                    var element =  document.getElementById('product'+(parseInt(x)+1)).innerHTML;
                    if(element.split("<span")[0].trim() === queuedDetails[y].PRODUCT_NAME.trim()){
                        document.getElementById('productCount'+(parseInt(x)+1)).innerHTML = queuedDetails[y].total;
                    }
                }
            }
        }
    }else{
        for(var x=0;x<totalProducts;x++){
            document.getElementById('productCount'+(parseInt(x)+1)).innerHTML = '';
        }
    }

    if(!jQuery.isEmptyObject(etaDetails)){
        var count = etaDetails.length;

        for(var x=0;x<totalProducts;x++){
            document.getElementById('productETACount'+(parseInt(x)+1)).innerHTML = '';
        }

        if(count === undefined){
            for(var x=0;x<totalProducts;x++){
                var element =  document.getElementById('product'+(parseInt(x)+1)).innerHTML;
                if(element.split("<span")[0].trim() === etaDetails.PRODUCT_NAME.trim()){
                    document.getElementById('productETACount'+(parseInt(x)+1)).innerHTML = etaDetails.total;
                }
            }
        }else{
            for(var x=0;x<totalProducts;x++){
                for(var y=0;y<count;y++){
                    var element =  document.getElementById('product'+(parseInt(x)+1)).innerHTML;
                    if(element.split("<span")[0].trim() === etaDetails[y].PRODUCT_NAME.trim()){
                        document.getElementById('productETACount'+(parseInt(x)+1)).innerHTML = etaDetails[y].total;
                    }
                }
            }
        }

    }else{
        for(var x=0;x<totalProducts;x++){
            document.getElementById('productETACount'+(parseInt(x)+1)).innerHTML = '';
        }
    }

    if(!jQuery.isEmptyObject(devDetails)){
        var count = devDetails.length;
        for(var x=0;x<totalProducts;x++){
            document.getElementById('productDevCount'+(parseInt(x)+1)).innerHTML = '';
        }

        if(count === undefined){
            for(var x=0;x<totalProducts;x++){
                var element =  document.getElementById('product'+(parseInt(x)+1)).innerHTML;
                if(element.split("<span")[0].trim() === devDetails.PRODUCT_NAME.trim()){
                    document.getElementById('productDevCount'+(parseInt(x)+1)).innerHTML = "<span class='badge' style='background-color:#DC143C;padding:1px 3px 1px 3px;border-radius:0;border-top-left-radius:90%;border-bottom-left-radius:90%; width:13px;margin-left:-4px; margin-right:3px !important;'>"+ document.getElementById('productETACount'+(parseInt(x)+1)).innerHTML+"</span><span style='margin-top:2px;'>"+devDetails.total+"</span>";
                }else{
                    document.getElementById('productDevCount'+(parseInt(x)+1)).style.padding = '4px 6px';
                }
            }
        }else{
            for(var x=0;x<totalProducts;x++){
                for(var y=0;y<count;y++){
                    var element =  document.getElementById('product'+(parseInt(x)+1)).innerHTML;
                    if(element.split("<span")[0].trim() === devDetails[y].PRODUCT_NAME.trim()){
                        document.getElementById('productDevCount'+(parseInt(x)+1)).innerHTML = " <span class='badge' style='background-color:#DC143C;padding:1px 3px 1px 2px;border-radius:0;border-top-left-radius:90%;border-bottom-left-radius:90%; width:13px;margin-left:-4px; margin-right:3px !important;'>"+ document.getElementById('productETACount'+(parseInt(x)+1)).innerHTML+"</span><span style='margin-top:2px;'>" + devDetails[y].total+"</span>";
                    }
                }
            }
        }
    }else{
        for(var x=0;x<totalProducts;x++){
            document.getElementById('productDevCount'+(parseInt(x)+1)).innerHTML = '';
        }
    }
}

function loadPatchCountVersionDrillDown(start,end){

    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-menu-version-badgeCounts/'+start+'/'+end,
        async:false,
        success: function (data) {
            queuedVersionDetails = data.jsonResOfQueuedCount;
            etaVersionDetails = data.jsonResOfETACounts;
            devVersionDetails = data.jsonResOfDEVCounts;
        }
    });

    //set Queued patch count in version break down
    if(!jQuery.isEmptyObject(queuedVersionDetails)){
        var count = queuedVersionDetails.length;
        for(var x=1;x<versionCount;x++){
            if(document.getElementById('productVersionCount'+(parseInt(x)+1)) !== null){
                document.getElementById('productVersionCount'+(parseInt(x)+1)).innerHTML = '';
            }
        }

        if(count === undefined){
            for(var y=0;y<totalProducts;y++){
                var element =  document.getElementById('product'+(parseInt(y)+1)).innerHTML;
                if(element.split("<span")[0].trim() === queuedVersionDetails.PRODUCT_NAME.trim()){
                    var childVersions = [];
                    var childElement = document.getElementById('productVersion'+(y+1));
                    for (var ii = 0; ii < childElement.childNodes.length; ii++) {
                        var childId = childElement.childNodes[ii].id;
                        childVersions.push(childId);
                    }

                    for(var c=0;c<childVersions.length;c++){
                        if(document.getElementById(childVersions[c]).innerHTML.trim().split("<")[0] === "Version "+queuedVersionDetails.PRODUCT_VERSION.trim()){
                            var id_dump = document.getElementById(childVersions[c]).innerHTML.split("\"")[1];
                            var id_num = id_dump.split("Count")[1];
                            document.getElementById("productVersionCount"+id_num).innerHTML = queuedVersionDetails.total;
                            break;
                        }
                    }
                    break;
                }
            }
        }else{
            for(var x=0;x<count;x++){
                for(var y=0;y<totalProducts;y++){
                    var element =  document.getElementById('product'+(parseInt(y)+1)).innerHTML;
                    if(element.split("<span")[0].trim() === queuedVersionDetails[x].PRODUCT_NAME.trim()){
                        var childVersions = [];
                        var childElement = document.getElementById('productVersion'+(y+1));
                        for (var ii = 0; ii < childElement.childNodes.length; ii++) {
                            var childId = childElement.childNodes[ii].id;
                            childVersions.push(childId);
                        }

                        for(var c=0;c<childVersions.length;c++){
                            if(document.getElementById(childVersions[c]).innerHTML.trim().split("<")[0] === "Version "+queuedVersionDetails[x].PRODUCT_VERSION.trim()){
                                var id_dump = document.getElementById(childVersions[c]).innerHTML.split("\"")[1];
                                var id_num = id_dump.split("Count")[1];
                                document.getElementById("productVersionCount"+id_num).innerHTML = queuedVersionDetails[x].total;
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }else{
        for(var x=1;x<versionCount;x++){
            if(document.getElementById('productVersionCount'+(parseInt(x)+1)) !== null){
                document.getElementById('productVersionCount'+(parseInt(x)+1)).innerHTML = '';
            }
        }
    }

    //set ETA patch count in version break down
    if(!jQuery.isEmptyObject(etaVersionDetails)){
        var count = etaVersionDetails.length;
        for(var x=1;x<versionCount;x++){
            if(document.getElementById('productVersionETACount'+(parseInt(x)+1)) !== null){
                document.getElementById('productVersionETACount'+(parseInt(x)+1)).innerHTML = '';
            }
        }

        if(count === undefined){
            for(var y=0;y<totalProducts;y++){
                var element =  document.getElementById('product'+(parseInt(y)+1)).innerHTML;
                if(element.split("<span")[0].trim() === etaVersionDetails.PRODUCT_NAME.trim()){
                    var childVersions = [];
                    var childElement = document.getElementById('productVersion'+(y+1));
                    for (var ii = 0; ii < childElement.childNodes.length; ii++) {
                        var childId = childElement.childNodes[ii].id;
                        childVersions.push(childId);
                    }

                    for(var c=0;c<childVersions.length;c++){
                        if(document.getElementById(childVersions[c]).innerHTML.trim().split("<")[0] === "Version "+etaVersionDetails.PRODUCT_VERSION.trim()){
                            var id_dump = document.getElementById(childVersions[c]).innerHTML.split("\"")[1];
                            var id_num = id_dump.split("Count")[1];
                            document.getElementById("productVersionETACount"+id_num).innerHTML = etaVersionDetails.total;
                            break;
                        }
                    }
                    break;
                }
            }
        }else{
            for(var x=0;x<count;x++){
                for(var y=0;y<totalProducts;y++){
                    var element =  document.getElementById('product'+(parseInt(y)+1)).innerHTML;
                    if(element.split("<span")[0].trim() === etaVersionDetails[x].PRODUCT_NAME.trim()){
                        var childVersions = [];
                        var childElement = document.getElementById('productVersion'+(y+1));
                        for (var ii = 0; ii < childElement.childNodes.length; ii++) {
                            var childId = childElement.childNodes[ii].id;
                            childVersions.push(childId);
                        }

                        for(var c=0;c<childVersions.length;c++){
                            if(document.getElementById(childVersions[c]).innerHTML.trim().split("<")[0] === "Version "+etaVersionDetails[x].PRODUCT_VERSION.trim()){
                                var id_dump = document.getElementById(childVersions[c]).innerHTML.split("\"")[1];
                                var id_num = id_dump.split("Count")[1];
                                document.getElementById("productVersionETACount"+id_num).innerHTML = etaVersionDetails[x].total;
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }else{
        for(var x=1;x<versionCount;x++){
            if(document.getElementById('productVersionETACount'+(parseInt(x)+1)) !== null){
                document.getElementById('productVersionETACount'+(parseInt(x)+1)).innerHTML = '';
            }
        }
    }

    //set DEV patch count in version break down
    if(!jQuery.isEmptyObject(devVersionDetails)){
        var count = devVersionDetails.length;
        for(var x=1;x<versionCount;x++){
            if(document.getElementById('productVersionDevCount'+(parseInt(x)+1)) !== null){
                document.getElementById('productVersionDevCount'+(parseInt(x)+1)).innerHTML = '';
            }
        }

        if(count === undefined){
            for(var y=0;y<totalProducts;y++){
                var element =  document.getElementById('product'+(parseInt(y)+1)).innerHTML;
                if(element.split("<span")[0].trim() === devVersionDetails.PRODUCT_NAME.trim()){
                    var childVersions = [];
                    var childElement = document.getElementById('productVersion'+(y+1));
                    for (var ii = 0; ii < childElement.childNodes.length; ii++) {
                        var childId = childElement.childNodes[ii].id;
                        childVersions.push(childId);
                    }

                    for(var c=0;c<childVersions.length;c++){
                        if(document.getElementById(childVersions[c]).innerHTML.trim().split("<")[0] === "Version "+devVersionDetails.PRODUCT_VERSION.trim()){
                            var id_dump = document.getElementById(childVersions[c]).innerHTML.split("\"")[1];
                            var id_num = id_dump.split("Count")[1];
                            document.getElementById("productVersionDevCount"+id_num).innerHTML = " <span class='badge' style='background-color:#DC143C;padding:1px 3px 1px 2px;border-radius:0;border-top-left-radius:90%;border-bottom-left-radius:90%; width:13px;margin-left:-4px; margin-right:3px !important;'>"+ document.getElementById(document.getElementById(childVersions[c]).innerHTML.split("\"")[1]).innerHTML+"</span><span style='margin-top:2px;'>" + devVersionDetails.total+"</span>";
                            break;
                        }
                    }
                    break;
                }
            }
        }else{
            for(var x=0;x<count;x++){
                for(var y=0;y<totalProducts;y++){
                    var element =  document.getElementById('product'+(parseInt(y)+1)).innerHTML;
                    if(element.split("<span")[0].trim() === devVersionDetails[x].PRODUCT_NAME.trim()){
                        var childVersions = [];
                        var childElement = document.getElementById('productVersion'+(y+1));
                        for (var ii = 0; ii < childElement.childNodes.length; ii++) {
                            var childId = childElement.childNodes[ii].id;
                            childVersions.push(childId);
                        }

                        for(var c=0;c<childVersions.length;c++){
                            if(document.getElementById(childVersions[c]).innerHTML.trim().split("<")[0] === "Version "+devVersionDetails[x].PRODUCT_VERSION.trim()){
                                var id_dump = document.getElementById(childVersions[c]).innerHTML.split("\"")[1];
                                var id_num = id_dump.split("Count")[1];
                                document.getElementById("productVersionDevCount"+id_num).innerHTML = " <span class='badge' style='background-color:#DC143C;padding:1px 3px 1px 2px;border-radius:0;border-top-left-radius:90%;border-bottom-left-radius:90%; width:13px;margin-left:-4px; margin-right:3px !important;'>"+ document.getElementById(document.getElementById(childVersions[c]).innerHTML.split("\"")[1]).innerHTML+"</span><span style='margin-top:2px;'>" + devVersionDetails[x].total+"</span>";
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }else{
        for(var x=1;x<versionCount;x++){
            if(document.getElementById('productVersionDevCount'+(parseInt(x)+1)) !== null){
                document.getElementById('productVersionDevCount'+(parseInt(x)+1)).innerHTML = '';
            }
        }
    }
}

function changeDurationButtonCSS(val){
    var duration = ['day','week','month','quarter','year'];
    for(var i=0;i<duration.length;i++){
        if(val === duration[i]){
            document.getElementById(duration[i]).className = 'btn btn-default active';
        }else{
            document.getElementById(duration[i]).className = 'btn btn-default';
        }
    }
}

function changeDurationButtonCSS2(val){
    var duration = ['week','month','quarter','year'];
    for(var i=0;i<duration.length;i++){
        if(val === duration[i]){
            document.getElementById(duration[i]+'2').className = 'btn btn-default active';
        }else{
            document.getElementById(duration[i]+'2').className = 'btn btn-default';
        }
    }
}

function loadPatchDetails(type) {
    var start = "";
    var end = "";
    if(startDate === ""){
        start = firstdate;
        end = today;
    }else{
        start = startDate;
        end = endDate;
    }

    document.getElementById('popupInner').innerHTML = "No any patch details during this date range";

    if(type === 'queue'){
        document.getElementById('myModalLabel').innerHTML = "Yet to Start Patch Details</h3>";
        $.ajax({
            type: "GET",
            url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/get-queue-details/'+start+'/'+end,
            success: function(data){
                var count = data.length;
                document.getElementById('popupInner').innerHTML = "";

                for(var x=0;x<count;x++){
                    document.getElementById('popupInner').innerHTML += "<tr>" +
                        "<td>"+(parseInt(x)+1)+"</td>" +
                        "<td><a href='"+data[x].SUPPORT_JIRA+"' target='_blank'>"+data[x].SUPPORT_JIRA+"</a></td>" +
                        "<td>"+data[x].PRODUCT_NAME+"</td>" +
                        "<td>"+data[x].PRODUCT_VERSION+"</td>" +
                        "<td>"+data[x].CLIENT+"</td>" +
                        "<td>"+data[x].REPORTER+"</td>" +
                        "<td>"+data[x].ASSIGNED_TO+"</td>" +
                        "<td>"+data[x].REPORT_DATE+"</td>" +
                        "</tr>"
                }
            }
        });

        $("#myModal").modal('show');

    }else if(type === 'dev'){
        document.getElementById('myModalLabel2').innerHTML = "In Progress Patch Details";
        $.ajax({
            type: "GET",
            url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/get-dev-details/'+start+'/'+end,
            success: function(data){
                var count = data.length;
                document.getElementById('popupInner2').innerHTML = "";

                if(count === undefined){
                    if(data.WORST_CASE_ESTIMATE.split('+')[0] < end ){
                        document.getElementById('popupInner2').innerHTML += "<tr style='background-color:#F2DEDE;color:#A94442;'>" +
                            "<td>"+1+"</td>" +
                            "<td><a href='"+data.SUPPORT_JIRA+"' target='_blank'>"+data.SUPPORT_JIRA+"</a></td>" +
                            "<td>"+data.PATCH_NAME+"</td>" +
                            "<td>"+data.PRODUCT_NAME+"</td>" +
                            "<td>"+data.PRODUCT_VERSION+"</td>" +
                            "<td>"+data.CLIENT+"</td>" +
                            "<td>"+data.DEVELOPED_BY+"</td>" +
                            "<td>"+data.ASSIGNED_TO+"</td>" +
                            "<td>"+data.REPORT_DATE+"</td>" +
                            "</tr>"
                    }else{
                        document.getElementById('popupInner2').innerHTML += "<tr>" +
                            "<td>"+1+"</td>" +
                            "<td><a href='"+data.SUPPORT_JIRA+"' target='_blank'>"+data.SUPPORT_JIRA+"</a></td>" +
                            "<td>"+data.PATCH_NAME+"</td>" +
                            "<td>"+data.PRODUCT_NAME+"</td>" +
                            "<td>"+data.PRODUCT_VERSION+"</td>" +
                            "<td>"+data.CLIENT+"</td>" +
                            "<td>"+data.DEVELOPED_BY+"</td>" +
                            "<td>"+data.ASSIGNED_TO+"</td>" +
                            "<td>"+data.REPORT_DATE+"</td>" +
                            "</tr>"
                    }
                }else{
                    for(var x=0;x<count;x++){
                        if(data[x].WORST_CASE_ESTIMATE.split('+')[0] < end ){
                            document.getElementById('popupInner2').innerHTML += "<tr style='background-color:#F2DEDE;color:#A94442;'>" +
                                "<td>"+(parseInt(x)+1)+"</td>" +
                                "<td><a href='"+data[x].SUPPORT_JIRA+"' target='_blank'>"+data[x].SUPPORT_JIRA+"</a></td>" +
                                "<td>"+data[x].PATCH_NAME+"</td>" +
                                "<td>"+data[x].PRODUCT_NAME+"</td>" +
                                "<td>"+data[x].PRODUCT_VERSION+"</td>" +
                                "<td>"+data[x].CLIENT+"</td>" +
                                "<td>"+data[x].DEVELOPED_BY+"</td>" +
                                "<td>"+data[x].ASSIGNED_TO+"</td>" +
                                "<td>"+data[x].REPORT_DATE+"</td>" +
                                "</tr>"
                        }else{
                            document.getElementById('popupInner2').innerHTML += "<tr>" +
                                "<td>"+(parseInt(x)+1)+"</td>" +
                                "<td><a href='"+data[x].SUPPORT_JIRA+"' target='_blank'>"+data[x].SUPPORT_JIRA+"</a></td>" +
                                "<td>"+data[x].PATCH_NAME+"</td>" +
                                "<td>"+data[x].PRODUCT_NAME+"</td>" +
                                "<td>"+data[x].PRODUCT_VERSION+"</td>" +
                                "<td>"+data[x].CLIENT+"</td>" +
                                "<td>"+data[x].DEVELOPED_BY+"</td>" +
                                "<td>"+data[x].ASSIGNED_TO+"</td>" +
                                "<td>"+data[x].REPORT_DATE+"</td>" +
                                "</tr>"
                        }

                    }
                }
            }
        });

        $("#myModal2").modal('show');

    }else if(type === 'complete'){
        var completedPatches = [];
        dataSet2 = [];

        document.getElementById('myModalLabel3').innerHTML = "Completed / Partially Completed Patch Details";
        $.ajax({
            type: "GET",
            url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/get-complete-details/'+start+'/'+end,
            async:false,
            success: function(data){
                completedPatches = data;
            }
        });
        // console.log(completedPatches);

        $('#completedAndPartiallyPatchDetails').DataTable().destroy();

        for(var x=0;x<completedPatches.length;x++){


            var el = [
                completedPatches[x].SUPPORT_JIRA,
                completedPatches[x].PATCH_NAME,
                completedPatches[x].PRODUCT_NAME,
                completedPatches[x].PRODUCT_VERSION,
                completedPatches[x].CLIENT,
                completedPatches[x].DEVELOPED_BY,
                completedPatches[x].ASSIGNED_TO,
                completedPatches[x].LC_STATE
            ];

            dataSet2[x] = el;
        }

        $('#completedAndPartiallyPatchDetails').DataTable({
            data: dataSet2,
            columns: [
                { title: "Support JIRA" },
                { title: "Patch Name" },
                { title: "Product Name" },
                { title: "Version" },
                { title: "Client" },
                { title: "Developed By" },
                { title: "Team Lead" },
                { title: "Patch State" }
            ],
            "aoColumnDefs": [
                { "render": function(data, type, row, meta){data = '<a href="' + data + '" target="_blank">' + data + '</a>';return data;}, "aTargets": [ 0 ] }
            ]
        });

        $("#myModal3").modal('show');
    }
}

function loadingIcon(){
    // document.getElementById('loading').style.backgroundColor="rgba(244,243,239,0.9)";
    // document.getElementById('loading').style.display="block";
    // $('[data-toggle="loading"]').loading('show');
    // setTimeout(function() {
    //     $('[data-toggle="loading"]').loading('show');
    //     document.getElementById('loading').style.display="none";
    // });
}
