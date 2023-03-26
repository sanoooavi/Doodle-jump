.MODEL SMALL
.STACK 64  

.DATA        
   WINDOW_WIDTH DW 140h                 ;the width of the window (320 pixels)
   WINDOW_HEIGHT DW 0C8h               ;the height of the window (200 pixels)     
   ;WINDOW_BOUNDS DW 05h            
       
   BALL_CENTER_X DW 0A0h                ;current X position (column) of the ball
   BALL_CENTER_Y DW 64h                 ;current Y position (line) of the ball
   BALL_RADIUS DW 08h          
    
   D_X DW ?
   D_Y DW 0   
   P DW 0

   TIME_AUX DB 0 
   BALL_VELOCITY_X DW 0Ah               ;X (horizontal) velocity of the ball
   BALL_VELOCITY_Y DW 05h               ;Y (vertical) velocity of the ball        
   

.CODE

MAIN PROC FAR
     MOV AX, @DATA                            
     MOV DS, AX    
     CALL CLEAR_SCREEN  
     CHECK_TIME:                
        MOV AH,2Ch                   ;get the system time
		INT 21h    					 ;CH = hour CL = minute DH = second DL = 1/100 seconds                    
		CMP TIME_AUX,DL
		JE CHECK_TIME    
		MOV TIME_AUX,DL  
        CALL CLEAR_SCREEN                      
        CALL MOVE_BALL
        CALL DRAW_BALL  
        JMP CHECK_TIME      
     
            
  RET       
MAIN ENDP   

;---------------------------MOVE_BALL----------------------;
MOVE_BALL PROC  
    MOV AX,BALL_VELOCITY_Y          ; Move the ball vertically
    ADD BALL_CENTER_Y,AX     
    
    MOV AX,BALL_RADIUS            ; Check if the ball has passed the top boundarie    
    ADD AX,07h                       ; Add for window bounds        
    CMP BALL_CENTER_Y,AX            ; If is colliding, reverse the velocity in Y
    JL NEG_VELOCITY_Y                 
    
    MOV AX,WINDOW_HEIGHT                       
    SUB AX,BALL_RADIUS     
    SUB AX,03h
	CMP BALL_CENTER_Y,AX                    ;BALL_Y is compared with the bottom boundarie of the screen (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
	JL CHECK_KEYBOARD		         ;if is greater reverve the velocity in Y        

	NEG_VELOCITY_Y:
	    NEG BALL_VELOCITY_Y   ;reverse the velocity in Y of the ball 
	
	CHECK_KEYBOARD:
    	MOV AH,01h ;check if any key is being pressed
	    INT 16h    ;if nothing is being pressed ZF=1
	    JZ END_PART                                  
	
    	MOV AH,00h ;check which key is being pressed
    	INT 16h    ;AL has the ascii code    
	
	    CMP AL,'j'
	    JE MOVE_BALL_LEFT  
	
	    CMP AL,'k'
	    JE MOVE_BALL_RIGHT
	    JMP END_PART     
	
	    MOVE_BALL_LEFT: 
	       	MOV AX,BALL_VELOCITY_X
	       	SUB BALL_CENTER_X,AX
	       	
	       	MOV AX,BALL_RADIUS   
	       	ADD AX,01h
	       	CMP BALL_CENTER_X,AX
	       	JL FIX_BALL_TO_RIGHT
	       	JMP END_PART        
	       	
	       	FIX_BALL_TO_RIGHT:
	       	    MOV AX,WINDOW_WIDTH
	       	    SUB AX,BALL_RADIUS 
	       	    SUB AX,01h
	       	    MOV BALL_CENTER_X,AX
	       	    JMP END_PART
	       	
    	MOVE_BALL_RIGHT: 
	        MOV AX,BALL_VELOCITY_X
	       	ADD BALL_CENTER_X,AX   ;Add x position of the ball to the right
	       		       	
	       	MOV AX,WINDOW_WIDTH   ;check if it collides with right boundry
	       	SUB AX,BALL_RADIUS    
	       	SUB AX,01h
	       	CMP BALL_CENTER_X,AX
	       	JG FIX_BALL_TO_LEFT
	       	JMP END_PART
	       	       
	       	FIX_BALL_TO_LEFT:
	       	    MOV AX,BALL_RADIUS 
	       	    ADD AX,01h
	       	    MOV BALL_CENTER_X,AX
                
    END_PART:
        RET
MOVE_BALL ENDP
;---------------------------CLEAR_SCREEN----------------------;
CLEAR_SCREEN PROC               ;clear the screen by restarting the video mode
	
	MOV AH,00h                   ;set the configuration to video mode
	MOV AL,0Dh                   ;choose the video mode    (320*200)
	INT 10h    					 ;execute the configuration 
	MOV AH,0Bh 					 ;set the configuration
	MOV BH,00h 					 ;to the background color
	MOV BL,00h 					 ;choose black as background color
	INT 10h    					 ;execute the configuration	
	                      
  RET		
CLEAR_SCREEN ENDP

    
;--------------------------DRAW_PIXEL--------------------------;  
DRAW_PIXEL_INIT PROC NEAR
    MOV AH, 0Ch
    MOV BH, 00h
    INT 10h
    RET
DRAW_PIXEL_INIT ENDP
;--------------------------DRAW_BALL--------------------------;
DRAW_BALL PROC NEAR
    MOV DX, BALL_RADIUS
    MOV D_X, DX
    MOV D_Y,0

    MOV P,01h
    SUB P,DX   ;For now DX has radius value  P=1-r at first   
    CALL DRAW_POINTS
    
    ;This loop follows midpoint algorithm
    ;Check https://www.geeksforgeeks.org/mid-point-circle-drawing-algorithm/  FOR MORE INFORMATION
    CIRCLE_LOOP:
        MOV BX, D_X         ;check if(x>y) or else break the loop 
        CMP BX, D_Y
        JBE END_LOOP
      
        INC D_Y                 ;y++

        CMP P,0
        JG OUTSIDE_CIRCLE:       ;if(p<=0) then the pixel is inside the circle
        MOV AX,P                 ;so the next point is (x,y+1)
        INC AX
        ADD AX,D_Y
        ADD AX,D_Y
        MOV P,AX                 ;P=P+1+2*y
        JMP PRINT   
        OUTSIDE_CIRCLE:          ;if(the point is outside) the next pixel is (x-1,y+1)
            SUB D_X,1
            MOV AX,P
            INC AX
            ADD AX,D_Y
            ADD AX,D_Y
            SUB AX,D_X
            SUB AX,D_X  
            MOV P,AX             ;P=P+1+2*Y-2*(x-1)
        PRINT:    
            MOV BX,D_X
            CMP BX,D_Y
            JB END_LOOP
        
        CALL DRAW_POINTS    
        
        END_LOOP :
             RET
DRAW_BALL ENDP        
;--------------------------DRAW_FULL_CIRCLE--------------------------;
DRAW_POINTS PROC NEAR      
    MOV AL,0Eh   ;the circle is always yellow
    ;first octal
    ;1(x,y)
    MOV CX, BALL_CENTER_X       
    MOV DX, BALL_CENTER_Y
    ADD CX, D_X
    ADD DX, D_Y
    CALL DRAW_PIXEL_INIT        
    ;2(y,x)
    MOV CX, BALL_CENTER_X          
    MOV DX, BALL_CENTER_Y
    ADD CX, D_Y
    ADD DX, D_X
    CALL DRAW_PIXEL_INIT
    
    ;second octal
    ;3(x,-y)
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    ADD CX, D_X
    SUB DX, D_Y
    CALL DRAW_PIXEL_INIT         
    ;4(y,-x)
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    ADD CX, D_Y
    SUB DX, D_X
    CALL DRAW_PIXEL_INIT
    
    ;third octal    
    ;5(-x,y)
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    SUB CX, D_X
    ADD DX, D_Y
    CALL DRAW_PIXEL_INIT
    ;6(-y,x)
    MOV CX, BALL_CENTER_X         
    MOV DX, BALL_CENTER_Y
    SUB CX, D_Y
    ADD DX, D_X
    CALL DRAW_PIXEL_INIT
    
    ;fourth octal    
    ;7(-x,-y)
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    SUB CX, D_X
    SUB DX, D_Y
    CALL DRAW_PIXEL_INIT
    ;8(-y,-x)
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    SUB CX, D_Y
    SUB DX, D_X
    CALL DRAW_PIXEL_INIT
   
        
   
    RET
    DRAW_POINTS ENDP
END MAIN