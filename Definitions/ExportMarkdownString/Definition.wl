(* !Excluded
This notebook was automatically generated from [Definitions/ExportMarkdownString](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/ExportMarkdownString).
*)

ExportMarkdownString // ClearAll;
(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
$inDef = False;
$debug = True;

(* ::**************************************************************************************************************:: *)
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

(* ::**************************************************************************************************************:: *)
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

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Messages*)
ExportMarkdownString::Internal =
"An unexpected error occurred. `1`";

ExportMarkdownString::ArgumentCount =
"ExportMarkdownString called with `1` arguments; 1 argument is expected.";

ExportMarkdownString::OptionsExpected =
"Options expected (instead of `1`) beyond position `2` in `3`. An option must be a rule or a list of rules.";

ExportMarkdownString::NamedExportNotString =
"Failed to produce valid output for `2` using export method `1`.";

ExportMarkdownString::ExportNotString =
"Expected a string when applying image export function `1` to `2` instead of `3`.";

ExportMarkdownString::NotDirectory =
"`1` is not a valid directory.";

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Options*)
ExportMarkdownString // Options = {
    "ImageExportMethod" -> None,
    ConversionRules     -> { },
    PageWidth           -> 100,
    WindowWidth         -> Automatic
};

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$$cell          = _Cell | _CellObject;
$$notebook      = _Notebook | _NotebookObject;
$$data          = _TextData | _BoxData | _RawData;
$$string        = _String? StringQ;
$$supportedItem = $$cell|$$notebook|$$data|$$string|_RawBoxes;
$$supported     = $$supportedItem | { $$supportedItem.. };

$$positiveInt = _Integer? Positive;

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
ExportMarkdownString[ expr_, opts0: OptionsPattern[ ] ] := catchTop @ Enclose[
    Module[ { converted, boxes, opts, imageExportMethod, contentTypes, string },
        converted = ConfirmMatch[ convertInput @ expr, $$supported, "ConvertInput" ];
        boxes = Replace[ converted, RawBoxes[ b_ ] :> b, If[ ListQ @ converted, { 1 }, { 0 } ] ];
        opts = FilterRules[ { opts0 }, Options @ cellToString ];
        imageExportMethod = OptionValue[ "ImageExportMethod" ];
        contentTypes = ConfirmMatch[ determineContentTypes @ imageExportMethod, { __String }, "ContentTypes" ];
        string = ConfirmBy[ cellToString[ boxes, opts, "ContentTypes" -> contentTypes ], StringQ, "Result" ];
        ConfirmBy[ exportImages[ string, imageExportMethod ], StringQ, "ExportImages" ]
    ],
    throwInternalFailure
];

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

(* Invalid argument count: *)
ExportMarkdownString[ ] :=
    catchTop @ throwFailure[ "ArgumentCount", 0, 2 ];

e: ExportMarkdownString[ _, invalid: Except[ OptionsPattern[ ] ], ___ ] :=
    catchTop @ throwFailure[ "OptionsExpected", invalid, 2, HoldForm @ e ];

(* Missed something that needs to be fixed: *)
e: ExportMarkdownString[ ___ ] :=
    catchTop @ throwInternalFailure @ e;

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Chatbook Dependencies*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*cellToString*)
cellToString := (
    Needs[ "Wolfram`Chatbook`" -> None ];
    cellToString = Symbol @ SelectFirst[
        { "Wolfram`Chatbook`CellToString", "Wolfram`Chatbook`Serialization`CellToString" },
        definedQ,
        throwInternalFailure @ cellToString
    ]
);

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getExpressionURI*)
getExpressionURI := (
    Needs[ "Wolfram`Chatbook`" -> None ];
    If[ definedQ[ "Wolfram`Chatbook`GetExpressionURI" ],
        getExpressionURI = Symbol[ "Wolfram`Chatbook`GetExpressionURI" ],
        throwInternalFailure @ getExpressionURI
    ]
);

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*definedQ*)
definedQ // beginDefinition;
definedQ[ name_String ] := ToExpression[ name, InputForm, System`Private`HasAnyEvaluationsQ ];
definedQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Option Handling*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*determineContentTypes*)
determineContentTypes // beginDefinition;
determineContentTypes[ None ] := { "Text" };
determineContentTypes[ Automatic|"Chatbook" ] := { "Text", "Image" };
determineContentTypes[ f_ ] := { "Text", "Image" };
determineContentTypes // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Input Conversion*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertInput*)
convertInput // beginDefinition;
convertInput[ expr_ ] := convertInput0 @ expr;
convertInput // endDefinition;

convertInput0 // beginDefinition;
convertInput0[ cell: _TextCell|_ExpressionCell ] := convertCell @ cell;
convertInput0[ group_CellGroup ] := convertCellGroup @ group;
convertInput0[ notebook: _DialogNotebook|_DocumentNotebook|_PaletteNotebook ] := convertNotebook @ notebook;
convertInput0[ cells: { ___Cell } ] := Notebook @ cells;
convertInput0[ expr: $$supported ] := expr;
convertInput0[ expr_ ] := RawBoxes @ StyleBox[ MakeBoxes @ expr, ShowStringCharacters -> False ];
convertInput0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertCell*)
convertCell // beginDefinition;
convertCell[ cell: _TextCell|_ExpressionCell ] := convertCell @ ToBoxes @ cell;
convertCell[ InterpretationBox[ cell_Cell, ___ ] ] := convertCell @ cell;
convertCell[ cell_Cell ] := cell;
convertCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertCellGroup*)
convertCellGroup // beginDefinition;
convertCellGroup[ CellGroup[ group_List ] ] := Cell @ CellGroupData[ convertInput /@ group, Open ];
convertCellGroup[ CellGroup[ group_List, n: $$positiveInt ] ] := cellGroupData[ group, { n } ];
convertCellGroup[ CellGroup[ group_List, n: { $$positiveInt... } ] ] := cellGroupData[ group, n ];
convertCellGroup[ group_CellGroup ] := feParseCellGroup @ group;
convertCellGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*cellGroupData*)
cellGroupData // beginDefinition;
cellGroupData[ group_List, spec_ ] := Cell @ CellGroupData[ convertInput /@ group, spec ];
cellGroupData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*feParseCellGroup*)
feParseCellGroup // beginDefinition;

feParseCellGroup[ group_CellGroup ] := Enclose[
    Module[ { nbo, nb, cells },
        WithCleanup[
            nbo = ConfirmMatch[
                CreateDocument[ group, CellGrouping -> Manual, Visible -> False ],
                _NotebookObject,
                "NotebookObject"
            ],
            nb = ConfirmMatch[ NotebookGet @ nbo, _Notebook, "Notebook" ],
            NotebookClose @ nbo
        ];
        cells = ConfirmMatch[ Flatten @ { First[ nb, $Failed ] }, { Cell[ _CellGroupData, ___ ] }, "Cells" ];
        First @ cells
    ],
    throwInternalFailure
];

feParseCellGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertNotebook*)
convertNotebook // beginDefinition;

convertNotebook[ notebook_ ] := Enclose[
    Module[ { nbo, nb },
        WithCleanup[
            nbo = ConfirmMatch[ CreateWindow[ notebook, Visible -> False ], _NotebookObject, "NotebookObject" ],
            nb = ConfirmMatch[ NotebookGet @ nbo, _Notebook, "Notebook" ],
            NotebookClose @ nbo
        ];
        nb
    ],
    throwInternalFailure
];

convertNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Images*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*exportImages*)
exportImages // beginDefinition;

exportImages[ markdown_String, None|Automatic ] := markdown;

exportImages[ markdown_String, f_ ] := Enclose[
    Module[ { expanded, exported },

        expanded = StringSplit[
            markdown,
            link: "\\!\\(\\*MarkdownImageBox[\"![" ~~ Except[ "]" ].. ~~ "](" ~~ uri: Except[ "\"" ].. ~~ ")\"]\\)" :>
                markdownImage[ getExpressionURI @ uri, link ]
        ];


        exported = ConfirmMatch[
            Replace[
                expanded,
                markdownImage[ expr_, s_ ] :>
                    With[ { e = applyImageExport[ f, expr ] }, If[ StringQ @ e, e, s ] ],
                { 1 }
            ],
            { ___String },
            "Exported"
        ];

        StringJoin @ exported
    ],
    throwInternalFailure
];

exportImages // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*applyImageExport*)
applyImageExport // beginDefinition;
applyImageExport[ "CloudObject", expr_ ] := checkExported[ "CloudObject", expr, defaultCloudObjectExport @ expr ];
applyImageExport[ dir: _File|_CloudObject, expr_ ] := directoryExport[ dir, expr ];
applyImageExport[ f_, expr_ ] := checkExported[ f, expr, f @ expr ];
applyImageExport // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*defaultCloudObjectExport*)
defaultCloudObjectExport // beginDefinition;
defaultCloudObjectExport[ e_ ] := CloudExport[ e, "PNG", Permissions -> "Public" ];
defaultCloudObjectExport // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*directoryExport*)
directoryExport // beginDefinition;

directoryExport[ File[ dir_ ], expr_ ] :=
    directoryExport[ dir, expr ];

directoryExport[ dir_? DirectoryQ, expr_ ] := Enclose[
    Module[ { hash, name, target, exported },
        hash = ConfirmBy[ Hash @ Unevaluated @ expr, IntegerQ, "Hash" ];
        name = ConfirmBy[ IntegerString[ hash, 36 ], StringQ, "Name" ]<>".png";
        target = FileNameJoin @ { dir, name };
        exported = ConfirmBy[ Export[ target, expr, "PNG" ], FileExistsQ, "Export" ];
        checkExported[ "Directory", expr, exported ]
    ],
    throwInternalFailure
];

directoryExport[ target_? FileExistsQ, expr_ ] :=
    throwFailure[ "NotDirectory", target ];

directoryExport[ target_, expr_ ] :=
    With[ { dir = CreateDirectory @ target },
        If[ ! DirectoryQ @ dir,
            throwFailure[ "NotDirectory", dir ],
            directoryExport[ dir, expr ]
        ]
    ];

directoryExport // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkExported*)
checkExported // beginDefinition;
checkExported[ f_, expr_, exported_String? FileExistsQ ] := toMarkdownLink @ exported;
checkExported[ f_, expr_, exported_String ] := exported;
checkExported[ f_, expr_, (CloudObject|URL)[ url_String, ___ ] ] := toMarkdownLink @ url;
checkExported[ f_, expr_, File[ file_String ] ] := toMarkdownLink @ file;
checkExported[ name_String, expr_, other_ ] := messageFailure[ "NamedExportNotString", name, expr, other ];
checkExported[ f_, expr_, other_ ] := messageFailure[ "ExportNotString", f, expr, other ];
checkExported // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toMarkdownLink*)
toMarkdownLink // beginDefinition;
toMarkdownLink[ uri_String ] := "![image](" <> uri <> ")";
toMarkdownLink // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error handling*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchTop*)
catchTop // beginDefinition;
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, $failed = False, catchTop = # & },
        Catch[ eval, $top ]
    ];

catchTop // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwFailure*)
throwFailure // beginDefinition;
throwFailure // Attributes = { HoldFirst };

throwFailure[ tag_String, params___ ] :=
    throwFailure[ MessageName[ ExportMarkdownString, tag ], params ];

throwFailure[ msg_, args___ ] :=
    Module[ { failure },
        failure = messageFailure[ msg, Sequence @@ HoldForm /@ { args } ];
        If[ TrueQ @ $catching,
            Throw[ failure, $top ],
            failure
        ]
    ];

throwFailure // endDefinition;

(* ::**************************************************************************************************************:: *)
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

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwInternalFailure*)
throwInternalFailure // beginDefinition;
throwInternalFailure // Attributes = { HoldFirst };

throwInternalFailure[ eval_, a___ ] :=
    throwFailure[ ExportMarkdownString::Internal, $bugReportLink, HoldForm @ eval, a ];

throwInternalFailure // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$bugReportLink*)
$bugReportLink := $bugReportLink = Hyperlink[
    "Report this issue \[RightGuillemet]",
    URLBuild @ <|
        "Scheme"   -> "https",
        "Domain"   -> "resources.wolframcloud.com",
        "Path"     -> { "FunctionRepository", "feedback-form" },
        "Fragment" -> "ExportMarkdownString"
    |>
];