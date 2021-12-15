CreateResourceFunctionSymbols // ClearAll;
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
CreateResourceFunctionSymbols::internal =
"An unexpected error occurred. `1`";

CreateResourceFunctionSymbols::pctx =
"Cannot set definitions in protected context `1`.";

CreateResourceFunctionSymbols::invctx =
"Valid context string expected at position `1` in `2`.";

CreateResourceFunctionSymbols::invnames =
"String or list of strings expected at position `1` in `2`.";

CreateResourceFunctionSymbols::loadfail =
"Failed to retrieve definitions for the resource function `1`.";

CreateResourceFunctionSymbols::locked =
"Cannot set definitions for locked symbol `1`.";

CreateResourceFunctionSymbols::symname =
"Cannot get SymbolName of `1`.";

CreateResourceFunctionSymbols::symctx =
"Cannot get Context of `1`.";

CreateResourceFunctionSymbols::deffail =
"Failed to set definitions for `1`.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
CreateResourceFunctionSymbols // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
CreateResourceFunctionSymbols // Options = { OverwriteTarget -> False };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$validContext  = Automatic | _String? validContextQ;
$contextString = _String? contextQ;
$anyContext    = Automatic | $contextString;
$name          = _String? StringQ;
$names         = { $name... };
$nameOrNames   = $name | $names;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
CreateResourceFunctionSymbols[ opts: OptionsPattern[ ] ] :=
    catchTop @ CreateResourceFunctionSymbols[ Automatic, opts ];


CreateResourceFunctionSymbols[
    ctx: $validContext,
    opts: OptionsPattern[ ]
] :=
    catchTop @ CreateResourceFunctionSymbols[
        ctx,
        getResourceFunctionNames[ ],
        opts
    ];


CreateResourceFunctionSymbols[
    ctx0: $validContext,
    names: $nameOrNames,
    opts: OptionsPattern[ ]
] := catchTop @ Enclose[
    Module[ { ctx, base, full, overwrite, current, res },
        ctx       = Replace[ ctx0, Automatic -> $defaultContext ];
        base      = Flatten @ { names };
        full      = (ctx <> #1 &) /@ base;
        overwrite = TrueQ @ OptionValue @ OverwriteTarget;
        current   = If[ overwrite, { }, definedNamePatt @ full ];

        res       = Block[ { $existingNames = current },
                           ConfirmMatch[ defineRFSymbols @ full,
                                         { (_String|_Missing)... }
                           ]
                    ];

        If[ StringQ @ names,
            ConfirmMatch[ First[ res, $Failed ], _String|_Missing ],
            res
        ]
    ],
    throwInternalFailure[
        CreateResourceFunctionSymbols[ ctx0, names, opts ],
        ##
    ] &
];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error cases*)

(* Trying to define symbols in an internal context: *)
CreateResourceFunctionSymbols[ context: $contextString, ___ ] :=
    catchTop @ throwFailure[ "pctx", context ];

(* First argument is not a valid context: *)
CreateResourceFunctionSymbols[ a: Except[ $anyContext ], b___ ] :=
    catchTop @ throwFailure[
        "invctx",
        1,
        HoldForm @ CreateResourceFunctionSymbols[ a, b ]
    ];

(* Second argument is not a valid list of names: *)
CreateResourceFunctionSymbols[
    a: $anyContext,
    b: Except[ $nameOrNames ],
    c___
] :=
    catchTop @ throwFailure[
        "invnames",
        2,
        HoldForm @ CreateResourceFunctionSymbols[ a, b, c ]
    ];

(* Wrong number of arguments: *)
CreateResourceFunctionSymbols[ a_, b_, c: Except[ OptionsPattern[ ] ], d___ ] :=
    catchTop @ throwFailure[
        "nonopt",
        c,
        2,
        HoldForm @ CreateResourceFunctionSymbols[ a, b, c, d ]
    ];

(* Missed something that needs to be fixed: *)
CreateResourceFunctionSymbols[ a___ ] :=
    catchTop @ throwInternalFailure @ CreateResourceFunctionSymbols @ a;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

ClearAll[ $defaultContext, $existingNames, $wfrNames, $localNames ];

$defaultContext := "RF`";
$existingNames  := { };
$wfrNames       := publicResourceInformation[ "Names" ][ "Function" ];
$localNames     := Replace[ FunctionResource`Autocomplete`Private`$localNames,
                            Except[ { ___String } ] -> { }
                   ];


$emptyDefPattern // ClearAll;
$emptyDefPattern =
    Block[ { x },
        ReplaceAll[
            Language`ExtendedDefinition[ x, "ExcludedContexts" -> { } ],
            x -> _
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Misc utilities*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*definedNamePatt*)
definedNamePatt // beginDefinition;

definedNamePatt[ names: { ___String } ] :=
    Apply[
        Alternatives,
        ToExpression[ Select[ names, definedNameQ ], InputForm, HoldPattern ]
    ];

definedNamePatt // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*defineRFSymbols*)
defineRFSymbols // beginDefinition;

defineRFSymbols[ fullNames_ ] :=
    Quiet[ ToExpression[ fullNames, InputForm, defineRFSymbol ],
           General::shdw
    ];

defineRFSymbols // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*qualifiedNames*)
qualifiedNames // beginDefinition;

qualifiedNames[ args___ ] :=
    With[ { ctx = "$" <> StringDelete[ CreateUUID[ ], "-" ] <> "`" },
        Block[ { $Context = ctx, $ContextPath = { ctx } }, Names @ args ]
    ];

qualifiedNames // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*definedNameQ*)
definedNameQ // beginDefinition;

definedNameQ[ name_String? NameQ ] :=
    Or[ Attributes @ name =!= { },
        ! MatchQ[
              Language`ExtendedDefinition[ name, "ExcludedContexts" -> { } ],
              $emptyDefPattern
          ]
    ];

definedNameQ[ ___ ] := False;

definedNameQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validContextQ*)
validContextQ // beginDefinition;
validContextQ[ c_? contextQ ] := ! StringStartsQ[ c, $excludedContexts ];
validContextQ[ ___ ] := False;
validContextQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$excludedContexts*)
$excludedContexts // ClearAll;
$excludedContexts :=
    Block[ { $ContextPath },
        Needs[ "ResourceSystemClient`DefinitionUtilities`" ];
        $excludedContexts =
            FirstCase[
                {
                    ResourceSystemClient`DefinitionUtilities`Private`$defaultExcludedContexts,
                    Language`$InternalContexts
                },
                { __String },
                throwInternalFailure @ $excludedContexts
            ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*symbolNameQ*)
symbolNameQ // beginDefinition;
symbolNameQ[ name_String? StringQ ] := Internal`SymbolNameQ[ name, True ];
symbolNameQ[ ___ ] := False;
symbolNameQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*contextQ*)
contextQ // beginDefinition;
contextQ[ c_String? StringQ ] := Internal`SymbolNameQ[ c<>"x", True ];
contextQ[ ___ ] := False;
contextQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*defineRFSymbol*)
defineRFSymbol // beginDefinition;
defineRFSymbol // Attributes = { HoldFirst };

defineRFSymbol[ s_Symbol ] /; MatchQ[ Unevaluated @ s, $existingNames ] :=
    Missing[ "SymbolExists",
             Context @ Unevaluated @ s <> SymbolName @ Unevaluated @ s
    ];

defineRFSymbol[ s_Symbol ] /; MemberQ[ Attributes @ s, Locked ] :=
    messageFailure[ CreateResourceFunctionSymbols::locked, HoldForm @ s ];

defineRFSymbol[ s_Symbol ] := Enclose[
    defineRFSymbol[ s, ConfirmBy[ SymbolName @ Unevaluated @ s, StringQ ] ],
    messageFailure[ CreateResourceFunctionSymbols::symname, HoldForm @ s ] &
];

defineRFSymbol[ s_Symbol, n_String ] := Enclose[
    defineRFSymbol[ s, n, ConfirmBy[ Context @ Unevaluated @ s, StringQ ] ],
    messageFailure[ CreateResourceFunctionSymbols::symctx, HoldForm @ s ] &
];

defineRFSymbol[ s_Symbol, n_String, c_String ] := (

    s // Unprotect;
    s // ClearAll;

    s := With[ { f = ResourceFunction[ n, "Function" ] },
                If[ FailureQ @ f,
                    ResourceFunction[ "MessageFailure" ][
                        CreateResourceFunctionSymbols::loadfail,
                        n
                    ],
                    s = f
                ]
            ];

    If[ FreeQ[ OwnValues @ s, CreateResourceFunctionSymbols ],
        messageFailure[ CreateResourceFunctionSymbols::deffail, HoldForm @ s ],
        c <> n
    ]
);

defineRFSymbol // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getResourceFunctionNames*)
getResourceFunctionNames // beginDefinition;

getResourceFunctionNames[ ] :=
    Replace[ Quiet @ Union[ $wfrNames, $localNames ],
             Except[ { __String } ] :> throwFailure[ "names" ]
    ];

getResourceFunctionNames // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*publicResourceInformation*)
publicResourceInformation // ClearAll;

publicResourceInformation :=
    Block[ { $ContextPath },
        Needs[ "ResourceSystemClient`" ];
        publicResourceInformation =
            ResourceSystemClient`Private`publicResourceInformation
    ];

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
    throwFailure[ MessageName[ CreateResourceFunctionSymbols, tag ], params ];

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
    throwFailure[
        CreateResourceFunctionSymbols::internal,
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
        "Fragment" -> SymbolName @ CreateResourceFunctionSymbols
    |>
];