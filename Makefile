compile-benchmark:
	nim c --gc:orc --threads:on  -d:release benchmark/rf.nim
run-benchmarks:
	echo "Python Random Forest"
	time python ./benchmark/rf.py
	echo "============================"
	echo "Nim Random Forest"
	time ./benchmark/rf
clean-compiled:
	rm benchmark/rf