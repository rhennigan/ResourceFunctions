BeginPackage[ "RH`ReadableForm`" ];


(*
    TODO:

    * fix `Now + -Quantity[12, "Hours"]`
    * check `reqParenQ` to determine if Function should be full form
    * fix excess line break after long Rule|RuleDelayed
    * allow prefix for Slot, e.g. `func @ #`
    * don't line break `func[ x ]` if x is only one or two chars
*)


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Definition*)

ReadableForm // ClearAll;


Begin[ "`Private`" ];


  (* ::********************************************************************:: *)
  (* ::Subsection::Closed:: *)
  (*Options*)

$defaultTokens = <| "Comment" -> CommentToken |>;

ReadableForm // Options = {
    "DynamicAlignment" -> False,
    "FormatHeads"      -> Automatic,
    "IndentSize"       -> 4,
    "InitialIndent"    -> 0,
    "PrefixForm"       -> True,
    "RealAccuracy"     -> Automatic,
    "RelativeWidth"    -> False,
    "StrictMode"       -> False,
    "Tokens"           -> $defaultTokens,
    CachePersistence   -> Automatic,
    CharacterEncoding  -> "Unicode",
    PageWidth          -> 80,
    PerformanceGoal    -> "Quality"
};


  (* ::********************************************************************:: *)
  (* ::Subsection::Closed:: *)
  (*Formatting*)

    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*InputForm*)

ReadableForm /:
    Format[ ReadableForm[ expr_, opts: OptionsPattern[ ] ], InputForm ] :=
        OutputForm @ formatDataString[
            expr,
            OptionValue[ ReadableForm, { opts }, "IndentSize"       ],
            OptionValue[ ReadableForm, { opts }, PageWidth          ],
            OptionValue[ ReadableForm, { opts }, CharacterEncoding  ],
            OptionValue[ ReadableForm, { opts }, "RelativeWidth"    ],
            OptionValue[ ReadableForm, { opts }, "PrefixForm"       ],
            OptionValue[ ReadableForm, { opts }, PerformanceGoal    ],
            OptionValue[ ReadableForm, { opts }, "RealAccuracy"     ],
            OptionValue[ ReadableForm, { opts }, "InitialIndent"    ],
            OptionValue[ ReadableForm, { opts }, CachePersistence   ],
            OptionValue[ ReadableForm, { opts }, "DynamicAlignment" ],
            OptionValue[ ReadableForm, { opts }, "StrictMode"       ],
            OptionValue[ ReadableForm, { opts }, "Tokens"           ]
        ];


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*OutputForm*)

ReadableForm /:
    Format[ ReadableForm[ expr_, opts: OptionsPattern[ ] ], OutputForm ] :=
        formatDataString[
            expr,
            OptionValue[ ReadableForm, { opts }, "IndentSize"       ],
            OptionValue[ ReadableForm, { opts }, PageWidth          ],
            OptionValue[ ReadableForm, { opts }, CharacterEncoding  ],
            OptionValue[ ReadableForm, { opts }, "RelativeWidth"    ],
            OptionValue[ ReadableForm, { opts }, "PrefixForm"       ],
            OptionValue[ ReadableForm, { opts }, PerformanceGoal    ],
            OptionValue[ ReadableForm, { opts }, "RealAccuracy"     ],
            OptionValue[ ReadableForm, { opts }, "InitialIndent"    ],
            OptionValue[ ReadableForm, { opts }, CachePersistence   ],
            OptionValue[ ReadableForm, { opts }, "DynamicAlignment" ],
            OptionValue[ ReadableForm, { opts }, "StrictMode"       ],
            OptionValue[ ReadableForm, { opts }, "Tokens"           ]
        ];


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*StandardForm*)

ReadableForm /:
    MakeBoxes[ ReadableForm[ expr_, opts: OptionsPattern[ ] ], StandardForm ] :=
        Module[
            { boxes, formatNames, fSyms, $$c, n, held, dataString, newBoxes },

            formatNames = Cases[
                Map[
                    ToString,
                    Union @ Flatten @ ReplaceAll[
                        {
                            OptionValue[
                                ReadableForm,
                                { opts },
                                "FormatHeads"
                            ]
                        },
                        Automatic :> $defaultFormatHeads
                    ]
                ],
                _String? NameQ
            ];

            fSyms = Alternatives @@ ToExpression[
                formatNames,
                InputForm,
                Blank
            ];
            n = 1;

            held = ReplaceAll[
                HoldComplete @ expr,
                e: fSyms :>
                    With[ { i = Increment @ n },
                        $$c[ i ] := e;
                        $$c @ i /; True
                    ]
            ];


            dataString = Replace[
                held,
                HoldComplete[ e_ ] :> formatDataString[
                    e,
                    OptionValue[ ReadableForm, { opts }, "IndentSize"       ],
                    OptionValue[ ReadableForm, { opts }, PageWidth          ],
                    OptionValue[ ReadableForm, { opts }, CharacterEncoding  ],
                    OptionValue[ ReadableForm, { opts }, "RelativeWidth"    ],
                    OptionValue[ ReadableForm, { opts }, "PrefixForm"       ],
                    OptionValue[ ReadableForm, { opts }, PerformanceGoal    ],
                    OptionValue[ ReadableForm, { opts }, "RealAccuracy"     ],
                    OptionValue[ ReadableForm, { opts }, "InitialIndent"    ],
                    OptionValue[ ReadableForm, { opts }, CachePersistence   ],
                    OptionValue[ ReadableForm, { opts }, "DynamicAlignment" ],
                    OptionValue[ ReadableForm, { opts }, "StrictMode"       ],
                    OptionValue[ ReadableForm, { opts }, "Tokens"           ]
                ]
            ];


            boxes = StyleBox[
                Replace[ r_List :> RowBox @ r ][
                    UsingFrontEnd @ First @ First @ MathLink`CallFrontEnd @
                        FrontEnd`UndocumentedTestFEParserPacket[
                            dataString,
                            False
                        ]
                ],
                "Input",
                ShowAutoStyles       -> True,
                ShowStringCharacters -> True,
                StripOnInput         -> True
            ];


            newBoxes = ReplaceAll[
                ReplaceAll[
                    boxes,
                    Cases[
                        DownValues @ $$c,
                        HoldPattern[
                            Verbatim[ HoldPattern ][ lhs_$$c ] :> rhs_
                        ] :>
                            MakeBoxes[ lhs, StandardForm ] ->
                                MakeBoxes[ rhs, StandardForm ]
                    ]
                ],
                With[ { s = MakeBoxes[ $$c, StandardForm ] },
                    rb: RowBox @ { s, ___ } :> With[
                        {
                            cexp = ReplaceAll[
                                ToExpression[
                                    rb,
                                    StandardForm,
                                    HoldComplete
                                ],
                                DownValues @ $$c
                            ]
                        },
                        Replace[
                            cexp,
                            HoldComplete[ e_ ] :> makeSpecialBoxes @ e
                        ]
                    ]
                ]
            ];

            Remove @ $$c;

            newBoxes
        ];


  (* ::********************************************************************:: *)
  (* ::Subsection::Closed:: *)
  (*UpValues*)

ReadableForm /:
    HoldPattern[ CopyToClipboard[ data_ReadableForm ] ] :=
        CopyToClipboard @ ToString @ data;


(* ::Subsection:: *)
(*Dependencies*)


(* ::Subsubsection:: *)
(*formatDataString*)


formatDataString // ClearAll;


formatDataString[
    data_,
    indSize_,
    pageWidth_,
    enc_,
    rel_,
    prefix_,
    perf_,
    prec_,
    init_,
    cache_,
    fancy_,
    strict_,
    tokens_
] :=
    Block[
        {
            $NumberMarks    = False,
            $formatEncoding = enc,
            $level          = init,
            $indentSize     = indSize,
            $pageWidth      = pageWidth,
            $relativeWidth  = rel,
            $prefixEnabled  = prefix,
            $fastMode       = perf === "Speed",
            $fCache         = MatchQ[ cache, Full|True ],
            $sCache         = MatchQ[ cache, Full|Automatic|True ],
            $fancyAlign     = TrueQ @ fancy,
            $retry          = TrueQ @ strict
        },

        indent[ ] <> StringTrim @ Apply[
            cFormat,
            replaceTokens[ HoldComplete @ data, tokens ] /. {
                Slot -> $$slot,
                (r_Real)?realQ :> numberForm[r, prec]
            }
        ]
    ];


(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*replaceTokens*)
replaceTokens[ expr_, tokens_Association? AssociationQ ] :=
    ReplaceAll[
        expr,
        Rule @@@ (Values @ Merge[ { tokens, $defaultTokens }, Identity ])
    ];

replaceTokens[ expr_, ___ ] := expr;


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*Macros*)


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*symbolQ*)

symbolQ // ClearAll;
symbolQ // Attributes = { HoldAllComplete };
symbolQ[ sym_Symbol ] := AtomQ @ Unevaluated @ sym;


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*inline*)

inline // ClearAll;
inline // Attributes = { HoldAllComplete };

inline[ x_Symbol? symbolQ, expr_ ] :=
    ReleaseHold[ HoldComplete[ expr ] /. OwnValues @ x ];

inline[ { x_Symbol? symbolQ, xs___ }, expr_ ] :=
    inline[ x, inline[ { xs }, expr ] ];

inline[ { }, expr_ ] := expr;

inline /: HoldPattern[ SetDelayed ][ lhs_, inline[ x_, rhs_ ] ] :=
    inline[ x, SetDelayed[ lhs, rhs ] ];


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*defineLeftOp*)

defineLeftOp // ClearAll;
defineLeftOp[ sym_, op_ ] := (
    format[ e: Verbatim[ sym ][ arg_ ] ] /; fitsOnLineQ @ e :=
        StringJoin[ op, formatArg[ sym, arg ] ]
);


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*defineRightOp*)

defineRightOp // ClearAll;
defineRightOp[ sym_, op_ ] := (
    format[ e: Verbatim[ sym ][ arg_ ] ] /; fitsOnLineQ @ e :=
        StringJoin[ formatArg[ sym, arg ], op ]
);


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*defineBinaryOp*)

defineBinaryOp // ClearAll;
defineBinaryOp[ sym_, op_ ] := (
    format[ e: Verbatim[ sym ][ lhs_, rhs_ ] ] /; fitsOnLineQ @ e :=
        verifyLength[
            StringJoin[ formatLHS[ sym, lhs ], op, formatRHS[ sym, rhs ] ],
            cFormat @ e
        ]
);


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*defineMultiOp*)

defineMultiOp // ClearAll;
defineMultiOp[ sym_, op_ ] := (
    format[ e: Verbatim[ sym ][ first_, rest__ ] ] /; fitsOnLineQ @ e :=
        StringJoin[
            formatArg[ sym, first ],
            op,
            StringRiffle[ formatArgList[ sym, rest ], op ]
        ]
);

    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*cached*)

cached // ClearAll;
cached // Attributes = { HoldAllComplete };

cached[ eval_ ] := With[ { st = $state }, cached[ st, eval ] ];
cached[ state_, eval_ ] := cached[ state, Verbatim @ eval ] = eval;


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*cFormat*)

cFormat // ClearAll;
cFormat // Attributes = { HoldAllComplete };
cFormat[ arg_ ] /; $fCache := cached @ format @ arg;
cFormat[ arg_ ] := format @ arg;


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*$state*)

$state // ClearAll;


$state :=
    {
        $fancyAlign,
        $fastMode,
        $formatEncoding,
        $indentSize,
        $level,
        $pageWidth,
        $prefix,
        $prefixEnabled,
        $relativeWidth,
        $retry
    };


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*withIndent*)

withIndent // ClearAll;
withIndent // Attributes = { HoldAllComplete };
withIndent[ eval_ ] := Internal`WithLocalSettings[ $level++, eval, $level-- ];


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*formatArgLines*)

formatArgLines // ClearAll;
formatArgLines // Attributes = { HoldAllComplete };
formatArgLines[ args___ ] :=
    Cases[ HoldComplete @ args,
           a_ :> StringJoin[ indent[ ], cFormat @ a ]
    ];


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*verifyLength*)

verifyLength // ClearAll;

verifyLength // Attributes = { HoldRest };

verifyLength[ str_, retry_ ] /; $retry := verifyLength[ str, retry, 0 ];

verifyLength[ str_, retry_, n_ ] /; n <= 3 && $retryDepth <= 10 :=
    Module[ { split, max, over, new, newWidth },
        split = StringSplit[ str, "\n" ];
        max = Max[ StringLength /@ split ];
        over = max - currentLineWidth[ ];
        (* Echo[ str, <| "over"->over, "$pageWidth" -> $pageWidth, "n" -> n |> ]; *)
        If[ Positive @ over,
            newWidth = $pageWidth - $indentSize;
            Block[ { $pageWidth = newWidth, $retryDepth = $retryDepth + 1 },
                verifyLength[ retry, retry, n+1 ]
            ],
            str
        ]
    ];

verifyLength[ str_, __ ] := str;


$retryDepth = 0;


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*format*)

format // ClearAll;


format // Attributes = { HoldAllComplete };


format[ numberForm[ r_, a_ ] ] :=
  numberFormString[ r, a ];


format[ ReadableForm[ a___ ] ] :=
  StringReplace[ cFormat @ $ReadableForm @ a,
                 ToString @ $ReadableForm -> "ReadableForm"
  ];


format[ s_String ] :=
  toString @ s;


format[<||>] := "<| |>";
With[ { a = <| |> },
    format[ a ] := "<| |>";
];


format[{}] := "{ }";


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*Symbol Definitions*)

(* ClearAll *)
format[ ClearAll[ s_Symbol? symbolQ ] ] :=
    StringJoin[ toString @ s, " // ClearAll" ];


(* Attributes *)
format[ Attributes[ s_Symbol? symbolQ ] = attrs_ ] :=
    StringJoin[ toString @ s, " // Attributes = ", cFormat @ attrs ];


(* Options *)
format[ Options[ s_Symbol? symbolQ ] = opts_ ] :=
    StringJoin[ toString @ s, " // Options = ", cFormat @ opts ];


(* TagSetDelayed *)
format[ TagSetDelayed[ sym_Symbol, lhs_, rhs_ ] ] :=
    StringJoin[
        "\n",
        indent[ ],
        toString @ sym,
        " /:\n",
        Internal`WithLocalSettings[
            Increment @ $level,
            StringJoin[
                indent[ ],
                formatLHS[ TagSetDelayed, lhs ],
                " := ",
                formatRHS[ SetDelayed, rhs ]
            ],
            Decrement @ $level
        ]
    ];

(* TagSet *)
format[ TagSet[ sym_Symbol, lhs_, rhs_ ] ] :=
    StringJoin[
        "\n",
        indent[ ],
        toString @ sym,
        " /:\n",
        Internal`WithLocalSettings[
            Increment @ $level,
            StringJoin[
                indent[ ],
                formatLHS[ TagSet, lhs ],
                " = ",
                formatRHS[ Set, rhs ]
            ],
            Decrement @ $level
        ]
    ];

      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*Patterns*)

$bHead = (Blank|BlankSequence|BlankNullSequence);
$blank = $bHead[ _Symbol ] | $bHead[ ];


(* Condition *)
format[ Verbatim[ Condition ][ patt_, test_ ] ] /;
    fitsOnLineQ[ patt /; test ] :=
        Module[ { f1, f2 },

            f1 = If[ lhsParenQ[ Condition, patt ],
                     StringJoin[ "(", cFormat @ patt, ")" ],
                     cFormat @ patt
                 ];

            f2 = If[ rhsParenQ[ Condition, test ],
                     StringJoin[ "(", cFormat @ test, ")" ],
                     cFormat @ test
                 ];

            verifyLength[
                StringJoin[ f1, " /; ", f2 ],
                cFormat @ Condition[ patt, test ]
            ]
        ];


format[ Verbatim[ Condition ][ patt_, test_ ] ] :=
    Module[ { p1, p2, f1, f2, full, reflow },

        p1 = lhsParenQ[ Condition, patt ];
        p2 = rhsParenQ[ Condition, test ];
        f1 = If[ p1, StringJoin[ "(", cFormat @ patt, ")" ], cFormat @ patt ];
        f2 = If[ p2, StringJoin[ "(", cFormat @ test, ")" ], cFormat @ test ];

        full = StringJoin[ f1, " /; ", f2 ];

        (* reflow = If[
            stringFitsOnLineQ @ full,
            full,
            StringJoin[
                f1, " /;\n",
                withIndent @ StringJoin[
                    indent[ ],
                    formatRHS[ Condition, test ]
                ]
            ]
        ]; *)

        reflow = full;

        verifyLength[
            reflow,
            cFormat @ Condition[ patt, test ]
        ]
    ];



verifiedLength // ClearAll;
verifiedLength // Attributes = { HoldAllComplete };

verifiedLength /: HoldPattern[ SetDelayed ][ lhs_, verifiedLength[ rhs_ ] ] :=
    e: lhs := verifyLength[ rhs, e ];



(* Pattern *)
format[ Verbatim[ Pattern ][ s_Symbol, p: $blank ] ] :=
    inline[ $blank, StringJoin[ toString @ s, toString @ p ] ];


format[ Verbatim[ Pattern ][ s_Symbol, patt_ ] ] :=
    StringJoin[ toString @ s, ": ", formatRHS[ Pattern, patt ] ];


(* Blank, BlankSequence, and BlankNullSequence *)
format[ p: $blank ] :=
    inline[ $blank, toString @ p ];


(* Repeated *)
format[ Verbatim[ Repeated ][ a_ ] ] :=
    Module[ { str },
        str = formatArg[ Repeated, a ];
        (* https://bugs.wolfram.com/show?number=408503 *)
        If[ StringEndsQ[ str, "_" ],
            StringJoin[ "(", str, ").." ],
            StringJoin[ str, ".." ]
        ]
    ];


(* RepeatedNull *)
format[ Verbatim[ RepeatedNull ][ a_ ] ] :=
    Module[ { str },
        str = formatArg[ RepeatedNull, a ];
        (* https://bugs.wolfram.com/show?number=408503 *)
        If[ StringEndsQ[ str, "_" ],
            StringJoin[ "(", str, ")..." ],
            StringJoin[ str, "..." ]
        ]
    ];


(* PatternTest *)

format[ Verbatim[ PatternTest ][
    p: Verbatim[ Pattern ][ _? symbolQ, $blank ],
    f_? symbolQ
] ] :=
    inline[
        $blank,
        StringJoin[ toString @ p, "? ", toString @ f ]
    ];

format[ Verbatim[ PatternTest ][ p_, f_? symbolQ ] ] :=
    StringJoin[ formatLHS[ PatternTest, p ], "? ", toString @ f ];

format[ Verbatim[ PatternTest ][ p_, f_ ] ] :=
    StringJoin[ formatLHS[ PatternTest, p ], "? (", cFormat @ f, ")" ];


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*Flow Control*)

(*
    TODO:
        WithLocalSettings
        WithCleanup
        Which
        Switch
        Catch/Module
        Enclose/Module
*)

(* TODO: try to generalize this *)
(* Experimental! *)
format[ e: Verbatim[ Set ][ lhs_, If[ a_, b_, c_ ] ] ] /; $fancyAlign :=
    Module[ { before, offset, after, aligned },

        before   = StringJoin[ formatLHS[ Set, lhs ], " = " ];
        offset   = StringLength @ before;
        after    = Block[ { $pageWidth = Max[ 10, $pageWidth - offset - 4 ] }, cFormat @ If[ a, b, c ] ];
        aligned  = tryOffsetAlign[ offset, 4, after ];
        (* joined   = If[ StringQ @ aligned, StringJoin[ before, aligned ], "" ];
        expected = toString @ e;
        success  = equivStringsQ[ joined, expected ]; *)

        (* If[ ! success,
            Message[ tryOffsetAlign::offsetfailure, HoldForm @ e, joined ];
        ]; *)

        verifyLength[ StringJoin[ before, aligned ], cFormat @ e ] /;
            StringQ @ aligned
    ];





tryOffsetAlign::offsetfailure = "Offset alignment failed for `1` -> `2`";

tryOffsetAlign[ _, _, string_String ] /; StringFreeQ[ string, "\n" ] :=
    $Failed;

tryOffsetAlign[ baseOffset_, indentOffset_, string_ ] :=
    Enclose @ Module[ { lines, pad, ind, first, last, mid, align },

        lines = StringSplit[ string, "\n" ];
        pad   = ConstantArray[ " ", baseOffset ];
        ind   = ConstantArray[ " ", ConfirmBy[ baseOffset + indentOffset - $indentSize, NonNegative ] ];
        first = First @ lines;
        last  = Last @ lines;
        mid   = Function[ StringJoin[ ind, # ] ] /@ lines[[ 2;;-2 ]];
        align = AllTrue[ mid, Function[ StringLength[ # ] <= $pageWidth ] ];
        (* align = True; *)
        ConfirmAssert @ align;
        StringTrim[
            StringJoin[ first, "\n", StringRiffle[ mid, "\n" ], "\n", StringJoin[ pad, last ] ],
            "\n"
        ]
    ];


(* If (two arguments) *)
format[ if: If[ a_, b_ ] ] /; fitsOnLineQ @ if :=
    StringJoin[
        "If[ ", cFormat @ a, ", ", cFormat @ b, " ]"
    ];


format[ if: If[ cond_, expr_ ] ] :=
  StringJoin[ (* TODO: insert additional linebreak around comma for multiline *)
      "If[ ", cFormat[cond], ",\n",
      Internal`WithLocalSettings[
          $level++,
          StringJoin[ indent[], cFormat@expr, "\n" ],
          $level--
      ],
      indent[], "]"
  ];


(* If (three arguments) *)
format[ if: If[ a_, b_, c_ ] ] /; fitsOnLineQ @ if :=
    StringJoin[
        "If[ ", cFormat @ a, ", ", cFormat @ b, ", ", cFormat @ c,  " ]"
    ];


format[ if: If[ cond_, then_, else_ ] ] :=
  StringJoin[
      "If[ ", cFormat[cond], ",\n",
      Internal`WithLocalSettings[
          $level++,
          StringJoin[
              indent[], cFormat@then, ",\n",
              indent[], cFormat@else, "\n"
          ],
          $level--
      ],
      indent[], "]"
  ];


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*Scoping Constructs*)


$scopeFunc = Alternatives[
    Block,
    DynamicModule,
    Internal`InheritedBlock,
    Module,
    With
];


(* With, Block, and Module *)
format[ e: (h:$scopeFunc)[ args___ ] ] /; fitsOnLineQ[ e, 2 ] :=
    inline[
        $scopeFunc,
        StringJoin[
            ToString @ h,
            "[ ",
            StringRiffle[ formatArgList[ None, args ], ", " ],
            " ]"
        ]
    ];


format[ (h: $scopeFunc)[ { syms___ }, args__ ] ] :=
    inline[
        $scopeFunc,
        Module[ { symStrings, symLen, symStr, lines },
            $prefix = True;
            symStrings = Riffle[ formatArgList[ None, syms ], ", " ];
            symLen = Total[ StringLength /@ symStrings ];
            symStr = If[ TrueQ[ symLen < currentLineWidth[ ] ],
                        StringJoin[ " { ", symStrings, " }" ],
                        StringJoin[
                            "\n",
                            withIndent @ StringJoin[
                                indent[ ],
                                cFormat @ { syms }
                            ]
                        ]
                    ];

            lines = withIndent @ formatArgLines @ args;

            StringJoin[
                toString[h], "[", symStr, ",\n",
                StringRiffle[ StringTrim[ lines, Longest[ "\n" ..] ], ",\n"],
                "\n", indent[ ], "]"
            ]
        ]
    ];


      (* ::****************************************************************:: *)
      (* ::Subsubsubsection::Closed:: *)
      (*Other*)

(* format[ m: Map[ f_, l_ ] ] /; fitsOnLineQ @ m :=
  Module[ { str, fF, lF, fStr, lStr },
      str  = toString @ Map[ f, l ];
      fF   = cFormat @ f;
      lF   = cFormat @ l;
      fStr = If[ StringStartsQ[ str, "(" ], StringJoin[ "(", fF, ")" ], fF ];
      lStr = If[ StringEndsQ[   str, ")" ], StringJoin[ "(", lF, ")" ], lF ];
      StringJoin[ fStr, " /@ ", lStr ]
  ]; *)

(* TODO: define bin op *)
(* format[ m: Map[ f_, l_ ] ] /; fitsOnLineQ @ m :=
    StringJoin[ formatLHS[ Map, f ], " /@ ", formatRHS[ Map, l ] ]; *)




format[ expr: Function[ e_ ][ a___ ] ] /; fitsOnLineQ[ expr, 8 ] :=
    StringJoin[
        "Function[ ",
        Block[ { $singleSlot = singleSlotQ @ Function[ e ] }, cFormat @ e ],
        " ][ ",
        Riffle[ formatArgList[ None, a ], ", " ],
        " ]"
    ];


format[ expr: Function[ e_ ][ a___ ] ] :=
    StringJoin[
        Block[ { $singleSlot = singleSlotQ @ Function @ e }, cFormat @ Function @ e ],
        "[\n",
        Internal`WithLocalSettings[
            $level++,
            Riffle[
                List @@ Map[
                    Function[Null, StringJoin[indent[], cFormat[#1]], {HoldAllComplete}],
                    HoldComplete @ a
                ],
                ",\n"
            ],
            $level--
        ],
        "\n",
        indent[$level],
        "]"
    ];


singleSlotQ[ func_ ] :=
    FreeQ[ DeleteCases[ HoldComplete @ func,
                        _Function,
                        { 2, Infinity },
                        Heads -> True
           ],
           ($$slot|Slot|SlotSequence)[ Except[ 1 ] ]
    ];


format[ f: Function[ e_ ] ] /; fitsOnLineQ[ f, 8 ] :=
    Block[ { $singleSlot = singleSlotQ @ f },
        StringJoin[ "Function[ ", cFormat @ e, " ]" ]
    ];


format[ f: Function[ e_ ] ] :=
    Block[ { $singleSlot = singleSlotQ @ f },
        StringJoin[
            "Function[\n",
            Internal`WithLocalSettings[
                $level++,
                StringJoin[ indent[], cFormat @ e ],
                $level--
            ],
            "\n",
            indent[$level],
            "]"
        ]
    ];


format[ $key[ k_ ] -> $value[ v_ ] ] := cFormat @ Rule[ k, v ];


format[ $key[ k_ ] -> $delayed[ v_] ] := cFormat @ RuleDelayed[ k, v ];


format[ ($key|$value|$delayed)[ expr_ ] ] := cFormat @ expr;


format[ r: Rule[ a_, b_ ] /; fitsOnLineQ @ r || AtomQ @ Unevaluated @ b ] :=
    StringJoin[
        formatLHS[ Rule, a ],
        " -> ",
        formatRHS[ Rule, b ]
    ];


format[ r: RuleDelayed[ a_, b_ ] /; fitsOnLineQ @ r || AtomQ @ Unevaluated @ b ] :=
    StringJoin[
        formatLHS[ RuleDelayed, a ],
        " :> ",
        formatRHS[ RuleDelayed, b ]
    ];


format[ Rule[ a_, b_ ] ] :=
    StringJoin[
        formatLHS[ Rule, a ],
        " ->\n",
        Internal`WithLocalSettings[
            $level++,
            StringTrim[StringJoin[ indent[], formatRHS[ Rule, b ] ], "\n"],
            $level--
        ],
        "\n"
    ];


format[ RuleDelayed[ a_, b_ ] ] :=
    StringJoin[
        formatLHS[ RuleDelayed, a ],
        " :>\n",
        Internal`WithLocalSettings[
            $level++,
            StringTrim[StringJoin[ indent[], formatRHS[ RuleDelayed, b ] ], "\n"],
            $level--
        ],
        "\n"
    ];


(* format[ NumericArray[ array_List, args___ ] ] :=
  With[ { compressed = Compress @ array },
      format[ NumericArray[ CompressedData @ compressed, args ] ]
  ] /; ArrayQ[ Unevaluated @ array,
               2|3,
               Function[ Null, NumericQ @ Unevaluated @ ##, HoldAllComplete ]
       ]; *)


format[ na_NumericArray? Developer`NumericArrayQHold ] :=
  ToExpression[ ToString[ na, InputForm ],
                InputForm,
                cFormat
  ];


format[ PacletObject[ info_Association ] ] :=
    StringJoin[ "PacletObject[ ", cFormat @ info, " ]" ];


(* format[ r: Set[ a_, b_ ] ] :=
    Module[ { lhs, rhs },
        lhs = Block[ { $prefix = False }, formatLHS[ Set, a ] ];
        rhs = formatRHS[ Set, b ];
        StringJoin[ lhs, " = ", rhs ]
    ]; *)


(* format[ CompoundExpression[ a_, Null ] ] :=
    StringDelete[ cFormat[a], Longest[WhitespaceCharacter...]~~EndOfString ] <> ";";


format[CompoundExpression[a__, b: Except[ Null ], Null]] :=
  StringDelete[ cFormat[CompoundExpression[a, b]], Longest[WhitespaceCharacter...]~~EndOfString ] <> ";"; *)


(* format[ CompoundExpression[ a_, b__, Null ] ] :=
    StringRiffle[ formatArgList[ CompoundExpression, a, b ], "; " ] <> ";"; *)

ceAppend // ClearAll;
ceAppend[ str_ ] :=
    StringJoin[
        StringDelete[ str, Longest[ WhitespaceCharacter... ]~~EndOfString ],
        ";"
    ];



format[ CompoundExpression[ a_, Null ] ] :=
    ceAppend @ formatArg[ CompoundExpression, a ];

format[ CompoundExpression[ a__, b_, Null ] ] :=
    ceAppend @ ceFormat @ CompoundExpression[ a, b ];

format[ CompoundExpression[ a_, b__ ] ] :=
    ceFormat @ CompoundExpression[ a, b ];



ceFormat // ClearAll;
ceFormat // Attributes = { HoldAllComplete };

ceFormat[ ce: CompoundExpression[ a___ ] ] /; fitsOnLineQ @ ce  :=
    StringRiffle[ formatArgList[ CompoundExpression, a ], "; " ];

ceFormat[ CompoundExpression[ a___ ] ] :=
    Module[ { strings, lines },

        strings = StringDelete[
            formatArgList[ CompoundExpression, a ],
            Longest[WhitespaceCharacter...]~~EndOfString
        ];

        lines = Map[
            Function[
                If[ StringFreeQ[ #1, "\n" ],
                    StringJoin[ #1, ";\n", indent[ ] ],
                    StringJoin[ "\n", indent[ ], #1, ";\n\n", indent[ ] ]
                ]
            ],
            Most @ strings
        ];

        StringJoin[ lines, Last @ strings ]
    ];


(* ::**********************************************************************:: *)
(* ::Subsubsubsection::Closed:: *)
(*Misc Operators*)



defineBinaryOp[ AddTo        , " += "  ];
defineBinaryOp[ Apply        , " @@ "  ];
defineBinaryOp[ Apply1       , " @@@ " ];
defineBinaryOp[ ApplyTo      , " //= " ];
defineBinaryOp[ DivideBy     , " /= "  ];
defineBinaryOp[ Greater      , " > "   ];
defineBinaryOp[ GreaterEqual , " >= "  ];
defineBinaryOp[ Less         , " < "   ];
defineBinaryOp[ LessEqual    , " <= "  ];
defineBinaryOp[ Map          , " /@ "  ];
defineBinaryOp[ ReplaceAll   , " /. "  ];
defineBinaryOp[ SubtractFrom , " -= "  ];
defineBinaryOp[ TimesBy      , " *= "  ];
(* defineBinaryOp[ Power      , " ^ "   ]; *)

defineMultiOp[ Alternatives, " | "   ];
defineMultiOp[ And         , " && "  ];
defineMultiOp[ Plus        , " + "   ];
defineMultiOp[ SameQ       , " === " ];
(* defineMultiOp[ Times       , " * "   ]; *)
defineMultiOp[ UnsameQ     , " =!= " ];

defineLeftOp[ Not         , "! " ];
defineLeftOp[ PreDecrement, "--" ];
defineLeftOp[ PreIncrement, "++" ];

defineRightOp[ Decrement, "--" ];
defineRightOp[ Increment, "++" ];


(* TODO: fix `a-b` ending up as `a + -b` on long lines *)
format[ e: Times[ _, Power[ _, -1 ] ] ] /; fitsOnLineQ @ e := toString @ e;
format[ e_Times ] /; fitsOnLineQ @ e := toString @ e;

format[ e: Power[ ___ ] ] /; fitsOnLineQ @ e := toString @ e;


format[ e: Apply[ f_, x_, { 1 } ] ] /;
    ! reqParenQ[ Apply, f ] && ! reqParenQ[ Apply, x ] && fitsOnLineQ @ e :=
        cFormat @ Apply1[ f, x ];

prec @ Apply1 = prec @ Apply;

Apply1 /: Format[ Apply1, InputForm ] := Apply;



(* Slot *)
format[ $$slot[ 1 ] ] /; $singleSlot := "#";

format[ $$slot[ i_Integer ] ] /;
    ! $singleSlot && IntegerQ @ Unevaluated @ i && NonNegative @ i :=
        "#" <> toString @ i;


format[ $$slot[ str_String ] ] /;
    ! $singleSlot && StringQ @ Unevaluated @ str :=
    If[ StringMatchQ[
            str,
            LetterCharacter~~(LetterCharacter | DigitCharacter)...
        ],
        StringJoin[ "#", str ],
        StringJoin[ "#", toString @ str ]
    ];


(* SlotSequence *)
format[ Verbatim[ SlotSequence ][ 1 ] ] /; $singleSlot := "##";

format[ Verbatim[ SlotSequence ][ i_Integer ] ] /;
    ! $singleSlot && IntegerQ @ Unevaluated @ i && NonNegative @ i :=
        "##" <> toString @ i;



format[ e: Rational[ lhs_, rhs_ ] ] /; And[
    fitsOnLineQ @ e,
    AtomQ @ Unevaluated @ e,
    NumericQ @ Unevaluated @ lhs,
    NumericQ @ Unevaluated @ rhs
] :=
    StringJoin[ formatLHS[ Rational, lhs ], " / ", formatRHS[ Rational, rhs ] ];


format[ e: MessageName[ sym_? symbolQ, tag_String ] ] /;
    StringQ @ Unevaluated @ tag && fitsOnLineQ @ e :=
        StringJoin[
            toString @ sym,
            "::",
            If[ StringMatchQ[ tag, (LetterCharacter|DigitCharacter)... ],
                tag,
                toString @ tag
            ]
        ];

(* format[ Not[ expr_ ] ] :=
  "! " <> formatArg[ Not, expr ] /; StringStartsQ[ toString @ Not @ expr, "!"|" !" ]; *)


(* format[ and: And[ a_, b__ ] ] /; fitsOnLineQ @ and :=
    StringRiffle[ formatArgList[ And, a, b ], " && " ];


format[ sameQ: SameQ[ a_, b__ ] ] /; fitsOnLineQ @ sameQ :=
    StringRiffle[ formatArgList[ SameQ, a, b ], " === " ]; *)


format[ e: (f_[ a___ ])[ g_ ] ] /; prefixQ @ f @ a :=
  Module[ { fs, h, fas, gs },
      fs = Block[ { $prefix = False }, formatHead @ f ];
      fas = StringReplace[ Block[ { $prefix = False }, cFormat @ h @ a ], toString @ h -> fs ];
      gs = cFormat @ g;
      StringJoin[ fas, "[ ", gs, " ]" ]
  ];


format[ e: f_[ g_[ args___ ] ] ] /; prefixQ @ e && AtomQ @ Unevaluated @ f :=
  Module[ { full, fs, gs, hs, pform },
      full = Block[ { $prefix = False }, cFormat @ e ];
      If[ stringFitsOnLineQ @ full, Throw[ makePrefix[ e, 0 ], $tag ]];
      fs = cFormat @ f;
      gs = cFormat @ g;
      hs = fs <> " @ " <> gs;
      If[ stringFitsOnLineQ @ hs,
          makePrefix[ e, 0 ],
          If[ stringFitsOnLineQ @ gs,
              makePrefix[ e, 1 ],
              makePrefix[ e, 2 ]
          ]
      ]
  ] ~Catch~ $tag;


format[ e: f_[ x_ ] ] /; prefixQ @ e && AtomQ @ Unevaluated @ f && AtomQ @ Unevaluated @ x :=
  Module[ { full, fs, gs, hs, pform },
      full = Block[ { $prefix = False }, cFormat @ e ];
      If[ stringFitsOnLineQ @ full,
          makePrefix[ e, 0 ],
          makePrefix[ e, 1 ]
      ]
  ] ~Catch~ $tag;


format[ a: f_[ ___ ] ] /; $fastMode :=
  With[{str = toString @ a},
      str /; stringFitsOnLineQ @ str
  ];


format[ r: Verbatim[ Set ][ a_, b_ ] ] :=
    Module[ { fits, g },

        fits  = fitsOnLineQ @ r;
        g = rhsParenQ[ Set, b ];

        StringJoin[
            Block[ { $prefix = False }, formatLHS[ Set, a ] ],
            If[ g,  " = (", " = " ],
            If[ fits,
                cFormat @ b,
                StringJoin[
                    "\n",
                    withIndent @ formatArgLines @ b,
                    If[ g, "\n", "" ]
                ]
            ],
            If[ g,
                ")",
                ""
            ]
        ]
    ];


format[ r: Verbatim[ SetDelayed ][ a_, b_ ] ] :=
    Module[ { fits, g },

        fits  = fitsOnLineQ @ r;
        g = rhsParenQ[ SetDelayed, b ];

        StringJoin[
            Block[ { $prefix = False }, formatLHS[ SetDelayed, a ] ],
            If[ g,  " := (", " := " ],
            If[ fits,
                cFormat @ b,
                StringJoin[
                    "\n",
                    Internal`WithLocalSettings[
                        Increment @ $level,
                        StringJoin[ indent[ ], cFormat @ b ],
                        Decrement @ $level
                    ],
                    "\n"
                ]
            ],
            If[ g,
                ")",
                ""
            ],
            If[ fits,
                "",
                "\n"
            ]
        ]
    ];


format[ r: Verbatim[ UpSetDelayed ][ a_, b_ ] ] :=
    Module[ { fits, g },

        fits  = fitsOnLineQ @ r;
        g = rhsParenQ[ UpSetDelayed, b ];

        StringJoin[
            Block[ { $prefix = False }, formatLHS[ UpSetDelayed, a ] ],
            If[ g,  " ^:= (", " ^:= " ],
            If[ fits,
                cFormat @ b,
                StringJoin[
                    "\n",
                    Internal`WithLocalSettings[
                        Increment @ $level,
                        StringJoin[ indent[ ], cFormat @ b ],
                        Decrement @ $level
                    ],
                    "\n"
                ]
            ],
            If[ g,
                ")",
                ""
            ],
            If[ fits,
                "",
                "\n"
            ]
        ]
    ];


format[assoc_Association /; AssociationQ@Unevaluated@assoc && fitsOnLineQ @ assoc ] :=
    With[ { tagged = tagAssociations @ assoc },
        StringJoin[
            "<| ",
            StringRiffle[ StringTrim[ cFormat /@ Normal[ tagged, Association ], "\n" ], ", " ],
            " |>"
        ]
    ];


(* format[assoc_Association /; AssociationQ@Unevaluated@assoc] :=
  With[ { tagged = Global`tagged = tagAssociations @ assoc },
      Print @ formatAssoc @ tagged;
      StringJoin[ "<|", "\n",
          StringTrim[Internal`WithLocalSettings[
              $level++,
              StringRiffle[StringTrim[Map[StringJoin[indent[], cFormat[#]] &, Normal@tagged], "\n"], ",\n"],
              $level--
          ], "\n"],
          "\n", indent[$level], "|>"
      ]
  ]; *)


(* format[ Association[ rules: (_Rule | _RuleDelayed) .. ] ] :=
  formatAssoc @ ReleaseHold @ Echo @ tagAssociations @ HoldComplete @ { rules }; *)



format[ assoc: Association[ (_Rule | _RuleDelayed) .. ] ] :=
    formatAssoc @ tagAssociations @ unevaluatedAssociation @ assoc;



unevaluatedAssociation // ClearAll;
unevaluatedAssociation // Attributes = { HoldAllComplete };
unevaluatedAssociation[ assoc_ ] :=
    Internal`InheritedBlock[ { Rule, RuleDelayed },
        SetAttributes[ { Rule, RuleDelayed }, HoldAllComplete ];
        assoc
    ];


formatAssoc // ClearAll;

formatAssoc[ tagged_ ] /; $fancyAlign :=
    Module[
        {
            normal, ind, indSize, maxKeySize, maxValSize, limit,
            check, align, checked, aligned
        },

        normal     = Normal[ tagged, Association ];
        ind        = indent[ ];
        indSize    = StringLength @ ind;
        maxKeySize = 0;
        maxValSize = 0;
        limit      = currentLineWidth[ ];

        check[ k_ -> v_ ] :=
            With[ { ks = cFormat @ k, vs = cFormat @ v },

                If[ StringContainsQ[ StringJoin[ ks, vs ], "\n" ],
                    (* Echo[ k -> v, "line" ]; *)
                    Throw[ $noAlign, $tag ]
                ];

                maxKeySize = Max[ maxKeySize, StringLength @ ks ];
                maxValSize = Max[ maxValSize, StringLength @ vs ];

                If[ indSize+$indentSize + maxKeySize + maxValSize + 5 > limit,
                    (* Echo[ k -> v, "length" ]; *)
                    Throw[ $noAlign, $tag ]
                ];

                { indent[ ], ks, If[ Head @ v === $delayed, " :> ", " -> " ], vs }
            ];

        align[ { i_, k_, r_, v_ } ] :=
            StringJoin[
                i,
                StringPadRight[ k, maxKeySize, " " ],
                r,
                v
            ];

        aligned = Catch[
            withIndent @ StringRiffle[ align /@ check /@ normal, ",\n" ],
            $tag
        ];

        StringJoin[
            "<|",
            "\n",
            StringTrim[
                If[ StringQ @ aligned,
                    aligned,
                    withIndent @ StringRiffle[
                        StringTrim[
                            Function[ StringJoin[ indent[ ], cFormat[ # ] ] ] /@ normal,
                            "\n"..
                        ],
                        ",\n"
                    ]
                ],
                "\n"
            ],
            "\n",
            indent @ $level,
            "|>"
        ]
    ];




formatAssoc[ tagged_ ] :=
  StringJoin[
            "<|",
            "\n",
            StringTrim[
                withIndent @ StringRiffle[
                        StringTrim[
                            Function[ StringJoin[ indent[ ], cFormat[ # ] ] ] /@ Normal[ tagged, Association ],
                            "\n"..
                        ],
                        ",\n"
                    ],
                "\n"
            ],
            "\n",
            indent @ $level,
            "|>"
        ];




format[Association[rules : (_Rule | _RuleDelayed) ..] /; fitsOnLineQ @ Association @ rules ] :=
    StringJoin[
        "<| ",
        StringRiffle[ List @@ cFormat /@ HoldComplete[ rules ], ", " ],
        " |>"
    ];


(* format[Association[rules : (_Rule | _RuleDelayed) ..]] :=
  StringJoin[
      "<|",
      "\n",
      StringTrim[Internal`WithLocalSettings[
          $level++,
          StringRiffle[List @@
            Function[Null,
                StringJoin[indent[], cFormat[#]], {HoldAllComplete}] /@
              HoldComplete[rules], ",\n"],
          $level--
      ],"\n"],
      "\n",
      indent[$level],
      "|>"
  ]; *)


format[ list_List ] /; fitsOnLineQ @ list :=
    StringJoin[ "{ ", StringRiffle[ cFormat /@ Unevaluated @ list, ", " ], " }" ];


format[ { items___ } ] /; $fastMode :=
  StringJoin[
      "{", "\n",
      StringTrim[Internal`WithLocalSettings[
          $level++,
          StringRiffle[
              List @@ Map[
                  Function[Null, StringJoin[indent[], cFormat[#1]], {HoldAllComplete}],
                  HoldComplete @ items
              ],
              ",\n"
          ],
          $level--
      ], "\n"],
      "\n",
      indent[$level],
      "}"
  ];


(* format[ { rules: (_Rule | _RuleDelayed).. } ] :=
    StringReplace[
        cFormat @ Association[ rules ],
        {
            StartOfString~~"<|" :> "{",
            "|>"~~EndOfString :> "}"
        }
    ]; *)

format[ rules: { (_Rule|_RuleDelayed).. } ] :=
    Module[ { tagged },
        Internal`InheritedBlock[ { Rule, RuleDelayed },
            SetAttributes[ { Rule, RuleDelayed }, HoldAllComplete ];
            tagged =
                Replace[
                    rules,
                    {
                        Rule[ k_, v_ ] :> $key @ k -> $value @ v,
                        RuleDelayed[ k_, v_ ] :> $key @ k -> $delayed @ v
                    },
                    { 1 }
                ]
        ];
        StringReplace[
            formatAssoc @ tagged,
            {
                StartOfString~~"<|" :> "{",
                "|>"~~EndOfString :> "}"
            }
        ]
    ];


format[ { items___ } ] :=
    Module[ { strings, short },
        strings = List @@ cFormat /@ HoldComplete @ items;
        short = StringJoin[ "{ ", Riffle[ strings, ", " ], " }" ];
        stringFitsOnLineQ @ short;
        If[ stringFitsOnLineQ @ short,
            short,
            StringJoin[
                "{",
                "\n",
                StringTrim[ Internal`WithLocalSettings[
                    Increment @ $level,
                    StringRiffle[
                        Apply[
                            List,
                            Map[
                                Function[
                                    Null,
                                    StringTrim[ StringJoin[ indent[ ], cFormat @ #1 ], "\n"],
                                    { HoldAllComplete }
                                ],
                                HoldComplete @ items
                            ]
                        ],
                        ",\n"
                    ],
                    Decrement @ $level
                ], "\n" ],
                "\n",
                indent @ $level,
                "}"
            ]
        ]
    ];

format[ f_[ args___ ] ] /; ! TrueQ @ $fastMode && fitsOnLineQ @ f @ args :=
    Module[ { h, a },
        $prefix = True;
        h = formatHead @ f;
        a = StringRiffle[ formatArgList[ None, args ], ", " ];
        If[ a === "",
            StringJoin[ h, "[ ]" ],
            StringJoin[ h, "[ ", a, " ]" ]
        ]
    ];


format[ f_[ args___ ] ] /; ! TrueQ @ $fastMode :=
    Module[ { h, lines },
        $prefix = True;
        h = formatHead @ f;
        lines = withIndent @ formatArgLines @ args;
        If[ lines === { },
            StringJoin[ h, "[ ]" ],
            StringJoin[
                h, "[\n",
                StringRiffle[ StringTrim[ lines, Longest[ "\n" ..] ], ",\n"],
                "\n", indent[ ], "]"
            ]
        ]
    ];


format[f_[args___]] /; TrueQ @ $fastMode := StringJoin[
    toString @ f, "[\n",
    Internal`WithLocalSettings[
        $level++,
        Riffle[ List @@ Function[ Null, StringJoin[ indent[ ], cFormat[ #1 ] ], { HoldAllComplete } ] /@ HoldComplete[ args ], ",\n" ],
        $level--
    ],
    "\n", indent[$level], "]"
];


format[other_] := toString @ other;


(* ::Subsubsection:: *)
(*numberForm*)

numberForm // ClearAll;

numberForm /:
    Format[ numberForm[ r_, a_ ], InputForm ] :=
        OutputForm @ numberFormString[ r, a ];


    (* ::******************************************************************:: *)
    (* ::Subsubsection::Closed:: *)
    (*numberFormString*)

numberFormString // ClearAll;


numberFormString[ r_Real, Except[ _Integer? NonNegative ] ] :=
    StringReplace[
        ToString[ r, InputForm ],
        StringExpression[ "SetAccuracy[", d__, ",", ___, "]" ] :>
            ToString[ N @ ToExpression @ d, InputForm ]
    ];


(* numberFormString[ r_Real, a_Integer ] :=
    numberFormString[ RealDigits @ r, a ];


numberFormString[ { digits_, offset_? NonNegative }, a_ ] :=
    Module[ { split, decD, fracD, decS, fracS },

        split = TakeDrop[ digits, offset ];
        decD  = First @ split;
        fracD = Last @ split;
        decS  = IntegerString @ FromDigits @ decD;
        fracS = IntegerString @ FromDigits @ Take[ fracD, UpTo @ a ];

        StringJoin[ decS, ".", fracS ]
    ];


numberFormString[ { digits_, offset_ }, a_ ] :=
    Module[ { padding, take, dStr },

        padding = ConstantArray[ 0, Max[ 0, -offset ] ];
        take    = Take[ Join[ padding, digits ], UpTo @ a ];
        dStr    = StringRiffle[ take, "" ];

        If[ StringMatchQ[ dStr, "0".. ],
            "0.0",
            StringJoin[ "0", StringTrim[ StringJoin[ ".", dStr ], "0".. ] ]
        ]
    ]; *)


numberFormString[ r_Real, a_Integer ] :=
    realToString[ r, a ];

realToString[ r_, m_: 6 ] :=
    StringReplace[
        realToString0[ r, m ],
        StringExpression[ ".", EndOfString ] :> ".0"
    ];

realToString0[ r_, m_ ] :=
    Module[ { id, string },
        id = Ceiling @ RealExponent @ r;
        string = Which[
            id >= m + 3,
                (*ToString[ Round[ r, 10.0^(id - m) ], InputForm ]*)
                sciForm[ r, m, id ]
            ,
            Abs @ r < 10.0^(-(m - 1)),
                "0.0"
            ,
            id > Min[ 6, m ],
                StringJoin[ ToString @ Round @ r, ".0" ]
            ,
            id <= Max[ -5, -m + 1 ],
                ToString @ DecimalForm[ Round[ r, 10.0^(id - m) ], m ]
            ,
            True,
                ToString @ Round[ r, 10.0^(-(m - id)) ]
        ];
        If[ StringContainsQ[ string, "*^" ],
            sciForm[ r, m, id ],
            string
        ]
    ];


sciForm[ r_, m_ ] :=
    sciForm[ r, m, Ceiling @ RealExponent @ r ];

sciForm[ r_, m_, id_ ] :=
    Module[ { mant, exp },
        { mant, exp } = MantissaExponent @ Round[ r, 10.0^(id - m) ];
        StringJoin[ realToString[ mant*10, m ], "*^", ToString[ exp + -1 ] ]
    ];


(* ::Subsubsection:: *)
(*toString*)


toString // ClearAll;


toString // Attributes = { HoldAllComplete };


toString[ $key[ k_ ] -> $value[ v_ ] ] := toString[ k -> v ];


toString[ $key[ k_ ] -> $delayed[ v_ ] ] := toString[ k :> v ];


toString[ ($key|$delayed|$value)[ a_ ] ] := toString @ a;


toString[ expr_ /; ! FreeQ[ HoldComplete @ expr, $key|$delayed|$value ] ] :=
  With[ { untagged = untagAssociations @ HoldComplete @ expr },
      If[ TrueQ @ $sCache,
          (toString[ Verbatim @ expr ] = toString @@ untagged),
          toString @@ untagged
      ] /;
        FreeQ[ HoldComplete @ untagged, $key|$delayed|$value ]
  ];


toString[ expr_ ] /; $sCache := toString[ Verbatim @ expr ] =
    toString0 @ expr;

(* toString[ expr_ ] :=
    If[ TrueQ @ symbolQ @ expr && MemberQ[ Attributes @ expr, Temporary ],
        Global`stack= Stack[_]; Abort[],
        toString0 @ expr
    ]; *)

toString[ expr_ ] := toString0 @ expr;


(* ::Subsubsection:: *)
(*toString0*)

toString0 // ClearAll;

toString0 // Attributes = { HoldAllComplete };


toString0[ expr_ ] :=
    Replace[ HoldComplete[ expr ] /. { $$slot -> Slot },
             HoldComplete[ e_ ] :>
                ToString[ Unevaluated @ e,
                          InputForm,
                          CharacterEncoding -> $formatEncoding
                ]
    ] // StringTrim;


(* ::Subsubsection:: *)
(*$key*)


$key // ClearAll;


$key // Attributes = { HoldAllComplete };


(* ::Subsubsection:: *)
(*$value*)


$value // ClearAll;


$value // Attributes = { HoldAllComplete };


(* ::Subsubsection:: *)
(*$delayed*)


$delayed // ClearAll;


$delayed // Attributes = { HoldAllComplete };


(* ::Subsubsection:: *)
(*untagAssociations*)


untagAssociations // ClearAll;


untagAssociations // Attributes = { HoldAllComplete };


untagAssociations[ expr_ ] :=
  expr //. {
      a: KeyValuePattern[ $key[ k_ ] -> $delayed[ v_ ] ] :>
        RuleCondition @
          KeyDrop[ Insert[ a, Unevaluated[ k :> v ], Key @ $key @ k ],
                   Key @ $key @ k
          ],
      a: KeyValuePattern[ $key[ k_ ] -> $value[ v_ ] ] :>
        RuleCondition @
          KeyDrop[ Insert[ a, Unevaluated[ k -> v ], Key @ $key @ k ],
                   Key @ $key @ k
          ]
  };


(* ::Subsubsection:: *)
(*$formatEncoding*)


$formatEncoding // ClearAll;


$formatEncoding = "Unicode";


(* ::Subsubsection:: *)
(*fitsOnLineQ*)


fitsOnLineQ // ClearAll;


fitsOnLineQ // Attributes = { HoldAllComplete };


fitsOnLineQ[ expr_ ] := stringFitsOnLineQ @ toString @ expr;


fitsOnLineQ[ expr_, offset_ ] := stringFitsOnLineQ[ toString @ expr, offset ];


(* ::Subsubsection:: *)
(*stringFitsOnLineQ*)


stringFitsOnLineQ // ClearAll;


stringFitsOnLineQ[ string_String ] := TrueQ[ StringLength @ string < currentLineWidth[ ] ];


stringFitsOnLineQ[ string_String, offset_ ] := TrueQ[ StringLength @ string < currentLineWidth[ ] - offset ];


stringFitsOnLineQ[ ___ ] := False;


(* ::Subsubsection:: *)
(*currentLineWidth*)


currentLineWidth // ClearAll;


currentLineWidth[ ] :=
  If[ $relativeWidth,
      $pageWidth,
      $pageWidth - $level*$indentSize
  ];


(* ::Subsubsection:: *)
(*$relativeWidth*)


$relativeWidth // ClearAll;


$relativeWidth = False;


(* ::Subsubsection:: *)
(*$pageWidth*)


$pageWidth // ClearAll;


$pageWidth = 80;


(* ::Subsubsection:: *)
(*$level*)


$level // ClearAll;


$level = 0;


(* ::Subsubsection:: *)
(*$indentSize*)


$indentSize // ClearAll;


$indentSize = 4;


(* ::Subsubsection:: *)
(*$assocLeft*)


$assocLeft = HoldPattern @ Alternatives[
    Part,
    Application,
    Divide,
    CircleMinus,
    PlusMinus,
    MinusPlus,
    LeftTee,
    DoubleLeftTee,
    UpTee,
    DownTee,
    Condition,
    ReplaceAll,
    ReplaceRepeated,
    Because
];


(* ::Subsubsection:: *)
(*$assocRight*)


$assocRight = HoldPattern @ Alternatives[
    Map,
    MapAll,
    Apply,
    Power,
    Implies,
    RightTee,
    DoubleRightTee,
    SuchThat,
    TwoWayRule,
    Rule,
    RuleDelayed,
    AddTo,
    SubtractFrom,
    TimesBy,
    DivideBy,
    ApplyTo,
    Therefore,
    Set,
    SetDelayed,
    UpSet,
    UpSetDelayed,
    Function
];


(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*headParenQ*)
headParenQ // ClearAll;
headParenQ // Attributes = { HoldAllComplete };
headParenQ[ sym_[ ___ ] ] := prec @ sym < 660;
headParenQ[ ___  ] := False;



$noFullFormHeads = Alternatives[
    CompoundExpression,
    Condition,
    Optional,
    Pattern
];



formatHead // ClearAll;
formatHead // Attributes = { HoldAllComplete };

formatHead[ s_Symbol? symbolQ ] := toString @ s;

With[ { nf = $noFullFormHeads },
formatHead[ h: nf[ ___ ] ] := StringJoin[ "(", Block[ { $prefix = False }, cFormat @ h ], ")" ];
];

formatHead[ h: f_[ a___ ] ] /; fitsOnLineQ @ h :=
    If[ headParenQ @ h,
        Block[ { $prefix = True }, StringJoin[ "(", cFormat @ h, ")" ] ],
        StringJoin[
            Block[ { $prefix = False }, formatHead @ f ],
            "[ ",
            StringRiffle[ formatArgList[ f, a ], ", " ],
            " ]"
        ]
    ];

formatHead[ h_ ] := Block[ { $prefix = False }, cFormat @ h ];



(* ::Subsubsection:: *)
(*lhsParenQ*)


lhsParenQ // ClearAll;


lhsParenQ // Attributes = { HoldAllComplete };


With[ { la = $assocLeft, ra = $assocRight },
lhsParenQ[ h:la, (h:la)[ ___ ] ] := False;
lhsParenQ[ h:ra, (h:ra)[ ___ ] ] := True;
];


lhsParenQ[ args___ ] := reqParenQ @ args;


(* ::Subsubsection:: *)
(*reqParenQ*)


reqParenQ // ClearAll;


reqParenQ // Attributes = { HoldAllComplete };


reqParenQ[ f_, h_[ ___ ] ] := TrueQ[ prec @ f >= prec @ h ];


reqParenQ[ f_ ] := Function[ e, reqParenQ[ f, e ], HoldAllComplete ];

reqParenQ[ Power, neg_ ] := Internal`SyntacticNegativeQ @ Unevaluated @ neg;

reqParenQ[ _, __ ] := False;


(* ::Subsubsection:: *)
(*prec*)


prec // ClearAll;


prec // Attributes = { HoldAllComplete };

prec[ Function ] = 1000.0;

(* https://bugs.wolfram.com/show?number=408557 *)
prec[ TagSetDelayed ] = 100.0; (* wtf? *)

prec[ sym_Symbol ? symbolQ ] := Precedence @ Unevaluated @ sym;


prec[ ___                  ] := 1000.0;


(* ::Subsubsection:: *)
(*rhsParenQ*)


rhsParenQ // ClearAll;


rhsParenQ // Attributes = { HoldAllComplete };


With[ { la = $assocLeft, ra = $assocRight },
rhsParenQ[ h:la, (h:la)[ ___ ] ] := True;
rhsParenQ[ h:ra, (h:ra)[ ___ ] ] := False;
];

rhsParenQ[ SetDelayed, _Set ] := False;
rhsParenQ[ args___ ] := reqParenQ @ args;


(* ::Subsubsection:: *)
(*indent*)


indent // ClearAll;


indent[n_] := StringJoin@ConstantArray[" ", {n, $indentSize}];


indent[] := indent[$level];


(* ::Subsubsection:: *)
(*equivStringsQ*)


equivStringsQ // ClearAll;


equivStringsQ[ s1_String, s2_String ] :=
  Quiet @ SameQ[
      ToExpression[ s1, InputForm, HoldComplete ],
      ToExpression[ s2, InputForm, HoldComplete ]
  ];


(* ::Subsubsection:: *)
(*$prefix*)


$prefix // ClearAll;


$prefix = True;


(* ::Subsubsection:: *)
(*formatLHS*)


formatLHS // ClearAll;


formatLHS // Attributes = { HoldAllComplete };


formatLHS[ parent_, expr_ ] :=
    If[ lhsParenQ[ parent, expr ],
        StringJoin[ "(", cFormat @ expr, ")" ],
        cFormat @ expr
    ];


(* ::Subsubsection:: *)
(*formatRHS*)


formatRHS // ClearAll;


formatRHS // Attributes = { HoldAllComplete };


formatRHS[ parent_, expr_ ] :=
    If[ rhsParenQ[ parent, expr ],
        StringJoin[ "(", cFormat @ expr, ")" ],
        cFormat @ expr
    ];


(* ::Subsubsection:: *)
(*$noPrefixHeads*)


$noPrefixHeads // ClearAll;


$noPrefixHeads = Alternatives[
    CompoundExpression,
    Except,
    Function,
    List,
    Message,
    Not,
    Pattern,
    OptionsPattern
];


(* ::Subsubsection:: *)
(*$noPrefixInner*)


$noPrefixInner // ClearAll;


$noPrefixInner = HoldPattern @ Alternatives[
    _Not,
    _Integer,
    _Real,
    _PatternTest,
    HoldPattern[ Blank|BlankSequence|BlankNullSequence ][ ___ ],
    HoldPattern[ Repeated|RepeatedNull ][ _ ]
];


(* ::Subsubsection:: *)
(*prefixQ*)


prefixQ // ClearAll;


prefixQ // Attributes = { HoldAllComplete };


With[ { h = $noPrefixHeads, i = $noPrefixInner },
prefixQ[ h[ ___ ] ] := False;
prefixQ[ _[ i ] ] := False;
];

prefixQ[ (f_?symbolQ)[ (g_?symbolQ)[ a___ ] ] ] :=
    TrueQ @ And[
        $prefix,
        $prefixEnabled,
        Or[ prec @ g > 640,
            Block[ { $prefix = False },
                StringStartsQ[ cFormat @ g @ a, toString @ g ~~ "[" ]
            ]
        ]
    ];


prefixQ[ ___ ] := TrueQ[ $prefix && $prefixEnabled ];

(* ::Subsubsection:: *)
(*$prefixEnabled*)


$prefixEnabled // ClearAll;


$prefixEnabled = True;


(* ::Subsubsection:: *)
(*makePrefix*)


makePrefix // ClearAll;


makePrefix // Attributes = { HoldAllComplete };


makePrefix[ slot_Slot, _ ] :=
  toString @ slot;


makePrefix[ f_[ s_String ], _ ] :=
  StringJoin[
      Block[ { $prefix = False }, cFormat @ f ],
      "[ ",
      toString @ s,
      " ]"
  ];


makePrefix[ e: _List|_Association, _ ] :=
  With[ { str = Block[ { $prefix = False }, cFormat @ e ] },
      $prefix = True;
      str
  ];


makePrefix[ e: _[ Verbatim[ Pattern ][ ___ ] ], _ ] :=
  With[ { str = Block[ { $prefix = False }, cFormat @ e ] },
      $prefix = True;
      str
  ];


makePrefix[ f_[ g_[ args___ ] ], 0 ] :=
    Module[ { fs, ga, pform },
        fs = cFormat @ f;
        ga = cFormat @ g @ args;
        pform = StringJoin[ fs, " @ ", ga ];

        If[ And[ ! StringStartsQ[ ga, "(" ],
                 MatchQ[ Quiet @ ToExpression[ pform, InputForm, HoldComplete ],
                         HoldComplete @ Verbatim[ f ][ Verbatim[ g ][ ___ ] ]
                 ]
            ],
            verifyLength[ pform, makePrefix[ f @ g @ args, 0 ] ],
            Block[ { $prefix = False }, cFormat @ f @ g @ args ]
        ]
    ];


makePrefix[ f_[ g_[ args___ ] ], 1 ] :=
  Module[ { fs, ga, pform },
      fs = cFormat @ f;
      ga = Internal`WithLocalSettings[
              $level++,
              StringJoin[ indent[], cFormat @ g @ args ],
              $level--
          ];
      pform = StringJoin[ fs, " @\n", ga ];

      If[ And[ ! StringStartsQ[ ga, WhitespaceCharacter...~~"(" ],
                 MatchQ[ Quiet @ ToExpression[ pform, InputForm, HoldComplete ],
                         HoldComplete @ Verbatim[ f ][ Verbatim[ g ][ ___ ] ]
                 ]
          ],
          verifyLength[ pform, makePrefix[ f @ g @ args, 1 ] ],
          Block[ { $prefix = False }, cFormat @ f @ g @ args ]
      ]
  ];


makePrefix[ f_[ g_[ args___ ] ], 2 ] :=
  Module[ { fs, gs, hs, pform },
      fs = cFormat @ f;
      gs = cFormat @ g;
      hs = StringJoin[ fs, " @ ", gs ];
      pform = StringJoin[
          hs, "[\n",
          Internal`WithLocalSettings[
              $level++,
              Riffle[ List @@ Function[ Null, StringJoin[ indent[ ], cFormat[ #1 ] ], { HoldAllComplete } ] /@ HoldComplete[ args ], ",\n" ],
              $level--
          ],
          "\n", indent[$level], "]"
      ];
      If[ MatchQ[ Quiet @ ToExpression[ pform, InputForm, HoldComplete ],
                  HoldComplete[ Verbatim[ f ][ Verbatim[ g ][ ___ ] ] ]
          ],
          verifyLength[ pform, makePrefix[ f @ g @ args, 2 ] ],
          Block[ { $prefix = False },
              cFormat @ f @ g @ args
          ]
      ]
  ];


makePrefix[ f_[ x_ ], _ ] :=
  Module[ { fs, xs, pform },
      fs = cFormat @ f;
      xs = cFormat @ x;
      pform = StringJoin[ fs, " @ ", xs ];
      If[ MatchQ[ Quiet @ ToExpression[ pform, InputForm, HoldComplete ],
                  HoldComplete[ f[ _ ] ]
          ],
          If[ stringFitsOnLineQ @ pform,
              pform,
              StringJoin[
                  fs, " @\n",
                  Internal`WithLocalSettings[
                      $level++,
                      StringJoin[ indent[ ], xs ],
                      $level--
                  ]
              ]
          ],
          StringJoin[ fs, "[", xs, "]" ]
      ]
  ];


(* ::Subsubsection:: *)
(*tagAssociations*)


tagAssociations // ClearAll;


tagAssociations // Attributes = { HoldAllComplete };


tagAssociations[ expr_ ] :=
  expr //. {
      a: Except[ _List, KeyValuePattern[ k_ :> v_ ] ] :>
        RuleCondition @
          KeyDrop[ Insert[ a, $key @ k -> $delayed @ v, Unevaluated @ Key @ k ],
                   Unevaluated @ Key @ k
          ],
      a: Except[ _List, KeyValuePattern[ k: Except[ _$key ] -> v: Except[ _$value ] ] ] :>
        RuleCondition @
          KeyDrop[ Insert[ a, $key @ k -> $value @ v, Unevaluated @ Key @ k ],
                   Unevaluated @ Key @ k
          ]
  };


(* ::Subsubsection:: *)
(*tighten*)


tighten // ClearAll;


tighten[ str_String ] :=
  StringReplace[
      str,
      {
          "[  ]" -> "[ ]",
          "{  }" -> "{ }"
      }
  ];


(* ::Subsubsection:: *)
(*formatArg*)


formatArg // ClearAll;


formatArg // Attributes = { HoldAllComplete };


formatArg[ parent_, expr_ ] :=
    Module[ { pref, paren, str },

        pref  = prec @ parent < 640;
        paren = reqParenQ[ parent, expr ];
        str   = Block[ { $prefix = pref }, cFormat @ expr ];

        If[ paren, StringJoin[ "(", str, ")" ], str ]
    ];


(* ::Subsubsection:: *)
(*formatArgList*)


formatArgList // ClearAll;


formatArgList // Attributes = { HoldAllComplete };

formatArgList[ None, args___ ] :=
    Cases[ HoldComplete @  args, e_ :> cFormat @ e ];

formatArgList[ parent_, args___ ] :=
    Cases[ HoldComplete @  args, e_ :> formatArg[ parent, e ] ];


(* ::Subsubsection:: *)
(*realQ*)


realQ // ClearAll;


realQ // Attributes = { HoldAllComplete };


realQ[ r_Real ] := Developer`RealQ @ Unevaluated @ r;


realQ[ ___ ] := False;


(* ::Subsubsection:: *)
(*$defaultFormatHeads*)


$defaultFormatHeads // ClearAll;


$defaultFormatHeads := {
    ByteArray,
    DateObject,
    Image,
    RawArray,
    IconizedObject,
    System`NumericArray,
    CodeEquivalence`Types`TypedSymbol
};


(* ::Subsubsection:: *)
(*makeSpecialBoxes*)


makeSpecialBoxes // ClearAll;


makeSpecialBoxes // Attributes = { HoldAllComplete };


makeSpecialBoxes[ x: DateObject[ ___? safeArg ] ] :=
  With[ { e = Quiet @ x }, MakeBoxes[ e, StandardForm ] /; DateObjectQ @ e ];


makeSpecialBoxes[ x: ByteArray[ ___? safeArg ] ] :=
  With[ { e = Quiet @ x }, MakeBoxes[ e, StandardForm ] /; ByteArrayQ @ e ];


makeSpecialBoxes[ e_ ] :=
  MakeBoxes[ e, StandardForm ];


(* ::Subsubsection:: *)
(*safeArg*)


safeArg // ClearAll;


safeArg // Attributes = { HoldAllComplete };


safeArg[ { ___? safeArg } ] := True;


safeArg[ x: _Integer|_Real|_String ] := AtomQ @ Unevaluated @ x;


End[ ];

EndPackage[ ];