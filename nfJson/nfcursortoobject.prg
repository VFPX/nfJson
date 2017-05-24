*-------------------------------------------------------------------
* Created by Marco Plaza vfp2nofox@gmail.com / @vfp2Nofox
* ver 1.000 - 20/02/2016 
*-------------------------------------------------------------------
parameters  copytoarray,includestruct

private all

if EMPTY(ALIAS())
	return .f.
endif

ovfp = createobject('empty')
addproperty(ovfp,'arrayOfValues', m.copytoarray )


if copytoarray

	copy to array arows
	recordcount = _tally

else

	recordcount = 0
	count to n

	dimension arows(1)
	arows(1) = '{}'

	if m.n > 0

		dimension arows(m.n)
		recordcount = m.n

		n=0

		scan
			n=m.n+1
			scatter name ofields memo
			arows(n) = m.ofields
		endscan

	endif

endif

addproperty(ovfp,'recordcount', m.recordCount)

IF m.recordcount > 0
	addarray(ovfp,'rows',@arows)
ENDIF


if m.includestruct

	ncols = afields(astruct)

	for n = 1 to ncols
		store '' to astruct(n,13),astruct(n,14),astruct(n,15)
		store 0 to astruct(n,17),astruct(n,18)
	endfor

	addarray(m.ovfp,'aStruct',@astruct)


endif


RETURN m.oVfp


***************************************
Function addArray(o2add2,aName,a2add)
***************************************

AddProperty(o2add2,(aName+'(1)'))

Acopy(a2add,o2add2.&aName)