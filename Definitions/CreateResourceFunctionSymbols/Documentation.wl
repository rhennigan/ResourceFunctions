<|
"Usage" -> {
    {
        "CreateResourceFunctionSymbols[]",
        "defines a symbol for each named <+ResourceFunction+> in \"RF`\"."
    },
    {
        "CreateResourceFunctionSymbols[\"ctx`\"]",
        "defines symbols in the given context."
    },
    {
        "CreateResourceFunctionSymbols[\"ctx`\", {\"name$1\", \"name$2\", $$}]",
        "only defines symbols for the given names."
    },
    {
        "CreateResourceFunctionSymbols[\"ctx`\", names, \"op\"]",
        "performs the operation specified by <+\"op\"+> on <+names+>."
    }
},
"Notes" -> {
    "<+CreateResourceFunctionSymbols[]+> is equivalent to
        <+CreateResourceFunctionSymbols[Automatic]+>."
    ,
    "<+CreateResourceFunctionSymbols[context]+> is equivalent to
        <+CreateResourceFunctionSymbols[context, All]+>."
    ,
    "<+CreateResourceFunctionSymbols+> accepts the following options:",
    {
        {
            "<+OverwriteTarget+>",
            "<+False+>",
            "whether to redefine the target symbol if it already exists"
        },
        {
            "<+ExcludedContexts+>",
            "<+Automatic+>",
            "a list of contexts that should be protected from changes"
        },
        {
            "<+ResourceSystemBase+>",
            "<+Automatic+>",
            "the resource system to obtain names from"
        },
        {
            "<+AllowUnknownNames+>",
            "<+True+>",
            "whether to set definitions for unknown resource names"
        }
    }
    ,
    "When <+OverwriteTarget+> is set to <+False+>, a target symbol will not be
        redefined if it has any existing definitions."
    ,
    "<+ExcludedContexts+> is meant to be a safety mechanism to prevent changing
        definitions in important system contexts."
    ,
    "<+ExcludedContexts->None+> can be used to force
        <+CreateResourceFunctionSymbols+> to define symbols in a system context,
        but this is not recommended."
    ,
    "When <+AllowUnknownNames+> is set to <+True+>,
        <+CreateResourceFunctionSymbols[\"ctx`\", names]+> will define symbols
        for all <+names+>, even if they do not correspond to a known resource
        function name."
    ,
    "The operation specified by <+\"op\"+> can be one of the following:"
    ,
    {
        { "\"List\""  , "list the symbols created"            },
        { "\"Remove\"", "remove the symbols created"          },
        { "\"Create\"", "equivalent to the two-argument form" }
    }
}
|>