port module CustomPorts exposing (..)


type alias ChartTemperature =
    { reading : Float
    , date : String
    }


port showChart : List ChartTemperature -> Cmd msg


port updateChart : ChartTemperature -> Cmd msg
