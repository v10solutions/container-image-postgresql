#
# Container Image PostgreSQL
#

.PHONY: container-run-linux
container-run-linux:
	$(BIN_DOCKER) container create \
		--platform "$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)" \
		--name "postgres" \
		-h "postgres" \
		-u "480" \
		--entrypoint "postgres" \
		--net "$(NET_NAME)" \
		-p "5432":"5432" \
		--health-interval "10s" \
		--health-timeout "8s" \
		--health-retries "3" \
		--health-cmd "postgres-healthcheck \"5432\" \"8\"" \
		-v "postgres":"/usr/local/var/lib/postgresql" \
		"$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)" \
		-D "/usr/local/var/lib/postgresql"
	$(BIN_FIND) "bin" -mindepth "1" -type "f" -iname "*" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "postgres":"/usr/local"
	$(BIN_FIND) "etc/postgresql" -mindepth "1" -type "f" -iname "*" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "postgres":"/usr/local"
	$(BIN_FIND) "var/lib/postgresql"  -mindepth "1" -type "f" -iname "*" ! -iname "tls-key.pem" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "480" --group "480" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "postgres":"/usr/local"
	$(BIN_FIND) "var/lib/postgresql" -mindepth "1" -type "f" -iname "tls-key.pem" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "480" --group "480" --mode "600" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "postgres":"/usr/local"
	$(BIN_DOCKER) container start -a "postgres"

.PHONY: container-run
container-run:
	$(MAKE) "container-run-$(PROJ_PLATFORM_OS)"

.PHONY: container-rm
container-rm:
	$(BIN_DOCKER) container rm -f "postgres"
