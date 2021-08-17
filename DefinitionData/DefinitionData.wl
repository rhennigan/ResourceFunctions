(* ::Package:: *)
DefinitionData // ClearAll;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
DefinitionData // Attributes = { HoldFirst };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Messages*)
DefinitionData::unknown = "`1` is not a known DefinitionData property.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main Definition*)
DefinitionData[ symbol_Symbol? symbolQ ] :=
    Module[ { def, defData, name, data },

        def     = minimalFullDefinition @ symbol;
        defData = definitionRules @ def;
        name    = fullSymbolName @ symbol;
        data    = <| "Name" -> name, "Definitions" -> defData |>;

        DefinitionData @ Evaluate @ data
    ];

(* For <+ResourceFunction+>, get the definition of the underlying symbol: *)
DefinitionData[ rf_ResourceFunction ] := (
    ResourceFunction[ rf, "Function" ];
    ToExpression[ ResourceFunction[ rf, "SymbolName" ],
                  InputForm,
                  DefinitionData
    ]
);

(* Standardize association arguments: *)
DefinitionData[ a_Association /; ! AssociationQ @ Unevaluated @ a ] :=
    With[ { b = a }, DefinitionData @ b /; AssociationQ @ b ];

DefinitionData[ info: KeyValuePattern[ "Definitions" -> bytes_ByteArray ] ] :=
    With[ { new = Append[ info, "Definitions" -> BinaryDeserialize @ bytes ] },
        DefinitionData @ new /; AssociationQ @ new
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Properties*)
DefinitionData[ info_Association ][ property_ ] :=
    getProperty[ info, property ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getProperty*)
getProperty // ClearAll;

getProperty[ KeyValuePattern[ prop_ -> val_ ], prop_ ] := val;
getProperty[ info_, "Properties" ] := $properties;
getProperty[ info_, "ObjectType" ] := "DefinitionData";
getProperty[ info_, "Symbols"    ] := getSymbolsProperty @ info;
getProperty[ info_, "Names"      ] := getNamesProperty @ info;
getProperty[ info_, "Size"       ] := getSizeProperty @ info;
getProperty[ info_, "Contexts"   ] := getContextsProperty @ info;
getProperty[ info_, props_List   ] := getProperties[ info, props ];
getProperty[ info_ ][ prop_      ] := getProperty[ info, prop ];


getProperty[ info_, p_ ] := (
    ResourceFunction[ "ResourceFunctionMessage" ][ DefinitionData::unknown, p ];
    Failure[ "InvalidProperty",
             <|
                 "MessageTemplate"   :> DefinitionData::unknown,
                 "MessageParameters" -> { HoldForm @ p }
             |>
    ]
);

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$properties*)
$properties // ClearAll;

$properties =
    {
        "Name",
        "ObjectType",
        "Definitions",
        "Names",
        "Symbols",
        "Size",
        "Contexts",
        "DefinitionList"
    };

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getProperties*)
getProperties // ClearAll;
getProperties[ info_, props_ ] := AssociationMap[ getProperty @ info, props ];
getProperties[ ___ ] := $Failed; (* TODO: better failures *)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getSymbolsProperty*)
getSymbolsProperty // ClearAll;

getSymbolsProperty[ KeyValuePattern[ "Definitions" -> defs_Association ] ] :=
    ToExpression[ Keys @ defs, InputForm, HoldForm ];

getSymbolsProperty[ ___ ] := $Failed; (* TODO: better failures *)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getNamesProperty*)
getNamesProperty // ClearAll;

getNamesProperty[ KeyValuePattern[ "Definitions" -> defs_Association ] ] :=
    Keys @ defs;

getNamesProperty[ ___ ] := $Failed; (* TODO: better failures *)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getSizeProperty*)
getSizeProperty // ClearAll;

getSizeProperty[ KeyValuePattern[ "Definitions" -> defs_Association ] ] :=
    bytesToQuantity @ ByteCount @ defs;

getSizeProperty[ ___ ] := $Failed; (* TODO: better failures *)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getContextsProperty*)
getContextsProperty // ClearAll;

getContextsProperty[ KeyValuePattern[ "Definitions" -> defs_Association ] ] :=
    Union @ Map[
        StringJoin[ StringRiffle[ Most @ #, "`" ], "`" ] &,
        StringSplit[ Keys @ defs, "`" ]
    ];

getContextsProperty[ ___ ] := $Failed; (* TODO: better failures *)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getDefinitionListProperty*)
getDefinitionListProperty // ClearAll;

getDefinitionListProperty[ info_Association ] :=
    toDefinitionList @ DefinitionData @ info;

getDefinitionListProperty[ ___ ] := $Failed; (* TODO: better failures *)

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Loading definitions*)
DefinitionData /: HoldPattern @
Get @ DefinitionData[ info: KeyValuePattern @ {
    "Name"        -> name_,
    "Definitions" -> _Association
} ] :=
    With[ { defs = toDefinitionList @ DefinitionData @ info },
        Language`ExtendedFullDefinition[ ] = defs; Symbol @ name
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Information*)
DefinitionData /:
HoldPattern @ Information[ data: DefinitionData[ _Association ] ] :=
    InformationData @ AssociationMap[ data, $infoProperties ];

DefinitionData /:
Information`OpenerViewQ[ DefinitionData, "Names"|"Contexts" ] := True;

DefinitionData /: HoldPattern @
Information`GetInformationSubset[ d_DefinitionData, p_List ] := d @ p;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$infoProperties*)
$infoProperties := $infoProperties =
    DeleteCases[ $properties, "DefinitionList"|"Definitions"|"Symbols" ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Formatting*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Boxes*)
DefinitionData /:
MakeBoxes[
    DefinitionData[ info: KeyValuePattern @ {
        "Name"        -> name_,
        "Definitions" -> definitions_Association
    } ],
    fmt_
] :=
    Module[ { packed, contextList, shown, hidden, head, panel, box },

        packed      = serializeDefinitions @ info;
        contextList = summaryContextList[ definitions, fmt ];
        shown       = summaryVisibleRows[ name, definitions, fmt ];
        hidden      = summaryHiddenRows[ contextList, definitions, fmt ];
        head        = $symbolBoxes;
        panel       = summaryPanel[ shown, hidden, fmt ];
        box         = RowBox @ { head, "[", panel, "]" };

        summaryInterpretation[ box, packed ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$resourceFunction*)
$resourceFunction // ClearAll;

$resourceFunction := $resourceFunction =
    StringStartsQ[ Context @ DefinitionData, "FunctionRepository`" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$symbolBoxes*)
$symbolBoxes // ClearAll;

$symbolBoxes := $symbolBoxes =
    If[ $resourceFunction,
        First @ FunctionResource`MakeResourceFunctionBoxes[ "DefinitionData" ],
        "DefinitionData"
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*summaryInterpretation*)
summaryInterpretation // ClearAll;

summaryInterpretation[ box_, packed_ ] :=
    InterpretationBox[
        box,
        ResourceFunction[ "DefinitionData" ][ packed ],
        Editable           -> False,
        Selectable         -> False,
        SelectWithContents -> True
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*summaryContextList*)
summaryContextList // ClearAll;

summaryContextList[ definitions_, fmt_ ] :=
    KeyValueMap[
        BoxForm`MakeSummaryItem[ { StringJoin[ #1, ": " ], #2 }, fmt ] &,
        Counts @ Map[
            StringJoin[ StringRiffle[ Most[ # ], "`" ], "`" ] &,
            StringSplit[ Keys @ definitions, "`" ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*summaryVisibleRows*)
summaryVisibleRows // ClearAll;

summaryVisibleRows[ name_, definitions_, fmt_ ] := {
    { BoxForm`MakeSummaryItem[ { "Name: "   , name                 }, fmt ] },
    { BoxForm`MakeSummaryItem[ { "Symbols: ", Length @ definitions }, fmt ] }
};

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*summaryHiddenRows*)
summaryHiddenRows // ClearAll;

summaryHiddenRows[ contextList_, definitions_, fmt_ ] :=
    Module[ { size, count, contexts },

        size     = bytesToQuantity @ ByteCount @ definitions;
        count    = Length @ contextList;
        contexts = OpenerView[ { count, Column @ contextList }, False ];

        {
            { BoxForm`MakeSummaryItem[ { "Size: "    , size     }, fmt ] },
            { BoxForm`MakeSummaryItem[ { "Contexts: ", contexts }, fmt ] }
        }
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*bytesToQuantity*)
bytesToQuantity // ClearAll;

bytesToQuantity := bytesToQuantity =
    ResourceFunction[ "BytesToQuantity", "Function" ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*summaryPanel*)
summaryPanel // ClearAll;

summaryPanel[ shown_, hidden_, fmt_ ] :=
    FirstCase[
        BoxForm`ArrangeSummaryBox[
            "DefinitionData",
            Null,
            $icon,
            shown,
            hidden,
            fmt
        ],
        DynamicModuleBox[ _, TemplateBox[ _, "SummaryPanel" ], ___ ],
        "\[Ellipsis]",
        Infinity
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$icon*)
$icon // ClearAll;

$icon := $icon =
    Module[ { label },

        label = RowBox @ { RowBox @ { "f", "[", "x_", "]" }, ":=", "\"\"" };

        Framed[ Style[ RawBoxes @ label,
                       "Input",
                       FontColor      -> GrayLevel[ 0.25 ],
                       FontFamily     -> "Source Sans Pro",
                       FontSize       -> 12,
                       ShowAutoStyles -> True
                ],
                Background     -> GrayLevel[ 0.95 ],
                FrameMargins   -> { { 2, 2 }, { 4, 3 } },
                RoundingRadius -> 3
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*InputForm*)
DefinitionData /: Format[
    DefinitionData[ info: KeyValuePattern[ "Definitions" -> _Association ] ],
    InputForm
] /; $resourceFunction :=
    With[ { packed = serializeDefinitions @ info },
        OutputForm @ ToString[
            Unevaluated @ ResourceFunction[ "DefinitionData" ][ packed ],
            InputForm
        ]
    ];

DefinitionData /: Format[
    DefinitionData[ info: KeyValuePattern[ "Definitions" -> _Association ] ],
    InputForm
] :=
    With[ { packed = serializeDefinitions @ info },
        OutputForm @ ToString[ Unevaluated @ DefinitionData @ packed, InputForm ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*serializeDefinitions*)
serializeDefinitions // ClearAll;

serializeDefinitions[
    info: KeyValuePattern[ "Definitions" -> defs_Association ]
] :=
    Module[ { bytes },
        bytes = serializeWithContext[ defs, PerformanceGoal -> "Size" ];
        Append[ info, "Definitions" -> bytes ]
    ];

serializeDefinitions[ info: KeyValuePattern[ "Definitions" -> _ByteArray ] ] :=
    info;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*serializeWithContext*)
serializeWithContext // ClearAll;

serializeWithContext[ expr_, opts___ ] :=
    withContext @ BinarySerialize[ Unevaluated @ expr, opts ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*definitionRules*)
definitionRules // ClearAll;

definitionRules[ def_ ] :=
    Association @ Cases[
        def,
        HoldPattern[ HoldForm[ sym_ ] -> { defs___ } ] :>
            (fullSymbolName @ sym -> Association @ defs)
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toDefinitionList*)
toDefinitionList // ClearAll;

toDefinitionList[ DefinitionData[ info_Association ] ] :=
    toDefinitionList @ info;

toDefinitionList[ info_Association ] :=
    toDefinitionList[ info, Lookup[ info, "Definitions" ] ];

toDefinitionList[ _Association, definitions_Association ] :=
    Language`DefinitionList @@ KeyValueMap[ definitionRule, definitions ];

toDefinitionList[ ___ ] := $Failed; (* TODO: better failures *)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*definitionRule*)
definitionRule // ClearAll;

definitionRule[ name_String, defs_Association ] :=
    ToExpression[ name, InputForm, HoldForm ] -> Normal[ defs, Association ];

definitionRule[ ___ ] := $Failed; (* TODO: better failures *)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*minimalFullDefinition*)
minimalFullDefinition // ClearAll;
minimalFullDefinition := defUtilSymbol[ "MinimalFullDefinition" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fullSymbolName*)
fullSymbolName // ClearAll;
fullSymbolName := defUtilSymbol[ "FullSymbolName" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*withContext*)
withContext // ClearAll;
withContext := defUtilSymbol[ "WithContext" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*symbolQ*)
symbolQ // ClearAll;
symbolQ := defUtilSymbol[ "SymbolQ" ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*defUtilSymbol*)
defUtilSymbol // ClearAll;

defUtilSymbol[ name_String ] :=
    Module[ { ctx, full },
        ctx  = "ResourceSystemClient`DefinitionUtilities`";
        full = StringJoin[ ctx, name ];
        Block[ { $ContextPath }, Quiet[ Needs @ ctx, General::shdw ]; ];
        If[ NameQ @ full, Symbol @ full, $Failed & ] (* TODO: better failure *)
    ];
