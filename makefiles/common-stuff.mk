tags: ./src/tags

./src/tags:
	@# tag-relative: Make output relative to ctags file, not current directory
	@#               Because I run make from repo base dir, and vim from src dir.
	ctags --recurse --tag-relative -f $@

