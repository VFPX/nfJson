**********************************************
* collections to json and back to vfp
**********************************************
Public oCol,oDebugCollection

Close Databases All
Set Talk Off
Set Safety Off

IF UPPER(RIGHT(CURDIR(),14)) # upper('\nfJson\tests\')
	MESSAGEBOX('Please run from nfJson\tests',0)
	RETURN
ENDIF

Set Path To ..\   && nfJson folder additive

Try
	Erase temp\test_*.json
	MD temp
Catch

Endtry

Clear

oparent = CREATEOBJECT('empty')

ADDPROPERTY(oParent,'collectionTest1',Createobject("collection"))
oCollection = Createobject("collection")

addcollection( oParent.collectionTest1 )
addcollection( oCollection )

Clear

Erase temp\colltest.json

****** CONVERT COLLECTION TO JSON AND SHOW FILE:

Set Path To ..\

declare arrayTest(2)

* test 1: object with collection and collection as array items
arrayTest(1) = m.oParent
arrayTest(2) = m.oCollection
cJson1 = nfJsonCreate(@arrayTest,.T.,.T.)

* test 2
* myforms is the name we want to assign to the root element ( the collection ) of resulting object
cJson2 = nfJsonCreate(oCollection,.T.,.T.,'myForms')

Strtofile( m.cJson2 ,'temp\colltest.json')

Modify File temp\colltest.json

&& reset the variable, open debugger may not show object changes if you don't do so.

oCollectionFromJson1 = ''
oDebugCollection1 = ''

oCollectionFromJson1 = nfJsonRead(m.cJson1,.T.) && <- this will parse json and create a vfp collection
oDebugCollection1 = nfJsonRead(m.cJson1) && <- this will parse object as it is represented in json

oCollectionFromJson2 = ''
oDebugCollection2 = ''

oCollectionFromJson2 = nfJsonRead(m.cJson2,.T.) && <- this will parse json and create a vfp collection
oDebugCollection2 = nfJsonRead(m.cJson2) && <- this will parse object as it is represented in json

*** test:
* note: revived items of keyless collections may not appear on the original position
* this is a problem not only for nfJson but any array to object serialization
* check:
*
* https://www.firebase.com/docs/rest/guide/understanding-data.html
* https://www.firebase.com/blog/2014-04-28-best-practices-arrays-in-firebase.html
*
* rule: avoid keyless collections if you need to hard code element positions or depend on them somehow
*
* test 1:
* messagebox( [ oCollectionFromJson.array(2).Item(5).item(3).item(4).item('Product') = ]+ oCollectionFromJson.array(1).Item(5).item(3).item(4).item('Product'),0)
 messagebox( [ oCollectionFromJson1.array(1).collectiontest1.Item(5).item(3).item(4).item('Product') = ]+ oCollectionFromJson1.array(1).collectionTest1.Item(5).item(3).item(4).item('Product'),0)
 messagebox( [ oCollectionFromJson1.array(2).Item(5).item(3).item(4).item('Product') = ]+ oCollectionFromJson1.array(2).Item(5).item(3).item(4).item('Product'),0)

* test 2: ( using root name for collection object )
messagebox( [ oCollectionFromJson2.myforms.Item(5).item(3).item(4).item('Product')  = ]+ oCollectionFromJson2.myforms.Item(5).item(3).item(4).item('Product'),0)

*---------------------------------------
FUNCTION addcollection( oo )
*---------------------------------------
WITH m.oo

	.Add(123) && item 1
	.Add("AAA") && item 2
	.Add(createobject("empty")) && item 3
	.Add(Createobject("session")) && item 4
	.Add(Createobject("collection")) && item 5

	With .Item(5)

		.Add(456) && item 1
		.Add("BBB") && item 2
		.Add(Createobject("collection")) && item 3

		With .Item(3)

			.Add(789) && item 1
			.Add("CCC") && item 2
			.Add(Createobject("session")) && item 3
			.Add(Createobject("Collection")) && item 4

			with .Item(4)
				.Add('VFP','Product')
				.Add(Program(),'Executing program Name')
			endwith

		Endwith

		.Add(Createobject("container")) && item 5

	Endwith

Endwith
