port module CustomPorts exposing (..)


type alias ChartTemperature =
    { temperature : Float
    , timestamp : String
    }


port showChart : List ChartTemperature -> Cmd msg


port updateChart : ChartTemperature -> Cmd msg
