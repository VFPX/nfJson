*-------------------------------------------------------------------
* Created by Marco Plaza @nfTools
* ver 1.100 - 24/02/2016
* enabled collection processing
* ver 1.101 - 24/02/2016
* solved indentation on nested collections
* ver 1.110 -11/03/2016
* -added support for collections inside arrays
* -user can pass aMemembersFlag value
*  ( since Json is intended for DTO creation default value is 'U' )
*   check amembers topic on vfp help file for usage
* changed cr to crlf
* Added Json validation ; throws error for invalid Json.
* ver 1.120
* encode control characters ( chr(0) ~ chr(31) )
*-----------------------------------------------------------------------
parameters ovfp,formattedOutput,nonullarrayitem,crootName,aMembersFlag

#define crlf chr(13)+Chr(10)

private all
amembersFlag = evl(m.amembersFlag,'U')

esarray = type('oVfp',1) = 'A'
esobjeto = vartype(m.ovfp) = 'O'

if !m.esarray and !m.esobjeto
	Error 'must supply a vfp object/array'
	return
endif

_nivel = iif( cast(m.formattedOutput as l ) , 1, -1)

lcPoint = set('Point')
SET POINT TO '.'

do case
case esarray

	ojson = createobject('empty')

	addproperty(ojson,'array(1)')
	acopy(ovfp,ojson.array)
	cjson = procobject(ojson,.f.,m.nonullarrayitem,m.amembersFlag)
	cJson = substr( m.cJson,at('[',m.cJson))

case type('oVfp.BaseClass')='C' and ovfp.baseclass = 'Collection'
	cjson = procobject(ovfp,.t.,m.nonullarrayitem,m.amembersFlag)

	cRootName    = evl(m.cRootName,'collection')
	cjson = '{"'+m.cRootName+collTagName(oVfp)+'": '+cjson+'}'+IIF(formattedoutput,crlf,'')+'}'

otherwise
	cjson = '{'+procobject(ovfp,.f.,m.nonullarrayitem,m.amembersFlag)+'}'

endcase

SET POINT TO (m.lcPoint)

return ltrim(m.cjson)

*----------------------------------------
function collTagName(thiscoll)
*----------------------------------------
return iif( m.thiscoll.Count > 0 And !Empty( m.thiscoll.GetKey(1) ), '_kv_collection','_kl_collection' )

*----------------------------------------------------------------------------------
function procobject(obt,iscollection,nonullarrayitem,amembersFlag)
*----------------------------------------------------------------------------------

if isnull(m.obt)
	return 'null'
endif

private all except _nivel

este = ''

xtabs = nivel(2)

bc = iif(type('m.obt.baseclass')='C',m.obt.baseclass,'?')

iscollection =  bc = 'Collection'

if m.iscollection

	este = m.este+'{ '+m.xtabs
	xtabs = nivel(2)
	este = m.este+'"collectionitems": ['+m.xtabs

	procCollection(obt,m.noNullArrayItem,m.amembersFlag)

	xtabs = nivel(-2)
	este  = m.este+m.xtabs+']'

else

	amembers(am,m.obt,0,m.amembersFlag)

	if vartype(m.am) = 'U'
		xtabs=m.nivel(-2)
		return ''
	endif

	nm = alen(am)

	for x1 = 1 to m.nm

		var = lower(am(m.x1))

		este = m.este+iif(m.x1>1,',','')+m.xtabs

		este = m.este+["]+strtran(m.var,'_vfpsafe_','')+[":]

		esobjeto = type('m.obt.&Var')='O'

		if type('m.obt.&var') = 'U'
			este = m.este+["unable to evaluate expression"]
			loop
		endif

		esarray  = type('m.obt.&Var',1) = 'A'

		do case

		case m.esarray

			procarray(m.obt,m.var,m.nonullarrayitem)

		case m.esobjeto

			thiso=m.obt.&var

			bc = iif(type('m.thiso.baseclass')='C',m.thiso.baseclass,'?')

			if bc = 'Collection'

				este = rtrim(m.este,1,'":')+ collTagName( m.thiso )+'":'

				este =  m.este+procobject(m.obt.&var,.t.,m.nonullarrayitem,m.amembersFlag)+[}]

			else

				este =  m.este+[{]+procobject(m.obt.&var,.f.,m.nonullarrayitem,m.amembersFlag)+[}]

			endif

		otherwise

			este = m.este+concatval(m.obt.&var)

		endcase

	endfor

endif

	xtabs = nivel(-2)
	este  = m.este+m.xtabs

return m.este

*----------------------------------------------------
procedure procarray(obt,arrayName,nonullarrayitem)
*----------------------------------------------------
nrows = alen(m.obt.&arrayName,1)
ncols = alen(m.obt.&arrayName,2)
bidim = m.ncols > 0
ncols = iif(m.ncols=0,m.nrows,m.ncols)
titems = alen(m.obt.&arrayName)

xtabs=nivel(2)

este = m.este+'['+m.xtabs
nelem = 1

do while m.nelem <= m.titems

	este = m.este+iif(m.nelem>1,','+m.xtabs,'')

	if m.bidim
		xtabs = nivel(2)
		este = m.este+'['+m.xtabs
	endif

	for pn = m.nelem to m.nelem+m.ncols-1

		elem = m.obt.&arrayName( m.pn )

		este = m.este+iif(m.pn>m.nelem,','+m.xtabs,'')

		if vartype(m.elem) # 'O'

			if m.nelem+m.ncols-1 = 1 and isnull(m.elem) and m.nonullarrayitem

				este = m.este+""

			else
				este = m.este+concatval(m.elem)

			endif

		else

			bc = iif(type('m.elem.baseclass')='C',m.elem.baseclass,'?')

			if bc = 'Collection'

				este = m.este+' { "collection'+ collTagName( m.elem )+'":'

   				este =  m.este+procobject(m.elem ,.t.,m.nonullarrayitem,m.amembersFlag)

				este = m.este + '}'+m.xTabs+'}'

			else

   				este =  m.este+[{]+procobject(m.elem ,.f.,m.nonullarrayitem,m.amembersFlag)+[}]

			endif


		endif

	endfor

	nelem = m.pn

	if m.bidim
		xtabs=nivel(-2)
		este = m.este+m.xtabs+']'
	endif

enddo

xtabs=nivel(-2)

este = m.este+m.xtabs+']'

*-----------------------------
function nivel(n)
*-----------------------------
if m._nivel = -1
	return ''
else
	_nivel= m._nivel+m.n
	return crlf+replicate('  ',m._nivel)
endif

*-----------------------------
function concatval(valor)
*-----------------------------

#define specialChars ["\/]+chr(127)+chr(12)+chr(10)+chr(13)+chr(9)+CHR(0)+CHR(1)+CHR(2)+CHR(3)+CHR(4)+CHR(5)+CHR(6)+CHR(7)+CHR(8)+CHR(9)+CHR(10)+CHR(11)+CHR(12)+CHR(13)+CHR(14)+CHR(15)+CHR(16)+CHR(17)+CHR(18)+CHR(19)+CHR(20)+CHR(21)+CHR(22)+CHR(23)+CHR(24)+CHR(25)+CHR(26)+CHR(27)+CHR(28)+CHR(29)+CHR(30)+CHR(31)

if isnull(m.valor)

	return 'null'

else

	tvar = vartype(m.valor)
	** no cambiar el orden de ejecución!
	do case
	case m.tvar $ 'FBYINQ'
		vc = rtrim(cast( m.valor as c(32)))
	case m.tvar = 'L'
		vc = iif(m.valor,'true','false')
	case m.tvar $ 'DT'
		vc = ["]+ttoc(m.valor,3)+[Z"]
	case mustEncode(m.valor)
		vc = ["]+escapeandencode(m.valor)+["]
	case m.tvar $ 'CVM'
		vc = ["]+rtrim(m.valor)+["]
	case m.tvar $ 'GQW'
		vc = ["]+strconv(m.valor,13)+["]
	endcase

	return m.vc

endif

*-----------------------------------
FUNCTION mustEncode(valor)
*-----------------------------------
RETURN len(chrtran(m.valor,specialChars,'')) <> len(m.valor)

*-------------------------------
function escapeandencode(valun)
*-------------------------------
valun = strtran(m.valun,'\','\\')
valun = strtran(m.valun,'"','\"')
*valun = Strtran(m.valun,'/','\/')

IF !mustEncode(m.valun)
	RETURN
ENDIF

valun = strtran(m.valun,chr(127),'\b')
valun = strtran(m.valun,chr(12),'\f')
valun = strtran(m.valun,chr(10),'\n')
valun = strtran(m.valun,chr(13),'\r')
valun = strtran(m.valun,chr(9),'\t')

IF !mustEncode(m.valun)
	RETURN
ENDIF

LOCAL x
FOR x = 0 TO 31
	valun = strtran(m.valun,chr(m.x),'\u'+RIGHT(TRANSFORM(m.x,'@0'),4))
ENDFOR

return RTRIM(m.valun)

*---------------------------------------------------------------
Function procCollection(obt,nonullArrayItems,amembersFlag )
*---------------------------------------------------------------

local isCollection

With obt

	nm = .Count

	conllave = .Count > 0 And !Empty(.GetKey(1))

	For x1 = 1 To .Count

		If m.conllave
			elem = Createobject('empty')
			addproperty(elem,'Key', .GetKey(m.x1) )
			addproperty(elem,'Value',.Item(m.x1))
		Else
			elem = .Item(m.x1)
		Endif

		este = m.este+Iif(m.x1>1,','+m.xtabs,'')

		If Vartype(m.elem) # 'O'

			este = m.este+Concatval(m.elem)

		else

			if vartype( m.elem.baseclass ) = 'C' and m.elem.baseclass = 'Collection'
				isCollection = .t.
				este = m.este+'{ '+m.xTabs+'"collection'+collTagName(m.elem)+'" :'
				xTabs = nivel(2)
			else
				isCollection = .f.
				m.este = m.este+'{'
			endif

			este = m.este+procObject(m.elem, m.isCollection , m.noNullArrayItem, m.aMembersFlag )

			este = m.este+'}'

			if m.isCollection
				xTabs = nivel(-2)
				este = m.este+m.xTabs+'}'
			endif

		Endif

	endfor

	este = rtrim(m.este,1,m.xTabs)

Endwith
