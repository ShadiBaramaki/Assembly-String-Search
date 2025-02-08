.model small
.stack 100h
.data
    input1 db 100, ?, 100 dup('$')
    input2 db 20, ?, 20 dup('$')
    reversed db 100 dup('$')
    msg_main db 'Enter main string: $'
    msg_sub db 10, 13, 'Enter sub string: $'
    msg_original db 10, 13, 'string: $'
    msg_search db 10, 13, 'sub string: $'
    msg_count db 10, 13, ' match numbers: $'
    msg_indexes db 10, 13, 'Match locations: $'
    msg_reversed db 10, 13, 'Reversed string: $'
    match_total dw 0
    match_positions dw 50 dup(0)

.code
entry_point proc
    mov ax, @data
    mov ds, ax

    lea dx, msg_main
    mov ah, 09h
    int 21h
    lea dx, input1
    mov ah, 0ah
    int 21h

    lea dx, msg_sub
    mov ah, 09h
    int 21h
    lea dx, input2
    mov ah, 0ah
    int 21h

    call reverse_primary
    call find_matches
    call show_outputs

    mov ah, 4ch
    int 21h
entry_point endp

reverse_primary proc
    mov si, offset input1 + 2
    mov di, offset reversed
    mov cx, 0
    mov cl, [input1 + 1]

    add si, cx
    dec si

rev_loop_new:
    mov al, [si]
    mov [di], al
    dec si
    inc di
    loop rev_loop_new

    mov byte ptr [di], '$'
    ret
reverse_primary endp

find_matches proc
    mov si, offset input1 + 2
    mov di, offset input2 + 2
    mov bx, offset match_positions
    xor cx, cx  
    xor dx, dx 

search_loop_new:
    push si
    push di
    push cx

compare_loop_new:
    mov al, [si]
    mov ah, [di]
    cmp al, 0Dh
    je check_match_end
    cmp ah, 0Dh
    je match_confirmed
    cmp al, ah
    jne no_match_found
    inc si
    inc di
    jmp compare_loop_new

check_match_end:
    cmp ah, 0Dh
    je match_confirmed

no_match_found:
    pop cx
    pop di
    pop si
    inc si
    inc cx
    mov al, [si]
    cmp al, 0Dh
    je search_complete
    jmp search_loop_new

match_confirmed:
    pop cx
    pop di
    pop si
    inc dx
    mov [bx], cx
    add bx, 2
    inc si
    inc cx
    mov al, [si]
    cmp al, 0Dh
    jne search_loop_new

search_complete:
    mov [match_total], dx
    ret
find_matches endp

show_outputs proc
    lea dx, msg_original
    mov ah, 09h
    int 21h
    lea dx, input1 + 2
    int 21h

    lea dx, msg_search
    mov ah, 09h
    int 21h
    lea dx, input2 + 2
    int 21h

    lea dx, msg_count
    mov ah, 09h
    int 21h
    mov ax, [match_total]
    call print_num

    cmp ax, 0
    je skip_display_positions
    lea dx, msg_indexes
    mov ah, 09h
    int 21h
    mov cx, [match_total]
    mov si, offset match_positions

display_positions_loop:
    mov ax, [si]
    call print_num
    mov dl, ' '
    mov ah, 02h
    int 21h
    add si, 2
    loop display_positions_loop

skip_display_positions:
    lea dx, msg_reversed
    mov ah, 09h
    int 21h
    lea dx, reversed
    int 21h

    ret
show_outputs endp

print_num proc
    push ax
    push bx
    push cx
    push dx

    xor cx, cx
    mov bx, 10

divide_num_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz divide_num_loop

print_num_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_num_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

end entry_point
