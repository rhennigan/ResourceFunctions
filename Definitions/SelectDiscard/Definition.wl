(* !Excluded
This notebook was automatically generated from [Definitions/SelectDiscard](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/SelectDiscard).
*)

SelectDiscard // ClearAll;
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
SelectDiscard::Internal =
"An unexpected error occurred. `1`";

SelectDiscard::Normal =
"Nonatomic expression expected at position 1 in `1`.";

SelectDiscard::ArgumentCount =
"SelectDiscard called with `1` arguments; between 1 and 3 arguments are expected.";

SelectDiscard::Count =
"Non-negative integer or Infinity expected at position 3 in `1`.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$$assoc      = _Association? associationQ;
$$sparse     = _SparseArray? sparseArrayQ;
$$graph      = _Graph? graphQ;
$$normal     = _[ ___ ] | $$assoc | $$sparse;
$$selectable = $$normal | $$graph;
$$posInt     = _Integer? NonNegative;
$$count      = $$posInt | UpTo[ $$posInt ] | Infinity;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*associationQ*)
associationQ // ClearAll;
associationQ // Attributes = { HoldAllComplete };
associationQ[ as_Association ] := AssociationQ @ Unevaluated @ as;
associationQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*sparseArrayQ*)
sparseArrayQ // ClearAll;
sparseArrayQ // Attributes = { HoldAllComplete };
sparseArrayQ[ sa_SparseArray ] := SparseArrayQ @ Unevaluated @ sa;
sparseArrayQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*graphQ*)
graphQ // ClearAll;
graphQ // Attributes = { HoldAllComplete };
graphQ[ gr_Graph ] := GraphQ @ Unevaluated @ gr;
graphQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
SelectDiscard[ list: $$selectable, crit_ ] :=
    catchTop @ selectDiscard[ list, crit ];

SelectDiscard[ list: $$selectable, crit_, n: $$count ] :=
    catchTop @ selectDiscard[ list, crit, n ];

SelectDiscard[ crit_ ][ list_ ] :=
    catchTop @ SelectDiscard[ Unevaluated @ list, crit ];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

(* Wrong number of arguments: *)
SelectDiscard[ ] := catchTop @ throwFailure[ "ArgumentCount", 0 ];

SelectDiscard[ a_, b_, c_, d__ ] :=
    catchTop @ throwFailure[
        "ArgumentCount",
        Length @ HoldComplete[ a, b, c, d ]
    ];


(* First argument is atomic: *)
SelectDiscard[ expr_? atomQ, a__ ] :=
    catchTop @ throwFailure[
        "Normal",
        HoldForm @ SelectDiscard[ expr, a ]
    ];


(* Invalid count: *)
SelectDiscard[ list_, crit_, count: Except[ $$count ] ] :=
    catchTop @ throwFailure[
        "Count",
        HoldForm @ SelectDiscard[ list, crit, count ]
    ];


(* Missed something that needs to be fixed: *)
e: SelectDiscard[ _, __ ] := catchTop @ throwInternalFailure @ e;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*selectDiscard*)
selectDiscard // beginDefinition;

selectDiscard[ list_List, crit_ ] :=
    Lookup[ GroupBy[ Unevaluated @ list, bool @ crit ],
            { True, False },
            { }
    ];

selectDiscard[ list: $$normal, crit_ ] := {
    select[ list, crit ],
    select[ list, not @ crit ]
};

selectDiscard[ graph: $$graph, args__ ] := Enclose[
    Module[ { vertices, v1, v2, g1, g2 },
        vertices = ConfirmBy[ VertexList @ graph, ListQ ];
        { v1, v2 } = ConfirmMatch[ SelectDiscard[ vertices, args ], { _, _ } ];
        g1 = ConfirmBy[ Subgraph[ graph, v1 ], GraphQ ];
        g2 = ConfirmBy[ Subgraph[ graph, v2 ], GraphQ ];
        { g1, g2 }
    ],
    throwInternalFailure @ selectDiscard[ graph, args ] &
];

selectDiscard[ list_, crit_, Infinity | UpTo[ Infinity ] ] :=
    selectDiscard[ list, crit ];

selectDiscard[ list_, crit_, UpTo[ n: $$posInt ] ] :=
    Module[ { a, b, a1, a2 },
        { a, b } = selectDiscard[ list, crit ];
        { a1, a2 } = TakeDrop[ a, UpTo[ n ] ];
        { a1, Join[ a2, b ] }
    ];

selectDiscard[ list_, crit_, n: $$posInt ] :=
    selectDiscard[ list, crit, UpTo[ n ] ];

selectDiscard // Attributes = { HoldAllComplete };
selectDiscard // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*bool*)
bool // beginDefinition;
bool[ crit_ ] := Function[ e, TrueQ @ crit @ e, HoldAllComplete ];
bool // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*select*)
select // beginDefinition;
select // Attributes = { HoldAllComplete };

select[ list_, a__ ] :=
    Replace[ Select[ Unevaluated @ list, a ],
             _Select :> throwInternalFailure @ select[ list, a ]
    ];

select // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*not*)
not // beginDefinition;
not[ crit_ ] := Function[ e, ! TrueQ @ crit @ e, HoldAllComplete ];
not // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*atomQ*)
atomQ // ClearAll;
atomQ // Attributes = { HoldAllComplete };
atomQ[ expr_ ] := AtomQ @ Unevaluated @ expr;
atomQ[ ___   ] := False;

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
    throwFailure[ MessageName[ SelectDiscard, tag ], params ];

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
    throwFailure[ SelectDiscard::Internal, $bugReportLink, HoldForm @ eval, a ];

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
        "Fragment" -> "SelectDiscard"
    |>
];