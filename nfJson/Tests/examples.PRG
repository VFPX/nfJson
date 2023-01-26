***********************************************
* nfJsonRead & nfJsonCreate functions test
* Marco Plaza, 2016
************************************************

Close Databases All
Set Talk Off
Set Safety Off

samplesPath = JUSTPATH(SYS(16,0))+'\jsonSamples\'
tempPath = JUSTPATH(SYS(16,0))+'\temp\'

Set Path To '..\' additive   && nfJson folder additive

Try
	Erase (m.tempPath+'test_*.json')
	MD (m.tempPath)
Catch

Endtry

Clear
READ

*************************************************************************
* will read and parse all json files found in jsonSamples\
* objects will be members of myObjectFromJson
* inspect later in vfp debugger or simply type "myObjectFromJson." from the command line
*************************************************************************

Public myObjectFromJson

myObjectFromJson = Createobject('empty')

nFiles = Adir(jsonfiles,m.samplesPath+'*.json')

? 'Processing:'

For x = 1 To m.nFiles

	thisFile = jsonfiles(x,1)
	propName = Strtran(Juststem(m.thisFile),' ','')

	? m.thisFile

	oJson = nfJsonRead( FORCEPATH(m.thisfile,m.samplesPath))

	AddProperty( myObjectFromJson, m.propName , m.oJson )

Endfor

******************************************************
* create json String back from myObjectFromJson
* raw / formatted
*******************************************************

jsonRaw = nfJsonCreate( myObjectFromJson )
jsonFormatted = nfJsonCreate( myObjectFromJson , .T. )


Strtofile( m.jsonFormatted , m.tempPath+'test_Formatted_'+Sys(2015)+'.Json' )
Strtofile( m.jsonRaw , m.tempPath+'test_Raw_'+Sys(2015)+'.Json' )

Modify FILE (m.tempPath+'*.json') Nowait

=Sys(1500,"_MWI_CASCADE","_MSM_WINDO")

****************************************************************
* create vfp objects back from from raw / formatted json
****************************************************************

Public oFromRaw,oFromFormatted
Store ''  To oFromRaw,oFromFormatted

oFromRaw = nfJsonRead( m.jsonRaw )
oFromFormatted = nfJsonRead( m.jsonFormatted )

messagebox( 'Please inspect myObjectFromJson , oFromRaw, oFromFormatted in your debugger ',0)

***************************************************
* convert cursor to Json using
* different output options:
***************************************************

Select Top 2 ;
	employeeId,firstName,lastName,birthDate,city ;
	from (Sys(2004)+'\samples\northwind\employees') ;
	order By 1 Into Cursor temp

TEXT to demoCursor textmerge

-Cursor as Array of values:

 << nfCursorToJson(.t.,.t.) >>

-Cursor as array of objects:

 << nfCursorToJson(.t.) >>

-Cursor as Object with array of objects ( default) :

<< nfCursorToJson() >>

-Cursor as Object with array of values:

<< nfCursorToJson(.f.,.t.) >>

-Cursor as Object with array of objects and original cursor structure:

<< nfCursorToJson(.f.,.f.,.t.) >>

ENDTEXT

Strtofile( demoCursor, m.tempPath+'Cursor tests Output.txt')
Modify File m.tempPath+'Cursor tests Output.txt' nowait

****************************************************************
* create a cursor back from json:
* json must be created using nfCursortoJson( .f.,.f.,.t. )
* a wrapper function is included for this purpose:
****************************************************************

Select * ;
	from (Sys(2004)+'\samples\northwind\employees') ;
	order By 1 Into Cursor temp

cJson = nfCursorToJson4vfp()

close databases

* create named cursor:

 nfJsonToCursor( m.cJson , 'imaCursorFromJson' )

go top
browse nowait
messagebox( 'Cursor back from Json!',64)

* creates a temp cursor, return alias name:

* myTempCursor = nfJsonToCursor( m.cJson )
