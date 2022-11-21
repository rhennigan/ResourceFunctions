(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization@@Definitions/FITImport/Tests.wlt:4,1-9,2"
]

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)
VerificationTest[
    1 + 2,
    3,
    TestID -> "JustTesting@@Definitions/FITImport/Tests.wlt:18,1-22,2"
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
    TestID   -> "Cleanup@@Definitions/FITImport/Tests.wlt:62,1-67,2"
]
