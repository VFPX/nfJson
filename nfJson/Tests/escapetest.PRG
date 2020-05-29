clear

set path to ..\

private all

public pair

pair = CREATEOBJECT("empty")

addproperty(pair , [test], [\\"""he\"\\"""\///""\"\\"/"ll/\"o/"\"\\\\""\"] )

json = nfjsoncreate(pair)

_cliptext = m.json
? json

ee = nfJsonRead(m.json)

? 'Test equal?', ee.test == pair.test

? ee.test
? pair.test
