
def:
	./build.sh lql plan
	./build.sh lql package --version 0.0.1
	make install

up:
	docker-compose up -d

down:
	docker-compose down -v

ssh:
	docker exec -it postgres /bin/bash

install:
	$(MAKE) docker-install || $(MAKE) k8-install

dinstall:
	$(MAKE) docker-install

docker-install:
	docker exec launchql-postgres /sql-bin/install.sh

k8-install:
	$(eval POD_NAME := $(shell kubectl get pods -l app=postgres -n webinc -o jsonpath="{.items[*].metadata.name}"))
	kubectl exec -n webinc -it $(POD_NAME) /sql-bin/install.sh

all:
	./build.sh lql package --version 0.0.1
	./build.sh lql plan

dump:
	lql dump --deps --project dbs --path $(WEBINC_PATH)/services/packages/graphql-server-service/bootstrap/app.sql

seed:
	createdb launchql
	# lql deploy --recursive --database launchql --yes --project db_modules
	lql deploy --recursive --database launchql --yes --project lql-svc-local

mods:
	createdb db-mods
	lql deploy --recursive --database db-mods --yes --project launchql-meta-modules

deploy:
	@echo lql deploy --recursive --createdb --yes --project dbs --database launchql-db
	@echo lql deploy --recursive --createdb --yes --project db_modules --database webinc-db

generate:
	@cd packages/db_text && ./generate/generate.js
	@cd packages/db_text && lql package --version 0.0.1
	@cd packages/db_utils && lql package --version 0.0.1
	@cd packages/db_deps && lql package --version 0.0.1
	@cd packages/db_migrate && lql package --version 0.0.1
	$(MAKE) install

gen:
	@cd packages/db_text && ./generate/generate.js

ast:
	@cd packages/ast && lql package --version 0.0.1
	@cd packages/ast_actions && lql package --version 0.0.1
	@cd packages/objects && lql package --version 0.0.1
	@cd packages/transactor && lql package --version 0.0.1
	@cd packages/db_migrate && lql package --version 0.0.1
	$(MAKE) install


