
var Elm = require('./Main.elm');

var languageEnglish  = require('./Languages/en.json');
var languageNorwegian  = require('./Languages/no.json');

var languages = {
  "en" : languageEnglish,
  "no" : languageNorwegian
}

var app = Elm.Main.fullscreen({
  settings : getSettings(),
  languages: getTranslations()
});

var chart = null;
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
            "valueField": "temperature",
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
        "categoryField": "timestamp",
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


function getTranslations(){
  var languagesDictionary = {};
  for(var language in languages) {
    languageDictionary = {}
    languagesDictionary[language] = languageDictionary;
    for(var key in languages[language]){
      languageDictionary[key] = languages[language][key];
    }
  }
  return languagesDictionary;
}

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