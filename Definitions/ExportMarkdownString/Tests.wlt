(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "Initialization@@Definitions/ExportMarkdownString/Tests.wlt:4,1-9,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)
VerificationTest[
    ExportMarkdownString @ Row @ {
        Style[ "bold", FontWeight -> Bold ],
        " and ",
        Style[ "italic", FontSlant -> Italic ],
        " text"
    },
    "**bold** and *italic* text",
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-1@@Definitions/ExportMarkdownString/Tests.wlt:18,1-28,2"
]

VerificationTest[
    ExportMarkdownString @ TableForm[ { { a, b }, { c, d } }, TableHeadings -> { None, { "First", "Second" } } ],
    "| First | Second |\n| ----- | ------ |\n| a     | b      |\n| c     | d      |",
    SameTest -> MatchQ,
    TestID -> "BasicExamples-2@@Definitions/ExportMarkdownString/Tests.wlt:30,1-35,2"
]

VerificationTest[
    ExportMarkdownString @ Row @ {
        "This can format ",
        Style[ TraditionalForm, "InlineCode" ],
        " too: ",
        TraditionalForm @ Integrate[ Sin @ x / Log @ x, x ]
    },
    "This can format ``TraditionalForm`` too: $$\\int \\frac{\\sin (x)}{\\log (x)} \\, dx$$",
    SameTest -> MatchQ,
    TestID   -> "BasicExamples-3@@Definitions/ExportMarkdownString/Tests.wlt:37,1-47,2"
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
    TestID   -> "Cleanup@@Definitions/ExportMarkdownString/Tests.wlt:87,1-92,2"
]
