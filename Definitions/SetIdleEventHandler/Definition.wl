(* !Excluded
This notebook was automatically generated from [Definitions/SetIdleEventHandler](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/SetIdleEventHandler).
*)

SetIdleEventHandler // ClearAll;
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
(* ::Section:: *)
(*Messages*)
SetIdleEventHandler::Internal =
"An unexpected error occurred. `1`";

SetIdleEventHandler::InvalidCell =
"Expected a valid Cell or CellObject instead of `1`.";

SetIdleEventHandler::InvalidDelay =
"Expected Automatic, None, or a non-negative value instead of `1`.";

SetIdleEventHandler::OptionsExpected =
"Options expected (instead of `1`) beyond position `2` in `3`. An option must \
be a rule or a list of rules.";

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Attributes*)
SetIdleEventHandler // Attributes = { HoldAll };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Options*)
SetIdleEventHandler // Options = { "Delay" -> 1 };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$$association = _Association? AssociationQ;
$$cellObject  = _CellObject? cellObjectQ;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*cellObjectQ*)
cellObjectQ // ClearAll;
cellObjectQ[ co_CellObject ] := StringQ @ CurrentValue[ co, ExpressionUUID ];
cellObjectQ[ ___           ] := False;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
SetIdleEventHandler[ code_, opts: OptionsPattern[ ] ] :=
    catchTop @ SetIdleEventHandler[ EvaluationCell[ ], code, opts ];

SetIdleEventHandler[ cell_, code_, opts: OptionsPattern[ ] ] :=
    catchTop @ With[ { delay = OptionValue[ "Delay" ] },
        SetIdleEventHandler[ cell, code, delay, opts ]
    ];

SetIdleEventHandler[ cell_, code_, delay_, opts: OptionsPattern[ ] ] :=
	catchTop @ setIdleEventHandler[
        cell,
        HoldComplete @ code,
        optionsAssociation[ SetIdleEventHandler, opts, "Delay" -> delay ]
    ];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

(* Wrong number of arguments: *)
e: SetIdleEventHandler[ _, _, _, a: Except[ OptionsPattern[ ] ], ___ ] :=
    catchTop @ throwFailure[ "OptionsExpected", a, 3, HoldForm @ e ];

(* Missed something that needs to be fixed: *)
e: SetIdleEventHandler[ ___ ] :=
    catchTop @ throwInternalFailure @ e;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)
$editCounter = 0;
$tasks       = <| |>;
$timeouts    = <| |>;
$timestamps  = <| |>;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*initialize*)
initialize[ ] := initialize[ ] = (
    $editCounter = 0;
    $tasks       = <| |>;
    $timeouts    = <| |>;
    $timestamps  = <| |>;
    Internal`SetValueNoTrack[ { checkUpdate }, True ];
);

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$rf*)
$rf := $rf = Block[ { PrintTemporary },
    StringQ @ Quiet @ ResourceFunction[ "SetIdleEventHandler", "Name" ]
];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setIdleEventHandler*)
setIdleEventHandler // beginDefinition;

setIdleEventHandler[ cell: $$cellObject, HoldComplete @ None, _ ] :=
    (CurrentValue[ cell, CellDynamicExpression ] = Inherited);

setIdleEventHandler[ cell_Cell, HoldComplete @ None, _ ] :=
    DeleteCases[ cell, (Rule|RuleDelayed)[ CellDynamicExpression, _ ] ];

setIdleEventHandler[ cell: $$cellObject, code_, opts: $$association ] := (
    initialize[ ];
    SetOptions[ cell, CellDynamicExpression -> idleHandler[ code, opts ] ]
);

setIdleEventHandler[ cell_Cell, code_, opts: $$association ] := (
    initialize[ ];
    Append[ DeleteCases[ cell, (Rule|RuleDelayed)[ CellDynamicExpression, _ ] ],
            CellDynamicExpression -> idleHandler[ code, opts ]
    ]
);

setIdleEventHandler[ cell: Except[ $$cellObject|_Cell ], ___ ] :=
    throwFailure[ "InvalidCell", cell ];

setIdleEventHandler // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*idleHandler*)
idleHandler // beginDefinition;

idleHandler[ heldCode_, opts: $$association ] :=
    idleHandler[ heldCode, Lookup[ opts, "Delay", Automatic ] ];

idleHandler[ heldCode_, Automatic ] :=
    idleHandler[ heldCode, 1.0 ];

idleHandler[ heldCode_, None ] :=
    idleHandler[ heldCode, 0.0 ];

idleHandler[ HoldComplete[ code_ ], delay_? NonNegative ] /; $rf :=
    Dynamic @ ReplaceAll[
        Unevaluated[
            Once[
                Quiet @ Symbol @ StringJoin[
                    ResourceFunction[ "SetIdleEventHandler", "Context" ],
                    "checkUpdate"
                ]
            ][
                code,
                Max @ CurrentValue[ EvaluationCell[ ], CellChangeTimes ],
                EvaluationCell[ ],
                delay
            ]
        ],
        HoldPattern @ EvaluationCell[ ] -> EvaluationCell[ ]
    ];

idleHandler[ HoldComplete[ code_ ], delay_? NonNegative ] :=
    Dynamic @ ReplaceAll[
        Unevaluated @ checkUpdate[
            code,
            Max @ CurrentValue[ EvaluationCell[ ], CellChangeTimes ],
            EvaluationCell[ ],
            delay
        ],
        HoldPattern @ EvaluationCell[ ] -> EvaluationCell[ ]
    ];

idleHandler[ HoldComplete[ code_ ], delay_ ] :=
    throwFailure[ "InvalidDelay", delay ];

idleHandler // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkUpdate*)
checkUpdate // beginDefinition;
checkUpdate // Attributes = { HoldFirst };

checkUpdate[ eval_, new_, cell_, delay_ ] := (
    If[ ! AssociationQ @ $timestamps, $timestamps = <| |> ];
    If[ ! NumberQ @ $timestamps @ cell, $timestamps[ cell ] = 0 ];
    If[ TrueQ[ new > $timestamps @ cell ],
        startDelayedEval[ cell, eval, delay ]
    ];
    $timestamps[ cell ] = new
);

checkUpdate // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*startDelayedEval*)
startDelayedEval // beginDefinition;
startDelayedEval // Attributes = { HoldRest };

startDelayedEval[ id_, { active_, idle_ }, delay_ ] := (
    active;
    If[ IntegerQ @ $editCounter, $editCounter++, $editCounter = 1 ];
    If[ ! AssociationQ @ $tasks   , $tasks    = <| |> ];
    If[ ! AssociationQ @ $timeouts, $timeouts = <| |> ];
    $timeouts[ id ] = AbsoluteTime[ TimeZone -> 0 ] + delay;
    If[ ! KeyExistsQ[ $tasks, id ],
        $tasks[ id ] =
            RunScheduledTask[
                If[ AbsoluteTime[ TimeZone -> 0 ] > $timeouts @ id,
                    WithCleanup[
                        idle,
                        KeyDropFrom[ $tasks, id ];
                        RemoveScheduledTask @ $ScheduledTask
                    ]
                ],
                1
            ]
    ]
);

startDelayedEval[ id_, eval_, delay_ ] :=
    startDelayedEval[ id, { None, eval }, delay ];

startDelayedEval // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*optionsAssociation*)
optionsAssociation // beginDefinition;

optionsAssociation[ sym_Symbol, opts___ ] :=
    Module[ { assoc },
        assoc = Association @ Reverse @ Flatten @ { opts, Options @ sym };
        KeyMap[ ToString, assoc ] /; AssociationQ @ assoc
    ];

optionsAssociation // endDefinition;

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
    throwFailure[ MessageName[ SetIdleEventHandler, tag ], params ];

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
        SetIdleEventHandler::Internal,
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
        "Fragment" -> "SetIdleEventHandler"
    |>
];