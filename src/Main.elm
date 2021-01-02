module Main exposing (Msg(..), main, update)

import Browser
import Graphql.Document as Document
import Graphql.Http exposing (HttpError)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (Html, button, main_, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import StarWars.Object exposing (Human)
import StarWars.Object.Human as Human
import StarWars.Query as Query
import StarWars.Scalar



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    Response


init : () -> ( Model, Cmd Msg )
init _ =
    ( { vader = Nothing }
    , query
        |> Graphql.Http.queryRequest "https://elm-graphql.herokuapp.com/api"
        |> Graphql.Http.send GotReponse
    )



-- UPDATE


type alias Response =
    { vader : Maybe HumanData
    }


type alias HumanData =
    { name : String
    , homePlanet : Maybe String
    }



{--
  query {
    human(id: "1001") {
      name
      homePlanet
    }
  }
--}


query : SelectionSet Response RootQuery
query =
    SelectionSet.map Response
        (Query.human { id = StarWars.Scalar.Id "1001" } humanSelection)


humanSelection : SelectionSet HumanData StarWars.Object.Human
humanSelection =
    SelectionSet.map2 HumanData
        Human.name
        Human.homePlanet


type Msg
    = GotReponse (Result (Graphql.Http.Error Response) Response)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotReponse response ->
            case response of
                Ok r ->
                    ( r, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.vader of
        Just vader ->
            main_
                [ class "ly_cont" ]
                [ p []
                    [ text vader.name
                    ]
                , p []
                    [ text <| Maybe.withDefault "home planet is none." vader.homePlanet
                    ]
                ]

        Nothing ->
            main_ [] [ text "Nothing" ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
