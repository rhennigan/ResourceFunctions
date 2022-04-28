<|
"Usage" -> {
    {
        "SaveReadableNotebook[notebook,\"file\"]",
        "saves <+notebook+> to <+\"file\"+> as a <+Notebook+> expression formatted for readability."
    }
},
"Notes" -> {
    "In <+SaveReadableNotebook[notebook,$$]+>, the value for <+notebook+> can be any of the following:",
    {
        { "<+Notebook[$$]+>"      , "a notebook expression"          },
        { "<+NotebookObject[$$]+>", "a currently open notebook"      },
        { "<+\"path\"+>"          , "a pathname of a saved notebook" }
    },
    "<+SaveReadableNotebook+> accepts the same options as [ReadableForm](https://resources.wolframcloud.com/FunctionRepository/resources/ReadableForm) with the the following additions:",
    {
        { "\"ExcludedCellOptions\""    , "<+{CellChangeTimes,ExpressionUUID}+>", "cell options that should be discarded from the saved notebook" },
        { "\"ExcludedNotebookOptions\"", "<+{WindowSize,WindowMargins}+>"      , "notebook options that should be discarded"                     }
    }
}
|>