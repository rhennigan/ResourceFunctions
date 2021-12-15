AssociationOuter // ClearAll;
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
AssociationOuter::internal =
"`1`";

AssociationOuter::rffail =
"Failed to retrieve definitions for the required resource function `1`.";

AssociationOuter::list =
"List expected at position `1` in `2`.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
AssociationOuter // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
AssociationOuter // Options = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$list = _List | _SparseArray? SparseArrayQ;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
AssociationOuter[ f_, args: $list... ] :=
    catchTop @ Module[ { rules, assoc },
        rules = makeRules[ f, args ];
        assoc = makeAssoc @ rules;
        AssociationKeyDeflatten @ assoc
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error cases*)

(*Invalid argument count:*)
AssociationOuter[ ] :=
    catchTop @ throwFailure[ "argm", AssociationOuter, 0, 1 ];

(*Invalid list arguments:*)
AssociationOuter[ f_, a___, b: Except[ $list ], c___ ] :=
    catchTop @ With[ { tag = If[ AtomQ @ Unevaluated @ b, "normal", "list" ] },
        throwFailure[
            tag,
            Length @ HoldComplete[ f, a, b ],
            HoldForm @ AssociationOuter[ f, a, b, c ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Misc utilities*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeRules*)
makeRules // beginDefinition;
makeRules // Attributes = { HoldAllComplete };

makeRules[ f_, a___ ] :=
    Replace[ Unevaluated /@ HoldComplete @ a,
             HoldComplete[ e___ ] :> checkOuter @ Outer[ makeOuterFunc @ f, e ]
    ];

makeRules // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkOuter*)
checkOuter // beginDefinition;
checkOuter[ list_List ] := Flatten @ list;
checkOuter // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeOuterFunc*)
makeOuterFunc // beginDefinition;
makeOuterFunc // Attributes = { HoldAllComplete };
makeOuterFunc[ f_ ] := Function[ Null, keys @ ## -> f @ ##, HoldAllComplete ];
makeOuterFunc // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeAssoc*)
makeAssoc // beginDefinition;

makeAssoc[ { a___ } ] :=
    UnevaluatedAssociation @@ (HoldComplete @ a /. keys -> List);

makeAssoc // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*keys*)
keys // ClearAll;
keys // Attributes = { HoldAllComplete };

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
    throwFailure[ MessageName[ AssociationOuter, tag ], params ];

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
        WithCleanup[ quiet @ MessageFailure @ args, $failed = True ]
    ];

messageFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwInternalFailure*)
throwInternalFailure // beginDefinition;
throwInternalFailure // Attributes = { HoldFirst };

throwInternalFailure[ eval_, a___ ] :=
    throwFailure[
        AssociationOuter::internal,
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
        "Fragment" -> SymbolName @ AssociationOuter
    |>
];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*External Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Utilities*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$selfResourceFunction*)
$selfResourceFunction // ClearAll;
$selfResourceFunction /: Set[ s_, $selfResourceFunction ] :=
    With[ { n = SymbolName @ Unevaluated @ s },
        s // ClearAll;
        s := Enclose[
            s = Block[ { PrintTemporary },
                    Confirm @ ResourceFunction[ n, "Function" ]
                ],
            throwFailure[ "rffail", n ] &
        ];
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ResourceFunctions*)
AssociationKeyDeflatten = $selfResourceFunction;
UnevaluatedAssociation  = $selfResourceFunction;
MessageFailure          = $selfResourceFunction;
