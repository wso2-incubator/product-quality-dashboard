//var BALLERINA_URL = "localhost:9092";
var BALLERINA_URL = "digitalops.services.wso2.com:9092";

var firstdate = "";
var today = new Date();
var startDate = "";
var endDate = "";
var totalBuildData = [];

var currentProduct ="";
var authorizationToken = "7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8";

loadDashboard();

function loadDashboard(){
    setDate();
    var allProducts =loadDataFromServices(firstdate,today);
    loadBuildData(allProducts);
    loadFailureFrequencyChart(allProducts);
    createFailureReasonPieChart(allProducts.failureReasons, allProducts.failureReasonsDrilldown);
}

function globalSubmit(){
    var dateRange = document.getElementById("date-picker").value;
    var dateArray = dateRange.split(' - ');
    startDate=dateArray[0];
    endDate = dateArray[1];

    var allProducts = loadDataFromServices(startDate,endDate);
    loadBuildData(allProducts);
    loadFailureFrequencyChart(allProducts);
    createFailureReasonPieChart(allProducts.failureReasons, allProducts.failureReasonsDrilldown);
}

function loadDataFromServices(start,end){
    var allProducts = [];

    $.ajax({
        type: "GET",
        data: {
            ballerinaAuth: authorizationToken
        },
        url: 'https://'+BALLERINA_URL+'/jenkins-get-build-data/load-jenkins-dashboard/'+start+'/'+end,
        async:false,
        success: function (data) {
            allProducts = data;
        }
    });

    return allProducts;
}

function areaOnClick(product){
    var productData = [];
    var start="";
    var end ="";
    currentProduct = product;

    if(startDate === ""){
        start = firstdate;
        end = today;
    }else{
        start = startDate;
        end = endDate;
    }

    //adding area rates
    for(var i=0; i< totalBuildData.buildData.length;i++){
        if(totalBuildData.buildData[i].productArea === product){

            document.getElementById('areaSuccess').innerHTML = totalBuildData.buildData[i].successRate;
            document.getElementById('areaFailure').innerHTML = totalBuildData.buildData[i].failureRate;
            document.getElementById('areaStability').innerHTML = "<img src='/portal/store/wso2.com/fs/gadget/jenkins_build_statistics/images/jenkins_lables/"+totalBuildData.buildData[i].stability+".png' class='img-responsive' style='float:left;margin-top:-5px; margin-left:15px;height:40px;'>";
        }
    }

    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/jenkins-get-build-data/area-popup/'+product+'/'+start+'/'+end,
        async:false,
        success: function (data) {
            productData = data;
        }
    });

    document.getElementById('product').innerHTML = product;
    document.getElementById('productComponentCount').innerHTML = productData.total;

    document.getElementById('components').innerHTML ="";
    for (var x = 0; x < productData.allComponents.length; x++) {
        var num = (parseInt(x)+1);
        document.getElementById('components').innerHTML += "<a href='#collapseProduct"+(parseInt(x)+1)+"' data-toggle='collapse' id='component"+(parseInt(x)+1)+"' class='list-group-item' style='font-size:1vw;' onclick='clickOneComponentForCulprits("+num+")'>"+productData.allComponents[x].component+
            "<span id='failureCount"+(parseInt(x)+1)+"' class='badge' style='background-color:#FE646E;padding:3px 6px;'>0</span>" +
            "<span id='successCount"+(parseInt(x)+1)+"' class='badge' style='background-color:#8ac417; padding:3px 6px;'>0</span></a>";
    }

    for(var t=0; t<productData.allComponents.length; t++){
        var currentComponent = document.getElementById('component'+(parseInt(t)+1)+'').innerHTML.split('<')[0];

        for(var z=0; z < totalBuildData.componentWiseBuildData.length; z++){
            if(totalBuildData.componentWiseBuildData[z].productArea === product){
                for(var w = 0; w < totalBuildData.componentWiseBuildData[z].components.length; w++){
                    if(currentComponent === totalBuildData.componentWiseBuildData[z].components[w].componentName){
                        var currentFailureCount = document.getElementById('failureCount'+(parseInt(t)+1)+'').innerHTML;
                        var currentSuccessCount = document.getElementById('successCount'+(parseInt(t)+1)+'').innerHTML;
                        document.getElementById('successCount'+(parseInt(t)+1)+'').innerHTML = (parseInt(currentSuccessCount) + parseInt(totalBuildData.componentWiseBuildData[z].components[w].successBuilds));
                        document.getElementById('failureCount'+(parseInt(t)+1)+'').innerHTML = (parseInt(currentFailureCount) + parseInt(totalBuildData.componentWiseBuildData[z].components[w].failureBuilds));
                    }
                }
            }
        }

    }

    //hide if success or failure build count is zero
    // for(var y=0; y < productData.allComponents.length; y++){
    //     if(parseInt(document.getElementById('failureCount'+(parseInt(y)+1)+'').innerHTML) === 0){
    //         document.getElementById('failureCount'+(parseInt(y)+1)+'').style.display = 'none';
    //     }
    //
    //     if(parseInt(document.getElementById('successCount'+(parseInt(y)+1)+'').innerHTML) === 0){
    //         document.getElementById('successCount'+(parseInt(y)+1)+'').style.display = 'none';
    //     }
    // }

    //list down the culprits of failures
    document.getElementById('tableBodyOfFailures').innerHTML = "";
    if(productData.failureDetails.length > 0){
        for(var d=0; d<productData.failureDetails.length; d++){
            if(productData.failureDetails[d].culprits === ""){
                productData.failureDetails[d].culprits = "none";
            }

            document.getElementById('tableBodyOfFailures').innerHTML +=
                "<tr>"+
                "<td>"+productData.failureDetails[d].component+"</td>"+
                "<td>"+productData.failureDetails[d].committedBy+"</td>"+
                "<td>"+productData.failureDetails[d].PRmergedName+"</td>" +
                "<td>"+productData.failureDetails[d].culprits+"</td>" +
                "<td><a href='"+productData.failureDetails[d].commitUrl+"' target='_blank'>GitHub Link</a></td>" +
                "<td><a href='"+productData.failureDetails[d].jobUrl+"' target='_blank'>Job Link</a></td>" +
                "</tr>";

        }
    }else{
        document.getElementById('tableBodyOfFailures').innerHTML = "<h5>No any failures occurred in this date range</h5>";
    }

    if(productData.failureReasons.length > 0){
        createFailureReasonPieChartForProduct(productData.failureReasons);
    }else{
        document.getElementById('container2').innerHTML = "<h5>No any failures occurred in this date range</h5>"
    }
    $("#myModal").modal('show');
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
    date.setDate(date.getDate() - 6);
    firstdate= date.toISOString().split('T')[0];
}

function loadBuildData(dataSet){
    totalBuildData = dataSet;
    dataSet = dataSet.buildData;

    document.getElementById('product-list').innerText = "";
    for(var x = 0; x< dataSet.length; x++){

        if(dataSet[x].successRate !== "N/A"){
            var temp = Math.floor(dataSet[x].successRate);
            dataSet[x].successRate = Math.floor(dataSet[x].successRate)+"%";
            dataSet[x].failureRate = (100 - temp)+"%";
        }else{
            dataSet[x].successRate = "N/A";
            dataSet[x].failureRate = "N/A";
        }

        document.getElementById('product-list').innerHTML +=
            "<div class='list-group' id='accordion' role='tablist' aria-multiselectable='true'>" +
            "<div class='panel panel-default ' style='margin-top:-21px;'>" +
            "<a role='button' data-toggle='collapse' data-parent='#accordion' href='#collapseOne' >" +
            "<div class='panel-heading' role='tab' id='headingOne' style='padding-left:10px; padding-right:0;' onclick=\"areaOnClick('"+dataSet[x].productArea+"')\">" +
            "<div class='row'>" +
            "<div class='col-xs-6'>" +
            "<p class='panel-title' style='font-size:1vw; margin-top:7px;' >"
            + dataSet[x].productArea+
            "</p>" +
            "</div>" +
            "<div class='col-xs-2'>" +
            "<p class='panel-title' style='font-size:1.1vw; margin-top:7px;'>"+ dataSet[x].successRate+"</p>" +
            "</div>" +
            "<div class='col-xs-2'>" +
            "<p class='panel-title' style='font-size:1.1vw; margin-top:7px;'>"+dataSet[x].failureRate+"</p>" +
            "</div>" +
            "<div class='col-xs-2'>" +
            "<img src='/portal/store/wso2.com/fs/gadget/jenkins_build_statistics/images/jenkins_lables/"+dataSet[x].stability+".png' class='img-responsive pull-left' style='margin-left:5px; height:33px;' />" +
            "</div>" +
            "</div>" +
            "</div>" +
            "</a>" +
            "</div>" +
            "</div>";

    }

    //Failure Contributors table
    document.getElementById('tableBodyOfContributors').innerHTML = "";
    if(totalBuildData.failureContributors.length > 0){
        for(var d=0; d<totalBuildData.failureContributors.length; d++){
            document.getElementById('tableBodyOfContributors').innerHTML +=
                "<tr>"+
                "<td style='text-align: center;'>"+totalBuildData.failureContributors[d].total+"</td>"+
                "<td style='text-align: center;'>"+totalBuildData.failureContributors[d].committedBy+"</td>"+
                "<td width='300' height='20'  style='text-align: center;'> <div style='width:300px;height:20px;overflow:auto; padding:0 auto;'>"+totalBuildData.failureContributors[d].PRmergedBy+"</div></td>" +
                "</tr>";

        }
    }else{
        document.getElementById('tableBodyOfContributors').innerHTML = "<h5>No any failures contributors in this date range</h5>";
    }
}

function clickOneComponentForCulprits(id){
    var start="";
    var end ="";
    var culpritsData = [];

    if(startDate === ""){
        start = firstdate;
        end = today;
    }else{
        start = startDate;
        end = endDate;
    }

    if(id !== "reset"){
        var idOfComponent = "component"+id;
        var innerHTTML = document.getElementById(idOfComponent).innerHTML.split("<")[0];

        $.ajax({
            type: "GET",
            url: 'https://'+BALLERINA_URL+'/jenkins-get-build-data/component-culprits/'+currentProduct+'/'+innerHTTML+'/'+start+'/'+end,
            async:false,
            success: function (data) {
                culpritsData = data;
            }
        });

        document.getElementById('resetButton').style.display='block';

    }else{
        $.ajax({
            type: "GET",
            url: 'https://'+BALLERINA_URL+'/jenkins-get-build-data/component-culprits/'+currentProduct+'/all/'+start+'/'+end,
            async:false,
            success: function (data) {
                culpritsData = data;
            }
        });

        document.getElementById('resetButton').style.display='none';
    }

    //list down the culprits of failures
    document.getElementById('tableBodyOfFailures').innerHTML = "";
    if(culpritsData.length > 0){
        for(var d=0; d<culpritsData.length; d++){
            if(culpritsData[d].culprits === ""){
                culpritsData[d].culprits = "none";
            }

            document.getElementById('tableBodyOfFailures').innerHTML +=
                "<tr>"+
                "<td>"+culpritsData[d].component+"</td>"+
                "<td>"+culpritsData[d].committedBy+"</td>"+
                "<td>"+culpritsData[d].PRmergedName+"</td>" +
                "<td>"+culpritsData[d].culprits+"</td>" +
                "<td><a href='"+culpritsData[d].commitUrl+"' target='_blank'>GitHub Link</a></td>" +
                "<td><a href='"+culpritsData[d].jobUrl+"' target='_blank'>Job Link</a></td>" +
                "</tr>";

        }
    }else{
        document.getElementById('tableBodyOfFailures').innerHTML = "<h5>No any failures occurred in this date range</h5>";
    }

}

function createFailureReasonPieChart(mainJSON, drillDownJSON){
    // Create the chart
    Highcharts.chart('container', {
        chart: {
            type: 'pie',
            margin: [60, 270,10,50]
        },
        title: {
            text: 'Build Failure Reasons'
        },
        subtitle: {
            text: 'Click the slices to view build failure reasons in product wise'
        },
        legend: {
            enabled: true,
            floating: true,
            verticalAlign: 'middle',
            align:'right',
            layout: 'vertical',
            labelFormatter : function() {
                var total = 0, percentage; $.each(this.series.data, function() { total+=this.y; });
                percentage=((this.y/total)*100).toFixed(2);
                return this.name  + '  (<span style=\"color:'+this.color+'\">'+percentage+ '%)';
            }

        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: false
                },
                showInLegend: true
            }
        },

        tooltip: {
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>'
        },
        series: [{
            name: 'Failure Reason',
            colorByPoint: true,
            data: mainJSON
        }],
        drilldown: {
            drillUpButton: {
                relativeTo: 'spacingBox',
                position: {
                    y: 60,
                    x: 0
                }
            },
            series: drillDownJSON
        }
    });
}

function createFailureReasonPieChartForProduct(mainJSON){
    Highcharts.chart('container2', {
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false,
            type: 'pie'
        },
        title: {
            text: 'Failure Categories'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: false
                },
                showInLegend: true
            }
        },
        series: [{
            name: 'Brands',
            colorByPoint: true,
            data: mainJSON
        }]
    });
}

function loadFailureFrequencyChart(dataset){
    dataset = dataset.buildData;

    var dataArray = [];
    for(var x = 0; x < dataset.length; x++){
        var temp = {"name":"s","y":0};
        temp.name = dataset[x].productArea;
        temp.y = parseInt(dataset[x].failureBuilds);

        dataArray.push(temp);
    }
    // Create the chart
    Highcharts.chart('failureFrequecy', {
        chart: {
            type: 'column'
        },
        colors: ['#F25128'],
        title: {
            text: 'Build Failure Frequency'
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Build Failures'
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
            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b> of total<br/>'
        },

        series: [{
            name: 'Brands',
            colorByPoint: true,
            data: dataArray
        }]
    });
}
