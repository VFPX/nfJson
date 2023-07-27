***************
* 
*
***************


TEXT to mssample2 noshow
[
{ "CorpCode": "KAKK01",
"MobNo": "9447820950",
"KitID": "2320007005",
"EwireTxnNo": "2"
},
{ "CorpCode": "KAKK01",
"MobNo": "9544727140",
"KitID": "2320007006",
"EwireTxnNo": "2"
}
]
ENDTEXT

ox = nfJsonRead(m.mssample2)


Create Cursor temp ( corpcode v(10), mobno v(20),kitid v(10), ewireTxnNo v(10) )

For Each Row In ox.Array
	Insert Into temp From Name Row
Endfor

BROWSE TITLE 'using nfJsonRead'


*** using nfOpenJson:

TEXT TO curstruc NOSHOW TEXTMERGE PRETEXT 8
- corpcode v(10) $.corpCode
- mobno v(20) $.mobNo
- kitid v(10) $.kitid
- ewireTxnNo v(10) $.ewireTxnNo
ENDTEXT

nfOpenJson( m.mssample2,'array',m.curstruc)

BROWSE TITLE 'Using nfOpenJson'


