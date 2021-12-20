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

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)

VerificationTest[
    AssociationOuter[ f, { a, b }, { x, y, z } ],
    <|
        a -> <| x -> f[ a, x ], y -> f[ a, y ], z -> f[ a, z ] |>,
        b -> <| x -> f[ b, x ], y -> f[ b, y ], z -> f[ b, z ] |>
    |>
]


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)

VerificationTest[
    AssociationOuter[f, {a, b}, {x, y, z}, {u, v}],
    <|
        a -> <|
            x -> <| u -> f[ a, x, u ], v -> f[ a, x, v ] |>,
            y -> <| u -> f[ a, y, u ], v -> f[ a, y, v ] |>,
            z -> <| u -> f[ a, z, u ], v -> f[ a, z, v ] |>
        |>,
        b -> <|
            x -> <| u -> f[ b, x, u ], v -> f[ b, x, v ] |>,
            y -> <| u -> f[ b, y, u ], v -> f[ b, y, v ] |>,
            z -> <| u -> f[ b, z, u ], v -> f[ b, z, v ] |>
        |>
    |>
]


VerificationTest[
    AssociationOuter[ f, { { 1, 2 }, { 3, 4 } }, { { a, b }, { c, d } }, 1 ],
    <|
        { 1, 2 } -> <|
            { a, b } -> f[ { 1, 2 }, { a, b } ],
            { c, d } -> f[ { 1, 2 }, { c, d } ]
        |>,
        { 3, 4 } -> <|
            { a, b } -> f[ { 3, 4 }, { a, b } ],
            { c, d } -> f[ { 3, 4 }, { c, d } ]
        |>
    |>
]


VerificationTest[
    AssociationOuter[ Times, { { 1, 2 }, { 3, 4 } }, { { a, b, c }, { d, e } } ],
    <|
        1 -> <| a -> a, b -> b, c -> c, d -> d, e -> e |>,
        2 -> <| a -> 2 * a, b -> 2 * b, c -> 2 * c, d -> 2 * d, e -> 2 * e |>,
        3 -> <| a -> 3 * a, b -> 3 * b, c -> 3 * c, d -> 3 * d, e -> 3 * e |>,
        4 -> <| a -> 4 * a, b -> 4 * b, c -> 4 * c, d -> 4 * d, e -> 4 * e |>
    |>
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

VerificationTest[
    AssociationOuter[ ],
    Failure[ "AssociationOuter::argm", _ ],
    { AssociationOuter::argm },
    SameTest -> MatchQ
]

VerificationTest[
    AssociationOuter[ f ],
    Failure[ "AssociationOuter::argm", _ ],
    { AssociationOuter::argm },
    SameTest -> MatchQ
]

VerificationTest[
    AssociationOuter[ f, { a, b, c }, x ],
    Failure[ "AssociationOuter::ipnfm", _ ],
    { AssociationOuter::ipnfm },
    SameTest -> MatchQ
]

VerificationTest[
    AssociationOuter[ f, { a, b, c }, x ],
    Failure[ "AssociationOuter::ipnfm", _ ],
    { AssociationOuter::ipnfm },
    SameTest -> MatchQ
]

VerificationTest[
    AssociationOuter[ f, x ],
    Failure[ "AssociationOuter::normal", _ ],
    { AssociationOuter::normal },
    SameTest -> MatchQ
]

VerificationTest[
    AssociationOuter[ f, g[ x ] ],
    Failure[ "AssociationOuter::list", _ ],
    { AssociationOuter::list },
    SameTest -> MatchQ
]



(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ
]
