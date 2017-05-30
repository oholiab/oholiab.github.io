.PHONY: dev-env serve post get-assets publish assets-remote-init

ASSETS_HOST:=$(shell cat assets_host)
ASSETS_PATH:=$(shell cat assets_path)
ASSETS_PARENT:=$(dir $(ASSETS_PATH))
ASSETS_REMOTE:=$(shell cat assets_remote)

default: dev-env

dev-env: vendor | _assets

vendor:
	which bundle || gem install bundler
	bundle install --path=vendor

serve:
	bundle exec jekyll serve

post:
	bundle exec helpers post

doc: helpers
	bundle exec rdoc helpers

_assets:
	git clone $(ASSETS_REMOTE) _assets

get-assets: _assets
	cd _assets && git annex get .

publish: dev-env
	git push origin master
	cd _assets && git annex sync && git annex copy * --to origin
	scp -r _remote-utils $(ASSETS_HOST):.
	ssh -A $(ASSETS_HOST) ./_remote-utils/update-assets.sh $(ASSETS_PATH)

assets-remote-init:
	scp -r _remote-utils $(ASSETS_HOST):.
	ssh -A $(ASSETS_HOST) ./_remote-utils/init-assets.sh $(ASSETS_PATH) $(ASSETS_REMOTE)
