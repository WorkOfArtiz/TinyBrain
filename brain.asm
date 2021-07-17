; compile runtime
; rsi = pointer to offset in bf_program where we're working
; rcx = nr of bytes left in bf_program to compile
; r14 = nr of bytes in compiled program

; mini abi:
; rsp, rbp - off limits
; r11, r12 - arg1, arg2 of functions
; rsi - current offset
; rax, rbx, rdx, rdi  - scratch

        global _start
        section .text
_start:
main:
        xor rax, rax                   ; system call read
        xor rdi, rdi                   ; stdin
        mov rsi, bf_program            ; give buffer
        mov rdx, 0x1000                ; max size = 0x1000
        syscall                        ; exec

        mov rsi, bf_program            ; rsi = char * pointing to current offset
        mov rcx, rax                   ; rcx = nr of bytes left
        xor r14, r14                   ; r14 = compiled program length = 0

main.compile_loop:
        test rcx, rcx
        jz main.done_compiling
        mov al, byte [rsi]

        cmp al, '-'
        je main.append_minus

        cmp al, '+'
        je main.append_plus

        cmp al, '<'
        je main.append_smaller

        cmp al, '>'
        je main.append_bigger

        cmp al, '.'
        je main.append_period

        cmp al, ', '
        je main.append_comma

        cmp al, '['
        je main.append_open

        cmp al, ']'
        je main.append_close

main.compile_loop_update:
        sub rcx, 1
        add rsi, 1
        jmp main.compile_loop

main.append_plus:
        mov r11, plus.start
        mov r12, plus.finish - plus.start
        call append
        jmp main.compile_loop_update

main.append_minus:
        mov r11, minus.start
        mov r12, minus.finish - minus.start
        call append
        jmp main.compile_loop_update

main.append_bigger:
        mov r11, bigger.start
        mov r12, bigger.finish - bigger.start
        call append
        jmp main.compile_loop_update

main.append_smaller:
        mov r11, smaller.start
        mov r12, smaller.finish - smaller.start
        call append
        jmp main.compile_loop_update

main.append_period:
        mov r11, period.start
        mov r12, period.finish - period.start
        call append
        jmp main.compile_loop_update

main.append_comma:
        mov r11, comma.start
        mov r12, comma.finish - comma.start
        call append
        jmp main.compile_loop_update

main.append_open:
        mov al, 0xE9                   ; unconditional relative jump
        mov byte [program_memory + r14], al
        add r14, 5                     ; jmp = e9 [00 00 00 00]
        push r14                       ; store the address AFTER jmp
        jmp main.compile_loop_update

main.append_close:
; Link in the jump in the opening bracket
        pop rdi                        ; store address of first address after matching open in rdi
        mov rbx, r14                   ; get current
        sub rbx, rdi                   ; calculate the difference
        mov dword [program_memory + rdi - 4], ebx ; write the correct offset

; Append the binary for ecx=0, test eax,ecx, jnz 000000
        mov r11, close.start
        mov r12, close.finish - close.start
        call append

        sub rdi, r14
        mov [program_memory + r14 - 4], rdi

        jmp main.compile_loop_update

main.done_compiling:
        mov r11, main.exit
        mov r12, main.finish - main.exit
        call append

        %ifdef DUMP_CODE               ; print binary
        mov rax, 1
        mov rdi, 1
        mov rsi, program_memory
        mov rdx, r14
        syscall
        %endif

        %ifdef EXECUTE                 ; execute code
        xor r13, r13
        xor rax, rax
        jmp program_memory
        %endif

main.exit:
        mov rax, 60                    ; system call for exit
        xor rdi, rdi                   ; exit code 0
        syscall                        ; invoke operating system to exit
main.finish:

; append call dest = program_memory+r14, r11 = src, r12 = len, clobbers rax, updates r14
append:
        test r12, r12
        jz append.return
        mov al, byte [r11]
        mov byte [program_memory + r14], al
        sub r12, 1
        add r11, 1
        add r14, 1
        jmp append

append.return:
        ret

; BF-runtime registers
; current memory pointer [memory + r13d * 4]
; current memory value    eax
plus.start:
        add eax, 1
plus.finish:

minus.start:
        sub eax, 1
minus.finish:

bigger.start:
        mov [memory + r13d * 4], eax
        add r13d, 1
        mov eax, [memory + r13d * 4]
bigger.finish:

smaller.start:
        mov [memory + r13d * 4], eax
        sub r13d, 1
        mov eax, [memory + r13d * 4]
smaller.finish:

close.start:
        xor ecx, ecx
        cmp eax, ecx
        db 0x0f, 0x85, 0x0, 0x0, 0x0, 0x0 ; jnz (0xf, 0x85) with relative [32 bit index]
close.finish:

period.start:
        push rax
        mov byte [bf_program], al
        mov rax, 1                     ; SYS_WRITE
        mov rdi, rax                   ; stdio
        mov rsi, bf_program            ; (char *) bf_program
        mov rdx, rax                   ; len = 1
        syscall                        ; syscall
        pop rax
period.finish:

comma.start:
        xor rax, rax                   ; system call read
        xor rdi, rdi                   ; stdin
        mov rsi, bf_program            ; give buffer
        mov rdx, 1                     ; max size = 1
        syscall                        ; exec
        xor rdi, rdi
        cmp rax, rdi
        cmovg rax, [bf_program]
comma.finish:

        section .bss nobits alloc exec write align=16
bf_program:
        resb 0x1000

program_memory:
        resb 0x1000

memory:
        resw 0x10000

