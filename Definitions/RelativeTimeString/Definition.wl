(* !Excluded
This notebook was automatically generated from [Definitions/RelativeTimeString](https://github.com/rhennigan/ResourceFunctions/blob/main/Definitions/RelativeTimeString).
*)

RelativeTimeString // ClearAll;
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
RelativeTimeString::Internal =
"An unexpected error occurred. `1`";

RelativeTimeString::InvalidDate =
"Expression `1` cannot be interpreted as a date specification.";

RelativeTimeString::InvalidUnit =
"Expression `1` is not a valid time quantity.";

RelativeTimeString::WrongNumberOfArguments =
"RelativeTimeString called with `1` arguments; between 1 and 2 arguments are \
expected.";

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Attributes*)
RelativeTimeString // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Options*)
RelativeTimeString // Options = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$$tinyUnit = Alternatives[
    "Attoseconds",
    "Femtoseconds",
    "Microseconds",
    "Milliseconds",
    "Nanoseconds",
    "Picoseconds",
    "PlanckTime",
    "Yoctoseconds",
    "Zeptoseconds"
];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
RelativeTimeString[ time_Quantity ] :=
    catchTop @ relativeTimeString @ time;

RelativeTimeString[ date_DateObject? DateObjectQ ] :=
    catchTop @ RelativeTimeString[
        DateObject[ Now, date[ "Granularity" ] ],
        date
    ];

RelativeTimeString[ date_DateInterval ] :=
    catchTop @ Enclose[
        Module[ { bounds, quant, seconds, int },

            bounds = ConfirmMatch[
                toDateObject /@ DateBounds @ date,
                { _? DateObjectQ, _? DateObjectQ }
            ];

            quant = ConfirmMatch[
                bounds - $now,
                { _Quantity, _Quantity }
            ];

            seconds = ConfirmMatch[
                QuantityMagnitude @ UnitConvert[ quant, "Seconds" ],
                { _? NumberQ, _? NumberQ }
            ];

            int = Confirm @ Quantity[ Interval @ seconds, "Seconds" ];

            RelativeTimeString @ int
        ],
        throwFailure[ "InvalidDateInterval", date ] &
    ];

RelativeTimeString[ date_ ] :=
    catchTop @ RelativeTimeString @ toDateObject @ date;

RelativeTimeString[ date1_, date2_ ] :=
    catchTop @ Module[ { d1, d2, diff },
        d1 = toDateObject @ date1;
        d2 = toDateObject @ date2;
        diff = d2 - d1;
        relativeTimeString @ diff
    ];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

(* Wrong number of arguments: *)
RelativeTimeString[ ] :=
    catchTop @ throwFailure[ "WrongNumberOfArguments", 0 ];

RelativeTimeString[ a_, b_, c__ ] :=
    catchTop @ throwFailure[
        "WrongNumberOfArguments",
        Length @ HoldComplete[ a, b, c ]
    ];

(* Missed something that needs to be fixed: *)
e: RelativeTimeString[ ___ ] :=
    catchTop @ throwInternalFailure @ e;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Relative Date Intervals*)
ClearAll[ $now, $yesterday, $lastNight, $thisMorning, $tomorrow,
          $tomorrowMorning, $lastWeek, $nextWeek ];

$now             := $now             = Now;
$yesterday       := $yesterday       = yesterday[ ];
$lastNight       := $lastNight       = lastNight[ ];
$thisMorning     := $thisMorning     = thisMorning[ ];
$tonight         := $tonight         = tonight[ ];
$tomorrow        := $tomorrow        = tomorrow[ ];
$tomorrowMorning := $tomorrowMorning = tomorrowMorning[ ];
$lastWeek        := $lastWeek        = lastWeek[ ];
$nextWeek        := $nextWeek        = nextWeek[ ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*yesterday*)
yesterday // beginDefinition;

yesterday[ ] :=
    Module[ { t1, t2, cut },
        t1 = DateObject[ Take[ DateList @ $now, 3 ] - { 0, 0, 1 }, "Instant" ];
        t2 = t1 + Quantity[ 24, "Hours" ];
        cut = $now - Quantity[ 8, "Hours" ];
        Which[ TrueQ[ cut < t1        ], DateInterval[ { } ],
               TrueQ[ t1 <= cut <= t2 ], DateInterval[ { t1, cut } ],
               True                    , DateInterval[ { t1, t2 } ]
        ]
    ];

yesterday // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*lastNight*)
lastNight // beginDefinition;

lastNight[ ] :=
    Module[ { t0, t1, t2, cut },
        t0 = DateObject[ Take[ DateList @ $now, 3 ] - { 0, 0, 1 }, "Instant" ];
        t1 = t0 + Quantity[ 20, "Hours" ];
        t2 = t0 + Quantity[ 24, "Hours" ];
        cut = $now - Quantity[ 8, "Hours" ];
        Which[ TrueQ[ cut < t1        ], DateInterval[ { } ],
               TrueQ[ t1 <= cut <= t2 ], DateInterval[ { t1, cut } ],
               True                    , DateInterval[ { t1, t2 } ]
        ]
    ];

lastNight // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*thisMorning*)
thisMorning // beginDefinition;

thisMorning[ ] :=
    Module[ { t0, t1, t2, cut },
        t0 = DateObject[ Take[ DateList @ $now, 3 ], "Instant" ];
        t1 = t0 + Quantity[ 4 , "Hours" ];
        t2 = t0 + Quantity[ 12, "Hours" ];
        cut = $now - Quantity[ 8, "Hours" ];
        Which[ TrueQ[ cut < t1        ], DateInterval[ { } ],
               TrueQ[ t1 <= cut <= t2 ], DateInterval[ { t1, cut } ],
               True                    , DateInterval[ { t1, t2 } ]
        ]
    ];

thisMorning // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*tonight*)
tonight // beginDefinition;

tonight[ ] :=
    Module[ { t0, t1, t2, cut },
        t0 = DateObject[ Take[ DateList @ $now, 3 ], "Instant" ];
        t1 = t0 + Quantity[ 20 , "Hours" ];
        t2 = t0 + Quantity[ 24, "Hours" ];
        cut = $now + Quantity[ 8, "Hours" ];

        Which[ TrueQ[ t2 < cut        ], DateInterval[ { } ],
               TrueQ[ t1 <= cut <= t2 ], DateInterval[ { cut, t2 } ],
               True                    , DateInterval[ { t1, t2 } ]
        ]
    ];

tonight // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*tomorrow*)
tomorrow // beginDefinition;

tomorrow[ ] :=
    Module[ { t1, t2, cut },
        t1 = DateObject[ Take[ DateList @ $now, 3 ] + { 0, 0, 1 }, "Instant" ];
        t2 = t1 + Quantity[ 24, "Hours" ];
        cut = $now + Quantity[ 12, "Hours" ];

        Which[ TrueQ[ t2 < cut        ], DateInterval[ { } ],
               TrueQ[ t1 <= cut <= t2 ], DateInterval[ { cut, t2 } ],
               True                    , DateInterval[ { t1, t2 } ]
        ]
    ];

tomorrow // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*tomorrowMorning*)
tomorrowMorning // beginDefinition;

tomorrowMorning[ ] :=
    Module[ { t0, t1, t2, cut },
        t0 = DateObject[ Take[ DateList @ $now, 3 ] + { 0, 0, 1 }, "Instant" ];
        t1 = t0 + Quantity[ 4, "Hours" ];
        t2 = t1 + Quantity[ 12, "Hours" ];
        cut = $now + Quantity[ 8, "Hours" ];

        Which[ TrueQ[ t2 < cut        ], DateInterval[ { } ],
               TrueQ[ t1 <= cut <= t2 ], DateInterval[ { cut, t2 } ],
               True                    , DateInterval[ { t1, t2 } ]
        ]
    ];

tomorrowMorning // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*lastWeek*)
lastWeek // beginDefinition;

lastWeek[ ] :=
    Module[ { t1, t2, cut },
        t2 = DateObject[ DayRound[ $now, Sunday, "Previous" ], "Instant" ];
        t1 = t2 - Quantity[ 7, "Days" ];
        cut = $now - Quantity[ 4, "Days" ];
        Which[ TrueQ[ cut < t1        ], DateInterval[ { } ],
               TrueQ[ t1 <= cut <= t2 ], DateInterval[ { t1, cut } ],
               True                    , DateInterval[ { t1, t2 } ]
        ]
    ];

lastWeek // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*nextWeek*)
nextWeek // beginDefinition;

nextWeek[ ] :=
    Module[ { t1, t2, cut },
        t1 = DateObject[ DayRound[ $now, Sunday, "Next" ], "Instant" ];
        t2 = t1 + Quantity[ 7, "Days" ];
        cut = $now + Quantity[ 4, "Days" ];
        Which[ TrueQ[ t2 < cut        ], DateInterval[ { } ],
               TrueQ[ t1 <= cut <= t2 ], DateInterval[ { cut, t2 } ],
               True                    , DateInterval[ { t1, t2 } ]
        ]
    ];

nextWeek // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*freezeTime*)
freezeTime // beginDefinition;
freezeTime // Attributes = { HoldFirst };

freezeTime[ eval_ ] :=
    Block[ { freezeTime = #1 & },
        Internal`InheritedBlock[
            {
                $now = Now,
                $yesterday,
                $lastNight,
                $tomorrow,
                $tomorrowMorning,
                $lastWeek,
                $nextWeek
            },
            eval
        ]
    ];

freezeTime // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toDateObject*)
toDateObject // beginDefinition;

toDateObject[ date_DateObject? DateObjectQ ] := date;

toDateObject[ date_DateInterval ] :=
    If[ MatchQ[ DateBounds @ date, { _? DateObjectQ, _? DateObjectQ } ],
        date,
        throwFailure[ "InvalidDate", date ]
    ];

toDateObject[ date_ ] :=
    Module[ { dateObj },
        dateObj = Quiet @ DateObject @ date;
        If[ DateObjectQ @ dateObj,
            dateObj,
            throwFailure[ "InvalidDate", date ]
        ]
    ];

toDateObject // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*relativeTimeString*)
relativeTimeString // beginDefinition;

relativeTimeString[ diff_Quantity ] :=
    If[ ! TrueQ @ CompatibleUnitQ[ diff, "Seconds" ],
        throwFailure[ "InvalidUnit", diff ],
        relativeTimeString0 @ diff
    ];

relativeTimeString[ date1_? DateObjectQ, date2_? DateObjectQ ] :=
    relativeTimeString[ date2 - date1 ];

relativeTimeString // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*relativeTimeString0*)
relativeTimeString0 // beginDefinition;

relativeTimeString0[ Quantity[ Interval @ { a_, b_ }, unit_ ] ] :=
    Module[ { q1, q2, s1, s2 },
        q1 = Quantity[ a, unit ];
        q2 = Quantity[ b, unit ];
        s1 = relativeTimeString0 @ q1;
        s2 = relativeTimeString0 @ q2;
        combineIntervalStrings[ s1, s2 ]
    ];

relativeTimeString0[ diff_Quantity ] :=
    Module[ { date, abs, low, high, dwQ },
        date = $now + diff;
        abs  = Abs @ diff;
        low  = Quantity[ 8, "Hours" ];
        high = Quantity[ 14, "Days" ];
        dwQ  = TrueQ @ DateWithinQ[ ## ] &;
        Which[
            ! TrueQ[ low <= abs <= high ], relativeTimeString1 @ diff,
            dwQ[ $lastNight      , date ], "last night",
            dwQ[ $yesterday      , date ], "yesterday",
            dwQ[ $thisMorning    , date ], "this morning",
            dwQ[ $tomorrowMorning, date ], "tomorrow morning",
            dwQ[ $tomorrow       , date ], "tomorrow",
            dwQ[ $lastWeek       , date ], "last week",
            dwQ[ $nextWeek       , date ], "next week",
            True                         , relativeTimeString1 @ diff
        ]
    ];

relativeTimeString0 // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*relativeTimeString1*)
relativeTimeString1 // beginDefinition;

relativeTimeString1[ diff_Quantity ] :=
    Module[ { quant, nice },
        quant = secondsToQuantity[ Abs @ diff, "MixedUnits" -> False ];
        nice  = simplifyTime @ Round @ quant;
        diffString[ nice, TrueQ @ Positive @ diff ]
    ];

relativeTimeString1 // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*combineIntervalStrings*)
combineIntervalStrings // beginDefinition;

combineIntervalStrings[ s_, s_ ] := s;

combineIntervalStrings[ s1_String, s2_String ] :=
    combineIntervalStrings[ split @ s1, split @ s2 ];

combineIntervalStrings[
    { a___String, digits[ d1_String ], b___String, "ago" },
    { a___String, digits[ d2_String ], b___String, "ago" }
] :=  StringRiffle @ { a, d2, "to", d1, b, "ago" };

combineIntervalStrings[
    { a___String, digits[ d1_String ], b___String },
    { a___String, digits[ d2_String ], b___String }
] :=  StringRiffle @ { a, d1, "to", d2, b };

combineIntervalStrings[
    { digits[ d1_ ], u1_, "ago" },
    { digits[ d2_ ], u2_, "ago" }
] := StringRiffle @ { "between", d2, u2, "and", d1, u1, "ago" };

combineIntervalStrings[
    { "in", digits[ d1_ ], u1_ },
    { "in", digits[ d2_ ], u2_ }
] := StringRiffle @ { "between", d1, u1, "and", d2, u2, "from now" };

combineIntervalStrings[
    { digits[ d1_ ], u1_, "ago" },
    { "in", digits[ d2_ ], u2_ }
] := StringRiffle @ { "between", d1, u1, "ago and", d2, u2, "from now" };

combineIntervalStrings[
    { digits[ d1_ ], u1_, "ago" },
    { s__String, "ago" }
] := StringRiffle @ { "between", s, "and", d1, u1, "ago" };

combineIntervalStrings[ { "in", a__ }, { "in", b__ } ] :=
    StringRiffle[
        Flatten @ { a, "to", b, "from now" } /. digits[ d_ ] :> d
    ];

combineIntervalStrings[ a_List, { "in", b__ } ] :=
    StringRiffle[
        Flatten @ { a, "to", b, "from now" } /. digits[ d_ ] :> d
    ];

combineIntervalStrings[ a_List, b_List ] :=
    StringRiffle[ Flatten @ { a, "to", b } /. digits[ d_ ] :> d ];

combineIntervalStrings // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*split*)
split // beginDefinition;

split[ s_String ] :=
    DeleteCases[
        StringSplit[ s, { d: DigitCharacter.. :> digits @ d, " " } ],
        ""
    ];

split // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*simplifyTime*)
simplifyTime // beginDefinition;

simplifyTime[ Quantity[
    MixedMagnitude @ { a__, 0 },
    MixedUnit @ { b__, _ }
] ] := simplifyTime @ Quantity[ MixedMagnitude @ { a }, MixedUnit @ { b } ];

simplifyTime[ time_ ] := time;

simplifyTime // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*diffString*)
diffString // beginDefinition;

diffString[ Quantity[ 1, "Seconds" ], False ] := "a second ago";
diffString[ Quantity[ 1, "Seconds" ], True  ] := "in a second";

diffString[ Quantity[ 60, "Seconds" ], pos_  ] := diffString[
    Quantity[ 1, "Minutes" ],
    pos
];

diffString[ Quantity[ 1000, "Milliseconds" ], pos_  ] := diffString[
    Quantity[ 1, "Seconds" ],
    pos
];

diffString[ Quantity[ 1, "Minutes" ], False ] := "a minute ago";
diffString[ Quantity[ 1, "Minutes" ], True  ] := "in a minute";

diffString[ Quantity[ 60, "Minutes" ], pos_  ] := diffString[
    Quantity[ 1, "Hours" ],
    pos
];

diffString[ Quantity[ 1, "Hours" ], False ] := "an hour ago";
diffString[ Quantity[ 1, "Hours" ], True  ] := "in an hour";

diffString[ Quantity[ 24, "Hours" ], pos_  ] := diffString[
    Quantity[ 1, "Days" ],
    pos
];

diffString[ Quantity[ 1, "Days" ], False ] := "a day ago";
diffString[ Quantity[ 1, "Days" ], True  ] := "in a day";

diffString[ Quantity[ 7, "Days" ], pos_  ] := diffString[
    Quantity[ 1, "Weeks" ],
    pos
];

diffString[ Quantity[ 1, "Weeks" ], False ] := "a week ago";
diffString[ Quantity[ 1, "Weeks" ], True  ] := "in a week";

diffString[ Quantity[ 1, "Months" ], False ] := "a month ago";
diffString[ Quantity[ 1, "Months" ], True  ] := "in a month";

diffString[ Quantity[ 12, "Months" ], pos_  ] := diffString[
    Quantity[ 1, "Years" ],
    pos
];

diffString[ Quantity[ 1, "Years" ], False ] := "a year ago";
diffString[ Quantity[ 1, "Years" ], True  ] := "in a year";

diffString[ Quantity[ _, $$tinyUnit ], False ] := "just now";
diffString[ Quantity[ _, $$tinyUnit ], True  ] := "now";
diffString[ Quantity[ t_ /; t == 0, _ ],   _ ] := "now";

diffString[ diff_Quantity, pos_ ] :=
    Module[ { pre, post },
        pre  = If[ TrueQ @ pos, "in ", "" ];
        post = If[ TrueQ @ pos, "", " ago" ];
        StringJoin[
            pre,
            ToString[ diff /. r_Rational :> RuleCondition @ Round @ r ],
            post
        ]
    ];

diffString // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*secondsToQuantity*)
secondsToQuantity := secondsToQuantity =
    Block[ { PrintTemporary },
        ResourceFunction[ "SecondsToQuantity", "Function" ]
    ];

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
        Catch[ freezeTime @ eval, $top ]
    ];

catchTop // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwFailure*)
throwFailure // beginDefinition;
throwFailure // Attributes = { HoldFirst };

throwFailure[ tag_String, params___ ] :=
    throwFailure[ MessageName[ RelativeTimeString, tag ], params ];

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
    throwFailure[ RelativeTimeString::Internal,
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
        "Fragment" -> "RelativeTimeString"
    |>
];