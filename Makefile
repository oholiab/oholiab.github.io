.PHONY: dev-env serve post get-assets

default: dev-env

dev-env: vendor | assets/images

vendor:
	which bundle || gem install bundler
	bundle install --path=vendor

serve:
	bundle exec jekyll serve

post:
	bundle exec helpers post

doc: helpers
	bundle exec rdoc helpers

assets/images:
	git submodule update --init --recursive

get-assets: assets/images
	cd assets && git annex get .
