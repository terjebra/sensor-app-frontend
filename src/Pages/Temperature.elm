module Pages.Temperature exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Material
import Material.Grid as Grid exposing (grid, size, cell, Device(..))
import Material.Snackbar as Snackbar
import WebSocket
import Http exposing (..)
import Utils exposing (..)
import CustomPorts exposing (..)
import Types exposing (..)


--Constants


type alias Temperature =
    { id : String
    , timestamp : String
    , temperature : Float
    }


type alias Model =
    { temperatures : List Temperature
    , alertMessage : Maybe String
    , mdl : Material.Model
    , snackbar : Snackbar.Model (Maybe Msg)
    , context : Context
    }


type Msg
    = NewTemperatures (Result Http.Error (List Temperature))
    | Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg (Maybe Msg))
    | ReceiveNewTemperature String



--Decoder and encoder


temperatureDecoder : Decoder Temperature
temperatureDecoder =
    Decode.map3 Temperature
        (field "id" Decode.string)
        (field "timestamp" Decode.string)
        (field "temperature" Decode.float)


encodeReading : String -> Float -> Encode.Value
encodeReading date temp =
    Encode.object
        [ ( "timestamp", Encode.string date )
        , ( "temperature", Encode.float temp )
        ]



--UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewTemperatures (Ok temperatures) ->
            ( { model | temperatures = temperatures }, showChart (getChartTemperatures temperatures) )

        NewTemperatures (Err error) ->
            ( { model | alertMessage = Just (httpErrorToMessage error) }, Cmd.none )

        ReceiveNewTemperature raw ->
            case Decode.decodeString temperatureDecoder raw of
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


isWithinSameDay : Model -> Temperature -> Bool
isWithinSameDay model temperature =
    case List.head (List.reverse model.temperatures) of
        Just head ->
            Utils.isSameDay head.timestamp temperature.timestamp

        Nothing ->
            True


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


getTemperatures : Settings -> Cmd Msg
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
    { temperature = temperature.temperature, timestamp = (getLocalDateString temperature.timestamp) }


view : Context -> Model -> Html Msg
view context model =
    grid []
        [ cell
            [ Grid.size Desktop 12
            , Grid.size Tablet 8
            , Grid.size Phone 12
            ]
            [ div [ id "chart" ] [] ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:8080/websocket" ReceiveNewTemperature


init : Context -> ( Model, Cmd Msg )
init context =
    ( { temperatures = []
      , mdl = Material.model
      , snackbar = Snackbar.model
      , context = context
      , alertMessage = Nothing
      }
    , getTemperatures context.settings
    )
