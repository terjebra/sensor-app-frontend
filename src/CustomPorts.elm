port module CustomPorts exposing (..)


type alias Settings =
    { apiUrl : String
    , socketUrl : String
    }


port receiveSettings : (Settings -> msg) -> Sub msg
