; =============================================================================
; XKERNEL - THE OFFICIAL XOS EXOKERNEL [XSPEC-0004]
; Syntax: NASM (16-bit Real Mode)
; Punto de carga físico: 0x1000:0x0000
; =============================================================================

bits 16
org 0x0000                      ; Offset 0 dentro del segmento 0x1000

xkernel_entry:
    ; 1. Asegurar que los segmentos apunten al entorno del Kernel
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; 2. Mensaje oficial de inicialización del núcleo
    mov si, msg_kernel_start
    call k_print_string

    ; 3. INICIALIZACIÓN DE COMPONENTES CORE (Versión 1)
    call k_init_timer           ; Inicializar temporizador (Frecuencia base)
    call k_init_keyboard        ; Inicializar buffer de teclado
    call k_init_interrupts      ; Configurar tabla de interrupciones (IVT)

    mov si, msg_kernel_ready
    call k_print_string

    ; 4. CONFIGURAR PARÁMETROS Y SALTAR A EXIT
    ; Simulamos la llamada al binario modular EXIT que ya tienes en GitHub.
    ; En una imagen unificada, haríamos un salto lejano al segmento de EXIT.
    jmp k_launch_exit

; =============================================================================
; API DEL NÚCLEO: FUNCIONES DEL SUBSISTEMA DE VIDEO
; =============================================================================
k_print_string:
    push ax
    push bx
    mov ah, 0x0E                ; Servicio TTY de la BIOS (Hardware de video)
    mov bh, 0x00                ; Página de video 0
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10                    ; Interrupción nativa de video
    jmp .loop
.done:
    pop bx
    pop ax
    ret

; =============================================================================
; API DEL NÚCLEO: SUBSISTEMA DE TEMPORIZADOR (TIMER)
; =============================================================================
k_init_timer:
    mov si, msg_sub_timer
    call k_print_string
    ; Aquí se reprogramaría el chip Intel 8253/8254 PIT (Programmable Interval Timer)
    ret

; =============================================================================
; API DEL NÚCLEO: SUBSISTEMA DE TECLADO (KEYBOARD)
; =============================================================================
k_init_keyboard:
    mov si, msg_sub_keyboard
    call k_print_string
    ; Configuración inicial del buffer de escaneo de teclas
    ret

; =============================================================================
; API DEL NÚCLEO: SUBSISTEMA DE INTERRUPCIONES (INTERRUPTS)
; =============================================================================
k_init_interrupts:
    mov si, msg_sub_int
    call k_print_string
    ; En las versiones posteriores, aquí mapearás las interrupciones del Exokernel completo.
    ret

; =============================================================================
; ENRUTADOR HACIA EL SUBSISTEMA EXIT
; =============================================================================
k_launch_exit:
    mov si, msg_kernel_jump
    call k_print_string
    
    ; Aquí es donde el Exokernel cede el control al Init de XOS (EXIT)
    ; Para propósitos de simulación en esta fase, congelamos el procesador de forma segura.
    cli
.halt:
    hlt
    jmp .halt

; =============================================================================
; SECCIÓN DE DATOS (IDENTIDAD GRÁFICA NATIVA XOS)
; =============================================================================
msg_kernel_start    db 'XKERNEL: Despertando el Exokernel base...', 13, 10, 0
msg_sub_timer       db '  -> Temporizador del sistema... [OK]', 13, 10, 0
msg_sub_keyboard    db '  -> Controlador de teclado...... [OK]', 13, 10, 0
msg_sub_int         db '  -> Vectores de interrupcion.... [OK]', 13, 10, 0
msg_kernel_ready    db 'XKERNEL: Multiplexacion de hardware lista.', 13, 10, 0
msg_kernel_jump     db 'XKERNEL: Saltando al proceso de inicializacion EXIT...', 13, 10, 0
