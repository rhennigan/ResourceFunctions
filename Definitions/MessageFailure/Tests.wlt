VerificationTest[
    SetOptions[ MessageFailure, "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ,
    TestID   -> "SetTestMode@@Definitions/MessageFailure/Tests.wlt:1,1-6,2"
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
    { Power::infy },
    TestID -> "DivideByZero@@Definitions/MessageFailure/Tests.wlt:8,1-19,2"
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
    { f::argx },
    TestID -> "FunctionArgumentError@@Definitions/MessageFailure/Tests.wlt:21,1-32,2"
]

VerificationTest[
    rsqrt[ x_ ] := If[ TrueQ[ x >= 0 ], Sqrt @ x, MessageFailure[ rsqrt::nnarg, x ] ];
    rsqrt::nnarg = "The argument `1` is not greater than or equal to zero.";
    rsqrt[ 2.25 ],
    1.5,
    TestID -> "NonNegativeArgument-1@@Definitions/MessageFailure/Tests.wlt:34,1-40,2"
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
    { rsqrt::nnarg },
    TestID -> "NonNegativeArgument-2@@Definitions/MessageFailure/Tests.wlt:42,1-53,2"
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
    { MessageFailure::message },
    TestID -> "TagAndMessageAssociation@@Definitions/MessageFailure/Tests.wlt:55,1-66,2"
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
            "MessageTemplate"   :> MessageFailure::message
        |>
    ],
    { MessageFailure::message },
    TestID -> "MessageTemplateAndParametersAssociation@@Definitions/MessageFailure/Tests.wlt:68,1-85,2"
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
    { MessageFailure::empty },
    TestID -> "EmptyMessage@@Definitions/MessageFailure/Tests.wlt:87,1-98,2"
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
    { MessageFailure::message },
    TestID -> "MessageOnly@@Definitions/MessageFailure/Tests.wlt:100,1-111,2"
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
    { MessageFailure::message },
    TestID -> "TagAndMessage@@Definitions/MessageFailure/Tests.wlt:113,1-124,2"
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
    { MyFunction::argx },
    TestID -> "FunctionArgumentError@@Definitions/MessageFailure/Tests.wlt:126,1-137,2"
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
    { General::argx },
    TestID -> "GeneralArgumentError@@Definitions/MessageFailure/Tests.wlt:139,1-156,2"
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
    { MyFunction::argx },
    TestID -> "GeneralArgumentError@@Definitions/MessageFailure/Tests.wlt:158,1-175,2"
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
    ],
    TestID -> "OptionsMessageFunction-1@@Definitions/MessageFailure/Tests.wlt:177,1-191,2"
]

VerificationTest[
    result,
    { Power::infy, Defer[ 1/0 ] },
    TestID -> "OptionsMessageFunction-2@@Definitions/MessageFailure/Tests.wlt:193,1-197,2"
]

VerificationTest[
    WithCleanup[
        SetOptions[ MessageFailure, "TestMode" -> False ],
        MessageFailure[
            FunctionRepository`Temp`MyFunction::infy,
            HoldForm[ 1/0 ],
            "MessageFunction" -> Automatic
        ],
        SetOptions[ MessageFailure, "TestMode" -> True ]
    ],
    Failure[
        "MyFunction::infy",
        <|
            "MessageParameters" :> { HoldForm[ 1/0 ] },
            "MessageTemplate"   :> FunctionRepository`Temp`MyFunction::infy
        |>
    ],
    { ResourceFunction::usermessage },
    TestID -> "OptionsMessageFunction-3@@Definitions/MessageFailure/Tests.wlt:199,1-218,2"
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
            "MessageTemplate"   :> MessageFailure::message
        |>
    ],
    { MessageFailure::message },
    TestID -> "MessageTemplateAndParameters@@Definitions/MessageFailure/Tests.wlt:220,1-237,2"
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
            "MessageTemplate"   :> MessageFailure::message
        |>
    ],
    { MessageFailure::message },
    TestID -> "MessageTemplateAndParameters-2@@Definitions/MessageFailure/Tests.wlt:239,1-256,2"
]

VerificationTest[
    MessageFailure[
        "RestrictionFailure",
        <|
            "MessageTemplate"   :> Interpreter::numberinterval,
            "MessageParameters" -> <| "Min" -> 1, "Max" -> 10, "Input" -> { "100" } |>,
            "Interval"          -> Interval @ { 1, 10 },
            "Input"             -> { "100" },
            "Type"              -> "Number"
        |>
    ],
    Failure[
        "RestrictionFailure",
        <|
            "MessageParameters" :> Evaluate @ <| "Min" -> 1, "Max" -> 10, "Input" -> { "100" } |>,
            "MessageTemplate"   :> Interpreter::numberinterval,
            "Interval"          :> Interval @ { 1, 10 },
            "Input"             :> { "100" },
            "Type"              :> "Number"
        |>
    ],
    { Interpreter::numberinterval },
    TestID -> "MessageTemplateAndNamedParameters-1@@Definitions/MessageFailure/Tests.wlt:258,1-281,2"
]

VerificationTest[
    MessageFailure[
        "RestrictionFailure",
        <|
            "MessageTemplate"   :> Interpreter::numberinterval,
            "MessageParameters" -> <| "Min" -> 1, "Max" -> 10, "Input" -> { "100" } |>,
            "MessageSymbol"     -> MyFunction
        |>
    ],
    Failure[
        "RestrictionFailure",
        <|
            "MessageParameters" :> Evaluate @ <| "Min" -> 1, "Max" -> 10, "Input" -> { "100" } |>,
            "MessageTemplate"   :> Interpreter::numberinterval
        |>
    ],
    { MyFunction::numberinterval },
    TestID -> "MessageTemplateAndNamedParameters-2@@Definitions/MessageFailure/Tests.wlt:283,1-301,2"
]

VerificationTest[
    fail = MessageFailure @ <|
        "MessageTemplate"   :> Style[ TemplateSlot[ 1 ], Green ],
        "MessageParameters" -> { "oh no!" }
    |>,
    Failure[
        "MessageFailure",
        <|
            "MessageParameters" :> { "oh no!" },
            "MessageTemplate"   :> Style[ TemplateSlot[ 1 ], Green ]
        |>
    ],
    { MessageFailure::empty },
    TestID -> "MessageExpressionTemplate-1@@Definitions/MessageFailure/Tests.wlt:303,1-317,2"
]

VerificationTest[
    MessageFailure @ fail,
    fail,
    { MessageFailure::empty },
    TestID -> "MessageExpressionTemplate-2@@Definitions/MessageFailure/Tests.wlt:319,1-324,2"
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
    { MessageFailure::tagged },
    TestID -> "AutomaticMessageText-1@@Definitions/MessageFailure/Tests.wlt:326,1-337,2"
]

VerificationTest[
    MessageFailure[ "MyTag", Automatic ][ "Message" ],
    "A failure of type \"" ~~ __ ~~ "\" occurred.",
    { MessageFailure::tagged },
    SameTest -> StringMatchQ,
    TestID   -> "AutomaticMessageText-2@@Definitions/MessageFailure/Tests.wlt:339,1-345,2"
]

VerificationTest[
    MyFunction::test = "first: `1`, second: `2`";
    fail = MessageFailure[ MyFunction::test, 123, { } ],
    Failure[
        "MyFunction::test",
        KeyValuePattern @ { "MessageParameters" :> { 123, { } }, "MessageTemplate" :> MyFunction::test }
    ],
    { MyFunction::test },
    SameTest -> MatchQ,
    TestID   -> "ListParameterRegressionTest-1@@Definitions/MessageFailure/Tests.wlt:347,1-357,2"
]

VerificationTest[
    ToString @ fail[ "Message" ],
    "first: 123, second: {}",
    TestID -> "ListParameterRegressionTest-2@@Definitions/MessageFailure/Tests.wlt:359,1-363,2"
]

VerificationTest[
    SetOptions[ MessageFailure, "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ,
    TestID   -> "RestoreTestMode@@Definitions/MessageFailure/Tests.wlt:365,1-370,2"
]