(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization@@Definitions/ImportMarkdownString/Tests.wlt:4,1-9,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)
VerificationTest[
    ImportMarkdownString[ "**bold** and *italic* text" ],
    RawBoxes @ Cell[
        TextData @ {
            StyleBox[ "bold", ___, FontWeight -> Bold, ___ ],
            " and ",
            StyleBox[ "italic", ___, FontSlant -> Italic, ___ ],
            " text"
        },
        "Text",
        ___
    ],
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-1@@Definitions/ImportMarkdownString/Tests.wlt:18,1-32,2"
]

VerificationTest[
    ImportMarkdownString[ "Math formatting: $$\\int_0^1 \\sin (\\sin (x)) \\, dx$$" ],
    RawBoxes @ Cell[
        TextData @ { "Math formatting: ", Cell @ BoxData @ FormBox[ TemplateBox[ _, "TeXAssistantTemplate", ___ ], TraditionalForm ] },
        "Text",
        ___
    ],
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-2@@Definitions/ImportMarkdownString/Tests.wlt:34,1-43,2"
]

VerificationTest[
    ImportMarkdownString[ "Visit [this website](https://www.wolfram.com) for more information." ],
    RawBoxes @ Cell[
        TextData @ {
            "Visit ",
            ButtonBox[
                "this website",
                OrderlessPatternSequence[
                    ___,
                    BaseStyle -> "Hyperlink",
                    ButtonData -> { URL[ "https://www.wolfram.com" ], None }
                ]
            ],
            " for more information."
        },
        "Text",
        ___
    ],
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-3@@Definitions/ImportMarkdownString/Tests.wlt:45,1-65,2"
]

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
    TestID   -> "Cleanup@@Definitions/ImportMarkdownString/Tests.wlt:105,1-110,2"
]
