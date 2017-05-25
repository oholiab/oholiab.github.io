.PHONY: dev-env serve post get-assets publish assets-remote-init

ASSETS_HOST:=$(shell cat assets_host)
ASSETS_PATH:=$(shell cat assets_path)
ASSETS_PARENT:=$(dir $(ASSETS_PATH))
ASSETS_REMOTE:=$(shell bash -c "cd assets && git remote show origin | grep Fetch | sed -E 's/^.+Fetch URL: (.+)$$/\1/'")

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

publish: dev-env
	git push origin master
	cd assets && git annex sync
	ssh -A $(ASSETS_HOST) bash -c "cd $(ASSETS_PATH) && git annex sync && git annex get ."

assets-remote-init:
	scp -r _remote-utils $(ASSETS_HOST):.
	ssh -A $(ASSETS_HOST) ./_remote-utils/init-assets.sh $(ASSETS_PATH) $(ASSETS_REMOTE)
