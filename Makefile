SHELL := /bin/bash

all: compile

install: update compile minify clone push

build: update compile minify

compile:
	jekyll

server:
	jekyll --server

clone:
	# Remove it not a git repo
	test -d "_live" && (test -d "_live/.git" || rm -rf _live); exit 0

	# Update if a git repo
	test -d "_live" && (cd _live && git pull); exit 0

	# Clone if it doesn't exist
	test -d "_live" || git clone git@github.com:DamianZaremba/damianzaremba.github.com.git _live; exit 0

clean:
	test -d _site && rm -rf _site; exit 0

minify:
	# Js/CSS
	test -f ~/bin/yuicompressor.jar && find _site/assests/ -type f \( -iname '*.css' -o -iname '*.js' \) \
	| while read f; do java -jar ~/bin/yuicompressor.jar $$f -o $$f --charset utf-8; done; exit 0

	# HTML
	test -f ~/bin/htmlcompressor.jar && find _site/ -type f -iname '*.html' \
	| while read f; do java -jar ~/bin/htmlcompressor.jar --type html \
		--compress-js --compress-css --remove-quotes --js-compressor yui \
	 	-o $$f $$f; done; exit 0

	# Images
	test -x /usr/bin/convert && find _site/assests/ -type f \
		\( -name 'date.png' -o -name 'comments.png' -o -name 'categories.png' \) \
		| while read f; do /usr/bin/convert $$f -quality 70% $$f; done; exit 0

push:
	rsync -vr --exclude=.git --delete _site/ _live/
	cd _live/ && (touch .nojekyll; git add *; git commit -am "Updated site"; git push origin master)

update:
	# Make sure the dir exists
	test -d content/cv/ || mkdir -p content/cv/; exit 0

	# Download the current README
	wget -O /tmp/github-damianzaremba-cv-readme https://raw.github.com/DamianZaremba/cv/master/README.md

	# Write out the header
	echo "---" > content/cv/index.markdown
	echo "layout: default" >> content/cv/index.markdown
	echo "title: CV" >> content/cv/index.markdown
	echo "description: Damian Zaremba's CV" >> content/cv/index.markdown
	echo "---" >> content/cv/index.markdown

	# Cat in the main stuff ignoring the header crap
	tail -n +4 /tmp/github-damianzaremba-cv-readme >> content/cv/index.markdown
	rm -f /tmp/github-damianzaremba-cv-readme

	# Write out the footer
	echo >> content/cv/index.markdown
	echo >> content/cv/index.markdown
	echo "Other Formats" >> content/cv/index.markdown
	echo "-------------" >> content/cv/index.markdown
	echo "Available on [GitHub](https://github.com/DamianZaremba/cv)" >> content/cv/index.markdown
