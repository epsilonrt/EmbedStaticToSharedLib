# Embed a static library to a shared library

Very often, you get a static library from some other source, which you need to use for your purposes. What if you finally are working towards creation of a dynamic library, which uses symbols (or functions) from the static library? How do you “link” the symbols in the static library to your dynamic library so that there will be no “undefined” symbols at runtime? This article helps to bust this problem.

The idea is to embed all the functions of the static library in the shared library.

This reduces dependencies and allows you to include a static library without recompiling it while respecting the license.

Inspired by the article [How can I link a static library to a dynamic library?](https://blog.ramdoot.in/how-can-i-link-a-static-library-to-a-dynamic-library-e1f25c8095ef)

In this tutorial, the static library `libfiles` is compiled from the files file1.c and file2.c, while the dynamic library `libfiled` is compiled from the file file3.c and embeds all the symbols and functions of `libfiles`. The source files are in src/, the header files in include/. 


## Static library files

**include/files.h**

```c
#pragma once
void func1();
void func2();
```

**src/file1.c**

```c
#include <stdio.h>

void func1() {
  printf ("func1\n");
}
```

**src/file2.c**

```c
#include <stdio.h>

void func2() {
  printf ("func2\n");
}
```

## Dynamic library files

La bibliothèque dynamique inclura la bibliothèque statique et utilisera ses fonctions.

**include/filed.h**

```c
#pragma once
#include "files.h"
void func3();
```

**src/file3.c**

```c
#include <stdio.h>
#include "files.h"

void func3() {
  printf ("calling func2 from func3\n");
  func2();
  printf ("func3\n");
}
```

## Main program

**src/main.c**

```c
#include "filed.h"

int main() {
  func1();
  func3();
  return 0;
}
```

## With gcc on Linux or other Unix-like systems

First, create the directories that will contain the generated files:

```bash
mkdir -p obj lib bin
``` 

Build the relocatable object files:

```bash
gcc -c -fPIC src/file1.c -o obj/file1.o -Iinclude
gcc -c -fPIC src/file2.c -o obj/file2.o -Iinclude
gcc -c -fPIC src/file3.c -o obj/file3.o -Iinclude
```

Then create the static library:

```bash
ar rcs lib/libfiles.a obj/file1.o obj/file2.o
ranlib lib/libfiles.a
```

Then create the dynamic library:

```bash
gcc -o lib/libfiled.so -Wl,--whole-archive lib/libfiles.a -Wl,--no-whole-archive -shared obj/file3.o
```

Build the main program:

```bash
gcc -o bin/main src/main.c -Llib -lfiled -Wl,-rpath,./lib -Iinclude
```

## Execution

```bash
$ bin/main
func1
calling func2 from func3
func2
func3
```

There you have it, the dynamic library has called a function from the static library.

## with Gnu Make on Linux or other Unix-like systems

Now, let's automate the process with a Makefile:

```makefile
SRC_DIR := src
OBJ_DIR := obj
BIN_DIR := bin
LIB_DIR := lib

EXE := $(BIN_DIR)/main
EXE_SRC := $(SRC_DIR)/main.c
EXE_OBJ := $(EXE_SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

LIBSTATIC := $(LIB_DIR)/libfiles.a
LIBSTATIC_SRC := $(SRC_DIR)/file1.c $(SRC_DIR)/file2.c
LIBSTATIC_OBJ := $(LIBSTATIC_SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

LIBSHARED := $(LIB_DIR)/libfiled.so
LIBSHARED_SRC := $(SRC_DIR)/file3.c
LIBSHARED_OBJ := $(LIBSHARED_SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

LIB_SRC := $(LIBSTATIC_SRC) $(LIBSHARED_SRC)
LIB_OBJ := $(LIBSTATIC_OBJ) $(LIBSHARED_OBJ)

CPPFLAGS := -Iinclude -MMD -MP
CFLAGS   := -Wall
LDFLAGS  := -Llib
LDLIBS   := -lfiled

.PHONY: all clean

all: $(EXE)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -c $< -o $@

$(LIBSTATIC): $(LIBSTATIC_OBJ) | $(LIB_DIR)
	ar rcs $@ $^
	ranlib $@

$(LIBSHARED): $(LIBSHARED_OBJ) $(LIBSTATIC) | $(LIB_DIR)
	$(CC) -shared -o $@ -Wl,--whole-archive $(LIBSTATIC) -Wl,--no-whole-archive  $<
	
$(EXE_OBJ): $(EXE_SRC) | $(OBJ_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(EXE): $(EXE_OBJ) $(LIBSHARED) | $(BIN_DIR)
	$(CC) $(LDFLAGS) $< $(LDLIBS) -Wl,-rpath,./lib -o $@

$(BIN_DIR) $(OBJ_DIR) $(LIB_DIR):
	mkdir -p $@

clean:
	@$(RM) -rv $(BIN_DIR) $(OBJ_DIR) $(LIB_DIR)

-include $(OBJ:.o=.d)
```

```bash
$ make
mkdir -p obj
cc -Iinclude -MMD -MP -Wall -c src/main.c -o obj/main.o
cc -Iinclude -MMD -MP -Wall -fPIC -c src/file3.c -o obj/file3.o
cc -Iinclude -MMD -MP -Wall -fPIC -c src/file1.c -o obj/file1.o
cc -Iinclude -MMD -MP -Wall -fPIC -c src/file2.c -o obj/file2.o
mkdir -p lib
ar rcs lib/libfiles.a obj/file1.o obj/file2.o
ranlib lib/libfiles.a
cc -shared -o lib/libfiled.so -Wl,--whole-archive lib/libfiles.a -Wl,--no-whole-archive  obj/file3.o
mkdir -p bin
cc -Llib obj/main.o -lfiled -Wl,-rpath,./lib -o bin/main


## With CMake

https://stackoverflow.com/questions/11697820/cmake-link-static-library-to-dynamic-library  
https://discourse.cmake.org/t/automatically-wrapping-a-static-library-in-whole-archive-no-whole-archive-when-used-during-linking/5883