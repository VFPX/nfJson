*-------------------------------------------------------------------
* Created by Marco Plaza  @vfp2Nofox
* ver 1.000 - 20/02/2016 
*-------------------------------------------------------------------
parameters returnArray,arrayofValues,includestruct,formattedOutput

LOCAL o
o = nfCursorToObject( m.arrayOfValues,m.includestruct )


IF m.returnArray
	DIMENSION rows(1)
	ACOPY(o.rows,'rows')
	Return nfJsonCreate(@rows,m.formattedOutput)
ELSE
	Return nfJsonCreate(m.o,m.formattedOutput)
ENDIF



