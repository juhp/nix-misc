#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: nix list [PKG] ...   - list packages"
  echo "       nix search PKGREGEXP - search available packages"
  echo "       nix binary [PKG] ... - list binary substitute packages"
  echo "       nix info PKG ...     - show package xml info"
  echo "       nix install PKG ...  - install package"
  echo "       nix update [PKG] ... - update package"
  echo "       nix remove PKG ...   - remove package"
  echo "       nix path PKG ...     - show the package's store dir"
  echo "       nix files PKG ...    - list package's files in store root"
  echo "       nix locate FILEEXP   - locate in store without prefix"
  exit 1
fi

CMD=$1
shift
ARGS=$*

QUERY='nix-env -qaP'
QUERYSTATE="$QUERY -s"
SHOW_STATE="sed -e s/^.P./Present\t/g -e s/^..S/subst\t/g -e s/^---/\t/g"

case $CMD in
    list)
	    $QUERYSTATE ${ARGS:-\*} | $SHOW_STATE
	;;
    binary)
	    $QUERYSTATE -b ${ARGS:-\*} | $SHOW_STATE
	;;
    search)
	if [ $# != 1 ]; then
	    echo Usage: nix search PKGREGEXP
	    exit 1
	fi
	PKGREGEXP=$(echo $1 | sed -e "s/\*/\.\*/g")
	# query state of everything too slow
	$QUERY \* | grep $PKGREGEXP
	;;
    info)
	if [ $# -lt 1 ]; then
	    echo Usage: nix info PKG ...
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
	STORE=`$QUERY --no-name --out-path $ARGS`
	if [ -n "$STORE" ]; then
	    for dir in $STORE; do
		if [ -d "$dir" ]; then
		    echo $dir
		fi
	    done
	fi
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
