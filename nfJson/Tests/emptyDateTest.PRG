

o = nfJsonRead('{"testDate":"2017-12-01T00:00:00"}')
? 'should be date:',vartype(o.testDate)

try
	o = nfJsonRead('{"testDate":"2017-25-01T00:00:00"}')
catch to oerr
	? 'should throw error: ',oerr.message
endtry

o = nfJsonRead('{"testDate":"2017-12-01T01:00:00"}')
? 'should be time:', vartype(o.testDate)

o = nfJsonRead('{"testDate":"0000-00-00T00:00:00"}')
? 'should be empty:',empty(o.testDate), vartype(o.testDate)

create cursor test ( adatetime t null , adate d null )
insert into test ( adatetime, adate ) values ( .null.,.null. )
append blank

cJson = nfCursorToJson4vfp()

nfJsonToCursor(  m.cJson  )
browse

close tables ALL
