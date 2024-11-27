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

#define ASM_FILE        1
#include "multiboot2.h"
#include "page_types.h"
#include "cpu_types.h"

/*  C symbol format. HAVE_ASM_USCORE is defined by configure. */
#ifdef HAVE_ASM_USCORE
#define EXT_C(sym)                     _ ## sym
#else
#define EXT_C(sym)                     sym
#endif

/*  The size of our stack (16KB). */
#define STACK_SIZE                      0x4000
        
    .section .header
    
multiboot_header:
    /*  Align 64 bits boundary. */
    .align  8
    /*  magic */
    .long   MULTIBOOT2_HEADER_MAGIC
    /*  ISA: i386 */
    .long   MULTIBOOT_ARCHITECTURE_I386
    /*  Header length. */
    .long   multiboot_header_end - multiboot_header
    /*  checksum */
    .long   -(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + (multiboot_header_end - multiboot_header))
entry_address_tag_start:        
    .align  8
    .short MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS
    .short MULTIBOOT_HEADER_TAG_OPTIONAL
    .long entry_address_tag_end - entry_address_tag_start
    .long multiboot_entry
entry_address_tag_end:
end_tag_start:
    .align  8
    .short MULTIBOOT_HEADER_TAG_END
    .short 0
    .long end_tag_end - end_tag_start
end_tag_end:
multiboot_header_end:

    .section .text
    .code32
    .global _start
_start:
multiboot_entry:    
    movl    $(stack + STACK_SIZE), %esp

    /*  Reset EFLAGS. */
    pushl   $0
    popf

    /*  Push the pointer to the Multiboot information structure. */
    pushl   %ebx
    /*  Push the magic value. */
    pushl   %eax

    # set up page table for booting stage
    # it's okay to write only 32bit here :)
    mov     $boot_pud, %eax
    or      $(PDE_ATTR_P | PDE_ATTR_RW), %eax
    mov     %eax, boot_pgd

    xor     %eax, %eax
    or      $(PDE_ATTR_P | PDE_ATTR_RW | PDE_ATTR_PS), %eax
    movl    %eax, boot_pud

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

    /*  Load GDT */
    lgdt    gdt64_ptr

    /*  Far jump to enter 64-bit mode */
    jmp $(1 << SELECTOR_INDEX), $long_mode_entry


    #.code64
long_mode_entry:
    /*  Now enter the C main function... */
    call    EXT_C(cmain)

    /*  Halt. */
    push   $halt_message
    call    EXT_C(printf)

    /*  Halt if cmain returns */
loop:   
    hlt
    jmp     loop

    .section .data
halt_message:
    .asciz  "Halted."

    /*  Our stack area. */
    .comm   stack, STACK_SIZE

/* Temp tables*/
    .align  0x1000
boot_pgd:
    .space 0x1000
boot_pud:
    .space 0x1000
 
/*  GDT for 64-bit mode */
    .align  0x1000
gdt64:
    .quad   0x0000000000000000  /*  NULL descriptor */
    .quad   0x00209A0000000000  /*  Code segment */
    .quad   0x0000920000000000  /*  Data segment */
gdt64_ptr:
    .short  gdt64_ptr - gdt64 - 1
    .long   gdt64
    
