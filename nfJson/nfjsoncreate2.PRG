*-------------------------------------------------------------------
* Created by Marco Plaza @vfp2Nofox
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
parameters ovfp,formattedoutput,nonullarrayitem,crootname,amembersflag

#define crlf chr(13)+chr(10)

private all

if vartype(formattedoutput) = 'C' and lower(m.formattedoutput) = 'nson'

	formattedoutput = .t.
	_nson = .t.
	_propdelimopen = '.'
	_propdelimclose = ''
	_propseparator = ''
	_arrayopen = '[]'
	_arrayclose = ''
	_arrayitemseparator = ''
	_arraybidim = '.item'
	_arrayitemst = '.item = '
	_arrayitemct = '.item: '
	_arraycomplex = ''
	_simpletype = ' = '
	_complextype = ':'
	_objectopen =''
	_objectclose = ''
	_indentchar = chr(9)

else

	_nson = .f.
	_propdelimopen = '"'
	_propdelimclose = '"'
	_propseparator = ','
	_arraybidim  = ''
	_arrayopen   = '['
	_arrayclose  = ']'
	_arrayitemseparator = ','
	_arrayitemst  =  ''
	_arrayitemct  = ''
	_arraycomplex = ':'
	_simpletype  = ':'
	_complextype = ':'
	_objectopen  ='{'
	_objectclose = '}'
	_indentchar  = space(3)

endif


amembersflag = evl(m.amembersflag,'U')

esarray = type('oVfp',1) = 'A'
esobjeto = vartype(m.ovfp) = 'O'

if !m.esarray and !m.esobjeto
	error 'must supply a vfp object/array'
endif

_nivel = icase(  !cast(m.formattedoutput as l ) , -2, _nson, -1, 0 )

do case
case esarray

	ojson = createobject('empty')

	addproperty(ojson,'array(1)')
	acopy(ovfp,ojson.array)
	cjson = procobject(ojson,.f.,m.nonullarrayitem,m.amembersflag)
	cjson = substr( m.cjson,at(_arrayopen,m.cjson))


case type('oVfp.BaseClass')='C' and ovfp.baseclass = 'Collection'
	cjson = procobject(ovfp,.t.,m.nonullarrayitem,m.amembersflag)

	crootname    = evl(m.crootname,'collection')
	cjson = _objectopen+m._propdelimopen+m.crootname+colltagname(ovfp)+'": '+cjson+m._objectclose+iif(formattedoutput,crlf,'')+m._objectclose

otherwise
	cjson = _objectopen+procobject(ovfp,.f.,m.nonullarrayitem,m.amembersflag)+m._objectclose

endcase


return ltrim(cjson)

*----------------------------------------
function colltagname(thiscoll)
*----------------------------------------
return iif( m.thiscoll.count > 0 and !empty( m.thiscoll.getkey(1) ), '_kv_collection','_kl_collection' )

*----------------------------------------------------------------------------------
function procobject(obt,iscollection,nonullarrayitem,amembersflag)
*----------------------------------------------------------------------------------


if isnull(m.obt)
	return 'null'
endif

private all except _*


este = ''

xtabs = nivel(1)

bc = iif(type('m.obt.class')='C',m.obt.class,'?')

iscollection =  bc = 'Collection'

if m.iscollection


	este = este+m._objectopen+' '+xtabs
	xtabs = nivel(1)
	este = este+m._propdelimopen+'collectionitems'+m._propdelimclose+m._arraycomplex+m._arrayopen+xtabs

	proccollection(obt,m.nonullarrayitem,m.amembersflag)

	xtabs = nivel(-1)
	este  = este+xtabs+m._arrayclose

else

	amembers(am,m.obt,0,m.amembersflag)

	if vartype(m.am) = 'U'
		xtabs=m.nivel(-1)
		return ''
	endif


	nm = alen(am)

	for x1 = 1 to m.nm

		var = lower(am(m.x1))

		este = m.este+iif(m.x1>1,_propseparator,'')+m.xtabs

		este = m.este+M._propdelimopen+strtran(m.var,'_vfpsafe_','')+m._propdelimclose

		esobjeto = type('m.obt.&Var')='O'

		if type('m.obt.&var') = 'U'
			este = m.este+["unable to evaluate expression"]
			loop
		endif

		esarray  = type('m.obt.&Var',1) = 'A'

		do case

		case m.esarray

			este = m.este+m._arraycomplex

			procarray(obt,m.var,m.nonullarrayitem)

		case m.esobjeto

			thiso=m.obt.&var

			bc = iif(type('m.thiso.class')='C',m.thiso.class,'?')

			if bc = 'Collection'

				este = rtrim(m.este,1,'"')+ colltagname( m.thiso )+'"'+m._complextype

				este =  m.este+procobject(m.obt.&var,.t.,m.nonullarrayitem,m.amembersflag)+m._objectclose

			else

				este = m.este+':'
				este =  m.este+m._objectopen+procobject(m.obt.&var,.f.,m.nonullarrayitem,m.amembersflag)+m._objectclose

			endif

		otherwise

			este = m.este+m._simpletype

			este = este+concatval(m.obt.&var)

		endcase

	endfor


endif

xtabs = nivel(-1)
este  = este+m.xtabs


return m.este


*----------------------------------------------------
procedure procarray(obt,arrayname,nonullarrayitem)
*----------------------------------------------------
nrows = alen(m.obt.&arrayname,1)
ncols = alen(m.obt.&arrayname,2)
bidim = m.ncols > 0
ncols = iif(m.ncols=0,m.nrows,m.ncols)
titems = alen(m.obt.&arrayname)

xtabs=nivel(1)

este = m.este+m._arrayopen+m.xtabs
nelem = 1

do while nelem <= m.titems

	este = este+iif(m.nelem>1,_arrayitemseparator+m.xtabs,'')

	if m.bidim
		xtabs = nivel(1)
		este = m.este+m._arraybidim+m._arrayopen+m.xtabs
	endif

	for pn = m.nelem to m.nelem+m.ncols-1

		elem = m.obt.&arrayname( m.pn )

		este = m.este+iif(m.pn>m.nelem,_arrayitemseparator+m.xtabs,'')

		if vartype(m.elem) # 'O'

			este = este+m._arrayitemst

			if m.nelem+m.ncols-1 = 1 and isnull(m.elem) and m.nonullarrayitem

				este = m.este+""

			else
				este = m.este+concatval(m.elem)

			endif

		else


			este = este+m._arrayitemct

			bc = iif(type('m.elem.class')='C',m.elem.class,'?')

			if bc = 'Collection'

				este = m.este+' '+m._objectopen+' '+m._propdelimopen+'collection'+ colltagname( m.elem )+m._propdelimclose+':'


				este =  m.este+procobject(m.elem ,.t.,m.nonullarrayitem,m.amembersflag)

				este = este + _objectclose+m.xtabs+m._objectclose


			else

				este =  m.este+m._objectopen+procobject(m.elem ,.f.,m.nonullarrayitem,m.amembersflag)+m._objectclose

			endif


		endif

	endfor

	nelem = m.pn

	if m.bidim
		xtabs=nivel(-1)
		este = m.este+m.xtabs+m._arrayclose
	endif

enddo


xtabs=nivel(-1)

este = m.este+m.xtabs+m._arrayclose



*-----------------------------
function nivel(n)
*-----------------------------
if m._nivel = -2
	return ''
else
	_nivel= m._nivel+m.n
	return crlf + iif( _nivel > 0, replicate(_indentchar,m._nivel),'')
endif

*-----------------------------
function concatval(valor)
*-----------------------------

#define specialchars ["\/]+chr(127)+chr(12)+chr(10)+chr(13)+chr(9)+chr(0)+chr(1)+chr(2)+chr(3)+chr(4)+chr(5)+chr(6)+chr(7)+chr(8)+chr(9)+chr(10)+chr(11)+chr(12)+chr(13)+chr(14)+chr(15)+chr(16)+chr(17)+chr(18)+chr(19)+chr(20)+chr(21)+chr(22)+chr(23)+chr(24)+chr(25)+chr(26)+chr(27)+chr(28)+chr(29)+chr(30)+chr(31)

if isnull(m.valor)

	return 'null'

else


	tvar = vartype(m.valor)
** no cambiar el orden de ejecución!
	do case
	case m.tvar $ 'FBYINQ'
		vc = rtrim(cast( m.valor as c(32)))
	case m.tvar = 'L' 
	 if !_nson
		vc = iif(m.valor,'true','false')
	 else
	 	vc = iif( m.valor ,'.t.','.f.')
	 endif
	case m.tvar $ 'DT'
		vc = ["]+ttoc(m.valor,3)+["]
	case mustencode(m.valor)
		vc = ["]+escapeandencode(m.valor)+["]
	case m.tvar $ 'CVM'
		vc = ["]+rtrim(m.valor)+["]
	case m.tvar $ 'GQW'
		vc = ["]+strconv(m.valor,13)+["]
	endcase

	return m.vc

endif

*-----------------------------------
function mustencode(valor)
*-----------------------------------
return len(chrtran(m.valor,specialchars,'')) <> len(m.valor)

*-------------------------------
function escapeandencode(valun)
*-------------------------------
valun = strtran(m.valun,'\','\\')
valun = strtran(m.valun,'"','\"')
*valun = Strtran(m.valun,'/','\/')

if !mustencode(m.valun)
	return
endif

valun = strtran(m.valun,chr(127),'\b')
valun = strtran(m.valun,chr(12),'\f')
valun = strtran(m.valun,chr(10),'\n')
valun = strtran(m.valun,chr(13),'\r')
valun = strtran(m.valun,chr(9),'\t')

if !mustencode(m.valun)
	return
endif

local x
for x = 0 to 31
	valun = strtran(m.valun,chr(m.x),'\u'+right(transform(m.x,'@0'),4))
endfor

return rtrim(m.valun)



*---------------------------------------------------------------
function proccollection(obt,nonullarrayitems,amembersflag )
*---------------------------------------------------------------

local iscollection

with obt

	nm = .count

	conllave = .count > 0 and !empty(.getkey(1))

	for x1 = 1 to .count

		if conllave
			elem = createobject('empty')
			addproperty(elem,'Key', .getkey(x1) )
			addproperty(elem,'Value',.item(x1))
		else
			elem = .item(x1)
		endif

		este = este+iif(x1>1,_propseparator+xtabs,'')

		if vartype(elem) # 'O'

			este = este+concatval(m.elem)

		else

			if vartype( m.elem.baseclass ) = 'C' and m.elem.baseclass = 'Collection'
				iscollection = .t.
				este = m.este+m._objectopen+' '+m.xtabs+m._propdelimopen+'collection'+colltagname(m.elem)+m._propdelimclose+' :'
				xtabs = nivel(1)
			else
				iscollection = .f.
				m.este = m.este+m._objectopen
			endif

			este = este+procobject(m.elem, m.iscollection , m.nonullarrayitem, m.amembersflag )

			este = este+m._objectclose

			if m.iscollection
				xtabs = nivel(-1)
				este = este+m.xtabs+m._objectclose
			endif

		endif

	endfor

	este = rtrim(m.este,1,m.xtabs)

endwith
