        global _start

        section .text
_start:
        xor rax, rax                   ; system call read
        xor rdi, rdi                   ; stdin
        mov rsi, bf_program            ; give buffer
        mov rdx, 0x1000                ; max size = 0x1000
        syscall                        ; exec
        push rax                       ; store nr of bytes

        mov rax, 1                     ; system call for write
        mov rdi, 1                     ; file handle 1 is stdout
        mov rsi, bf_program            ; address of string to output
        pop rdx                        ; number of bytes
        syscall                        ; invoke operating system to write

        mov rax, 60                    ; system call for exit
        xor rdi, rdi                   ; exit code 0
        syscall                        ; invoke operating system to exit

compile:
    ; Here we need to convert bf_program into

plus_start:
        add r13d, 1
plus_end:

sub_start:
        sub r13d, 1
sub_end:

bigger_start:
        mov [rbp + rcx * 4], r12d
        inc r13w
bigger_end:

smaller_start:
        mov [rbp + rcx * 4], r12d
        dec r13w
smaller_end:

; section .texts
message:
        db "Hello, World", 10          ; note the newline at the end

        section .bss nobits alloc exec write align=16
bf_program:
        resb 0x1000

program_memory:
        resb 0x1000

memory:
        resw 0x10000

