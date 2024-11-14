/*  boot.S - bootstrap the kernel */
/*  Copyright (C) 1999, 2001, 2010  Free Software Foundation, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/*for multiboot2.h*/
#define ASM_FILE        1       
#include "multiboot2.h"
#include "cpu_types.h"
#include "page_types.h"



/*  Multiboot header. */
/*  Align 64 bits boundary. */
.section .header
.align  8
    multiboot_header:
    .align  8
        /*  magic */
        .long   MULTIBOOT2_HEADER_MAGIC
        /*  ISA: i386 */
        .long   MULTIBOOT_ARCHITECTURE_I386
        /*  Header length. */
        .long   multiboot_header_end - multiboot_header
        /*  checksum */
        .long   -(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + (multiboot_header_end - multiboot_header))

    #ifndef __ELF__
    address_tag_start: 
    .align  8     
        .short MULTIBOOT_HEADER_TAG_ADDRESS
        .short MULTIBOOT_HEADER_TAG_OPTIONAL
        .long address_tag_end - address_tag_start
        /*  header_addr */
        .long   multiboot_header
        /*  load_addr */
        .long   _start
        /*  load_end_addr */
        .long   _edata
        /*  bss_end_addr */
        .long   _end
    address_tag_end:

    entry_address_tag_start:  
    .align  8      
        .short MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS
        .short MULTIBOOT_HEADER_TAG_OPTIONAL
        .long entry_address_tag_end - entry_address_tag_start
        /*  entry_addr */
        .long multiboot_entry
    entry_address_tag_end:
    #endif /*  __ELF__ */

    framebuffer_tag_start: 
    .align  8 
        .short MULTIBOOT_HEADER_TAG_FRAMEBUFFER
        .short MULTIBOOT_HEADER_TAG_OPTIONAL
        .long framebuffer_tag_end - framebuffer_tag_start
        .long 1024
        .long 768
        .long 32
    framebuffer_tag_end:
    .align  8
        .short MULTIBOOT_HEADER_TAG_END
        .short 0
        .long 8
multiboot_header_end:


/* start */        
.section .text
.code32
.align 0x1000
.extern kernel_main
.globl _start

_start:
    # turn off the interrupt temporarily,
    # and we should turn it on after our own IDT has been built.
    cli

    # check for multiboot2 header
    cmp     $MULTIBOOT2_BOOTLOADER_MAGIC, %eax
    jne     loop

    # temporary stack
    mov     $boot_stack_top, %esp

    # set the boot information as parameters for boot_main()
    mov     %eax, %edi
    mov     %ebx, %esi

    /*  Reset EFLAGS. */
    push   $0
    popf

    # disable paging (UEFI may turn it on)
    mov     %cr0, %eax
    mov     $CR0_PG, %ebx
    not     %ebx
    and     %ebx, %eax
    mov     %eax, %cr0

    # set up page table for booting stage
    # it's okay to write only 32bit here :)
    mov     $boot_pud, %eax
    or      $(PDE_ATTR_P | PDE_ATTR_RW), %eax
    mov     %eax, boot_pgd

    xor     %eax, %eax
    or      $(PDE_ATTR_P | PDE_ATTR_RW | PDE_ATTR_PS), %eax
    mov     %eax, boot_pud

    xor     %eax, %eax
    mov     %eax, (boot_pgd + 4)
    mov     %eax, (boot_pud + 4)

    # load page table
    mov     $boot_pgd, %eax
    mov     %eax, %cr3

    # enable PAE and PGE
    mov     %cr4, %eax
    or      $(CR4_PAE | CR4_PGE), %eax
    mov     %eax, %cr4

    # enter long mode by enabling EFER.LME
    mov     $0xC0000080, %ecx
    rdmsr
    or      $(1 << 8), %eax
    wrmsr

    # enable paging
    mov     %cr0, %eax
    or      $CR0_PG, %eax
    mov     %eax, %cr0

    # set up GDT
    mov     $gdt64_ptr, %eax
    lgdt    0(%eax)

    # reload all the segment registers
    mov     $(2 << SELECTOR_INDEX), %ax
    mov     %ax, %ds
    mov     %ax, %ss
    mov     %ax, %es
    mov     %ax, %fs
    mov     %ax, %gs

    # enter the 64-bit world within a long jmp
    jmp     $(1 << SELECTOR_INDEX), $kernel_main
        
loop:   
    hlt
    jmp     loop

.section .data
    .align 0x1000

    .globl boot_stack, boot_stack_top, boot_pgd, boot_pud

    #
    # When the system is booted under legacy BIOS, there's no stack
    # So we reserve a page there as a temporary stack for booting
    #
    boot_stack:
        .space 0x1000
    boot_stack_top:

    boot_pgd:
        .space 0x1000
    boot_pud:
        .space 0x1000

    # global segment descriptor table
    .align 0x1000   # it should be aligned to page
    .globl gdt64, gdt64_ptr
    gdt64:
        .quad 0 # first one must be zero
    gdt64_code_segment:
        .quad 0x00209A0000000000 # exec/read
    gdt64_data_segment:
        .quad 0x0000920000000000 # read/write
    gdt64_ptr:
        .short gdt64_ptr - gdt64 - 1    # GDT limit
        .long gdt64                     # GDT Addr
