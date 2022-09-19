#
# Container Image PostgreSQL
#

.PHONY: setup-postgres-user
setup-postgres-user:
	$(BIN_DOCKER) exec -u "postgres" -t -i "postgres" psql \
		-q \
		-p "5432" \
		-c "\password"

.PHONY: setup-wms-user
setup-wms-user:
	$(BIN_DOCKER) exec -u "postgres" -t -i "postgres" createuser \
		-p "5432" \
		-l \
		-P \
		"wms"

.PHONY: setup-wms-db
setup-wms-db:
	$(BIN_DOCKER) exec -u "postgres" -t -i "postgres" createdb \
		-p "5432" \
		-O "wms" \
		"wms"

.PHONY: setup-wms-%
setup-wms-%:
	hostname=$(shell $(BIN_DOCKER) exec -u "postgres" "postgres" hostname -f) \
	&& $(BIN_DOCKER) exec -u "postgres" -t -i "postgres" psql \
		-q \
		-h "$${hostname}" \
		-p "5432" \
		-d "wms" \
		-U "wms" \
		-c "$$(cat "setup/wms-$(*).sql")"
