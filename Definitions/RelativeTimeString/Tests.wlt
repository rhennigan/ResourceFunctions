(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization"
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
    TestID -> "BasicExamples-1"
]

VerificationTest[
    RelativeTimeString @ Tomorrow,
    "tomorrow",
    TestID -> "BasicExamples-2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 42, "Seconds" ],
    "in 42 seconds",
    TestID -> "BasicExamples-3"
]

VerificationTest[
    RelativeTimeString[ -Quantity[ 42, "Seconds" ] ],
    "42 seconds ago",
    TestID -> "BasicExamples-4"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 31536000, "Seconds" ],
    "in a year",
    TestID -> "BasicExamples-5"
]

VerificationTest[
    RelativeTimeString[ -Quantity[ 10, "Nanoseconds" ] ],
    "just now",
    TestID -> "BasicExamples-6"
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
    TestID -> "Scope-1"
]

VerificationTest[
    RelativeTimeString[ Now, Now - Quantity[ 1, "Weeks" ] ],
    "last week",
    TestID -> "Scope-2"
]

VerificationTest[
    RelativeTimeString @ Round[ AbsoluteTime[ ] - 162861 ],
    "2 days ago",
    TestID -> "Scope-3"
]

VerificationTest[
    StringQ @ RelativeTimeString[ "2022 12-15" ],
    True,
    TestID -> "Scope-4"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Possible Issues*)
VerificationTest[
    RelativeTimeString @ Quantity[ 0.999, "Seconds" ],
    "now",
    TestID -> "PossibleIssues-1"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 0.0, "Seconds" ],
    "now",
    TestID -> "PossibleIssues-2"
]

VerificationTest[
    RelativeTimeString @ Quantity[ 1.0, "Seconds" ],
    "in a second",
    TestID -> "PossibleIssues-3"
]

VerificationTest[
    RelativeTimeString[ -Quantity[ 0.999, "Seconds" ] ],
    "just now",
    TestID -> "PossibleIssues-4"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)
VerificationTest[
    RelativeTimeString @ Quantity[ 3, "Miles" ],
    Failure[ "RelativeTimeString::InvalidUnit", _ ],
    { RelativeTimeString::InvalidUnit },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-InvalidUnit-1"
]

VerificationTest[
    RelativeTimeString[ "hello" ],
    Failure[ "RelativeTimeString::InvalidDate", _ ],
    { RelativeTimeString::InvalidDate },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-InvalidDate-1"
]

VerificationTest[
    RelativeTimeString[ ],
    Failure[ "RelativeTimeString::WrongNumberOfArguments", _ ],
    { RelativeTimeString::WrongNumberOfArguments },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-WrongNumberOfArguments-1"
]

VerificationTest[
    RelativeTimeString[ Now, Now, Now ],
    Failure[ "RelativeTimeString::WrongNumberOfArguments", _ ],
    { RelativeTimeString::WrongNumberOfArguments },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-WrongNumberOfArguments-2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID   -> "Cleanup"
]
