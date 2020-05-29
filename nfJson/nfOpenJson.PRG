*---------------------------------------------
* Marco Plaza, 2017 @nfTools
* usage sample see nfOpenJsonTest.prg
* refer to https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql
*
* ver 0.91 2019/04/03 -
*
*---------------------------------------------
parameters cjson, carraypath, cstruct

carraypath = evl(m.carraypath,'.array')
carraypath = '.'+ltrim(m.carraypath,1,'.','$')

private all

oj = ''

if pcount() < 2
	cres = json2kvcursor( m.cjson )
else
	cres = json2kvcursor( m.cjson, m.carraypath )
endif

if pcount() < 3
	return m.cres
endif

=alines( cc, cstruct,7,'-')

isql = ' SELECT '

for each line in cc

	oproperty  = strextract(M.line,[$.],[ ],1,2)
	castexp    = getwordnum(M.line,2,' ')
	fieldalias = getwordnum(M.line,1,' ')

	cexp =  textmerge("ncast('<< evl(m.oProperty,m.fieldAlias) >> as <<m.castExp>>')")

	if m.castexp = 'JSON'
		m.cexp = 'cast( '+m.cexp+' as m )'
	endif

	m.cexp = m.cexp + ' as '+ m.fieldalias

	isql = isql+' '+m.cexp+','

endfor

isql = rtrim(M.isql,1,',')+' from (cres) where vtooj() into cursor result'

&isql

*-------------------------------
function vtooj()
*-------------------------------
oj = nfjsonread( value )

*------------------------------------
function ncast( path )
*-------------------------------------
if 'as json' $ lower(m.path)

	vname = 'oj.'+getwordnum(m.path,1)

	if type(m.vname,1) = 'A'
		ic = 'acopy('+m.vname+',tarray)'
		&ic
		return nfjsoncreate(@tarray)
	else
		return nfjsoncreate(eval(m.vname))
	endif

else

	return evaluate(' cast( oj.'+m.path+')')

endif

*------------------------------------------------------
function json2kvcursor(cjsonstr,cpropertypath)
*------------------------------------------------------

kk = nfjsonread(m.cjsonstr)

if isnull(m.kk)
	return .null.
endif

try
	if pcount() > 1

		cpropertypath = ltrim(m.cpropertypath,1,'$')
		pname = substr(m.cpropertypath,rat('.',m.cpropertypath)+1)

		if	type('m.kk'+m.cpropertypath,1) = 'A'
			acopy(m.kk&cpropertypath,lretval)
		else
			lretval = evaluate('kk'+m.cpropertypath)
		endif
	else
		lretval = kk
	endif
catch
	lretval = .null.
endtry

do case

case isnull(m.lretval)
	return .null.

otherwise

	cn = sys(2015)

	create cursor ( m.cn ) ( key c(40), value m null, type c(1) )
	do case
	case type('m.lretval',1) = 'A'
		arraytokvtable( @m.lretval )
	case vartype(m.lretval) # 'O'
		tr = createobject('empty')
		addproperty(m.tr,m.pname,m.lretval)
		objecttokvtable( m.tr )
	otherwise
		objecttokvtable( m.lretval )
	endcase

	return m.cn

endcase

*---------------------------------------------
function arraytokvtable( aa )
*---------------------------------------------

nitem = 1
for each thisval in aa

	if vartype(m.thisval) = 'O'
		thisval = nfjsoncreate( m.thisval)
	endif

	insert into (m.cn) ;
		( key, value , type ) ;
		values ;
		( transform(nitem) ,iif(isnull(m.thisval),.null.,cast( m.thisval as m ) ) , vartype( m.thisval ) )
	nitem = m.nitem+1
endfor

*--------------------------------------------------
function objecttokvtable( ox )
*--------------------------------------------------

amembers( op, m.ox )

for each pname in op

	if type('m.oX.&pName',1) = 'A'

		DIMENSION acc(1)

		acopy(m.ox.&pname,acc)
		thisval = nfjsoncreate( @m.acc )

	else

		thisval = m.ox.&pname

		if vartype(m.thisval) = 'O'
			thisval = nfjsoncreate( m.thisval)
		endif

	endif

	insert into (m.cn) ;
		( key, value , type ) ;
		values ;
		( m.pname ,iif(isnull(m.thisval),.null.,cast( m.thisval as m ) ) , vartype( m.thisval ) )

endfor
