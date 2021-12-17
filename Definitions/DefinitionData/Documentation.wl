<|
"Usage" -> {
    {
        "DefinitionData[symbol]",
        "returns a definition object for <+symbol+> and all its dependencies."
    },
    {
        "DefinitionData[$$][property]",
        "returns the definition information specified by <+property+>."
    }
},
"Notes" -> {
    "In <+DefinitionData[$$][property]+>, possible values for <+property+> include:",
    {
        { "\"Name\""            , "the fully qualified name of the symbol"                            },
        { "\"Definitions\""     , "an <+Association+> containing full definition information"         },
        { "\"Symbols\""         , "a list of all the contained symbols, each wrapped in <+HoldForm+>" },
        { "\"Names\""           , "a list of fully qualified symbol names"                            },
        { "\"Size\""            , "the full size of the definition data in bytes"                     },
        { "\"Contexts\""        , "a list of all contexts for the defined symbols"                    },
        { "\"DefinitionList\""  , "returns a <%Language`DefinitionList%> of the definition data"      }
    },
    "<+Get[DefinitionData[$$]]+> will restore all the contained definitions.",
    "<+Information[DefinitionData[$$]]+> provides a summary of some properties."
}
|>