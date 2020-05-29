*-------------------------------------------------------------------
* Created by Marco Plaza @nfTools
* ver 1.000 - 20/02/2016
*-------------------------------------------------------------------
parameters returnArray,arrayofValues,includestruct,formattedOutput

LOCAL o
o = nfCursorToObject( m.arrayOfValues,m.includestruct )

IF m.returnArray
	DIMENSION rows(1)
	ACOPY(m.o.rows,'rows')
	Return nfJsonCreate(@m.rows,m.formattedOutput,.t.)
ELSE
	Return nfJsonCreate(m.o,m.formattedOutput,.t.)
ENDIF
