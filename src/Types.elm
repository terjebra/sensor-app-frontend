module Types exposing (..)

import Dict exposing (Dict)


type alias Settings =
    { apiUrl : String
    , socketUrl : String
    , date : String
    }


type alias Context =
    { settings : Settings
    , language : Language
    , languages : Languages
    }


type alias Languages =
    Dict String (Dict String String)


type alias LanguageCode =
    String


type Language
    = Norwegian
    | English


type ContextUpdate
    = UpdateLanguage Language
    | NoUpdate
