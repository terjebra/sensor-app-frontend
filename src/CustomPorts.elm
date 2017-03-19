port module CustomPorts exposing (..)


type alias Settings =
    { apiUrl : String
    , socketUrl : String
    , date : String
    }


type alias ChartTemperature =
    { reading : Float
    , date : String
    }


port receiveSettings : (Settings -> msg) -> Sub msg


port showChart : List ChartTemperature -> Cmd msg


port updateChart : ChartTemperature -> Cmd msg
