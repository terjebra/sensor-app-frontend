var Elm = require('./Main.elm');

var myApp = Elm.Main.fullscreen();

myApp.ports.receiveSettings.send(GetSettings());

function GetSettings (){
  return {
    apiUrl : API_URL,
    socketUrl: SOCKET_URL
  }
}