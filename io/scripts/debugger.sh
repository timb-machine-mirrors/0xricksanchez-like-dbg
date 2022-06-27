#!/usr/bin/env bash

PROJECT_DIR=""
VMLINUX=""
ARCH=""

while true; do
    if [ $# -eq 0 ];then
	echo $#
	break
    fi
    case "$1" in
        -a | --arch)
            # Sets the architecture as expected in GDB
    	    ARCH=$2
            shift 2
            ;;
        -p | --project)
            # Sets the kernel root dir where vmlinux is located
    	    PROJECT_DIR=$2
            VMLINUX=$PROJECT_DIR/vmlinux
            shift 2
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
        *)  # No more options
            break
            ;;
    esac
done

# Handle GDB naming sceme
case "$ARCH" in
    arm64)
        ARCH=armv8-a
        ;;
    arm)
        ARCH=armv7
        ;;
    x86_64)
        ARCH=i386:x86-64
        ;;
    *)
        ARCH=$ARCH
        ;;
esac
pushd $HOME
echo "add-auto-load-safe-path $PROJECT_DIR" >> .gdbinit
popd
rm vmlinux-gdb.py
ln -sd scripts/gdb/vmlinux-gdb.py

gdb -q $VMLINUX -iex "set architecture $ARCH" -ex "target remote :1234" \
    -ex "add-symbol-file $VMLINUX" \
    -ex "break start_kernel" \
    -ex "continue" \
    -ex "lx-symbols" \
    -ex "macro define offsetof(_type, _memb) ((long)(&((_type *)0)->_memb))" \
    -ex "macro define containerof(_ptr, _type, _memb) ((_type *)((void *)(_ptr) - offsetof(_type, _memb)))"
