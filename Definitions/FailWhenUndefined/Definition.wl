FailWhenUndefined // ClearAll;
(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
$inDef = False;
$debug = True;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*beginDefinition*)
beginDefinition // ClearAll;
beginDefinition // Attributes = { HoldFirst };
beginDefinition::unfinished = "\
Starting definition for `1` without ending the current one.";

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
beginDefinition[ s_Symbol ] /; $debug && $inDef :=
    WithCleanup[
        $inDef = False
        ,
        Print @ TemplateApply[ beginDefinition::unfinished, HoldForm @ s ];
        beginDefinition @ s
        ,
        $inDef = True
    ];
(* :!CodeAnalysis::EndBlock:: *)

beginDefinition[ s_Symbol ] :=
    WithCleanup[ Unprotect @ s; ClearAll @ s, $inDef = True ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*endDefinition*)
endDefinition // beginDefinition;
endDefinition // Attributes = { HoldFirst };

endDefinition[ s_Symbol ] := endDefinition[ s, DownValues ];

endDefinition[ s_Symbol, None ] := $inDef = False;

endDefinition[ s_Symbol, DownValues ] :=
    WithCleanup[
        AppendTo[ DownValues @ s,
                  e: HoldPattern @ s[ ___ ] :>
                      throwInternalFailure @ HoldForm @ e
        ],
        $inDef = False
    ];

endDefinition[ s_Symbol, SubValues  ] :=
    WithCleanup[
        AppendTo[ SubValues @ s,
                  e: HoldPattern @ s[ ___ ][ ___ ] :>
                      throwInternalFailure @ HoldForm @ e
        ],
        $inDef = False
    ];

endDefinition[ s_Symbol, list_List ] :=
    endDefinition[ s, # ] & /@ list;

endDefinition // endDefinition;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Messages*)
FailWhenUndefined::internal =
"An unexpected error occurred. `1`";

FailWhenUndefined::undefined =
"Encountered an undefined pattern for `1`.";

FailWhenUndefined::badsymbol =
"Expected a symbol instead of `1`.";

FailWhenUndefined::badtype =
"`1` is not a supported definition type.";

FailWhenUndefined::badtag =
"Expected a string or symbol instead of `1` as a failure tag.";

FailWhenUndefined::badtemplate =
"Expected a string instead of `1` as a message template.";

FailWhenUndefined::badmessage =
"Expected True or False instead of `1` as the option setting for \"Message\"";

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Attributes*)
FailWhenUndefined // Attributes = { HoldFirst };

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Options*)
FailWhenUndefined // Options = {
    "FailureTag"      -> Automatic,
    "MessageTemplate" -> Automatic,
    "Message"         -> True
};

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)
FailWhenUndefined[ sym_, opts: OptionsPattern[ ] ] :=
    FailWhenUndefined[ sym, Identity, opts ];

FailWhenUndefined[ sym_, func_, opts: OptionsPattern[ ] ] :=
    FailWhenUndefined[ sym, func, DownValues, opts ];

FailWhenUndefined[ sym_, func_, type_, opts: OptionsPattern[ ] ] :=
    catchTop @ Module[ { symbol, template },
        symbol = toSymbol @ sym;

        template =
            OptionValue[
                FailWhenUndefined,
                { opts },
                "MessageTemplate",
                HoldComplete
            ];

        failWhenUndefined[
            symbol,
            toHandlerFunction @ func,
            toDefinitionType @ type,
            toFailureTag @ OptionValue[ "FailureTag" ],
            toMessageTemplate[ symbol, template ],
            toMessageQ @ OptionValue[ "Message" ]
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error cases*)

(* Invalid argument count: *)
FailWhenUndefined[ ] :=
    catchTop @ throwFailure[ "argb", FailWhenUndefined, 0, 1, 3 ];

e: FailWhenUndefined[ s_, f_, t_, o: OptionsPattern[ ], other_, ___ ] :=
    catchTop @ throwFailure[
        "nonopt",
        HoldForm @ other,
        Length @ HoldComplete[ s, f, t, o ],
        HoldForm @ e
    ];

(* Missed something that needs to be fixed: *)
e: FailWhenUndefined[ ___ ] :=
    catchTop @ throwInternalFailure @ e;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*failWhenUndefined*)
failWhenUndefined // beginDefinition;

failWhenUndefined[ sym_, func_, types_List, tag_, template_ ] :=
    failWhenUndefined[ sym, func, #, tag, template ] & /@ types;

failWhenUndefined[
    HoldComplete[ sym_ ],
    func_,
    spec: (type_Symbol | { type_Symbol, _Integer }),
    tag_,
    template_,
    msg_
] :=
    Module[ { defRule, prot },

        defRule =
            makeDefRule[ spec, HoldComplete @ sym, func, tag, template, msg ];


        WithCleanup[
            prot = Unprotect @ sym,
            AppendTo[ type @ sym, defRule ],
            Protect @@ prot
        ];

        defRule
    ];

failWhenUndefined // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeDefRule*)
makeDefRule // beginDefinition;

makeDefRule[
    OwnValues,
    HoldComplete[ sym_ ],
    func_,
    tag_,
    HoldComplete[ template_ ],
    False
] :=
    expr: HoldPattern @ sym :>
        func @ Failure[
            tag,
            <|
                "MessageTemplate"   :> template,
                "MessageParameters" -> { HoldForm @ sym },
                "Type"              -> OwnValues,
                "Symbol"            :> sym,
                "Input"             :> expr
            |>
        ];

makeDefRule[
    DownValues,
    HoldComplete[ sym_ ],
    func_,
    tag_,
    HoldComplete[ template_ ],
    False
] :=
    expr: HoldPattern @ sym[ ___ ] :>
        func @ Failure[
            tag,
            <|
                "MessageTemplate"   :> template,
                "MessageParameters" -> { HoldForm @ sym },
                "Type"              -> DownValues,
                "Symbol"            :> sym,
                "Input"             :> expr
            |>
        ];

makeDefRule[
    { SubValues, n_ },
    HoldComplete[ sym_ ],
    func_,
    tag_,
    HoldComplete[ template_ ],
    False
] :=
    With[ { lhs = makeSubValuesPattern[ sym, n ] },
        expr: lhs :>
            func @ Failure[
                tag,
                <|
                    "MessageTemplate"   :> template,
                    "MessageParameters" -> { HoldForm @ sym },
                    "Type"              -> SubValues,
                    "Symbol"            :> sym,
                    "Input"             :> expr
                |>
            ]
    ];

makeDefRule[ type_, sym_, func_, tag_, template_, True ] :=
    insertMessageFailure @ makeDefRule[ type, sym, func, tag, template, False ];

makeDefRule // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeSubValuesPattern*)
makeSubValuesPattern // beginDefinition;
makeSubValuesPattern // Attributes = { HoldFirst };
makeSubValuesPattern[ s_, n_ ] := makeSubValuesPattern0[ HoldPattern @ s, n ];
makeSubValuesPattern // endDefinition;


makeSubValuesPattern0 // beginDefinition;

makeSubValuesPattern0[ Verbatim[ HoldPattern ][ p_ ], 1 ] :=
    HoldPattern @ p[ ___ ];

makeSubValuesPattern0[ Verbatim[ HoldPattern ][ p_ ], n_ ] :=
    makeSubValuesPattern0[ HoldPattern @ p[ ___ ], n-1 ];

makeSubValuesPattern0 // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertMessageFailure*)
insertMessageFailure // beginDefinition;

insertMessageFailure[
    Verbatim[ RuleDelayed ][ lhs_, func_[ Failure[ tag_, as_ ] ] ]
] := lhs :> func @ ResourceFunction[ "MessageFailure" ][ tag, as ];

insertMessageFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toSymbol*)
toSymbol // beginDefinition;
toSymbol // Attributes = { HoldFirst };
toSymbol[ sym_Symbol? symbolQ ] := HoldComplete @ sym;
toSymbol[ str_String? nameQ ] := ToExpression[ str, InputForm, toSymbol ];
toSymbol[ other_ ] := throwFailure[ "badsymbol", HoldForm @ other ];
toSymbol // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toHandlerFunction*)
toHandlerFunction // beginDefinition;
toHandlerFunction[ Automatic ] := Identity;
toHandlerFunction[ func_ ] := func;
toHandlerFunction // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toDefinitionType*)
toDefinitionType // beginDefinition;

toDefinitionType[ Automatic ] := DownValues;
toDefinitionType[ list_List ] := toDefinitionType /@ list;

toDefinitionType[ 0 ] := OwnValues;
toDefinitionType[ 1 ] := DownValues;
toDefinitionType[ n_Integer? Positive ] := { SubValues, n };

toDefinitionType[ OwnValues |"OwnValues"  ] := OwnValues;
toDefinitionType[ DownValues|"DownValues" ] := DownValues;
toDefinitionType[ SubValues |"SubValues"  ] := { SubValues, 2 };

toDefinitionType[ { SubValues|"SubValues", 0 } ] := OwnValues;
toDefinitionType[ { SubValues|"SubValues", 1 } ] := DownValues;
toDefinitionType[ { SubValues|"SubValues", n_Integer? Positive } ] :=
    { SubValues, n };

toDefinitionType[ other_ ] :=
    throwFailure[ "badtype", HoldForm @ other ];

toDefinitionType // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toFailureTag*)
toFailureTag // beginDefinition;
toFailureTag[ Automatic ] := "Undefined";
toFailureTag[ sym_Symbol? symbolQ ] := sym;
toFailureTag[ tag_String? StringQ ] := tag;
toFailureTag[ other_ ] := throwFailure[ "badtag", HoldForm @ other ];
toFailureTag // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toMessageTemplate*)
toMessageTemplate // beginDefinition;

toMessageTemplate[ HoldComplete[ sym_? symbolQ ], HoldComplete[ Automatic ] ] :=
    Module[ { prot },
        If[ StringQ @ sym::undefined,
            HoldComplete[ FailWhenUndefined::undefined ],

            WithCleanup[
                prot = Unprotect @ sym,
                sym::undefined = FailWhenUndefined::undefined,
                Protect @@ prot
            ];

            If[ StringQ @ sym::undefined,
                HoldComplete[ sym::undefined ],
                HoldComplete[ FailWhenUndefined::undefined ]
            ]
        ]
    ];

toMessageTemplate[ _, HoldComplete[ template_ ] ] :=
    If[ MatchQ[ template, _String? StringQ | _MessageName ],
        HoldComplete @ template,
        throwFailure[ "badtemplate", HoldForm @ template ]
    ];

toMessageTemplate // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toMessageQ*)
toMessageQ // beginDefinition;
toMessageQ[ bool: (True|False) ] := bool;
toMessageQ[ other_ ] := throwFailure[ "badmessage", HoldForm @ other ];
toMessageQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Misc utilities*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*symbolQ*)
symbolQ // ClearAll;
symbolQ // Attributes = { HoldAllComplete };

symbolQ[ s_Symbol ] :=
    And[ AtomQ @ Unevaluated @ s,
         ! Internal`RemovedSymbolQ @ Unevaluated @ s,
         ! MatchQ[ Unevaluated @ s, Internal`$EFAIL ]
    ];

symbolQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*nameQ*)
nameQ // ClearAll;
nameQ[ name_String? StringQ ] := Internal`SymbolNameQ[ name, True ];
nameQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error handling*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchTop*)
catchTop // beginDefinition;
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, $failed = False, catchTop = # & },
        Catch[ eval, $top ]
    ];

catchTop // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwFailure*)
throwFailure // beginDefinition;
throwFailure // Attributes = { HoldFirst };

throwFailure[ tag_String, params___ ] :=
    throwFailure[ MessageName[ FailWhenUndefined, tag ], params ];

throwFailure[ msg_, args___ ] :=
    Module[ { failure },
        failure = messageFailure[ msg, Sequence @@ HoldForm /@ { args } ];
        If[ TrueQ @ $catching,
            Throw[ failure, $top ],
            failure
        ]
    ];

throwFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*messageFailure*)
messageFailure // beginDefinition;
messageFailure // Attributes = { HoldFirst };

messageFailure[ args___ ] :=
    Module[ { quiet },
        quiet = If[ TrueQ @ $failed, Quiet, Identity ];
        WithCleanup[
            quiet @ ResourceFunction[ "MessageFailure" ][ args ],
            $failed = True
        ]
    ];

messageFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*throwInternalFailure*)
throwInternalFailure // beginDefinition;
throwInternalFailure // Attributes = { HoldFirst };

throwInternalFailure[ eval_, a___ ] :=
    throwFailure[ FailWhenUndefined::internal, $bugReportLink, HoldForm @ eval, a ];

throwInternalFailure // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$bugReportLink*)
$bugReportLink := $bugReportLink = Hyperlink[
    "Report this issue \[RightGuillemet]",
    URLBuild @ <|
        "Scheme"   -> "https",
        "Domain"   -> "resources.wolframcloud.com",
        "Path"     -> { "FunctionRepository", "feedback-form" },
        "Fragment" -> SymbolName @ FailWhenUndefined
    |>
];