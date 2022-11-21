(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Package header*)

Package[ "RH`ResourceFunctions`" ]

PackageExport[ "EvaluateInPlace" ]

PackageScope[ "AutoTemplateStrings" ]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*EvaluateInPlace*)
EvaluateInPlace[ expr_ ] := expr;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*AutoTemplateStrings*)
AutoTemplateStrings // ClearAll;

AutoTemplateStrings[
    Cell[
        str_String? excludedStringQ,
        style__String,
        opts: OptionsPattern[ ]
    ]
] :=
    AutoTemplateStrings @ Cell[
        StringTrim @ StringDelete[ str, StartOfString ~~ $exclusionPrefix ],
        style,
        "Excluded",
        opts
    ];

AutoTemplateStrings[ cell_Cell ] :=
    Replace[ AutoTemplateStrings @ { cell },
             Cell[ b_BoxData ] :> Cell[ b, "InlineFormula" ],
             { 4 }
    ];

AutoTemplateStrings[ cells_ ] :=
    Module[ { eval },
        eval = evaluateStringTemplates @ cells;
        eval /. $autoTemplateRules
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*excludedStringQ*)
excludedStringQ[ str_String? StringQ ] :=
    StringStartsQ[ str, $exclusionPrefix ];

excludedStringQ[ ___ ] := False;

$exclusionPrefix = WhitespaceCharacter... ~~ "!Excluded" ~~ WhitespaceCharacter;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*evaluateStringTemplates*)
evaluateStringTemplates // ClearAll;

evaluateStringTemplates[ cells_ ] :=
    ReplaceAll[
        cells,
        {
            Cell[ str_String, a___ ] /;
                StringContainsQ[ str, StringExpression[ "<*", __, "*>" ] ] :>
                    Cell[ stringTemplateEvaluate[ str, TextData ], a ]
            ,
            str_String /;
                StringContainsQ[ str, StringExpression[ "<*", __, "*>" ] ] :>
                    stringTemplateEvaluate @ str
        }
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stringTemplateEvaluate*)
stringTemplateEvaluate // ClearAll;

stringTemplateEvaluate[ str_String, TextData ] :=
    TextData @ Replace[
        stringTemplateEvaluate[ str, List ],
        HoldPattern @ insertEvaluated[ expr_ ] :>
            Cell[
                BoxData @ ToBoxes @ expr,
                "Input",
                FontFamily -> "Source Sans Pro"
            ],
        { 1 }
    ];

stringTemplateEvaluate[ str_String, List ] :=
    TemplateApply @ StringTemplate[
        str,
        CombinerFunction -> Identity,
        InsertionFunction -> insertEvaluated
    ];

stringTemplateEvaluate[ str_String ] :=
    TemplateApply @ StringTemplate[
        str,
        InsertionFunction -> Function[ ToString[ #, StandardForm ] ]
    ];


insertEvaluated[
    Hyperlink[ name_String, ref_String ] /; StringStartsQ[ ref, "paclet:" ]
] :=
    Cell[
        BoxData @ TagBox[
            ButtonBox[
                StyleBox[
                    name,
                    "SymbolsRefLink",
                    ShowStringCharacters -> True,
                    FontFamily -> "Source Sans Pro"
                ],
                BaseStyle ->
                    Dynamic @ FEPrivate`If[
                        CurrentValue[ "MouseOver" ],
                        {
                            "Link",
                            FontColor -> RGBColor[ 0.8549, 0.39608, 0.1451 ]
                        },
                        { "Link" }
                    ],
                ButtonData -> ref,
                ContentPadding -> False
            ],
            MouseAppearanceTag[ "LinkHand" ]
        ],
        "InlineFormula",
        FontFamily -> "Source Sans Pro"
    ];

insertEvaluated[ expr_ ] :=
    Cell[ BoxData @ ToBoxes @ expr, "Input", FontFamily -> "Source Sans Pro" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$autoTemplateRules*)
$autoTemplateRules // ClearAll;
$autoTemplateRules := $autoTemplateRules = Dispatch @ {
    Cell[ s_String? templateStringQ, a___ ] :>
        RuleCondition @ Cell[ stringTemplateInput[ s, TextData ], a ],
    Cell[
        b_BoxData /; FreeQ[ b, _Cell ] && !FreeQ[ b, _String? templateStringQ ],
        a___
    ] :>
        RuleCondition @ Cell[
            ReplaceAll[
                b,
                s_String? templateStringQ :>
                    RuleCondition @ stringTemplateInput[ s, BoxData ]
            ],
            a
        ],
    s_String? templateStringQ :>
        RuleCondition @ stringTemplateInput @ s
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*templateStringQ*)
templateStringQ // ClearAll;

templateStringQ[ str_String? StringQ ] :=
  TrueQ @ Or[
      StringContainsQ[ str, "<+"~~__~~"+>" ],
      StringContainsQ[ str, "<%"~~__~~"%>" ],
      StringContainsQ[ str, First @ urlPatternRule @ TextData ]
  ];

templateStringQ[ ___ ] := False;


$brace = "[" | "]" | "(" | ")";

urlPatternRule[ String ] :=
    "[" ~~ l: Except[ $brace ].. ~~ "](" ~~ u: Except[ $brace ].. ~~ ")" :>
        ToString[ RawBoxes @ hyperlinkBox[ l, u ], StandardForm ];

urlPatternRule[ _ ] :=
    "[" ~~ l: Except[ $brace ].. ~~ "](" ~~ u: Except[ $brace ].. ~~ ")" :>
        hyperlinkBox[ l, u ];

hyperlinkBox[ label_, url_ ] :=
    ButtonBox[
        label,
        BaseStyle  -> "Hyperlink",
        ButtonData -> { URL @ url, None },
        ButtonNote -> url
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stringTemplateInput*)
stringTemplateInput // ClearAll;

stringTemplateInput[ str_String ] :=
    StringReplace[
        str,
        {
            "<+" ~~ t: Shortest[ __ ] ~~ "+>" :>
                ToString[
                    RawBoxes @ StyleBox[
                        templateString @ t,
                        ShowStringCharacters -> True,
                        FontFamily -> "Source Sans Pro"
                    ],
                    StandardForm
                ],
            "<%" ~~ t: Shortest[ __ ] ~~ "%>" :>
                ToString[
                    RawBoxes @ StyleBox[
                        literalString @ t,
                        ShowStringCharacters -> True,
                        FontFamily -> "Source Sans Pro"
                    ],
                    StandardForm
                ],
            urlPatternRule @ String
        }
    ];

stringTemplateInput[ str_String, TextData ] :=
    TextData @ Flatten @ StringSplit[
        str,
        {
            "<+" ~~ t: Shortest[ __ ] ~~ "+>" :>
                Cell @ BoxData @ StyleBox[
                    templateString @ t,
                    ShowStringCharacters -> True,
                    FontFamily -> "Source Sans Pro"
                ],
            "<%" ~~ t: Shortest[ __ ] ~~ "%>" :>
                Cell @ BoxData @ StyleBox[
                    literalString @ t,
                    ShowStringCharacters -> True,
                    FontFamily -> "Source Sans Pro"
                ],
            urlPatternRule @ TextData
        }
    ];

stringTemplateInput[ str_String, BoxData ] :=
    StyleBox[
        RowBox @ Flatten @ StringSplit[
            str,
            {
                "<+" ~~ t: Shortest[ __ ] ~~ "+>" :> templateString @ t,
                "<%" ~~ t: Shortest[ __ ] ~~ "%>" :> literalString @ t,
                urlPatternRule @ BoxData
            }
        ],
        ShowStringCharacters -> True,
        FontFamily -> "Source Sans Pro"
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*templateString*)
templateString // ClearAll;
templateString[ s_ ] :=
    ReplaceAll[
        DefinitionNotebookClient`StringTemplateInput @ StringTrim @ s,
        "$$icon" :> ResourceSystemClient`Private`$resourceObjectNotebookBlob
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*literalString*)
literalString // ClearAll;
literalString[ s_ ] :=
    ReplaceAll[
        DefinitionNotebookClient`StringLiteralInput @ StringTrim @ s,
        "$$icon" :> ResourceSystemClient`Private`$resourceObjectNotebookBlob
    ];
