.PHONY: dev-env serve

default: dev-env

dev-env: vendor

vendor:
	which bundle || gem install bundler
	bundle install --path=vendor

serve:
	bundle exec jekyll serve
