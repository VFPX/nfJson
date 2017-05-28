*---------------------------------------------
* Marco Plaza, 2017 @nfTools
* usage:
* ? nfopenjson('{"employee":{"firstname":"John","surName":"Doe"}}','.employee.surname')
*---------------------------------------------
parameters cjsonstr,cpropertypath

private all

try
	kk = nfjsonread(m.cjsonstr)
	lretval = evaluate('kk'+m.cpropertypath)
catch
	lretval = .null.
endtry

return m.lretval
