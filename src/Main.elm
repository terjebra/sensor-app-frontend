module Main exposing (..)

import Html exposing (..)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (..)
import Types exposing (Languages, Context, Settings, ContextUpdate(..), Language(..))
import Navigation exposing (Location)
import Router


type alias Model =
    { state : AppState
    , location : Location
    }


type alias Flags =
    { languages : Decode.Value
    , settings : Settings
    }


type AppState
    = NotReady
    | Ready Context Router.Model


type Msg
    = UrlChange Location
    | RouterMsg Router.Msg


type Subscription
    = Inactive
    | Active


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        { settings, languages } =
            flags

        context =
            Context settings Norwegian (decodeLanguages languages)

        ( model, cmd ) =
            Router.init location context

        ready =
            Ready context model
    in
        ( Model ready location, Cmd.map RouterMsg cmd )



-- Decoders


decoderLanguages : Decoder (Dict String (Dict String String))
decoderLanguages =
    dict (dict string)


decodeLanguages : Value -> Dict String (Dict String String)
decodeLanguages languages =
    case Decode.decodeValue decoderLanguages languages of
        Ok rest ->
            rest

        _ ->
            Dict.empty



--UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            updateRouter
                { model | location = location }
                (Router.UrlChange location)

        RouterMsg routerMsg ->
            updateRouter model routerMsg


updateRouter : Model -> Router.Msg -> ( Model, Cmd Msg )
updateRouter model routerMsg =
    case model.state of
        Ready context routerModel ->
            let
                ( nextRouterModel, routerCmd, contextUpdate ) =
                    Router.update routerMsg context routerModel

                nextContext =
                    updateContext context contextUpdate
            in
                ( { model | state = Ready nextContext nextRouterModel }
                , Cmd.map RouterMsg routerCmd
                )

        NotReady ->
            Debug.crash "Ooops. Not ready?"


updateContext : Context -> ContextUpdate -> Context
updateContext context contextUpdate =
    case contextUpdate of
        UpdateLanguage language ->
            { context | language = language }

        NoUpdate ->
            context


view : Model -> Html Msg
view model =
    case model.state of
        Ready context routerModel ->
            Router.view
                context
                routerModel
                |> Html.map RouterMsg

        NotReady ->
            text "Loading"


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        Ready context model ->
            Sub.map
                RouterMsg
                (Router.subscriptions context model)

        _ ->
            Sub.none
