
LOG    = 2>&1 | tee -a log.$(shell date +%Y.%m.%d_%H.%M.%S).$@
DATE   = date | sed -n '/\(.*\)/ { h ; 's/./-/g' p ; x ; p ; x ; p }'
IAM   := piblink

SHELL := /bin/bash

.PHONY: make.vars make.targets make.clean make.default

make.default : make.vars make.targets

make.vars :
	@echo "available variables"
	@$(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null \
	| awk '/^# makefile/,/^[^#]/ { if ($$1 !~ "^[#.]") {print $$$$1} }' \
	| sed -e 's/ := / !:= /' -e 's/ = / ! = /' \
	| column -t -s'!' \
	| sed 's/  \([:=]\)/\1/' \
	| sed 's/^/    /' \
	| sort

make.targets :
	@echo "available Make targets:"
	@$(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null \
	| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
	| egrep -v '^make.default$$' \
	| sed 's/^/    make    /' \
	| sed 's/make    maven.release/make -n maven.release/' \
	| sort


all : build blink

blink :
	docker run --rm -it --privileged blink python src/blink.py

blink2 :
	docker run --rm -it --privileged blink python src/blink2.py

shell :
	docker run --rm -it --privileged --entrypoint /bin/sh blink

make.clean :
	find * -name \*~ -print -delete

docker.build :
	docker build --tag ${IAM} .

docker.run :
	docker run --rm -it --privileged ${IAM} sh

docker.srun :
	docker run --rm -it --privileged -v $$(dirname $$SSH_AUTH_SOCK):$$(dirname $$SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$$SSH_AUTH_SOCK mpinet-controller sh

#EOF
