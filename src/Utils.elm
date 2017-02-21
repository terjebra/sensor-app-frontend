module Utils exposing (..)

import Date exposing (Date)


secondsInAnHour : Int
secondsInAnHour =
    3600


secondsInAMinute : Int
secondsInAMinute =
    60


formatUnixEpoch : String -> String
formatUnixEpoch epoch =
    case Date.fromString epoch of
        Ok value ->
            formatTime value

        Err error ->
            ""


formatTime : Date -> String
formatTime date =
    (toString (Date.hour date) |> addPadding) ++ ":" ++ (toString (Date.minute date) |> addPadding) ++ ":" ++ (toString (Date.second date) |> addPadding)


secondsToTimeFormat : Float -> String
secondsToTimeFormat seconds =
    (toString (convertSecondsToHours seconds) |> addPadding) ++ ":" ++ (toString (convertSecondsToMinutes seconds) |> addPadding) ++ ":" ++ (toString (convertSecondsToSeconds seconds) |> addPadding)


convertSecondsToHours : Float -> Int
convertSecondsToHours seconds =
    (Basics.floor (seconds / Basics.toFloat secondsInAnHour))


convertSecondsToMinutes : Float -> Int
convertSecondsToMinutes seconds =
    (%) (Basics.floor (seconds / Basics.toFloat secondsInAMinute)) 60


convertSecondsToSeconds : Float -> Int
convertSecondsToSeconds seconds =
    (%) (convertFloatToInt seconds) 60


convertFloatToInt : Float -> Int
convertFloatToInt value =
    Result.withDefault 0 (String.toInt (toString value))


addPadding : String -> String
addPadding string =
    if String.length string == 1 then
        "0" ++ string
    else
        string


average : Int -> Float -> Float
average len sum =
    sum / toFloat (len)


timeInSeconds : Date -> Float
timeInSeconds date =
    toFloat ((Date.hour date) * secondsInAnHour + (Date.minute date) * secondsInAMinute + (Date.second date))


getTimeInSecondsFromString : String -> Float
getTimeInSecondsFromString dateString =
    case Date.fromString dateString of
        Ok value ->
            timeInSeconds value

        Err error ->
            0
