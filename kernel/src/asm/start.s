# Assembly for booting

.section .text.entry

# Declare _start used in linker.ld script

.global _start

_start:

    # Setup Stack
    la sp, boot_stack_top
    mv tp, a0

    call kernel_entry

.section .bss.stack
.global boot_stack

boot_stack:
    # 16K
    .space 4096 * (kernel_stack_size)

.global boot_stack_top
boot_stack_top: