<|
"Usage" -> {
    {
        "CreateRandomFile[\"n\"]",
        "creates a random file of <+n+> bytes in the default area for temporary files on your computer system."
    },
    {
        "CreateRandomFile[path,n]",
        "creates a random file at the location specified by <+path+>."
    }
},
"Notes" -> {
    "The value for <+path+> can be any of the following:",
    {
        { "<+\"file\"+>"       , "a string corresponding to a local file path" },
        { "<+File[\"file\"]+>" , "a local file path"                           },
        { "<+LocalObject[$$]+>", "a <+LocalObject+>"                           },
        { "<+CloudObject[$$]+>", "a <+CloudObject+>"                           }
    },
    "If <+\"file\"+> has no pathname separators, <+CreateRandomFile+> creates a file in your current working directory.",
    "A relative path specified by <+\"file\"+> is interpreted with respect to the current working directory.",
    "<+CreateRandomFile+> only creates the file; it does not open it.",
    "The file created can subsequently be opened for reading or writing in binary mode.",
    "<+CreateRandomFile+> returns the full name of the file it creates, and a <+Failure+> object if it cannot create the file.",
    "<+CreateRandomFile[n]+> creates a file in the directory specified by the current value of <+$TemporaryDirectory+>.",
    "<+CreateRandomFile[n]+> is equivalent to <+CreateRandomFile[Automatic,n]+>.",
    "The default setting <+CreateIntermediateDirectories->True+> specifies that intermediate directories should be created as needed.",
    "<+File[\"path\"]+> may be used to specify a file name."
}
|>