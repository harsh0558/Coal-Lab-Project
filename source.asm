INCLUDE Irvine32.inc
.data

number_of_turns dword 0
rowsize dword 12
col dword 0
row dword 0
temp dword 0
enter_prompt BYTE "Enter your move (0-8): ",0
enter_invalid BYTE "Invalid move cell already taken, try again.",0
enter_computer_win BYTE "Computer Wins ",0
enter_player_win BYTE "Player Wins ",0
enter_draw BYTE "It's a Draw",0
computer_win dword 0
player_win dword 0
computer_played dword 0
computer_grid byte "Computer's Grid:",0
player_grid byte "Player's Grid:",0
prompt byte "Do you want to play again? (0 for yes | 1 for no ) : ",0
print_X dword "X",0
print_O dword "O",0
seperate byte "---+---+---",0
line byte "| ",0
welcome BYTE "Welcome :)",0
option1 BYTE "1) Human Vs Human.",0
option2 BYTE "2) Human Vs Computer. ",0
options BYTE "Select any one : ",0
invalid BYTE "Invalid input select (0 or 1) ",0




grid sdword 9 dup(-1)      

;------------------------------------

dotMsg   BYTE ".",0       
spaceMsg BYTE " ",0

;------------------------------------
						
msg1 byte "Enter the name of Player 1: ",0
msg2 byte "Enter the name of Player 2: ",0
msg3 byte " wins!",0
msg4 byte " wins!",0
msg5 byte "It's a draw!",0
msg6 byte "'s turn. Enter a number between 0-8: ",0
msg7 byte "Invalid input, please enter a number between 0-8",0
msgTaken byte "Cell already taken, please choose another cell",0
playerTurn dword 0
player1 byte 20 dup(?)
player2 byte 20 dup(?)
player1Count dword 0
player2Count dword 0
HorizontalCount2 dword 0
HorizontalCount3 dword 0
turnsTaken dword 0
currentPlayer dword 0

valEAX dword ?
valEBX dword ?
valECX dword ?
valEDX dword ?
valESI dword ?


winValidation dword 0



.code
main PROC
    mov edx,OFFSET welcome
    call writestring
    call crlf
    GAME:
    
    mov edx,OFFSET option1
    call writestring
    call crlf
    
    mov edx,OFFSET option2
    call writestring
    call crlf
    
    mov edx,OFFSET options
    call writestring
    call readint
    
    cmp eax,1
    je HVH
    cmp eax,2
    jne invalid_choice
    call computervshuman
    jmp continue
    
    HVH:
    call HumanvsHuman
    jmp continue
    invalid_choice:
    mov edx,OFFSET invalid
    call writestring
    call crlf
    jmp GAME

    continue:
        call crlf
        mov edx,OFFSET prompt
        call WriteString
        call readint
        cmp eax,0
        jne end_full_game
        call Game
        end_full_game:
        exit
main ENDP







;---------------- Main Game Loop ----------------

computervshuman proc 

    call Randomize
    call reset_grid 
    ; zero out counters and flags
    mov number_of_turns, 0
    mov computer_win, 0
    mov player_win, 0
    mov computer_played, 0


mov number_of_turns, 0          ; initialize turn counter

call turn_1                     ; computer makes first random move
call print_grid
inc number_of_turns


main_game_loop:

    ; ----- Human Turn -----
    call human_move
    mov edx, OFFSET player_grid
    call WriteString
    call crlf
    call print_grid
    call check_player_win
    cmp player_win, 1
    je player_wins_label

    inc number_of_turns
    cmp number_of_turns, 9
    je draw_label                ; if 9 moves, game draw

    ; ----- Computer Turn -----
    mov eax, 0                   ; clear return value
    call computer_win_move       ; if move made, check win
    call check_computer_win
    cmp computer_win, 1
    je computer_wins_label

    ; ----- Block human or calculated move -----
    call block_human_win         ; returns 1 if move placed
    cmp computer_played,1
    jne no_block                  ; if no move, go to calculated probability

    jmp after_computer_move       ; already moved

no_block:
    call calculated_probability  ; returns 1 if move placed
    cmp computer_played,1
    je after_computer_move
    call turn_1
    jmp after_computer_move

after_computer_move:
    call check_computer_win
    cmp computer_win, 1
    je computer_wins_label
    mov eax,0
    mov computer_played,eax      ; reset flag
    mov edx, OFFSET computer_grid
    call WriteString
    call crlf
    call print_grid
    inc number_of_turns
    cmp number_of_turns, 9
    je draw_label
    jmp main_game_loop

; ---------- Labels ----------
player_wins_label:
    mov edx, OFFSET enter_player_win
    call WriteString
    jmp end_game

computer_wins_label:
    mov edx,OFFSET computer_grid
    call WriteString
    call crlf
    call print_grid
    call crlf
    mov edx, OFFSET enter_computer_win
    call WriteString
    jmp end_game

draw_label:
    mov edx, OFFSET enter_draw
    call WriteString

end_game:
    mov eax,0
    call crlf
    ret
    
computervshuman endp

;---------------------grid reset-----------------------
reset_grid PROC
    mov esi, OFFSET grid     ; point to start of grid array
    mov ecx, 9               ; 9 cells total
    mov eax, -1              ; value for empty cell

reset_loop:
    mov [esi], eax           ; store -1 at current cell
    add esi, TYPE grid       ; move to next cell (4 bytes for DWORD)
    loop reset_loop           ; repeat 9 times
    ret
reset_grid ENDP

;---------------------------------------------------------




;------------generating computer's first move-------------

turn_1 PROC

; generate random col (0–2)
mov eax, 3
call RandomRange
mov col, eax

; generate random row (0–2)
mov eax, 3
call RandomRange
mov row, eax

;----------- compute offset = row*12 + col*4-------------

mov eax, rowsize        ; eax = 12
imul eax, row           ; eax = row*12
mov ebx, col
imul ebx, TYPE grid     ; ebx = col*4
add eax, ebx            ; eax = row*12 + col*4
mov esi, eax            ; esi = byte offset
mov DWORD PTR [grid + esi], 0           ; place 0 in that cell

ret

turn_1 ENDP
;-------------------------------------------------------


;------------ generated ------------------

















; ------------ print grid --------------

print_grid proc
    call crlf
 
mov ecx, 0               ; index 0..8
    mov esi, OFFSET grid     ; start of grid
	mov edx,OFFSET spaceMsg
	call writestring
print_loop:
    mov eax, [esi]           ; get cell value
    cmp eax, -1
    jne print_value

    ; print dot if empty
    mov edx, OFFSET dotMsg
    call WriteString
    jmp after_value

print_value:																					;	
																								; O | X | O 
																								;---+---+---
																								; O | X | O 
																								;---+---+---
																								; O | X | O 				
																								;---+---+---
    cmp eax,1
	jne O_print
	mov edx,OFFSET print_X
	call writestring
	jmp after_value
	O_print:
	mov edx,OFFSET print_O
	call writestring


after_value:
    mov edx, OFFSET spaceMsg
    call WriteString

    inc ecx                   ; next cell index
    add esi, TYPE grid        ; move to next cell

    mov eax, ecx
    mov ebx, 3
	mov edx,0
    div ebx
    cmp edx, 0
    jne skip_line_add
	call crlf
	mov edx,OFFSET seperate
	call writestring
    call crlf
	mov edx,OFFSET spaceMsg
	call writestring
	jmp skip_crlf

skip_line_add:
	mov edx,OFFSET line
	call writestring

skip_crlf:
    cmp ecx, 9
    jl print_loop



call crlf
    ret

print_grid ENDP
;---------------------------------------








;------------ human's turn ------------------

human_move PROC

human_input_loop:
    mov edx, OFFSET enter_prompt
    call WriteString
    call ReadInt          ; input in EAX

    ; map 0..8 -> row,col
    cmp eax, 0
    jl human_move_invalid
    cmp eax, 8
    jg human_move_invalid

    mov ebx, 3
    xor edx, edx
    div ebx               ; quotient in EAX = row, remainder in EDX = col

    mov row, eax
    mov col, edx

    ; compute offset = row*12 + col*4
    mov eax, rowsize      ; 12
    imul eax, row         ; row*12
    mov ebx, col
    imul ebx, TYPE grid   ; col*4
    add eax, ebx
    mov esi, eax

    ; check cell
    mov eax, [grid + esi]
    cmp eax, -1
    jne human_move_invalid  ; occupied -> retry

    mov DWORD PTR [grid + esi], 1   ; place player '1'
    mov edx, OFFSET spaceMsg
    call WriteString
    jmp human_move_done

human_move_invalid:
    mov edx, OFFSET enter_invalid
    call WriteString
    jmp human_input_loop

human_move_done:
    ret
human_move ENDP

;-----------human's turn end------------------



;--------------------check computer win--------------------
check_computer_win PROC
                                                 
mov eax,0
mov computer_win,eax
mov ecx, 0
win_move:
    mov esi, OFFSET grid
    mov ebx, 0
    mov edx,0

check_possibilities_of_1:              ; Row checks
    cmp ecx, 0
    jne skip_row0
    call possibility1
    cmp computer_win,1
    je ccw_done
skip_row0:
    
    cmp ecx, 3
    jne skip_row3
    call possibility1
    cmp computer_win,1
    je ccw_done
skip_row3:

    cmp ecx, 6
    jne skip_row6
    call possibility1
    cmp computer_win,1
    je ccw_done
skip_row6:


check_possibilities_of_2:              ; Column checks
    cmp ecx, 0
    jne skip_col0
    call possibility2
    cmp computer_win,1
    je ccw_done
skip_col0:

    cmp ecx, 1
    jne skip_col1
    call possibility2
    cmp computer_win,1
    je ccw_done
skip_col1:

    cmp ecx, 2
    jne skip_col2
    call possibility2
    cmp computer_win,1
    je ccw_done
skip_col2:


check_possibilities_of_3:              ; Diagonal 1
    cmp ecx, 0
    jne skip_diag1
    call possibility3
    cmp computer_win,1
    je ccw_done
skip_diag1:


check_possibilities_of_4:              ; Diagonal 2
    cmp ecx, 2
    jne skip_diag2
    call possibility4
    cmp computer_win,1
    je ccw_done
skip_diag2:

    jmp end_block


possibility1:                         ; check row (ecx = 0,3,6)
    mov row, ecx
    mov edx, 0                        ; reset sum

    mov ebx, ecx                      ; end index = start index + 3
    add ebx, 3

row_loop:
    mov eax,row          ; load grid[row]
    imul eax, 4
    mov eax, [esi + eax]                   ; if empty, skip adding
    cmp eax,0
    je skip_return_possibility1                               ;
    ret
    skip_return_possibility1:
    inc row
    cmp row, ebx
    jl row_loop                       ; loop until row end index

    mov eax,1
    mov computer_win,eax
    ret

possibility2:                         ; col check (ecx = 0,1,2)
    mov col, ecx
    mov edx, 0

    mov ebx, ecx
    add ebx, 9                        ; col end index (ecx+6 effectively, step 3)

col_loop:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, 0
    je skip_return_possibility2                               ; if sum != 2, return to block 
    ret
    skip_return_possibility2:
    
    add col, 3                        ; move down one row
    cmp col, ebx
    jl col_loop

    mov eax,1
    mov computer_win,eax
    ret

possibility3:
    mov row, 0
    mov edx, 0

diag1_loop:
    mov eax,row
    mov eax, [esi + eax*4]
    cmp eax, 0
    je skip_return_possibility3                               ; if sum != 2, return to block 
    ret
    skip_return_possibility3:
    add row, 4                        ; step through 0,4,8
    cmp row, 12
    jl diag1_loop

    mov eax,1
    mov computer_win,eax
    ret

possibility4:
    mov row, 2
    mov edx, 0

diag2_loop:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, 0
    je skip_return_possibility4                               ; if sum != 2, return to block 
    ret
    skip_return_possibility4:
    add row, 2                        ; step 2 ? goes 2,4,6
    cmp row, 6
    jle diag2_loop                    

    mov eax,1
    mov computer_win,eax
    ret

end_block:
    inc ecx
    cmp ecx, 9
    jl win_move                                                 
    mov eax,0
    mov computer_win,eax

ccw_done:
ret
check_computer_win ENDP

;----------------check computer win end----------------





;--------------------check player win--------------------
check_player_win PROC   

mov eax,0
mov player_win,eax
mov ecx, 0
win_move:
    mov esi, OFFSET grid
    mov ebx, 0
    mov edx,0

check_possibilities_of_1:              ; Row checks
    cmp ecx, 0
    jne skip_row0
    call possibility1
skip_row0:

    cmp ecx, 3
    jne skip_row3
    call possibility1
skip_row3:

    cmp ecx, 6
    jne skip_row6
    call possibility1
skip_row6:


check_possibilities_of_2:              ; Column checks
    cmp ecx, 0
    jne skip_col0
    call possibility2
skip_col0:

    cmp ecx, 1
    jne skip_col1
    call possibility2
skip_col1:

    cmp ecx, 2
    jne skip_col2
    call possibility2
skip_col2:


check_possibilities_of_3:              ; Diagonal 1
    cmp ecx, 0
    jne skip_diag1
    call possibility3
skip_diag1:


check_possibilities_of_4:              ; Diagonal 2
    cmp ecx, 2
    jne skip_diag2
    call possibility4
skip_diag2:

    jmp end_block


possibility1:                         ; check row (ecx = 0,3,6)
    mov row, ecx
    mov edx, 0                        ; reset sum

    mov ebx, ecx                      ; end index = start index + 3
    add ebx, 3

row_loop:
    mov eax,row          ; load grid[row]
    imul eax, 4
    mov eax, [esi + eax]                   ; if empty, skip adding
    cmp eax,1
    je skip_return_possibility1                               ;
    ret
    skip_return_possibility1:
    inc row
    cmp row, ebx
    jl row_loop                       ; loop until row end index

    mov eax,1
    mov player_win,eax
    ret

possibility2:                         ; col check (ecx = 0,1,2)
    mov col, ecx
    mov edx, 0

    mov ebx, ecx
    add ebx, 9                        ; col end index (ecx+6 effectively, step 3)

col_loop:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, 1
    je skip_return_possibility2                               ; if sum != 2, return to block 
    ret
    skip_return_possibility2:
    
    add col, 3                        ; move down one row
    cmp col, ebx
    jl col_loop

    mov eax,1
    mov player_win,eax
    ret

possibility3:
    mov row, 0
    mov edx, 0

diag1_loop:
    mov eax,row
    mov eax, [esi + eax*4]
    cmp eax, 1
    je skip_return_possibility3                               ; if sum != 2, return to block 
    ret
    skip_return_possibility3:
    add row, 4                        ; step through 0,4,8
    cmp row, 12
    jl diag1_loop

    mov eax,1
    mov player_win,eax
    ret

possibility4:
    mov row, 2
    mov edx, 0

diag2_loop:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, 1
    je skip_return_possibility4                               ; if sum != 2, return to block 
    ret
    skip_return_possibility4:
    add row, 2                        ; step 2 ? goes 2,4,6
    cmp row, 6
    jle diag2_loop                    

    mov eax,1
    mov player_win,eax
    ret

end_block:
    inc ecx
    cmp ecx, 9
    jl win_move        

ret
check_player_win ENDP

;----------------check player win end----------------







; ------------possibility --------------


;mov esi, OFFSET grid
;mov ebx, 0
;mov ecx, 9
;possibility_right_next :               ; loop 9 cells
;            mov eax,[esi + ebx]     
;            cmp eax,0               
;            jne end_loop    ; if not 0, skip
;            mov temp,ebx
;            add temp,4
;            mov eax,temp
;            cmp eax,12      ; if eax=12, skip
;            je turn1
;            mov eax, [esi + ebx + 4]
;            cmp eax,-1
;            jne end_loop        ; if not -1, skip
;            mov dword ptr [esi+ebx+4],0     ; place 0 in that cell
;            jmp  print_loop
;            end_loop:
;            add ebx,4
;            loop possibility
;            ret
;;---------------------------------------
        





;-----------------computer calculated move------------------



calculated_probability PROC

    mov ecx,0
    mov esi, OFFSET grid
    
    possibility:
            mov eax,ecx
            imul eax,4
            mov eax,[esi + eax]
            cmp eax,0
            jne next_cell

            mov eax, ecx
            mov ebx, 3
            xor edx, edx
            div ebx       ; eax = row, edx = col
            mov row, eax
            mov col, edx

            cmp col,0
            jne skip_add_to_right
                mov eax, col
                mov temp, eax 
                call add_to_right
                cmp eax,1
                je cal_success
                    

            skip_add_to_right:
            cmp col,2
            jne skip_add_to_left
                mov eax, col
                mov temp, eax 
                call add_to_left 
                cmp eax,1
                je cal_success

            skip_add_to_left:
            cmp row,0
            jne skip_add_to_bottom
                mov eax, row
                mov temp, eax
                call add_to_bottom
                cmp eax,1
                je cal_success

            skip_add_to_bottom:
            cmp row,2
            jne skip_add_to_top
                mov eax, row
                mov temp, eax
                call add_to_top
                cmp eax,1
                je cal_success

            skip_add_to_top:
            cmp col,0
            jne skip_add_to_diagonal1
            cmp row,0
            jne skip_add_to_diagonal1
                mov eax, row
                mov temp, eax
                call add_to_diagonal1
                cmp eax,1
                je cal_success
            
            skip_add_to_diagonal1:
            cmp row,0
            jne next_cell
            cmp col,2
            jne skip_add_to_diagonal2
                mov eax, row
                mov temp,eax 
                call add_to_diagonal2
                cmp eax,1
                je cal_success

            skip_add_to_diagonal2:
            jmp next_cell

            cal_success:
                    ret
add_to_right:
        mov eax,temp
   right_loop:
        inc eax
        cmp eax,2
        ja right_done


        mov ebx,row
        imul ebx,3
        add ebx,eax
        imul ebx,4
        mov edx,[esi + ebx]         ; check right neighbor
        cmp edx,-1
        jne right_loop

        mov dword ptr [esi + ebx],0
        mov eax,1
        mov computer_played,eax
        ret

right_done:
        mov eax,0
        ret


add_to_left:
    mov eax, temp
left_loop:
    dec eax
    jl left_done
    
    
    mov ebx, row
    imul ebx, 3
    add ebx, eax
    imul ebx, 4
    mov edx, [esi + ebx]
    cmp edx, -1
    jne left_loop


    mov dword ptr [esi + ebx], 0
    mov eax,1
    mov computer_played,eax
    ret


left_done:
mov eax,0
ret


add_to_bottom:
    mov eax, temp
bottom_loop:
    inc eax
    cmp eax, 2
    ja bottom_done
    
    
    mov ebx, eax
    imul ebx, 3
    add ebx, col
    imul ebx, 4
    mov edx, [esi + ebx]
    cmp edx, -1
    jne bottom_loop
    
    
    mov dword ptr [esi + ebx], 0
    mov eax,1
    mov computer_played,eax
    ret


bottom_done:
mov eax,0
ret

add_to_top:
    mov eax, temp
top_loop:
    dec eax
    jl top_done
            
    
    mov ebx, eax
    imul ebx, 3
    add ebx, col
    imul ebx, 4
    mov edx, [esi + ebx]
    cmp edx, -1
    jne top_loop
    
    
    mov dword ptr [esi + ebx], 0
    mov eax,1
    mov computer_played,eax
    ret


top_done:
    mov eax,0
    ret


add_to_diagonal1:
    mov eax, temp
d1_loop:
    inc eax
    cmp eax, 2
    ja d1_done
    
    
    ; target (eax, eax)
    mov ebx, eax
    imul ebx, 3
    add ebx, eax
    imul ebx, 4
    mov edx, [esi + ebx]
    cmp edx, -1
    jne d1_loop
    
    
    mov dword ptr [esi + ebx], 0
    mov eax,1
    mov computer_played,eax
    ret


d1_done:
    mov eax,0
    ret


add_to_diagonal2:
    mov eax, temp
d2_loop:
    inc eax
    cmp eax, 2
    ja d2_done
    
    
    mov ebx, 2
    sub ebx, eax ; target_col = 2 - eax
    mov edx, eax
    imul edx, 3
    add edx, ebx
    imul edx, 4
    mov ecx, [esi + edx]
    cmp ecx, -1
    jne d2_loop
    
    
    mov dword ptr [esi + edx], 0
    mov eax,1
    mov computer_played,eax
    ret


d2_done:
    mov eax,0
    ret

next_cell:
inc ecx
cmp ecx,9
jl possibility
mov eax,0
mov computer_played,eax
ret


calculated_probability ENDP


;--------------computer's calculated move end------------------






; ------------block human's win--------------

block_human_win PROC

mov ecx, 0
block:
    mov esi, OFFSET grid    
    mov ebx, 0
    mov edx,0

check_possibilities_of_1:              ; Row checks
    cmp ecx, 0
    mov edx,0
    jne skip_row0
    call possibility1
    cmp computer_played,1
    je end_block_success

skip_row0:
    mov edx,0
    cmp ecx, 3
    jne skip_row3
    call possibility1
    cmp computer_played,1
    je end_block_success

skip_row3:

    mov edx,0
    cmp ecx, 6
    jne skip_row6
    call possibility1
    cmp computer_played,1
    je end_block_success

skip_row6:


check_possibilities_of_2:              ; Column checks
    mov edx,0
    cmp ecx, 0
    jne skip_col0
    call possibility2
    cmp computer_played,1
    je end_block_success

skip_col0:

    mov edx,0
    cmp ecx, 1
    jne skip_col1
    call possibility2
    cmp computer_played,1
    je end_block_success

skip_col1:

    mov edx,0
    cmp ecx, 2
    jne skip_col2
    call possibility2
    cmp computer_played,1
    je end_block_success

skip_col2:


check_possibilities_of_3:              ; Diagonal 1
    mov edx,0
    cmp ecx, 0
    jne skip_diag1
    call possibility3
    cmp computer_played,1
    je end_block_success

skip_diag1:


check_possibilities_of_4:              ; Diagonal 2
    mov edx,0
    cmp ecx, 2
    jne skip_diag2
    call possibility4
    cmp computer_played,1
    je end_block_success

skip_diag2:

    jmp end_block

end_block_success:
    ret

possibility1:                         ; check row (ecx = 0,3,6)
    mov row, ecx
    mov edx, 0                        ; reset sum

    mov ebx, ecx                      ; end index = start index + 3
    add ebx, 3

row_loop:
    mov eax,row          ; load grid[row]
    imul eax, 4
    mov eax, [esi + eax]
    cmp eax, -1
    je skip_add_row                   ; if empty, skip adding
    add edx, eax
skip_add_row:                         ; skip adding if empty
    inc row
    cmp row, ebx
    jl row_loop                       ; loop until row end index

    cmp edx, 2
    je skip_return_possibility                               ; if sum != 2, return to block 
    ret
    skip_return_possibility:

    mov row, ecx                      ; reset row to start index
check_empty_row:
    mov eax, row
    imul eax, 4
    mov eax, [esi + eax]
    cmp eax, -1
    je place_zero_row                 ; found empty
    inc row
    cmp row, ebx
    jl check_empty_row
    jmp end_block

place_zero_row:                       ; found empty cell
    mov eax, row
    imul eax, 4
    mov dword ptr [esi + eax], 0    ; place zero in empty cell
    mov eax,1
    mov computer_played,eax
    ret

possibility2:                         ; col check (ecx = 0,1,2)
    mov col, ecx
    mov edx, 0

    mov ebx, ecx
    add ebx, 9                        ; col end index (ecx+6 effectively, step 3)

col_loop:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, -1
    je skip_add_col
    add edx, eax
skip_add_col:
    add col, 3                        ; move down one row
    cmp col, ebx
    jl col_loop

    cmp edx, 2
    je skip_return_possibility2                               ; if sum != 2, return to block 
    ret
    skip_return_possibility2:

    mov col, ecx
check_empty_col:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_col
    add col, 3
    cmp col, ebx
    jl check_empty_col
    jmp end_block

place_zero_col:
    mov eax, col
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

possibility3:
    mov row, 0
    mov edx, 0

diag1_loop:
    mov eax,row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je skip_add_diag1
    add edx, eax
skip_add_diag1:
    add row, 4                        ; step through 0,4,8
    cmp row, 12
    jl diag1_loop

    cmp edx, 2
    je skip_return_possibility3                               ; if sum != 2, return to block 
    ret
    skip_return_possibility3:

    mov row, 0
check_empty_diag1:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_diag1
    add row, 4
    cmp row, 12
    jl check_empty_diag1
    jmp end_block

place_zero_diag1:
    mov eax, row
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

possibility4:
    mov row, 2
    mov edx, 0

diag2_loop:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je skip_add_diag2
    add edx, eax
skip_add_diag2:
    add row, 2                        ; step 2 ? goes 2,4,6
    cmp row, 6
    jle diag2_loop                    

    cmp edx, 2
    je skip_return_possibility4                               ; if sum != 2, return to block 
    ret
    skip_return_possibility4:

    mov row, 2
check_empty_diag2:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_diag2
    add row, 2
    cmp row, 6
    jle check_empty_diag2
    jmp end_block

place_zero_diag2:
    mov eax, row
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

end_block:
    inc ecx
    cmp ecx, 9
    jl block
    mov eax,0
    mov computer_played,eax
    ret 

block_human_win ENDP


;--------------block human's win end------------------





;-------------computer's win move--------------

computer_win_move PROC

mov ecx, 0
win_move:
    mov esi, OFFSET grid
    mov ebx, 0
    mov edx,0

check_possibilities_of_1:              ; Row checks
    cmp ecx, 0
    jne skip_row0
    call possibility1
    cmp computer_played,1
    je end_win_success

skip_row0:

    cmp ecx, 3
    jne skip_row3
    call possibility1
    cmp computer_played,1
    je end_win_success

skip_row3:

    cmp ecx, 6
    jne skip_row6
    call possibility1
    cmp computer_played,1
    je end_win_success

skip_row6:


check_possibilities_of_2:              ; Column checks
    cmp ecx, 0
    jne skip_col0
    call possibility2
    cmp computer_played,1
    je end_win_success

skip_col0:                                

    cmp ecx, 1
    jne skip_col1
    call possibility2
    cmp computer_played,1
    je end_win_success

skip_col1:

    cmp ecx, 2
    jne skip_col2
    call possibility2
    cmp computer_played,1
    je end_win_success

skip_col2:


check_possibilities_of_3:              ; Diagonal 1
    cmp ecx, 0
    jne skip_diag1
    call possibility3
    cmp computer_played,1
    je end_win_success

skip_diag1:


check_possibilities_of_4:              ; Diagonal 2
    cmp ecx, 2
    jne skip_diag2
    call possibility4
    cmp computer_played,1
    je end_win_success

skip_diag2:

    jmp end_block

end_win_success:
    ret

possibility1:                         ; check row (ecx = 0,3,6)
    mov row, ecx
    mov edx, 0                        ; reset sum

    mov ebx, ecx                      ; end index = start index + 3
    add ebx, 3

row_loop:
    mov eax,row          ; load grid[row]
    imul eax, 4
    mov eax, [esi + eax]                   ; if empty, skip adding
    cmp eax,1
    je rat
    add edx, eax
    inc row
    cmp row, ebx
    jl row_loop                       ; loop until row end index

    cmp edx,-1
    je skip_return_possibility1                               ; if sum != 2, return to block 
    rat:
    ret
    skip_return_possibility1:

    mov row, ecx                      ; reset row to start index
check_empty_row:
    mov eax, row
    imul eax, 4
    mov eax, [esi + eax]
    cmp eax, -1
    je place_zero_row                 ; found empty
    inc row
    cmp row, ebx
    jl check_empty_row
    jmp end_block

place_zero_row:                       ; found empty cell
    mov eax, row
    imul eax, 4
    mov dword ptr [esi + eax], 0    ; place zero in empty cell
    mov eax,1
    mov computer_played,eax
    ret

possibility2:                         ; col check (ecx = 0,1,2)
    mov col, ecx
    mov edx, 0

    mov ebx, ecx
    add ebx, 9                        ; col end index (ecx+6 effectively, step 3)

col_loop:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, 1
    je rat_col
    add edx, eax
    add col, 3                        ; move down one row
    cmp col, ebx
    jl col_loop

    cmp edx, -1
    je skip_return_possibility2                               ; if sum != 2, return to block 
    rat_col:
    ret
    skip_return_possibility2:

    mov col, ecx
check_empty_col:
    mov eax, col
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_col
    add col, 3
    cmp col, ebx
    jl check_empty_col
    jmp end_block

place_zero_col:
    mov eax, col
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

possibility3:
    mov row, 0
    mov edx, 0

diag1_loop:
    mov eax,row
    mov eax, [esi + eax*4]
    cmp eax, 1
    je rat_d1
    add edx, eax
    add row, 4                        ; step through 0,4,8
    cmp row, 12
    jl diag1_loop

    cmp edx, -1
    je skip_return_possibility3                               ; if sum != 2, return to block 
    rat_d1:
    ret
    skip_return_possibility3:

    mov row, 0
check_empty_diag1:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_diag1
    add row, 4
    cmp row, 12
    jl check_empty_diag1
    jmp end_block

place_zero_diag1:
    mov eax, row
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

possibility4:
    mov row, 2
    mov edx, 0

diag2_loop:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, 1
    je rat_d2
    add edx, eax
    add row, 2                        ; step 2 ? goes 2,4,6
    cmp row, 6
    jle diag2_loop                    

    cmp edx, -1
    je skip_return_possibility4                               ; if sum != 2, return to block 
    rat_d2:
    ret
    skip_return_possibility4:

    mov row, 2
check_empty_diag2:
    mov eax, row
    mov eax, [esi + eax*4]
    cmp eax, -1
    je place_zero_diag2
    add row, 2
    cmp row, 6
    jle check_empty_diag2
    jmp end_block

place_zero_diag2:
    mov eax, row
    mov dword ptr [esi + eax*4], 0
    mov eax,1
    mov computer_played,eax
    ret

end_block:
    inc ecx
    cmp ecx, 9
    jl win_move                                                 

ret
computer_win_move ENDP

;---------------computer's win move end------------------







;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------


HumanVsHuman PROC
    call initalise_grid

    mov playerTurn , 0
    mov player1Count , 0
    mov player2Count , 0
    mov HorizontalCount2 , 0
    mov HorizontalCount3 , 0
    mov turnsTaken , 0
    mov currentPlayer , 0
    mov winValidation,0
   
	mov edx, OFFSET msg1
	call WriteString

	mov ecx,20
	mov edx, offset player1
	call ReadString

	mov edx, OFFSET msg2
	call WriteString
	
	mov ecx,20
	mov edx, offset player2
	call ReadString

    call print_grid

    start:
	mov ebx,0
    

	game:
		cmp ebx,0
		je player1_turn
		jmp player2_turn
		jump_back_into_game:
		call readInt
		cmp eax,0
		jl invalid_input
		cmp eax,8
		jg invalid_input
		mov ecx,eax
		jmp update_grid
		continue_game:
		mov eax, turnsTaken
		inc eax
		mov turnsTaken, eax
		mov valEAX,eax
		mov valEBX,ebx
		mov valECX,ecx
		mov valEDX,edx
		mov valESI,esi
		call validation
        call print_grid
		mov eax,valEAX
		mov ebx,valEBX
		mov ecx,valECX
		mov edx,valEDX
		mov esi,valESI
		cmp winValidation,1
		je end_of_game
		cmp eax,9
		je end_of_game
		jmp game

	update_grid:
		mov esi, OFFSET grid     
		mov eax, TYPE grid       
		imul ecx, eax            
		add esi, ecx             

		mov eax, [esi]           
		cmp eax, -1              
		jne cell_taken           

		mov eax, currentPlayer             
		mov [esi], eax   
        jmp continue_game

	cell_taken:
		mov edx, OFFSET msgTaken
		call WriteString
		call Crlf
		mov eax, playerTurn
		cmp eax,0
		je rectify_player2_turn
		jmp rectify_player1_turn
		
	invalid_input:
		mov edx, OFFSET msg7
		call WriteString
		call crlf
		mov eax, playerTurn
		cmp eax,0
		je rectify_player2_turn
		jmp rectify_player1_turn

	rectify_player2_turn:
		mov ebx,1
		jmp game

	rectify_player1_turn:
		mov ebx,0
		jmp game

	player1_turn:
		mov currentPlayer,0 
		mov edx, OFFSET player1
		call WriteString
		mov edx, OFFSET msg6
		call WriteString
		mov ebx,1
		mov playerTurn,1
		jmp jump_back_into_game
		

	player2_turn:
		mov currentPlayer,1
		mov edx, OFFSET player2
		call WriteString
		mov edx, OFFSET msg6
		call WriteString
		mov ebx,0
		mov playerTurn,0
		jmp jump_back_into_game

	end_of_game:
		cmp winValidation,0
		je declare_draw
		jmp end_game

	declare_draw:
		mov edx, offset msg5
		call writestring
        call crlf
	end_game:

	ret
HumanVsHuman ENDP


Validation PROC

;validating for player 1

	; validating rows for player 1
	
	mov player1Count,0
	mov esi,0
    mov eax, 0          ; row 
    mov ebx, 0          ; col

	traverse_row: 
		mov eax, esi       ; Reset eax to current row
		imul eax, 3       
		add eax, ebx        
		mov edx, [grid + eax * TYPE grid] 

		cmp edx,0
		je increment_player1_count
		jump_back:
		inc ebx
		cmp ebx,3
		je break_player1_loop
		jmp traverse_row

    increment_player1_count:
		inc player1Count
		jmp jump_back

	break_player1_loop:
		cmp player1Count,3
		je print_winner_player1
		inc esi
		cmp esi,3
		je end_row_validation
		mov ebx,0
		mov player1Count,0
		jmp traverse_row

	print_winner_player1:
		mov edx, OFFSET player1
		call WriteString
		mov edx, OFFSET msg3
		call WriteString
        call crlf
		mov winValidation,1
		jmp end_of_validation
	end_row_validation:

	; validating cols for player 1
	mov player1Count,0
	mov esi,0
    mov eax, 0          ; row 
    mov ebx, 0          ; col

	traverse_col: 
		mov eax, esi       ; Reset eax to current row
		imul eax, 3       
		add eax, ebx        
		mov edx, [grid + eax * TYPE grid] 

		cmp edx,0
		je increment_player1_count_col
		jump_back_col:
		inc esi
		cmp esi,3
		je break_player1_loop_col
		jmp traverse_col

    increment_player1_count_col:
		inc player1Count
		jmp jump_back_col

	break_player1_loop_col:
		cmp player1Count,3
		je print_winner_player1_col
		inc ebx
		cmp ebx,3
		je end_col_validation
		mov esi,0
		mov player1Count,0
		jmp traverse_col

	print_winner_player1_col:
		mov edx, OFFSET player1
		call WriteString
		mov edx, OFFSET msg3
		call WriteString
		mov winValidation,1
		jmp end_of_validation
	end_col_validation:

	;validating diagonals for player 1
	
	mov player1Count,0
	mov eax,0 ;row
	mov ebx,0 ;col
	mov esi,0
	
	traverse_diagonal1:
		mov eax, esi       ; Reset eax to current row
		imul eax, 3       
		add eax, ebx        
		mov edx, [grid + eax * TYPE grid]
		cmp edx,0
		je increment_player1_count_diagonal1
		jump_back_diagonal1:
		inc esi
		inc ebx
		cmp esi,3
		je break_player1_loop_diagonal1
		jmp traverse_diagonal1

	increment_player1_count_diagonal1:
		inc player1Count
		jmp jump_back_diagonal1

	break_player1_loop_diagonal1:
		cmp player1Count,3
		je print_winner_player1_diagonal1
		jmp end_diagonal1_validation

	print_winner_player1_diagonal1:
		mov edx, OFFSET player1
		call WriteString
		mov edx, OFFSET msg3
		call WriteString
		mov winValidation,1
		jmp end_of_validation
	end_diagonal1_validation:

	;validating diagonal 2

	mov player1Count,0
	mov eax,0 ;row
	mov ebx,2 ;col
	mov esi,0
	
	traverse_diagonal2:
		mov eax, esi       ; Reset eax to current row
		imul eax, 3       
		add eax, ebx        
		mov edx, [grid + eax * TYPE grid]
		cmp edx,0
		je increment_player1_count_diagonal2
		jump_back_diagonal2:
		inc esi
		dec ebx
		cmp esi,3
		je break_player1_loop_diagonal2
		jmp traverse_diagonal2

	increment_player1_count_diagonal2:
		inc player1Count
		jmp jump_back_diagonal2

	break_player1_loop_diagonal2:
		cmp player1Count,3
		je print_winner_player1_diagonal2
		jmp end_diagonal2_validation

	print_winner_player1_diagonal2:
		mov edx, OFFSET player1
		call WriteString
		mov edx, OFFSET msg3
		call WriteString
		mov winValidation,1
		jmp end_of_validation
	end_diagonal2_validation:

;validating for player 2

	; validating rows for player 2
	
	mov player2Count,0
	mov esi,0
    mov eax, 0          ; row 
    mov ebx, 0          ; col

	traverse_row_player2: 
		mov eax, esi       ; Reset eax to current row
		imul eax, 3       
		add eax, ebx        
		mov edx, [grid + eax * TYPE grid] 

		cmp edx,1
		je increment_player2_count
		jump_back_player2:
		inc ebx
		cmp ebx,3
		je break_player2_loop
		jmp traverse_row_player2

    increment_player2_count:
		inc player2Count
		jmp jump_back_player2

	break_player2_loop:
		cmp player2Count,3
		je print_winner_player2
		inc esi
		cmp esi,3
		je end_row_validation_player2
		mov ebx,0
		mov player2Count,0
		jmp traverse_row_player2

	print_winner_player2:
		mov eax, player2Count
		call WriteDec
		call Crlf
		mov edx, OFFSET player2
		call WriteString
		mov edx, OFFSET msg4
		call WriteString
		mov winValidation,1
		jmp end_of_validation
	end_row_validation_player2:

	; validating cols for player 2
	mov player2Count,0
	mov esi,0
    mov eax, 0          ; row 
    mov ebx, 0          ; col

	traverse_col_player2: 
		mov eax, esi       ; Reset eax to current row
		imul eax, 3       
		add eax, ebx        
		mov edx, [grid + eax * TYPE grid] 

		cmp edx,1
		je increment_player2_count_col
		jump_back_col_player2:
		inc esi
		cmp esi,3
		je break_player2_loop_col
		jmp traverse_col_player2

    increment_player2_count_col:
		inc player2Count
		jmp jump_back_col_player2

	break_player2_loop_col:
		cmp player2Count,3
		je print_winner_player2_col
		inc ebx
		cmp ebx,3
		je end_col_validation_player2
		mov esi,0
		mov player2Count,0
		jmp traverse_col_player2

	print_winner_player2_col:
		mov edx, OFFSET player2
		call WriteString
		mov edx, OFFSET msg4
		call WriteString
		mov winValidation,1
		jmp end_of_validation
	end_col_validation_player2:

	;validating diagonals for player 2
	
	mov player2Count,0
	mov eax,0 ;row
	mov ebx,0 ;col
	mov esi,0
	
	traverse_diagonal1_player2:
		mov eax, esi       ; Reset eax to current row
		imul eax, 3       
		add eax, ebx        
		mov edx, [grid + eax * TYPE grid]
		cmp edx,1
		je increment_player2_count_diagonal1
		jump_back_diagonal1_player2:
		inc esi
		inc ebx
		cmp esi,3
		je break_player2_loop_diagonal1
		jmp traverse_diagonal1_player2

	increment_player2_count_diagonal1:
		inc player2Count
		jmp jump_back_diagonal1_player2

	break_player2_loop_diagonal1:
		cmp player2Count,3
		je print_winner_player2_diagonal1
		jmp end_diagonal1_validation_player2

	print_winner_player2_diagonal1:
		mov edx, OFFSET player2
		call WriteString
		mov edx, OFFSET msg4
		call WriteString
		mov winValidation,1
		jmp end_of_validation
	end_diagonal1_validation_player2:

	;validating diagonal 2

	mov player2Count,0
	mov eax,0 ;row
	mov ebx,2 ;col
	mov esi,0
	
	traverse_diagonal2_player2:
		mov eax, esi       ; Reset eax to current row
		imul eax, 3       
		add eax, ebx        
		mov edx, [grid + eax * TYPE grid]
		cmp edx,1
		je increment_player2_count_diagonal2
		jump_back_diagonal2_player2:
		inc esi
		dec ebx
		cmp esi,3
		je break_player2_loop_diagonal2
		jmp traverse_diagonal2_player2

	increment_player2_count_diagonal2:
		inc player2Count
		jmp jump_back_diagonal2_player2

	break_player2_loop_diagonal2:
		cmp player2Count,3
		je print_winner_player2_diagonal2
		jmp end_diagonal2_validation_player2

	print_winner_player2_diagonal2:
		mov edx, OFFSET player2
		call WriteString
		mov edx, OFFSET msg4
		call WriteString
        call crlf
		mov winValidation,1
		jmp end_of_validation
	end_diagonal2_validation_player2:

	end_of_validation:

    ret
Validation ENDP

initalise_grid PROC
    mov ecx,9
    mov esi,0
    l1:
    mov grid[esi],-1
    add esi,4
    loop l1
    ret
initalise_grid ENDP


END main
