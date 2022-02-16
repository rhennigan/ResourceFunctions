(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID -> "Set-MessageFailure-TestMode@@Definitions/ASTPattern/Tests.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "CodeParser`" ],
    Null,
    TestID -> "Initialize-Needs-CodeParser@@Definitions/ASTPattern/Tests.wlt:11,1-15,2"
]

VerificationTest[
    setDef // Attributes = { HoldFirst };
    setDef[ sym_Symbol ] :=
        If[ Context @ sym =!= Context @ ASTPattern,
            sym = Symbol @ StringJoin[
                      Context @ ASTPattern,
                      SymbolName @ Unevaluated @ sym
                  ];
            HoldPattern[ sym ] -> sym,
            Nothing
        ],
    Null,
    TestID -> "RF-Context-Helper-Definition@@Definitions/ASTPattern/Tests.wlt:17,1-30,2"
]

VerificationTest[
    setDef /@ { FromAST, EquivalentNodeQ },
    { }|{ _Rule, _Rule },
    SameTest -> MatchQ,
    TestID -> "RF-Context-Helper-Set@@Definitions/ASTPattern/Tests.wlt:32,1-37,2"
]

VerificationTest[
    testParse // Attributes = { HoldRest };

    testParse[ str_ ] := (CodeParse @ str)[[ 2, 1 ]];

    testParse[ str_, patt_ ] :=
        MatchQ[ testParse @ str, ASTPattern @ HoldPattern @ patt ];
    ,
    Null,
    TestID -> "TestParse-Definition@@Definitions/ASTPattern/Tests.wlt:39,1-49,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Context Check*)
VerificationTest[
    Context @ CodeParse,
    "CodeParser`",
    TestID -> "Context-CodeParse@@Definitions/ASTPattern/Tests.wlt:54,1-58,2"
]

VerificationTest[
    Context @ LeafNode,
    "CodeParser`",
    TestID -> "Context-LeafNode@@Definitions/ASTPattern/Tests.wlt:60,1-64,2"
]

VerificationTest[
    Context @ CallNode,
    "CodeParser`",
    TestID -> "Context-CallNode@@Definitions/ASTPattern/Tests.wlt:66,1-70,2"
]

VerificationTest[
    Context @ Source,
    "CodeParser`",
    TestID -> "Context-Source@@Definitions/ASTPattern/Tests.wlt:72,1-76,2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*ASTPattern*)
VerificationTest[
    ASTPattern[ _Integer ],
    (CallNode | LeafNode)[
        Integer | LeafNode[ Symbol, "Integer" | "System`Integer", _ ],
        _,
        _
    ],
    TestID -> "Leaf-Call@@Definitions/ASTPattern/Tests.wlt:81,1-89,2"
]

VerificationTest[
    ASTPattern[ _Integer? IntegerQ ],
    LeafNode[ Integer, _, _ ],
    TestID -> "Leaf-PatternTest@@Definitions/ASTPattern/Tests.wlt:91,1-95,2"
]

VerificationTest[
    ASTPattern @ x,
    LeafNode[ Symbol, "x" | Context @ x <> "x", _ ],
    TestID -> "Leaf-Symbol@@Definitions/ASTPattern/Tests.wlt:97,1-101,2"
]

VerificationTest[
    ASTPattern @ HoldPattern @ Identity[ _ ],
    CallNode[
        LeafNode[ Symbol, "Identity" | "System`Identity", _ ],
        { (CallNode|LeafNode)[ _, _, _ ] },
        _
    ],
    TestID -> "HoldPattern@@Definitions/ASTPattern/Tests.wlt:103,1-111,2"
]

VerificationTest[
    ASTPattern @ f[ ASTPattern[ _ ], ASTPattern[ _ ] ],
    ASTPattern @ f[ _, _ ],
    TestID -> "Invisible-Nested@@Definitions/ASTPattern/Tests.wlt:113,1-117,2"
]

VerificationTest[
    ASTPattern[ f[ ASTPattern[ _, a_ ], ASTPattern[ _, b_ ] ], c_ ],
    CodeParser`CallNode[
        CodeParser`LeafNode[ Symbol, "f" | Context @ f <> "f", _ ],
        {
            (CodeParser`CallNode | CodeParser`LeafNode)[ _, _, a_ ],
            (CodeParser`CallNode | CodeParser`LeafNode)[ _, _, b_ ]
        },
        c_
    ],
    TestID -> "Bound-Nested@@Definitions/ASTPattern/Tests.wlt:119,1-130,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Duplicate Pattern Symbols*)
VerificationTest[
    Count[ CodeParse[ "{{1,1},{2,2}}" ], ASTPattern @ { a_, a_ }, Infinity ],
    2,
    TestID -> "Duplicate-Pattern-Symbols-1@@Definitions/ASTPattern/Tests.wlt:135,1-139,2"
]

VerificationTest[
    Count[
        CodeParse[ "{{{1,1},{2,2}},{{1,1},{2,2}}}" ],
        ASTPattern @ { a_, a_ },
        Infinity
    ],
    5,
    TestID -> "Duplicate-Pattern-Symbols-2@@Definitions/ASTPattern/Tests.wlt:141,1-149,2"
]

VerificationTest[
    Cases[
        CodeParse[ "{{1,1,1},{1,1},{1,1,1,2},{2,2,2}}" ],
        ASTPattern[ expr: { a_, a_, a_ } ] :> FromAST @ expr,
        Infinity
    ],
    { { 1, 1, 1 }, { 2, 2, 2 } },
    TestID -> "Duplicate-Pattern-Symbols-3@@Definitions/ASTPattern/Tests.wlt:151,1-159,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Two Arguments*)
VerificationTest[
    ASTPattern[ id_String, as1_ ],
    id: (CallNode | LeafNode)[
        String | LeafNode[ Symbol, "String" | "System`String", _ ],
        _,
        as1_
    ],
    TestID -> "Two-Arguments@@Definitions/ASTPattern/Tests.wlt:164,1-172,2"
]

VerificationTest[
    Cases[
        CodeParse[ "VerificationTest[1 + 1, 2, TestID -> \"Addition\", SameTest -> SameQ]" ],
        ASTPattern[
            HoldPattern @ VerificationTest[
                __,
                TestID -> ASTPattern[ id_String, as1_ ],
                ___
            ] /; StringQ @ id,
            as2_
        ] :> Lookup[ { as1, as2 }, Source ],
        Infinity
    ],
    { { { { 1, 38 }, { 1, 48 } }, { { 1, 1 }, { 1, 68 } } } },
    TestID -> "Nested-Meta-Bindings@@Definitions/ASTPattern/Tests.wlt:174,1-189,2"
]

VerificationTest[
    ASTPattern[ id_, as1_ ],
    id: (CallNode | LeafNode)[ _, _, as1_ ],
    TestID -> "Meta-Unknown-Head@@Definitions/ASTPattern/Tests.wlt:191,1-195,2"
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*TestParse*)
VerificationTest[
    testParse[ "VerificationTest[x,y]", VerificationTest[ ___ ] ],
    True,
    TestID -> "TestParse-VerificationTest@@Definitions/ASTPattern/Tests.wlt:200,1-204,2"
]

VerificationTest[
    testParse[ "f[x,y]", f[ _, _ ] ],
    True,
    TestID -> "TestParse-Normal@@Definitions/ASTPattern/Tests.wlt:206,1-210,2"
]

VerificationTest[
    testParse[ "2.5", _Real ],
    True,
    TestID -> "TestParse-Atom-Real@@Definitions/ASTPattern/Tests.wlt:212,1-216,2"
]

VerificationTest[
    testParse[ "2", _Integer ],
    True,
    TestID -> "TestParse-Atom-Integer@@Definitions/ASTPattern/Tests.wlt:218,1-222,2"
]

VerificationTest[
    testParse[ "\"hello\"", _String ],
    True,
    TestID -> "TestParse-Atom-String@@Definitions/ASTPattern/Tests.wlt:224,1-228,2"
]

VerificationTest[
    testParse[ "x", _Symbol ],
    True,
    TestID -> "TestParse-Atom-Symbol@@Definitions/ASTPattern/Tests.wlt:230,1-234,2"
]

VerificationTest[
    With[ { expr = 2/3 }, testParse[ "2/3", expr ] ],
    True,
    TestID -> "TestParse-Atom-Rational@@Definitions/ASTPattern/Tests.wlt:236,1-240,2"
]

VerificationTest[
    With[ { expr = 2 + 3 I }, testParse[ "2 + 3 I", expr ] ],
    True,
    TestID -> "TestParse-Atom-Complex@@Definitions/ASTPattern/Tests.wlt:242,1-246,2"
]

VerificationTest[
    testParse[ "5", x_Integer ],
    True,
    TestID -> "TestParse-Pattern@@Definitions/ASTPattern/Tests.wlt:248,1-252,2"
]

VerificationTest[
    testParse[ "f[5]", e: f[ x_Integer ] ],
    True,
    TestID -> "TestParse-Nested-Pattern@@Definitions/ASTPattern/Tests.wlt:254,1-258,2"
]

VerificationTest[
    testParse[ "f[5]", f[ x_Integer ] /; Positive @ x ],
    True,
    TestID -> "TestParse-Condition-1@@Definitions/ASTPattern/Tests.wlt:260,1-264,2"
]

VerificationTest[
    testParse[ "f[5]", f[ x_Integer ] /; Negative @ x ],
    False,
    TestID -> "TestParse-Condition-2@@Definitions/ASTPattern/Tests.wlt:266,1-270,2"
]

VerificationTest[
    testParse[
        "VerificationTest[1+1, 2, TestID -> \"test\"]",
        VerificationTest[ __, TestID -> id_, ___ ] /; StringQ @ id
    ],
    True,
    TestID -> "TestParse-Condition-3@@Definitions/ASTPattern/Tests.wlt:272,1-279,2"
]

VerificationTest[
    testParse[
        "VerificationTest[1+1, 2, TestID -> Automatic]",
        VerificationTest[ __, TestID -> id_, ___ ] /; StringQ @ id
    ],
    False,
    TestID -> "TestParse-Condition-4@@Definitions/ASTPattern/Tests.wlt:281,1-288,2"
]

VerificationTest[
    testParse[ "5", _Integer? IntegerQ ],
    True,
    TestID -> "TestParse-PatternTest-1@@Definitions/ASTPattern/Tests.wlt:290,1-294,2"
]

VerificationTest[
    testParse[ "5", x_Integer? IntegerQ ],
    True,
    TestID -> "TestParse-PatternTest-2@@Definitions/ASTPattern/Tests.wlt:296,1-300,2"
]

VerificationTest[
    testParse[ "5", x_ /; IntegerQ @ x ],
    True,
    TestID -> "TestParse-PatternTest-3@@Definitions/ASTPattern/Tests.wlt:302,1-306,2"
]

VerificationTest[
    testParse[ "f[1.2]", f @ Except[ _Integer ] ],
    True,
    TestID -> "TestParse-Except-1@@Definitions/ASTPattern/Tests.wlt:308,1-312,2"
]

VerificationTest[
    testParse[ "f[1.2]", f @ Except[ _Real ] ],
    False,
    TestID -> "TestParse-Except-2@@Definitions/ASTPattern/Tests.wlt:314,1-318,2"
]

VerificationTest[
    testParse[ "f[1.2]", f @ Except[ _Integer, _Real ] ],
    True,
    TestID -> "TestParse-Except-3@@Definitions/ASTPattern/Tests.wlt:320,1-324,2"
]

VerificationTest[
    testParse[ "f[1.2]", f @ Except[ _Integer, _String ] ],
    False,
    TestID -> "TestParse-Except-4@@Definitions/ASTPattern/Tests.wlt:326,1-330,2"
]

VerificationTest[
    testParse[ "f[\"hello\"]", f @ Except[ _Integer, _String ] ],
    True,
    TestID -> "TestParse-Except-5@@Definitions/ASTPattern/Tests.wlt:332,1-336,2"
]

VerificationTest[
    testParse[ "{a,b,c,d,c,d,a,b}", { x__, PatternSequence[ c, d, c ], y__ } ],
    True,
    TestID -> "TestParse-PatternSequence-1@@Definitions/ASTPattern/Tests.wlt:338,1-342,2"
]

VerificationTest[
    testParse[ "{a,b,a,b,a,b,a,b,a,b}", { PatternSequence[ x_, x_ ].. } ],
    False,
    TestID -> "TestParse-PatternSequence-3@@Definitions/ASTPattern/Tests.wlt:344,1-348,2"
]

VerificationTest[
    testParse[ "{1,1,2,2}", ASTPattern @ { x_, x_, y_, y_ } ],
    True,
    TestID -> "Reused-Pattern-Bindings-1@@Definitions/ASTPattern/Tests.wlt:350,1-354,2"
]

VerificationTest[
    testParse[
        "1+1",
        ASTPattern @ HoldPattern[ ASTPattern[ 1 ] + ASTPattern[ 1 ] ]
    ],
    True,
    TestID -> "Nested-ASTPattern-Held@@Definitions/ASTPattern/Tests.wlt:356,1-363,2"
]

VerificationTest[
    testParse[ "{1,1}", ASTPattern[ { x_, x_ } /; IntegerQ @ x ] ],
    True,
    TestID -> "Reused-Bindings-Condition@@Definitions/ASTPattern/Tests.wlt:365,1-369,2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*FromAST*)
VerificationTest[
    Cases[
        CodeParse[ "VerificationTest[1 + 1, 2, TestID -> \"Addition\", SameTest -> SameQ]" ],
        ASTPattern[
            HoldPattern @ VerificationTest[
                __,
                TestID -> ASTPattern[ id_String, as1_ ],
                ___
            ] /; StringQ @ id,
            as2_
        ] :> FromAST @ id,
        Infinity
    ],
    { "Addition" },
    TestID -> "FromAST-Bindings@@Definitions/ASTPattern/Tests.wlt:374,1-389,2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*EquivalentNodeQ*)
VerificationTest[
    Enclose @ Apply[
        EquivalentNodeQ,
        ConfirmMatch[
            Cases[
                CodeParse[ "{f[x],f[x]}" ],
                ASTPattern[ _[ _ ] ],
                Infinity
            ],
            { _, _ }
        ]
    ],
    True,
    TestID -> "EquivalentNodeQ-1@@Definitions/ASTPattern/Tests.wlt:394,1-408,2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Regression Tests*)
VerificationTest[
    testParse[ "{a,a,a}", ASTPattern[ { x: (_).. } /; SameQ @ x ] ],
    True,
    TestID -> "FromAST-Sequence-1@@Definitions/ASTPattern/Tests.wlt:413,1-417,2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Future*)
Hold @ VerificationTest[
    testParse[ "{a,b,a,b,a,b,a,b,a,b}", { PatternSequence[ x_, y_ ].. } ],
    True,
    TestID -> "TestParse-PatternSequence-2@@Definitions/ASTPattern/Tests.wlt:422,8-426,2"
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID -> "Reset-MessageFailure-TestMode@@Definitions/ASTPattern/Tests.wlt:431,1-436,2"
]
