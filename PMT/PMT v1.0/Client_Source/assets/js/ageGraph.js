//create x axis last 12 months up to current month
var now = new Date();
var months = ["January", "February", "March", "April", "May","June", "July", "August", "September", "October", "November","December"];
var lastMonthsName = [];
var lastMonthsNumber = [];
var limitArray = [[0,7],[7,14],[14,30],[30,60],[60,90],[90]];

function getMonth(monthStr){
    return new Date(monthStr+'-1-01').getMonth()+1
}

function ageGraph() {
    loadingIcon();
    var lastday = function(y,m){
        return  new Date(y, m +1, 0).getDate();
    };

    now.setMonth(now.getMonth());
    lastMonthsName[11]=months[now.getMonth()]+' '+now.getFullYear();
    if(getMonth(months[now.getMonth()])<10 || now.getDate() <10){
        if(getMonth(months[now.getMonth()])<10 && now.getDate() <10){
            lastMonthsNumber[11]=now.getFullYear()+'-0'+getMonth(months[now.getMonth()])+'-0'+now.getDate();
        }else if(getMonth(months[now.getMonth()])<10){
            lastMonthsNumber[11]=now.getFullYear()+'-0'+getMonth(months[now.getMonth()])+'-'+now.getDate();
        }else if(now.getDate() <10){
            lastMonthsNumber[11]=now.getFullYear()+'-'+getMonth(months[now.getMonth()])+'-0'+now.getDate();
        }
    }else{
        lastMonthsNumber[11]=now.getFullYear()+'-'+getMonth(months[now.getMonth()])+'-'+now.getDate();
    }


    for(var i=0; i<=10;i++){
        now.setMonth(now.getMonth()-1);
        lastMonthsName[10-i]=months[now.getMonth()]+' '+now.getFullYear();
        if(getMonth(months[now.getMonth()])<10){
            lastMonthsNumber[10-i]=now.getFullYear()+'-0'+getMonth(months[now.getMonth()])+'-'+lastday(now.getFullYear(),getMonth(months[now.getMonth()])-1);
        }else{
            lastMonthsNumber[10-i]=now.getFullYear()+'-'+getMonth(months[now.getMonth()])+'-'+lastday(now.getFullYear(),getMonth(months[now.getMonth()])-1);
        }

    }

    var lastMonth = "";
    now.setMonth(now.getMonth()-1);
    if(getMonth(months[now.getMonth()]) < 10){
        lastMonth = now.getFullYear()+'-0'+getMonth(months[now.getMonth()])+'-'+lastday(now.getFullYear(),getMonth(months[now.getMonth()])-1)
    }else{
        lastMonth = now.getFullYear()+'-'+getMonth(months[now.getMonth()])+'-'+lastday(now.getFullYear(),getMonth(months[now.getMonth()])-1)
    }

    var durationString = "";
    for(var y=0;y<lastMonthsNumber.length;y++){
        durationString += lastMonthsNumber[y]+'>';
    }
    durationString = durationString.substring(0, durationString.length-1);

    // console.log(lastMonth);
    // console.log(durationString);
    var queuedGraphData = [];

    console.log('https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-queued-age-graph/'+durationString+'/'+lastMonth);
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-queued-age-graph/'+durationString+'/'+lastMonth,
        async: false,
        success: function(data){
            queuedGraphData = data;
        }
    });

    // console.log(queuedGraphData);

//draw age  graph
    Highcharts.chart('ageContainer', {
        chart: {
            type: 'area',
        },
        colors: ['#39AA59', '#CEAE22', '#3E90BC','#B787E6','#ea780e','#F85858'],
        title: {
            text: 'Age of Queued (Yet to Start + In Progress) Patches During the Last Year'
        },
        subtitle: {
            text: 'Click on any area to get more details'
        },
        xAxis: {
            categories: lastMonthsName,
            tickmarkPlacement: 'on',
            title: {
                enabled: false
            }
        },
        yAxis: {
            title: {
                text: 'Patch count'
            },
            labels: {
                formatter: function () {
                    return this.value;
                }
            }
        },
        tooltip: {
            split: true,
            valueSuffix: ' patches'
        },
        plotOptions: {
            area: {
                stacking: 'normal',
                lineColor: '#666666',
                cursor: 'pointer',
                trackByArea: true,
                lineWidth: 1,
                marker: {
                    lineWidth: 1,
                    lineColor: '#666666'
                },
                point: {
                    events: {
                        click: function(event) {
                            showStackBarChart (this.category,event.point.series.name);
                        }
                    }
                }
            }
        },
        series: [{
            name: 'Age > 0 Days', //a >90
            data: queuedGraphData[5]
        },{
            name: 'Age > 7 Days', //a<90
            data: queuedGraphData[4]
        },{
            name: 'Age > 14 Days', //a<60
            data: queuedGraphData[3]
        },{
            name: 'Age > 30 Days', //a<30
            data: queuedGraphData[2]
        },{
            name: 'Age > 60 Days', //a<14
            data: queuedGraphData[1]
        },{
            name: 'Age > 90 Days', //a<7
            data: queuedGraphData[0]
        }]
    });

}

function showStackBarChart(date,vars){
    //alert(vars);
    document.getElementById('stackTab').style.display = 'block';
    document.getElementById('fullDiv').style.height = '1300px';

    var indexOf = lastMonthsName.indexOf(date);
    var getMonth = lastMonthsNumber[indexOf];
    var group = vars.split(" ")[2];

    var today1 = today.replace(/0/g, "");
    var today2 = getMonth.replace(/0/g, "");

    var isToday = "false";
    if(today1 === today2){
        isToday = "true";
    }

    var index = lastMonthsNumber.indexOf(getMonth);
    console.log(index);
    var mainData = [];
    var drillDownData = [];
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-drilldown-age-graph/'+group+'/'+getMonth+'/'+isToday+'/'+index,
        async: false,
        success: function(data){
            mainData = data.mainData;
            drillDownData = data.drillDown;
        }
    });
    console.log(mainData);
    console.log(drillDownData);
    drawStackBar(vars,date,mainData,drillDownData);

    $('html,body').animate({
            scrollTop: $(".areaDrilldown").offset().top},
        'slow');
    loadingIcon();

}

function drawStackBar(vars,date,array,drilldown) {
    var chart = Highcharts.chart('stackBar', {
        chart: {
            type: 'column',
            events: {
                drilldown: function (e) {
                    chart.setTitle({text: vars+' Queued Patches from ' + e.point.name},{text:''});
                },
                drillup: function(e) {
                    chart.setTitle({ text: vars+' Patch Counts up to '+date },{text: "Click on the columns to view more details.."});
                }
            }
        },
        title: {
            text: vars+' Patch Counts up to '+date
        },
        subtitle:{
            text: 'Click on the columns to view more details..'
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'No of patches'
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
            name: 'All Queued Patches',
            colorByPoint: true,
            data: array
        }],
        drilldown: {
            series: drilldown
        }
    });
}


