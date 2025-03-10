# gdb_script.gdb
target remote :1234
set architecture i386:x86-64
break multiboot_entry
