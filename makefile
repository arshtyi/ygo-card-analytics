SHELL := /usr/bin/fish
.SHELLFLAGS := -c
.ONESHELL:

setup:
	mkdir assets
	cd assets
	curl -fsSL https://github.com/arshtyi/ygo-cards/releases/download/latest/ot.json | tee ot.json | sha256sum > ot.json.sha256sum
	curl -fsSL https://github.com/arshtyi/ygo-cards/releases/download/latest/rd.json | tee rd.json | sha256sum > rd.json.sha256sum

compile:
	typst compile ygo-card-analytics.typ ygo-card-analytics.pdf

watch:
	typst watch ygo-card-analytics.typ ygo-card-analytics.pdf
