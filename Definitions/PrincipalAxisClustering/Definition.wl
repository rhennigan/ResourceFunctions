
PrincipalAxisClustering // ClearAll;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Messages*)
PrincipalAxisClustering::matrix = "\
The argument `1` is not a rectangular matrix of numeric values.";

PrincipalAxisClustering::invnarr = "\
The array `1` is not valid.";

PrincipalAxisClustering::invspd = "\
`1` is not a valid SpatialPointData object.";

PrincipalAxisClustering::invspdp = "\
`1` does not contain valid point data.";

PrincipalAxisClustering::invcount = "\
Non-negative integer or Automatic expected for the cluster count instead of `1`.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)

PrincipalAxisClustering // Options = {
    Method -> Median
};

(*
    TODO: Possible options to implement (from FindClusters):
        CriterionFunction
        DistanceFunction
        FeatureExtractor
        FeatureNames
        FeatureTypes
        Method
        MissingValueSynthesis
        PerformanceGoal
        RandomSeeding
        Weights
*)

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
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
(* ::Subsection::Closed:: *)
(*principalAxisClustering*)
principalAxisClustering // ClearAll;

e: principalAxisClustering[ arr_NumericArray, maxItems_, method_ ] :=
    Module[ { points, clusters, type, result },
        points = Developer`ToPackedArray @ Normal @ arr;
        If[ Dimensions @ points =!= 2, throwFailure[ "matrix", arr ] ];
        If[ ! pointsQ @ points, throwFailure[ "invnarr", arr ] ];
        clusters = principalAxisClustering[ points, maxItems, method ];
        If[ ! TrueQ @ clustersQ @ clusters, internalFailure @ e ];
        type = NumericArrayType @ arr;
        result = NumericArray[ #, type ] & /@ clusters
    ];

principalAxisClustering[ points_? pointsQ, maxItems_, method_ ] :=
    Block[ { axisSign = getAxisSignFunc @ method },
        paClusters[ points, maxItems ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Validation*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkPoints*)
checkPoints // ClearAll;

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

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*pointsQ*)
pointsQ // ClearAll;
pointsQ[ points_ ] := ArrayQ[ points, 2, NumericQ ];
pointsQ[ ___     ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clustersQ*)
clustersQ // ClearAll;
clustersQ[ clusters_List ] := AllTrue[ clusters, pointsQ ];
clustersQ[ ___           ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkMaxItems*)
checkMaxItems // ClearAll;
checkMaxItems[ n_Integer? Positive ] := n;
checkMaxItems[ UpTo[ n_Integer? Positive ] ] := n;
checkMaxItems[ Automatic ] := Automatic;
checkMaxItems[ other_ ] := throwFailure[ "invcount", other ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Recursive Clustering*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*paClusters*)
paClusters // ClearAll;

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

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*split*)
split // ClearAll;

split[ points_ /; Length @ points < 2 ] := { points };

split[ points_ ] :=
    Module[ { axis, sign, left, right },

        axis  = principalAxis @ points;
        sign  = axisSign[ points, axis ];
        left  = Pick[ points, sign, -1 ];
        right = Pick[ points, sign,  1 ];

        { left, right }
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*partialSplit*)
partialSplit // ClearAll;

partialSplit[ clusters_, rem_ ] /; Less[ 0, rem, Length @ clusters ] :=
    Module[ { lens, largest, pos, splitter },

        pos = Keys @ TakeLargestBy[
                  Association @ MapIndexed[ #2 -> #1 &, clusters ],
                  Length,
                  rem
              ];

        splitter = Composition[ Apply @ Sequence, split ];

        MapAt[ splitter, clusters, pos ]
    ];

partialSplit[ clusters_, _ ] := clusters;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Principal Axis*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*principalAxis*)
principalAxis // ClearAll;

principalAxis[ points_ ] :=
    First[ Eigenvectors[ Covariance @ points, UpTo[ 1 ] ],
           internalFailure @ principalAxis @ points
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getAxisSignFunc*)
getAxisSignFunc // ClearAll;
getAxisSignFunc[ Mean   ] := axisMeanSign;
getAxisSignFunc[ Median ] := axisMedianSign;
getAxisSignFunc[ other_ ] := throwFailure[ "invmethod", other ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*axisSign*)
axisSign // ClearAll;
axisSign := getAxisSignFunc @ OptionValue[ PrincipalAxisClustering, Method ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*axisSign*)
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
(* ::Subsection::Closed:: *)
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
(* ::Section::Closed:: *)
(*Compiled code utilities*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$compilationTarget*)
$compilationTarget // ClearAll;
$compilationTarget := $compilationTarget = If[ noCCompilerQ[ ], "WVM", "C" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*noCCompilerQ*)
noCCompilerQ // ClearAll;
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

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error handling*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*catchTop*)
catchTop // ClearAll;
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, $failed = False, catchTop = # & },
        Enclose[ eval, internalFailure @ eval & ]
    ] ~Catch~ $top;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*throwFailure*)
throwFailure // ClearAll;
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

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*messageFailure*)
messageFailure // ClearAll;
messageFailure // Attributes = { HoldFirst };
messageFailure[ args___ ] :=
    Module[ { quiet },
        quiet = If[ TrueQ @ $failed, Quiet, Identity ];
        WithCleanup[
            quiet @ ResourceFunction[ "MessageFailure" ][ args ],
            $failed = True
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*internalFailure*)
internalFailure // ClearAll;
internalFailure // Attributes = { HoldFirst };

internalFailure[ eval_ ] :=
    throwFailure[ PrincipalAxisClustering::internal, HoldForm @ eval ];
