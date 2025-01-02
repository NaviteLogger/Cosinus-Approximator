#!/bin/bash

# Check if a directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory> <filename>"
    exit 1
fi

# Assign the directory argument to a variable
DIR="$1"

# Check if the directory exists
if [ ! -d "$DIR" ]; then
    echo "Directory $DIR does not exist."
    exit 1
fi

# Navigate to the specified directory
cd "$DIR" || exit

# Find all .asm files in the directory and assemble them
for ASM_FILE in *.asm; do
    if [ -f "$ASM_FILE" ]; then
        OBJ_FILE="${ASM_FILE%.asm}.obj"
        echo "Assembling $ASM_FILE to $OBJ_FILE"
        nasm -g -f elf32 "$ASM_FILE" -o "$OBJ_FILE"
        # gcc -m32 interface.c file1.obj file2.obj -o program
                if [ $? -ne 0 ]; then
            echo "Error assembling $ASM_FILE"
            exit 1
        fi
    fi
done

# Compile the C program and link it with the static library
C_FILE="$2"
if [ -f "$C_FILE" ]; then
    echo "Compiling $C_FILE"
    gcc -g -m32 -o main.o -c ${C_FILE}
    if [ $? -ne 0 ]; then
        echo "Error compiling $C_FILE"
        exit 1
    fi
else
    echo "C file $C_FILE not found."
    exit 1
fi

# Link the object files to create the executable
echo "Linking object files"
ASM_FILES=$(ls *.obj)
ASM_FILES=$(echo $ASM_FILES | tr '\n' ' ')
echo "ASM_FILES: $ASM_FILES"

gcc -m32 $ASM_FILES main.o -o main -lc -g
if [ $? -ne 0 ]; then
    echo "Error linking object files"
    exit 1
fi

echo "Build successful."