(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ
]

VerificationTest[
    $tmp = FileNameJoin @ { $TemporaryDirectory, "readable.nb" },
    _String,
    SameTest -> MatchQ,
    TestID   -> "Define-Temporary-File"
]

VerificationTest[
    saveAndOpenTest[ nb_, opts___ ] :=
        UsingFrontEnd @ Enclose @ Module[ { file, nbo },
            Quiet @ DeleteFile @ $tmp;
            ConfirmAssert[ ! FileExistsQ @ $tmp ];

            file = ConfirmBy[
                SaveReadableNotebook[ nb, $tmp, opts ],
                FileExistsQ
            ];

            WithCleanup[
                nbo = ConfirmMatch[ NotebookOpen @ file, _NotebookObject ];
                NotebookGet @ nbo,
                NotebookClose @ nbo
            ]
        ],
    Null,
    TestID -> "Define-NotebookOpen-Test"
]

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Convert to String*)
VerificationTest[
    UsingFrontEnd @ WithCleanup[
        nb = CreateDocument @ {
                TextCell[ "Test notebook", "Title" ],
                TextCell[ "This is a test", "Text" ],
                ExpressionCell[ Defer[ 1 + 1 ], "Input" ],
                ExpressionCell[ 2, "Output" ]
            },
        ImportString[ SaveReadableNotebook[ nb, String ], "NB" ],
        NotebookClose @ nb
    ],
    _Notebook,
    SameTest -> MatchQ,
    TestID   -> "Save-NotebookObject-String"
]

VerificationTest[
    ImportString[
        SaveReadableNotebook[
            Notebook @ { Cell[ "Hello world", "Text" ] },
            String
        ],
        "NB"
    ],
    _Notebook,
    SameTest -> MatchQ,
    TestID   -> "Save-Notebook-String"
]

VerificationTest[
    ImportString[
        SaveReadableNotebook[
            FindFile[ "ExampleData/document.nb" ],
            String
        ],
        "NB"
    ],
    _Notebook,
    SameTest -> MatchQ,
    TestID   -> "Save-File-String"
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Save to File*)
VerificationTest[
    UsingFrontEnd @ WithCleanup[
        nb = CreateDocument @ {
                TextCell[ "Test notebook", "Title" ],
                TextCell[ "This is a test", "Text" ],
                ExpressionCell[ Defer[ 1 + 1 ], "Input" ],
                ExpressionCell[ 2, "Output" ]
            },
        saveAndOpenTest @ nb,
        NotebookClose @ nb
    ],
    _Notebook,
    SameTest -> MatchQ,
    TestID   -> "Save-NotebookObject-File"
]

VerificationTest[
    saveAndOpenTest @ Notebook @ { Cell[ "Hello world", "Text" ] },
    _Notebook,
    SameTest -> MatchQ,
    TestID   -> "Save-Notebook-File"
]

VerificationTest[
    saveAndOpenTest @ FindFile[ "ExampleData/document.nb" ],
    _Notebook,
    SameTest -> MatchQ,
    TestID   -> "Save-File-File"
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
