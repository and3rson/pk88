SECTIONS
{
    .code 0x0000 : AT(0xF0000) {
        *(.rodata);
        FILL(0xAD)
        *(.text);
        FILL(0xAD);
        . = 0xFFF0;
    }
    .reset . : AT(0xFFFF0) {
        *(.reset)
    }
}
