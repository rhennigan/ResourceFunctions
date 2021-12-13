<|
"Usage" -> {
    {
        "BinaryWriteAt[path, bytes, offset]",
        "writes bytes to <+path+> beginning at the position given by offset."
    },
    {
        "BinaryWriteAt[path, bytes]",
        "uses an offset of zero."
    }
},
"Notes" -> {
    "The value for <+path+> can be any of the following:",
    {
        { "<+\"file\"+>"       , "a string corresponding to a local file path" },
        { "<+File[\"file\"]+>" , "a local file path"                           }
    },
    "The value for <+bytes+> can be any of the following:",
    {
        { "<+\"str\"+>"      , "a string"                                    },
        { "<+ByteArray[$$]+>", "a byte array"                                },
        { "<+{b$1,b$2,$$}+>" , "a sequence of byte values given as integers" }
    },
    "Negative values for <+offset+> can be given to specify an offset from the end of the file.",
    "<+BinaryWriteAt+> accepts the <+CharacterEncoding+> option, which specifies how strings should be converted to byte values before writing.",
    "The <+CharacterEncoding+> option has no effect if <+bytes+> is not a string."
}
|>