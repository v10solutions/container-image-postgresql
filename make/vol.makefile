#
# Container Image PostgreSQL
#

.PHONY: vol-create-linux
vol-create-linux:
	$(BIN_DOCKER) volume create "postgres"
	$(BIN_DOCKER) run \
		--platform "$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)" \
		--rm \
		--name "postgres-vol-create" \
		-h "postgres-vol-create" \
		-u "480" \
		--entrypoint "initdb" \
		--net "$(NET_NAME)" \
		-v "postgres":"/usr/local/var/lib/postgresql" \
		"$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)" \
		-D "/usr/local/var/lib/postgresql"

.PHONY: vol-create
vol-create:
	$(MAKE) "vol-create-$(PROJ_PLATFORM_OS)"

.PHONY: vol-rm
vol-rm:
	$(BIN_DOCKER) volume rm "postgres"
