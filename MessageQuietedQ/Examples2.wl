ExampleSection[ "Basic Examples" ]


Example[
    Text[ "Test if a message is disabled via <+Quiet+>:" ],
    Quiet @ { MessageQuietedQ @ Power::infy, 1/0 },
    { True, ComplexInfinity }
]


Example[
    { MessageQuietedQ @ Power::infy, 1/0 },
    Message[ Power::infy, 1/0 ],
    { False, ComplexInfinity }
]


Delimiter


Example[
    Text[ "Check when specific messages are quieted:" ],
    Quiet[ { MessageQuietedQ @ Power::infy, 1/0 }, Power::infy ],
    { True, ComplexInfinity }
]


Example[
    Quiet[ { MessageQuietedQ @ Power::infy, 1/0 }, First::argx ],
    Message[ Power::infy, 1/0 ],
    { False, ComplexInfinity }
]



ExampleSection[ "Scope" ]


Example[
    Text[ "Check for messages inherited from <+General+>:" ],
    Quiet[ { MessageQuietedQ @ First::normal, First[ 1 ] }, General::normal ],
    { True, First[ 1 ] }
]

Example[
    Quiet[ { MessageQuietedQ @ General::normal, First[ 1 ] }, First::normal ],
    Message[ Power::infy, 1/0 ],
    { False, First[ 1 ] }
]
