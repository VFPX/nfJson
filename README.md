# nfJson

Project developer: Marco Plaza  [GitHub/nfoxdev](https://github.com/nfoxdev)

[Issues?](https://github.com/VFPX/nfJson/issues) - [Discussions/Ideas](https://github.com/VFPX/nfJson/discussions)

**A set of fast performance, reliable and easy to use Json functions using pure VFP.**

## Functions & Usage

( Each function is a single prg -  No additional dependencies / Requires VFP9 )

* oJson = **nfJsonRead(**cJsonString , _lReviveCollections_**)**  
 Example :   
 jsonstr = '{"name":"John", "age":30, "family":{"wife":"Susana","son":"Tom"}, "location":"texas"}'  
 vfpobj = nfJsonRead(jsonstr)  
 ? vfpobj.age    && 30     
 ? vfpobj.family.son  && Tom

*lReviveCollections: nfJsoncreate stringify key/keyless kcollections as arrays; set this flag if you are parsing json created with nfjsoncreate that
you know have a vfp collection; this will  perform a extra step to get your collections back from the array representation ( revive it ) or set it to
false to view your collections as arrays for debugging purposes  -check collectiontest.prg in test folder.

* cJsonString = **nfJsonCreate(**oVfp, _lFormattedOutput, lNoNullArrayItems,cRootName,aMembersFlag_**)**

* **nfJsonToCursor(**cJson, _cCursorName ,  lForceImportFromArray_**)** ( creates cursor back from Json created using nfCursorToJson4vfp,
 for any other case see nfOpenJson and notes below: )

* cJsonString = **nfCursorToJson4vfp()**  _&& converts current open table/cursor to Json suitable for later use of nfJsonToCursor()_

* cJsonString = **nfCursorToJson(**_lReturnArray, lArrayofValues, lIncludestruct, lFormattedOutput_**)**    converts current open table/cursor to Json

* oJson = **nfCursorToObject(**_lCopyToArray, lIncludeStruct_**)**

* cJsonString = **jsonFormat( cJsonStr )\*** Format json string w/o validate or change element positions

* nfOpenJson(** cJsonString , [ cArrayPath ], [cCursorStructure & object mappings ] )

	Similar to SqlServer 2016 openJson function 

To convert json to cursor:

For simple 1:1 conversion I recommend to
simply use nfJsonRead and a existing
destination cursor like this:

```
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

```


** Use nfOpenJson to flatten objects
 with ease ( check a discussion here https://www.tek-tips.com/viewthread.cfm?qid=1796615 )

```
*** using nfOpenJson:

TEXT to mssample3 noshow
[
{ "CorpCode": "KAKK01",
"MobNo": "9447820950",
"KitID": "2320007005",
"EwireTxnNo": "2",
"person":{"name":"Curt","age":54,"phone":["12345","5645466"]}
},
{ "CorpCode": "KAKK01",
"MobNo": "9544727140",
"KitID": "2320007006",
"EwireTxnNo": "2",
"person":{"name":"David","age":55,"phone":["142145","4665465"]}
}
]
ENDTEXT

TEXT TO curstruc NOSHOW TEXTMERGE PRETEXT 8
- corpcode v(10) $.corpCode
- mobno v(20) $.mobNo
- kitid v(10) $.kitid
- ewireTxnNo v(10) $.ewireTxnNo
- name v(10) $.person.Name
- age i $.person.age
- phone1 v(10) $.person.phone[1]
- phone2 v(10) $.person.phone[2]
ENDTEXT

nfOpenJson( m.mssample3,'array',m.curstruc)

BROWSE TITLE 'Using nfOpenJson'
```


## Tests & Sample files

* **nfOpenJsonTest:** samples taken from [https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql](https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql)

*  **nfJsonPerfTest.prg:** just run it and choose one of the embedded json samples from the list to check performance on your pc. ( Allows you to parse Json from clipboard too. )

* **examples.prg**  will parse the next Json files included in  JsonSamples folder. just run from test folder and see sample code and output.

* **collectionTest.prg:** creates a complex collection , converts it to Json and back to vfp.

* Sample Json files included:
	* youtubesearch.json
	* cycloneForecast.json
	* dropbox.json
	* googleMapsDistance.json
	* iphone photo.json
	* mapquest.json
	* mySimpleArray.json
	* tweeter.json
	* weatherService.json
	* yahooweather.json

## Release Notes

2022/07/09 ( PatrickvonDeetzen )
* create json with special characters is now significantly faster (changes made in function "escapeandencode")
* updated performance test & added new test sample
* bug fix: missing m. in nfcursortoobject.prg

2019/06/14

* JsonFormat function by Carlos Alloati

2017/08/05

* no matter wich strictdate setting you have set, a JsonDateTime "0000-00-00T00:00:00" will return an empty date.
* valid JsonDates with time "T00:00:00" will return a date value ( ie: {"testDate":"2017-12-01T00:00:00"} )
* invalid dates ( ie 2017/50/50 ) properly formatted as Json Date ( ie: 2017-50-50T00:00:00 ) will throw error;
 ( previous behavior was to return .null. )

2017/03/10

* fixed: proper support for 19 character strings with ISO basic date format & different strictdate settings.

2017/02/05

* fixed: nfJsonRead bug fix: incorrect parsing for strings terminated with escaped double quotes; minor changes & code refactoring.

2017/01/11

* fixed: nfJsonRead: incorrect unescaped output with "set exact = on"
* escapetest.prg - removed "leftover" lines.

2017/01/11

* fixed issue escaping values terminated with "
* nfJsonRead: removed parameter "isFile" now you can just pass a file name or string
* added test: escapeTest.prg

2016/09/28

* minor bug fix: zero item collections created as 1 empty item collection
* proper indent for raw/formatted collection objects

2016/08/16

* nfJsonPerfTest: added compiled exe, samples file ships as a separate file for you to edit
* fixed bug on test prgs: clean installs would fail due to missing temp folder on distribution zip w/o tests\temp folder
* fixed bug on collectionTest

2016/07/22

* nfJsonRead: Improved error management
* CollectionTest: added new test

2016/07/20

* Fixed bug: missing closing curly brace on collections as object member
* Updated collections program test

2016/07/09

* Automatic cast for datetime properties ( ISO-8601 basic format & vfp compilant as described on [https://en.wikipedia.org/wiki/ISO_8601#Times](https://en.wikipedia.org/wiki/ISO_8601#Times). )
* nfJsonToCursor Bug Fix: "Date/datetime evaluated to an invalid value" while running under "strictdate = 1" converting empty dates back from Json

2016/07/04

* Added support for control characters encoding ( chr( 0) ~ chr(31) )

2016/05/05

* invalid Json error shows calling program information

2016/04/02

* complex nested objects/arrays validation
* missing object/array closures validation

2016/03/28

* nfJsonRead performs JSON validation: invalid Json throws error indicating reason.
* nfJsonPerfTest: proper error management enabled for invalid Json input from clipboard
* nfJsonToCursor: use of strict date format
