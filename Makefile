run:
	nextflow run main.nf

run_debug:
	nextflow run main.nf -dump-channels -ansi-log false

docker:
	docker build -t hadrieng/hmp:0.1.0 .
	docker push hadrieng/hmp:0.1.0

clean:
	rm -rf work/
	rm -rf .nextflow.log*