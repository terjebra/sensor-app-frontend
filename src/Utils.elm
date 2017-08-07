module Utils exposing (..)

import Date exposing (Date)
import Date.Format exposing (..)
import Types exposing (Language(..))


getDateFromString : String -> Maybe Date
getDateFromString dateString =
    case Date.fromString dateString of
        Ok value ->
            Just value

        Err error ->
            Nothing


getLocalDateString : String -> String
getLocalDateString dateString =
    case getDateFromString dateString of
        Just value ->
            formatDate value

        Nothing ->
            ""


formatDate : Date -> String
formatDate date =
    format "%Y-%m-%d %H:%M:%S" date


isSameDay : String -> String -> Bool
isSameDay dateStringOne dateStringTwo =
    case getDateFromString dateStringOne of
        Just dateOne ->
            case getDateFromString dateStringTwo of
                Just dateTwo ->
                    if Date.year dateOne == Date.year dateTwo && Date.month dateOne == Date.month dateTwo && Date.day dateOne == Date.day dateTwo then
                        True
                    else
                        False

                Nothing ->
                    False

        Nothing ->
            False


languageToLanguageCode : Language -> String
languageToLanguageCode language =
    case language of
        Norwegian ->
            "no"

        English ->
            "en"
