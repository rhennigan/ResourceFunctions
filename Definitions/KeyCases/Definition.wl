(* !Excluded
This notebook was automatically generated from [Definitions/KeyCases](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/KeyCases).
*)

KeyCases // ClearAll;
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
KeyCases::Internal =
"An unexpected error occurred. `1`";

KeyCases::InvalidKeyValuePairs =
"The argument `1` is not a valid Association or set of rules.";

KeyCases::WrongNumberOfArguments =
"KeyCases called with `1` arguments; 2 or 3 arguments are expected.";

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
KeyCases[ as_, patt_ ] := catchTop @ keyCases[ as, patt ];

(* Operator form: *)
KeyCases[ patt_ ][ as_ ] := catchTop @ keyCases[ as, patt ];

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

KeyCases[ ] := catchTop @ throwFailure[ "WrongNumberOfArguments", 0 ];

KeyCases[ a_, b_, c__ ] := catchTop @ throwFailure[ "WrongNumberOfArguments", Length @ HoldComplete[ a, b, c ] ];

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*keyCases*)
keyCases // beginDefinition;
keyCases // Attributes = { HoldAllComplete };
keyCases[ as_Association? associationQ, patt_ ] := KeySelect[ as, keySelector @ patt ];
keyCases[ _[ rules: (Rule|RuleDelayed)[ _, _ ]... ], patt_ ] := keyListCases[ { rules }, patt ];
keyCases[ other_, patt_ ] := throwFailure[ "InvalidKeyValuePairs", HoldForm @ other ];
keyCases // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*associationQ*)
associationQ // ClearAll;
associationQ // Attributes = { HoldAllComplete };
associationQ[ as_Association ] := AssociationQ @ Unevaluated @ as;
associationQ[ ___ ] := False;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*keySelector*)
keySelector // beginDefinition;
keySelector // Attributes = { HoldAllComplete };
keySelector[ patt_ ] := Function[ Null, MatchQ[ Unevaluated @ #, HoldPattern @ patt ], HoldAllComplete ];
keySelector // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*keyListCases*)

(* Workaround for 431755: *)
keyListCases // beginDefinition;
keyListCases // Attributes = { HoldAllComplete };
keyListCases[ as: KeyValuePattern @ { }, patt_ ] := keyTake[ HoldComplete @ as, matchingKeys[ as, patt ] ];
keyListCases // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*keyTake*)
keyTake // beginDefinition;
keyTake[ HoldComplete[ as_ ], HoldComplete[ keys___ ] ] := KeyTake[ Unevaluated @ as, Unevaluated @ { keys } ];
keyTake // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*matchingKeys*)
matchingKeys // beginDefinition;
matchingKeys // Attributes = { HoldAllComplete };

matchingKeys[ as: KeyValuePattern @ { }, patt_ ] :=
    Module[ { cases },
        cases = Cases[ Unevaluated @ as, (Rule|RuleDelayed)[ key: HoldPattern @ patt, _ ] :> HoldComplete @ key ];
        Flatten[ HoldComplete @@ cases ]
    ];

matchingKeys // endDefinition;

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
    throwFailure[ MessageName[ KeyCases, tag ], params ];

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
    throwFailure[ KeyCases::Internal, $bugReportLink, HoldForm @ eval, a ];

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
        "Fragment" -> "KeyCases"
    |>
];