(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ
]

VerificationTest[
    ClearAll[
        AddOne,
        AddTwo,
        Add2,
        Add3,
        $value,
        $condition,
        symbol,
        MyFunction
    ],
    Null
]

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Tests*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Basic Examples*)
VerificationTest[
    AddOne // ClearAll;
    AddOne[ x_? NumberQ ] := x + 1;
    FailWhenUndefined @ AddOne,
    _RuleDelayed,
    SameTest -> MatchQ
]

VerificationTest[
    AddOne[ 5 ],
    6
]

VerificationTest[
    AddOne[ "test" ],
    Failure[ "Undefined", _ ],
    { AddOne::undefined },
    SameTest -> MatchQ
]

VerificationTest[
    AddOne[ 1,2,3 ],
    Failure[ "Undefined", _ ],
    { AddOne::undefined },
    SameTest -> MatchQ
]

VerificationTest[
    AddTwo // ClearAll;
    AddTwo[ x_? NumberQ ] := x + 2;
    FailWhenUndefined[ AddTwo, Throw ],
    _RuleDelayed,
    SameTest -> MatchQ
]

VerificationTest[
    Catch[ AddTwo /@ { 1, 2, 3 } ],
    { 3, 4, 5 }
]

VerificationTest[
    Catch[ AddTwo /@ { 1, 2, "three" } ],
    Failure[ "Undefined", _ ],
    { AddTwo::undefined },
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Scope*)
VerificationTest[
    Add2[ x_? NumberQ ][ y_? NumberQ ] := x + y;
    FailWhenUndefined[ Add2, Identity, SubValues ],
    _RuleDelayed,
    SameTest -> MatchQ
]

VerificationTest[
    Add2[ 5 ],
    HoldPattern @ Add2[ 5 ],
    SameTest -> MatchQ
]

VerificationTest[
    Add2[ 5 ][ 6 ],
    11
]

VerificationTest[
    Add2[ "hello" ],
    HoldPattern @ Add2[ "hello" ],
    SameTest -> MatchQ
]

VerificationTest[
    Add2[ "hello" ][ "world" ],
    Failure[ "Undefined", _ ],
    { Add2::undefined },
    SameTest -> MatchQ
]

VerificationTest[
    Add3[ x_? NumberQ ][ (y_? NumberQ) ][ z_? NumberQ ] := x + y + z;
    FailWhenUndefined[ Add3, Identity, { SubValues, 3 } ],
    _RuleDelayed,
    SameTest -> MatchQ
]

VerificationTest[
    Add3[ 5 ][ 6 ][ 7 ],
    18
]

VerificationTest[
    Add3[ 5 ][ 6 ][ "hello" ],
    Failure[ "Undefined", _ ],
    { Add3::undefined },
    SameTest -> MatchQ
]

VerificationTest[
    $value /; $condition := "The condition is True";
    $value /; ! $condition := "The condition is False";
    FailWhenUndefined[ $value, Identity, OwnValues ],
    _RuleDelayed,
    SameTest -> MatchQ
]

VerificationTest[
    $condition = True;
    $value,
    "The condition is True"
]

VerificationTest[
    $condition = False;
    $value,
    "The condition is False"
]

VerificationTest[
    $condition = "hello";
    $value,
    Failure[ "Undefined", _ ],
    { $value::undefined },
    SameTest -> MatchQ
]

VerificationTest[
    symbol // ClearAll;
    FailWhenUndefined[ symbol, Identity, 3 ],
    symbol // ClearAll;
    FailWhenUndefined[ symbol, Identity, { SubValues, 3 } ]
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Options*)
VerificationTest[
    MyFunction // ClearAll;
    MyFunction[ x_ ] := x + 1;
    FailWhenUndefined[ MyFunction, "Message" -> False ],
    _RuleDelayed,
    SameTest -> MatchQ
]

VerificationTest[
    MyFunction[ 1, 2 ],
    Failure[ "Undefined", _ ],
    { },
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Properties and Relations*)
VerificationTest[
    symbol // ClearAll;
    FailWhenUndefined[ symbol, Identity, { SubValues, 1 } ],
    symbol // ClearAll;
    FailWhenUndefined[ symbol, Identity, DownValues ]
]

VerificationTest[
    symbol // ClearAll;
    FailWhenUndefined[ symbol, Identity, { SubValues, 0 } ],
    symbol // ClearAll;
    FailWhenUndefined[ symbol, Identity, OwnValues ]
]

VerificationTest[
    MyFunction // ClearAll;
    MyFunction[ x_ ] := x + 1;
    expr$: HoldPattern[ MyFunction[ ___ ] ] :=
        Failure[ "MyFailure", <| "Expression" :> expr$ |> ];
    FailWhenUndefined @ MyFunction,
    _RuleDelayed,
    SameTest -> MatchQ
]

VerificationTest[
    MyFunction[ 1, 2 ],
    Failure[ "MyFailure", _ ],
    { },
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    ClearAll[
        AddOne,
        AddTwo,
        Add2,
        Add3,
        $value,
        $condition,
        symbol,
        MyFunction
    ],
    Null
]

VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ
]
