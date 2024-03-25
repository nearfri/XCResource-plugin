TEMP_DIR = release_temp
EXECUTABLE_NAME = xcresource

XCRESOURCE_URL = https://github.com/nearfri/XCResource.git
ARTIFACTBUNDLE = $(EXECUTABLE_NAME).artifactbundle
ARTIFACTBUNDLE_PATH = $(TEMP_DIR)/$(ARTIFACTBUNDLE)
ARTIFACTBUNDLE_ZIP = $(ARTIFACTBUNDLE).zip
ARTIFACTBUNDLE_ZIP_PATH = $(TEMP_DIR)/$(ARTIFACTBUNDLE_ZIP)
ARTIFACTBUNDLE_ZIP_URL = https://github.com/nearfri/XCResource/releases/download/$(NEW_VERSION)/$(ARTIFACTBUNDLE_ZIP)
RELEASE_NOTES_PATH = $(TEMP_DIR)/release_notes.md
RELEASE_NOTES_JSON_PATH = $(TEMP_DIR)/release_notes.json
RELEASE_API_URL = https://api.github.com/repos/nearfri/XCResource-plugin/releases
RELEASE_PAGE_URL = https://github.com/nearfri/XCResource-plugin/releases

MANIFEST_PATH = ./Package.swift

# Invoke make with GIT_CHECK=false to override this value.
GIT_CHECK = true

VERSION = $(shell git describe --tags `git rev-list --tags --max-count=1`)
GITHUB_TOKEN = $(shell security find-generic-password -w -s GITHUB_TOKEN)

ARTIFACTBUNDLE_CHECKSUM = $(shell swift package compute-checksum $(ARTIFACTBUNDLE_ZIP_PATH))

RELEASE_RESPONSE_PATH = $(TEMP_DIR)/release_response.json
RELEASE_NOTES_RESPONSE_PATH = $(TEMP_DIR)/release_notes_response.json

RELEASE_ID = $(shell cat $(RELEASE_RESPONSE_PATH) \
	| python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")

RELEASE_NOTES_BODY = $(shell cat $(RELEASE_NOTES_PATH) \
	| sed -E 's/"/\\"/g' | sed -E 's/$$/\\n/g' | tr -d '\n')

define NEWLINE


endef

define ADDITIONAL_RELEASE_NOTES_TEMPLATE
See https://github.com/nearfri/XCResource/releases/tag/$(VERSION)
endef
ADDITIONAL_RELEASE_NOTES = $(subst $(NEWLINE),\n,$(ADDITIONAL_RELEASE_NOTES_TEMPLATE))

define RELEASE_NOTES_TEMPLATE
{
	"tag_name": "$(VERSION)",
	"target_commitish": "main",
	"body": "$(subst ','\'',$(subst \n,\\n,$(RELEASE_NOTES_BODY)))"
}
endef
RELEASE_NOTES = $(subst $(NEWLINE),\n,$(RELEASE_NOTES_TEMPLATE))

####################################################################################################

.PHONY: default-release
default-release: release

.PHONY: release
release: release-local-process release-remote-process _finish_release

.PHONY: release-local-process
release-local-process: _ask-new-version _download_artifacebundle _update-manifest _update_plugin_code build-test

.PHONY: print-version
print-version:
	@echo Current Version: $(VERSION)

.PHONY: _ask-new-version
_ask-new-version: _check_git print-version
# .ONESHELL은 make 3.82부터 지원하므로 NEW_VERSION 정의를 위해 eval을 이용한다.
# https://superuser.com/a/1285748
	$(eval NEW_VERSION=$(shell read -p "Enter New Version: " NEW_VER; echo $$NEW_VER))
	
	@if [ -z $(NEW_VERSION) ]; then \
		exit 11; \
	fi

.PHONY: _check_git
_check_git:
	@if [ $(GIT_CHECK) == true ]; then \
		if ! git diff-index --quiet HEAD --; then \
			echo "You have uncommitted changes:"; \
			git status -s; \
			echo "If you want to ignore git status, invoke make with \"GIT_CHECK=false\""; \
			exit 10; \
		fi; \
	fi

.PHONY: _download_artifacebundle
_download_artifacebundle:
	mkdir -p $(TEMP_DIR)
	curl -L -o "$(ARTIFACTBUNDLE_ZIP_PATH)" "$(ARTIFACTBUNDLE_ZIP_URL)"

.PHONY: _update-manifest
_update-manifest:
	@sed -E -i '' "s/(.*url: .*download\/)(.+)(\/xcresource\.artifact.*)/\1$(NEW_VERSION)\3/" $(MANIFEST_PATH); \
	sed -E -i '' "s/(.*checksum: \")([^\"]+)(\".*)/\1$(ARTIFACTBUNDLE_CHECKSUM)\3/" $(MANIFEST_PATH)

.PHONY: _update_plugin_code
_update_plugin_code:
	mkdir -p $(TEMP_DIR)
	
	cd $(TEMP_DIR); \
	git clone $(XCRESOURCE_URL); \
	cd XCResource; \
	git checkout $(NEW_VERSION)

	cp $(TEMP_DIR)/XCResource/Plugins/RunXCResource/* Plugins/RunXCResource/

.PHONY: build-test
build-test:
	swift package plugin run-xcresource --allow-writing-to-package-directory --help > /dev/null

.PHONY: release-remote-process
release-remote-process: _git-commit _create-release _update-release-notes _open-release-page

.PHONY: _git-commit
_git-commit:
	git add .
	git commit -m "Update to $(NEW_VERSION)"
	git tag $(NEW_VERSION)
	git push origin $(NEW_VERSION)

.PHONY: _create-release
_create-release:
	@echo Create a release $(VERSION)
	
	@if [ -z $(GITHUB_TOKEN) ]; then \
		echo "GITHUB_TOKEN not found in the keychain."; \
		exit 20; \
	fi

	curl -X POST \
		-H "Authorization: token $(GITHUB_TOKEN)" \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Content-Type:application/json" \
		-d '{"tag_name":"$(VERSION)","target_commitish":"main","prerelease":true,"generate_release_notes":true}' \
		-o "$(RELEASE_RESPONSE_PATH)" \
		$(RELEASE_API_URL)

.PHONY: _update-release-notes
_update-release-notes: _generate-release-notes-file
	@echo Update a release notes

	@echo '$(RELEASE_NOTES)' > $(RELEASE_NOTES_JSON_PATH)

	curl -X PATCH \
		-H "Authorization: token $(GITHUB_TOKEN)" \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Content-Type: application/json" \
		--data-binary @$(RELEASE_NOTES_JSON_PATH) \
		-o "$(RELEASE_NOTES_RESPONSE_PATH)" \
		$(RELEASE_API_URL)/$(RELEASE_ID)

.PHONY: _generate-release-notes-file
_generate-release-notes-file:
# Write auto-generated release notes first
	@cat $(RELEASE_RESPONSE_PATH) \
	| python3 -c "import sys, json; print(json.load(sys.stdin)['body'])" \
	| tr -d '\r' \
	> $(RELEASE_NOTES_PATH)

	@echo '\n$(ADDITIONAL_RELEASE_NOTES)' >> $(RELEASE_NOTES_PATH)

.PHONY: _open-release-page
_open-release-page:
	open $(RELEASE_PAGE_URL)

.PHONY: _finish_release
_finish_release:
	rm -rf $(TEMP_DIR)
	@echo "The $(VERSION) update has been completed."
	@echo "Please finish with 'git push origin main'."
