.PHONY: dev-env serve post

default: dev-env

dev-env: vendor

vendor:
	which bundle || gem install bundler
	bundle install --path=vendor

serve:
	bundle exec jekyll serve

post:
	bundle exec helpers post

doc: helpers
	bundle exec rdoc helpers
