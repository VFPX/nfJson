
TEXT TO books noshow
[{
  "Library": "Books",
  "Shelf": 5,
  "version": "LIB3.1.2",
  "hash": "hash",
  "Book": [
    {
      "Name": "Ths Blooms",
      "Category": "Fiction"
    },
    {
      "Name": "Legends",
      "Category": "Drama"
    }
  ]
},
{
  "Library": "Books",
  "Shelf": 6,
  "version": "LIB3.1.3",
  "hash": "hash",
  "Book": [
    {
      "Name": "Those Blooms 2",
      "Category": "Another Fiction"
    },
    {
      "Name": "Legends 2",
      "Category": "Drama 2"
    }
  ]
}
]
ENDTEXT


* just for illustration purposes how to flatten objects using nfOpenJson

nfOpenJson( m.books,'$.array',';
- Library c(15) $.Library;
- Shelf n(6) $.Shelf;
- version1 c(10) $.version ;
- Book1Name c(40) $.Book(1).name;
- Book1category c(40) $.Book(1).Category;
- Book2Name c(40) $.Book(2).Name;
- Book2Category c(10) $.book(2).category;
')


Browse

* desired way:


Create Cursor Library ( Library c(15), shelf N(6), Version c(10), hash c(10), Name c(20), category c(20))

jLibrary = nfJsonRead(m.books)

For Each oLibrary In jLibrary.Array

	For Each book In oLibrary.book

		Append Blank
		Gather Name oLibrary
		Gather Name book

	Endfor

Endfor

Browse
