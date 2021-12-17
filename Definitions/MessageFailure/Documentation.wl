<|
"Usage" -> {
    {
        "MessageFailure[\"message\"]",
        "prints <+\"message\"+> as a <+Message+> and returns a corresponding <+Failure+> object."
    },
    {
        "MessageFailure[\"tag\", \"message\"]",
        "uses \"tag\" as the <+Failure+> tag."
    },
    {
        "MessageFailure[\"tag\", <|$$|>]",
        "determines the message text and failure details from the given <+Association+>."
    },
    {
        "MessageFailure[symbol::tag]",
        "prints the message <+symbol::tag+> and returns a corresponding <+Failure+> object."
    },
    {
        "MessageFailure[symbol::tag, e$1, e$2]",
        "prints a message and returns a <+Failure+>, inserting the values of the <+e$i+> as needed."
    }
},
"Notes" -> {
    "<+MessageFailure[]+> gives a predefined generic error message.",
    "<+MessageFailure[tag,Automatic]+> gives a generic message based on the given <+tag+>.",
    "The association <+assoc+> in <+MessageFailure[\"tag\",assoc]+> typically includes:",
    {
        { "\"MessageTemplate\""  , "a string template for a message"            },
        { "\"MessageParameters\"", "parameters to use for the message template" }
    },
    "The parameters are effectively inserted into the message template using <+TemplateApply+>.",
    "Message templates can use either positional (`<+n+>`) or named (`<+name$i+>`) arguments."
}
|>