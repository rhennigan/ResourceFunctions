<|
"Usage" -> {
    {
        "RelativeTimeString[date]",
        "gives a human-readable string representation of <+date+> relative to the current time."
    },
    {
        "RelativeTimeString[base,date]",
        "uses <+base+> instead of the current time."
    }
},
"Notes" -> {
    "The value for <+date+> can either be a <+Quantity+> of time or a valid <+DateObject+> specification.",
    "If <+date+> is a <+Quantity+> object, then it is interpreted as a time offset relative to the current time.",
    "<+RelativeTimeString[date]+> is effectively equivalent to <+RelativeTimeString[Now,date]+> when <+date+> corresponds to a <+DateObject+> specification.",
    "Dates can be specified as any of the following:",
    {
        { "<+DateObject[$$]+>"  , "a <+DateObject+>"                               },
        { "<+{y,m,d,h,m,s}+>"   , "a <+DateList+> specification"                   },
        { "<+time+>"            , "an <+AbsoluteTime+> specification"              },
        { "<+\"string\"+>"      , "a <+DateString+> specification"                 },
        { "<+{\"string\",fmt}+>", "a date string formed from the specified format" }
    },
    "<+RelativeTimeString[Quantity[$$]]+> is effectively equivalent to <+RelativeTimeString[Now+Quantity[$$]]+>.",
    "A valid time <+Quantity+> has <+UnitDimensions+> of <+{{\"TimeUnit\",1}}.+>"
}
|>