.model tiny
.386
.code
org 100h


start:

    ; lea si, start  ; Начало секции .data
    ; mov cx, Wrong - start  ; Размер секции .data
    ; call Calculate_Hash_Of_Part_Code

    lea dx , Msg_Enter_Pass
    mov ah , 09h
    int 21h

    mov byte ptr InputBuffer , 20
    lea dx , InputBuffer
    mov ah , 0Ah
    int 21h

    ; Добавляем нулевой терминатор в конец ввода

    lea di , Input
    push di
    mov cl , InputLength
    add di , cx
    mov byte ptr [di] , 0
    pop di

    ; call Atbash_decoder
    lea si , obman
    lea di , Input
    call Compare
    cmp Compare_Result , 1
    je Block_User

    ; Сравниваем с настоящим паролем
    lea si , True_Password
    lea di , Input
    call Compare
    cmp Compare_Result , 1
    je Correct


    call Admin_Access
    ; lea si , Admin_Password
    ; lea di , Input
    ; call Compare
    ; cmp Compare_Result , 1
    ; je Admin_Access

Wrong:

    lea dx , Msg_Access_DEN
    mov ah , 09h
    int 21h
    jmp Exit

Correct:

    lea dx , Msg_Access_OK
    mov ah , 09h
    int 21h
    jmp Exit

Block_User:

    lea dx , Msg_Blocked
    mov ah , 09h
    int 21h
    jmp Exit

Admin_Access:

    xor ax , ax
    mov Hash_Sum_1 , ax

    lea si , start
    mov cx , Wrong - start
    call Calculate_Hash_Of_Part_Code


    cmp ax, [True_Hash_sum_1]
    jne Block_User  ; Если хэши не совпали — данные изменены

    lea si , Admin_Password
    lea di , Input
    call Compare
    cmp Compare_Result , 1
    jne Wrong

    lea dx , Msg_Admin_Pass
    mov ah , 09h
    int 21h

    jmp Exit


Compare:
    mov Compare_Result , 1

Compare_Loop:
    mov al , [si]
    cmp al , [di]
    jmp Overflove_Part

    InputBuffer  db 10             ; Максимальная длина ввода
    InputLength  db 0              ; Фактическая длина введённого пароля
    Input        db 10 dup (0)

Overflove_Part:

    jne Not_Equal_Password
    test al , al
    je Equal_Password
    inc si
    inc di
    jmp Compare_Loop


Not_Equal_Password:
    mov Compare_Result, 0

Equal_Password:
    ret

True_Password:
    db "Senyalox" , 0

Admin_Password:
    db "ABOBA" , 0


Calculate_Hash_Of_Part_Code:

    mov ax , 0

Calculate_Loop:

    add ax , 1
    inc si
    loop Calculate_Loop

    ret


Exit:

    mov ax , 4C00h
    int 21h


Atbash_decoder:
    lea si , input

Atbash_loop:

    lodsb
    test al , al          ; Если 0 (конец строки) — выходим
    jz End_atbash
    cmp al , 'A'          ; Если меньше 'A' , то не шифруем
    jb Store_char
    cmp al , 'Z'
    jbe Atbash_upper      ; Если буква в верхнем регистре

    cmp al , 'a'
    jb Store_char
    cmp al , 'z'
    jbe Atbash_lower      ; Если буква в нижнем регистре

Store_char:

    stosb                ; Сохраняем без изменений
    jmp Atbash_loop

Atbash_upper:

    mov ah , 'Z'
    sub ah , al           ; Разница между AL и 'Z'
    mov al , 'A'
    add al , ah           ; Делаем замену
    jmp Store_char

Atbash_lower:

    mov ah , 'z'
    sub ah , al
    mov al , 'a'
    add al , ah
    jmp Store_char

End_atbash:

    mov byte ptr [di] , 0

    ret

; Calculate_Hash_Of_Part_Code:
;
;     mov ax, 0
;     lea si, InputBuffer  ; Начало секции .data
;     mov cx, end_data - Password  ; Размер секции .data
;
; Calculate_Loop:
;
;     add ax, [si]  ; Суммируем ASCII-коды всех байтов
;     inc si
;     loop Calculate_Loop
;
;     ret

.data
    obman           db "catty cat" , 0

    True_Hash_sum_1 dw 48h

    Msg_Enter_Pass  db "Enter password: $"
    Msg_Access_OK   db 13 , 10 , "Access granted!$"
    Msg_Access_DEN  db 13 , 10 , "Access denied!$"
    Msg_Blocked     db 13 , 10 , "OH-OH-OH , KAKOI PLOXOI , ZACHEM TU PUTAESCHSI NAS VZLOMAT ." , 13 , 10 , "TU CHITAL BIBLIU , TAM GOVORITSY SHTO OBMANUVAT OCHEN PLOXO , POSIDI PODUMAI TEPER NAD SVOIM POVEDENIEM HI-HI-HI HAAAA" , 13 , 10 , "TEPER TU BYDESCH ZABANEN NA VECHNO PO TVOEMY IP$"
    Msg_Admin_Pass  db 13 , 10 , "Welcome , Admin , you are logged into your account$"

    Compare_Result  db 0

    Hash_Sum_1      dw 0

end_data:

end start
