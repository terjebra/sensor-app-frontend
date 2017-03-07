var Elm = require('./Main.elm');

var myApp = Elm.Main.fullscreen();

myApp.ports.receiveSettings.send(getSettings());

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
  