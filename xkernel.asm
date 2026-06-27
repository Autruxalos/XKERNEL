; =============================================================================
; XKERNEL - THE UNIFIED MULTI-ARCH EXOKERNEL (16 / 32 / 64-BIT FAT KERNEL)
; Syntax: NASM
; =============================================================================

org 0x10000                     ; Dirección de carga estándar en RAM

; =============================================================================
; SECCIÓN 1: ENTRADA EN MODO REAL (16-BITS)
; =============================================================================
bits 16
_kernel_entry_16:
    ; Si el cargador nos dejó en 16 bits, usamos interrupciones de la BIOS
    mov si, msg_kernel_16
    call print_string_16

    ; Saltamos a la sección de la Shell en modo 16-bits
    jmp _xsh_entry_16

print_string_16:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

msg_kernel_16 db '-> XKERNEL: Operando en Modo Real de 16-bits.', 13, 10, 0


; =============================================================================
; SECCIÓN 2: ENTRADA EN MODO PROTEGIDO (32-BITS)
; =============================================================================
bits 32
align 16
_kernel_entry_32:
    ; Si despertamos en 32 bits, no hay BIOS. Escribimos directo en la pantalla VGA
    mov esi, msg_kernel_32
    mov edi, 0xB8000            ; Dirección física de memoria de video texto
    mov ah, 0x0F                ; Color: Blanco
.loop:
    lodsb
    cmp al, 0
    je .done
    mov [edi], ax
    add edi, 2
    jmp .loop
.done:
    ; Saltar a la Shell de 32 bits
    jmp _xsh_entry_32

msg_kernel_32 db '-> XKERNEL: Operando en Modo Protegido de 32-bits (VGA Direct).', 0


; =============================================================================
; SECCIÓN 3: ENTRADA EN MODO LARGO (64-BITS NATIVOS)
; =============================================================================
bits 64
align 16
_kernel_entry_64:
    ; Si despertamos en 64 bits nativos, tenemos acceso a los registros Rxx expandidos
    mov rsi, msg_kernel_64
    mov rdi, 0xB80A0            ; Escribir en la segunda línea de la pantalla VGA (80 caracteres * 2)
    mov ah, 0x0E                ; Color: Amarillo/Blanco
.loop:
    lodsb
    cmp al, 0
    je .done
    mov [rdi], ax
    add rdi, 2
    jmp .loop
.done:
    ; Saltar a la Shell de 64 bits
    jmp _xsh_entry_64

msg_kernel_64 db '-> XKERNEL: Operando en Modo Largo de 64-bits Nativo.', 0
