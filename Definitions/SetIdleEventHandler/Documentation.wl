<|
"Usage" -> {
    {
        "SetIdleEventHandler[cell,code]",
        "evaluates <+code+> whenever editing stops in the given cell."
    },
    {
        "SetIdleEventHandler[cell,{active,idle}]",
        "evaluates <+active+> whenever edits are made and evaluates <+idle+> a short time after editing has stopped."
    },
    {
        "SetIdleEventHandler[cell,code,delay]",
        "waits <+delay+> seconds after editing to consider the cell idle."
    }
},
"Notes" -> {
    "The value for <+cell+> can be either a <+Cell+> expression or a <+CellObject+>.",
    "The default <+delay+> is one second.",
    "<+SetIdleEventHandler[code]+> is equivalent to <+SetIdleEventHandler[EvaluationCell[],code]+>.",
    "Notebook history tracking and dynamic updating must be enabled in order for <+SetIdleEventHandler+> to work.",
    "<+SetIdleEventHandler+> uses <+CellDynamicExpression+> to track changes."
}
|>