<|
"Usage" -> {
    {
        "FITImport[source]",
        "imports data from a FIT file <+source+> as a <+Dataset+>."
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
        { "<%\"Dataset\"%>"               , "gives a <+Dataset+> of records" },
        { "<%\"Data\"%>"                  , "gives a list of associations for records" },
        { "<%\"MessageCounts\"%>"         , "gives an association of counts of each message type contained in the file" },
        { "<%\"MessageInformation\"%>"    , "gives a <+Dataset+> containing meta information about messages" },
        { "<%\"RawData\"%>"               , "gives raw data from the file as a matrix of integers" },
        { "<+\"prop\"+>"                  , "a <+TimeSeries+> for the specified record property" },
        { "<+\"type\"+>"                  , "a <+Dataset+> for the specified message type" },
        { "<+{\"prop$1\",\"prop$2\",$$}+>", "an association of <+TimeSeries+> objects for each <+\"prop$i\"+>" },
        { "<+{\"type$1\",\"type$2\",$$}+>", "a <+Dataset+> containing all messages of the specified types" },
        { "<+All+>"                       , "imports all record properties as an association of <+TimeSeries+> objects" },
        { "<+{\"TimeSeries\",elem}+>"     , "specifies that <+elem+> should be imported as a record property" }
    },
    "Some additional cycling-specific visualization elements are:",
    {
        { "\"PowerZonePlot\""         , "gives a timeline plot of [power zone levels](https://www.trainingpeaks.com/blog/power-training-levels/) over time" },
        { "\"AveragePowerPhasePlot\"" , "gives a visualization of left-right pedal power phase balance" },
        { "\"CriticalPowerCurvePlot\"", "gives a plot of the estimated [critical power curve](https://www.highnorth.co.uk/articles/critical-power-calculator)" }
    },
    "For a string element <+\"elem\"+> that matches both a message type and a record property, the message type is used.",
    "To specify that <+\"elem\"+> is a record property, use <+{\"TimeSeries\",\"elem\"}+>.",
    "A few common message types are:",
    {
        { "<%\"Record\"%>"           , "a timestamped message that's used for many of the default import elements"             },
        { "<%\"DeviceInformation\"%>", "a message containing information about a device that's generating data for a FIT file" },
        { "<%\"DeviceSettings\"%>"   , "information about hardware settings for a device"                                      },
        { "<%\"Event\"%>"            , "an arbitrary event that's recorded"                                                    },
        { "<%\"FileID\"%>"           , "information about the FIT file"                                                        },
        { "<%\"Session\"%>"          , "information that typically aggregates record values as a summary"                      },
        { "<%\"UserProfile\"%>"      , "user preferences that can affect how the FIT value is interpreted"                     }
    },
    "The FIT protocol currently defines approximately 100 message types, though not all are supported by <+FITImport+>. Use <+FITImport[file,\"MessageInformation\"]+> to see which message types in <+file+> can be imported.",
    "<+FITImport+> is not currently compatible with the cloud or MacOSX-ARM64 systems."
}
|>