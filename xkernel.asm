; =============================================================================
; XKERNEL - XOS NATIVE 64-BIT EXOKERNEL CORE
; Syntax: NASM (64-bit Long Mode)
; =============================================================================

bits 64
org 0x10000                     ; El cargador colocará el Kernel en esta dirección física

_kernel_entry:
    ; 1. Inicializar los registros de datos para asegurar el entorno plano de 64 bits
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; 2. Limpiar la pantalla de video (Dirección de memoria VGA de texto: 0xB8000)
    call kernel_clear_screen

    ; 3. Imprimir el mensaje de inicialización del Exokernel
    mov rsi, msg_kernel_start
    mov rbx, 0                  ; Fila 0
    mov rdx, 0                  ; Columna 0
    call kernel_print

    ; 4. TRANSFERENCIA DE CONTROL AL SUBSISTEMA (Filosofía Exokernel)
    ; Saltamos directamente a la dirección donde el cargador dejó el binario de XSH (ej. 0x20000)
    mov rsi, msg_kernel_jump
    mov rbx, 1                  ; Fila 1
    mov rdx, 0
    call kernel_print

    ; Salto definitivo a XSH (Shell)
    jmp 0x20000

; =============================================================================
; RUTINAS DEL NÚCLEO (CONTROL DIRECTO DE HARDWARE)
; =============================================================================

kernel_clear_screen:
    mov rdi, 0xB8000            ; Puntero base a la memoria de video VGA
    mov rcx, 2000               ; 80 columnas * 25 filas = 2000 caracteres
    mov ax, 0x0F20              ; 0x0F = Texto blanco sobre fondo negro, 0x20 = Espacio en blanco
.loop:
    mov [rdi], ax
    add rdi, 2
    loop .loop
    ret

kernel_print:
    ; Entrada: RSI = Dirección de la cadena (terminada en 0)
    ;          RBX = Fila (0-24), RDX = Columna (0-79)
    push rax
    push rdi
    
    ; Calcular el offset en la memoria de video: (Fila * 80 + Columna) * 2
    imul rbx, 80
    add rbx, rdx
    imul rbx, 2
    mov rdi, 0xB8000
    add rdi, rbx                ; RDI ahora apunta a las coordenadas exactas

.print_loop:
    lodsb                       ; Cargar siguiente byte de RSI en AL
    cmp al, 0
    je .print_done
    mov ah, 0x0F                ; Atributo de color: Blanco brillante
    mov [rdi], ax               ; Escribir caracter + atributo en la pantalla
    add rdi, 2                  ; Avanzar al siguiente espacio de caracter
    jmp .print_loop

.print_done:
    pop rdi
    pop rax
    ret

; =============================================================================
; SECCIÓN DE DATOS DEL KERNEL
; =============================================================================
msg_kernel_start db '-> XOS Exokernel Inicializado con éxito (Modo Largo 64-bits).', 0
msg_kernel_jump  db '-> Cediendo control seguro del hardware a XSH...', 0
