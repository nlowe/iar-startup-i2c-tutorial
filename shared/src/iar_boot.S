        NAME boot
    
        PUBLIC  __iar_program_start
        PUBLIC  __vector_table
        PUBLIC  _halt
        EXTERN  main
        EXTERN  __stack
        EXTERN  __i2c1_ev
        EXTERN  __i2c1_er
        
        // SFE and SFB need segment definitions in the same object
        // Declare data and init table here as well
        RSEG .data : DATA(2)
        RSEG .data_init : CONST(2)
        
        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
        // Initialize data segment 4 words at a time
__iar_program_start:
        ldr     r0,  =SFB(.data_init)
        ldr     r1,  =SFB(.data)
        eor     r6, r6, r6
        ldr     r7, =SIZEOF(.data_init)
__init_data:
        sub     r8, r7, r6
        cmp     r8, #16
        blt     __init_data_small // less than 4 words left?
        ldmia   r0!, {r2-r5}
        stmia   r1!, {r2-r5}
        add     r6, r6, #16
        cmp     r6, r7
        blt     __init_data
        
__init_data_small: // copy the remaining bytes one byte at a time
        cmp     r6, r7
        beq     __init_done
        ldrb    r2, [r0], #1
        strb    r2, [r1], #1
        add     r6, r6, #1
        b       __init_data_small
        
        
__init_done:
        // Zero registers
        eor     r1, r1, r1
        eor     r2, r2, r2
        eor     r3, r3, r3
        eor     r4, r4, r4
        eor     r5, r5, r5
        eor     r6, r6, r6
        eor     r7, r7, r7
        eor     r8, r8, r8
        
        // Go do the thing
        B       main
        
_halt:  B      _halt

        ;; Forward declaration of sections.
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     __stack
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler
        
        REPT    31
        DCD     NOP_Handler // I don't want any other interrupts please
        ENDR
        
        DCD     I2C1_EV_IRQHandler
        DCD     I2C1_ER_IRQHandler
        
        REPT    48
        DCD     NOP_Handler
        ENDR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB
        
NOP_Handler
        mov     pc, lr
        
I2C1_EV_IRQHandler
        push    {lr}
        bl      __i2c1_ev
        pop     {pc}

I2C1_ER_IRQHandler
        push    {lr}
        bl      __i2c1_er
        pop     {pc}

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler
        
        END