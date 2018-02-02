//create x axis last 12 months up to current month
var now = new Date();
var months = ["January", "February", "March", "April", "May","June", "July", "August", "September", "October", "November","December"];
var lastMonthsName = [];
var lastMonthsNumber = [];
var arrayOfYears = [];


function getMonth(monthStr){
    return new Date(monthStr+'-1-01').getMonth()+1
}

function ageGraph() {
    loadingIcon();
    var lastday = function(y,m){
        return  new Date(y, m +1, 0).getDate();
    };

    var aYear = now.getFullYear();
    var aMonth = now.getMonth();
    for (i=0; i<12; i++) {
        arrayOfYears[i] = aYear ;
        aMonth--;
        if (aMonth < 0) {
            aMonth = 11;
            aYear = aYear -1 ;
        }
    }

    arrayOfYears.reverse();


    //get today date and push that date i to arrays
    now.setMonth(now.getMonth());
    lastMonthsName[11]=now.getFullYear()+' '+months[now.getMonth()]+' '+now.getDate();
    if(getMonth(months[now.getMonth()])<10 || now.getDate() <10){
        if(getMonth(months[now.getMonth()])<10 && now.getDate() <10){
            lastMonthsNumber[11]=arrayOfYears[11]+'-0'+getMonth(months[now.getMonth()])+'-0'+now.getDate();
        }else if(getMonth(months[now.getMonth()])<10){
            lastMonthsNumber[11]=arrayOfYears[11] +'-0'+getMonth(months[now.getMonth()])+'-'+now.getDate();
        }else if(now.getDate() <10){
            lastMonthsNumber[11]=arrayOfYears[11] +'-'+getMonth(months[now.getMonth()])+'-0'+now.getDate();
        }
    }else{
        lastMonthsNumber[11]=arrayOfYears[11] +'-'+getMonth(months[now.getMonth()])+'-'+now.getDate();
    }

    //get last 12 months from current date
    var lastTwelveMonths = [];
    var thisMonth = now.getMonth();

    for(var i = 0; i<12;i++){
        if(thisMonth === -1){
            thisMonth = 11;
        }
        lastTwelveMonths[11-i] = thisMonth;
        thisMonth --;
    }


    //get first and last date of previous 12 months and add those in to arrays
    now.setMonth(lastTwelveMonths[11]);
    for(var i=0; i<=10;i++){
        lastMonthsName[10-i]=arrayOfYears[10-i] +' '+months[lastTwelveMonths[10-i]]+' '+lastday(now.getFullYear(),getMonth(months[lastTwelveMonths[10-i]])-1);

        if(getMonth(months[lastTwelveMonths[10-i]])<10){
            lastMonthsNumber[10-i]=arrayOfYears[10-i]+'-0'+getMonth(months[lastTwelveMonths[10-i]])+'-'+lastday(now.getFullYear(),getMonth(months[lastTwelveMonths[10-i]])-1);
        }else{
            lastMonthsNumber[10-i]=arrayOfYears[10-i]+'-'+getMonth(months[lastTwelveMonths[10-i]])+'-'+lastday(now.getFullYear(),getMonth(months[lastTwelveMonths[10-i]])-1);
        }
        now.setMonth(lastTwelveMonths[10-i]);
        if(lastTwelveMonths[10-i] === 0){
            now.setFullYear(arrayOfYears[10-i] - 1);
        }
    }


    //create a last date to send via ajax
    var lastMonthDate = "";
    for(var y=0;y<lastMonthsNumber.length;y++){
        lastMonthDate += lastMonthsNumber[y]+'>';
    }
    lastMonthDate = lastMonthDate.substring(0, lastMonthDate.length-1);
    var queuedGraphData = [];

    // console.log(lastMonthDate);
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-queued-age-graph',
        data: {lastMonthDate:lastMonthDate },
        async: false,
        success: function(data){
            queuedGraphData = data;
        }
    });


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


    var index = lastMonthsNumber.indexOf(getMonth);
    var mainData = [];
    var drillDownData = [];
    $.ajax({
        type: "GET",
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-drilldown-age-graph/'+group+'/'+getMonth,
        async: false,
        success: function(data){
            mainData = data.mainData;
            drillDownData = data.drillDown;
        }
    });
    // console.log(mainData);
    // console.log(drillDownData);
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

