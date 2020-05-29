*-------------------------------------------------------------------
* Created by Marco Plaza , 2013-2019 @nfTools
*-------------------------------------------------------------------
Lparameters cjsonstr,revivecollection

#Define crlf Chr(13)+Chr(10)

Private All

stacklevels=Astackinfo(aerrs)

If m.stacklevels > 1
	calledfrom = ' ( called From '+aerrs(m.stacklevels-1,4)+' line '+Transform(aerrs(m.stacklevels-1,5))+')'
Else
	calledfrom = ''
Endif

Try

	cerror = ''
	If Not Left(Ltrim(cjsonstr),1)  $ '{['  And File(m.cjsonstr)
		cjsonstr = Filetostr(m.cjsonstr)
	Endif

	ost = Set('strictdate')
	Set StrictDate To 0
	ojson = nfjsonread2(m.cjsonstr, m.revivecollection)
	Set StrictDate To (m.ost)

Catch To oerr1
	cerror = 'nfJson '+m.calledfrom+crlf+m.oerr1.Message

Endtry

If !Empty(m.cerror)
	Error m.cerror
	Return .Null.
Endif

Return Iif(Vartype(m.ojson)='O',m.ojson,.Null.)

*-------------------------------------------------------------------------
Function nfjsonread2(cjsonstr,revivecollection)
*-------------------------------------------------------------------------

Try

	x = 1
	cerror = ''

* process json:

	cjson = Rtrim(Chrtran(m.cjsonstr,Chr(13)+Chr(9)+Chr(10),''))
	pchar = Left(Ltrim(m.cjson),1)

	nl = Alines(aj,m.cjson,20,'{','}','"',',',':','[',']','\\')

	For xx = 1 To Alen(aj)
		If Left(Ltrim(aj(m.xx)),1) $ '{}",:[]'  Or Lower(Left(Ltrim(m.aj(m.xx)),4)) $ 'true/false/null'
			aj(m.xx) = Ltrim(aj(m.xx))
		Endif
	Endfor

	ostack = Createobject('stack')

	ojson = Createobject('empty')

	Do Case
	Case  aj(1)='{'
		x = 1
		ostack.pushobject()
		procstring(m.ojson)

	Case aj(1) = '['
		x = 0
		procstring(m.ojson,.T.)

	Otherwise
		Error ' expecting [{  got '+m.pchar

	Endcase

	If m.revivecollection
		ojson = revivecollection(m.ojson)
	Endif

Catch To oerr

	strp = ''

	For Y = 1 To m.x
		strp = m.strp+aj(m.y)
	Endfor

	Do Case
	Case oerr.ErrorNo = 1098

		cerror = ' Invalid Json: '+ m.oerr.Message+crlf+' Parsing: '+Right(m.strp,80)

	Otherwise

		cerror = ' program error # '+Transform(m.oerr.ErrorNo)+crlf+m.oerr.Message+' at line: '+Transform(oerr.Lineno)+crlf+' Parsing: '+Right(m.strp,80)

	Endcase

Endtry

If !Empty(m.cerror)
	Error m.cerror
Endif

Return m.ojson

*--------------------------------------------------------------------------------
Procedure procstring(obj,evalue)
*--------------------------------------------------------------------------------
#Define cvalid 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_'
#Define creem  '_______________________________________________________________'

Private rowpos,colpos,bidim,ncols,arrayname,expecting,arraylevel,vari
Private expectingpropertyname,expectingvalue,objectopen

expectingpropertyname = !m.evalue
expectingvalue = m.evalue
expecting = Iif(expectingpropertyname,'"}','')
objectopen = .T.
bidim = .F.
colpos = 0
rowpos = 0
arraylevel = 0
arrayname = ''
vari = ''
ncols = 0

Do While m.objectopen

	x = m.x+1

	Do Case

	Case m.x > m.nl

		m.x = m.nl

		If ostack.Count > 0
			Error 'expecting '+m.expecting
		Endif

		Return

	Case aj(m.x) = '}' And '}' $ m.expecting
		closeobject()

	Case aj(x) = ']' And ']' $ m.expecting
		closearray()

	Case  m.expecting = ':'
		If aj(m.x) = ':'
			expecting = ''
			Loop
		Else
			Error 'expecting : got '+aj(m.x)
		Endif

	Case ',' $ m.expecting

		Do Case
		Case aj(x) = ','
			expecting = Iif( '[' $ m.expecting , '[' , '' )
		Case Not aj(m.x) $ m.expecting
			Error 'expecting '+m.expecting+' got '+aj(m.x)
		Otherwise
			expecting = Strtran(m.expecting,',','')
		Endcase

	Case m.expectingpropertyname

		If aj(m.x) = '"'
			propertyname(m.obj)
		Else
			Error 'expecting "'+m.expecting+' got '+aj(m.x)
		Endif

	Case m.expectingvalue

		If m.expecting == '[' And m.aj(m.x) # '['
			Error 'expecting [ got '+aj(m.x)
		Else
			procvalue(m.obj)
		Endif

	Endcase

Enddo

*-----------------------------------------------------------------------------
Function anuevoel(obj,arrayname,valasig,bidim,colpos,rowpos)
*-----------------------------------------------------------------------------

If m.bidim

	colpos = m.colpos+1

	If colpos > m.ncols
		ncols = m.colpos
	Endif

	Dimension obj.&arrayname(m.rowpos,m.ncols)

	obj.&arrayname(m.rowpos,m.colpos) = m.valasig

	If Vartype(m.valasig) = 'O'
		procstring(obj.&arrayname(m.rowpos,m.colpos))
	Endif

Else

	rowpos = m.rowpos+1
	Dimension obj.&arrayname(m.rowpos)

	obj.&arrayname(m.rowpos) = m.valasig

	If Vartype(m.valasig) = 'O'
		procstring(obj.&arrayname(m.rowpos))
	Endif

Endif

*-----------------------------------------
Function unescunicode( cstr )
*-----------------------------------------

Private All

ust = ''

For x = 1 To Alines(xstr,m.cstr,18,'\u','\\u')

	If Right(xstr(m.x),3) # '\\u' And Right(xstr(m.x),2) = '\u'

		ust = m.ust + Rtrim(xstr(M.x),0,'\u')

		dec = Val( "0x"+Left(xstr(m.x+1),4))

		Ansi = left(Strconv( BinToC( m.dec  , "R" ) ,6 ),1)

		If  m.ansi # '?'
			ust = m.ust + m.ansi
		Else
			ust = m.ust + '&#'+Transform(m.dec)+';'
		Endif

		xstr(m.x+1) = Substr(xstr(m.x+1),5)

	Else

		ust = m.ust + xstr(m.x)

	Endif

Endfor

cstr = m.ust

*-----------------------------------
Function unescapecontrolc( Value )
*-----------------------------------

If At('\', m.value) = 0
	Return
Endif

* unescape special characters:

Private aa,elem,unesc

Declare aa(1)
=Alines(m.aa,m.value,18,'\\','\b','\f','\n','\r','\t','\"','\/')

unesc =''

#Define sustb 'bnrt/"'
#Define sustr Chr(127)+Chr(10)+Chr(13)+Chr(9)+Chr(47)+Chr(34)

For Each elem In m.aa

	If ! m.elem == '\\' And Left(Right(m.elem,2),1) = '\'
		elem = Left(m.elem,Len(m.elem)-2)+Chrtran(Right(m.elem,1),sustb,sustr)
	Endif

	unesc = m.unesc+m.elem

Endfor

Value = m.unesc

*--------------------------------------------
Procedure propertyname(obj)
*--------------------------------------------

x = m.x+1
vari = aj(m.x)

Do While Right(aj(m.x),1) # '"' And m.x < Alen(m.aj)
	x=m.x+1
	vari = m.vari + aj(m.x)
Enddo

If Right(m.aj(m.x),1) # '"'
	Error ' expecting "  got  '+ m.aj(m.x)
Endif

vari = Rtrim(m.vari,1,'"')
vari = Iif(Isalpha(m.vari),'','_')+m.vari
vari = Chrtran( vari, Chrtran( vari, cvalid,'' ) , creem )

If vari == 'tabindex'
	vari = '_tabindex'
Endif

expecting = ':'
expectingvalue = .T.
expectingpropertyname = .F.

*-------------------------------------------------------------
Procedure procvalue(obj)
*-------------------------------------------------------------

Do Case
Case aj(m.x) = '{'

	ostack.pushobject()

	If m.arraylevel = 0

		AddProperty(obj,m.vari,Createobject('empty'))

		procstring(m.obj.&vari)
		expectingpropertyname = .T.
		expecting = ',}'
		expectingvalue = .F.

	Else

		anuevoel(m.obj,m.arrayname,Createobject('empty'),m.bidim,@m.colpos,@m.rowpos)
		expectingpropertyname = .F.
		expecting = ',]'
		expectingvalue = .T.

	Endif

Case  aj(x) = '['

	ostack.pusharray()

	Do Case

	Case m.arraylevel = 0

		arrayname = Evl(m.vari,'array')
		rowpos = 0
		colpos = 0
		bidim = .F.

		Try
			AddProperty(obj,(m.arrayname+'(1)'),.Null.)
		Catch
			m.arrayname = m.arrayname+'_vfpSafe_'
			AddProperty(obj,(m.arrayname+'(1)'),.Null.)
		Endtry

	Case m.arraylevel = 1 And !m.bidim

		rowpos = 1
		colpos = 0
		ncols = 1

		Dime obj.&arrayname(1,2)
		bidim = .T.

	Endcase

	arraylevel = m.arraylevel+1

	vari=''

	expecting = Iif(!m.bidim,'[]{',']')
	expectingvalue = .T.
	expectingpropertyname = .F.

Otherwise

	isstring = aj(m.x)='"'
	x = m.x + Iif(m.isstring,1,0)

	Value = ''

	Do While m.x <= Alen(m.aj)
		Value = m.value + aj(m.x)
		If  ( ( m.isstring And Right(aj(m.x),1) = '"' ) Or (!m.isstring And Right(aj(m.x),1) $ '}],') ) And Left(Right(aj(m.x),2),1) # '\'
			Exit
		Endif
		x = m.x+1
	Enddo

	closechar = Right(aj(m.x),1)

	Value = Left(m.value,Len(m.value)-1)

	Do Case

	Case Empty(m.value) And  Not ( m.isstring And m.closechar = '"'  )
		Error 'Expecting value got '+m.closechar

	Case  m.isstring
		If m.closechar # '"'
			Error 'expecting " got '+m.closechar
		Endif

	Case ostack.isobject() And Not m.closechar $ ',}'
		Error 'expecting ,} got '+m.closechar

	Case ostack.isarray() And  Not m.closechar $ ',]'
		Error 'expecting ,] got '+m.closechar

	Endcase

	If m.isstring

* don't change this lines sequence!:
		unescunicode(@m.value)  && 1
		unescapecontrolc(@m.value)  && 2
		Value = Strtran(m.value,'\\','\')  && 3

** check for Json DateTime: && 2017-03-10T17:43:55
* proper formatted dates with invalid values will parse as character - eg: {"today":"2017-99-01T15:99:00"}

		If isjsondt( m.value )
			Value = jsondatetodt( m.value )
		Endif

	Else

		Value = Alltrim(m.value)

		Do Case
		Case Lower(m.value) == 'null'
			Value = .Null.
		Case Lower(m.value) == 'true' Or Lower(m.value) == 'false'
			Value = m.value='true'

		Case Empty(Chrtran(m.value,'-1234567890.Ee',''))

			Try
				Local tvaln,im
				im = 'tvaln = '+m.value
				&im
				Value = m.tvaln
				badnumber = .F.
			Catch
				badnumber = .T.
			Endtry

			If badnumber
				Error 'bad number format:  got '+aj(m.x)
			Endif

		Otherwise
			Error 'expecting "|number|null|true|false|  got '+aj(m.x)
		Endcase

	Endif

	If m.arraylevel = 0

		AddProperty(obj,m.vari,m.value)

		expecting = '}'
		expectingvalue = .F.
		expectingpropertyname = .T.

	Else

		anuevoel(obj,m.arrayname,m.value,m.bidim,@m.colpos,@m.rowpos)
		expecting = ']'
		expectingvalue = .T.
		expectingpropertyname = .F.

	Endif

	expecting = Iif(m.isstring,',','')+m.expecting

	Do Case
	Case m.closechar = ']'
		closearray()
	Case m.closechar = '}'
		closeobject()
	Endcase

Endcase

*------------------------------
Function closearray()
*------------------------------

If ostack.Pop() # 'A'
	Error 'unexpected ] '
Endif

If m.arraylevel = 0
	Error 'unexpected ] '
Endif

arraylevel = m.arraylevel-1

If m.arraylevel = 0

	arrayname = ''
	rowpos = 0
	colpos = 0

	expecting = Iif(ostack.isobject(),',}','')
	expectingpropertyname = .T.
	expectingvalue = .F.

Else

	If  m.bidim
		rowpos = m.rowpos+1
		colpos = 0
		expecting = ',]['
	Else
		expecting = ',]'
	Endif

	expectingvalue = .T.
	expectingpropertyname = .F.

Endif

*-------------------------------------
Procedure closeobject
*-------------------------------------

If ostack.Pop() # 'O'
	Error 'unexpected }'
Endif

If m.arraylevel = 0
	expecting = ',}'
	expectingvalue = .F.
	expectingpropertyname = .T.
	objectopen = .F.
Else
	expecting = ',]'
	expectingvalue = .T.
	expectingpropertyname = .F.
Endif

*----------------------------------------------
Function revivecollection( o )
*----------------------------------------------

Private All

oconv = Createobject('empty')

nprop = Amembers(elem,m.o,0,'U')

For x = 1 To m.nprop

	estavar = m.elem(x)

	esarray = .F.
	escoleccion = Type('m.o.'+m.estavar) = 'O' And Right( m.estavar , 14 ) $ '_KV_COLLECTION,_KL_COLLECTION' And Type( 'm.o.'+m.estavar+'.collectionitems',1) = 'A'

	Do Case
	Case m.escoleccion

		estaprop = Createobject('collection')

		tv = m.o.&estavar

		m.keyvalcoll = Right( m.estavar , 14 ) = '_KV_COLLECTION'

		If Not ( Alen(m.tv.collectionItems) = 1 And Isnull( m.tv.collectionItems ) )

			For T = 1 To Alen(m.tv.collectionItems)

				If m.keyvalcoll
					esteval = m.tv.collectionItems(m.t).Value
				Else
					esteval = m.tv.collectionItems(m.t)
				Endif

				If Vartype(m.esteval) = 'O' Or Type('esteVal',1) = 'A'
					esteval = revivecollection(m.esteval)
				Endif

				If m.keyvalcoll
					estaprop.Add(esteval,m.tv.collectionItems(m.t).Key)
				Else
					estaprop.Add(m.esteval)
				Endif

			Endfor

		Endif

	Case Type('m.o.'+m.estavar,1) = 'A'

		esarray = .T.

		For T = 1 To Alen(m.o.&estavar)

			Dimension &estavar(m.t)

			If Type('m.o.&estaVar(m.T)') = 'O'
				&estavar(m.t) = revivecollection(m.o.&estavar(m.t))
			Else
				&estavar(m.t) = m.o.&estavar(m.t)
			Endif

		Endfor

	Case Type('m.o.'+estavar) = 'O'
		estaprop = revivecollection(m.o.&estavar)

	Otherwise
		estaprop = m.o.&estavar

	Endcase

	estavar = Strtran( m.estavar,'_KV_COLLECTION', '' )
	estavar = Strtran( m.estavar, '_KL_COLLECTION', '' )

	Do Case
	Case m.escoleccion
		AddProperty(m.oconv,m.estavar,m.estaprop)
	Case  m.esarray
		AddProperty(m.oconv,m.estavar+'(1)')
		Acopy(&estavar,m.oconv.&estavar)
	Otherwise
		AddProperty(m.oconv,m.estavar,m.estaprop)
	Endcase

Endfor

Try
	retcollection = m.oconv.Collection.BaseClass = 'Collection'
Catch
	retcollection = .F.
Endtry

If m.retcollection
	Return m.oconv.Collection
Else
	Return m.oconv
Endif

*----------------------------------
Function isjsondt( cstr )
*----------------------------------

cstr = Rtrim(m.cstr,1,'Z')

Return Iif( Len(m.cstr) = 19 ;
	and Len(Chrtran(m.cstr,'01234567890:T-','')) = 0 ;
	and Substr(m.cstr,5,1) = '-' ;
	and Substr(m.cstr,8,1) = '-' ;
	and Substr(m.cstr,11,1) = 'T' ;
	and Substr(m.cstr,14,1) = ':' ;
	and Substr(m.cstr,17,1) = ':' ;
	and Occurs('T',m.cstr) = 1 ;
	and Occurs('-',m.cstr) = 2 ;
	and Occurs(':',m.cstr) = 2 ,.T.,.F. )

*-----------------------------------------------------
Procedure jsondatetodt( cjsondate )
*-----------------------------------------------------

cjsondate = Rtrim(m.cjsondate,1,'Z')

If m.cjsondate = '0000-00-00T00:00:00'

	Return {}

Else

	cret = Eval('{^'+Rtrim(m.cjsondate,1,"T00:00:00")+'}')

	If !Empty(m.cret)
		Return m.cret
	Else
		Error 'Invalid date '+cjsondate
	Endif

Endif

******************************************
Define Class Stack As Collection
******************************************

*---------------------------
	Function pushobject()
*---------------------------
	This.Add('O')

*---------------------------
	Function pusharray()
*---------------------------
	This.Add('A')

*--------------------------------------
	Function isobject()
*--------------------------------------
	Return This.Count > 0 And This.Item( This.Count ) = 'O'

*--------------------------------------
	Function isarray()
*--------------------------------------
	Return This.Count > 0 And This.Item( This.Count ) = 'A'

*----------------------------
	Function Pop()
*----------------------------
	cret = This.Item( This.Count )
	This.Remove( This.Count )
	Return m.cret

******************************************
Enddefine
******************************************
