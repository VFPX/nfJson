
CREATE CURSOR response ( id i,name v(20), secondname v(20) )

responseType1 = ' { "persons": [ { "id":1, "name":"John" , "secondName": "Doe" }, { "id":1, "name":"Jane" , "secondName": "Doe" } ] } '


oResponse = nfJsonRead( m.responseType1 ) 


For Each oRow In oResponse.persons
    Insert Into response From Name oRow
Endfor



* from unnamed array:

responseType2 = '[ { "id":1, "name":"John 2" , "secondName": "Doe 2" }, { "id":1, "name":"Jane 2" , "secondName": "Doe 2" } ] '


oResponse = nfJsonRead( m.responseType2 ) 

* nfjsonRead will always return an object, unnamed arrays get named as "Array"

For Each oRow In oResponse.array
    Insert Into response From Name oRow
Endfor

BROWSE
