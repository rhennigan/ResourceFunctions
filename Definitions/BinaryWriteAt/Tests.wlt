(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> True ],
    KeyValuePattern[ "TestMode" -> True ],
    SameTest -> MatchQ
]

(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Tests*)

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)

VerificationTest[
    file = Export[ CreateFile[ ], ConstantArray[ 37, 50 ], "Binary" ];
    ReadString @ file,
    "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
]

VerificationTest[
    BinaryWriteAt[ file, "hello world" ];
    ReadString @ file,
    "hello world%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
]

VerificationTest[
    BinaryWriteAt[ file, "everyone", 6 ];
    ReadString @ file,
    "hello everyone%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
]

VerificationTest[
    BinaryWriteAt[ file, "goodbye", -10 ];
    ReadString @ file,
    "hello everyone%%%%%%%%%%%%%%%%%%%%%%%%%%%goodbye%%"
]

VerificationTest[
    DeleteFile @ file,
    Null
]


(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Scope*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Negative offsets*)
VerificationTest[
    FileExistsQ[ file = Export[ CreateFile[ ], "0123456789", "String" ] ]
]

VerificationTest[
    BinaryWriteAt[ file, "appended", -1 ];
    ReadString @ file,
    "0123456789appended"
]

VerificationTest[
    DeleteFile @ file,
    Null
]

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*UpTo*)

VerificationTest[
    FileExistsQ[ file = Export[ CreateFile[ ], "0123456789", "String" ] ]
]

VerificationTest[
    BinaryWriteAt[ file, "out of range", 100 ],
    Failure[ "BinaryWriteAt::outofrange", _Association ],
    { BinaryWriteAt::outofrange },
    SameTest -> MatchQ
]

VerificationTest[
    BinaryWriteAt[ file, "out of range", UpTo[ 100 ] ];
    ReadString @ file,
    "0123456789out of range"
]

VerificationTest[
    DeleteFile @ file,
    Null
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Options*)

(* ::**********************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*CharacterEncoding*)

VerificationTest[
    ba = ByteArray[ "4eHh4eHh4eHh4eHh4eHh" ];
    file = Export[ CreateFile[ ], ba, "Binary" ];
    BinaryReadList @ file,
    ConstantArray[ 225, 15 ]
]

VerificationTest[
    BinaryWriteAt[ file, "\[Beta]", 5 ];
    ReadByteArray @ file,
    ByteArray[ "4eHh4eHOsuHh4eHh4eHh" ]
]

VerificationTest[
    Export[ file, ba, "Binary" ],
    file
]

VerificationTest[
    BinaryWriteAt[ file, "\[Beta]", 5, CharacterEncoding -> "ISO8859-7" ];
    ReadByteArray @ file,
    ByteArray[ "4eHh4eHi4eHh4eHh4eHh" ]
]

(* ::**********************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)

VerificationTest[
    BinaryWriteAt[ ],
    Failure[ "BinaryWriteAt::argt", _Association ],
    { BinaryWriteAt::argt },
    SameTest -> MatchQ
]

VerificationTest[
    BinaryWriteAt[ CharacterEncoding -> "ASCII" ],
    Failure[ "BinaryWriteAt::argt", _Association ],
    { BinaryWriteAt::argt },
    SameTest -> MatchQ
]

VerificationTest[
    BinaryWriteAt[ "test" ],
    Failure[ "BinaryWriteAt::argtu", _Association ],
    { BinaryWriteAt::argtu },
    SameTest -> MatchQ
]

VerificationTest[
    BinaryWriteAt[ "test", CharacterEncoding -> "ASCII" ],
    Failure[ "BinaryWriteAt::argtu", _Association ],
    { BinaryWriteAt::argtu },
    SameTest -> MatchQ
]


(* ::**********************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    SetOptions[ ResourceFunction[ "MessageFailure" ], "TestMode" -> False ],
    KeyValuePattern[ "TestMode" -> False ],
    SameTest -> MatchQ
]
