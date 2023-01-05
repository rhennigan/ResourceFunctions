
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization@@Definitions/KeyCases/Tests.wlt:8,1-13,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)
VerificationTest[
    KeyCases[ <| "a" -> 1, "b" -> 2, "c" -> 3 |>, "a" | "b" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-1@@Definitions/KeyCases/Tests.wlt:22,1-27,2"
]

VerificationTest[
    KeyCases[ <| "a" -> 1, "b" -> 2, "c" -> 3 |>, "a" | "b" | "d" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-2@@Definitions/KeyCases/Tests.wlt:29,1-34,2"
]

VerificationTest[
    KeyCases[ <| "a" -> 1, b -> 2, "c" -> 3 |>, _String ],
    <| "a" -> 1, "c" -> 3 |>,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-3@@Definitions/KeyCases/Tests.wlt:36,1-41,2"
]

VerificationTest[
    KeyCases[ <| 1 -> 1, 2 :> 2^2, 3 :> 3^2 |>, n_ /; n < 3 ],
    <| 1 -> 1, 2 :> 2^2 |>,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-4@@Definitions/KeyCases/Tests.wlt:43,1-48,2"
]

VerificationTest[
    KeyCases[ "a" | "b" ][ <| "a" -> 1, "b" -> 2, "c" -> 3 |> ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-5@@Definitions/KeyCases/Tests.wlt:50,1-55,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)
VerificationTest[
    KeyCases[ { "a" -> 1, "b" -> 2, "c" -> 3 }, "a" | "b" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> MatchQ,
    TestID   -> "Scope-1@@Definitions/KeyCases/Tests.wlt:60,1-65,2"
]

VerificationTest[
    KeyCases[ MyData[ a -> 1, b -> 2, c -> 3 ], a | b ],
    <| a -> 1, b -> 2 |>,
    SameTest -> MatchQ,
    TestID   -> "Scope-2@@Definitions/KeyCases/Tests.wlt:67,1-72,2"
]

VerificationTest[
    KeyCases[ Unevaluated @ { Echo[ "a" ] -> 1 + 1, Echo[ "b" ] -> 2 + 2, Echo[ "c" ] -> 3 + 3 }, HoldPattern @ Echo[ "a"|"b" ] ],
    HoldPattern @ KeyValuePattern @ { Echo[ "a" ] -> 1 + 1, Echo[ "b" ] -> 2 + 2 },
    SameTest -> MatchQ,
    TestID   -> "Scope-3@@Definitions/KeyCases/Tests.wlt:74,1-79,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Options*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Applications*)


(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Properties and Relations*)
VerificationTest[
    KeyCases[ Block[ { Echo }, <| Echo[ "key" ] -> Echo[ "value" ] |> ], _Echo ],
    HoldPattern @ KeyValuePattern @ { Echo[ "key" ] -> Echo[ "value" ] },
    SameTest -> MatchQ,
    TestID   -> "PropertiesAndRelations-1@@Definitions/KeyCases/Tests.wlt:94,1-99,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Possible Issues*)

(* :!CodeAnalysis::Disable::DuplicateKeys::ListOfRules:: *)
VerificationTest[
    KeyCases[ { "a" -> 1, "b" -> 2, "c" -> 3, "b" -> 4 }, "a"|"b" ],
    <| "a" -> 1, "b" -> 4 |>,
    SameTest -> MatchQ,
    TestID   -> "PossibleIssues-1@@Definitions/KeyCases/Tests.wlt:106,1-111,2"
]

VerificationTest[
    KeyCases[ MyData[ x, a -> 1, b -> 2, c -> 3 ], a|b ],
    Failure[ "KeyCases::InvalidKeyValuePairs", _ ],
    { KeyCases::InvalidKeyValuePairs },
    SameTest -> MatchQ,
    TestID   -> "PossibleIssues-2@@Definitions/KeyCases/Tests.wlt:113,1-119,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Neat Examples*)
VerificationTest[
    KeyCases[ Unevaluated @ <| 1 + 1 -> Echo[ 2 ], 2 + 2 -> Echo[ 4 ] |>, _ ],
    ResourceFunction[ "UnevaluatedAssociation" ][ 1 + 1 -> Echo[ 2 ], 2 + 2 -> Echo[ 4 ] ],
    SameTest -> MatchQ,
    TestID   -> "NeatExamples-1@@Definitions/KeyCases/Tests.wlt:124,1-129,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)
VerificationTest[
    KeyCases[ ],
    Failure[ "KeyCases::WrongNumberOfArguments", _ ],
    { KeyCases::WrongNumberOfArguments },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-1@@Definitions/KeyCases/Tests.wlt:134,1-140,2"
]

VerificationTest[
    KeyCases[ { "a" -> 1, "b" -> 2, "c" -> 3 }, "a"|"b", "c" ],
    Failure[ "KeyCases::WrongNumberOfArguments", _ ],
    { KeyCases::WrongNumberOfArguments },
    SameTest -> MatchQ,
    TestID   -> "ErrorCases-2@@Definitions/KeyCases/Tests.wlt:142,1-148,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID   -> "Cleanup@@Definitions/KeyCases/Tests.wlt:153,1-158,2"
]

(* :!CodeAnalysis::EndBlock:: *)
