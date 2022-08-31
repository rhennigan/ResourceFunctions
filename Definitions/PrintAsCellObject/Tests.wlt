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
VerificationTest[
    cell = PrintAsCellObject[ a + b ];
    First @ NotebookRead @ cell,
    BoxData @ RowBox @ { "a", "+", "b" }
]

VerificationTest[
    ResourceFunction[ "CellInformation" ][ cell ],
    KeyValuePattern[ "Style" -> "Print" ],
    SameTest -> MatchQ
]

VerificationTest[
    NotebookDelete @ cell,
    Null,
    SameTest -> MatchQ
]

VerificationTest[
    ResourceFunction[ "CellInformation" ][ cell ],
    $Failed
]

VerificationTest[
    Block[ { CellPrint }, RemoteEvaluate[ PrintAsCellObject[ "test" ] ] ],
    Missing[ "FrontEndNotAvailable" ]
]

VerificationTest[
    RemoteEvaluate[ UsingFrontEnd @ PrintAsCellObject[ "test" ] ],
    _CellObject,
    SameTest -> MatchQ
]

VerificationTest[
    cell = PrintAsCellObject[ a + b ];
    First @ NotebookRead @ cell,
    BoxData @ RowBox @ { "a", "+", "b" }
]

VerificationTest[
    NotebookDelete @ cell,
    Null
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
