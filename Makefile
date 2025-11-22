clean:
	rm -rf _output
	rm -rf .up
	rm -rf ~/.up/cache

build:
	up project build

render: render-example

render-all: render-example

render-example:
	up composition render --xrd=apis/accounts/definition.yaml apis/accounts/composition.yaml examples/accounts/example-member.yaml

test:
	up test run tests/test*

validate: validate-composition validate-example

validate-composition:
	up composition render --xrd=apis/accounts/definition.yaml apis/accounts/composition.yaml examples/accounts/example-member.yaml --include-full-xr --quiet | crossplane beta validate apis/accounts --error-on-missing-schemas -

validate-example:
	crossplane beta validate apis/accounts examples/accounts

publish:
	@if [ -z "$(tag)" ]; then echo "Error: tag is not set. Usage: make publish tag=<version>"; exit 1; fi
	up project build --push --tag $(tag)

generate-definitions:
	up xrd generate examples/accounts/example-member.yaml

generate-function:
	up function generate --language=go-templating render apis/accounts/composition.yaml

e2e:
	up test run tests/e2etest* --e2e
