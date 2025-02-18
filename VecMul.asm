section .text
global dot

; =======================================================
; FUNCTION: vector product of 2 integer arrays
; Arguments:
;   [esp+4] arr0 (int*) - Pointer to the start of arr0
;   [esp+8] arr1 (int*) - Pointer to the start of arr1
;   [esp+12] n (int)    - Number of elements to use
;   [esp+16] s0 (int)   - Stride of arr0
;   [esp+20] s1 (int)   - Stride of arr1
; Returns:
;   eax (int)           - Dot product of arr0 and arr1
; Exceptions:
;   - Error 36: If n < 1
;   - Error 37: If either stride < 1
; =======================================================
dot:
    ; Prologue
    push ebp
    mov ebp, esp
    sub esp, 8            ; Allocate space for local variables
    push esi              ; Save caller-saved registers
    push edi
    push ebx

    ; Initialize variables
    mov ebx, 0            ; t1 = sum = 0
    mov ecx, 0            ; t2 = index = 0

    ; Load arguments
    mov esi, [ebp+8]      ; arr0
    mov edi, [ebp+12]     ; arr1
    mov eax, [ebp+16]     ; n
    cmp eax, 1            ; n >= 1?
    jl error_1

    mov edx, [ebp+20]     ; s0 (stride for arr0)
    cmp edx, 1            ; s0 >= 1?
    jl error_2

    mov edx, [ebp+24]     ; s1 (stride for arr1)
    cmp edx, 1            ; s1 >= 1?
    jl error_2

loop_start:
    cmp ecx, [ebp+16]     ; if (t2 >= n), exit loop
    jge loop_end

    ; Calculate offsets for arr0 and arr1
    mov eax, ecx          ; eax = t2
    imul eax, [ebp+20]    ; eax = t2 * s0 (stride of arr0)
    shl eax, 2            ; eax = offset for arr0
    add eax, esi          ; eax = address of arr0[t2]
    mov edx, [eax]        ; edx = value of arr0[t2]

    mov eax, ecx          ; eax = t2
    imul eax, [ebp+24]    ; eax = t2 * s1 (stride of arr1)
    shl eax, 2            ; eax = offset for arr1
    add eax, edi          ; eax = address of arr1[t2]
    mov eax, [eax]        ; eax = value of arr1[t2]

    ; Multiply and accumulate
    imul eax, edx         ; t3 * t4
    add ebx, eax          ; sum += t3 * t4

    ; Increment index and repeat
    inc ecx
    jmp loop_start

loop_end:
    ; Return result
    mov eax, ebx          ; eax = sum
    jmp cleanup

error_1:
    mov eax, 36           ; Error code 36
    jmp exit

error_2:
    mov eax, 37           ; Error code 37
    jmp exit

cleanup:
    ; Epilogue
    pop ebx
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret
