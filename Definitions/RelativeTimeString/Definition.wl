RelativeTimeString // ClearAll;

RelativeTimeString // Attributes = { Listable };

RelativeTimeString[ date1_? DateObjectQ, date2_? DateObjectQ ] :=
    Module[ { diff, post, nice },
        diff = date2 - date1;
        post = If[ TrueQ @ Positive @ diff, " ago", " from now" ];
        nice = Round @ ResourceFunction[ "SecondsToQuantity" ][ Abs @ diff ];
        If[ QuantityMagnitude @ nice === 0,
            "now",
            StringJoin[
                TextString[ nice /. r_Rational :> RuleCondition @ Round @ r ],
                post
            ]
        ]
    ];

RelativeTimeString[ date_? DateObjectQ ] :=
    RelativeTimeString[ date, DateObject[ Now, date[ "Granularity" ] ] ];