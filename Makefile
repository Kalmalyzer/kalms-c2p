
.PHONY:	all build test clean

all: build

build:
	mkdir -p build
	cd build && cmake -DCMAKE_TOOLCHAIN_FILE=../amigaos-toolchain.cmake .. && make

test: build
	echo "Not yet implemented"
	exit 1

clean:
	rm -rf build
