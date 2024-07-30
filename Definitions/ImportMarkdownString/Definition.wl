(* !Excluded
This notebook was automatically generated from [Definitions/ImportMarkdownString](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/ImportMarkdownString).
*)

(* TODO:
    * Additional import elements:
        * CodeBlocks
        * Images
        * Links
        * Expressions
        * HeldExpressions
*)

ImportMarkdownString // ClearAll;
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
ImportMarkdownString::Internal =
"An unexpected error occurred. `1`";

ImportMarkdownString::ArgumentCount =
"ImportMarkdownString called with `1` arguments; 1 argument is expected.";

ImportMarkdownString::OptionsExpected =
"Options expected (instead of `1`) beyond position `2` in `3`. An option must be a rule or a list of rules.";

ImportMarkdownString::NotAString =
"Argument `1` is not a string.";

ImportMarkdownString::InvalidImportElement =
"Invalid import element `1`. Valid elements are \"Cell\", \"Notebook\", or Automatic.";

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Options*)
ImportMarkdownString // Options = {

};

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
ImportMarkdownString[ string_String? StringQ, opts: OptionsPattern[ ] ] :=
    ImportMarkdownString[ string, Automatic, opts ];

ImportMarkdownString[ string_String? StringQ, Automatic, opts: OptionsPattern[ ] ] := catchTop @ Enclose[
    Module[ { formatted, inlined, replaced },
        formatted = ConfirmMatch[ formatChatOutput @ string, _RawBoxes, "Formatted" ];
        replaced = ConfirmMatch[ replaceBoxes @ formatted, _RawBoxes, "Replaced" ];
        inlined = ConfirmMatch[ inlineTemplateBoxes @ replaced, _RawBoxes, "Inlined" ];
        ConfirmMatch[ setStyle @ inlined, _RawBoxes, "SetStyle" ]
    ],
    throwInternalFailure
];

ImportMarkdownString[ string_String? StringQ, "Cell", opts: OptionsPattern[ ] ] :=
    catchTop @ toCell @ ImportMarkdownString[ string, Automatic, opts ];

ImportMarkdownString[ string_String? StringQ, "Notebook", opts: OptionsPattern[ ] ] :=
    catchTop @ toNotebook @ ImportMarkdownString[ string, Automatic, opts ];

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

(* Not a string: *)
ImportMarkdownString[ invalid: Except[ _String? StringQ ], ___ ] :=
    catchTop @ throwFailure[ "NotAString", invalid, 1 ];

(* Not a valid import element: *)
ImportMarkdownString[ _, invalid: Except[ "Cell" | "Notebook" | Automatic ], ___ ] :=
    catchTop @ throwFailure[ "InvalidImportElement", invalid, 2 ];

(* Invalid argument count: *)
ImportMarkdownString[ ] :=
    catchTop @ throwFailure[ "ArgumentCount", 0, 2 ];

e: ImportMarkdownString[ _, _, invalid: Except[ OptionsPattern[ ] ], ___ ] :=
    catchTop @ throwFailure[ "OptionsExpected", invalid, 2, HoldForm @ e ];

(* Missed something that needs to be fixed: *)
e: ImportMarkdownString[ ___ ] :=
    catchTop @ throwInternalFailure @ e;

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatChatOutput*)
formatChatOutput // beginDefinition;
formatChatOutput[ string_String? StringQ ] := formatChatOutput[ string, formatChatOutput0 @ string ];
formatChatOutput[ string_, boxes_RawBoxes ] := boxes;
formatChatOutput // endDefinition;

formatChatOutput0 := (
    Needs[ "Wolfram`Chatbook`" -> None ];
    formatChatOutput0 = Symbol[ "Wolfram`Chatbook`FormatChatOutput" ]
);

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceBoxes*)
replaceBoxes // beginDefinition;
replaceBoxes[ boxes_ ] := boxes /. $boxReplacements;
replaceBoxes // endDefinition;


$boxReplacements := $boxReplacements = Dispatch @ {
    TemplateBox[ { boxes_ }, "ChatCodeBlockTemplate", opts___ ] :>
        With[ { new = FirstCase[ boxes, Cell[ __, "ChatCode", ___ ], Missing[ ], Infinity ] },
            TemplateBox[ { new }, "ChatCodeBlockTemplate", opts ] /; ! MissingQ @ new
        ]
};

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inlineTemplateBoxes*)
inlineTemplateBoxes // beginDefinition;
inlineTemplateBoxes[ boxes_ ] := inlineTemplateBoxes[ boxes, inlineTemplateBoxes0 @ boxes ];
inlineTemplateBoxes[ boxes_, inlined_RawBoxes ] := inlined;
inlineTemplateBoxes // endDefinition;

inlineTemplateBoxes0 := (
    Needs[ "Wolfram`Chatbook`" -> None ];
    inlineTemplateBoxes0 = Symbol @ SelectFirst[
        { "Wolfram`Chatbook`InlineTemplateBoxes", "Wolfram`Chatbook`Common`inlineTemplateBoxes" },
        NameQ,
        throwInternalFailure @ inlineTemplateBoxes0
    ]
);

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setStyle*)
setStyle // beginDefinition;
setStyle[ RawBoxes[ cell_ ] ] := RawBoxes @ setStyle @ cell;
setStyle[ Cell[ a___ ] ] := Cell[ a, "Text", Background -> None ];
setStyle // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toCell*)
toCell // beginDefinition;
toCell[ RawBoxes[ cell_ ] ] := toCell @ cell;
toCell[ cell_Cell ] := cell;
toCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toNotebook*)
toNotebook // beginDefinition;
toNotebook[ RawBoxes[ cell_ ] ] := toNotebook @ cell;
toNotebook[ cell_Cell ] := toNotebook[ cell, explodeCell @ cell ];
toNotebook[ cell_, cells: { ___Cell } ] := Notebook @ cells;
toNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*explodeCell*)
explodeCell // beginDefinition;
explodeCell[ RawBoxes[ cell_ ] ] := explodeCell @ cell;
explodeCell[ cell_Cell ] := explodeCell[ cell, explodeCell0 @ cell ];
explodeCell[ cell_, cells: { ___Cell } ] := cells;
explodeCell // endDefinition;

explodeCell0 := (
    Needs[ "Wolfram`Chatbook`" -> None ];
    explodeCell0 = Symbol @ SelectFirst[
        { "Wolfram`Chatbook`ExplodeCell", "Wolfram`Chatbook`Common`explodeCell" },
        NameQ,
        throwInternalFailure @ explodeCell0
    ]
);

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
    throwFailure[ MessageName[ ImportMarkdownString, tag ], params ];

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
    throwFailure[ ImportMarkdownString::Internal, $bugReportLink, HoldForm @ eval, a ];

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
        "Fragment" -> "ImportMarkdownString"
    |>
];