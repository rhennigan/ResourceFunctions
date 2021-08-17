(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialize definitions*)

VerificationTest[
    ClearAll[ MyFunction, messageQuietTest ];
    MyFunction::test = "Test message, please ignore";
    messageQuietTest // Attributes = { HoldAll };
    messageQuietTest[ args___ ] := (Message[ args ]; MessageQuietedQ @ args)
    ,
    Null
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Quiet*)

VerificationTest[
    Quiet @ messageQuietTest @ MyFunction::test,
    True
]

VerificationTest[
    Quiet[ messageQuietTest @ MyFunction::test, { MyFunction::test } ],
    True
]

VerificationTest[
    Quiet[ messageQuietTest @ MyFunction::argx, { General::argx } ],
    True
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Not Quiet*)

VerificationTest[
    messageQuietTest @ MyFunction::test,
    False,
    { MyFunction::test }
]

VerificationTest[
    Quiet[ messageQuietTest @ MyFunction::test, { MyFunction::argx } ],
    False,
    { MyFunction::test }
]

VerificationTest[
    Quiet[ messageQuietTest @ MyFunction::test, { General::test } ],
    False,
    { MyFunction::test }
]

VerificationTest[
    Quiet[ messageQuietTest @ MyFunction::test, { General::test } ],
    False,
    { MyFunction::test }
]