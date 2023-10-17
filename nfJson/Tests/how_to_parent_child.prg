*--------------------------------------------
* using nfJson to create json
* from parent-child cursors:
*--------------------------------------------

Clear
Close Data

Open Database Home()+'samples\northwind\northwind'

Select Top 2 orderid,customerid,orderdate ;
	from orders Order By 1 ;
	into Cursor cursample

* Turn parent cursor to object.rows using nfCursorToObject:

oOrders = nfcursortoobject() && returns an object with a rows array


* get child records for each row:

For Each oOrder In oOrders.Rows

	Select * From orderdetails ;
		where orderid = oorder.orderid ;
		into Cursor curdet

* use nfCursorToObject for child records:
	oOrderdetail = nfcursortoobject()


* then copy the 'rows' array to parent Object:
	AddProperty(oOrder,"orderDetail(1)",Null)
	Acopy(oorderdetail.Rows,oorder.orderdetail)

Endfor

* we have the object Orders, but
* since you want only the array [],
* we need to pass oOrders.Rows to nfJsonCreate;
* so we have to copy the rows:

Acopy(oorders.Rows,arows)

* then just do:
myjson =  nfjsoncreate(@m.arows,.T.)

? m.myjson

