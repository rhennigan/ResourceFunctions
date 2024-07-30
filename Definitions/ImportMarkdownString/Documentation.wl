<|
"Usage" -> {
    {
        "ImportMarkdownString[\"markdown\"]",
        "imports <+\"markdown\"+> as a formatted expression."
    },
    {
        "ImportMarkdownString[\"markdown\", \"prop\"]",
        "imports the specified property <+\"prop\"+> from <+\"markdown\"+>."
    }
},
"Notes" -> {
    "The value for <+\"prop\"+> can be any of the following:",
    {
        { "<+Automatic+>", "a formatted expression"                                      },
        { "\"Cell\""     , "a <+Cell+> expression that represents the formatted content" },
        { "\"Notebook\"" , "a <+Notebook+> expression"                                   }
    }
}
|>