(* !Excluded
This notebook was automatically generated from [Definitions/SaveReadableNotebook](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/SaveReadableNotebook).
*)

SaveReadableNotebook // ClearAll;
(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
$inDef = False;
$debug = True;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*beginDefinition*)
beginDefinition // ClearAll;
beginDefinition // Attributes = { HoldFirst };
beginDefinition::Unfinished =
"Starting definition for `1` without ending the current one.";

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
beginDefinition[ s_Symbol ] /; $debug && $inDef :=
    WithCleanup[
        $inDef = False
        ,
        Print @ TemplateApply[ beginDefinition::Unfinished, HoldForm @ s ];
        beginDefinition @ s
        ,
        $inDef = True
    ];
(* :!CodeAnalysis::EndBlock:: *)

beginDefinition[ s_Symbol ] :=
    WithCleanup[ Unprotect @ s; ClearAll @ s, $inDef = True ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*endDefinition*)
endDefinition // beginDefinition;
endDefinition // Attributes = { HoldFirst };

endDefinition[ s_Symbol ] := endDefinition[ s, DownValues ];

endDefinition[ s_Symbol, None ] := $inDef = False;

endDefinition[ s_Symbol, DownValues ] :=
    WithCleanup[
        AppendTo[ DownValues @ s,
                  e: HoldPattern @ s[ ___ ] :>
                      throwInternalFailure @ HoldForm @ e
        ],
        $inDef = False
    ];

endDefinition[ s_Symbol, SubValues  ] :=
    WithCleanup[
        AppendTo[ SubValues @ s,
                  e: HoldPattern @ s[ ___ ][ ___ ] :>
                      throwInternalFailure @ HoldForm @ e
        ],
        $inDef = False
    ];

endDefinition[ s_Symbol, list_List ] :=
    endDefinition[ s, # ] & /@ list;

endDefinition // endDefinition;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Messages*)
SaveReadableNotebook::Internal =
"An unexpected error occurred. `1`";

SaveReadableNotebook::FormatError =
"The file `1` does not correspond to a valid notebook file.";

SaveReadableNotebook::NotebookObjectError =
"The notebook `1` is not a valid NotebookObject.";

SaveReadableNotebook::NotebookError =
"The notebook `1` is not a valid Notebook expression.";

SaveReadableNotebook::FileDoesNotExist =
"The file `1` does not exist.";

SaveReadableNotebook::InvalidNotebookSource =
"Expected a valid Notebook, NotebookObject, or notebook file instead of `1`.";

SaveReadableNotebook::InvalidTarget =
"`1` is not a valid destination for SaveReadableNotebook.";

SaveReadableNotebook::ExpectedOptions =
"Options expected (instead of `1`) beyond position `2` in `3`. An option must be a rule or a list of rules.";

SaveReadableNotebook::WrongNumberOfArguments =
"SaveReadableNotebook called with `1` arguments; between 1 and 2 arguments are expected.";

SaveReadableNotebook::ConversionFailed =
"Failed to convert notebook to readable form.";

SaveReadableNotebook::Mismatch =
"Warning: generated notebook yields a different expression.";

SaveReadableNotebook::FailedExport =
"Could not write to file `1`.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
SaveReadableNotebook // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Options*)
SaveReadableNotebook // Options = {
    "CachePersistence"        -> Automatic,
    "CharacterEncoding"       -> "ASCII",
    "DynamicAlignment"        -> False,
    "ExcludedCellOptions"     -> { CellChangeTimes, ExpressionUUID },
    "ExcludedNotebookOptions" -> { WindowSize, WindowMargins },
    "ExpressionChangeWarning" -> False,
    "FormatHeads"             -> { },
    "IndentSize"              -> 1,
    "InitialIndent"           -> 0,
    "PageWidth"               -> 60,
    "PerformanceGoal"         -> "Speed",
    "PrefixForm"              -> False,
    "RealAccuracy"            -> 5,
    "RelativeWidth"           -> True
};

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Patterns*)
$$string      = _String? StringQ;
$$notebook    = _Notebook;
$$notebookObj = _NotebookObject? notebookObjectQ;
$$file        = $$string | (File|URL|LocalObject|CloudObject)[ $$string, ___ ];
$$target      = $$file | String;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*notebookObjectQ*)
notebookObjectQ // beginDefinition;

notebookObjectQ[ nbo_NotebookObject ] :=
    StringQ @ CurrentValue[ nbo, ExpressionUUID ];

notebookObjectQ[ ___ ] := False;

notebookObjectQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)

(* Save a <+NotebookObject+>: *)
SaveReadableNotebook[ nbo: $$notebookObj, target_, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { nb },
        nb = NotebookGet @ nbo;
        If[ ! MatchQ[ nb, $$notebook ],
            throwFailure[ "NotebookObjectError", nbo ]
        ];
        SaveReadableNotebook[ nb, target, opts ]
    ];

(* Save a <+Notebook+> expression: *)
SaveReadableNotebook[ nb: $$notebook, target_, opts: OptionsPattern[ ] ] :=
    catchTop @ saveReadableNotebook[
        nb,
        target,
        OptionValue[ "ExcludedCellOptions"     ],
        OptionValue[ "ExcludedNotebookOptions" ],
        OptionValue[ "ExpressionChangeWarning" ],
        FilterRules[
            Join[ { opts }, Options @ SaveReadableNotebook ],
            Options @ readableForm
        ]
    ];

(* Import a <+Notebook+> from a file, then save it in readable form: *)
SaveReadableNotebook[ file_? FileExistsQ, target_, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { nb },
        nb = Quiet @ Import[ file, "NB" ];
        If[ ! MatchQ[ nb, $$notebook ],
            throwFailure[ "FormatError", file ]
        ];
        SaveReadableNotebook[ nb, target, opts ]
    ];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

(* Invalid <+NotebookObject[$$]+>: *)
SaveReadableNotebook[ nbo_NotebookObject, ___ ] :=
    catchTop @ throwFailure[ "NotebookObjectError", nbo ];

(* Invalid <+Notebook[$$]+>: *)
SaveReadableNotebook[ nb_Notebook, ___ ] :=
    catchTop @ throwFailure[ "NotebookError", nb ];

(* Source file does not exist: *)
SaveReadableNotebook[ file: $$file, ___ ] :=
    catchTop @ throwFailure[ "FileDoesNotExist", file ];

(* Invalid notebook source argument: *)
SaveReadableNotebook[ other_, ___ ] :=
    catchTop @ throwFailure[ "InvalidNotebookSource", other ];

(* Invalid options specification: *)
SaveReadableNotebook[
    notebook_,
    target_,
    a___,
    invalid: Except[ OptionsPattern[ ] ],
    b___
] :=
    catchTop @ throwFailure[
        "ExpectedOptions",
        invalid,
        Length @ Hold[ notebook, target, a ],
        HoldForm @ SaveReadableNotebook[ notebook, target, a, invalid, b ]
    ];

(* Wrong number of arguments: *)
SaveReadableNotebook[ a___ ] :=
    catchTop @ throwFailure[ "WrongNumberOfArguments", Length @ Hold @ a ];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*saveReadableNotebook*)
saveReadableNotebook // beginDefinition;

saveReadableNotebook[
    nb_,
    target_,
    excludedCellOpts_,
    excludedNBOpts_,
    warn_,
    opts_
] :=
    Module[ { cleanedCells, cleanedNB, string, exported },
        If[ ! MatchQ[ target, $$target ],
            throwFailure[ "InvalidTarget", target ]
        ];

        cleanedCells = excludeCellOptions[ nb, excludedCellOpts ];
        cleanedNB = excludeNBOptions[ cleanedCells, excludedNBOpts ];
        string = createNBString[ cleanedNB, $fullFormFormats, opts ];

        If[ ! StringQ @ string, throwFailure[ "ConversionFailed" ] ];

        If[ TrueQ @ warn && ! validNotebookStringQ[ cleanedNB, string ],
            $FailedString = string;
            $FailedNB = cleanedNB;
            Message[ SaveReadableNotebook::Mismatch ];
        ];

        If[ target === String, Throw[ string, $tag ] ];

        exported = ExpandFileName @ Export[ target, string, "String" ];

        If[ FileExistsQ @ exported,
            File @ exported,
            throwFailure[ "FailedExport", target ]
        ]
    ] ~Catch~ $tag;

saveReadableNotebook // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readableForm*)
readableForm // ClearAll;
readableForm := readableForm = ResourceFunction[ "ReadableForm", "Function" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*excludeCellOptions*)
excludeCellOptions // beginDefinition;
excludeCellOptions[ nb_, excluded_ ] := excludeOptions[ nb, Cell, excluded ];
excludeCellOptions // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*excludeNBOptions*)
excludeNBOptions // beginDefinition;
excludeNBOptions[ nb_, excluded_ ] := excludeOptions[ nb, Notebook, excluded ];
excludeNBOptions // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*excludeOptions*)
excludeOptions // beginDefinition;

excludeOptions[ expr_, head_, None ] := expr;

excludeOptions[ expr_, head_, All ] :=
    excludeOptions[ expr, head, (Rule|RuleDelayed)[ _, _ ] ];

excludeOptions[ expr_, head_, excluded_ ] :=
    With[ { patt = toExcludedOptionPattern @ excluded },
        ReplaceRepeated[
            expr,
            e: head[ ___, patt, ___ ] :>
                With[ { d = DeleteCases[ $ConditionHold @ e, patt, { 2 } ] },
                    RuleCondition[ d, True ]
                ]
        ]
    ];

excludeOptions // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toExcludedOptionPattern*)
toExcludedOptionPattern // beginDefinition;

toExcludedOptionPattern[ name: _Symbol|_String ] :=
    (Rule|RuleDelayed)[ toExcludedOptionName @ name, _ ];

toExcludedOptionPattern[ (r: Rule|RuleDelayed)[ s: _Symbol|_String, v_ ] ] :=
    r[ toExcludedOptionName @ s, v ];

toExcludedOptionPattern[ list_List ] :=
    Alternatives @@ Flatten[ toExcludedOptionPattern /@ list ];

toExcludedOptionPattern[ other_ ] := other;

toExcludedOptionPattern // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toExcludedOptionName*)
toExcludedOptionName // beginDefinition;
toExcludedOptionName // Attributes = { HoldFirst };

toExcludedOptionName[ sym_Symbol ] :=
    SymbolName @ Unevaluated @ sym | HoldPattern @ sym;

toExcludedOptionName[ name_String ] /; Internal`SymbolNameQ[ name, True ] :=
    name | _Symbol? (symbolNamedQ @ name);

toExcludedOptionName[ other_ ] := HoldPattern @ other;

toExcludedOptionName // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*symbolNamedQ*)
symbolNamedQ // beginDefinition;

symbolNamedQ[ name_String ] :=
    Function[ sym, SymbolName @ Unevaluated @ sym === name, HoldAllComplete ];

symbolNamedQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*createNBString*)
createNBString // beginDefinition;

createNBString[ nb_, HoldComplete[ overrides___ ], { opts___ } ] :=
    Identity[ Internal`InheritedBlock ][ { RawArray, NumericArray, overrides },

        Unprotect[ RawArray, NumericArray, overrides ];
        ReleaseHold[ overrideFormat /@ HoldComplete @ overrides ];

        Format[ x_RawArray? rawArrayQ, InputForm ] :=
            OutputForm[ "CompressedData[\"" <> Compress @ x <> "\"]" ];

        Format[ x_NumericArray? numericArrayQ, InputForm ] :=
            OutputForm[ "CompressedData[\"" <> Compress @ x <> "\"]" ];

        $nbStringHeader <> ToString @ ResourceFunction[ "ReadableForm" ][
            stripCellContext[ nb /. $fullFormRules ],
            opts
        ]
    ];

createNBString // endDefinition;

$nbStringHeader = "\
(* Content-type: application/vnd.wolfram.mathematica *)

(*** Wolfram Notebook File ***)
(* http://www.wolfram.com/nb *)

(* Created By: SaveReadableNotebook *)
(* https://resources.wolframcloud.com/FunctionRepository/resources/SaveReadableNotebook *)

";

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*overrideFormat*)
overrideFormat // beginDefinition;
overrideFormat // Attributes = { HoldAllComplete };

overrideFormat[ sym_Symbol ] := (
    Unprotect @ sym;
    Format[ x_sym, InputForm ] :=
        OutputForm @ ToString @ Unevaluated @ FullForm @ x
);

overrideFormat // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*rawArrayQ*)
rawArrayQ // ClearAll;
rawArrayQ // Attributes = { HoldFirst };
rawArrayQ[ arr_RawArray ] := Developer`RawArrayQ @ Unevaluated @ arr;
rawArrayQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*numericArrayQ*)
numericArrayQ // ClearAll;
numericArrayQ // Attributes = { HoldFirst };
numericArrayQ[ arr_NumericArray ] := NumericArrayQ @ Unevaluated @ arr;
numericArrayQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$fullFormRules*)
$fullFormRules // ClearAll;
$fullFormRules := $fullFormRules = Dispatch @ Cases[
    $fullFormFormats,
    s_Symbol :> (HoldPattern @ s -> fullFormHead @ s)
];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fullFormHead*)
fullFormHead // ClearAll;
fullFormHead // Attributes = { HoldFirst };
fullFormHead /: Format[ fullFormHead[ h_ ], InputForm ] := h;
fullFormHead /: MakeBoxes[ fullFormHead[ h_ ], fmt_ ] := MakeBoxes[ h, fmt ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*stripCellContext*)
stripCellContext // beginDefinition;

stripCellContext[ nb_ ] :=
    ReplaceAll[
        nb,
        sym_Symbol? cellContextQ :>
            With[ { s = stripCellContext0[ sym, $ConditionHold ] },
                RuleCondition[ s, True ]
            ]
    ];

stripCellContext // endDefinition;

stripCellContext0 // beginDefinition;
stripCellContext0 // Attributes = { HoldAllComplete };
stripCellContext0[ sym_ ] := stripCellContext0[ sym, HoldComplete ];
stripCellContext0[ sym_, wrapper_ ] :=
    ToExpression[ SymbolName @ Unevaluated @ sym, InputForm, wrapper ];
stripCellContext0 // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellContextQ*)
cellContextQ // ClearAll;
cellContextQ // Attributes = { HoldAllComplete };
cellContextQ[ sym_Symbol? symbolQ ] := Context @ sym === "$CellContext`";
cellContextQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*symbolQ*)
symbolQ // ClearAll;
symbolQ // Attributes = { HoldAllComplete };

symbolQ[ sym_Symbol ] := TrueQ @ And[
    AtomQ @ Unevaluated @ sym,
    ! Internal`RemovedSymbolQ @ Unevaluated @ sym,
    Unevaluated @ sym =!= Internal`$EFAIL
];

symbolQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$fullFormFormats*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
$fullFormFormats // ClearAll;
$fullFormFormats = HoldComplete[
    AddTo,
    Alternatives,
    Apply,
    Blank,
    BlankNullSequence,
    BlankSequence,
    Composition,
    Condition,
    Decrement,
    DivideBy,
    Factorial,
    Factorial2,
    Increment,
    Map,
    MapAll,
    System`MapApply,
    MessageName,
    Not,
    Out,
    Part,
    Pattern,
    PatternTest,
    PreDecrement,
    PreIncrement,
    Repeated,
    RepeatedNull,
    ReplaceAll,
    ReplaceRepeated,
    RightComposition,
    Span,
    StringExpression,
    StringJoin,
    SubtractFrom,
    TimesBy,
    TwoWayRule,
    Unset,
    UpSet,
    UpSetDelayed
];
(* :!CodeAnalysis::EndBlock:: *)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validNotebookStringQ*)
validNotebookStringQ // beginDefinition;

validNotebookStringQ[ nb_Notebook, s_String ] :=
    ImportString[ s, "NB" ] === ImportString[ ExportString[ nb, "NB" ], "NB" ];

validNotebookStringQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error handling*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchTop*)
catchTop // beginDefinition;
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, $failed = False, catchTop = # & },
        Catch[ eval, $top ]
    ];

catchTop // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwFailure*)
throwFailure // beginDefinition;
throwFailure // Attributes = { HoldFirst };

throwFailure[ tag_String, params___ ] :=
    throwFailure[ MessageName[ SaveReadableNotebook, tag ], params ];

throwFailure[ msg_, args___ ] :=
    Module[ { failure },
        failure = messageFailure[ msg, Sequence @@ HoldForm /@ { args } ];
        If[ TrueQ @ $catching,
            Throw[ failure, $top ],
            failure
        ]
    ];

throwFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*messageFailure*)
messageFailure // beginDefinition;
messageFailure // Attributes = { HoldFirst };

messageFailure[ args___ ] :=
    Module[ { quiet },
        quiet = If[ TrueQ @ $failed, Quiet, Identity ];
        WithCleanup[
            quiet @ ResourceFunction[ "MessageFailure" ][ args ],
            $failed = True
        ]
    ];

messageFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwInternalFailure*)
throwInternalFailure // beginDefinition;
throwInternalFailure // Attributes = { HoldFirst };

throwInternalFailure[ eval_, a___ ] :=
    throwFailure[
        SaveReadableNotebook::Internal,
        $bugReportLink,
        HoldForm @ eval,
        a
    ];

throwInternalFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$bugReportLink*)
$bugReportLink := $bugReportLink = Hyperlink[
    "Report this issue \[RightGuillemet]",
    URLBuild @ <|
        "Scheme"   -> "https",
        "Domain"   -> "resources.wolframcloud.com",
        "Path"     -> { "FunctionRepository", "feedback-form" },
        "Fragment" -> SymbolName @ SaveReadableNotebook
    |>
];