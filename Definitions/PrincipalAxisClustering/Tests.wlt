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
    points = RandomReal[ 1, { 128, 2 } ];,
    Null
]

VerificationTest[
    Length[ clusters = PrincipalAxisClustering[ points, 10 ] ],
    10
]

VerificationTest[
    Sort @ points === Sort @ Flatten[ clusters, 1 ],
    True
]

VerificationTest[
    Sort[
        Length /@ PrincipalAxisClustering[ RandomReal[ 1, { 128, 2 } ], 10 ]
    ],
    { 8, 8, 8, 8, 16, 16, 16, 16, 16, 16 }
]


VerificationTest[
    Apply[
        SameQ,
        Map[
            Length,
            PrincipalAxisClustering[
                RandomReal[ 1, { 2^RandomInteger[10], 2 } ],
                Method -> Median
            ]
        ]
    ],
    True
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Error Cases*)


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ
]
