<|
"Usage" -> {
    {
        "KeyCases[assoc,patt]",
        "selects elements in the association <+assoc+> for which their keys match <+patt+>."
    },
    {
        "KeyCases[patt]",
        "represents an operator form of <+KeyCases+> that can be applied to an expression."
    }
},
"Notes" -> {
    "<+KeyCases+> yields an <+Association+> object whose elements appear in the same order as they did in <+assoc+>.",
    "<+KeyCases+> can be applied not only to <+Association+> objects, but also to any expression that has rules for arguments.",
    "<+KeyCases[patt][assoc]+> is equivalent to <+KeyCases[assoc,patt]+>."
}
|>