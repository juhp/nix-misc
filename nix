#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: nix list [PKG] ...   - list packages"
  echo "       nix binary [PKG] ... - list binary substitute packages"
  echo "       nix search PKGREGEXP - search available packages"
  echo "       nix info PKG ...     - show package info"
  echo "       nix xml PKG ...      - show package info"
  echo "       nix install PKG ...  - install package"
  echo "       nix update [PKG] ... - update package"
  echo "       nix remove PKG ...   - remove package"
  echo "       nix attrib PKG ...   - show package attribute"
  echo "       nix files PKG ...    - find package's files in store"
  echo "       nix locate FILEEXP   - locate output with store prefix"
  echo "       nix path PKG ...     - show the package's store dir"
  exit 1
fi

CMD=$1
shift
ARGS=$*

QUERY='nix-env -qsa'
SHOW_STATE="sed -e s/^.P./Present\t/g -e s/^..S/subst\t/g -e s/^---/\t/g"

case $CMD in
    list)
	    $QUERY ${ARGS:-\*} | $SHOW_STATE
	;;
    binary)
	    $QUERY -b ${ARGS:-\*} | $SHOW_STATE
	;;
    search)
	if [ $# != 1 ]; then
	    echo Usage: nix search PKGREGEXP
	    exit 1
	fi
	PKGREGEXP=$(echo $1 | sed -e "s/\*/\.\*/g")
	$QUERY \* | grep $PKGREGEXP | $SHOW_STATE
	;;
    info)
	if [ $# -lt 1 ]; then
	    echo Usage: nix info PKG ...
	    exit 1
	fi
	$QUERY -P --description $ARGS
	;;
    xml)
	if [ $# -lt 1 ]; then
	    echo Usage: nix xml PKG ...
	    exit 1
	fi
	$QUERY --xml --meta $ARGS
	;;
    install)
	if [ $# -lt 1 ]; then
	    echo Usage: nix install PKG ...
	    exit 1
	fi
	nix-env -i $ARGS
	;;
    update)
	nix-env -u ${ARGS:-\*}
	;;
    remove)
	if [ $# -lt 1 ]; then
	    echo Usage: nix remove PKG ...
	    exit 1
	fi
	nix-env -e $ARGS
	;;
    path)
	if [ $# -lt 1 ]; then
	    echo Usage: nix path PKG ...
	    exit 1
	fi
	nix-env -qa --no-name --out-path $ARGS
	;;
    attrib)
	if [ $# -lt 1 ]; then
	    echo Usage: nix attrib PKG ...
	    exit 1
	fi
	nix-env -qa --no-name -P $ARGS
	;;
    files)
	if [ $# -lt 1 ]; then
	    echo Usage: nix files PKG ...
	    exit 1
	fi
	STORE=`nix-env -qa --no-name --out-path $ARGS`
	if [ -n "$STORE" ]; then
	    for dir in $STORE; do
		if [ -d "$dir" ]; then
		    find $dir | sed -e "s%$dir/%%g"
		fi
	    done
	fi
	;;
    locate)
	if [ $# != 1 ]; then
	    echo Usage: nix locate FILEEXP
	    exit 1
	fi
	locate /nix/store/*$ARGS* | sed -e "s%^/nix/store/[^-]\+-%%g"
	;;
    *)
	echo "No such command: run 'nix' for usage"
	;;
esac
