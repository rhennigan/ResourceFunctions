CanonicalFileName // ClearAll;
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
beginDefinition::unfinished = "\
Starting definition for `1` without ending the current one.";

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
beginDefinition[ s_Symbol ] /; $debug && $inDef :=
    WithCleanup[
        $inDef = False
        ,
        Print @ TemplateApply[ beginDefinition::unfinished, HoldForm @ s ];
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
$$Messages

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
CanonicalFileName // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
CanonicalFileName // Options = { OperatingSystem :> $OperatingSystem };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$symbol = _Symbol? symbolQ;
$string = _String? stringQ;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
CanonicalFileName[ file_, opts: OptionsPattern[ ] ] :=
    If[ OptionValue @ OperatingSystem === "Windows",
        canonicalFileNameWin @ file,
        canonicalFileNameOther @ file
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error cases*)
$$ErrorCases

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

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
    throwFailure[ MessageName[ CanonicalFileName, tag ], params ];

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
    throwFailure[ CanonicalFileName::internal, $bugReportLink, HoldForm @ eval, a ];

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
        "Fragment" -> SymbolName @ CanonicalFileName
    |>
];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Misc utilities*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*canonicalFileNameWin*)
canonicalFileNameWin // beginDefinition;

canonicalFileNameWin[ file_ ] :=
    Enclose @ Module[ { split, trail, exists, parent, rest, before, after },

        split  = FileNameSplit @ ConfirmBy[ ExpandFileName @ file, StringQ ];
        trail  = FoldList[ Composition[ FileNameJoin, List ], split ];
        exists = LengthWhile[ trail, DirectoryQ ];
        { parent, rest } = TakeDrop[ split, exists ];
        before = ConfirmBy[ AbsoluteFileName @ FileNameJoin @ parent, StringQ ];
        after  = ToLowerCase @ FileNameJoin @ rest;

        FileNameJoin[
            FileNameSplit @ FileNameJoin @ { before, after },
            OperatingSystem -> "Unix"
        ]
    ];

canonicalFileNameWin // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*canonicalFileNameOther*)
canonicalFileNameOther // beginDefinition;

canonicalFileNameOther[ file_ ] := ExpandFileName @ file;

canonicalFileNameOther // endDefinition;
