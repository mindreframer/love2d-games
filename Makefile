.PHONY : run spec coverage clean

run:
	${LOVEPATH} ./

spec:
	busted `find spec -name \*spec.lua -print`

coverage:
	luacov luacov.stats.out && cat luacov.report.out | less

clean:
	rm -f luacov*

