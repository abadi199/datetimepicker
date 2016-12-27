port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import DateTimePicker.Css


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "styles.css", Css.File.compile [ DateTimePicker.Css.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
