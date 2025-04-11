*------------------------------------------------------
* different methods to flatten json objects to cursor:
*------------------------------------------------------
close tables all


text to mssample2 noshow
[
  {
    "Order": {
      "Number":"SO43659",
      "Date":"2011-05-31T00:00:00"
    },
    "AccountNumber":"AW29825",
    "Item": {
      "Price":136.95,
      "Quantity":1
    }
  },
  {
    "Order": {
      "Number":"SO43661",
      "Date":"2011-06-01T00:00:00"
    },
    "AccountNumber":"AW73565",
    "Item": {
      "Price":866.35,
      "Quantity":3
    }
  }
]
ENDTEXT


*------ 1) using nfJsonRead and existing cursor ( preferred way  )

oSrc = nfJsonRead(m.mssample2)


Create Cursor curStruct2 ( Number v(10),Date d,Customer v(10),itemPrice N(10,2),itemQuantity i, Order m )

For Each Row In oSrc.Array

    Insert Into curStruct2 ;
        ( Number,Date ,Customer ,itemPrice ,itemQuantity ,Order ) ;
        VALUES ;
        ( Row.Order.Number, Row.Order.Date, Row.accountNumber, Row.Item.price,Row.Item.quantity, nfJsonCreate(m.row) )

Endfor

Browse Normal Title 'sample 1'

*------- 2) using gather name ( less code , works even if order or item object have missing keys ) 

Create Cursor curStruct3 ( Number v(10),Date d,accountNumber v(10),price N(10,2),quantity i, sourceDoc m )


For Each oRow In oSrc.Array

    Append Blank
    Gather Name oRow
    Gather Name oRow.Order
    Gather Name oRow.Item

    Replace sourceDoc With nfJsonCreate(m.oRow.Order)

Endfor


Browse Normal Title 'sample 2'


* USING NFOPENJSON 

*----- map structure to object:

text to cStruct pretext 8 noshow
 - Number   c(10)   $.Order.Number  
 - Date     t       $.Order.Date    
 - Customer c(10)   $.AccountNumber  
 - itemPrice n(10,2) $.Item.Price 
 - itemQuantity i   $.Item.Quantity 
 - Order  JSON
endtext

nfOpenJson( m.mssample2,'$.array',m.cStruct )
BROWSE TITLE 'sample 3'

*---------- skipping text-endtext if you like for short structures:


nfOpenJson( m.mssample2,'$.array', ';
 - Number   c(10)   $.Order.Number  ;
 - Date     t       $.Order.Date    ;
 - Customer c(10)   $.AccountNumber ;
 - itemPrice n(10,2) $.Item.Price   ;
 - itemQuantity i   $.Item.Quantity ;
 - Order  JSON ;
 ')

BROWSE TITLE 'sample 4'

