org 0x7C00  ; BIOS (Legacy) boots from address 0x7C00. this is where our OS will be.
bits 16     ; What mode to run on.

;; nasm macro for newline
%define BRK 0x0D, 0x0A

; ** Jump to `main` as without it, the assembler would think any other function is our
;    entry point.
start:
    jmp main

; ------------------------------
; Write a string to your screen
; ------------------------------
; Usage:
;   -   `ds-si` points to a 
;        string
swrite:
    ;; push registers to be used in the stack
    push si
    push ax

.loop:
    lodsb           ; load next character in AL
    or al, al       ; check if character is NULL
    jz .end

    mov ah, 0x0e    ; call bios interrupt
    mov bh, 0       ; set page number
    int 0x10

    jmp .loop       ; jump to this so the code loops

.end:
    ;; pop previously pushed registers in reverse order
    pop ax
    pop si
    ret



; -------------------------
; Main entry of our program
; -------------------------
main:
    ;; data segments
    mov ax, 0          ; can't write to ds/es directly
    mov ds, ax
    mov es, ax

    ;; setup stack
    mov ss, ax
    mov sp, 0x7C00     ; stack grows downward from loaded memory location

    ;; welcome you
    mov si, welcome
    call swrite

    ;; another line
    mov si, another
    call swrite

    hlt

.halt:
    jmp .halt

; -------------------
; Our welcome message
; -------------------
welcome: db 'envySystem 0.0.1-0 :: Purgatory. Enjoy your stay.', BRK, 0
another: db 'This may be the start of something so great.', BRK, 0

times 510-($-$$) db 0
dw 0AA55h