deploy_latest:
	./tf_run.sh -a test -s latest -b 10_example

deploy_review:
	./tf_run.sh -a test -s review -b 10_example