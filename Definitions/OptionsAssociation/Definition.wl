OptionsAssociation // ClearAll;
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
OptionsAssociation::internal = "\
An unexpected error occurred.";

OptionsAssociation::optkey = "\
Invalid option key: `1`;";

OptionsAssociation::symrules = "\
Expected a valid symbol or list of rules instead of `1` at position 1 in `2`.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
OptionsAssociation // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
OptionsAssociation // Options = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$symbol = _Symbol? symbolQ;
$string = _String? stringQ;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
OptionsAssociation /:
    e: HoldPattern @ (sym_Symbol? symbolWithOptionsQ)[
        a___,
        OptionsAssociation[ opts: OptionsPattern[ ] | KeyValuePattern @ { } ]
    ] /; ! TrueQ @ $catching :=
        catchTop @ With[ { assoc = filteredOptions[ sym, opts ] },
            Replace[ assoc, Association[ r___ ] :> sym[ a, r ] ]
        ];


OptionsAssociation[
    symbol_Symbol? validSymbolQ,
    opts: ___? optionPatternQ,
    Association | Automatic
] :=
    catchTop @ optionsAssociation[ symbol, opts ];


OptionsAssociation[
    name_String? validNameQ,
    opts: ___? optionPatternQ,
    type_
] :=
    catchTop @ ToExpression[
        name,
        InputForm,
        Function[
            symbol,
            OptionsAssociation[ symbol, opts, type ],
            { HoldFirst }
        ]
    ];


OptionsAssociation[ sym_? symOrNameQ, opts: ___? optionPatternQ ] :=
    catchTop @ optionsAssociation[ sym, opts ];


OptionsAssociation[
    inv: Except[ _? symOrNameQ | ___? optionPatternQ ],
    a___
] :=
    catchTop @ throwFailure[
        OptionsAssociation::symrules,
        HoldForm @ inv,
        HoldForm @ OptionsAssociation[ inv, a ]
    ];


OptionsAssociation[
    sym_? symOrNameQ,
    opts: ___? optionPatternQ,
    head: Except[ ___? optionPatternQ ]
] :=
    catchTop @ Module[ { assoc },
        assoc = optionsAssociation[ sym, opts ];

        If[ ! AssociationQ @ assoc,
            throwFailure[ OptionsAssociation::internal, assoc ]
        ];

        Replace[ assoc, Association[ a___ ] :> head @ a ]
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error cases*)


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

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
    throwFailure[ MessageName[ OptionsAssociation, tag ], params ];

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
    throwFailure[ OptionsAssociation::internal,
                  $bugReportLink,
                  HoldForm @ eval,
                  a
    ];

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
        "Fragment" -> SymbolName @ OptionsAssociation
    |>
];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Misc utilities*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*symbolWithOptionsQ*)
symbolWithOptionsQ // beginDefinition;

symbolWithOptionsQ[ sym_Symbol? validSymbolQ ] :=
    MatchQ[ Options @ Unevaluated @ sym, { __ } ];

symbolWithOptionsQ[ ___ ] := False;

symbolWithOptionsQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validSymbolQ*)
validSymbolQ // beginDefinition;

validSymbolQ // Attributes = { HoldAllComplete };

validSymbolQ[ sym_Symbol ] :=
    TrueQ[ AtomQ @ Unevaluated @ sym && Unevaluated @ sym =!= Internal`$EFAIL ];

validSymbolQ[ ___ ] := False;

validSymbolQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchTop*)
catchTop // beginDefinition;

catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] :=
    Block[ { $catching = True, catchTop = Slot[ 1 ] & }, Catch[ eval, $top ] ];

catchTop // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*filteredOptions*)
filteredOptions // beginDefinition;

filteredOptions // Attributes = { HoldFirst };

filteredOptions[ symbol_Symbol, opts: ___? optionPatternQ ] :=
    Module[ { full, rules, assoc },
        full = Options @ Unevaluated @ symbol;
        rules = FilterRules[ Reverse @ toListOfRules @ opts, full ];
        assoc = Association @ rules;
        KeySort @ KeyMap[ optionString, assoc ]
    ];

filteredOptions // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*optionPatternQ*)
optionPatternQ // beginDefinition;

optionPatternQ // Attributes = { HoldFirst, SequenceHold };

optionPatternQ[ ] := True;

optionPatternQ[ OptionsPattern[ ] ] := True;

optionPatternQ[ a_Association ] := AssociationQ @ Unevaluated @ a;

optionPatternQ[ Alternatives[ Sequence, List ][ a___ ] ] :=
    AllTrue[ HoldComplete @ a, optionPatternQ ];

optionPatternQ[ (Rule | RuleDelayed)[ _, _ ] ] := True;

optionPatternQ[ ___ ] := False;

optionPatternQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toListOfRules*)
toListOfRules // beginDefinition;

toListOfRules[ args___ ] :=
    With[ { rules = Flatten @ { args } },
        Cases[
            Flatten @ Replace[
                rules,
                assoc_Association? AssociationQ :> Normal[ assoc, Association ],
                { 1 }
            ],
            _Rule | _RuleDelayed
        ]
    ];

toListOfRules // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*optionString*)
optionString // beginDefinition;

optionString // Attributes = { HoldAllComplete };

optionString[ symbol_Symbol? validSymbolQ ] :=
    SymbolName @ Unevaluated @ symbol;

optionString[ name_String? validNameQ ] := Last @ StringSplit[ name, "`" ];

optionString[ key_ ] := throwFailure[ "optkey", key ];

optionString // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validNameQ*)
validNameQ // beginDefinition;

validNameQ // Attributes = { HoldAllComplete };

validNameQ[ name_String ] :=
    TrueQ[ StringQ @ Unevaluated @ name && Internal`SymbolNameQ[ name, True ] ];

validNameQ[ ___ ] := False;

validNameQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*optionsAssociation*)
optionsAssociation // beginDefinition;

optionsAssociation // Attributes = { HoldFirst };

optionsAssociation[ symbol_Symbol, opts: ___? optionPatternQ ] :=
    Module[ { rules1, rules2, assoc1, assoc2 },
        rules1 = Options @ Unevaluated @ symbol;
        rules2 = FilterRules[ Reverse @ toListOfRules @ opts, rules1 ];
        assoc1 = KeyMap[ optionString, Association @ rules1 ];
        assoc2 = KeyMap[ optionString, Association @ rules2 ];
        KeySort @ Join[ assoc1, assoc2 ]
    ];

optionsAssociation // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*symOrNameQ*)
symOrNameQ // beginDefinition;

symOrNameQ // Attributes = { HoldAllComplete };

symOrNameQ[ _Symbol? validSymbolQ ] := True;

symOrNameQ[ _String? validNameQ ] := True;

symOrNameQ[ ___ ] := False;

symOrNameQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*optionsPattern*)
optionsPattern // beginDefinition;

optionsPattern[ ] := ___? optionPatternQ;

optionsPattern // endDefinition;