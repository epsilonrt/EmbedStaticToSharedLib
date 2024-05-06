
SRC_DIR := src
TEST_DIR := test
OBJ_DIR := obj
BIN_DIR := bin
LIB_DIR := lib

EXE := $(BIN_DIR)/test_filed
EXE_SRC := $(TEST_DIR)/test_filed.c
EXE_OBJ := $(EXE_SRC:$(TEST_DIR)/%.c=$(OBJ_DIR)/%.o)

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