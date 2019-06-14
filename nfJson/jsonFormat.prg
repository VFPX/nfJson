*-------------------------------------------------------------
* Json Format
* Carlos Alloati, 10/06/2019
* VFPX License
*-------------------------------------------------------------
Lparameters pjson
Local c1, c2, cb, instring, jsonfmt, nlen, nlevel, nx

m.pjson = Alltrim(m.pjson)
m.nlevel = 0
m.instring = .F.
m.jsonfmt = ''
m.c1 = ''
m.c2 = ''
m.nlen = Len(m.pjson)

For m.nx = 1 To m.nlen

	m.cb = Substr(m.pjson, m.nx, 1)

	If m.nx > 1 Then
		m.c1 = Substr(m.pjson, m.nx - 1, 1)
	Endif
	If m.nx < m.nlen Then
		m.c2 = Substr(m.pjson, m.nx + 1, 1)
	Endif
	If  m.cb == '"' And Not m.c1 = '\'
		m.instring = Not m.instring
	Endif
	If m.instring = .F. And m.cb $ '{['
		m.nlevel = m.nlevel + 1
	Endif
	If m.instring = .F. And m.cb $ '}]'
		m.nlevel = m.nlevel - 1
	Endif

	Do Case
	Case m.instring = .F. And m.cb == '[' And m.c2 == ']'
		m.jsonfmt = m.jsonfmt + m.cb
	Case m.instring = .F. And m.cb == ']' And m.c1 == '['
		m.jsonfmt = m.jsonfmt + m.cb
	Case m.instring = .F. And m.cb $ ',{['
		m.jsonfmt = m.jsonfmt + m.cb + 0h0d0a + Space(m.nlevel * 2)
	Case m.instring = .F. And m.cb $ ',}]'
		m.jsonfmt = m.jsonfmt + 0h0d0a + Space(m.nlevel * 2) + m.cb
	Otherwise
		m.jsonfmt = m.jsonfmt + m.cb
	Endcase

Endfor

Return m.jsonfmt
