*---------------------------------------------
* Marco Plaza, 2017 @nfTools
* usage sample see nfOpenJsonTest.prg
* refer to https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql
* ver 0.9 2017/05/29
*---------------------------------------------
parameters cjsonstr,cpropertypath,returnvalue

private all

kk = nfjsonread(m.cjsonstr)

if isnull(m.kk)
	return .null.
endif

try
	if pcount() > 1

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

case m.returnvalue
	return m.lretval

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

