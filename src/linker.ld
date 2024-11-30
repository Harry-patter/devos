OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)

SECTIONS
{
	. = 2M;

	.text : {
		_start = .;
		*(.text)
	}

	/* Read-only data. */
	.rodata : {
		*(.rodata)
	}

	/* Read-write data (initialized) */
	.data : {
		*(.data)
	}

	/* Read-write data (uninitialized) and stack */
	.bss : {
		*(COMMON)
		*(.bss)
	}
}