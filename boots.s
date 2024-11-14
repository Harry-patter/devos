# 0 "boot.s"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "boot.s"
# 21 "boot.s"
# 1 "multiboot2.h" 1
# 22 "boot.s" 2
# 1 "cpu_types.h" 1
# 23 "boot.s" 2
# 1 "page_types.h" 1
# 24 "boot.s" 2





.section .header
.align 8
    multiboot_header:
    .align 8

        .long 0xe85250d6

        .long 0

        .long multiboot_header_end - multiboot_header

        .long -(0xe85250d6 + 0 + (multiboot_header_end - multiboot_header))
# 68 "boot.s"
    framebuffer_tag_start:
    .align 8
        .short 5
        .short 1
        .long framebuffer_tag_end - framebuffer_tag_start
        .long 1024
        .long 768
        .long 32
    framebuffer_tag_end:
    .align 8
        .short 0
        .short 0
        .long 8
multiboot_header_end:



.text
.code32
# .align 0x1000
# .extern kernel_main
.globl _start

_start:
    # turn off the interrupt temporarily,
    # and we should turn it on after our own IDT has been built.
    cli

    # check for multiboot2 header
    cmp $0x36d76289, %eax
    jne loop

    # temporary stack
    mov $boot_stack_top, %esp

    # set the boot information as parameters for boot_main()
    mov %eax, %edi
    mov %ebx, %esi


    push $0
    popf

    # disable paging (UEFI may turn it on)
    mov %cr0, %eax
    mov $(1 << 31), %ebx
    not %ebx
    and %ebx, %eax
    mov %eax, %cr0

    # set up page table for booting stage
    # it's okay to write only 32bit here :)
    mov $boot_pud, %eax
    or $((1 << 0) | (1 << 1)), %eax
    mov %eax, boot_pgd

    xor %eax, %eax
    or $((1 << 0) | (1 << 1) | (1 << 7)), %eax
    mov %eax, boot_pud

    xor %eax, %eax
    mov %eax, (boot_pgd + 4)
    mov %eax, (boot_pud + 4)

    # load page table
    mov $boot_pgd, %eax
    mov %eax, %cr3

    # enable PAE and PGE
    mov %cr4, %eax
    or $((1 << 5) | (1 << 7)), %eax
    mov %eax, %cr4

    # enter long mode by enabling EFER.LME
    mov $0xC0000080, %ecx
    rdmsr
    or $(1 << 8), %eax
    wrmsr

    # enable paging
    mov %cr0, %eax
    or $(1 << 31), %eax
    mov %eax, %cr0

    # set up GDT
    mov $gdt64_ptr, %eax
    lgdt 0(%eax)

    # reload all the segment registers
    mov $(2 << (3)), %ax
    mov %ax, %ds
    mov %ax, %ss
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    # enter the 64-bit world within a long jmp
    jmp $(1 << (3)), $kernel_main

loop:
    hlt
    jmp loop

.section .data
    .align 0x1000

    .globl boot_stack, boot_stack_top, boot_pgd, boot_pud


    # When the system is booted under legacy BIOS, there's no stack
    # So we reserve a page there as a temporary stack for booting

    boot_stack:
        .space 0x1000
    boot_stack_top:

    boot_pgd:
        .space 0x1000
    boot_pud:
        .space 0x1000

    # global segment descriptor table
    .align 0x1000 # it should be aligned to page
    .globl gdt64, gdt64_ptr
    gdt64:
        .quad 0 # first one must be zero
    gdt64_code_segment:
        .quad 0x00209A0000000000 # exec/read
    gdt64_data_segment:
        .quad 0x0000920000000000 # read/write
    gdt64_ptr:
        .short gdt64_ptr - gdt64 - 1 # GDT limit
        .long gdt64 # GDT Addr
