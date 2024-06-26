# Remember to update github actions
# Remember to at least edit _config.yml to url
# This is also using custom domain

setup:
	bundle lock --add-platform x86_64-linux

run:
	JEKYLL_ENV=production bundle exec jekyll s --livereload -o --incremental

run2:
	JEKYLL_ENV=production bundle exec jekyll serve --livereload
	
docker:
	docker run -it --rm \
	-e JEKYLL_ENV=production \
	--platform linux/amd64 \
    --volume="$(shell pwd):/srv/jekyll" \
    -p 4000:4000 jekyll/jekyll \
	bundle && \
	bundle lock --add-platform x86_64-linux && \
    bundle exec jekyll serve --livereload -o --incremental

docker2:
	docker run -it --rm \
	-e JEKYLL_ENV=production \
	--platform linux/amd64 \
    --volume="$(shell pwd):/srv/jekyll" \
    -p 4000:4000 jekyll/jekyll \
	bundle && \
	bundle lock --add-platform x86_64-linux && \
    bundle exec jekyll serve

# https://stackoverflow.com/questions/9794931/keep-file-in-a-git-repo-but-dont-track-changes

freeze_config:
	git update-index --assume-unchanged _config.yml

unfreeze_config:
	git update-index --no-assume-unchanged _config.yml
