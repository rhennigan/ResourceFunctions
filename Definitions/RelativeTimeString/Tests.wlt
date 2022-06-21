(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization@@Definitions/RelativeTimeString/Tests.wlt:4,1-9,2"
]

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)
VerificationTest[
    RelativeTimeString[ Now + Quantity[ 1, "Hours" ] ],
    "in an hour",
    TestID -> "BasicExamples-1@@Definitions/RelativeTimeString/Tests.wlt:18,1-22,2"
]

VerificationTest[
    RelativeTimeString @ Tomorrow,
    "tomorrow",
    TestID -> "BasicExamples-2@@Definitions/RelativeTimeString/Tests.wlt:24,1-28,2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 42, "Seconds" ],
    "in 42 seconds",
    TestID -> "BasicExamples-3@@Definitions/RelativeTimeString/Tests.wlt:30,1-34,2"
]

VerificationTest[
    RelativeTimeString[ -Quantity[ 42, "Seconds" ] ],
    "42 seconds ago",
    TestID -> "BasicExamples-4@@Definitions/RelativeTimeString/Tests.wlt:36,1-40,2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 31536000, "Seconds" ],
    "in a year",
    TestID -> "BasicExamples-5@@Definitions/RelativeTimeString/Tests.wlt:42,1-46,2"
]

VerificationTest[
    RelativeTimeString[ -Quantity[ 10, "Nanoseconds" ] ],
    "just now",
    TestID -> "BasicExamples-6@@Definitions/RelativeTimeString/Tests.wlt:48,1-52,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)
VerificationTest[
    RelativeTimeString[
        DateObject[
            { 2022, 6, 20, 13, 42, 2.1677 },
            "Instant",
            "Gregorian",
            -4.0
        ],
        DateObject[
            { 2022, 6, 27, 16, 6, 2.1677 },
            "Instant",
            "Gregorian",
            -4.0
        ]
    ],
    "next week",
    TestID -> "Scope-1@@Definitions/RelativeTimeString/Tests.wlt:57,1-74,2"
]

VerificationTest[
    RelativeTimeString[ Now, Now - Quantity[ 1, "Weeks" ] ],
    "last week",
    TestID -> "Scope-2@@Definitions/RelativeTimeString/Tests.wlt:76,1-80,2"
]

VerificationTest[
    RelativeTimeString @ Round[ AbsoluteTime[ ] - 162861 ],
    "2 days ago",
    TestID -> "Scope-3@@Definitions/RelativeTimeString/Tests.wlt:82,1-86,2"
]

VerificationTest[
    StringQ @ RelativeTimeString[ "2022 12-15" ],
    True,
    TestID -> "Scope-4@@Definitions/RelativeTimeString/Tests.wlt:88,1-92,2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 7, "DogYears" ],
    "in a year",
    TestID -> "Scope-5@@Definitions/RelativeTimeString/Tests.wlt:94,1-98,2"
]

VerificationTest[
    RelativeTimeString[ -Quantity[ "AcademicQuarters" ] ],
    "2 to 3 months ago",
    TestID -> "Scope-6@@Definitions/RelativeTimeString/Tests.wlt:100,1-104,2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ "Fortnights" ],
    "in 14 days",
    TestID -> "Scope-7@@Definitions/RelativeTimeString/Tests.wlt:106,1-110,2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ Interval @ { 3, 5 }, "Seconds" ],
    "in 3 to 5 seconds",
    TestID -> "Scope-8@@Definitions/RelativeTimeString/Tests.wlt:112,1-116,2"
]

VerificationTest[
    RelativeTimeString[ -Quantity[ Interval @ { 3, 5 }, "Seconds" ] ],
    "3 to 5 seconds ago",
    TestID -> "Scope-9@@Definitions/RelativeTimeString/Tests.wlt:118,1-122,2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ Interval @ { -3, 500 }, "Seconds" ],
    "between 3 seconds ago and 8 minutes from now",
    TestID -> "Scope-10@@Definitions/RelativeTimeString/Tests.wlt:124,1-128,2"
]

VerificationTest[
    RelativeTimeString @ DateInterval @ {
        Now + Quantity[ 3, "Seconds" ],
        Now + Quantity[ 500, "Seconds" ]
    },
    "between 3 seconds and 8 minutes from now",
    TestID -> "Scope-11@@Definitions/RelativeTimeString/Tests.wlt:130,1-137,2"
]

VerificationTest[
    RelativeTimeString[
        DateObject[
            { 2022, 6, 20, 20, 48, 35.699 },
            "Instant",
            "Gregorian",
            -4.0
        ],
        DateInterval[
            {
                {
                    { 2022, 6, 20, 20, 48, 35.699 },
                    { 2022, 6, 20, 20, 56, 52.699 }
                }
            },
            "Instant",
            "Gregorian",
            -4.0
        ]
    ],
    "just now to 8 minutes from now",
    TestID -> "Scope-12@@Definitions/RelativeTimeString/Tests.wlt:139,1-161,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Possible Issues*)
VerificationTest[
    RelativeTimeString @ Quantity[ 0.999, "Seconds" ],
    "now",
    TestID -> "PossibleIssues-1@@Definitions/RelativeTimeString/Tests.wlt:166,1-170,2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 0.0, "Seconds" ],
    "now",
    TestID -> "PossibleIssues-2@@Definitions/RelativeTimeString/Tests.wlt:172,1-176,2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 1.0, "Seconds" ],
    "in a second",
    TestID -> "PossibleIssues-3@@Definitions/RelativeTimeString/Tests.wlt:178,1-182,2"
]

VerificationTest[
    RelativeTimeString[ -Quantity[ 0.999, "Seconds" ] ],
    "just now",
    TestID -> "PossibleIssues-4@@Definitions/RelativeTimeString/Tests.wlt:184,1-188,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)
VerificationTest[
    RelativeTimeString @ Quantity[ 3, "Miles" ],
    Failure[ "RelativeTimeString::InvalidUnit", _ ],
    { RelativeTimeString::InvalidUnit },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-InvalidUnit-1@@Definitions/RelativeTimeString/Tests.wlt:193,1-199,2"
]

VerificationTest[
    RelativeTimeString[ "hello" ],
    Failure[ "RelativeTimeString::InvalidDate", _ ],
    { RelativeTimeString::InvalidDate },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-InvalidDate-1@@Definitions/RelativeTimeString/Tests.wlt:201,1-207,2"
]

VerificationTest[
    RelativeTimeString[ ],
    Failure[ "RelativeTimeString::WrongNumberOfArguments", _ ],
    { RelativeTimeString::WrongNumberOfArguments },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-WrongNumberOfArguments-1@@Definitions/RelativeTimeString/Tests.wlt:209,1-215,2"
]

VerificationTest[
    RelativeTimeString[ Now, Now, Now ],
    Failure[ "RelativeTimeString::WrongNumberOfArguments", _ ],
    { RelativeTimeString::WrongNumberOfArguments },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-WrongNumberOfArguments-2@@Definitions/RelativeTimeString/Tests.wlt:217,1-223,2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID   -> "Cleanup@@Definitions/RelativeTimeString/Tests.wlt:228,1-233,2"
]
