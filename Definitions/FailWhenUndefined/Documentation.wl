<|
"Usage" -> {
    {
        "FailWhenUndefined[f]",
        "appends a rule to the definition of <+f+> so that it will return a
            <+Failure+> object rather than remain unevaluated for undefined
            arguments."
    },
    {
        "FailWhenUndefined[f, handler]",
        "applies <+handler+> to the generated <+Failure+> object at the time
            of failure."
    },
    {
        "FailWhenUndefined[f, handler, type]",
        "specifies which set of values to modify for <+f+>."
    }
},
"Notes" -> {
    "The default value for <+handler+> is <+Identity+>.",
    "The default value for <+type+> is <+DownValues+>.",
    "The value for <+type+> can be one of the following:",
    {
        { "<+OwnValues+>"    , "definitions of the form <+f:=$$+>"           },
        { "<+DownValues+>"   , "definitions of the form <+f[$$]:=$$+>"       },
        { "<+SubValues+>"    , "definitions of the form <+f[$$][$$]:=$$+>"   },
        { "<+{SubValues,n}+>", "definitions of the form <+f[$$]$$[$$]:=$$+>" },
        { "<+n+>"            , "equivalent to <+{SubValues,n}+>"             }
    },
    "<+FailWhenUndefined+> accepts the option <%\"Message\"%> which specifies
        whether a message should be issued at the time of failure."
}
|>