*************************************************************
*  just for testing purposes.
*  you can  add your sample json
* strings to  nfJsonPerfTest.txt
*
* delimit your json file using 3 Double quotes <sample name> and a colon :
*
* """ mysample Json :
* <json....>
* """
*
*************************************************************

#define millon 1000000
Public oJson, nsamp

IF  _vfp.StartMode # 4 and UPPER(RIGHT(CURDIR(),24)) # upper('\nfJson\performanceTest\')
	MESSAGEBOX('Please run from nfJson\performanceTest',0)
	RETURN
ENDIF

SET PATH TO ..\   && nfJson folder

m.testFile = JUSTPATH(SYS(16,0))+'\nfjsonperftestSamples.TXT'

IF !FILE(m.testFile)
	MESSAGEBOX('Missing  '+m.testFile,0)
	cJson = [""" Missing Samples File: {"FileName":"nfjsonperftestSamples.TXT"} """]
ELSE
	cjson = FILETOSTR(m.testFile)
ENDIF

Dimension opt(1)
N=1
nsamp = 75

Do While .T.
	op=Strextract(cjson,'"""',':',N)
	If Empty(op)
		Exit
	Endif
	Dimension opt(N)
	opt(N)=op
	N=N+1
Enddo

o=Createobject('sampletest')
Read Events

Define Class sampletest As Form

	Height=680
	Width=900
	ShowWindow=2
	Left=300
	Top=100
	caption='nfJson 1.0000'
	
	Add Object lblsamplesize As Label With Left=10,Height=25,Width=235,Top=14,fontname='Consolas',FontSize=11,Caption="Number of Samples to be used:"
	Add Object txtsamplesize As TextBox With Left=250,Height=25,Width=60,Top=10,fontname='Consolas',FontSize=11,Format="KZ",Inputmask="99999",Controlsource="nsamp"
	Add Object samples As ListBox With Anchor=7,Left=10,Top=40,Height = 595,Width = 235,RowSourceType=5,FontName='Consolas',FontSize=10
	Add Object json As EditBox With Anchor=15,Left=250,Top=40,Height = 595,Width = 640,RowSourceType=5,FontName='Consolas',FontSize=10
	Add Object deCliptext As CommandButton With Anchor=6,Left =9, Top = 640, Height=30, Width=237 , Caption='Json from clipboard',FontName='Consolas',FontSize=11
	Add Object TRESULT As TextBox With Anchor=6,Left=250,Height=28,Width=640,Top=641,fontname='Consolas',FontSize=11

	Procedure Init
	This.Visible = .T.
	This.samples.RowSource='opt'

	Procedure Destroy
	Clear Events

*-----------------------------------------
	Procedure deCliptext.Click()
*-----------------------------------------
try
	Thisform.procesarJson(_Cliptext)
Catch to oerr

	MessageBox(oerr.message,0)

EndTry

*-------------------------------------
	Procedure samples.Click()
*-------------------------------------
	Thisform.procesarJson( Strextract(cjson,opt(This.ListIndex)+':','"""') )

*------------------------------------------
	Function procesarJson(jText)
*------------------------------------------

	If Vartype(jText) # 'C'
		Messagebox('No es Texto!',0)
		Return .F.
	Endif
	
* indicator that results are being recalculated
	Thisform.TRESULT.ForeColor = RGB(255,0,0)
	
* transform sample json data into vfp Object:
	TI=Seconds()

	For nv = 1 To nsamp
		oJson = nfJsonRead(jText)
		if vartype(ojson) # 'O'
			MESSAGEBOX('Test Failed: '+TRANSFORM(oJson),0)
			exit
		endif
	Endfor

	TR=(Seconds()-TI)*millon

	TR = round(TR/nsamp,0)

* transform vfp object into json string and show result:
	TI=Seconds()

	For nv = 1 To nsamp
		xJson = nfJsonCreate(oJson,.T.)
	endfor

	Thisform.json.Value = xJson

	TR2=(Seconds()-TI)*millon
	TR2=round(TR2/nsamp,0)

	Thisform.TRESULT.ForeColor = RGB(0,0,0)
	Thisform.TRESULT.Value = ' Read: '+Transform(TR,'99,999')+'us  ( '+Transform(millon/TR,'99,999')+' op/sec )   Create: '+Transform(TR2,'99,999')+'us  ( '+Transform(millon/TR2,'99,999')+' op/sec )'

	Thisform.json.SelStart=1

***************************
Enddefine
***************************