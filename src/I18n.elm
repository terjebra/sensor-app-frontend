module I18n exposing (getTranslation)

import Dict
import Types exposing (Languages, Language(..))
import Utils exposing (..)


getTranslation : Languages -> Language -> String -> String
getTranslation languages language key =
    languages
        |> Dict.get (languageToLanguageCode language)
        |> Maybe.andThen (Dict.get key)
        |> Maybe.withDefault key
