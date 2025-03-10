OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)

STACK_SIZE = 0x4000;

PHDRS 
{
    text PT_LOAD FLAGS(5);    /* READ | EXEC */
    rodata PT_LOAD FLAGS(4);  /* READ */
    data PT_LOAD FLAGS(6);    /* READ | WRITE */
    bss PT_LOAD FLAGS(6);     /* READ | WRITE */
    stack PT_LOAD FLAGS(6);   /* READ | WRITE */
}

SECTIONS
{
    . = 2M;

    .multiboot : {
        *(.multiboot)
    } :rodata

    .text : {
        *(.text)
    } :text

    /* Read-only data. */
    .rodata : {
        *(.rodata)
    } :rodata

    /* Read-write data (initialized) */
    .data : {
        *(.data)
    } :data

    /* Read-write data (uninitialized) and stack */
    .bss : {
        *(COMMON)
        *(.bss)
    } :bss

    /* Stack section */
    .stack (NOLOAD) : {
        . = . + STACK_SIZE;
    } :bss

    /* GNU stack note */
    .note.GNU-stack : { } 
}