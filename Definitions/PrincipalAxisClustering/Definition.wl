PrincipalAxisClustering // ClearAll;
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
(* ::Section:: *)
(*Messages*)
PrincipalAxisClustering::internal =
"An unexpected error occurred. `1`";

PrincipalAxisClustering::matrix =
"The argument `1` is not a rectangular matrix of numeric values.";

PrincipalAxisClustering::invnarr =
"The array `1` is not valid.";

PrincipalAxisClustering::invspd =
"`1` is not a valid SpatialPointData object.";

PrincipalAxisClustering::invspdp =
"`1` does not contain valid point data.";

PrincipalAxisClustering::invcount =
"Non-negative integer or Automatic expected for the cluster count instead of
`1`.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
PrincipalAxisClustering // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
PrincipalAxisClustering // Options = { Method -> Median };

(*
    TODO: Possible options to implement (from FindClusters):
        CriterionFunction
        DistanceFunction
        FeatureExtractor
        FeatureNames
        FeatureTypes
        MissingValueSynthesis
        PerformanceGoal
        RandomSeeding
        Weights
*)

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
PrincipalAxisClustering[ points_, opts: OptionsPattern[ ] ] :=
    catchTop @ PrincipalAxisClustering[ points, Automatic, opts ];

PrincipalAxisClustering[ points_, maxItems_, opts: OptionsPattern[ ] ] :=
    catchTop @ principalAxisClustering[
        checkPoints @ points,
        checkMaxItems @ maxItems,
        OptionValue @ Method
    ];

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*principalAxisClustering*)
principalAxisClustering // beginDefinition;

e: principalAxisClustering[ arr_NumericArray, maxItems_, method_ ] :=
    Module[ { points, clusters, type, result },
        points = Developer`ToPackedArray @ Normal @ arr;
        If[ Dimensions @ points =!= 2, throwFailure[ "matrix", arr ] ];
        If[ ! pointsQ @ points, throwFailure[ "invnarr", arr ] ];
        clusters = principalAxisClustering[ points, maxItems, method ];
        If[ ! TrueQ @ clustersQ @ clusters, throwInternalFailure @ e ];
        type = NumericArrayType @ arr;
        result = NumericArray[ #, type ] & /@ clusters
    ];

principalAxisClustering[ points_? pointsQ, maxItems_, method_ ] :=
    Block[ { axisSign = getAxisSignFunc @ method },
        paClusters[ points, maxItems ]
    ];

principalAxisClustering // endDefinition;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

(* Invalid argument count: *)
PrincipalAxisClustering[ ] :=
    catchTop @ throwFailure[ "argm", PrincipalAxisClustering, 0, 2 ];

PrincipalAxisClustering[ a_, b_, c: Except[ OptionsPattern[ ] ], d___ ] :=
    catchTop @ throwFailure[
        "nonopt",
        c,
        2,
        HoldForm @ PrincipalAxisClustering[ a, b, c, d ]
    ];

(* Missed something that needs to be fixed: *)
e: PrincipalAxisClustering[ ___ ] :=
    catchTop @ throwInternalFailure @ e;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Argument Validation*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkPoints*)
checkPoints // beginDefinition;

checkPoints[ points_? pointsQ ] :=
    points;

checkPoints[ arr_NumericArray ] :=
    If[ NumericArrayQ @ arr, arr, throwFailure[ "invnarr", arr ] ];

checkPoints[ spd_SpatialPointData ] := (
    If[ ! System`Private`ValidQ @ spd, throwFailure[ "invspd", spd ] ];
    If[ ! pointsQ @ spd[ "Points" ], throwFailure[ "invspdp", spd ] ];
    spd
);

(*
    TODO:
        QuantityArray
        StructuredArray
        SymmetrizedArray
        RawArray
        SparseArray
        Association?
        GeoPositions?
*)

checkPoints[ other_ ] := throwFailure[ "matrix", other ];

checkPoints // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*pointsQ*)
pointsQ // beginDefinition;
pointsQ[ points_ ] := ArrayQ[ points, 2, NumericQ ];
pointsQ[ ___     ] := False;
pointsQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*clustersQ*)
clustersQ // beginDefinition;
clustersQ[ clusters_List ] := AllTrue[ clusters, pointsQ ];
clustersQ[ ___           ] := False;
clustersQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkMaxItems*)
checkMaxItems // beginDefinition;
checkMaxItems[ n_Integer? Positive ] := n;
checkMaxItems[ UpTo[ n_Integer? Positive ] ] := n;
checkMaxItems[ Automatic ] := Automatic;
checkMaxItems[ other_ ] := throwFailure[ "invcount", other ];
checkMaxItems // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Clustering*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*paClusters*)
paClusters // beginDefinition;

paClusters[ points_, Automatic ] :=
    paClusters[ points, 2 ^ Floor[ Log2 @ Length @ points / 2 ] ];

paClusters[ points_, maxItems_ ] :=
    Module[ { iterations, splitter, clusters, remaining },

        iterations = Floor @ Log2 @ maxItems;
        splitter   = Flatten[ split /@ #, 1 ] &;
        clusters   = Nest[ splitter, { points }, iterations ];
        remaining  = maxItems - Length @ clusters;

        partialSplit[ clusters, remaining ]
    ];

paClusters // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*split*)
split // beginDefinition;

split[ points_ /; Length @ points < 2 ] := { points };

split[ points_ ] :=
    Module[ { axis, sign, left, right },

        axis  = principalAxis @ points;
        sign  = axisSign[ points, axis ];
        left  = Pick[ points, sign, -1 ];
        right = Pick[ points, sign,  1 ];

        { left, right }
    ];

split // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*partialSplit*)
partialSplit // beginDefinition;

partialSplit[ clusters_, rem_ ] /; Less[ 0, rem, Length @ clusters ] :=
    Module[ { pos, splitter },

        pos = Keys @ TakeLargestBy[
                  Association @ MapIndexed[ #2 -> #1 &, clusters ],
                  Length,
                  rem
              ];

        splitter = Composition[ Apply @ Sequence, split ];

        MapAt[ splitter, clusters, pos ]
    ];

partialSplit[ clusters_, _ ] := clusters;

partialSplit // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Principal Axis*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*principalAxis*)
principalAxis // beginDefinition;

principalAxis[ points_ ] :=
    First[ Eigenvectors[ Covariance @ points, UpTo[ 1 ] ],
           throwInternalFailure @ principalAxis @ points
    ];

principalAxis // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getAxisSignFunc*)
getAxisSignFunc // beginDefinition;
getAxisSignFunc[ Mean      ] := axisMeanSign;
getAxisSignFunc[ Median    ] := axisMedianSign;
getAxisSignFunc[ Automatic ] := axisMedianSign;
getAxisSignFunc[ other_    ] := throwFailure[ "invmethod", other ];
getAxisSignFunc // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*axisSign*)
axisSign // ClearAll;
axisSign := getAxisSignFunc @ OptionValue[ PrincipalAxisClustering, Method ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*axisMedianSign*)
axisMedianSign // ClearAll;

axisMedianSign := axisMedianSign =
    Compile[ { { points, _Real, 2 }, { axis0, _Real, 1 } },
        Block[ { mean, shifted, axis, dotted, len, sign },

            mean    = Mean @ points;
            shifted = # - mean & /@ points;
            axis    = If[ Negative @ Total @ axis0, -axis0, axis0 ];
            dotted  = Dot[ shifted, axis ];
            len     = Length @ points;
            sign    = Sign[ dotted - Median @ dotted ];

            2 * Sign[ sign + 1 ] - 1
        ],
        RuntimeOptions    -> "Speed",
        RuntimeAttributes -> { Listable },
        Parallelization   -> True,
        CompilationTarget -> $compilationTarget
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*axisMeanSign*)
axisMeanSign // ClearAll;

axisMeanSign := axisMeanSign =
    Compile[ { { points, _Real, 2 }, { axis0, _Real, 1 } },
        Block[ { median, shifted, axis, dotted },

            median  = Mean @ points;
            shifted = # - median & /@ points;
            axis    = If[ Negative @ Total @ axis0, -axis0, axis0 ];
            dotted  = Dot[ shifted, axis ];

            Sign @ dotted
        ],
        RuntimeOptions    -> "Speed",
        RuntimeAttributes -> { Listable },
        Parallelization   -> True,
        CompilationTarget -> $compilationTarget
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Compilation*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$compilationTarget*)
$compilationTarget // ClearAll;
$compilationTarget := $compilationTarget = If[ noCCompilerQ[ ], "WVM", "C" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*noCCompilerQ*)
noCCompilerQ // beginDefinition;

noCCompilerQ[ ] :=
    TrueQ @ Quiet @ Check[
        Compile[ { }, 1 + 1, CompilationTarget -> "C" ],
        True,
        {
            CCompilerDriver`CreateLibrary::nocomp,
            CCompilerDriver`CreateLibrary::instl,
            Compile::nogen
        }
    ];

noCCompilerQ // endDefinition;

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
    throwFailure[ MessageName[ PrincipalAxisClustering, tag ], params ];

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
        PrincipalAxisClustering::internal,
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
        "Fragment" -> SymbolName @ PrincipalAxisClustering
    |>
];