<|
"Usage" -> {
    {
        "PrintAsCellObject[expr]",
        "prints <+expr+> as output and yields a <+CellObject+> corresponding to the printed cell."
    }
},
"Notes" -> {
    "In a notebook, <+PrintAsCellObject+> generates a cell with style <%\"Print\"%>.",
    "<+PrintAsCellObject+> can print any expression, including graphics and dynamic objects.",
    "<+PrintAsCellObject[expr$1,expr$2,$$]+> prints <+expr$1+> concatenated together, effectively using <+Row+>.",
    "With a text-based interface, <+PrintAsCellObject+> ends its output with a single newline (line feed).",
    "If no front end is available, the output of <+PrintAsCellObject+> is a <+Missing+> object.",
    "You can arrange to have expressions on several lines by using <+Column+>.",
    "<+PrintAsCellObject+> sends its output to the channel <+$Output+>.",
    "<+PrintAsCellObject+> uses the format type of <+$Output+> as its default format type."
}
|>