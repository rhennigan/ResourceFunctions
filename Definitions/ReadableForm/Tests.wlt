VerificationTest[
    verifyExpr // ClearAll;
    verifyExpr // Attributes = { HoldAllComplete };
    verifyExpr[ expr_, opts___ ] :=
        Module[ { string, readable },
            string   = ToString[ HoldComplete @ expr, InputForm ];
            readable = ToString @ ReadableForm[ HoldComplete @ expr, opts ];
            SameQ[
                ToExpression[ string, InputForm, HoldComplete ],
                ToExpression[ readable, InputForm, HoldComplete ]
            ]
        ],
    Null
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Regression tests*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Verify round trips*)
VerificationTest[
    verifyExpr[
        Hold[ Times[ a, -1 ], Times[ -1, a ] ]
    ]
]

VerificationTest[
    verifyExpr @ <|
        "Context" -> ($Context = ctx),
        "ContextPath" -> ($ContextPath = cp)
    |>
]

VerificationTest[
    verifyExpr @ Hold @ Plus[
        a,
        Times[
            -1,
            Plus[ Times[ -1, f[ Plus[ b, 1 ] ] ] ]
        ]
    ]
]

VerificationTest[
    verifyExpr @ Function[ Times[ Slot[1], -1 ] ]
]

VerificationTest @ verifyExpr[
    HoldComplete @ Association @ Apply[
        Rule,
        Tally[ Part[ Part[ preformated, All, 4 ], All, 2 ] ],
        { 1 }
    ],
    PageWidth -> 65,
    "DynamicAlignment" -> True,
    "StrictMode" -> True
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Expected ooutputs*)
VerificationTest[
    ToString @ ReadableForm[
        Unevaluated[
            \[FormalA] - (\[FormalB] + \[FormalC]) - \[FormalD] + \[FormalE]
        ],
        "DynamicAlignment" -> True,
        PageWidth -> 30
    ],
    "\[FormalA] - (\[FormalB] + \[FormalC]) - \[FormalD] + \[FormalE]"
]

VerificationTest[
    ToString @ ReadableForm @ Hold @ Association @ stuff,
    "Hold @ Association @ stuff"
]

VerificationTest[
    ToString @ ReadableForm @ Hold[ Now - Quantity[ 12, "Hours" ] ],
    "Hold[ Now - Quantity[ 12, \"Hours\" ] ]"
]

VerificationTest[
    ToString @ ReadableForm @ Hold @ x[[ 1, 2;;3;;4 ]],
    "Hold @ x[[ 1, 2;;3;;4 ]]"
]

VerificationTest[
    ToString @ ReadableForm @ Unevaluated[
        $checkPropertyOptions = <|
            "DefinitionNotebook" -> {
                "IgnoredProperties" -> {
                    "DefinitionNotebook",
                    "FileManagerData",
                    "PacletFiles",
                    "PacletObject"
                }
            },
            "Documentation" -> { "ScrapedProperties" -> { "Documentation" } },
            "PacletFiles" -> {
                "ScrapedProperties" -> {
                    "PacletFiles",
                    "PacletObject",
                    "Name",
                    "Description",
                    "ContributorInformation"
                }
            }
        |>;
    ],
    "\
$checkPropertyOptions = <|
    \"DefinitionNotebook\" -> {
        \"IgnoredProperties\" -> {
            \"DefinitionNotebook\",
            \"FileManagerData\",
            \"PacletFiles\",
            \"PacletObject\"
        }
    },
    \"Documentation\" -> { \"ScrapedProperties\" -> { \"Documentation\" } },
    \"PacletFiles\" -> {
        \"ScrapedProperties\" -> {
            \"PacletFiles\",
            \"PacletObject\",
            \"Name\",
            \"Description\",
            \"ContributorInformation\"
        }
    }
|>;"
]