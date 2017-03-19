module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (..)
import Html.Events exposing (onClick)
import Phoenix.Socket
import Phoenix.Channel
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Material
import Material.Layout as Layout
import Material.Snackbar as Snackbar
import Material.Options as Options exposing (css, cs, when)
import Material.Grid as Grid exposing (grid, size, cell, Device(..))
import Utils exposing (..)
import CustomPorts exposing (..)
import Material.Spinner as Loading


--Constants


temperatureChannel : String
temperatureChannel =
    "temperature"


temperatureChannelEvent : String
temperatureChannelEvent =
    "registered"


type AppModel
    = NotReady
    | Ready ReadyModel


type alias ReadyModel =
    { temperatures : List Temperature
    , alertMessage : Maybe String
    , socket : Phoenix.Socket.Socket ReadyMsg
    , mdl : Material.Model
    , snackbar : Snackbar.Model (Maybe ReadyMsg)
    , settings : CustomPorts.Settings
    }


type alias Temperature =
    { id : Int
    , date : String
    , reading : Float
    }


type Msg
    = NotReadyMessage NotReadyMsg
    | ReadyMessage ReadyMsg


type NotReadyMsg
    = SettingsReceived CustomPorts.Settings


type ReadyMsg
    = NewTemperatures (Result Http.Error (List Temperature))
    | ReceiveNewTemperature Encode.Value
    | CloseAlert
    | PhoenixMsg (Phoenix.Socket.Msg ReadyMsg)
    | ShowJoinedMessage
    | Mdl (Material.Msg ReadyMsg)
    | Snackbar (Snackbar.Msg (Maybe ReadyMsg))



--Decoder and encoder


temperatureDecoder : Decoder Temperature
temperatureDecoder =
    Decode.map3 Temperature
        (field "id" Decode.int)
        (field "date" Decode.string)
        (field "reading" Decode.float)


encodeReading : String -> Float -> Encode.Value
encodeReading date temp =
    Encode.object
        [ ( "date", Encode.string date )
        , ( "reading", Encode.float temp )
        ]



--UPDATE


update : Msg -> AppModel -> ( AppModel, Cmd Msg )
update msg model =
    case msg of
        ReadyMessage msg ->
            case model of
                Ready readyModel ->
                    let
                        ( rm, readyMsg ) =
                            updateReadyModel msg readyModel
                    in
                        ( Ready rm, Cmd.map ReadyMessage readyMsg )

                _ ->
                    ( model, Cmd.none )

        NotReadyMessage msg ->
            case model of
                NotReady ->
                    let
                        ( readyModel, readyMsg ) =
                            updateNoneReadyModel msg
                    in
                        ( Ready readyModel, Cmd.map ReadyMessage readyMsg )

                _ ->
                    ( model, Cmd.none )


updateNoneReadyModel : NotReadyMsg -> ( ReadyModel, Cmd ReadyMsg )
updateNoneReadyModel msg =
    case msg of
        SettingsReceived settings ->
            ( initReadyModel settings, getTemperatures settings )


updateReadyModel : ReadyMsg -> ReadyModel -> ( ReadyModel, Cmd ReadyMsg )
updateReadyModel msg model =
    case msg of
        NewTemperatures (Ok temperatures) ->
            ( { model | temperatures = temperatures }, joinChannel model )

        NewTemperatures (Err error) ->
            ( { model | alertMessage = Just (httpErrorToMessage error) }, Cmd.none )

        CloseAlert ->
            ( { model | alertMessage = Nothing }, Cmd.none )

        ReceiveNewTemperature raw ->
            case Decode.decodeValue temperatureDecoder raw of
                Ok temperature ->
                    if isWithinSameDay model temperature then
                        ( { model | alertMessage = Just "New temperature received", temperatures = model.temperatures ++ [ temperature ] }
                        , updateChart (getChartTemperature temperature)
                        )
                    else
                        ( { model | alertMessage = Just "New temperature received", temperatures = [ temperature ] }
                        , updateChart (getChartTemperature temperature)
                        )

                Err error ->
                    ( { model | alertMessage = Just "errr " }, Cmd.none )

        ShowJoinedMessage ->
            ( { model | alertMessage = Just "Joined " }, Cmd.none )

        PhoenixMsg msg_ ->
            ( model, showChart (getChartTemperatures model.temperatures) )

        Mdl msg_ ->
            let
                ( mdlModel, mdlCmd ) =
                    Material.update Mdl msg_ model
            in
                ( mdlModel, mdlCmd )

        Snackbar msg_ ->
            let
                ( snackbar, snackCmd ) =
                    Snackbar.update msg_ model.snackbar
            in
                ( { model | snackbar = snackbar }, Cmd.map Snackbar snackCmd )


isWithinSameDay : ReadyModel -> Temperature -> Bool
isWithinSameDay model temperature =
    case List.head (List.reverse model.temperatures) of
        Just head ->
            Utils.isSameDay head.date temperature.date

        Nothing ->
            True


joinChannel : ReadyModel -> Cmd ReadyMsg
joinChannel model =
    let
        channel =
            Phoenix.Channel.init temperatureChannel
                |> Phoenix.Channel.onJoin (always ShowJoinedMessage)

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel model.socket
    in
        Cmd.map PhoenixMsg phxCmd


httpErrorToMessage : Http.Error -> String
httpErrorToMessage error =
    case error of
        Http.NetworkError ->
            "Could not connect to Server"

        Http.BadStatus response ->
            (toString response.status)

        Http.BadPayload message _ ->
            "Decoding failed: " ++ message

        _ ->
            (toString error)



--Commands


getTemperatures : CustomPorts.Settings -> Cmd ReadyMsg
getTemperatures settings =
    (Decode.list temperatureDecoder)
        |> Http.get (settings.apiUrl ++ "?date=" ++ settings.date)
        |> Http.send NewTemperatures



--View


getChartTemperatures : List Temperature -> List ChartTemperature
getChartTemperatures temperatures =
    temperatures
        |> List.map getChartTemperature


getChartTemperature : Temperature -> ChartTemperature
getChartTemperature temperature =
    { reading = temperature.reading, date = (getLocalDateString temperature.date) }


viewMain : ReadyModel -> Html ReadyMsg
viewMain model =
    grid []
        [ cell
            [ Grid.size Desktop 12
            , Grid.size Tablet 8
            , Grid.size Phone 12
            ]
            [ div [ id "chart" ] [] ]
        ]


viewAlertMessage : Maybe String -> Html ReadyMsg
viewAlertMessage alertMessage =
    case alertMessage of
        Just message ->
            div [ class "alert", onClick CloseAlert ]
                [ text message ]

        Nothing ->
            text ""


viewHeader : ReadyModel -> Html ReadyMsg
viewHeader model =
    Layout.row
        []
        [ Layout.title [] [ text "Sensor data" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link
                []
                [ span [] [] ]
            ]
        ]


view : AppModel -> Html Msg
view model =
    case model of
        NotReady ->
            Loading.spinner
                [ Loading.active True ]

        Ready model ->
            Html.map ReadyMessage <| viewReady model


viewReady : ReadyModel -> Html ReadyMsg
viewReady model =
    div [] <|
        [ Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Options.css "display" "flex !important"
            , Options.css "flex-direction" "row"
            , Options.css "align-items" "center"
            ]
            { header = [ viewHeader model ]
            , drawer = []
            , tabs = ( [], [] )
            , main =
                [ viewMain model
                , Snackbar.view model.snackbar |> Html.map Snackbar
                ]
            }
        ]



-- SUBSCRIPTIONS


subscriptions : AppModel -> Sub Msg
subscriptions model =
    case model of
        NotReady ->
            Sub.map NotReadyMessage (receiveSettings SettingsReceived)

        Ready model ->
            Sub.map ReadyMessage (Phoenix.Socket.listen model.socket PhoenixMsg)


initSocket : CustomPorts.Settings -> Phoenix.Socket.Socket ReadyMsg
initSocket settings =
    Phoenix.Socket.init settings.socketUrl
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on temperatureChannelEvent temperatureChannel ReceiveNewTemperature


initReadyModel : CustomPorts.Settings -> ReadyModel
initReadyModel settings =
    { temperatures = []
    , alertMessage = Nothing
    , socket = initSocket settings
    , mdl = Material.model
    , snackbar = Snackbar.model
    , settings = settings
    }


init : ( AppModel, Cmd Msg )
init =
    ( NotReady, Cmd.none )


main : Program Never AppModel Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
