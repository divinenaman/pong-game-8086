STACK SEGMENT
	DB 64 DUP(?)
STACK ENDS

DATA SEGMENT
	
	WINDOW_WIDTH DW 140H ; width of screen (320 px)
	WINDOW_HEIGHT DW 0C8H ; height of screen (200 px)
	WINDOW_BOUNDS DW 06H ; used to check collisions early
	
	TIME_AUX DB 0 ; check if time changed
	
	BALL_ORIGIN_X DW 0A0H ; start poisiton x
	BALL_ORIGIN_Y DW 64H ; start postion y
	
	BALL_X DW 0AH ; x position
	BALL_Y DW 0AH ; y poisiton
	BALL_SIZE DW 04H ; size of ball; x=4 and y=4 therefore 16pixels
	BALL_VELOCITY_X DW 05H ; x velovity
	BALL_VELOCITY_Y DW 02H ; y velocity

	PADDLE_LEFT_X DW 0AH
	PADDLE_LEFT_Y DW 0AH
	
	PADDLE_RIGHT_X DW 130H
	PADDLE_RIGHT_Y DW 0AH
	
	PADDLE_WIDTH DW 05H
	PADDLE_HEIGHT DW 1FH
	
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE,SS:STACK,DS:DATA
	
	MAIN PROC FAR
	
	PUSH DS
	PUSH AX
	SUB AX,AX
	MOV AX,DATA
	MOV DS,AX
	POP AX
	POP AX
	
		CALL CLEAR_SCREEN  ; set video mode, set bg
		
		MOV AX,BALL_ORIGIN_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGIN_Y
		MOV BALL_Y,AX
		
		CHECK_TIME:
			MOV AH,2CH ; system time
			INT 21H
		
			CMP DL,TIME_AUX
			JE CHECK_TIME  ; equal check again
			
			MOV TIME_AUX,DL
			
			CALL CLEAR_SCREEN ; set video mode, set bg 	
			CALL DRAW_PADDLE
			CALL MOVE_BALL ; move ball
			CALL DRAW_BALL ; call prodcedure
				
			JMP CHECK_TIME	
		RET
	MAIN ENDP
	
	DRAW_PADDLE PROC NEAR
		
		MOV AH,0CH ; set pixel write mode
		MOV AL,0FH ; choose color
		MOV BH,00H ; page number
		MOV CX,PADDLE_LEFT_X ; initial pos x
		MOV DX,PADDLE_LEFT_Y ; inital pos y
		
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0CH ; set pixel write mode
			MOV AL,0FH ; choose color
			MOV BH,00H ; page number
			INT 10H
			INC CX
			MOV AX,CX ; cx-x > size => next line:else continue
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL ; jump if not greater (ax>size)
			MOV CX,PADDLE_LEFT_X
			INC DX
			MOV AX,DX
			SUB AX,PADDLE_LEFT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
		
		
		MOV AH,0CH ; set pixel write mode
		MOV AL,0FH ; choose color
		MOV BH,00H ; page number
		MOV CX,PADDLE_RIGHT_X ; initial pos x
		MOV DX,PADDLE_RIGHT_Y ; inital pos y
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0CH ; set pixel write mode
			MOV AL,0FH ; choose color
			MOV BH,00H ; page number
			INT 10H
			INC CX
			MOV AX,CX ; cx-x > size => next line:else continue
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL ; jump if not greater (ax>size)
			MOV CX,PADDLE_RIGHT_X
			INC DX
			MOV AX,DX
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
		
		RET
	DRAW_PADDLE ENDP
	
	DRAW_BALL PROC NEAR
		
		MOV AH,0CH ; set pixel write mode
		MOV AL,0FH ; choose color
		MOV BH,00H ; page number
		MOV CX,BALL_X ; initial pos x
		MOV DX,BALL_Y ; inital pos y
		
		DRAW_BALL_HORIZONTAL:
			MOV AH,0CH ; set pixel write mode
			MOV AL,0FH ; choose color
			MOV BH,00H ; page number
			INT 10H
			INC CX
			MOV AX,CX ; cx-x > size => next line:else continue
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL ; jump if not greater (ax>size)
			MOV CX,BALL_X
			INC DX
			MOV AX,DX
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
		RET
	DRAW_BALL ENDP
	
	MOVE_BALL PROC NEAR	
		MOV AX,BALL_VELOCITY_X
		ADD BALL_X,AX 
		
		MOV AX,WINDOW_BOUNDS ; left = x = WINDOW_BOUND+0
		CMP BALL_X,AX 
		JL RESET_POSITIION
		
		MOV AX,WINDOW_WIDTH ; right = x = WINDOW_WIDTH 
		SUB AX,BALL_SIZE	; WINDOW_WIDTH-BALL_SIZE
		SUB AX,WINDOW_BOUNDS ; colliosion before colliding with max screen bound
		CMP	BALL_X,AX   
		JG RESET_POSITIION
		
		MOV AX,BALL_VELOCITY_Y
		ADD BALL_Y,AX 
		
		MOV AX,WINDOW_BOUNDS
		CMP BALL_Y,AX  ; top = height = WINDOW_BOUND+0
		JL NEG_VELOCITY_Y
		
		MOV AX,WINDOW_HEIGHT ; bottom = height = WINDOW_HEIGHT
		SUB AX,BALL_SIZE	; WINDOW_HEIGHT-BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP	BALL_Y,AX 
		JG NEG_VELOCITY_Y
		
		RET
		
		NEG_VELOCITY_X:
			NEG BALL_VELOCITY_X ; BALL_VELOCITY_X = - BALL_VELOCITY_X
			RET
		
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y ; BALL_VELOCITY_Y = - BALL_VELOCITY_Y
			RET	
		RESET_POSITIION:
			CALL RESET_BALL_POSITION
			RET
			
	MOVE_BALL ENDP
	
	RESET_BALL_POSITION PROC NEAR
		MOV AX,BALL_ORIGIN_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGIN_Y
		MOV BALL_Y,AX
		
		RET
	RESET_BALL_POSITION ENDP
	
	CLEAR_SCREEN PROC NEAR
		MOV AH,00H ; set video mode
		MOV AL,13H	; choose video mode
		INT 10H ; interrupt
		
		MOV AH,0BH ; backround mode
		MOV BH,00H	; to backround color
		MOV BL,00H ; color==black
		INT 10H
	RET
	CLEAR_SCREEN ENDP

CODE ENDS
END 