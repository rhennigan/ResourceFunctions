<|
"Usage" -> {
    {
        "ASTPattern[patt]",
        "converts <+patt+> into a pattern suitable for matching against
            <+CodeParser+> AST nodes."
    },
    {
        "ASTPattern[patt,meta]",
        "uses the pattern <+meta+> to match against node metadata."
    }
},
"Notes" -> {
    "<+ASTPattern+> creates a pattern such that if <+MatchQ[expr, patt]+>,
        then <+MatchQ[node,ASTPattern[patt]]+> where <+node+> is a part of an
        abstract syntax tree that would parse to <+expr+>.",

    "An abstract syntax tree for Wolfram Language code can be generated with
        <*Hyperlink[\"CodeParse\",\"paclet:CodeParser/ref/CodeParse\"]*>.",

    "Not all raw patterns are supported by <+ASTPattern+>.",

    "Combinations of multiple <+PatternTest+>, <+Condition+>, and/or repeated
        <+Pattern+> bindings should be considered experimental and unlikely to
        perform well."
}
|>