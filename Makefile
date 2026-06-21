#==============================================================================#
# Project
#==============================================================================#
.DEFAULT_GOAL := help
.ONESHELL:
.PHONY: ${MAKECMDGOALS}
RED := \033[1;31m
BLU := \033[36m
RST := \033[0m
MAKEFILE_DIR := $(subst ${CURDIR}/,,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))).
LUAROCKS := luarocks --lua-version 5.1 --tree ${MAKEFILE_DIR}/.luarocks
XML2LUA_REF := v1.6-1

# This fixes luasystem not being able to find RT_DIR upon install
ifdef RT_DIR
	LUAROCKS += RT_DIR="${RT_DIR}"
endif

## IN_NIX: [0] Set to 1 to run a command in the nix shell
ifeq ($(IN_NIX),1)
	.SHELLFLAGS := develop --ignore-environment --command bash -ce
	SHELL := nix
endif

## IN_DOCKER: [0] Set to 1 to run a command in a docker container
ifeq ($(IN_DOCKER),1)
	.SHELLFLAGS := run --rm -it -v${MAKEFILE_DIR}:/src nvim-neocov:latest
	SHELL := docker
endif

#==============================================================================#
# Environment
#==============================================================================#
export PATH := ${MAKEFILE_DIR}/.luarocks/bin:${PATH}
export VIMRUNTIME = $(shell nvim --clean --headless --cmd 'lua io.write(os.getenv("VIMRUNTIME"))' --cmd 'quit')

#==============================================================================#
# Goals
#==============================================================================#
help: ## Shows this message
	@printf '${RED}Usage:\n  ${RST}${BLU}make [<VARIABLE>=<value>] <goal>\n${RST}'
	printf '${RED}Targets:\n${RST}'
	cat ${MAKEFILE_LIST} | awk -F'(:|##|])\\s*' '/[^:]*:[^:]+##\s.*$$/ {printf "  ${BLU}%-18s${RST} %s\n", $$1, $$3}'
	printf '${RED}Variables:\n${RST}'
	cat ${MAKEFILE_LIST} | awk -F'(:|##|])\\s*' '/##\s*[A-Z_]+:.*$$/ {printf "  ${BLU}%-18s ${RED}%s]${RST} %s\n", $$2, $$3, $$4}'

clean: ## Deletes artifacts
	@rm -rf luacov.stats luacov.report.html src

distclean: ## Resets the repo back to its state at checkout
	git clean -xdff

shell: ## Enter a shell containing dev dependencies
	nix develop

setup: ## Once-per-clone setup
	git -C .cache clone https://github.com/nvim-neotest/neotest.git
	git -C .cache clone https://github.com/stevearc/overseer.nvim.git
	${LUAROCKS} install busted 2.2.0-1 --force
	${LUAROCKS} install llscheck 0.7.0-1 --force
	${LUAROCKS} install luacheck 1.2.0-1 --force
	${LUAROCKS} install luacov 0.16.0-1 --force
	${LUAROCKS} install nlua 0.3.2-1 --force
	${LUAROCKS} install nvim-nio 1.10.1-1 --force
	# Required for nix
	ln -sf ./.luarocks/lib/luarocks/rocks-*/luacov/*/src/ src

check: format lint test cov ## Runs quality assurance steps

format: ## Reformats code
	@printf '${BLU}=== formatting ===${RST}\n'
	stylua lua plugin spec

lint: ## Runs static analysis tools
	@printf '${BLU}=== stylua ===${RST}\n'
	stylua lua plugin spec --color always --check
	printf '${BLU}=== luacheck ===${RST}\n'
	luacheck lua plugin spec
	printf '${BLU}=== llscheck ===${RST}\n'
	$(shell ${LUAROCKS} path) && VIMRUNTIME=${VIMRUNTIME} llscheck .
	printf '${BLU}=== emmylua_check ===${RST}\n'
	emmylua_check .

echo:
	@echo ${VIMRUNTIME}

test: ## Runs tests
	@printf '${BLU}=== testing ===${RST}\n'
	$(shell ${LUAROCKS} path) && busted

cov: ## Generates test coverage
	@printf '${BLU}=== coverage ===${RST}\n'
	$(shell ${LUAROCKS} path) && luacov

docs: ## Build the documentation
	@printf '${BLU}=== documentation ===${RST}\n'
	panvimdoc --project-name nvim-neocov --input-file README.md
	nvim -es -c 'helptags doc' -c 'q'

docker.build: ## Builds the docker image
	docker build . -t nvim-neocov

docker.run: docker.build ## Runs the docker image
	docker run --rm -it nvim-neocov

external: ## Vendor xml2lua
	rm -rf lua/nvim-neocov/external/xml2lua
	git -C lua/nvim-neocov/external clone https://github.com/manoelcampos/xml2lua
	git -C lua/nvim-neocov/external/xml2lua checkout ${XML2LUA_REF}
	find lua/nvim-neocov/external/xml2lua \
	  -type f \
	  ! -name "XmlParser.lua" \
	  ! -name "xml2lua.lua" \
	  ! -name "dom.lua" \
	  ! -name "print.lua" \
	  ! -name "tree.lua" \
	  -delete
	find lua/nvim-neocov/external/xml2lua \
	  -name "*.lua" \
	  -exec sed -i 's#require("#require("nvim-neocov.external.xml2lua.#g' {} +

nvim-neocov:
	mkdir -p "${HOME}/.local/bin/"
	echo "#!/bin/bash" > "${HOME}/.local/bin/nvim-neocov"
	echo "export NVIM_APPNAME=nvim-neocov" >> "${HOME}/.local/bin/nvim-neocov"
	echo 'nvim "$$@"' >> "${HOME}/.local/bin/nvim-neocov"
	chmod +x "${HOME}/.local/bin/nvim-neocov"
	rm -f "${HOME}/.config/nvim-neocov"
	# TODO(create config with nvim-neocov)
	ln -s "${PWD}/home/.config/nvim" "${HOME}/.config/nvim-neocov"

nvim-neocov.clean:
	rm -f "${HOME}/.local/bin/nvim-neocov"
	rm -rf "${HOME}/.cache/nvim-neocov"
	rm -rf "${HOME}/.config/nvim-neocov"
	rm -rf "${HOME}/.local/share/nvim-neocov"
	rm -rf "${HOME}/.local/state/nvim-neocov"

