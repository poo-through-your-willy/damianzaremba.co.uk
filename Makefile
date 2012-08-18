SHELL := /bin/bash

all: build

install: update build clone push

build:
	jekyll

server:
	jekyll --server

clone:
	# Remove it not a git repo
	test -d "_live" && test -d "_live/.git" || rm -rf _live; exit 0

	# Update if a git repo
	test -d "_live" && (cd _live && git pull); exit 0

	# Clone if it doesn't exist
	test -d "_live" || git clone git@github.com:DamianZaremba/DamianZaremba.github.com.git _live; exit 0

clean:
	test -d _site && rm -rf _site; exit 0

push:
	rsync -vr --exclude=.git --delete _site/ _live/
	cd _live/ && (git add *; git commit -am "Updated site"; git push origin master)

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
	tail -n +9 /tmp/github-damianzaremba-cv-readme >> content/cv/index.markdown
	rm -f /tmp/github-damianzaremba-cv-readme

	# Write out the footer
	echo >> content/cv/index.markdown
	echo >> content/cv/index.markdown
	echo "Other Formats" >> content/cv/index.markdown
	echo "-------------" >> content/cv/index.markdown
	echo "Available on [GitHub](https://github.com/DamianZaremba/cv)" >> content/cv/index.markdown