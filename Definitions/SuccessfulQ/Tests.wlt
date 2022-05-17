(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Tests*)

VerificationTest[
    SuccessfulQ @ x,
    True,
    TestID -> "SuccessfulQ-Symbol"
]

VerificationTest[
    SuccessfulQ[ 1 + 1 ],
    True,
    TestID -> "SuccessfulQ-Number"
]

VerificationTest[
    SuccessfulQ @ $Failed,
    False,
    TestID -> "SuccessfulQ-$Failed"
]

VerificationTest[
    SuccessfulQ @ Interpreter[ "Integer" ][ "invalid" ],
    False,
    TestID -> "SuccessfulQ-Failure"
]

VerificationTest[
    SuccessfulQ @ Lookup[ <| |>, "x" ],
    False,
    TestID -> "SuccessfulQ-Missing"
]

VerificationTest[
    SuccessfulQ @ $Canceled,
    False,
    TestID -> "SuccessfulQ-$Canceled"
]

VerificationTest[
    SuccessfulQ @ $Aborted,
    False,
    TestID -> "SuccessfulQ-$Aborted"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)
VerificationTest[
    SuccessfulQ[ a, b ],
    Failure[ "SuccessfulQ::OneArgumentExpected", _ ],
    { SuccessfulQ::OneArgumentExpected },
    SameTest -> MatchQ,
    TestID   -> "SuccessfulQ-OneArgumentExpected"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ
]
