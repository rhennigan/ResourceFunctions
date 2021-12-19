<|
"Usage" -> {
    {
        "AssociationOuter[f,list$1,list$2,$$]",
        "gives the generalized outer product of the <+list$i+>, forming all
            possible combinations of the lowest-level elements in each of them,
            and feeding them as arguments to <+f+>."
    },
    {
        "AssociationOuter[f,list$1,list$2,$$,n]",
        "treats as separate elements only sublists at level <+n+> in the
            <+list$i+>."
    },
    {
        "AssociationOuter[f,list$1,list$2,$$,n$1,n$2,$$]",
        "treats as separate elements only sublists at level <+n$i+> in the
            corresponding <+list$i+>."
    }
},
"Notes" -> {
    "<+AssociationOuter[Times,list$1,list$2]+> gives an outer product.",

    "Unlike <+Outer+>, the heads of all <+list$i+> must be <+List+>.",

    "<+AssociationOuter[f]+> returns <+f[]+>.",

    "The <+list$i+> need not necessarily be cuboidal arrays.",

    "The specifications <+n$i+> of levels must be positive integers, or
        <+Infinity+>.",

    "If only a single level specification is given, it is assumed to apply to
        all the <+list$i+>. If there are several <+n$i+>, but fewer than the
        number of <+list$i+>, the lowest-level elements in the remaining
        <+list$i+> will be used.",

    "<+AssociationOuter+> can be used on <+SparseArray+> objects, returning a
        <+SparseArray+> object when possible."
}
|>