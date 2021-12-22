(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Package header*)

Package[ "RH`ResourceFunctions`" ]

PackageScope[ "AutoTemplateStrings" ]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*AutoTemplateStrings*)
AutoTemplateStrings // ClearAll;

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
        insertEvaluated[ expr_ ] :>
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
      StringContainsQ[ str, "<%"~~__~~"%>" ]
  ];

templateStringQ[ ___ ] := False;

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
                ]
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
                ]
        }
    ];

stringTemplateInput[ str_String, BoxData ] :=
    StyleBox[
        RowBox @ Flatten @ StringSplit[
            str,
            {
                "<+" ~~ t: Shortest[ __ ] ~~ "+>" :> templateString @ t,
                "<%" ~~ t: Shortest[ __ ] ~~ "%>" :> literalString @ t
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
