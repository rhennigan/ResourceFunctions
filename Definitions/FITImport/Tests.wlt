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
    1 + 1,
    2,
    TestID -> "JustTesting"
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Options*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Applications*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Properties and Relations*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Possible Issues*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Neat Examples*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID   -> "Cleanup"
]
