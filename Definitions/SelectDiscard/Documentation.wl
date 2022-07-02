<|
"Usage" -> {
    {
        "SelectDiscard[list,crit]",
        "gives the pair <+{list$1,list$2}+> where <+list$1+> contains all elements <+e$i+> of <+list+> for which <+crit[e$i]+> is <+True+> and <+list$2+> contains the rest."
    },
    {
        "SelectDiscard[list,crit,n]",
        "limits <+list$1+> to <+n+> elements."
    },
    {
        "SelectDiscard[crit]",
        "represents an operator form of <+SelectDiscard+> that can be applied to an expression."
    }
},
"Notes" -> {
    "The <+list$1+> can be thought of as the \"selected\" elements, and <+list$2+> as the \"discarded\" elements.",
    "The values <+e$i+> in <+list$2+> do not necessarily give <+False+> for <+crit[e$i]+>; they are simply the elements not included in <+list$1+>.",
    "The object <+list+> can have any head, not necessarily <+List+>.",
    "When used on an <+Association+>, <+SelectDiscard+> picks out elements according to their values.",
    "<+SelectDiscard+> can be used on <+SparseArray+> objects.",
    "<+SelectDiscard[crit][list]+> is equivalent to <+SelectDiscard[list,crit]+>."
}
|>