
function loadStackQueuedGraph(){
    var start = "";
    var end = "";
    if(startDate === ''){
        start = firstdate;
        end = today;
    }else{
        start = startDate;
        end = endDate;
    }

    var states = [];
    var products = [];
    var counts = [];
    $.ajax({
        type: "GET",
        async:false,
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-lifecycle-stack/'+start+'/'+end,
        success: function(jsonResponse){
            states = jsonResponse.category;
            products = jsonResponse.products;
            counts = jsonResponse.counts
        }
    });

    var chart = [];
    for(var z=0;z<states.length;z++){
        var json={name:"x",data:2016};
        json.name = states[z];
        json.data = counts[z];
        chart.push(json)
    }
    console.log(chart);
    drawStackChart(products,chart);
}

function drawStackChart(products,chartData){
    Highcharts.chart('lifeCycle', {
        chart: {
            type: 'column'
        },
        title: {
            text: 'Patch States of Products from 2017-08-29 to 2017-09-28'
        },
        subtitle:{
            text:"Click on a bar to view more details"
        },
        xAxis: {
            categories: products
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Total Patch Count'
            },
            stackLabels: {
                enabled: true,
                style: {
                    fontWeight: 'bold',
                    color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
                }
            }
        },
        legend: {
            align: 'right',
            x: -30,
            verticalAlign: 'top',
            y: 49,
            floating: true,
            backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
            borderColor: '#CCC',
            borderWidth: 1,
            shadow: false
        },
        tooltip: {
            headerFormat: '<b>{point.x}</b><br/>',
            pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
        },
        plotOptions: {
            column: {
                stacking: 'normal',
                dataLabels: {
                    enabled: true,
                    formatter: function(){
                        var val = this.y;
                        if (val < 1) {
                            return '';
                        }
                        return val;
                    },
                    color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
                },
                treshold: 1
            }
        },
        series: chartData
    });
}

Highcharts.chart('stateGraph', {
    chart: {
        backgroundColor: 'white',
        events: {
            load: function () {

                // Draw the flow chart
                var ren = this.renderer,
                    colors = Highcharts.getOptions().colors,
                    rightArrow = ['M', 0, 0, 'L', 100, 0, 'L', 95, 5, 'M', 100, 0, 'L', 95, -5],
                    leftArrow = ['M', 100, 0, 'L', 0, 0, 'L', 5, 5, 'M', 0, 0, 'L', 5, -5];



                // Separator, Yet to start from In progress
                ren.path(['M', 200, 40, 'L', 200, 330])
                    .attr({
                        'stroke-width': 2,
                        stroke: 'silver',
                        dashstyle: 'dash'
                    })
                    .add();

                // Separator, In progress from Released
                ren.path(['M', 775, 40, 'L', 775, 330])
                    .attr({
                        'stroke-width': 2,
                        stroke: 'silver',
                        dashstyle: 'dash'
                    })
                    .add();

                // Headers
                ren.label('Yet to Start', 60, 40)
                    .css({
                        fontWeight: 'bold'
                    })
                    .add();
                ren.label('In Progress', 440, 40)
                    .css({
                        fontWeight: 'bold'
                    })
                    .add();
                ren.label('Released', 870, 40)
                    .css({
                        fontWeight: 'bold'
                    })
                    .add();

                // Queued label
                ren.label('Queued State  <br/> <span style="text-align: center;">Count 34</span>', 10, 82)
                    .attr({
                        fill: colors[0],
                        stroke: 'white',
                        'stroke-width': 2,
                        padding: 16,
                        r: 10
                    })
                    .css({
                        color: 'white',
                        width: '100px',
                        textAlign:'center'
                    })
                    .add()
                    .shadow(true);

                ren.label('Pre QA State  <br/> <span style="text-align: center;">Count 34</span>', 220, 82)
                    .attr({
                        fill: colors[1],
                        stroke: 'white',
                        'stroke-width': 2,
                        padding: 16,
                        r: 10
                    })
                    .css({
                        color: 'white',
                        width: '100px',
                        textAlign:'center'
                    })
                    .add();

                ren.label('Developing State <br/> <span style="text-align: center;">Count 34</span>', 430, 82)
                    .attr({
                        fill: colors[1],
                        stroke: 'white',
                        'stroke-width': 2,
                        padding: 16,
                        r: 10
                    })
                    .css({
                        color: 'white',
                        width: '100px',
                        textAlign:'center'
                    })
                    .add();

                ren.label('Testing State  <br/> <span style="text-align: center;">Count 34</span>', 660, 82)
                    .attr({
                        fill: colors[1],
                        stroke: 'white',
                        'stroke-width': 2,
                        padding: 16,
                        r: 10
                    })
                    .css({
                        color: 'white',
                        width: '100px',
                        textAlign:'center'
                    })
                    .add();

                // Arrow from Queued to Pre QA
                ren.path(rightArrow)
                    .attr({
                        'stroke-width': 2,
                        stroke: colors[3]
                    })
                    .translate(115, 105)
                    .add();

                ren.label('Get 2 Days', 135, 87)
                    .css({
                        fontSize: '10px',
                        color: colors[3]
                    })
                    .add();

                // Arrow from Pre QA to Developing
                ren.path(rightArrow)
                    .attr({
                        'stroke-width': 2,
                        stroke: colors[3]
                    })
                    .translate(325, 105)
                    .add();

                ren.label('Get 2 Days', 345, 87)
                    .css({
                        fontSize: '10px',
                        color: colors[3]
                    })
                    .add();

                // Arrow from Developing to Testing
                ren.path(rightArrow)
                    .attr({
                        'stroke-width': 2,
                        stroke: colors[3]
                    })
                    .translate(555, 105)
                    .add();

                ren.label('Get 2 Days', 575, 87)
                    .css({
                        fontSize: '10px',
                        color: colors[3]
                    })
                    .add();

                // Arrow to On Hold state
                ren.path(['M', 345, 180, 'L', 345, 245, 'L', 340, 240, 'M', 345, 245, 'L', 350, 240])
                    .attr({
                        'stroke-width': 2,
                        stroke: colors[3]
                    })
                    .add();

                //On hold state
                ren.label('On Hold State  <br/> <span style="text-align: center;">Count 34</span>', 290, 250)
                    .attr({
                    fill: colors[1],
                    stroke: 'white',
                    'stroke-width': 2,
                    padding: 16,
                    r: 10
                })
                    .css({
                        color: 'white',
                        width: '100px',
                        textAlign:'center'
                    })
                    .add();

                // Arrow to On Hold state
                ren.path(['M', 575, 180, 'L', 575, 245, 'L', 580, 240, 'M', 575, 245, 'L', 570, 240])
                    .attr({
                        'stroke-width': 2,
                        stroke: colors[3]
                    })
                    .add();

                //Broken State
                ren.label('Broken State   <br/> <span style="text-align: center;">Count 34</span>', 525, 250)
                    .attr({
                        fill: colors[1],
                        stroke: 'white',
                        'stroke-width': 2,
                        padding: 16,
                        r: 10
                    })
                    .css({
                        color: 'white',
                        width: '100px',
                        textAlign:'center'
                    })
                    .add();

                // Released label
                ren.label('Released State   <br/> <span style="text-align: center;">Count 34</span>', 870, 80)
                    .attr({
                        fill: '#7AC29A',
                        stroke: 'white',
                        'stroke-width': 2,
                        padding: 16,
                        r: 10
                    })
                    .css({
                        color: 'white',
                        width: '100px',
                        textAlign:'center'
                    })
                    .add()
                    .shadow(true);

                // Arrow from Testing to Released
                ren.path(rightArrow)
                    .attr({
                        'stroke-width': 2,
                        stroke: '#7AC29A'
                    })
                    .translate(765, 105)
                    .add();

                ren.label('Get 4 Days', 782, 87)
                    .css({
                        color:'#7AC29A',
                        fontSize: '10px'
                    })
                    .add();


            }
        }
    },
    title: {
        text: '',
        style: {
            color: 'black'
        }
    }
});
