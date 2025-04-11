*---------------------------------------------
* Marco Plaza, 2017 @nfTools
* usage sample see json_to_cursor_test.prg
* 
* refer to https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql
*
* ver 0.91 2019/04/03 -
*
*---------------------------------------------
Parameters cjson, carraypath, cstruct

carraypath = Evl(m.carraypath,'.array')
carraypath = '.'+Ltrim(m.carraypath,1,'.','$')

Private All

Try

  oj = ''

  Do Case
  Case Pcount() = 1
    cres = json2kvcursor( m.cjson )
  Case Pcount() = 3
    cres = json2kvcursor( m.cjson, m.carraypath )
  Otherwise
    Error 'missing parameter'
  Endcase


  =Alines( cc, cstruct,7,'-')

  isql = ' SELECT '

  For Each Line In cc

    oproperty  = Strextract(M.line,[$.],[ ],1,2)
    castexp    = Getwordnum(M.line,2,' ')
    fieldalias = Getwordnum(M.line,1,' ')

    cexp =  Textmerge("ncast('<< evl(m.oProperty,m.fieldAlias) >> as <<m.castExp>>')")

    If m.castexp = 'JSON'
      m.cexp = 'cast( '+m.cexp+' as m )'
    Endif

    m.cexp = m.cexp + ' as '+ m.fieldalias

    isql = isql+' '+m.cexp+','

  Endfor

  isql = Rtrim(M.isql,1,',')+' from (cres) where vtooj() into cursor result'

  &isql

Catch To oerror

Endtry

If Vartype(m.oerror) = 'O'
  Error oerror.Message
Endif

*-------------------------------
Function vtooj()
*-------------------------------
oj = nfjsonread( Value )

*------------------------------------
Function ncast( Path )
*-------------------------------------
If 'as json' $ Lower(m.path)

  vname = 'oj.'+Getwordnum(m.path,1)

  If Type(m.vname,1) = 'A'
    ic = 'acopy('+m.vname+',tarray)'
    &ic
    Return nfjsoncreate(@tarray)
  Else
    Return nfjsoncreate(Eval(m.vname))
  Endif

Else

  Return Evaluate(' cast( oj.'+m.path+')')

Endif

*------------------------------------------------------
Function json2kvcursor(cjsonstr,cpropertypath)
*------------------------------------------------------

kk = nfjsonread(m.cjsonstr)

If Isnull(m.kk)
  Return .Null.
Endif

Try
  If Pcount() > 1

    cpropertypath = Ltrim(m.cpropertypath,1,'$')
    pname = Substr(m.cpropertypath,Rat('.',m.cpropertypath)+1)

    If   Type('m.kk'+m.cpropertypath,1) = 'A'
      Acopy(m.kk&cpropertypath,lretval)
    Else
      lretval = Evaluate('kk'+m.cpropertypath)
    Endif
  Else
    lretval = kk
  Endif
Catch
  lretval = .Null.
Endtry

Do Case

Case Isnull(m.lretval)
  Return .Null.

Otherwise

  cn = Sys(2015)

  Create Cursor ( m.cn ) ( Key c(40), Value m Null, Type c(1) )
  Do Case
  Case Type('m.lretval',1) = 'A'
    arraytokvtable( @m.lretval )
  Case Vartype(m.lretval) # 'O'
    tr = Createobject('empty')
    AddProperty(m.tr,m.pname,m.lretval)
    objecttokvtable( m.tr )
  Otherwise
    objecttokvtable( m.lretval )
  Endcase

  Return m.cn

Endcase

*---------------------------------------------
Function arraytokvtable( aa )
*---------------------------------------------

nitem = 1
For Each thisval In aa

  If Vartype(m.thisval) = 'O'
    thisval = nfjsoncreate( m.thisval)
  Endif

  Insert Into (m.cn) ;
    ( Key, Value , Type ) ;
    values ;
    ( Transform(nitem) ,Iif(Isnull(m.thisval),.Null.,Cast( m.thisval As m ) ) , Vartype( m.thisval ) )
  nitem = m.nitem+1
Endfor

*--------------------------------------------------
Function objecttokvtable( ox )
*--------------------------------------------------

Amembers( op, m.ox )

For Each pname In op

  If Type('m.oX.&pName',1) = 'A'

    Dimension acc(1)

    Acopy(m.ox.&pname,acc)
    thisval = nfjsoncreate( @m.acc )

  Else

    thisval = m.ox.&pname

    If Vartype(m.thisval) = 'O'
      thisval = nfjsoncreate( m.thisval)
    Endif

  Endif

  Insert Into (m.cn) ;
    ( Key, Value , Type ) ;
    values ;
    ( m.pname ,Iif(Isnull(m.thisval),.Null.,Cast( m.thisval As m ) ) , Vartype( m.thisval ) )

Endfor
