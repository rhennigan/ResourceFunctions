ASTPattern // ClearAll;
(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
Needs[ "CodeParser`" ];
Language`AddInternalContexts[ "CodeParser`*" ];

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
ASTPattern::internal =
"An unexpected error occurred. `1`";

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes*)
ASTPattern // Attributes = { HoldFirst };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Options*)
ASTPattern // Options = { };

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Main definition*)
ASTPattern[ patt_ ] :=
    catchTop @ Block[ { $ContextPath },
        Needs[ "CodeParser`" ];
        With[ { p = astBlockPattern @ patt },
            checkDuplicatePatterns @ astPattern @ p
        ]
    ];

ASTPattern[ patt_, meta_ ] :=
    catchTop @ Block[ { $ContextPath },
        Needs[ "CodeParser`" ];
        With[ { p = astBlockPattern @ patt }, astPattern[ p, meta ] ]
    ];


astPattern  // ClearAll;
astPattern  // Attributes = { HoldAllComplete };
$astPattern // Attributes = { HoldAllComplete };

astPattern[ patt_ ] /; ! FreeQ[ Unevaluated @ patt, _ASTPattern ] :=
    Module[ { held, expanded, new },
        held     = HoldComplete @ patt;
        expanded = expandNestedASTPatterns @ held;
        new      = astPattern @@ expanded;
        new /. $astPattern[ a_ ] :> a
    ];

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Auxiliary Functions*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*FromAST*)
FromAST // beginDefinition;

FromAST[ ast_ ] := FromAST[ ast, ##1 & ];

FromAST[ ast: _LeafNode|_CallNode, wrapper_ ] :=
    ToExpression[ ToFullFormString @ ast, InputForm, wrapper ];

FromAST[ ContainerNode[ _, ast_List, _ ], wrapper_ ] :=
    FromAST[ ast, wrapper ];

FromAST[ ast_List, wrapper_ ] := FromAST[ #, wrapper ] & /@ ast;

FromAST // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ASTPatternTest*)
ASTPatternTest // ClearAll;

ASTPatternTest[ func_ ][ node_ ] := FromAST[ node, func ];

ASTPatternTest /: MakeBoxes[ ASTPatternTest[ f_ ], StandardForm ] :=
    With[
        {
            row = MakeBoxes[ f, StandardForm ],
            tt = MakeBoxes[ HoldForm[ ASTPatternTest ][ f ], StandardForm ],
            col = ColorData[ 97 ][ 1 ]
        },
        InterpretationBox[
            FrameBox[
                TooltipBox[ row, tt ],
                RoundingRadius -> 3,
                FrameStyle     -> col,
                FrameMargins   -> { { 4, 4 }, { 1, 1 } }
            ]
            ,
            ASTPatternTest @ f
        ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ASTCondition*)
ASTCondition // beginDefinition;
ASTCondition // Attributes = { HoldRest };

ASTCondition[ vals_List, cond_ ] :=
    Module[ { rules, replaced },
        rules    = MapIndexed[ astCVRule, vals ];
        replaced = HoldComplete @ cond /. rules;
        ReleaseHold[ replaced /. $conditionHold[ e_ ] :> e ]
    ];

ASTCondition /: MakeBoxes[ ASTCondition[ vals_List, cond_ ], StandardForm ] :=
    Module[ { rules, replaced },
        rules = MapIndexed[ astCVBoxRule, vals ];
        replaced = HoldComplete @ cond /. rules;
        Replace[
            replaced /. $conditionHold[ e_ ] :> e,
            HoldComplete[ e_ ] :>
                With[
                    {
                        box =
                            MakeBoxes[
                                Tooltip[
                                    e,
                                    HoldForm[ ASTCondition ][ vals, cond ]
                                ],
                                StandardForm
                            ],
                        col = ColorData[ 97 ][ 2 ]
                    },
                    InterpretationBox[
                        FrameBox[
                            box,
                            RoundingRadius -> 3,
                            FrameStyle     -> col,
                            FrameMargins   -> { { 4, 4 }, { 1, 1 } }
                        ],
                        ASTCondition[ vals, cond ]
                    ]
                ]
        ]
    ];

ASTCondition // endDefinition;

$conditionHold // Attributes = { HoldAllComplete };

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*astCVBoxRule*)
astCVBoxRule // beginDefinition;
astCVBoxRule // Attributes = { HoldFirst };

astCVBoxRule[ node_, { pos_ } ] :=
    ASTConditionValue @ pos -> node;

astCVBoxRule // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*astCVRule*)
astCVRule // beginDefinition;

astCVRule[ node_, { pos_ } ] :=
    ASTConditionValue @ pos -> FromAST[ node, $conditionHold ];

astCVRule // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*EquivalentNodeQ*)
EquivalentNodeQ // beginDefinition;

EquivalentNodeQ[ nodes___ ] :=
    SameQ @@ DeleteCases[ { nodes }, KeyValuePattern[ Source -> _ ], Infinity ];

EquivalentNodeQ /: MakeBoxes[ EquivalentNodeQ[ a___ ], StandardForm ] :=
    With[
        {
            row =
                RowBox @ Riffle[
                    Cases[
                        HoldComplete @ a,
                        e_ :> MakeBoxes[ e, StandardForm ]
                    ],
                    StyleBox[
                        "\[TildeEqual]",
                        FontColor -> Orange,
                        FontWeight -> "Heavy"
                    ]
                ],
            tt = ToBoxes @ HoldForm @ HoldForm[ EquivalentNodeQ ][ a ],
            col = ColorData[ 97 ][ 3 ]
        },
        InterpretationBox[
            FrameBox[
                TooltipBox[ row, tt ],
                RoundingRadius -> 3,
                FrameStyle -> col,
                FrameMargins -> { { 4, 4 }, { 1, 1 } }
            ]
            ,
            EquivalentNodeQ @ a
        ]
    ];

EquivalentNodeQ // endDefinition;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Error cases*)

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Pattern*)
astPattern[ Verbatim[ Pattern ][ sym_Symbol? symbolQ, patt_ ] ] :=
    Pattern @@ Hold[ sym, astPattern @ patt ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Special patterns*)
astPattern[ patt_ASTPattern  ] := patt;
astPattern[ patt_$astPattern ] := patt;

astPattern[ Verbatim[ Verbatim     ][ a_   ] ] := verbatimAST @ a;
astPattern[ Verbatim[ HoldPattern  ][ a_   ] ] := astPattern @ a;
astPattern[ Verbatim[ Alternatives ][ a___ ] ] :=
    Alternatives @@ (astPattern /@ HoldComplete @ a);

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*verbatimAST*)
verbatimAST // beginDefinition;
verbatimAST // Attributes = { HoldAllComplete };

verbatimAST[ sym_Symbol? symbolQ ] := symNamePatt @ sym;
verbatimAST[ r_Rational ] /; AtomQ @ Unevaluated @ r := rationalPattern @ r;
verbatimAST[ c_Complex  ] /; AtomQ @ Unevaluated @ c := complexPattern  @ c;

verbatimAST[ expr: _Integer|_Real|_String ] /; AtomQ @ Unevaluated @ expr :=
    leafNode[ Head @ expr, ToString[ expr, InputForm ] ];

verbatimAST[ head_[ args___ ] ] :=
    CallNode[ astPattern @ head, astPattern /@ Unevaluated @ { args }, _ ];

verbatimAST // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Blanks*)
astPattern[ Verbatim[ _   ] ] := callOrLeafNode[ ];
astPattern[ Verbatim[ __  ] ] := callOrLeafNode[ ]..;
astPattern[ Verbatim[ ___ ] ] := callOrLeafNode[ ]...;

astPattern[ Verbatim[ Blank             ][ sym_? symbolQ ] ] := blank @ sym;
astPattern[ Verbatim[ BlankSequence     ][ sym_? symbolQ ] ] := blank @ sym..;
astPattern[ Verbatim[ BlankNullSequence ][ sym_? symbolQ ] ] := blank @ sym...;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*blank*)
blank // beginDefinition;
blank // Attributes = { HoldAllComplete };
blank[ sym_? leafHeadQ ] := callOrLeafNode[ sym | symNamePatt @ sym, _, _ ];
blank[ sym_ ] := callNode @ symNamePatt @ sym;
blank // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*leafNode*)
leafNode // beginDefinition;
leafNode[            ] := LeafNode[ _, _, _ ];
leafNode[ a_         ] := LeafNode[ a, _, _ ];
leafNode[ a_, b_     ] := LeafNode[ a, b, _ ];
leafNode[ a_, b_, c_ ] := LeafNode[ a, b, c ];
leafNode // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*callNode*)
callNode // beginDefinition;
callNode[            ] := CallNode[ _, _, _ ];
callNode[ a_         ] := CallNode[ a, _, _ ];
callNode[ a_, b_     ] := CallNode[ a, b, _ ];
callNode[ a_, b_, c_ ] := CallNode[ a, b, c ];
callNode // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*callOrLeafNode*)
callOrLeafNode // beginDefinition;
callOrLeafNode[            ] := (CallNode|LeafNode)[ _, _, _ ];
callOrLeafNode[ a_         ] := (CallNode|LeafNode)[ a, _, _ ];
callOrLeafNode[ a_, b_     ] := (CallNode|LeafNode)[ a, b, _ ];
callOrLeafNode[ a_, b_, c_ ] := (CallNode|LeafNode)[ a, b, c ];
callOrLeafNode // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*leafHeadQ*)
leafHeadQ // ClearAll;
leafHeadQ // Attributes = { HoldAllComplete };
leafHeadQ[ Complex|Integer|Rational|Real|String|Symbol ] := True;
leafHeadQ[ ___ ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Repeated*)
astPattern[ Verbatim[ Repeated ][ x_, a___ ] ] :=
    Repeated[ astPattern @ x, a ];

astPattern[ Verbatim[ RepeatedNull ][ x_, a___ ] ] :=
    RepeatedNull[ astPattern @ x, a ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Except*)
astPattern[ Verbatim[ Except ][ c_ ] ] :=
    Except @ astPattern @ c;

astPattern[ Verbatim[ Except ][ c_, p_ ] ] :=
    Except[ astPattern @ c, astPattern @ p ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Sequence Patterns*)
astPattern[ Verbatim[ PatternSequence ][ a___ ] ] :=
    PatternSequence @@ (astPattern /@ HoldComplete @ a);

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*PatternTest*)
astPattern[ Verbatim[ PatternTest ][
    Verbatim[ Pattern ][ s_Symbol? symbolQ, patt_ ],
    test_
] ] :=
    With[ { p = astPattern @ PatternTest[ patt, test ] },
        Pattern @@ HoldComplete[ s, p ]
    ];

astPattern[
    Verbatim[ PatternTest ][
        Verbatim[ Blank ][ head_? symbolQ ],
        test_
    ] ] /; leafTestQ[ head, test ] :=
    leafNode @ head;

astPattern[
    Verbatim[ PatternTest ][
        Verbatim[ BlankSequence ][ head_? symbolQ ],
        test_
    ]
] /; leafTestQ[ head, test ] :=
    leafNode @ head..;

astPattern[
    Verbatim[ PatternTest ][
        Verbatim[ BlankNullSequence ][ head_? symbolQ ],
        test_
    ]
] /; leafTestQ[ head, test ] :=
    leafNode @ head...;

astPattern[ Verbatim[ PatternTest ][ patt_, test_ ] ] :=
    With[ { p = astPattern @ patt },
        PatternTest @@ HoldComplete[ p, ASTPatternTest @ test ]
    ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*leafTestQ*)
leafTestQ // ClearAll;
leafTestQ // Attributes = { HoldAllComplete };

leafTestQ[ Integer, IntegerQ     ] := True;
leafTestQ[ Real, Developer`RealQ ] := True;
leafTestQ[ String, StringQ       ] := True;
leafTestQ[ _? leafHeadQ, AtomQ   ] := True;
leafTestQ[ ___                   ] := False;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Atoms*)
astPattern[ sym_Symbol? symbolQ ] := symNamePatt @ sym;
astPattern[ r_Rational ] /; AtomQ @ Unevaluated @ r := rationalPattern @ r;
astPattern[ c_Complex  ] /; AtomQ @ Unevaluated @ c := complexPattern  @ c;

astPattern[ expr: _Integer|_Real|_String ] /; AtomQ @ Unevaluated @ expr :=
    leafNode[ Head @ expr, ToString[ expr, InputForm ] ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*rationalPattern*)
rationalPattern // beginDefinition;

rationalPattern[ r_ ] := rationalPattern[ Numerator @ r, Denominator @ r ];

rationalPattern[ n_, d_ ] :=
    Module[ { na, da, mo, pw },
        na = astPattern @ n;
        da = astPattern @ d;
        mo = leafNode[ Integer, "-1" ];
        pw = callNode[ symbolNode[ "Power" ], { da, mo } ];
        callNode[ symbolNode[ "Times" ], { na, pw } ]
    ];

rationalPattern // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*complexPattern*)
complexPattern // beginDefinition;

complexPattern[ c_ ] := complexPattern[ Re @ c, Im @ c ];

complexPattern[ r_, i_ ] :=
    Module[ { ra, ia, im },
        ra = astPattern @ r;
        ia = astPattern @ i;
        im = callNode[ symbolNode[ "Times" ], { ia, symbolNode[ "I" ] } ];
        callNode[ symbolNode[ "Plus" ], { ra, im } ]
    ];

complexPattern // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Condition*)
astPattern[ Verbatim[ Condition ][ patt_, test_ ] ] :=
    makeASTCondition[ patt, test ] /.
        $ASTCondition[ { }, cond_ ] :> cond  /.
            $ASTCondition -> ASTCondition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeASTCondition*)
makeASTCondition // beginDefinition;

makeASTCondition // Attributes = { HoldAll };

makeASTCondition[ lhs_, rhs_ ] :=
    Module[ { syms, bound, vals, hs, cvRules, cv },

        syms    = DeleteDuplicates @ patternSymbols @ lhs;
        bound   = Select[ syms, appearsIn @ rhs ];
        vals    = Array[ ASTConditionValue, Length @ bound ];
        hs      = Cases[ bound, e_ :> HoldPattern @ e ];
        cvRules = Thread[ hs -> vals ];
        cv      = HoldComplete @ rhs /. cvRules;

        Condition @@ Replace[
            { bound, cv },
            { HoldComplete[ s___ ], HoldComplete[ c_ ] } :> {
                checkDuplicatePatterns @ astPattern @ lhs,
                $ASTCondition[ { s }, c ]
            }
        ]
    ];

makeASTCondition // endDefinition;

$ASTCondition // Attributes = { HoldAllComplete };

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*appearsIn*)
appearsIn // beginDefinition;
appearsIn // Attributes = { HoldFirst };

appearsIn[ rhs_ ] :=
    Function[ s, ! FreeQ[ Unevaluated @ rhs, HoldPattern @ s ], HoldFirst ];

appearsIn // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*patternSymbols*)
patternSymbols // beginDefinition;
patternSymbols // Attributes = { HoldFirst };
patternSymbols[ patt_ ] := Flatten[ HoldComplete @@ patternSymbols0 @ patt ];
patternSymbols // endDefinition;

patternSymbols0 // beginDefinition;
patternSymbols0 // Attributes = { HoldFirst };
patternSymbols0[ patt_ ] :=
    Cases[ HoldComplete @ patt,
           Verbatim[ Pattern ][ s_Symbol? symbolQ, _ ] :> HoldComplete @ s,
           Infinity,
           Heads -> True
    ];
patternSymbols0 // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*astConditionRule*)
astConditionRule // beginDefinition;
astConditionRule // Attributes = { HoldAllComplete };

astConditionRule[ x_ ] :=
    HoldPattern @ x :> RuleCondition[ FromAST[ x, $ConditionHold ], True ];

astConditionRule // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*astConditionPattern*)
astConditionPattern // beginDefinition;

astConditionPattern // Attributes = { HoldRest };

astConditionPattern[ lhs_, rhs_ ] :=
    With[ { rules = rhsConditionRules @ lhs },
        Condition @@ HoldComplete[ lhs, Unevaluated @ rhs /. rules ] /.
            $conditionRules[ r___ ] :> Flatten @ { r }
    ];

astConditionPattern // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*rhsConditionRules*)
rhsConditionRules // beginDefinition;

rhsConditionRules[ lhs_ ] :=
    Flatten[ $conditionRules @@ Cases[
        HoldComplete @ lhs,
        Verbatim[ Pattern ][ s_Symbol? symbolQ, _ ] :>
            $conditionRules @ Cases[
                HoldComplete @ s,
                e_ :> HoldPattern @ e :>
                    RuleCondition[ FromAST[ e, $ConditionHold ], True ]
            ],
        Infinity,
        Heads -> True
    ] ];

rhsConditionRules // endDefinition;

$conditionRules // Attributes = { HoldAllComplete };

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Normal expressions*)
astPattern[ head_[ args___ ] ] :=
    CallNode[ astPattern @ head, astPattern /@ Unevaluated @ { args }, _ ];

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Two argument form*)
astPattern[ patt_, meta_ ] :=
    insertMetaPatt[ checkDuplicatePatterns @ astPattern @ patt, meta ];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*insertMetaPatt*)
insertMetaPatt // beginDefinition;

insertMetaPatt[ (h: CallNode|LeafNode)[ a_, b_, _ ], meta_ ] :=
    h[ a, b, meta ];

insertMetaPatt[ (h: Verbatim[ CallNode|LeafNode ])[ a_, b_, _ ], meta_ ] :=
    h[ a, b, meta ];

insertMetaPatt[ Verbatim[ Pattern ][ s_, p_ ], meta_ ] :=
    With[ { ins = insertMetaPatt[ p, meta ] },
        Pattern @@ Hold[ s, ins ]
    ];

insertMetaPatt[ patt_Alternatives, meta_ ] :=
    insertMetaPatt[ #1, meta ] & /@ patt;

insertMetaPatt[ Verbatim[ Condition ][ lhs_, rhs_ ], meta_ ] :=
    With[ { ins = insertMetaPatt[ lhs, meta ] },
        Condition @@ Hold[ ins, rhs ]
    ];

insertMetaPatt // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Undefined*)
astPattern[ a___ ] := throwInternalFailure @ astPattern @ a;

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Misc Utilities*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkDuplicatePatterns*)
checkDuplicatePatterns // beginDefinition;

checkDuplicatePatterns[ p_ ] :=
    Module[ { names, realDups, possibleDups, dups },

        names =
            Cases[ p, Verbatim[ Pattern ][ s_, _ ] :> HoldPattern @ s, Infinity ];

        realDups = Select[ Counts @ names, GreaterThan[ 1 ] ];

        possibleDups = Association @ Cases[
            p,
            (Repeated | RepeatedNull)[ a_, ___ ] :>
                Cases[
                    HoldComplete @ a,
                    Verbatim[ Pattern ][ s_, _ ] :> (HoldPattern @ s -> Infinity),
                    Infinity
                ],
            Infinity
        ];

        dups = KeyDrop[ Join[ realDups, possibleDups ], HoldPattern @ e ];
        If[ TrueQ[ Length @ dups > 0 ], rebindConditionPattern[ p, dups ], p ]
    ];

checkDuplicatePatterns // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*rebindConditionPattern*)
rebindConditionPattern // beginDefinition;

rebindConditionPattern[ p_, dups_ ] :=
    Module[
        {
            $replacements, unseen, patt, replaced, conditions, flat,
            rhsHeld, lhsHeld
        },

        $replacements = <| |>;
        unseen        = AssociationMap[ True &, HoldComplete @@@ Keys @ dups ];
        patt          = Alternatives @@ Keys @ dups;

        replaced =
            ReplaceAll[
                p,
                {
                    s: patt /; unseen[ HoldComplete @ s ] :>
                        With[ { e = Null },
                            unseen[ HoldComplete @ s ] = False;
                            $replacements[ HoldComplete[ s ] ] = HoldComplete @ s;
                            s /; True
                        ],
                    s: patt /; ! unseen[ HoldComplete @ s ] :>
                        With[ { a = newPattSym @ s },
                            $replacements[ HoldComplete[ a ] ] = HoldComplete @ s;
                            a /; True
                        ]
                }
            ];

        conditions =
            Cases[
                GroupBy[ Normal @ $replacements, Last -> First ],
                { syms__ } :>
                    Replace[
                        Flatten @ HoldComplete @ syms,
                        HoldComplete[ a___ ] :>
                            HoldComplete @ EquivalentNodeQ @ a
                    ]
            ];

        flat = Flatten[ HoldComplete @@ conditions ];

        rhsHeld = Replace[ flat, HoldComplete[ a_, b__ ] :> HoldComplete[ a && b ] ];

        lhsHeld = HoldComplete @@ { replaced };
        Condition @@ Flatten[ HoldComplete @@ { lhsHeld, rhsHeld } ]
    ];

rebindConditionPattern // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*newPattSym*)
newPattSym // beginDefinition;
newPattSym // Attributes = { HoldAllComplete };
newPattSym[ s_? symbolQ ] := Module @@ HoldComplete[ { s }, s ];
newPattSym // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*symbolNode*)
symbolNode // beginDefinition;
symbolNode[ name_String   ] := LeafNode[ Symbol, name, _ ];
symbolNode[ sym_? symbolQ ] := symNamePatt @ sym;
symbolNode // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*symNamePatt*)
symNamePatt // beginDefinition;

symNamePatt // Attributes = { HoldAllComplete };

symNamePatt[ sym_Symbol? symbolQ ] :=
    With[
        {
            name = SymbolName @ Unevaluated @ sym,
            ctx  = Context @ Unevaluated @ sym
        },
        LeafNode[ Symbol, name | ctx <> name, _ ]
    ];

symNamePatt // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*expandNestedASTPatterns*)
expandNestedASTPatterns // beginDefinition;

expandNestedASTPatterns[ expr_ ] :=
    ReplaceAll[
        expandNestedResourceFunctions @ expr,
        {
            Verbatim[ Verbatim ][ a___ ] :> Verbatim @ a,
            HoldPattern @ ASTPattern[ a___ ] :>
                With[ { p = astPattern @ a }, $astPattern @ p /; True ]
        }
    ];

expandNestedASTPatterns // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*expandNestedResourceFunctions*)
expandNestedResourceFunctions // beginDefinition;

expandNestedResourceFunctions[ expr_ ] /; $rfTest :=
    ReplaceAll[
        expr,
        rf: $rfPatt :>
            With[ { sym = rfSymExpand @ rf }, sym /; sym === ASTPattern ]
    ];

expandNestedResourceFunctions[ expr_ ] := expr;

expandNestedResourceFunctions // endDefinition;


$rfTest := $rfTest =
    StringStartsQ[ Context @ ASTPattern, "FunctionRepository`" ];


rfSymExpand // Attributes = { HoldFirst };
rfSymExpand[ rf_ ] := rfSymExpand[ rf ] =
    Quiet @ ResourceFunction[ rf, "Function" ];

$rfNamePatt = "ASTPattern";
$rfInfoPatt = Association[ ___, "Name" -> "ASTPattern", ___ ];
$rfIDPatt   = $rfNamePatt|$rfInfoPatt;
$roPatt     = HoldPattern[ ResourceObject ][ $rfIDPatt, OptionsPattern[ ] ];

$rfPatt = HoldPattern[ ResourceFunction ][
    $rfIDPatt|$roPatt,
    OptionsPattern[ ]
];

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*astBlockPattern*)
astBlockPattern // beginDefinition;
astBlockPattern // Attributes = { HoldFirst };

astBlockPattern[ patt: Verbatim[ HoldPattern ][ ___ ] ] := patt;

astBlockPattern[ patt_ ] :=
    Block[ { ASTPattern },
        SetAttributes[ ASTPattern, HoldFirst ];
        HoldPattern @ Evaluate @ patt
    ];

astBlockPattern // endDefinition;

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*symbolQ*)
symbolQ // ClearAll;
symbolQ // Attributes = { HoldAllComplete };

symbolQ[ s_Symbol ] :=
    TrueQ @ And[
        AtomQ @ Unevaluated @ s,
        ! Internal`RemovedSymbolQ @ Unevaluated @ s,
        Unevaluated @ s =!= Internal`$EFAIL
    ];

symbolQ[ ___ ] := False;

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
    throwFailure[ MessageName[ ASTPattern, tag ], params ];

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
    throwFailure[ ASTPattern::internal, $bugReportLink, HoldForm @ eval, a ];

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
        "Fragment" -> SymbolName @ ASTPattern
    |>
];