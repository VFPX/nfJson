*-------------------------------------------------------------------
* Created by Marco Plaza / @nfTools
* ver 1.010 - 07/06/2017
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

	if _tally = 0
		dimension arows(1)
		arows(1)  = .null.
	endif

else

	recordcount = 0
	count to n

	dimension arows(1)
	arows(1) = .null.

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
addarray(ovfp,'rows',@m.arows)

if m.includestruct

	ncols = afields(astruct)

	for n = 1 to ncols
		store '' to astruct(n,13),astruct(n,14),astruct(n,15)
		store 0 to astruct(n,17),astruct(n,18)
	endfor

	addarray(m.ovfp,'aStruct',@m.astruct)

endif

RETURN m.oVfp

***************************************
Function addArray(o2add2,aName,a2add)
***************************************

AddProperty(o2add2,(aName+'(1)'))

Acopy(a2add,o2add2.&aName)