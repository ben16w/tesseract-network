SHELL := /bin/bash

# Variable definitions.
TESTING_DISTROS = "debian12 centos8 ubuntu2204 ubuntu2004"

# Show help.
.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  test         	un all tests for all roles in the repository using molecule."
	@echo "  test-changed 	Run all tests for a roles which have been modified since the last commit using molecule."
	@echo "  lint         	Lint all roles in the repository using yamllint and ansible-lint."
	@echo "  update-molecule Overwrite all molecule.yml files in roles from the molecule.yml in the repository root."

# Define directive to run a molecule test for a role directory.
define molecule-test
	if [ -f $${moleculedir}/default/molecule.yml ]; then \
		pushd $$(dirname $${moleculedir}) ;\
		export INSTANCE_NAME=$$(echo "molecule-$$RANDOM") ;\
		molecule test ;\
		popd ;\
	else \
		echo "No molecule.yml found for role: $${moleculedir}" ;\
	fi
endef

# Run all tests for all roles in the repository using molecule.
.PHONY: test
test:
	@set -e ;\
	for moleculedir in roles/*/molecule; do \
		echo "Testing role: $${moleculedir}" ;\
		$(molecule-test) ;\
	done ;\
	echo "Success!"

# Run all tests for all roles in the repository using molecule on a specific distros.
.PHONY: test-distros
test-distros:
	@set -e ;\
	for moleculedir in roles/*/molecule; do \
		for distro in $(shell echo $(TESTING_DISTROS)); do \
			echo "Testing role: $${moleculedir} on $${distro}" ;\
			export MOLECULE_DISTRO=$${distro} ;\
			$(molecule-test) ;\
		done ;\
	done ;\
	echo "Success!"

# Run all tests for a roles which have been modified since the last commit using molecule.
.PHONY: test-changed
test-changed:
	@set -e ;\
	roles="$$((git diff --name-only $$(git merge-base HEAD origin/main); git diff --name-only; ) | grep "roles/" | cut -d '/' -f 1-2 | sort -u )" ;\
	echo $${roles} ;\
	echo "sddsfds" ;\
	for roledir in $${roles}; do \
		moleculedir="$${roledir}/molecule" ;\
		echo "Testing role: $${moleculedir}" ;\
		$(molecule-test) ;\
	done ;\
	echo "Success!"

# Lint all roles in the repository using yamllint and ansible-lint.
.PHONY: lint
lint:
	@set -e ;\
	yamllint -d relaxed . ;\
	ansible-lint --profile safety -w var-naming[no-role-prefix] ;\
	echo "Success!"

# Overwrite all molecule.yml files in roles from the molecule.yml in the repository root.
.PHONY: update-molecule
update-molecule:
	@set -e ;\
	if [ ! -f molecule.yml ]; then \
		echo "ERROR: No molecule.yml found in repository root" ;\
		exit 1 ;\
	fi ;\
	for moleculedir in roles/*/molecule; do \
		echo "Updating molecule.yml for role: $${moleculedir}" ;\
		if [ ! -f $${moleculedir}/default/molecule.yml ]; then \
			echo "ERROR: No molecule.yml found for role: $${moleculedir}" ;\
			exit 1 ;\
		fi ;\
		if cmp -s molecule.yml $${moleculedir}/default/molecule.yml; then \
			echo "WARNING: $${moleculedir}/default/molecule.yml equals molecule.yml in repository root, skipping." ;\
		else \
			cp molecule.yml $${moleculedir}/default/molecule.yml ;\
		fi ;\
	done ;\
	echo "Success!"
