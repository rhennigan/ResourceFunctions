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

CreateResourceFunctionSymbols::exctx =
"Cannot set definitions in excluded context `1`.";

CreateResourceFunctionSymbols::invctx =
"Valid context string expected at position `1` in `2`.";

CreateResourceFunctionSymbols::invname =
"Expected a valid ResourceFunction name instead of `1`.";

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

CreateResourceFunctionSymbols::invexc =
"Expected a list of contexts or Automatic instead of `1` as the setting for ExcludedContexts.";

CreateResourceFunctionSymbols::invow =
"Expected True or False instead of `1` as the setting for OverwriteTarget.";

CreateResourceFunctionSymbols::invunk =
"Expected True or False instead of `1` as the setting for AllowUnknownNames.";

CreateResourceFunctionSymbols::names =
"Failed to retrieve resource function names.";

CreateResourceFunctionSymbols::rsbnames =
"Failed to retrieve resource function names using the ResourceSystemBase `1`.";

CreateResourceFunctionSymbols::unkname =
"`1` is not a known resource function name.";

CreateResourceFunctionSymbols::unknames =
"`1` are not known resource function names.";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
CreateResourceFunctionSymbols // Attributes = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
CreateResourceFunctionSymbols // Options = {
    "AllowUnknownNames" -> True,
    ExcludedContexts    -> Automatic,
    OverwriteTarget     -> False,
    ResourceSystemBase  -> Automatic
};

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument patterns*)
$contextString = _String? contextQ;
$anyContext    = Automatic | $contextString;
$symName       = _String? symbolNameQ;
$name          = _String? rfNameQ;
$names         = { $name... };
$nameOrNames   = $name | $names | Automatic | All;
$failure       = _Failure? FailureQ;
$result        = $symName | Missing[ "SymbolExists", $symName ] | $failure;

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Main definition*)

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Create symbols*)

(* Use <+Automatic+> as default first argument: *)
CreateResourceFunctionSymbols[ opts: OptionsPattern[ ] ] :=
    catchTop @ CreateResourceFunctionSymbols[ Automatic, opts ];

(* Use <+All+> as default second argument: *)
CreateResourceFunctionSymbols[ ctx: $anyContext, opts: OptionsPattern[ ] ] :=
    catchTop @ CreateResourceFunctionSymbols[ ctx, All, opts ];

(* Do the thing: *)
CreateResourceFunctionSymbols[
    ctx0: $anyContext,
    names: $nameOrNames,
    opts: OptionsPattern[ ]
] := catchTop @ Enclose[
    Module[ { ctx, rsbase, unk, base, full, overwrite, excluded, current, res },

        excluded  = OptionValue @ ExcludedContexts;
        ctx       = checkContext[ ctx0, excluded ];
        rsbase    = OptionValue @ ResourceSystemBase;
        unk       = OptionValue @ AllowUnknownNames;
        base      = toNameList[ names, rsbase, unk ];
        full      = (ctx <> #1 &) /@ base;
        overwrite = checkOverwriteTarget @ OptionValue @ OverwriteTarget;
        current   = If[ overwrite, { }, definedNamePatt @ full ];

        res       = Block[ { $existingNames = current },
                           ConfirmMatch[ defineRFSymbols @ full,
                                         { $result... }
                           ]
                    ];

        If[ StringQ @ names,
            ConfirmMatch[ First[ res, $Failed ], $result ],
            res
        ];

        ConfirmMatch[ makeResult @ res, _Success|$failure ]
    ],
    throwInternalFailure[
        CreateResourceFunctionSymbols[ ctx0, names, opts ],
        ##
    ] &
];

(* ::**********************************************************************:: *)
(* ::Subsection:: *)
(*Additional operations*)

(* List created symbols: *)
CreateResourceFunctionSymbols[
    ctx0: $anyContext,
    names: $nameOrNames,
    "List"|List,
    opts: OptionsPattern[ ]
] := catchTop @ Enclose[
    Module[ { ctx, res },
        ctx = checkContext[ ctx0, None ];
        res = listRFSymbols[ ctx, names ];
        ConfirmMatch[ res, { ___String? fullNameQ } ]
    ],
    throwInternalFailure[
        CreateResourceFunctionSymbols[ ctx0, names, opts ],
        ##
    ] &
];


(* Remove created symbols: *)
CreateResourceFunctionSymbols[
    ctx0: $anyContext,
    names: $nameOrNames,
    "Remove"|Remove,
    opts: OptionsPattern[ ]
] := catchTop @ Enclose[
    Module[ { before, removed, after },
        before = CreateResourceFunctionSymbols[ ctx0, names, "List", opts ];
        ConfirmMatch[ before, { ___String? fullNameQ } ];
        removed = Remove @@ before;
        after = CreateResourceFunctionSymbols[ ctx0, names, "List", opts ];
        ConfirmMatch[ after, { ___String? fullNameQ } ];
        If[ after === { },
            Success[
                "CreateResourceFunctionSymbols",
                <|
                    "MessageTemplate"   -> "Removed `1` symbols.",
                    "MessageParameters" -> { Length @ before },
                    "Tag"               -> "CreateResourceFunctionSymbols",
                    "Removed"           -> before,
                    "Failed"            -> after
                |>
            ],
            Failure[
                "CreateResourceFunctionSymbols",
                <|
                    "MessageTemplate"   -> "Failed to remove `1` symbols.",
                    "MessageParameters" -> { Length @ after },
                    "Tag"               -> "CreateResourceFunctionSymbols",
                    "Removed"           -> before,
                    "Failed"            -> after
                |>
            ]
        ]
    ],
    throwInternalFailure[
        CreateResourceFunctionSymbols[ ctx0, names, opts ],
        ##
    ] &
];

(* ::**********************************************************************:: *)
(* ::Section:: *)
(*Error cases*)

(* First argument is not a valid context: *)
e: CreateResourceFunctionSymbols[ Except[ $anyContext ], ___ ] :=
    catchTop @ throwFailure[ "invctx", 1, HoldForm @ e ];

(* Second argument is not a valid list of names: *)
e: CreateResourceFunctionSymbols[ $anyContext, Except[ $nameOrNames ], ___ ] :=
    catchTop @ throwFailure[ "invnames", 2, HoldForm @ e ];

(* Wrong number of arguments: *)
e: CreateResourceFunctionSymbols[ _, _, a: Except[ OptionsPattern[ ] ], ___ ] :=
    catchTop @ throwFailure[ "nonopt", a, 2, HoldForm @ e ];

(* Missed something that needs to be fixed: *)
e: CreateResourceFunctionSymbols[ ___ ] :=
    catchTop @ throwInternalFailure @ e;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

$defaultContext := "RF`";
$existingNames  := { };
$localNames     := getLocalCachedNames[ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Misc utilities*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeResult*)
makeResult // beginDefinition;

makeResult[ res: { ___, $failure, ___ } ] := Enclose[
    Module[ { created, exists, failed, other },

        created = Cases[ res, $symName ];
        exists  = Cases[ res, Missing[ "SymbolExists", $symName ] ];
        failed  = Cases[ res, $failure ];
        other   = Complement[ res, created, exists, failed ];

        ConfirmAssert[ other === { } ];

        Failure[
            "CreateResourceFunctionSymbols",
            <|
                "MessageTemplate"   -> "Failed to create `1` symbols.",
                "MessageParameters" -> { Length @ failed },
                "Created"           -> created,
                "Exists"            -> exists,
                "Failed"            -> failed
            |>
        ]
    ],
    throwInternalFailure[ makeResult @ res, ## ] &
];

makeResult[ res: { $result.. } ] := Enclose[
    Module[ { created, exists, failed, other, createdC, existsC, failedC, msg },

        created = Cases[ res, $symName ];
        exists  = Cases[ res, Missing[ "SymbolExists", $symName ] ];
        failed  = ConfirmMatch[ Cases[ res, $failure ], { } ];
        other   = Complement[ res, created, exists, failed ];

        ConfirmAssert[ other === { } ];

        createdC = Length @ created;
        existsC  = Length @ exists;
        failedC  = Length @ failed;

        msg = ConfirmBy[ successMsg[ createdC, existsC, failedC ], StringQ ];

        Success[
            "CreateResourceFunctionSymbols",
            <|
                "MessageTemplate"   -> msg,
                "MessageParameters" -> { createdC, existsC, failedC },
                "Tag"               -> "CreateResourceFunctionSymbols",
                "Created"           -> created,
                "Exists"            -> exists,
                "Failed"            -> failed
            |>
        ]
    ],
    throwInternalFailure[ makeResult @ res, ##1 ] &
];

makeResult[ { } ] (* TODO *)

makeResult // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*successMsg*)
successMsg // beginDefinition;

successMsg[ cr_Integer? NonNegative, ex_Integer? NonNegative, 0 ] :=
    Module[ { msg1, msg2, msg },

        msg1 = Replace[ cr,
                        {
                            1 -> "Created `1` symbol",
                            _ :> "Created `1` symbols"
                        }
               ];

        msg2 = Replace[ ex,
                        {
                            0 -> "",
                            1 -> "(`2` symbol already exists)",
                            _ :> "(`2` symbols already exist)"
                        }
               ];

        StringTrim[ msg1 <> " " <> msg2 ] <> "."
    ];


successMsg // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*listRFSymbols*)
listRFSymbols // beginDefinition;

listRFSymbols[ ctx_? contextQ, allowed0: $names ] := Enclose[
    Module[ { allowed, names, ov, assoc },
        FirstCase[
            allowed,
            name_String /; StringContainsQ[ name, "`" ] :>
                throwFailure[ "invname", name ]
        ];
        allowed = ConfirmMatch[ ctx <> #& /@ allowed0, { $symName... } ];
        names   = ConfirmMatch[ fullNames[ ctx <> "*" ], { ___String } ];
        names   = ConfirmMatch[ Intersection[ names, allowed ], { ___String } ];
        ov      = ToExpression[ names, InputForm, OwnValues ];
        assoc   = ConfirmBy[ AssociationThread[ names -> ov ], AssociationQ ];
        Keys @ Select[ assoc, rfDefQ ]
    ],
    throwInternalFailure[ listRFSymbols @ ctx, ## ] &
];

listRFSymbols[ ctx_? contextQ, All|Automatic ] :=
    listRFSymbols[ ctx, Last /@ StringSplit[ Names[ ctx <> "*" ], "`" ] ];

listRFSymbols[ ctx_? contextQ, name: $name ] :=
    listRFSymbols[ ctx, { name } ];

listRFSymbols // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fullNames*)
fullNames // beginDefinition;

fullNames[ args___ ] :=
    With[ { ctx = "$" <> StringDelete[ CreateUUID[ ], "-" ] <> "`" },
        Block[ { $Context = ctx, $ContextPath = { ctx } }, Names @ args ]
    ];

fullNames // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fullNameQ*)
fullNameQ // beginDefinition;

fullNameQ[ name_String? NameQ ] :=
    StringMatchQ[ name, Except[ "`" ] ~~ ___ ~~ "`" ~~ ___ ];

fullNameQ[ name_ ] := False;

fullNameQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*rfDefQ*)
rfDefQ // beginDefinition;
rfDefQ[ def_ ] := ! FreeQ[ def, CreateResourceFunctionSymbols ];
rfDefQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkOverwriteTarget*)
checkOverwriteTarget // beginDefinition;
checkOverwriteTarget[ bool: True|False ] := bool;
checkOverwriteTarget[ other_ ] := throwFailure[ "invow", other ];
checkOverwriteTarget // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkContext*)
checkContext // beginDefinition;

checkContext[ Automatic, excl_  ] := checkContext[ $defaultContext, excl ];
checkContext[ ctx_, Automatic   ] := checkContext[ ctx, $defaultExcluded ];
checkContext[ ctx_, None        ] := checkContext[ ctx, { }              ];

checkContext[ ctx_? contextQ, excl: { ___? StringPattern`StringPatternQ } ] :=
    If[ StringMatchQ[ ctx, # <> "*" & /@ StringTrim[ excl, "*" ] ],
        throwFailure[ "exctx", ctx ],
        ctx
    ];

checkContext[ ctx_, excl_? StringPattern`StringPatternQ ] :=
    checkContext[ ctx, { excl } ];

checkContext[ _, other_ ] := throwFailure[ "invexc", other ];

checkContext // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toNameList*)
toNameList // beginDefinition;

toNameList[ _, _, inv: Except[ True|False ] ] := throwFailure[ "invunk", inv ];

toNameList[ All | Automatic, rsb_, _ ] := getResourceFunctionNames @ rsb;

toNameList[ name: $name, rsb_, unk_ ] := toNameList[ { name }, rsb, unk ];

toNameList[ names: { $name... }, rsb_, True ] := names;

toNameList[ names: { $name... }, rsb_, False ] :=
    Module[ { known, unknown },
        known = getResourceFunctionNames @ rsb;
        unknown = Complement[ names, known ];
        Replace[
            unknown,
            {
                { }         :> names,
                { unk_ }    :> throwFailure[ "unkname" , unk ],
                unk: { __ } :> throwFailure[ "unknames", Short @ unk ],
                ___         :> throwInternalFailure @
                                   toNameList[ names, rsb, False ]
            }
        ]
    ];

toNameList // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*definedNamePatt*)
definedNamePatt // beginDefinition;

definedNamePatt[ names: { ___String } ] := Apply[
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
definedNameQ[ name_? NameQ ] := ToExpression[ name, InputForm, definedSymbolQ ];
definedNameQ[ ___ ] := False;
definedNameQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*definedSymbolQ*)
definedSymbolQ // beginDefinition;
definedSymbolQ // Attributes = { HoldAllComplete };
definedSymbolQ[ _Symbol? System`Private`HasAnyEvaluationsQ ] := True;
definedSymbolQ[ _Symbol? System`Private`HasAnyCodesQ       ] := True;
definedSymbolQ[ ___ ] := False;
definedSymbolQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$defaultExcluded*)
$defaultExcluded // ClearAll;
$defaultExcluded :=
    Block[ { $ContextPath },
        Needs[ "ResourceSystemClient`DefinitionUtilities`" ];
        $defaultExcluded =
            FirstCase[
                {
                    ResourceSystemClient`DefinitionUtilities`Private`$defaultExcludedContexts,
                    Language`$InternalContexts
                },
                { __String },
                throwInternalFailure @ $defaultExcluded
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
(*rfNameQ*)
rfNameQ // beginDefinition;
rfNameQ[ name_String? StringQ ] := Internal`SymbolNameQ[ name, False ];
rfNameQ[ ___ ] := False;
rfNameQ // endDefinition;

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

    s := With[ { rf = ResourceFunction[ n ] },
                If[ FailureQ @ rf,
                    ResourceFunction[ "MessageFailure" ][
                        CreateResourceFunctionSymbols::loadfail,
                        n
                    ],
                    s // Clear;
                    s /; (CreateResourceFunctionSymbols; True) =
                        ResourceFunction[ n, "Function" ]
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

getResourceFunctionNames[ rsb_ ] :=
    Replace[ Quiet @ Union[ wfrNames @ rsb, $localNames ],
             Except[ { __String } ] :> throwFailure[ "names" ]
    ];

getResourceFunctionNames // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*wfrNames*)
wfrNames // beginDefinition;

wfrNames[ Automatic ] := wfrNames @ $ResourceSystemBase;

wfrNames[ (URL|CloudObject)[ url_String? StringQ, ___ ] ] := wfrNames @ url;

wfrNames[ rsb_String? StringQ ] := Enclose[
    Module[ { all, names },
        all = ConfirmBy[ publicResourceInformation[ "Names", rsb ],
                         AssociationQ
              ];
        names = ConfirmMatch[ Lookup[ all, "Function" ], { __String } ];
        wfrNames[ rsb ] = names
    ],
    throwFailure[ "rsbnames", rsb ] &
];

wfrNames // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getLocalCachedNames*)
getLocalCachedNames // beginDefinition;

getLocalCachedNames[ ] :=
    getLocalCachedNames[
        FunctionResource`Autocomplete`Private`$resourceFunctionNames,
        FunctionResource`Autocomplete`Private`$publicNames
    ];

getLocalCachedNames[ all_List, public_List ] :=
    Select[ Complement[ all, public ], StringQ ];

getLocalCachedNames[ ___ ] := { };

getLocalCachedNames // endDefinition;

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