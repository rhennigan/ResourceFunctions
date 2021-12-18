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
    CreateResourceFunctionSymbols[ ],
    Success[
        "CreateResourceFunctionSymbols",
        Alternatives[
            KeyValuePattern[ "Created" -> { __String } ],
            KeyValuePattern[ "Exists" -> { __Missing } ]
        ]
    ],
    SameTest -> MatchQ
]

VerificationTest[
    RF`GrayCode[ 14 ],
    { 1, 0, 0, 1 }
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)

VerificationTest[
    CreateResourceFunctionSymbols[ "MyContext`" ],
    Success[
        "CreateResourceFunctionSymbols",
        Alternatives[
            KeyValuePattern[ "Created" -> { __String } ],
            KeyValuePattern[ "Exists" -> { __Missing } ]
        ]
    ],
    SameTest -> MatchQ
]


VerificationTest[
    MyContext`GrayCode[ 14 ],
    { 1, 0, 0, 1 }
]


VerificationTest[
    CreateResourceFunctionSymbols[
        "NewContext`",
        { "GrayCode", "ColorToHex" }
    ],
    Success[
        "CreateResourceFunctionSymbols",
        Alternatives[
            KeyValuePattern[ "Created" -> { __String } ],
            KeyValuePattern[ "Exists" -> { __Missing } ]
        ]
    ],
    SameTest -> MatchQ
]


VerificationTest[
    NewContext`GrayCode[ 14 ],
    { 1, 0, 0, 1 }
]


VerificationTest[
    CreateResourceFunctionSymbols[ "NewContext`", All, "List" ],
    { ___, "NewContext`ColorToHex", ___, "NewContext`GrayCode", ___ },
    SameTest -> MatchQ
]

VerificationTest[
    NewContext`MyFunction[ x_ ] := x + 1;
    FreeQ[
        CreateResourceFunctionSymbols[ "NewContext`", All, "List" ],
        "NewContext`MyFunction"
    ],
    True
]


VerificationTest[
    CreateResourceFunctionSymbols[ "NewContext`", All, "Remove" ],
    Success[
        "CreateResourceFunctionSymbols",
        KeyValuePattern @ { "Removed" -> { __String }, "Failed" -> { } }
    ],
    SameTest -> MatchQ
]


VerificationTest[
    Names[ "NewContext`*" ],
    { ___, "NewContext`MyFunction", ___ },
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Options*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*OverwriteTarget*)
VerificationTest[
    CreateResourceFunctionSymbols[ "OverwriteTargetTest`", All, "Remove" ],
    Success[
        "CreateResourceFunctionSymbols",
        KeyValuePattern @ { "Removed" -> { ___String }, "Failed" -> { } }
    ],
    SameTest -> MatchQ
]

VerificationTest[
    OverwriteTargetTest`ColorToHex[ x_ ] := x + 1;
    CreateResourceFunctionSymbols[ "OverwriteTargetTest`", All ];
    OverwriteTargetTest`ColorToHex[ 5 ],
    6
]

VerificationTest[
    OverwriteTargetTest`GrayCode[ 14 ],
    { 1, 0, 0, 1 }
]

VerificationTest[

    CreateResourceFunctionSymbols[
        "OverwriteTargetTest`",
        All,
        OverwriteTarget -> True
    ];

    StringQ @ OverwriteTargetTest`ColorToHex @ Red,
    True
]

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*ExcludedContexts*)
VerificationTest[
    CreateResourceFunctionSymbols[ "System`", "ContainsQ" ],
    Failure[ "CreateResourceFunctionSymbols::exctx", _ ],
    { CreateResourceFunctionSymbols::exctx },
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Applications*)


(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Properties and Relations*)
VerificationTest[
    CreateResourceFunctionSymbols[ "RedefineTest`", All, "Remove" ],
    Success[
        "CreateResourceFunctionSymbols",
        KeyValuePattern @ { "Removed" -> { ___String }, "Failed" -> { } }
    ],
    SameTest -> MatchQ
]

VerificationTest[
    CreateResourceFunctionSymbols[
        "RedefineTest`",
        { "GrayCode", "ColorToHex" }
    ],
    Success[
        "CreateResourceFunctionSymbols",
        KeyValuePattern[
            "Created" -> { "RedefineTest`GrayCode", "RedefineTest`ColorToHex" }
        ]
    ],
    SameTest -> MatchQ
]


VerificationTest[
    CreateResourceFunctionSymbols[
        "RedefineTest`",
        { "GrayCode", "ColorToHex", "AppendSequence" }
    ],
    Success[
        "CreateResourceFunctionSymbols",
        KeyValuePattern @ {
            "Created" -> { "RedefineTest`AppendSequence" },
            "Exists" -> {
                Missing[ "SymbolExists", "RedefineTest`GrayCode" ],
                Missing[ "SymbolExists", "RedefineTest`ColorToHex" ]
            }
        }
    ],
    SameTest -> MatchQ
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


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)

VerificationTest[
    Map[
        CreateResourceFunctionSymbols[ #1, All, "Remove" ] &,
        {
            "RF`",
            "MyContext`",
            "BirdStuff`",
            "NewContext`",
            "EmptyContext`",
            "WFP`",
            "Global`",
            "RedefineTest`",
            "DefinitionExample`"
        }
    ],
    {
        Success[
            "CreateResourceFunctionSymbols",
            KeyValuePattern @ { "Removed" -> { ___String }, "Failed" -> { } }
        ]..
    },
    SameTest -> MatchQ
]


VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ
]
