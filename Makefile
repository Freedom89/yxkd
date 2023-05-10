# Remember to update github actions
# Remember to at least edit _config.yml to url
# This is also using custom domain

setup:
	bundle
	bundle lock --add-platform x86_64-linux

run:
	bundle exec jekyll serve --livereload -o