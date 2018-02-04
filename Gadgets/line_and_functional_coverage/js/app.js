var baseUrl='https://digitalops.services.wso2.com:9096/';
//var baseUrl='https://localhost:9092/';

var selectedStartDate;
var selectedEndDate;

var currentLineCoverageFormat;
var currentLineCoverageSubTitle;
var currentLineCoverageXData;
var currentLineCoverageYData;
var currentLineCoverageColor;

var currentFunctionalCoverageFormat;
var currentFunctionalCoverageSubTitle;
var currentFunctionalCoverageXData;
var currentFunctionalCoverageYData;
var currentFunctionalCoverageColor;

var currentLineCoverageItemsTitle;
var currentLineCoverageItemsXData;
var currentLineCoverageItemsYData;
var lcXMax;

var currentFuncCoverageItemsTitle;
var currentFuncCoverageItemsXData;
var currentFuncCoverageItemsYData;
var fcXMax;

var currentAreaId;
var currentProductId;
var currentCategoryId;
var currentCategory;
var sameAreaIsSelected;

var currentData;

function initPage() {

    var sidePaneDetails;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/coverage/all/0',
        async: false,
        success: function(data){
            sidePaneDetails = data.data.items;
            currentData = data.data;
        }
    });

    currentCategory = "all";
    currentCategoryId = 0;
    sameAreaIsSelected = 0;

    loadSidePane(sidePaneDetails);
    initCoverageCharts();
}

function loadSidePane(sidePaneDetails) {

    var totalProducts = sidePaneDetails.length;

    for (var x = 0; x < totalProducts; x++) {
        document.getElementById('area').innerHTML += "<div class='panel' style='margin-top:0px; margin-bottom:-4px; font-size: 100%;'><button onclick='clickArea("+sidePaneDetails[x].id+")' data-parent='#area' href='#collapseArea"+(sidePaneDetails[x].id)+"' data-toggle='collapse' id='a"+(sidePaneDetails[x].id)+"' class='list-group-item'>"
            + sidePaneDetails[x].name        +
            "<span id='fc"+(parseInt(x)+1)+"' class='badge' style='width:2.7vw; font-size: 0.75vw; background-color:#206898;padding:3px 6px;'></span>" +
            "<span id='lc"+(parseInt(x)+1)+"' class='badge' style='width:2.7vw; font-size: 0.75vw; background-color:#00A388; padding:3px 6px;'></span></button>" +
            "<div id='collapseArea"+(sidePaneDetails[x].id)+"'  style='transition: all .8s ease;' class='panel-collapse collapse' role='tabpanel' aria-labelledby='headingOne'>" +
            "<div class='sidebarInside'>" +
            "<ul id='product"+(sidePaneDetails[x].id)+"' >"+
            ""+
            "</ul>"+
            "</div>" +
            "</div>" +
            "</div>"

        document.getElementById('lc'+(parseInt(x)+1)).innerHTML = (sidePaneDetails[x].lc.line_coverage).toFixed(2);
        document.getElementById('fc'+(parseInt(x)+1)).innerHTML = (sidePaneDetails[x].fc.functional_coverage).toFixed(2);
    }
}


function resetDashboardView() {
    var sidePaneDetails;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/coverage/all/0',
        async: false,
        success: function(data){

            sidePaneDetails = data.data.items;
            currentData = data.data;
        }
    });

    currentCategory = "all";
    currentCategoryId = 0;

    sameAreaIsSelected = 0;
    document.getElementById('area').innerHTML = "";

    loadSidePane(sidePaneDetails);
    initCoverageCharts();
}

function clickArea(areaId){
    document.getElementById('product'+(areaId)).innerHTML="";
    if(currentAreaId === areaId){
        sameAreaIsSelected = sameAreaIsSelected + 1;

        if(sameAreaIsSelected === 3){
            sameAreaIsSelected = 1;
        }

    }else{
        sameAreaIsSelected = 1;
    }

    currentCategoryId = areaId;
    currentCategory = "area";
    currentAreaId = areaId;

    var sidePaneDetails;

    if(sameAreaIsSelected === 2){
        currentCategoryId = 0;
        currentCategory = "all";

        $.ajax({
            type: "GET",
            url: baseUrl+'internal/product-quality/v1.0/coverage/all/0',
            async: false,
            success: function(data){
                currentData = data.data;
            }
        });

    }else{
        $.ajax({
            type: "GET",
            url: baseUrl+'internal/product-quality/v1.0/coverage/area/'+ areaId,
            async: false,
            success: function(data){

                sidePaneDetails = data.data.items;
                currentData = data.data;
            }
        });


        var totalProducts = sidePaneDetails.length;

        for(var y=0;y<totalProducts;y++){
            lc = (sidePaneDetails[y].lc.line_coverage).toFixed(2);
            fc = (sidePaneDetails[y].fc.functional_coverage).toFixed(2);

            document.getElementById('product'+(areaId)).innerHTML +=
                "<button class='btn-product list-group-item list-group-item-info' onclick='clickProduct("+(sidePaneDetails[y].id)+")' style='width:100%;text-align: left;' id='" + sidePaneDetails[y].id + "'>"+
                sidePaneDetails[y].name +
                "<span id='productfc"+areaId+(parseInt(y))+"' class='badge' style='min-width:2.7vw; font-size: 0.75vw; background-color:#206898;padding:3px 6px;'></span>" +
                "<span id='productlc"+areaId+(parseInt (y))+"' class='badge' style='min-width:2.7vw; font-size: 0.75vw; background-color:#00A388; padding:3px 6px;'></span></button>";

            document.getElementById('productlc'+areaId+(parseInt(y))).innerHTML = lc;
            document.getElementById('productfc'+areaId+(parseInt(y))).innerHTML = fc;

        }
    }
    initCoverageCharts();
}

function clickProduct(productId) {
    $('.btn-product').removeClass('btn-product-active').addClass('btn-product-inactive');
    $('#'+productId).removeClass('btn-product-inactive').addClass('btn-product-active');


    currentCategoryId = productId;
    currentProductId = productId;
    currentCategory = "product";

    var sidePaneDetails;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/coverage/product/'+productId ,
        async: false,
        success: function(data){

            sidePaneDetails = data.data.items;
            currentData = data.data;
        }
    });

    initCoverageCharts();
}

function initCoverageCharts() {
    var lineCoverageBarData=[];
    var lineCoverageChartYData=[];
    var lineCoverageChartXData=[];
    var funcCoverageBarData=[];
    var funcCoverageChartYData=[];
    var funcCoverageChartXData=[];

    if(currentCategory!=='product'){
        var itemsData=currentData.items;
        if(itemsData.length !== 0){
            if(itemsData.length < 5){
                lcXMax=itemsData.length-1;
                fcXMax=lcXMax;
            }else{
                lcXMax=4;
                fcXMax=4;
            }
            for(var i = 0; i < itemsData.length; i++){
                var name = itemsData[i].name;
                var id = itemsData[i].id;
                var lcy = parseFloat((itemsData[i].lc.line_coverage).toFixed(2));
                var lcColor;
                var fcColor;
                if(lcy<50){
                    lcColor='#ff424b';
                }else if(lcy>=50 && lcy<80){
                    lcColor='#ffff33';
                }else if(lcy>=80){
                    lcColor='#2eb82e';
                }
                var fcy = parseFloat((itemsData[i].fc.functional_coverage).toFixed(2));
                if(fcy<50){
                    fcColor='#ff424b';
                }else if(fcy>=50 && fcy<80){
                    fcColor='#ffff33';
                }else if(fcy>=80){
                    fcColor='#2eb82e';
                }
                lineCoverageChartYData.push({name:name,y:lcy,color:lcColor});
                funcCoverageChartYData.push({name:name,y:fcy,color:fcColor});
                if(itemsData[i].lc.lines_to_cover === 0){
                    lineCoverageChartXData.push([name,0]);
                }else{
                    lineCoverageChartXData.push([name,100]);
                }
                if(itemsData[i].fc.total_features=== 0){
                    funcCoverageChartXData.push([name,0]);
                }else{
                    funcCoverageChartXData.push([name,100]);
                }
            }
        }else{
            lcXMax=0;
            fcXMax=0;
        }
    }else{
        var lcItemsData=currentData.lc_items;
        var fcItemsData=currentData.fc_items;
        if(lcItemsData.length !== 0){
            if(lcItemsData.length < 5){
                lcXMax=lcItemsData.length-1;
            }else{
                lcXMax=4;
            }
            for(var i = 0; i < lcItemsData.length; i++){
                var name=lcItemsData[i].name;
                var id=lcItemsData[i].id;
                var lcy=parseFloat((lcItemsData[i].lc.line_coverage).toFixed(2));
                var lcColor;
                if(lcy<50){
                    lcColor='#ff424b';
                }else if(lcy>=50 && lcy<80){
                    lcColor='#ffff33';
                }else if(lcy>=80){
                    lcColor='#2eb82e';
                }
                lineCoverageChartYData.push({name:name,y:lcy,color:lcColor});
                if(lcItemsData[i].lc.lines_to_cover === 0){
                    lineCoverageChartXData.push([name,0]);
                }else{
                    lineCoverageChartXData.push([name,100]);
                }
            }
        }else{
            lcXMax=0;
        }
        if(fcItemsData.length !== 0){
            if(fcItemsData.length < 5){
                fcXMax=fcItemsData.length-1;
            }else{
                fcXMax=4;
            }
            for(var i = 0; i < fcItemsData.length; i++){
                var name=fcItemsData[i].name;
                var id=fcItemsData[i].id;
                var fcy=parseFloat((fcItemsData[i].fc.functional_coverage).toFixed(2));
                var fcColor;
                if(fcy<50){
                    fcColor='#ff424b';
                }else if(fcy>=50 && fcy<80){
                    fcColor='#ffff33';
                }else if(fcy>=80){
                    fcColor='#2eb82e';
                }
                funcCoverageChartYData.push({name:name,y:fcy,color:fcColor});
                if(fcItemsData[i].fc.total_features=== 0){
                    funcCoverageChartXData.push([name,0]);
                }else{
                    funcCoverageChartXData.push([name,100]);
                }
            }
        }else{
            fcXMax=0;
        }
    }
    currentLineCoverageItemsYData=lineCoverageChartYData;
    currentLineCoverageItemsXData=lineCoverageChartXData;
    currentFuncCoverageItemsYData=funcCoverageChartYData;
    currentFuncCoverageItemsXData=funcCoverageChartXData;
    if(currentData.line_cov.lines_to_cover=== 0){
        currentLineCoverageFormat='Line Coverage undefined.';
        currentLineCoverageYData=[0];
        currentLineCoverageXData=[0];
    }else{
        currentLineCoverageFormat='';
        currentLineCoverageSubTitle=currentData.line_cov.covered_lines+' / '+currentData.line_cov.lines_to_cover;
        var lcy=parseFloat((currentData.line_cov.line_coverage).toFixed(2));
        lineCoverageBarData.push(lcy);
        if(lcy<50){
            currentLineCoverageColor='#ff424b';
        }else if(lcy>=50 && lcy<80){
            currentLineCoverageColor='#ffff33';
        }else if(lcy>=80){
            currentLineCoverageColor='#2eb82e';
        }
        currentLineCoverageXData=[100];
        currentLineCoverageYData=lineCoverageBarData;
    }

    if(currentData.func_cov.total_features=== 0){
        currentFunctionalCoverageFormat='Functional Coverage undefined.';
        currentFunctionalCoverageXData=[0];
        currentFunctionalCoverageYData=[0];
    }else{
        currentFunctionalCoverageFormat='';
        currentFunctionalCoverageSubTitle=currentData.func_cov.passed_features +' / '+currentData.func_cov.total_features;
        var fcy=parseFloat((currentData.func_cov.functional_coverage).toFixed(2));
        funcCoverageBarData.push(fcy);
        if(fcy<50){
            currentFunctionalCoverageColor='#ff424b';
        }else if(fcy>=50 && fcy<80){
            currentFunctionalCoverageColor='#ffff33';
        }else if(fcy>=80){
            currentFunctionalCoverageColor='#2eb82e';
        }
        currentFunctionalCoverageXData=[100];
        currentFunctionalCoverageYData=funcCoverageBarData;
    }
    createLineCoverageBar();
    createFunctionalCoverageBar();
    createLineCoverageChart();
    createFunctionalCoverageChart();
    var dateFrom = moment().subtract(29, 'days');
    var dateTo= moment();
    selectedStartDate = dateFrom.format('YYYY-MM-DD');
    selectedEndDate = dateTo.format('YYYY-MM-DD');
    getTrendLineHistory("day");
}

function getTrendLineHistory(period) {

    var lcHistory;
    var fcHistory;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/coverage/history/'+ currentCategory + '/' + currentCategoryId,
        data:{
            dateFrom : this.startDate,
            dateTo : this.endDate,
            period: period
        },
        async: false,
        success: function(data){
            lcHistory = data.data.lc;
            fcHistory = data.data.fc;
        }
    });

    historyLCSeriesData = [];
    historyFCSeriesData = [];
    historyCoveredLines=[];
    historyUncoveredLines=[];


    for(var i = 0; i < lcHistory.length; i++){
        time = lcHistory[i].date.split("+");
        name = time[0];
        y1 = lcHistory[i].line_coverage;
        y2 = lcHistory[i].covered_lines;
        y3 = lcHistory[i].uncovered_lines;
        historyLCSeriesData.push({name: name, y: y1});
        historyCoveredLines.push({name: name, y: y2});
        historyUncoveredLines.push({name: name, y: y3});
    }
    for(var i = 0; i < fcHistory.length; i++){
        time = fcHistory[i].date.split("+");
        name = time[0];
        y = fcHistory[i].functional_coverage;
        historyFCSeriesData.push({name: name, y: y});
    }

    createTrendChart(historyLCSeriesData,historyFCSeriesData);
    createTrendChartForLineNumber(historyCoveredLines,historyUncoveredLines);

}

function createLineCoverageBar(){
    Highcharts.chart('line-coverage-bar', {
        title: {
            text: 'Line Coverage',
            align: 'center',
            margin: 10,
        },
        subtitle:{
            align: 'right',
            text:currentLineCoverageSubTitle,
        },
        chart: {
            type: 'bar',
            height: 100,
        },
        credits: false,
        tooltip: false,
        legend: false,
        navigation: {
        buttonOptions: {
          enabled: false
        }
        },
        xAxis: {
            visible: false,
        },
        yAxis: {
            visible: false,
            min: 0,
            max: 100,
        },
        series: [{
            data: currentLineCoverageXData,
            grouping: false,
            animation: false,
            enableMouseTracking: false,
            showInLegend: false,
            color: '#DBDDDD',
            pointWidth: 30,
            borderWidth: 0,
            borderRadiusTopLeft: '4px',
            borderRadiusTopRight: '4px',
            borderRadiusBottomLeft: '4px',
            borderRadiusBottomRight: '4px',
            dataLabels: {
              className: 'highlight',
              format: currentLineCoverageFormat,
              enabled: true,
              align: 'right',
              style: {
                color: 'black',
                textOutline: false,
              }
            }
            }, {
            enableMouseTracking: false,
            data: currentLineCoverageYData,
            color:currentLineCoverageColor,
            borderRadiusBottomLeft: '4px',
            borderRadiusBottomRight: '4px',
            borderWidth: 0,
            pointWidth: 30,
            animation: {
              duration: 250,
            },
            dataLabels: {
              enabled: true,
              inside: true,
              align: 'left',
              format: '{point.y}%',
              style: {
                color: 'black',
                textOutline: false,
              }
            }
        }]
    });
}

function createFunctionalCoverageBar(){
    Highcharts.chart('functional-coverage-bar', {
        title: {
            text: 'Functional Coverage',
            align: 'center',
            margin: 10,
        },
        subtitle:{
            align: 'right',
            text:currentFunctionalCoverageSubTitle,
        },
        chart: {
            type: 'bar',
            height: 100,
        },
        credits: false,
        tooltip: false,
        legend: false,
        navigation: {
        buttonOptions: {
          enabled: false
        }
        },
        xAxis: {
            visible: false,
        },
        yAxis: {
            visible: false,
            min: 0,
            max: 100,
        },
        series: [{
            data: currentFunctionalCoverageXData,
            grouping: false,
            animation: false,
            enableMouseTracking: false,
            showInLegend: false,
            color: '#DBDDDD',
            pointWidth: 30,
            borderWidth: 0,
            borderRadiusTopLeft: '4px',
            borderRadiusTopRight: '4px',
            borderRadiusBottomLeft: '4px',
            borderRadiusBottomRight: '4px',
            dataLabels: {
              className: 'highlight',
              format: currentFunctionalCoverageFormat,
              enabled: true,
              align: 'right',
              style: {
                color: 'black',
                textOutline: false,
              }
            }
            }, {
            enableMouseTracking: false,
            data: currentFunctionalCoverageYData,
            color:currentFunctionalCoverageColor,
            borderRadiusBottomLeft: '4px',
            borderRadiusBottomRight: '4px',
            borderWidth: 0,
            pointWidth: 30,
            animation: {
              duration: 250,
            },
            dataLabels: {
              enabled: true,
              inside: true,
              align: 'left',
              format: '{point.y}%',
              style: {
                color: 'black',
                textOutline: false,
              }
            }
        }]
    });
}

function createLineCoverageChart(){
    Highcharts.chart('line-coverage-container', {
        chart: {
            type: 'bar',
            marginLeft: 150
        },
        title: {
            text: 'Line Coverage Breakdown'
        },
        xAxis: {
            type: 'category',
            title: {
                text: null
            },
            min: 0,
            max: lcXMax,
            scrollbar: {
                enabled: true
            },
            tickLength: 0
        },
        yAxis: {
            min: 0,
            max: 100,
            title: {
                text: 'Line Coverage',
                align: 'high'
            }
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true
                }
            }
        },
        legend: {
            enabled: false
        },
        credits: {
            enabled: false
        },
        series: [{
        data: currentLineCoverageItemsXData,
        grouping: false,
        animation: false,
        enableMouseTracking: false,
        showInLegend: false,
        color: '#DBDDDD',
        pointWidth: 25,
        borderWidth: 0,

        dataLabels: {
          className: 'highlight',
          format: '',
          enabled: true,
          align: 'right',
          style: {
            color: 'black',
            textOutline: false,
          }
        }
      }, {
      	name:"Line-Coverage",
        enableMouseTracking: true,
        data: currentLineCoverageItemsYData,
        borderWidth: 0,
        pointWidth: 25,
        animation: {
          duration: 250,
        },
        dataLabels: {
          enabled: true,
          inside: true,
          align: 'left',
          format: '{point.y}%',
          style: {
            color: 'black',
            textOutline: false,
          }
        }
      }]
    });
}

function createFunctionalCoverageChart(){
    Highcharts.chart('functional-coverage-container', {
        chart: {
            type: 'bar',
            marginLeft: 150
        },
        title: {
            text: 'Functional Coverage Breakdown'
        },
        xAxis: {
            type: 'category',
            title: {
                text: null
            },
            min: 0,
            max: fcXMax,
            scrollbar: {
                enabled: true
            },
            tickLength: 0
        },
        yAxis: {
            min: 0,
            max: 100,
            title: {
                text: 'Functional Coverage',
                align: 'high'
            }
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true
                }
            }
        },
        legend: {
            enabled: false
        },
        credits: {
            enabled: false
        },
        series: [{
            data: currentFuncCoverageItemsXData,
            grouping: false,
            animation: false,
            enableMouseTracking: false,
            showInLegend: false,
            color: '#DBDDDD',
            pointWidth: 25,
            borderWidth: 0,

            dataLabels: {
              className: 'highlight',
              format: '',
              enabled: true,
              align: 'right',
              style: {
                color: 'white',
                textOutline: false,
              }
            }
            }, {
            name:"Functional-Coverage",
            enableMouseTracking: true,
            data: currentFuncCoverageItemsYData,
            borderWidth: 0,
            pointWidth: 25,
            animation: {
              duration: 250,
            },
            dataLabels: {
              enabled: true,
              inside: true,
              align: 'left',
              format: '{point.y}%',
              style: {
                color: 'black',
                textOutline: false,
              }
            }
        }]
    });
}

function createTrendChart(lcData,fcData){

    Highcharts.chart('trend-chart-container', {
        chart: {
            zoomType: 'x'
        },
        title: {
            text: ""
        },
        credits: {
            enabled: false
        },
        legend: {
            enabled: true,
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Coverage'
            },
            labels: {
                format: '{value}%'
            }
        },
        plotOptions: {
            series: {
                borderWidth: 0,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}%'
                }
            }
        },
//        tooltip: {
//            headerFormat: '<span style="font-size:0.7387508394895903vw">Coverage</span><br>',
//            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}%</b><br/>'
//        },
        series: [{
            name:'Functional Coverage',
            type: 'line',
            data: fcData,
            color:'#206898',
        },{
            name:'Line Coverage',
            type: 'line',
            data: lcData,
            color:'#00A388',

        }]

    });

}

function createTrendChartForLineNumber(coveredLines,uncoveredLines){

    Highcharts.chart('trend-for-lines', {
        chart: {
            zoomType: 'x'
        },
        title: {
            text: ""
        },
        credits: {
            enabled: false
        },
        legend: {
            enabled: true,
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Number of Lines'
            },
            labels: {
                format: '{value}'
            }
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
//        tooltip: {
//            headerFormat: '<span style="font-size:0.7387508394895903vw">Coverage</span><br>',
//            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}%</b><br/>'
//        },
        series: [{
            name:'Covered Lines',
            type: 'line',
            data: coveredLines,
            color:'#2eb82e',

        },{
            name:'Uncovered Lines',
            type: 'line',
            data: uncoveredLines,
            color:'#ff424b',
        }]

    });

}

function setSelectionDate(start, end) {
    selectedStartDate = start;
    selectedEndDate = end;
}

