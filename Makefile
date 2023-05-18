# Remember to update github actions
# Remember to at least edit _config.yml to url
# This is also using custom domain

setup:
	bundle
	bundle lock --add-platform x86_64-linux

run:
	JEKYLL_ENV=production bundle exec jekyll serve --livereload -o

docker:
	docker run -it --rm \
	--platform linux/amd64 \
    --volume="$(shell pwd):/srv/jekyll" \
    -p 4000:4000 jekyll/jekyll \
    jekyll serve --livereload -o