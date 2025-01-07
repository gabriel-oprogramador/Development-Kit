#!/bin/bash

# Diretórios e configurações
OUTPUT="../DK"
INCLUDE_DIR="DK/LuaApi/Include"
SOURCE_DIR="DK/LuaApi"
CFLAGS=" -DLUA_USE_LINUX -Wall -O2 -lm -I$INCLUDE_DIR"
SOURCES=$(find $SOURCE_DIR -name "*.c")

# Verificar qual compilador está disponível
if command -v gcc &> /dev/null; then
    COMPILER="clang"
    echo "Using clang to compile."
else
    COMPILER="gcc"
    echo "Using gcc to compile."
fi

# Compilar o projeto
echo "Starting Build: Development-Kit"
$COMPILER  DK/DK.c $SOURCES -o $OUTPUT $CFLAGS

# Verificar se a compilação teve sucesso
if [ $? -ne 0 ]; then
    echo "Build Failed!"
    exit 1
fi

echo "Build Success: $OUTPUT"