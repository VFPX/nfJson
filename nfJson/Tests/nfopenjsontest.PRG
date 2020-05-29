*----------------------------------------------------
* nfOpenJson test:
*----------------------------------------------------
close tables all

text to mssample1 noshow
{
  "StringValue":"John",
  "IntValue":45,
  "TrueValue":true,
  "FalseValue":false,
  "NullValue":null,
  "ArrayValue":["a","r","r","a","y"],
  "ObjectValue":{"obj":"ect"}
}
ENDTEXT

nfopenjson( m.mssample1 )
browse title 'object'
? nfopenjson( m.mssample1,'.stringvalue' )
browse title 'string'
? nfopenjson( m.mssample1,'.arrayValue' )
browse title 'Array:'

text to mssample2 noshow
[
  {
    "Order": {
      "Number":"SO43659",
      "Date":"2011-05-31T00:00:00"
    },
    "AccountNumber":"AW29825",
    "Item": {
      "Price":2024.9940,
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
      "Price":2024.9940,
      "Quantity":3
    }
  }
]
ENDTEXT

nfOpenJson( m.msSample2 )
browse

nfOpenJson( m.msSample2,'$.array')
browse

nfOpenJson( m.mssample2,'$.array',';
 - Number   v(200) $.Order.Number  ;
 - Date     t      $.Order.Date    ;
 - Customer v(200) $.AccountNumber  ;
 - itemPrice n(6,2) $.Item.Price ;
 - itemQuantity i   $.Item.Quantity ;
 - Order  JSON')

browse
