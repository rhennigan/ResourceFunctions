<|
"Usage" -> {
    {
        "FITImport[source]",
        "imports data from a fit file <+source+> as a <+Dataset+>."
    },
    {
        "FITImport[source,elements]",
        "imports the specified <+elements+> from a file."
    }
},
"Notes" -> {
    "Some possible values for <+source+> are:",
    {
        { "<+\"path\"+>"        , "a string corresponding to a file path or URL" },
        { "<+File[$$]+>"        , "a <+File+> object"                            },
        { "<+URL[$$]+>"         , "a <+URL+> object"                             },
        { "<+LocalObject[$$]+>" , "a <+LocalObject+>"                            },
        { "<+CloudObject[$$]+>" , "a <+CloudObject+>"                            },
        { "<+HTTPResponse[$$]+>", "an <+HTTPResponse+> object"                   }
    },
    "Valid elements include:",
    {
        { "<%\"Data\"%>"                  , "gives a list of associations"                                     },
        { "<%\"Dataset\"%>"               , "gives a <+Dataset+>"                                              },
        { "<%\"RawData\"%>"               , "gives raw data from the file as a matrix of integers"             },
        { "<+\"prop\"+>"                  , "a <+TimeSeries+> for the specified property"                      },
        { "<+{\"prop$1\",\"prop$2\",$$}+>", "an association of <+TimeSeries+> objects for each <+\"prop$i\"+>" },
        { "<+All+>"                       , "imports all properties"                                           }
    }
}
|>