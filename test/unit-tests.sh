#! /bin/bash
test_dir="$(dirname "$0")"
root_dir=$PWD/$test_dir/..

FILES_TO_REMOVE=""
function cleanup {
	rm -rf $FILES_TO_REMOVE
}
trap cleanup EXIT INT

repo=$(mktemp -d /tmp/git-archive-with-submodules-XXXXXXXXXX)
subrepo=$(mktemp -d /tmp/git-archive-with-submodules-XXXXXXXXXX)
FILES_TO_REMOVE="$FILES_TO_REMOVE $repo"
WORKDIR=$PWD

oneTimeSetUp()
{
	cd $subrepo
	git init >/dev/null
	touch subfile1
	git add subfile1
	git -c user.name=dummy -c user.email=dummy@mail.com commit -m "add subfile1" > /dev/null
	cd $repo
	git init >/dev/null
	git submodule add $subrepo subrepo 2>/dev/null
	touch superfile1
	git add superfile1
	git add -A
	git -c user.name=dummy -c user.email=dummy@mail.com commit -m "add subrepo and superfile1" > /dev/null
	cd $WORKDIR
}

oneTimeTearDown()
{
	rm -rf $repo
	cd $WORKDIR
}

setUp()
{
	cd $repo
}

tearDown()
{
	git checkout -- :/
	git clean -fdq
	cd $WORKDIR
}

testArchiveHead()
{
	$root_dir/git-archive-with-submodules -o test.tgz > /dev/null
	assertEquals ".gitmodules
subrepo/
superfile1
subrepo/
subrepo/subfile1" "$(tar -tf test.tgz)"
}

testArchiveHeadWithPrefix()
{
	$root_dir/git-archive-with-submodules -o test.tgz --prefix prefix/ > /dev/null
	assertEquals "prefix/
prefix/.gitmodules
prefix/subrepo/
prefix/superfile1
prefix/subrepo/
prefix/subrepo/subfile1" "$(tar -tf test.tgz)"
}

testArchiveWithUntrackedChanges()
{
	touch superfile2
	git add superfile2
	cd subrepo
	touch subfile2
	git add subfile2
	cd ..
	# unstaged changes should not be taken.
	$root_dir/git-archive-with-submodules -o test.tgz > /dev/null
	assertEquals ".gitmodules
subrepo/
superfile1
subrepo/
subrepo/subfile1" "$(tar -tf test.tgz)"

	# now with --include-changes, the unstaged changes should be included
	$root_dir/git-archive-with-submodules -o test.tgz --include-changes > /dev/null
	assertEquals ".gitmodules
subrepo/
superfile1
superfile2
subrepo/
subrepo/subfile1
subrepo/subfile2" "$(tar -tf test.tgz)"

	rm test.tgz
}

# load shunit2
. /etc/os-release
if [ "$ID_LIKE" == "debian" ]
then
	. shunit2
else
	. /usr/share/shunit2/src/shunit2
fi
