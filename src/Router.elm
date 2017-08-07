module Router exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>))
import Material
import Material.Layout as Layout
import Material.Snackbar as Snackbar
import Material.Options as Options exposing (css, when)
import Pages.Temperature as Temperature
import Types exposing (Context, ContextUpdate(..), Language(..))
import I18n exposing (getTranslation)


type Page
    = TemperaturePage Temperature.Model
    | NotFoundPage


type alias Model =
    { currentPage : Page
    , route : Route
    , mdl : Material.Model
    , snackbar : Snackbar.Model (Maybe Msg)
    }


type Route
    = TemperatureRoute
    | NotFoundRoute


type PageMsg
    = TemperatureMsg Temperature.Msg


type Msg
    = UrlChange Location
    | NavigateTo Route
    | Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg (Maybe Msg))
    | ChangeLanguage Language
    | CurrentPageMsg PageMsg


init : Location -> Context -> ( Model, Cmd Msg )
init location context =
    let
        route =
            fromUrl location

        ( page, pageCmd ) =
            initPage context route
    in
        ( { currentPage = page
          , route = TemperatureRoute
          , mdl = Material.model
          , snackbar = Snackbar.model
          }
        , pageCmd
        )


initPage : Context -> Route -> ( Page, Cmd Msg )
initPage context route =
    let
        ( pageModel, pageMsg ) =
            case route of
                TemperatureRoute ->
                    let
                        ( model, cmd ) =
                            Temperature.init context
                    in
                        ( TemperaturePage model, Cmd.map TemperatureMsg cmd )

                _ ->
                    let
                        ( model, cmd ) =
                            Temperature.init context
                    in
                        ( TemperaturePage model, Cmd.map TemperatureMsg cmd )
    in
        ( pageModel, Cmd.map CurrentPageMsg pageMsg )


view : Context -> Model -> Html Msg
view context model =
    div [] <|
        [ Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Options.css "display" "flex !important"
            , Options.css "flex-direction" "row"
            , Options.css "align-items" "center"
            ]
            { header = [ viewHeader context model ]
            , drawer = []
            , tabs = ( [], [] )
            , main =
                [ pageView context model
                , Snackbar.view model.snackbar |> Html.map Snackbar
                ]
            }
        ]


viewHeader : Context -> Model -> Html Msg
viewHeader context model =
    Layout.row
        []
        [ Layout.title [] [ text (getTranslation context.languages context.language "title") ]
        , Layout.spacer
        , Layout.navigation
            []
            [ Layout.link
                [ Options.onClick (NavigateTo TemperatureRoute) ]
                [ span [ class "header-item" ] [ text (getTranslation context.languages context.language "temperatures") ] ]
            , Layout.link
                [ Options.onClick (ChangeLanguage Norwegian) ]
                [ span [ class "header-item" ] [ text "Norsk" ] ]
            , Layout.link
                [ Options.onClick (ChangeLanguage English) ]
                [ span [ class "header-item" ] [ text "English" ] ]
            ]
        ]


pageView : Context -> Model -> Html Msg
pageView context model =
    let
        pageMsg =
            case model.currentPage of
                TemperaturePage pageModel ->
                    Temperature.view context pageModel |> Html.map TemperatureMsg

                _ ->
                    h1 [] [ text "Not the site you are looking for!" ]
    in
        Html.map CurrentPageMsg pageMsg


update : Msg -> Context -> Model -> ( Model, Cmd Msg, ContextUpdate )
update msg context model =
    case msg of
        Mdl msg_ ->
            let
                ( mdlModel, mdlCmd ) =
                    Material.update Mdl msg_ model
            in
                ( mdlModel, mdlCmd, NoUpdate )

        Snackbar msg_ ->
            let
                ( snackbar, snackCmd ) =
                    Snackbar.update msg_ model.snackbar
            in
                ( { model | snackbar = snackbar }, Cmd.map Snackbar snackCmd, NoUpdate )

        UrlChange location ->
            let
                route =
                    fromUrl location
            in
                ( { model | route = route }
                , commandOnUrlChange route context
                , NoUpdate
                )

        NavigateTo route ->
            ( model
            , Navigation.newUrl (toUrl route)
            , NoUpdate
            )

        CurrentPageMsg msg ->
            updatePage model msg

        ChangeLanguage lang ->
            ( model, Cmd.none, UpdateLanguage lang )


updatePage : Model -> PageMsg -> ( Model, Cmd Msg, ContextUpdate )
updatePage model msg =
    let
        ( newPage, pageMsg, contextUpdate ) =
            case msg of
                TemperatureMsg msg_ ->
                    case model.currentPage of
                        TemperaturePage pageModel ->
                            updateTemperature pageModel msg_

                        _ ->
                            ( model.currentPage, Cmd.none, NoUpdate )
    in
        ( { model | currentPage = newPage }, Cmd.map CurrentPageMsg pageMsg, contextUpdate )


commandOnUrlChange : Route -> Context -> Cmd Msg
commandOnUrlChange route context =
    let
        pageMsg =
            case route of
                TemperatureRoute ->
                    Cmd.map TemperatureMsg (Temperature.getTemperatures context.settings)

                _ ->
                    Cmd.none
    in
        Cmd.map CurrentPageMsg pageMsg


updateTemperature : Temperature.Model -> Temperature.Msg -> ( Page, Cmd PageMsg, ContextUpdate )
updateTemperature temperatureModel temperatureMsg =
    let
        ( nextTemperatureModel, temperatureModelCmd ) =
            Temperature.update temperatureMsg temperatureModel
    in
        ( TemperaturePage nextTemperatureModel
        , Cmd.map TemperatureMsg temperatureModelCmd
        , NoUpdate
        )


subscriptions : Context -> Model -> Sub Msg
subscriptions context model =
    let
        subPageMsg =
            case model.currentPage of
                TemperaturePage pageModel ->
                    Sub.map
                        TemperatureMsg
                        (Temperature.subscriptions pageModel)

                _ ->
                    Sub.none
    in
        Sub.map CurrentPageMsg subPageMsg


toUrl : Route -> String
toUrl route =
    case route of
        TemperatureRoute ->
            "#/temperatures"

        _ ->
            "#/"


toRoute : Url.Parser (Route -> a) a
toRoute =
    Url.map TemperatureRoute (Url.s "temperatures")


fromUrl : Location -> Route
fromUrl location =
    location
        |> Url.parseHash toRoute
        |> Maybe.withDefault NotFoundRoute
