.PHONY: benchmark results chart

benchmark:
	swift build -c release

results: benchmark
	.build/release/benchmark run results \
--disable-cutoff true \
--format pretty \
--cycles 3 \
--iterations 3 \
--sizes 5242880 10485760 20971520 52428800 104857600 209715200 536870912

chart: benchmark
	.build/release/benchmark render results chart.png \
--amortized false
