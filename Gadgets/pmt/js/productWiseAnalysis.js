//get summary years from Ballerina
var summaryArray = [];
var summaryArray2 = [];
var drillDown = [];
var drillDown2 = [];
var product = null;
var version = null;
var passVersion = null;
var listID = null;
var versionID = null;
var defaultTitle = "";
var drilldownTitle = "Reported Patch Summary in ";

// Create the chart summary chart initial - Reported Patches
function patchSummaryGraph(duration,start,end) {
    var flag = false;
    defaultTitle = "Reported Patches in "+start+' to '+end;
    summaryArray = [];
    drillDown = [];

    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-reportedPatchGraph/'+duration+'/'+start+'/'+end,
        async: false,
        success: function(data){
            if(!data.isEmpty){
                summaryArray = data.graphMainData;
                drillDown = data.graphDrillDownData;
            }else{
                flag = true;
            }
        }
    });

    if(!flag){
        if(duration === 'week'){
            document.getElementById('weekPatchReport').style.display = 'block';
        }else{
            document.getElementById('weekPatchReport').style.display = 'none';
        }
        createSummaryGraph(drilldownTitle,defaultTitle,summaryArray,drillDown,duration);
    }else{
        document.getElementById('graphDiv').innerHTML = '<h3 style="text-align:center; margin-top:10vh;">No patches reported in the selected time period</h3>'
    }

}
function createSummaryGraph(drilldownTitle,defaultTitle,summaryArray,drillDown,duration){
    var temp = "";
    if(duration === 'week'){
        temp = 'Week';
    }else if(duration === 'quater'){
        temp = 'Quarter';
    }
    var chart = Highcharts.chart('graphDiv', {
        chart: {
            type: 'column',
            events: {
                drilldown: function (e) {
                    chart.setTitle({text: drilldownTitle + e.point.name+' '+temp},{text: "Ordered by total patch count"});
                },
                drillup: function(e) {
                    chart.setTitle({ text: defaultTitle },{text: "Click on the columns to view more details.."});
                }
            }
        },title: {
            text: defaultTitle
        },
        subtitle: {
            text: 'Click on the columns to view more details..'
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
            name: 'All Reported Patches',
            colorByPoint: true,
            data: summaryArray
        }],
        drilldown: {
            series: drillDown
        }
    });
}

//Release trend graphs - TOTAL
function getCountsTotal(start,end){
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-total-product-summary/'+product+'/'+start+'/'+end,
        success: function(data){
            document.getElementById('pQueued').innerHTML = data.jsonResOfQueuedCounts[0].total;
            document.getElementById('pComplete').innerHTML = data.jsonResOfCompleteCounts[0].total;
            document.getElementById('pProcess').innerHTML = data.jsonResOfDevCounts[0].total;
            document.getElementById('bugCount').innerHTML = data.jsonResOfBugCount[0].bugs;
        }
    });

}
function totalProductDetails(duration,start,end) {
    //prepare feed json for the highchart
    var releaseTrend = [];
    var flag = false;

    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-total-release-trend/'+product+'/'+duration+'/'+start+'/'+end,
        async: false,
        success: function(data){
            if(!data.isEmpty){
                releaseTrend = data.totalReleaseTrend;
            }else{
                flag = true;
            }
        }
    });

    if(!flag){
        createVersionChart(releaseTrend,'All');
    }else{
        document.getElementById('container').innerHTML = '<h3 style="text-align:center; margin-top:10vh;">No patches released in the selected time period</h3>'
    }

}

//Release trend - ALL VERSION
function getAllVersionCount(start,end) {
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-total-product-summary/'+product+'/'+start+'/'+end,
        success: function(data){
            document.getElementById('pQueued').innerHTML = data.jsonResOfQueuedCounts[0].total;
            document.getElementById('pComplete').innerHTML = data.jsonResOfCompleteCounts[0].total;
            document.getElementById('pProcess').innerHTML = data.jsonResOfDevCounts[0].total;
            document.getElementById('bugCount').innerHTML = data.jsonResOfBugCount[0].bugs;
        }
    });
}
function allProductDetails(duration,start,end){
   //get all product versions
    var allVersions = [];
    var array = [];
    var childElement = document.getElementById('productVersion'+listID);
    var versionString = "";
    for (var ii = 0; ii < childElement.childNodes.length; ii++)
    {
        var childId = childElement.childNodes[ii].id;
        array.push(childId);
    }

    for(var y=0;y<array.length-2;y++){
        allVersions[y] = document.getElementById(array[y+2]).innerHTML.split(' ')[1].split('<')[0];
        versionString += allVersions[y]+'-';
    }
    // console.log(allVersions)
    versionString = versionString.substring(0, versionString.length-1);
    // console.log(allVersions);

    //get counts of all versions
    var allCounts = [];
    var category = [];
    var flag = false;
    // for(var q=0;q<allVersions.length;q++){
        // console.log('https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-all-version-release-trend/'+product+'/'+allVersions[q]+'/'+duration+'/'+start+'/'+end);
        $.ajax({
            type: "GET",
            url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-all-version-release-trend/'+product+'/'+versionString+'/'+duration+'/'+start+'/'+end,
            async: false,
            success: function(data){
                if(!jQuery.isEmptyObject(data)){
                    flag = true;
                }else{
                    flag = false;
                }
                allCounts= data.versionReleaseTrend;
            }
        });
    // }

    // //get category
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-category-alltrend/'+product+'/'+duration+'/'+start+'/'+end,
        async: false,
        success: function(data){
            if(!jQuery.isEmptyObject(data)){
                flag = true;
            }else{
                flag = false;
            }
            category = data;
        }
    });


    if(flag){
        var finalData = [];
        var categories = [];
        var finalCategory = [];
        var dump = []; //contain zero array length of categories

        if(category.length !== 1){
            for(var x=0; x<category.length;x++){
                categories[x]=category[x].TYPE.toString();
                dump[x]=0;
                if(duration === 'quarter'){
                    finalCategory[x] = category[x].YEAR.toString() +'-'+category[x].TYPE.toString();
                }else if(duration === 'month'){
                    finalCategory[x] = category[x].YEAR.toString() +'-'+months[category[x].TYPE -1];
                }else if(duration === 'week'){
                    // console.log(category[x].TYPE);
                    finalCategory[x] = getDateRangeOfWeek(parseInt(category[x].TYPE),parseInt(category[x].YEAR));
                }else{
                    finalCategory[x] =category[x].TYPE.toString();
                }
            }
        }else{
            categories[0]=category[0].TYPE.toString();
            dump[0]=0;
            if(duration === 'quarter'){
                finalCategory[0] = category[0].YEAR.toString() +'-'+category[0].TYPE.toString();
            }else if(duration === 'month'){
                finalCategory[0] = category[0].YEAR.toString() +'-'+months[category[0].TYPE -1];
            }else if(duration === 'week'){
                finalCategory[0] = getDateRangeOfWeek(parseInt(category[0].TYPE));
            }else{
                finalCategory[0] =category[0].TYPE.toString();
            }
        }

        // console.log(allNames[0].length);
        // console.log(allCounts);
        // console.log(category);
        // console.log(categories);
        var temp1 = [];
        for(var j=0;j<allCounts.length;j++){
            if(allCounts[j].length !== 0){
                var dump2 = [];
                if(allCounts[j].length !== 1){
                    if(allCounts[j].length === categories.length){
                        for(var k=0;k<allCounts[j].length;k++){
                            dump2[k]=parseInt(allCounts[j][k].total);
                        }
                        temp1.push(dump2);
                    }else{
                        for(var l=0;l<categories.length;l++){
                            var isFound = false;
                            for(var m=0;m<allCounts[j].length;m++){
                                if(allCounts[j][m].TYPE.toString()===categories[l] && category[l].YEAR.toString() === allCounts[j][m].YEAR.toString()){
                                    dump2[l] = parseInt(allCounts[j][m].total);
                                    isFound = true;
                                }
                            }
                            if(!isFound){
                                dump2[l] = 0;
                            }
                        }
                        temp1.push(dump2);
                    }

                }else{
                    for(var t=0; t<categories.length;t++){
                        if(allCounts[j][0].TYPE.toString()===categories[t] && category[t].YEAR.toString() === allCounts[j][0].YEAR.toString()){
                            dump2[t]=parseInt(allCounts[j][0].total);
                        }else{
                            dump2[t]=0;
                        }
                    }
                    temp1.push(dump2);
                }
            }else{
                temp1.push(dump);
            }
        }

        for(var z=0;z<allVersions.length;z++){
            var json={name:"x",data:2016};
            json.name = 'Version-'+allVersions[z];
            json.data = temp1[z];
            finalData.push(json)
        }

        // console.log(temp1);

        drawAllVersionChart(finalCategory,finalData);
    }else{
        document.getElementById('container').innerHTML = '<h3 style="text-align:center; margin-top:10vh;">No patches released in the selected time period</h3>'
    }

}

//Release trend - VERSION
function getCountVersion(start,end) {
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-version-product-version-summary/'+product+'/'+passVersion+'/'+start+'/'+end,
        success: function(data){
            document.getElementById('pQueued').innerHTML = data.jsonResOfQueuedCounts[0].total;
            document.getElementById('pComplete').innerHTML = data.jsonResOfCompleteCounts[0].total;
            document.getElementById('pProcess').innerHTML = data.jsonResOfDevCounts[0].total;
            document.getElementById('bugCount').innerHTML = data.jsonResOfBugCount[0].bugs;
        }
    });
}
function versionDetails(duration,start,end) {

    var releaseTrendVersion = [];
    var flag = false;
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-version-release-trend/'+product+'/'+passVersion+'/'+duration+'/'+start+'/'+end,
        async: false,
        success: function(data){
            if(!data.isEmpty){
                releaseTrendVersion = data.versionReleaseTrend;
            }else{
                flag = true;
            }
        }
    });

    if(!flag){
        createVersionChart(releaseTrendVersion,passVersion);
    }else{
        document.getElementById('container').innerHTML = '<h3 style="text-align:center; margin-top:10vh;">No patches released in the selected time period</h3>'
    }
}

//draw charts
function drawAllVersionChart(categories,finalData) {
    Highcharts.chart('container', {

        title: {
            text: 'Total Release Trend of '+product
        },
        xAxis: {
            categories:categories,
            type: 'category'
        },

        yAxis: {
            title: {
                text: 'Number of Patches'
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

        series: finalData,

        responsive: {
            rules: [{
                condition: {
                    maxWidth: 500
                },
                chartOptions: {
                    legend: {
                        layout: 'horizontal',
                        align: 'center',
                        verticalAlign: 'bottom'
                    }
                }
            }]
        }

    });
}
function createVersionChart(releaseTrend,version) {
    // console.log(totalProductVersionCount);

    var chart = new Highcharts.chart({
        chart: {
            defaultSeriesType: 'line',
            renderTo: 'container'
        },
        title: {
            text: 'Total Release Trend of '+product+'-'+version
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
            data: releaseTrend
        }]
    });
}

//change duration (week/month/quarter/year - Release Trend)
function changeDurationTrend(val) {
    changeDurationButtonCSS2(val);

    if(startDate === ''){

        if(version === 'Total Summary'){
            totalProductDetails(val,firstdate,today)
        }else if(version === 'All Versions'){
            allProductDetails(val,firstdate,today)
        }else{
            versionDetails(val,firstdate,today);
        }

    }else{

        if(version === 'Total Summary'){
            totalProductDetails(val,startDate,endDate);
        }else if(version === 'All Versions'){
            allProductDetails(val,startDate,endDate);
        }else{
            versionDetails(val,startDate,endDate);
        }
    }
    loadingIcon();
}

//functionality of close button
function closeDiv() {
    document.getElementById('prodcutDetails').style.display = 'none';
    document.getElementById('stackTab').style.display = 'none';
    document.getElementById('fullDiv').style.height = '730px';
}

//get firstDate from week number

function getDateRangeOfWeek(week,year) {

    // Jan 1 of 'year'
    var d = new Date(year, 0, 1),
        offset = d.getTimezoneOffset();

    // ISO: week 1 is the one with the year's first Thursday
    // so nearest Thursday: current date + 4 - current day number
    // Sunday is converted from 0 to 7
    d.setDate(d.getDate() + 4 - (d.getDay() || 7));

    // 7 days * (week - overlapping first week)
    d.setTime(d.getTime() + 7 * 24 * 60 * 60 * 1000
        * (week + (year == d.getFullYear() ? -1 : 0 )));

    // daylight savings fix
    d.setTime(d.getTime()
        + (d.getTimezoneOffset() - offset) * 60 * 1000);

    // back to Monday (from Thursday)
    d.setDate(d.getDate() - 3);

    return d.getFullYear() + "-" +  (d.getMonth()+1)+ "-" + d.getDate();
}

Date.prototype.getWeek = function() {
    var dt = new Date(this.getFullYear(),0,1);
    return Math.ceil((((this - dt) / 86400000) + dt.getDay()+1)/7);
};