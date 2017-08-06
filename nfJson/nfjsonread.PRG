*-------------------------------------------------------------------
* Created by Marco Plaza , 2013-2017 @nfTools
*-------------------------------------------------------------------
lparameters cjsonstr,revivecollection

#define crlf chr(13)+chr(10)

private all

stacklevels=astackinfo(aerrs)

if m.stacklevels > 1
	calledfrom = ' ( called From '+aerrs(m.stacklevels-1,4)+' line '+transform(aerrs(m.stacklevels-1,5))+')'
else
	calledfrom = ''
endif


try

	cerror = ''
	if not left(ltrim(cjsonstr),1)  $ '{['  and file(m.cjsonstr)
		cjsonstr = filetostr(m.cjsonstr)
	endif

	ost = set('strictdate')
	set strictdate to 0
	ojson = nfjsonread2(m.cjsonstr, m.revivecollection)
	set strictdate to (m.ost)

catch to oerr1
	cerror = 'nfJson '+m.calledfrom+crlf+m.oerr1.message

endtry

if !empty(m.cerror)
	error m.cerror
	return .null.
endif

return iif(vartype(m.ojson)='O',m.ojson,.null.)


*-------------------------------------------------------------------------
function nfjsonread2(cjsonstr,revivecollection)
*-------------------------------------------------------------------------


try

	x = 1
	cerror = ''

* process json:

	cjson = rtrim(chrtran(m.cjsonstr,chr(13)+chr(9)+chr(10),''))
	pchar = left(ltrim(m.cjson),1)


	nl = alines(aj,m.cjson,20,'{','}','"',',',':','[',']','\\')

	for xx = 1 to alen(aj)
		if left(ltrim(aj(m.xx)),1) $ '{}",:[]'  or lower(left(ltrim(m.aj(m.xx)),4)) $ 'true/false/null'
			aj(m.xx) = ltrim(aj(m.xx))
		endif
	endfor

	ostack = createobject('stack')

	ojson = createobject('empty')

	do case
	case  aj(1)='{'
		x = 1
		ostack.pushobject()
		procstring(m.ojson)

	case aj(1) = '['
		x = 0
		procstring(m.ojson,.t.)

	otherwise
		error ' expecting [{  got '+m.pchar

	endcase


	if m.revivecollection
		ojson = revivecollection(m.ojson)
	endif


catch to oerr

	strp = ''

	for y = 1 to m.x
		strp = m.strp+aj(m.y)
	endfor

	do case
	case oerr.errorno = 1098

		cerror = ' Invalid Json: '+ m.oerr.message+crlf+' Parsing: '+right(m.strp,80)

	otherwise

		cerror = ' program error # '+transform(m.oerr.errorno)+crlf+m.oerr.message+' at line: '+transform(oerr.lineno)+crlf+' Parsing: '+right(m.strp,80)

	endcase

endtry

if !empty(m.cerror)
	error m.cerror
endif

return m.ojson

*--------------------------------------------------------------------------------
procedure procstring(obj,evalue)
*--------------------------------------------------------------------------------
#define cvalid 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_'
#define creem  '_______________________________________________________________'

private rowpos,colpos,bidim,ncols,arrayname,expecting,arraylevel,vari
private expectingpropertyname,expectingvalue,objectopen

expectingpropertyname = !m.evalue
expectingvalue = m.evalue
expecting = iif(expectingpropertyname,'"}','')
objectopen = .t.
bidim = .f.
colpos = 0
rowpos = 0
arraylevel = 0
arrayname = ''
vari = ''
ncols = 0

do while m.objectopen

	x = m.x+1

	do case

	case m.x > m.nl

		m.x = m.nl

		if ostack.count > 0
			error 'expecting '+m.expecting
		endif

		return

	case aj(m.x) = '}' and '}' $ m.expecting
		closeobject()

	case aj(x) = ']' and ']' $ m.expecting
		closearray()

	case  m.expecting = ':'
		if aj(m.x) = ':'
			expecting = ''
			loop
		else
			error 'expecting : got '+aj(m.x)
		endif

	case ',' $ m.expecting

		do case
		case aj(x) = ','
			expecting = iif( '[' $ m.expecting , '[' , '' )
		case not aj(m.x) $ m.expecting
			error 'expecting '+m.expecting+' got '+aj(m.x)
		otherwise
			expecting = strtran(m.expecting,',','')
		endcase


	case m.expectingpropertyname

		if aj(m.x) = '"'
			propertyname(m.obj)
		else
			error 'expecting "'+m.expecting+' got '+aj(m.x)
		endif


	case m.expectingvalue

		if m.expecting == '[' and m.aj(m.x) # '['
			error 'expecting [ got '+aj(m.x)
		else
			procvalue(m.obj)
		endif


	endcase


enddo


*-----------------------------------------------------------------------------
function anuevoel(obj,arrayname,valasig,bidim,colpos,rowpos)
*-----------------------------------------------------------------------------


if m.bidim

	colpos = m.colpos+1

	if colpos > m.ncols
		ncols = m.colpos
	endif

	dimension obj.&arrayname(m.rowpos,m.ncols)

	obj.&arrayname(m.rowpos,m.colpos) = m.valasig

	if vartype(m.valasig) = 'O'
		procstring(obj.&arrayname(m.rowpos,m.colpos))
	endif

else

	rowpos = m.rowpos+1
	dimension obj.&arrayname(m.rowpos)

	obj.&arrayname(m.rowpos) = m.valasig

	if vartype(m.valasig) = 'O'
		procstring(obj.&arrayname(m.rowpos))
	endif

endif


*-----------------------------------------
function unescunicode( cstr )
*-----------------------------------------

private all

ust = ''

for x = 1 to alines(xstr,m.cstr,18,'\u','\\u')

	if right(xstr(m.x),3) # '\\u' and right(xstr(m.x),2) = '\u'

		ust = m.ust + rtrim(xstr(M.x),0,'\u')

		dec = val( "0x"+left(xstr(m.x+1),4))
		ansi = strconv( bintoc( m.dec  , "2RS" ) ,6 )

		if m.ansi = '?'
			ust = m.ust + '&#'+transform(m.dec)
		else
			ust = m.ust + m.ansi
		endif

		xstr(m.x+1) = substr(xstr(m.x+1),5)

	else

		ust = m.ust + xstr(m.x)

	endif

endfor

cstr = m.ust

*-----------------------------------
function unescapecontrolc( value )
*-----------------------------------

if at('\', m.value) = 0
	return
endif

* unescape special characters:

private aa,elem,unesc


declare aa(1)
=alines(m.aa,m.value,18,'\\','\b','\f','\n','\r','\t','\"','\/')

unesc =''

#define sustb 'bnrt/"'
#define sustr chr(127)+chr(10)+chr(13)+chr(9)+chr(47)+chr(34)

for each elem in m.aa

	if ! m.elem == '\\' and left(right(m.elem,2),1) = '\'
		elem = left(m.elem,len(m.elem)-2)+chrtran(right(m.elem,1),sustb,sustr)
	endif

	unesc = m.unesc+m.elem

endfor

value = m.unesc

*--------------------------------------------
procedure propertyname(obj)
*--------------------------------------------

x = m.x+1
vari = aj(m.x)

do while right(aj(m.x),1) # '"' and m.x < alen(m.aj)
	x=m.x+1
	vari = m.vari + aj(m.x)
enddo

if right(m.aj(m.x),1) # '"'
	error ' expecting "  got  '+ m.aj(m.x)
endif

vari = rtrim(m.vari,1,'"')
vari = iif(isalpha(m.vari),'','_')+m.vari
vari = chrtran( vari, chrtran( vari, cvalid,'' ) , creem )

if vari == 'tabindex'
	vari = '_tabindex'
endif

expecting = ':'
expectingvalue = .t.
expectingpropertyname = .f.


*-------------------------------------------------------------
procedure procvalue(obj)
*-------------------------------------------------------------

do case
case aj(m.x) = '{'

	ostack.pushobject()

	if m.arraylevel = 0

		addproperty(obj,m.vari,createobject('empty'))

		procstring(obj.&vari)
		expectingpropertyname = .t.
		expecting = ',}'
		expectingvalue = .f.

	else

		anuevoel(m.obj,m.arrayname,createobject('empty'),m.bidim,@m.colpos,@m.rowpos)
		expectingpropertyname = .f.
		expecting = ',]'
		expectingvalue = .t.

	endif


case  aj(x) = '['

	ostack.pusharray()

	do case

	case m.arraylevel = 0

		arrayname = evl(m.vari,'array')
		rowpos = 0
		colpos = 0
		bidim = .f.


		try
			addproperty(obj,(m.arrayname+'(1)'),.NULL.)
		catch
			m.arrayname = m.arrayname+'_vfpSafe_'
			addproperty(obj,(m.arrayname+'(1)'),.NULL.)
		endtry


	case m.arraylevel = 1 and !m.bidim

		rowpos = 1
		colpos = 0
		ncols = 1

		dime obj.&arrayname(1,2)
		bidim = .t.

	endcase

	arraylevel = m.arraylevel+1

	vari=''

	expecting = iif(!m.bidim,'[]{',']')
	expectingvalue = .t.
	expectingpropertyname = .f.

otherwise

	isstring = aj(m.x)='"'
	x = m.x + iif(m.isstring,1,0)

	value = ''

	do while m.x <= alen(m.aj)
		value = m.value + aj(m.x)
		if  ( ( m.isstring and right(aj(m.x),1) = '"' ) or (!m.isstring and right(aj(m.x),1) $ '}],') ) and left(right(aj(m.x),2),1) # '\'
			exit
		endif
		x = m.x+1
	enddo

	closechar = right(aj(m.x),1)

	value = left(m.value,len(m.value)-1)

	do case

	case empty(m.value) and  not ( m.isstring and m.closechar = '"'  )
		error 'Expecting value got '+m.closechar

	case  m.isstring
		if m.closechar # '"'
			error 'expecting " got '+m.closechar
		endif

	case ostack.isobject() and not m.closechar $ ',}'
		error 'expecting ,} got '+m.closechar

	case ostack.isarray() and  not m.closechar $ ',]'
		error 'expecting ,] got '+m.closechar

	endcase



	if m.isstring

* don't change this lines sequence!:
		unescunicode(@m.value)  && 1
		unescapecontrolc(@m.value)  && 2
		value = strtran(m.value,'\\','\')  && 3

** check for Json DateTime: && 2017-03-10T17:43:55
* proper formatted dates with invalid values will parse as character - eg: {"today":"2017-99-01T15:99:00"}

		if isjsondt( m.value )
			value = jsondatetodt( m.value )
		endif

	else

		value = alltrim(m.value)

		do case
		case lower(m.value) == 'null'
			value = .null.
		case lower(m.value) == 'true' or lower(m.value) == 'false'
			value = m.value='true'

		case empty(chrtran(m.value,'-1234567890.Ee',''))

			try
				local tvaln,im
				im = 'tvaln = '+m.value
				&im
				value = m.tvaln
				badnumber = .f.
			catch
				badnumber = .t.
			endtry

			if badnumber
				error 'bad number format:  got '+aj(m.x)
			endif

		otherwise
			error 'expecting "|number|null|true|false|  got '+aj(m.x)
		endcase


	endif


	if m.arraylevel = 0


		addproperty(obj,m.vari,m.value)

		expecting = '}'
		expectingvalue = .f.
		expectingpropertyname = .t.

	else

		anuevoel(obj,m.arrayname,m.value,m.bidim,@m.colpos,@m.rowpos)
		expecting = ']'
		expectingvalue = .t.
		expectingpropertyname = .f.

	endif

	expecting = iif(m.isstring,',','')+m.expecting


	do case
	case m.closechar = ']'
		closearray()
	case m.closechar = '}'
		closeobject()
	endcase

endcase


*------------------------------
function closearray()
*------------------------------

if ostack.pop() # 'A'
	error 'unexpected ] '
endif

if m.arraylevel = 0
	error 'unexpected ] '
endif

arraylevel = m.arraylevel-1

if m.arraylevel = 0

	arrayname = ''
	rowpos = 0
	colpos = 0

	expecting = iif(ostack.isobject(),',}','')
	expectingpropertyname = .t.
	expectingvalue = .f.

else

	if  m.bidim
		rowpos = m.rowpos+1
		colpos = 0
		expecting = ',]['
	else
		expecting = ',]'
	endif

	expectingvalue = .t.
	expectingpropertyname = .f.

endif



*-------------------------------------
procedure closeobject
*-------------------------------------

if ostack.pop() # 'O'
	error 'unexpected }'
endif

if m.arraylevel = 0
	expecting = ',}'
	expectingvalue = .f.
	expectingpropertyname = .t.
	objectopen = .f.
else
	expecting = ',]'
	expectingvalue = .t.
	expectingpropertyname = .f.
endif


*----------------------------------------------
function revivecollection( o )
*----------------------------------------------

private all

oconv = createobject('empty')

nprop = amembers(elem,m.o,0,'U')

for x = 1 to m.nprop

	estavar = m.elem(x)

	esarray = .f.
	escoleccion = type('m.o.'+m.estavar) = 'O' and right( m.estavar , 14 ) $ '_KV_COLLECTION,_KL_COLLECTION' and type( 'm.o.'+m.estavar+'.collectionitems',1) = 'A'

	do case
	case m.escoleccion

		estaprop = createobject('collection')

		tv = m.o.&estavar

		m.keyvalcoll = right( m.estavar , 14 ) = '_KV_COLLECTION'
		
		if not ( alen(m.tv.collectionItems) = 1 and isnull( m.tv.collectionItems ) )
		

		for t = 1 to alen(m.tv.collectionitems)

			if m.keyvalcoll
				esteval = m.tv.collectionitems(m.t).value
			else
				esteval = m.tv.collectionitems(m.t)
			endif


			if vartype(m.esteval) = 'O' or type('esteVal',1) = 'A'
				esteval = revivecollection(m.esteval)
			endif

			if m.keyvalcoll
				estaprop.add(esteval,m.tv.collectionitems(m.t).key)
			else
				estaprop.add(m.esteval)
			endif

		endfor

endif

	case type('m.o.'+m.estavar,1) = 'A'

		esarray = .t.

		for t = 1 to alen(m.o.&estavar)

			dimension &estavar(m.t)

			if type('m.o.&estaVar(m.T)') = 'O'
				&estavar(m.t) = revivecollection(m.o.&estavar(m.t))
			else
				&estavar(m.t) = m.o.&estavar(m.t)
			endif

		endfor

	case type('m.o.'+estavar) = 'O'
		estaprop = revivecollection(m.o.&estavar)

	otherwise
		estaprop = m.o.&estavar

	endcase


	estavar = strtran( m.estavar,'_KV_COLLECTION', '' )
	estavar = strtran( m.estavar, '_KL_COLLECTION', '' )

	do case
	case m.escoleccion
		addproperty(m.oconv,m.estavar,m.estaprop)
	case  m.esarray
		addproperty(m.oconv,m.estavar+'(1)')
		acopy(&estavar,m.oconv.&estavar)
	otherwise
		addproperty(m.oconv,m.estavar,m.estaprop)
	endcase

endfor

try
	retcollection = m.oconv.collection.baseclass = 'Collection'
catch
	retcollection = .f.
endtry

if m.retcollection
	return m.oconv.collection
else
	return m.oconv
endif


*----------------------------------
function isjsondt( cstr )
*----------------------------------
return iif( len(m.cstr) = 19 ;
	and len(chrtran(m.cstr,'01234567890:T-','')) = 0 ;
	and substr(m.cstr,5,1) = '-' ;
	and substr(m.cstr,8,1) = '-' ;
	and substr(m.cstr,11,1) = 'T' ;
	and substr(m.cstr,14,1) = ':' ;
	and substr(m.cstr,17,1) = ':' ;
	and occurs('T',m.cstr) = 1 ;
	and occurs('-',m.cstr) = 2 ;
	and occurs(':',m.cstr) = 2 ,.t.,.f. )


*-----------------------------------------------------
procedure jsondatetodt( cjsondate )
*-----------------------------------------------------

if m.cJsonDate = '0000-00-00T00:00:00'

	return {}

else

	cret = eval('{^'+rtrim(m.cjsondate,1,"T00:00:00")+'}')
	
	if !empty(m.cret) 
		return m.cret
	else
		error 'Invalid date '+cJsonDate
	endif

endif

******************************************
define class stack as collection
******************************************

*---------------------------
	function pushobject()
*---------------------------
	this.add('O')

*---------------------------
	function pusharray()
*---------------------------
	this.add('A')

*--------------------------------------
	function isobject()
*--------------------------------------
	return this.count > 0 and this.item( this.count ) = 'O'

*--------------------------------------
	function isarray()
*--------------------------------------
	return this.count > 0 and this.item( this.count ) = 'A'

*----------------------------
	function pop()
*----------------------------
	cret = this.item( this.count )
	this.remove( this.count )
	return m.cret

******************************************
enddefine
******************************************
