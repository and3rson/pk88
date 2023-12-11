SECTIONS
{
    .rodata 0x0000 : AT(0xF0000) {
        *(.rodata);
    }
    .text : {
        *(.text);
    }
    .reset 0xFFF0 : {
        *(.reset)
    }
}
