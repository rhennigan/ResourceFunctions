VerificationTest[
    SetOptions[ MessageFailure, "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ
]

VerificationTest[
    MessageFailure[ Power::infy, HoldForm[ 1/0 ] ],
    Failure[
        "Power::infy",
        <|
            "MessageParameters" :> { HoldForm[ 1/0 ] },
            "MessageTemplate"   :> Power::infy
        |>
    ],
    { Power::infy }
]

VerificationTest[
    MessageFailure[ f::argx, f, 2 ],
    Failure[
        "f::argx",
        <|
            "MessageParameters" :> { f, 2 },
            "MessageTemplate"   :> f::argx
        |>
    ],
    { f::argx }
]

VerificationTest[

    rsqrt[ x_ ] :=
        If[ TrueQ[ x >= 0 ], Sqrt @ x, MessageFailure[ rsqrt::nnarg, x ] ];

    rsqrt::nnarg = "The argument `1` is not greater than or equal to zero.";
    rsqrt[ 2.25 ],
    1.5
]

VerificationTest[
    rsqrt[ -2.25 ],
    Failure[
        "rsqrt::nnarg",
        <|
            "MessageParameters" :> { -2.25 },
            "MessageTemplate"   :> rsqrt::nnarg
        |>
    ],
    { rsqrt::nnarg }
]

VerificationTest[
    MessageFailure[ "MyTag", <| "Message" -> "A thing broke." |> ],
    Failure[
        "MyTag",
        <|
            "MessageParameters" :> { "A thing broke." },
            "MessageTemplate"   :> MessageFailure::message
        |>
    ],
    { MessageFailure::message }
]

VerificationTest[
    MessageFailure[
        "MyTag",
        <|
            "MessageTemplate"   -> "A `1` broke.",
            "MessageParameters" -> { "very important thing" }
        |>
    ],
    Failure[
        "MyTag",
        <|
            "MessageParameters" :> { "A very important thing broke." },
            "MessageTemplate" :> MessageFailure::message
        |>
    ],
    { MessageFailure::message }
]

VerificationTest[
    MessageFailure[ ],
    Failure[
        "MessageFailure",
        <|
            "MessageParameters" :> { },
            "MessageTemplate"   :> MessageFailure::empty
        |>
    ],
    { MessageFailure::empty }
]

VerificationTest[
    MessageFailure[ "This is the error message" ],
    Failure[
        "MessageFailure",
        <|
            "MessageParameters" :> { "This is the error message" },
            "MessageTemplate"   :> MessageFailure::message
        |>
    ],
    { MessageFailure::message }
]

VerificationTest[
    MessageFailure[ "MyTag", "Here is the message" ],
    Failure[
        "MyTag",
        <|
            "MessageParameters" :> { "Here is the message" },
            "MessageTemplate"   :> MessageFailure::message
        |>
    ],
    { MessageFailure::message }
]

VerificationTest[
    MessageFailure[ MyFunction::argx, MyFunction, 2 ],
    Failure[
        "MyFunction::argx",
        <|
            "MessageParameters" :> { MyFunction, 2 },
            "MessageTemplate"   :> MyFunction::argx
        |>
    ],
    { MyFunction::argx }
]

VerificationTest[
    MessageFailure[
        MyFunction,
        <|
            "MessageTemplate"   :> General::argx,
            "MessageParameters" :> { MyFunction, 2 }
        |>
    ],
    Failure[
        MyFunction,
        <|
            "MessageParameters" :> { MyFunction, 2 },
            "MessageTemplate"   :> General::argx
        |>
    ],
    { General::argx }
]

VerificationTest[
    MessageFailure[
        MyFunction,
        <|
            "MessageTemplate"   :> MyFunction::argx,
            "MessageParameters" :> { MyFunction, 2 }
        |>
    ],
    Failure[
        MyFunction,
        <|
            "MessageParameters" :> { MyFunction, 2 },
            "MessageTemplate"   :> MyFunction::argx
        |>
    ],
    { MyFunction::argx }
]

VerificationTest[
    MessageFailure[
        Power::infy,
        Defer[ 1/0 ],
        "MessageFunction" -> Function[ result = { ## } ]
    ],
    Failure[
        "Power::infy",
        <|
            "MessageParameters" :> { Defer[ 1/0 ] },
            "MessageTemplate"   :> Power::infy
        |>
    ]
]

VerificationTest[ result, { Power::infy, Defer[ 1/0 ] } ]

VerificationTest[
    MessageFailure[
        FunctionRepository`Temp`MyFunction::infy,
        HoldForm[ 1/0 ],
        "MessageFunction" -> Automatic
    ],
    Failure[
        "MyFunction::infy",
        <|
            "MessageParameters" :> { HoldForm[ 1/0 ] },
            "MessageTemplate" :> FunctionRepository`Temp`MyFunction::infy
        |>
    ],
    { ResourceFunction::usermessage }
]

VerificationTest[
    MessageFailure[
        "MyTag",
        <|
            "MessageTemplate"   -> "A `1` broke.",
            "MessageParameters" -> "very important thing"
        |>
    ],
    Failure[
        "MyTag",
        <|
            "MessageParameters" :> { "A very important thing broke." },
            "MessageTemplate" :> MessageFailure::message
        |>
    ],
    { MessageFailure::message }
]

VerificationTest[
    MessageFailure[
        "MyTag",
        <|
            "MessageTemplate"   -> "A `1` broke.",
            "MessageParameters" -> { "very important thing" }
        |>
    ],
    Failure[
        "MyTag",
        <|
            "MessageParameters" :> { "A very important thing broke." },
            "MessageTemplate" :> MessageFailure::message
        |>
    ],
    { MessageFailure::message }
]

VerificationTest[
    MessageFailure[
        "RestrictionFailure",
        <|
            "MessageTemplate" :> Interpreter::numberinterval,
            "MessageParameters" ->
                <| "Min" -> 1, "Max" -> 10, "Input" -> { "100" } |>,
            "Interval" -> Interval @ { 1, 10 },
            "Input" -> { "100" },
            "Type" -> "Number"
        |>
    ],
    Failure[
        "RestrictionFailure",
        <|
            "MessageParameters" :>
                Evaluate @ <| "Min" -> 1, "Max" -> 10, "Input" -> { "100" } |>,
            "MessageTemplate" :> Interpreter::numberinterval,
            "Interval" :> Interval @ { 1, 10 },
            "Input" :> { "100" },
            "Type" :> "Number"
        |>
    ],
    { Interpreter::numberinterval }
]

VerificationTest[
    MessageFailure[
        "RestrictionFailure",
        <|
            "MessageTemplate" :> Interpreter::numberinterval,
            "MessageParameters" ->
                <| "Min" -> 1, "Max" -> 10, "Input" -> { "100" } |>,
            "MessageSymbol" -> MyFunction
        |>
    ],
    Failure[
        "RestrictionFailure",
        <|
            "MessageParameters" :>
                Evaluate @ <| "Min" -> 1, "Max" -> 10, "Input" -> { "100" } |>,
            "MessageTemplate" :> Interpreter::numberinterval
        |>
    ],
    { MyFunction::numberinterval }
]

VerificationTest[
    fail =
        MessageFailure @ <|
            "MessageTemplate" :> Style[ TemplateSlot[ 1 ], Green ],
            "MessageParameters" -> { "oh no!" }
        |>,
    Failure[
        "MessageFailure",
        <|
            "MessageParameters" :> { "oh no!" },
            "MessageTemplate" :> Style[ TemplateSlot[ 1 ], Green ]
        |>
    ],
    { MessageFailure::empty }
]

VerificationTest[
    MessageFailure @ fail,
    fail,
    { MessageFailure::empty }
]

VerificationTest[
    MessageFailure[ "MyTag", Automatic ],
    Failure[
        "MyTag",
        <|
            "MessageParameters" :> { "MyTag" },
            "MessageTemplate"   :> MessageFailure::tagged
        |>
    ],
    { MessageFailure::tagged }
]

VerificationTest[
    MessageFailure[ "MyTag", Automatic ][ "Message" ],
    "A failure of type \""~~__~~"\" occurred.",
    { MessageFailure::tagged },
    SameTest -> StringMatchQ
]

VerificationTest[
    SetOptions[ MessageFailure, "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ
]