/* Multiboot header. */
.equ MULTIBOOT2_HEADER_MAGIC,                 0xe85250d6
.equ MULTIBOOT_ARCHITECTURE_I386,             0
.equ MULTIBOOT_HEADER_TAG_FRAMEBUFFER,        5
.equ MULTIBOOT_HEADER_TAG_OPTIONAL,           1
.equ MULTIBOOT_HEADER_TAG_END,                0

/* page types */
.equ PDE_ATTR_P,     (1 << 0)
.equ PDE_ATTR_RW,    (1 << 1)
.equ PDE_ATTR_PS,    (1 << 7)

/* cpu types */
.equ CR0_PG,  (1 << 31)
.equ CR4_PAE, (1 << 5)
.equ CR4_PGE, (1 << 7)
.equ SELECTOR_INDEX, (3)

/*  size of stack */
.equ STACK_SIZE,                      0x4000

/* multiboot2 header read only section */
.section .multiboot, "a"    
    .align  8
multiboot_header:
    .long   MULTIBOOT2_HEADER_MAGIC
    .long   MULTIBOOT_ARCHITECTURE_I386
    .long   multiboot_header_end - multiboot_header
    .long   -(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + (multiboot_header_end - multiboot_header))
framebuffer_tag_start:  
    .align  8 
    .short MULTIBOOT_HEADER_TAG_FRAMEBUFFER
    .short MULTIBOOT_HEADER_TAG_OPTIONAL
    .long framebuffer_tag_end - framebuffer_tag_start
    .long 1024
    .long 768
    .long 32
framebuffer_tag_end:
end_tag:
    .align  8
    .short MULTIBOOT_HEADER_TAG_END
    .short 0
    .long 8
multiboot_header_end:

/*  Code section. read and exectuable*/
.section .text,  "ax"
    .code32
    .global _start
_start:
    jmp multiboot_entry

multiboot_entry:    
    movl    $(stack + STACK_SIZE), %esp

    /*  Reset EFLAGS. */
    pushl   $0
    popf
    
    /*  First Parm: Magic value. */
    mov     %eax, %edi
    /*  Second Parm: Pointer to the Multiboot information structure. */
    mov     %ebx, %esi

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

long_mode_entry:
    /*  Now enter the C main function... */
    call    kernel

loop:   
    hlt
    jmp     loop

/*  stack area. */
    .comm   stack, STACK_SIZE

/*  Temp tables */
    .align  0x1000
    .global boot_pgd, boot_pud
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

.section .note.GNU-stack,"",@progbits   /* disable stack protector */
