var Elm = require('./Main.elm');

var app = Elm.Main.fullscreen();
var chart = null;

app.ports.receiveSettings.send(getSettings());

app.ports.showChart.subscribe(function(items) {

chart = AmCharts.makeChart("chart", {
    "type": "serial",
    "theme": "light",
    "marginRight": 40,
    "marginLeft": 40,
    "autoMarginOffset": 20,
    "mouseWheelZoomEnabled":true,
    "dataDateFormat": "YYYY-MM-DD JJ:NN:SS",
    "valueAxes": [{
        "id": "v1",
        "axisAlpha": 0,
        "position": "left",
        "ignoreAxisWidth":true
    }],
    "balloon": {
        "borderThickness": 1,
        "shadowAlpha": 0
    },
    "graphs": [{
        "id": "g1",
        "balloon":{
          "drop":true,
          "adjustBorderColor":false,
          "color":"#ffffff"
        },
        "bullet": "round",
        "bulletBorderAlpha": 1,
        "bulletColor": "#FFFFFF",
        "bulletSize": 5,
        "hideBulletsCount": 50,
        "lineThickness": 2,
        "title": "red line",
        "useLineColorForBulletBorder": true,
        "valueField": "reading",
        "balloonText": "<span style='font-size:8px;'>[[value]]</span>"
    }],
    "chartScrollbar": {
        "graph": "g1",
        "oppositeAxis":false,
        "offset":30,
        "scrollbarHeight": 80,
        "backgroundAlpha": 0,
        "selectedBackgroundAlpha": 0.1,
        "selectedBackgroundColor": "#888888",
        "graphFillAlpha": 0,
        "graphLineAlpha": 0.5,
        "selectedGraphFillAlpha": 0,
        "selectedGraphLineAlpha": 1,
        "autoGridCount":true,
        "color":"#AAAAAA"
    },
    "chartCursor": {
        "pan": true,
        "valueLineEnabled": true,
        "valueLineBalloonEnabled": true,
        "cursorAlpha":1,
        "cursorColor":"#258cbb",
        "limitToGraph":"g1",
        "valueLineAlpha":0.2,
        "valueZoomable":true,
        "categoryBalloonDateFormat": "JJ:NN:SS"
    },
    "categoryField": "date",
    "categoryAxis": {
        "parseDates": true,
        "minPeriod": "ss",
        "minorGridEnabled": true
    },
    "dataProvider": items
});

    chart.addListener("rendered", zoomChart);

    zoomChart();

    function zoomChart() {
        chart.zoomToIndexes(chart.dataProvider.length - 40, chart.dataProvider.length - 1);
    }
});

app.ports.updateChart.subscribe(function(item) {
    chart.dataProvider.push(item);
    chart.validateData();
});

function getSettings (){
  return {
    apiUrl : API_URL,
    socketUrl: SOCKET_URL,
    date : getDate()
  }
}

function getDate(){
  let date = new Date();
  return date.getFullYear() + "-" + addPadding(date.getMonth() + 1) + "-" + addPadding(date.getDate())
}

function addPadding(value){
   return value.toString().length === 1 ? "0" + value : value;
}



  