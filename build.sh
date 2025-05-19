if [ -z "$1" ]; then
    echo "error: no file provided"
    exit 1
fi
nasm -f elf32 -o test.o $1 && ld -m elf_i386 test.o -o a.out
echo "compiled $1 as an elf32 binary"
rm test.o
