org 0x7C00  ; BIOS (Legacy) boots from address 0x7C00. this is where our OS will be.
bits 16     ; What mode to run on.

;; nasm macro for newline
%define BRK 0x0D, 0x0A



; ------------
; FAT12 header
; ------------
jmp short start
nop

bdb_oem:                    db "MSWIN4.1"         ; 8 bytes
bdb_bytes_per_sector:       dw 512             
bdb_sectors_per_cluster:    db 1                  
bdb_reserved_sectors:       dw 1                  
bdb_number_of_fats:         db 2                  
bdb_dir_entries_countL:     dw 0E0h
bdb_total_sectors:          dw 2880                ; 1.44MB
bdb_media_descriptor:       db 0F0h                ; 3.5" 1.44MB floppy
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

;; extended boot record
ebr_drive_number:           db 0
                            db 0                    ; reserved
ebr_signature:              db 29h                  ; 0x29
ebr_volume_id:              dd 47h, 48h, 49h, 50h
ebr_volume_label:           db "ENVYSYSTEM "        ; 11 bytes
ebr_system_id:              db "FAT12   "           ; 8 bytes




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
welcome: db 'myHandwrittenSystem 0.0.2-0 bootloader', BRK, 0
another: db 'No kernel has been written yet', BRK, 0

times 510-($-$$) db 0
dw 0AA55h