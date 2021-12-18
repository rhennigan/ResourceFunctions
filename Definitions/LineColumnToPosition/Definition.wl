LineColumnToPosition // ClearAll;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Messages*)
LineColumnToPosition::strfile = "\
Expected a string or File instead of `1`.";

LineColumnToPosition::invpos = "\
Expected a pair of positive integers instead of `1`."

LineColumnToPosition::linebounds = "\
The line number `1` exceeds the number of lines available (`2`).";

LineColumnToPosition::colbounds = "\
The column number `1` exceeds the number of columns available (`2`) on the specified line.";

LineColumnToPosition::argb = "\
`1` called with `2` arguments; between `3` and `4` arguments are expected.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
LineColumnToPosition // Options = {
    "StrictColumnChecking" -> False,
    "StrictLineChecking"   -> True
};

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
LineColumnToPosition[ string_String ][ lc_ ] :=
    catchTop @ LineColumnToPosition[ string, lc ];

LineColumnToPosition[ File[ file_ ], lc___ ] :=
    catchTop @ LineColumnToPosition[ ReadString @ file, lc ];

LineColumnToPosition[
    string_String,
    { line_Integer? Positive, col_Integer? Positive }
] :=
    catchTop @ Module[ { lines },
        lines = lineSplit @ string;
        precedingLinesLength[ lines, line ] + col
    ];

LineColumnToPosition[ string_String, list: { __List } ] :=
    catchTop[ LineColumnToPosition @ string /@ list ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error handling*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Undefined argument patterns*)
LineColumnToPosition[ expr: Except[ _String | _File ], ___ ] :=
    throwFailure[ LineColumnToPosition::strfile, expr ];

LineColumnToPosition[ _String, invalid_ ] :=
    throwFailure[ LineColumnToPosition::invpos, invalid ];

LineColumnToPosition[ ] :=
    throwFailure[ LineColumnToPosition::argb, LineColumnToPosition, 0, 1, 2 ];

LineColumnToPosition[ a_, b_, c__ ] :=
    throwFailure[
        LineColumnToPosition::argb,
        LineColumnToPosition,
        Length @ HoldComplete[ a, b, c ],
        1,
        2
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Helpers*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchTop*)
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, catchTop = #1 & },
           Catch[ eval, $top ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwFailure*)
throwFailure // Attributes = { HoldFirst };

throwFailure[ tag_String, args___ ] :=
    throwFailure[ MessageName[ LineColumnToPosition, tag ], args ];

throwFailure[ msg_, args___ ] :=
    Module[ { failure },
        failure = ResourceFunction[ "MessageFailure" ][ msg, args ];
        If[ TrueQ @ $catching, Throw[ failure, $top ], failure ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Utilities*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*lineSplit*)
lineSplit[ string_ ] :=
    Module[ { split },
        split = StringSplit[ string, nl: "\r\n" | "\n" :> nl ];
        StringJoin /@ Partition[ split, UpTo[ 2 ] ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*precedingLinesLength*)
precedingLinesLength[ lines_, line_ ] :=
    Total[ StringLength /@ Take[ lines, UpTo @ Max[ 0, line - 1 ] ] ];
