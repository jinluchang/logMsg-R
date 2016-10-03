all:
	Rscript tests/build.R
	Rscript tests/test.R
	cat logs/*
	-rm -rf logs

