AssociationOuter[ f_, args___ ] :=
    ResourceFunction[ "AssociationKeyDeflatten" ][
        Association @ Flatten @ Outer[ { ## } -> f @ ## &, args ]
    ];