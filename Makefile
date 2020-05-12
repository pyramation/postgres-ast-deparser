
up:
	docker-compose up -d

down:
	docker-compose down -v

ssh:
	docker exec -it postgres /bin/bash

install:
	docker exec webinc-postgres /sql-extensions/install.sh
