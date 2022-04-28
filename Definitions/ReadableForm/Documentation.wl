<|
"Usage" -> {
    {
        "ReadableForm[expr]",
        "displays a version of <+expr+> similar to <+InputForm[expr]+> that is formatted to maximize readability."
    }
},
"Notes" -> {
    "<+ReadableForm+> has the following options:",
    {
        { "<+CachePersistence+>" , "<+Automatic+>", "specifies how internal caching should be handled"                                              },
        { "<+CharacterEncoding+>", "\"Unicode\""  , "which character encoding to use"                                                               },
        { "\"DynamicAlignment\"" , "<+False+>"    , "whether to use context-sensitive alignment across lines"                                       },
        { "\"FormatHeads\""      , "<+Automatic+>", "a set of heads <+{h$1,h$2,$$}+> such that <+h$i[$$]+> should be formatted in <+StandardForm+>" },
        { "\"IndentSize\""       , "4"            , "how many spaces to use for indenting"                                                          },
        { "\"InitialIndent\""    , "0"            , "how much additional indentation to apply to each line"                                         },
        { "<+PageWidth+>"        , "80"           , "the target character count for each line"                                                      },
        { "<+PerformanceGoal+>"  , "\"Quality\""  , "aspects of performance to try to optimize"                                                     },
        { "\"PrefixForm\""       , "<+True+>"     , "whether to use prefix form (<+f@x+>) when appropriate"                                         },
        { "\"RealAccuracy\""     , "<+Automatic+>", "number of digits to the right of the decimal point to display for real numbers"                },
        { "\"RelativeWidth\""    , "<+False+>"    , "whether to count indentation in page width"                                                    }
    },
    "Possible settings for <+CachePersistence+> include:",
    {
        { "<+None+>"     , "improves memory usage at the cost of speed" },
        { "<+Full+>"     , "improves speed at the cost of memory usage" },
        { "<+Automatic+>", "uses a balanced mix"                        }
    },
    "The <+\"DynamicAlignment\"+> option is considered experimental and is currently only applied for a small set of expression types.",
    "Specifying <+\"InitialIndent\"->n+> will add an additional <+n\[Times]s+> spaces to the beginning of each line, where <+s+> is the value of <+\"IndentSize\"+>.",
    "The value for <+PageWidth+> specifies a desired target width and is not a hard limit.",
    "The value for <+\"RealAccuracy\"+> can be one of the following:",
    {
        { "<+Automatic+>", "real numbers are displayed using normal <+InputForm+> behavior"                              },
        { "<+n+>"        , "a nonnegative integer specifying a maximum number of digits to display after decimal points" }
    },
    "With the setting <+\"RealAccuracy\"->n+>, real numbers will always display with at least one digit to the right of the decimal point. If there are no digits available, a zero will be used.",
    "With the setting <+\"RelativeWidth\"->True+>, the leading whitespace is not counted when determining the width of a line.",
    "[SaveReadableNotebook](https://resources.wolframcloud.com/FunctionRepository/resources/SaveReadableNotebook) should be used instead of <+ReadableForm+> if formatting notebook files."
}
|>