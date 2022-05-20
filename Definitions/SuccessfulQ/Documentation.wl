<|
"Usage" -> {
    {
        "SuccessfulQ[expr]",
        "gives <+False+> if <+expr+> is a failure or missing value and <+True+> otherwise."
    }
},
"Notes" -> {
    "<+SuccessfulQ+> considers <+expr+> to be successful as long as <+expr+> does not have any of the following forms:",
    {
        { "<+Failure[$$]+>" },
        { "<+Missing[$$]+>" },
        { "<+$Failed+>"     },
        { "<+$Canceled+>"   },
        { "<+$Aborted+>"    }
    },
    "<+SuccessfulQ+> has the attribute <+SequenceHold+>."
}
|>