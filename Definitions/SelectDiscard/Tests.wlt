(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization@@Definitions/SelectDiscard/Tests.wlt:4,1-9,2"
]

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)
VerificationTest[
    SelectDiscard[ { 1, 2, 4, 7, 6, 2 }, EvenQ ],
    { { 2, 4, 6, 2 }, { 1, 7 } },
    TestID -> "BasicExamples-1@@Definitions/SelectDiscard/Tests.wlt:18,1-22,2"
]

VerificationTest[
    SelectDiscard[ { 1, 2, 4, 7, 6, 2 }, #1 > 2 & ],
    { { 4, 7, 6 }, { 1, 2, 2 } },
    TestID -> "BasicExamples-2@@Definitions/SelectDiscard/Tests.wlt:24,1-28,2"
]

VerificationTest[
    SelectDiscard[ { 1, 2, 4, 7, 6, 2 }, #1 > 2 &, 1 ],
    { { 4 }, { 7, 6, 1, 2, 2 } },
    TestID -> "BasicExamples-3@@Definitions/SelectDiscard/Tests.wlt:30,1-34,2"
]

VerificationTest[
    SelectDiscard[ EvenQ ][ { 1, 2, 4, 7, 6, 2 } ],
    { { 2, 4, 6, 2 }, { 1, 7 } },
    TestID -> "BasicExamples-4@@Definitions/SelectDiscard/Tests.wlt:36,1-40,2"
]

VerificationTest[
    SelectDiscard[ <| a -> 1, b -> 2, c -> 3, d -> 4 |>, #1 > 2 & ],
    { <| c -> 3, d -> 4 |>, <| a -> 1, b -> 2 |> },
    TestID -> "BasicExamples-5@@Definitions/SelectDiscard/Tests.wlt:42,1-46,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)
VerificationTest[
    SelectDiscard[ { 1, 2, 4, 7, x }, #1 > 2 & ],
    { { 4, 7 }, { 1, 2, x } },
    TestID -> "Scope-1@@Definitions/SelectDiscard/Tests.wlt:51,1-55,2"
]

VerificationTest[
    SelectDiscard[
        { { 1, y }, { 2, x }, { 3, x }, { 4, z }, { 5, x } },
        MemberQ[ #1, x ] &
    ],
    { { { 2, x }, { 3, x }, { 5, x } }, { { 1, y }, { 4, z } } },
    TestID -> "Scope-2@@Definitions/SelectDiscard/Tests.wlt:57,1-64,2"
]

VerificationTest[
    SelectDiscard[
        { { 1, y }, { 2, x }, { 3, x }, { 4, z }, { 5, x } },
        MemberQ[ #1, x ] &,
        2
    ],
    { { { 2, x }, { 3, x } }, { { 5, x }, { 1, y }, { 4, z } } },
    TestID -> "Scope-3@@Definitions/SelectDiscard/Tests.wlt:66,1-74,2"
]

VerificationTest[
    SelectDiscard[
        { { 1, y }, { 2, x }, { 3, x }, { 4, z }, { 5, x } },
        MemberQ[ #1, z ] &,
        2
    ],
    { { { 4, z } }, { { 1, y }, { 2, x }, { 3, x }, { 5, x } } },
    TestID -> "Scope-4@@Definitions/SelectDiscard/Tests.wlt:76,1-84,2"
]

VerificationTest[
    SelectDiscard[ Range[ 10 ], GreaterThan[ 3 ] ],
    { { 4, 5, 6, 7, 8, 9, 10 }, { 1, 2, 3 } },
    TestID -> "Scope-5@@Definitions/SelectDiscard/Tests.wlt:86,1-90,2"
]

VerificationTest[
    SelectDiscard[ GreaterThan[ 3 ] ][ Range[ 10 ] ],
    { { 4, 5, 6, 7, 8, 9, 10 }, { 1, 2, 3 } },
    TestID -> "Scope-6@@Definitions/SelectDiscard/Tests.wlt:92,1-96,2"
]

VerificationTest[
    SelectDiscard[ Unevaluated[ 1 + 2 + 3 + 4 + 5 ], OddQ ],
    { 9, 6 },
    TestID -> "Scope-7@@Definitions/SelectDiscard/Tests.wlt:98,1-102,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Generalizations & Extensions*)
VerificationTest[
    SelectDiscard[ h[ 1, a, 2, b, 3 ], IntegerQ ],
    { h[ 1, 2, 3 ], h[ a, b ] },
    TestID -> "GeneralizationsAndExtensions-1@@Definitions/SelectDiscard/Tests.wlt:107,1-111,2"
]

VerificationTest[
    s = SparseArray @ Table[ 2^i -> i, { i, 0, 5 } ],
    _SparseArray? SparseArrayQ,
    SameTest -> MatchQ,
    TestID -> "GeneralizationsAndExtensions-2@@Definitions/SelectDiscard/Tests.wlt:113,1-118,2"
]

VerificationTest[
    SelectDiscard[ s, EvenQ ],
    {
        SparseArray[ Automatic, { 29 }, 0, { 1, { { 0, 2 }, { { 3 }, { 14 } } }, { 2, 4 } } ],
        { 1, 3, 5 }
    },
    TestID -> "GeneralizationsAndExtensions-3@@Definitions/SelectDiscard/Tests.wlt:120,1-127,2"
]

VerificationTest[
    SelectDiscard[ s, OddQ ],
    {
        { 1, 3, 5 },
        SparseArray[ Automatic, { 29 }, 0, { 1, { { 0, 2 }, { { 3 }, { 14 } } }, { 2, 4 } } ]
    },
    TestID -> "GeneralizationsAndExtensions-4@@Definitions/SelectDiscard/Tests.wlt:129,1-136,2"
]

VerificationTest[
    { g1, g2 } = SelectDiscard[ CompleteGraph[ 7 ], OddQ ],
    { _Graph? GraphQ, _Graph? GraphQ },
    SameTest -> MatchQ,
    TestID   -> "GeneralizationsAndExtensions-5@@Definitions/SelectDiscard/Tests.wlt:138,1-143,2"
]

VerificationTest[
    IsomorphicGraphQ[
        g1,
        Graph @ { 1 <-> 3, 1 <-> 5, 1 <-> 7, 3 <-> 5, 3 <-> 7, 5 <-> 7 }
    ],
    True,
    TestID -> "GeneralizationsAndExtensions-6@@Definitions/SelectDiscard/Tests.wlt:145,1-152,2"
]

VerificationTest[
    IsomorphicGraphQ[
        g2,
        Graph @ { 2 <-> 4, 2 <-> 6, 4 <-> 6 }
    ],
    True,
    TestID -> "GeneralizationsAndExtensions-7@@Definitions/SelectDiscard/Tests.wlt:154,1-161,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Applications*)
VerificationTest[
    SelectDiscard[ 7 * Pi^2 * x^2 * y^2, NumericQ ],
    { 7 * Pi^2, x^2 * y^2 },
    TestID -> "Applications-1@@Definitions/SelectDiscard/Tests.wlt:166,1-170,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Properties and Relations*)
VerificationTest[
    list = Range[ 10 ],
    { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
    TestID -> "PropertiesAndRelations-1@@Definitions/SelectDiscard/Tests.wlt:175,1-179,2"
]

VerificationTest[
    SelectDiscard[ list, LessEqualThan[ 4 ] ],
    TakeDrop[ list, 4 ],
    TestID -> "PropertiesAndRelations-2@@Definitions/SelectDiscard/Tests.wlt:181,1-185,2"
]

VerificationTest[
    SelectDiscard[ Range[ 10 ], OddQ ],
    { { 1, 3, 5, 7, 9 }, { 2, 4, 6, 8, 10 } },
    TestID -> "PropertiesAndRelations-3@@Definitions/SelectDiscard/Tests.wlt:187,1-191,2"
]

VerificationTest[
    GatherBy[ Range[ 10 ], OddQ ],
    { { 1, 3, 5, 7, 9 }, { 2, 4, 6, 8, 10 } },
    TestID -> "PropertiesAndRelations-4@@Definitions/SelectDiscard/Tests.wlt:193,1-197,2"
]

VerificationTest[
    SelectDiscard[ Range[ 10 ], EvenQ ],
    { { 2, 4, 6, 8, 10 }, { 1, 3, 5, 7, 9 } },
    TestID -> "PropertiesAndRelations-5@@Definitions/SelectDiscard/Tests.wlt:199,1-203,2"
]

VerificationTest[
    GatherBy[ Range[ 10 ], EvenQ ],
    { { 1, 3, 5, 7, 9 }, { 2, 4, 6, 8, 10 } },
    TestID -> "PropertiesAndRelations-6@@Definitions/SelectDiscard/Tests.wlt:205,1-209,2"
]

VerificationTest[
    Lookup[ GroupBy[ Range[ 10 ], PrimeQ ], { True, False }, { } ],
    { { 2, 3, 5, 7 }, { 1, 4, 6, 8, 9, 10 } },
    TestID -> "PropertiesAndRelations-7@@Definitions/SelectDiscard/Tests.wlt:211,1-215,2"
]

VerificationTest[
    SelectDiscard[ g[ 1, 2, 4, 7, 8 ], #1 > 2 & ],
    { g[ 4, 7, 8 ], g[ 1, 2 ] },
    TestID -> "PropertiesAndRelations-8@@Definitions/SelectDiscard/Tests.wlt:217,1-221,2"
]

VerificationTest[
    GroupBy[ g[ 1, 2, 4, 7, 8 ], #1 > 2 & ],
    HoldPattern @ GroupBy[ g[ 1, 2, 4, 7, 8 ], #1 > 2 & ],
    { GroupBy::list1 },
    SameTest -> MatchQ,
    TestID -> "PropertiesAndRelations-9@@Definitions/SelectDiscard/Tests.wlt:223,1-229,2"
]

VerificationTest[
    SelectDiscard[ { 1, 2, 4, 7, x, y }, #1 > 2 & ],
    { { 4, 7 }, { 1, 2, x, y } },
    TestID -> "PropertiesAndRelations-10@@Definitions/SelectDiscard/Tests.wlt:231,1-235,2"
]

VerificationTest[
    SelectDiscard[ Range[ 5 ], IntegerQ ],
    { { 1, 2, 3, 4, 5 }, { } },
    TestID -> "PropertiesAndRelations-11@@Definitions/SelectDiscard/Tests.wlt:237,1-241,2"
]

VerificationTest[
    GatherBy[ { 1, 2, 4, 7, x, y }, #1 > 2 & ],
    { { 1, 2 }, { 4, 7 }, { x }, { y } },
    TestID -> "PropertiesAndRelations-12@@Definitions/SelectDiscard/Tests.wlt:243,1-247,2"
]

VerificationTest[
    GroupBy[ { 1, 2, 4, 7, x, y }, #1 > 2 & ],
    <|
        False -> { 1, 2 },
        True  -> { 4, 7 },
        x > 2 -> { x },
        y > 2 -> { y }
    |>,
    TestID -> "PropertiesAndRelations-13@@Definitions/SelectDiscard/Tests.wlt:249,1-258,2"
]

VerificationTest[
    GroupBy[ Range[ 5 ], IntegerQ ],
    <| True -> { 1, 2, 3, 4, 5 } |>,
    TestID -> "PropertiesAndRelations-14@@Definitions/SelectDiscard/Tests.wlt:260,1-264,2"
]

VerificationTest[
    GatherBy[ Range[ 5 ], IntegerQ ],
    { { 1, 2, 3, 4, 5 } },
    TestID -> "PropertiesAndRelations-15@@Definitions/SelectDiscard/Tests.wlt:266,1-270,2"
]

VerificationTest[
    list = { 1, 2, 2, 3, 3, 4 },
    { 1, 2, 2, 3, 3, 4 },
    TestID -> "PropertiesAndRelations-16@@Definitions/SelectDiscard/Tests.wlt:272,1-276,2"
]

VerificationTest[
    SelectDiscard[ list, EvenQ ],
    { { 2, 2, 4 }, { 1, 3, 3 } },
    TestID -> "PropertiesAndRelations-17@@Definitions/SelectDiscard/Tests.wlt:278,1-282,2"
]

VerificationTest[
    With[ { sel = Select[ list, EvenQ ] },
        { sel, DeleteElements[ list, sel ] }
    ],
    { { 2, 2, 4 }, { 1, 3, 3 } },
    TestID -> "PropertiesAndRelations-18@@Definitions/SelectDiscard/Tests.wlt:284,1-290,2"
]

VerificationTest[
    list = { -2, 0, 1, 3, 3, x, y },
    { -2, 0, 1, 3, 3, x, y },
    TestID -> "PropertiesAndRelations-19@@Definitions/SelectDiscard/Tests.wlt:292,1-296,2"
]

VerificationTest[
    First @ SelectDiscard[ list, Positive ],
    Select[ list, Positive ],
    TestID -> "PropertiesAndRelations-20@@Definitions/SelectDiscard/Tests.wlt:298,1-302,2"
]

VerificationTest[
    Last @ SelectDiscard[ list, Positive ],
    Select[ list, Composition[ Not, TrueQ, Positive ] ],
    TestID -> "PropertiesAndRelations-21@@Definitions/SelectDiscard/Tests.wlt:304,1-308,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Possible Issues*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Neat Examples*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)

(* Argument count: *)
VerificationTest[
    SelectDiscard[ ],
    Failure[ "SelectDiscard::ArgumentCount", _ ],
    { SelectDiscard::ArgumentCount },
    SameTest -> MatchQ,
    TestID -> "ErrorCases-1@@Definitions/SelectDiscard/Tests.wlt:323,1-329,2"
]

VerificationTest[
    SelectDiscard[ { 1, 2, 3 }, OddQ, 1, 1 ],
    Failure[ "SelectDiscard::ArgumentCount", _ ],
    { SelectDiscard::ArgumentCount },
    SameTest -> MatchQ,
    TestID -> "ErrorCases-2@@Definitions/SelectDiscard/Tests.wlt:331,1-337,2"
]

(* Non-normal expression: *)
VerificationTest[
    SelectDiscard[ 1, crit ],
    Failure[ "SelectDiscard::Normal", _ ],
    { SelectDiscard::Normal },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-3@@Definitions/SelectDiscard/Tests.wlt:340,1-346,2"
]

(* Bad count spec: *)
VerificationTest[
    SelectDiscard[ { 1, 2, 3 }, OddQ, "x" ],
    Failure[ "SelectDiscard::Count", _ ],
    { SelectDiscard::Count },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-4@@Definitions/SelectDiscard/Tests.wlt:349,1-355,2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID -> "Cleanup@@Definitions/SelectDiscard/Tests.wlt:360,1-365,2"
]
