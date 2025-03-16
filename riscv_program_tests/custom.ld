SECTIONS
{
    . = 0x80000000;       /* Start address */
    .text : { *(.text) }  /* Place all `.text` sections here */
    .data : { *(.data) }  /* Place all `.data` sections here */
    .bss : { *(.bss) }    /* Place all `.bss` sections here */
}