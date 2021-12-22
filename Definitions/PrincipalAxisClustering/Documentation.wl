<|
"Usage" -> {
    {
        "PrincipalAxisClustering[{{p$11,p$12,$$}, {p$21,p$22,$$}, $$}]",
        "recursively partitions the given points into approximately equal-sized clusters along their principal axis."
    },
    {
        "PrincipalAxisClustering[points, n]",
        "partitions <+points+> into at most <+n+> clusters."
    }
},
"Notes" -> {
    "<+PrincipalAxisClustering[points]+> is equivalent to <+PrincipalAxisClustering[points, Automatic]+>.",
    "If <+n+> is a power of two, the clusters will be approximately equal-sized.",
    "<+PrincipalAxisClustering+> accepts a <+Method+> option which decides how to separate points according to their projected values on the principal axis.",
    "The value for <+Method+> can be one of the following:",
    {
        { "<+Median+>", "separate points into approximately equal-sized clusters" },
        { "<+Mean+>"  , "separate points at the center of mass"                   }
    }
}
|>