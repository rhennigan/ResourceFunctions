(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization@@Definitions/BirdChat/Tests.wlt:4,1-9,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Options*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Applications*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Properties and Relations*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Possible Issues*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Neat Examples*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)


(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID   -> "Cleanup@@Definitions/BirdChat/Tests.wlt:58,1-63,2"
]
