# git-archive-with-submodules

git-archive-with-submodules - create tgz from git repository, including submodules

## SYNOPSIS
git-archive-with-submodules [commit-ish]

If you define [commit-ish], the archive will be created based on whatever you define commit-ish to be.
Banch names, commit hash, etc. are acceptable.
Defaults to HEAD if not specified

## OPTIONS  
- --include-changes
	- include staged and unstaged changes in the archive
	- NOTE: this flag makes sense only when archiving HEAD
- -o | --output-file <output_file>
	- write archive to <output_file>.
	- Defaults to directory name of this git repository with .tgz suffix
- --prefix <prefix>/
	- Prepend <prefix>/ to each filename in the archive.
- -v | --verbose
	- be verbose
