IntegerToUUID[ n_Integer ] :=
    StringInsert[
        StringPadLeft[ IntegerString[ n, 16 ], 32, "0" ],
        "-",
        { 9, 13, 17, 21 }
    ];