check:
	while read -r script; do shellcheck --exclude=SC1090,SC1091 $$script; done < files

.PHONY: check
