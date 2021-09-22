(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionToken:: *)
EvaluateExcluded[
    Get @ FileNameJoin @ {
        DirectoryName @ $InputFileName,
        "DefinitionData.wl"
    };
    exampleDD = DefinitionData @ <|
        "Name" -> "Global`DefinitionData",
        "Definitions" -> ByteArray["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"]
    |>
];


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Basic Examples*)

(* Get all needed definitions for f, which depends on the function g: *)
g[ x_ ] := x^3;
f[ x_ ] := g[ x^2 ];
data = DefinitionData @ f

(* View information about the definitions: *)
Information[ data ]

(* Using <+Get+> can restore cleared symbols: *)
ClearAll[ f, g ];


f[ 5 ]


Get[ data ]


f[ 5 ]


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Applications*)

(*
    Store definitions from a package as an object that can be stored in
    notebooks:
*)
Get[ "ExampleData/Collatz.m" ];
data = DefinitionData @ Collatz`Collatz

(* View the definitions: *)
data[ "Definitions" ]

Collatz`Collatz // ClearAll;

(* This is now equivalent to loading the original package: *)
Get @ data

(*The definition is loaded:*)
Definition @ Collatz`Collatz

Collatz`Collatz[ 47 ]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Properties and Relations*)

(* Get a list of available properties: *)
EvaluateInPlace[ exampleDD ][ "Properties" ]

(******************************************************************************)

(* See what symbols are contained: *)
EvaluateInPlace[ exampleDD ][ "Names" ]

(******************************************************************************)

(* Use a list of properties to return an <+Association+>: *)
EvaluateInPlace[ exampleDD ][ { "Name", "Size", "Contexts" } ]

(******************************************************************************)

(*
    The <+InputForm+> of <%DefinitionData%> serializes definitions to protect
    contexts and initialization states of values:
*)
EvaluateInPlace[ exampleDD ] // InputForm

(* Use <+FullForm+> to see the actual expression structure: *)
EvaluateInPlace[ exampleDD ] // FullForm

(******************************************************************************)

(*
    When writing DefinitionData to a file as <+InputForm+> via <+Put+>,
    <+CloudPut+>, <+Export+>, etc., original contexts will be preserved in
    binary form:
*)
$Context = "MyContext`";

g1[ x_ ] := x^3;
f1[ x_ ] := g1[ x^2 ];
data = DefinitionData @ f1

Put[ data, "file.wl" ];
FilePrint[ "file.wl" ]

(*
    Changing <+$Context+> or <+$ContextPath+> will not affect which contexts
    the contained symbols are created in:
*)
$Context = "Global`";

Remove[ MyContext`f1, MyContext`f2 ];

Get[ "file.wl" ]

(* Load the definitions: *)
Get @ %

(* The symbols are redefined in their original contexts: *)
MyContext`f1[ 5 ]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Possible Issues*)

(* Some contexts (such as System`) are excluded when including definitions: *)
a := { b, Table };
b := { MyContext`c, CloudObject };
MyContext`c := 1;
DefinitionData @ a

%[ "Names" ]

(* :!CodeAnalysis::EndBlock:: *)