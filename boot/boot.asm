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
bdb_dir_entries_count:      dw 0E0h
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

clrscr:
  mov ah, 0x00
  mov al, 0x03
  int 0x10
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

    ;; clear screen
    call clrscr
    ; jmp $

    ;; welcome you
    mov si, welcome
    call swrite

    ;; another line
    mov si, another
    call swrite

    ;; read data from floppy
    mov [ebr_drive_number], dl 
    
    mov ax, 1       ; second sector from disk 
    mov cl, 1       ; 1 sector to read 
    mov bx, 0x7E00  ; data after bootloader
    call disk_read

    hlt

; ------------------------------
; Floppy read failure exceptions
; ------------------------------

floppy_error:
  mov ah, 0     ; wait for keypress
  int 0x16
  jmp bios_reboot

bios_reboot:
  jmp 0FFFFh:0  ; beginning of bios 

.halt:
  cli 
  hlt 

; ----------------
; Disk shenanigans
; ----------------
lba_to_chs:
  push ax
  push dx

  xor dx, dx                        ; dx = 0 
  div word [bdb_sectors_per_track]  ; ax, dx = lba [/, %] spt

  inc dx
  mov cx, dx    ; cx = sector 
  
  xor dx, dx
  div word [bdb_heads]

  mov dh, dl 
  mov ch, al 
  shl ah, 6
  or cl, al     ; put upper 2 bits of cylinder in CL

  pop ax
  mov dl, al    ; restore
  pop ax
  ret

; -----------------
; Read disk sectors
; -----------------
; Usage:
;   - ax:    LBA address
;   - cl:    # of sectors to read (up to 128)
;   - dl:    drive number 
;   - es:bx: stored data memory address
disk_read:
  ;; save registers
  push ax
  push bx 
  push cx
  push dx 
  push di 

  push cx           ; temporarily save cl 
  call lba_to_chs   ; compute CHS 
  pop ax            ; # of sectors to read 

  mov ah, 0x02
  mov di, 3 

.again:
  pusha       ; save registers
  stc         ; set carry flag
  int 0x13
  jnc .done   ; if carry not set

  ;; failed
  popa
  call disk_reset
  
  dec di 
  test di, di 
  jnz .again

.fail:
  err: db 'ERROR Cannot read from disk in any way!!!!', BRK, 0
  mov si, err 
  call swrite

  jmp floppy_error

.done:
  popa
  
  ;; restore modified registers
  push ax
  push bx 
  push cx
  push dx 
  push di 

  ret 

; ----------
; Reset disk
; ----------
; Usage:
;   - dl: drive number 
disk_reset:
  ;; reset uhhhhhhhhhhhhh i forgot
  pusha 

  mov ah, 0 
  stc 
  int 0x13
  jc floppy_error

  popa

  ret 

; -------------------
; Our welcome message
; -------------------
welcome: db 'envySystem 0.0.2.1-0, Copyright (c) 2025 Buck. All Rights Reserved.', BRK, 0
another: db 'Time of writing THIS exact message: 2025-03-15 17:46:19', BRK, 0

times 510-($-$$) db 0
dw 0xAA55
