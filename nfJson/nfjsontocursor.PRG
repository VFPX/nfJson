*-------------------------------------------------------------------
* Created by Marco Plaza / @nfTools
* ver 1.000 - 20/02/2016
* ver 1.100 - 05/08/2017
*-------------------------------------------------------------------
Parameters  cJson, cName, forceImportFromArray

cName = Evl(m.cName,Sys(2015))

Private All

oCursor = nfJsonRead(m.cJson)

do case
 CASE VARTYPE(oCursor) # 'O'
 	return
 case Vartype(oCursor.aStruct) = 'U'
	Error  'missing structure data - must create json using nfCursor2Json4vfp() '
	return
 case !m.forceImportFromArray and Vartype(oCursor.asarray) = 'L' and oCursor.asarray
 	Error  'array contains only values; create json using nfCursor2Json4vfp() ;
 	or use forceImportFromArray only if you are sure your data contains no memo or binary types'
	return
endcase

Create Cursor (m.cName) From Array oCursor.aStruct

If oCursor.recordCount = 0
	Return
Endif

If oCursor.arrayOfValues

	nFields = Alen(oCursor.aStruct,1)

	i = 'Insert into '+m.cName+' ( '
	i2 = ' values ('

	For N = 1 To m.nFields

		i = m.i+oCursor.aStruct[m.n,1]+','

		If oCursor.aStruct[m.n,2] = 'D'
			wrl = 'ttod('
			wrr = ')'
		Else
			Store '' To wrl,wrr
		Endif

		i2 = m.i2+m.wrl+'oCursor.rows[m.n,'+Transform(m.N)+']'+m.wrr+','

	Endfor

	i = Left(m.i,Len(m.i)-1)+') '+Left(m.i2,Len(m.i2)-1)+')'

	nRows = oCursor.recordCount

	For N = 1 To m.nRows
		&i
	Endfor

Else

	nFields = Alen(oCursor.aStruct,1)

	For Each oRow In oCursor.Rows
		Insert Into (cName) From Name oRow
	Endfor

Endif

Return m.cName
