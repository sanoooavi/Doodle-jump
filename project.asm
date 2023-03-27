.MODEL SMALL
.STACK 64  

.DATA            
   ;MAIN MENU
   TEXT_MAINMENU_TITLE DB 'DOODLE JUMP MAIN MENU','$'
   TEXT_MAINMENU_PLAY  DB 'PRESS S TO PLAY THE GAME','$'  
   TEXT_MAINMENU_EXIT  DB 'PRESS E TO EXIT THE GAME','$'


   MOVE_PAGE DB 0
   BALL_COLLIDED DB 0
   GAME_ACTIVE DB 1                     ;is the game active?      
   TEXT_GAME_OVER DB 'GAME OVER','$'  
   ;NEXT_PAGE DB 0
   ;Window features        
   WINDOW_WIDTH DW 140h                 ;the width of the window (320 pixels)
   WINDOW_HEIGHT DW 0C8h               ;the height of the window (200 pixels)     
   DIRECTION DB 0 ;0 means it is going up ,at first the direction is 0
   
   ;Ball features
       
   BALL_CENTER_X DW 0A0h                ;current X position (column) of the ball
   BALL_CENTER_Y DW 0BCh                 ;current Y position (line) of the ball  
                                         ;the ball starts at y=188 and goes up
   BALL_RADIUS DW 08h    
   ORIGINAL_BALL_VELOCITY_Y DW 0FFF0h         ;original velocity is 15              V collision=-16
   BALL_VELOCITY_X DW 0Ah               ;X (horizontal) velocity of the ball
   BALL_VELOCITY_Y DW 0FFF4h               ;Y (vertical) velocity of the ball       ;V0=-12
      
    
   D_X DW ?
   D_Y DW 0   
   P DW 0

   TIME_AUX DB 0 
   
   ;PLATFORMS    
   PLATFORM_WIDTH DW 50
   PLATFORM_HEIGHT DW 5 
   ;The platforms can start between 0 to 299
   PLATFORM2_X DW 40H   ;x=random
   PLATFORM2_Y DW 50H  ;y=80
   PLATFORM1_X DW 20     ;x=random
   PLATFORM1_Y DW 0B5H    ;y=181  
   
   SCORE DB 0
   
   ;RANDOM NUMBER BASE
   
   



;---------------------------------MAIN CODE-----------------------------;
.CODE

MAIN PROC FAR                                                               
    
     MOV AX, @DATA                            
     MOV DS, AX    
     CALL CLEAR_SCREEN 
     CALL START_GAME    
     
     CHECK_TIME:     

        MOV AH,2Ch                   ;get the system time
		INT 21h    					 ;CH = hour CL = minute DH = second DL = 1/100 seconds                    
		CMP TIME_AUX,DL
		JE CHECK_TIME    
		MOV TIME_AUX,DL   
		;NEW_COORDINATE_PLATFORM:                 
		
		;CMP NEW_PAGE,0
		;JE PRINITING_PLAY:
		
		
		CREATE_RANDOM_PLATFORM:
		
		    
		PRINTING_PLAY:       
          CALL CLEAR_SCREEN                      
          CALL MOVE_BALL
          CALL DRAW_BALL
          CALL DRAW_PLATFORM   
          CMP GAME_ACTIVE,00h
          JE SHOW_GAME_OVER              
          JMP CHECK_TIME      
        
        SHOW_GAME_OVER:
         CALL GAME_OVER_MENU  
        ;OldRange = (OldMax - OldMin)  
        ;NewRange = (NewMax - NewMin)  
        ;NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin  
        
		    
		    ;DH contains second           
		   ; MOV AL,DH
		   ; MOV BL,5           
		    ;5 is the result of old range(299)/new range(59)
		   ; MUL BL
		   ; MOV PLATFORM1_X,AX  
		    ;DL is a number between 0 to 100   
		   ; MOV DH,0
		   ; MOV PLATFORM2_X,DX             ;we need platform 1_y to be between 0 and 99   
		
		    ;MOV AH,0
		    ;MOV AL,DL
		    ;MOV CL,10
		    ;DIV CL   ;AH has the remainder
		                
            
  RET       
MAIN ENDP   


;---------------------------START_GAME----------------------;
START_GAME PROC               
    WAIT_FOR_KEY_MENU:
    MOV AH,02h                       ;set cursor position
	MOV BH,00h                       ;set page number
	MOV DH,09h                       ;y 
	MOV DL,0Ah						 ;x
	INT 10h	
							 
	MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
	LEA DX,TEXT_MAINMENU_TITLE           ;give DX a pointer 
	INT 21h         
	
	MOV AH,02h                       ;set cursor position
	MOV BH,00h                       ;set page number
	MOV DH,0Ch                       ;y 
	MOV DL,09h						 ;x
	INT 10h	
							 
	MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
	LEA DX,TEXT_MAINMENU_PLAY           ;give DX a pointer 
	INT 21h  
	
	MOV AH,02h                       ;set cursor position
	MOV BH,00h                       ;set page number
	MOV DH,0Fh                       ;y 
	MOV DL,09h						 ;x
	INT 10h	
							 
	MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
	LEA DX,TEXT_MAINMENU_EXIT           ;give DX a pointer 
	INT 21h  
	
	;waits for any key to press  
	MOV AH,00h
    INT 16h    
    
    CMP AL,'S'
    JE GO_TO_GAME    
    CMP AL,'E'   
    JE CALLING_EXIT
     
	JMP WAIT_FOR_KEY_MENU 
	CALLING_EXIT:
    	 CALL EXIT_PROGRAM
    GO_TO_GAME:
        RET
START_GAME ENDP
;---------------------------EXIT-PROGRAM----------------------;
EXIT_PROGRAM PROC
 	MOV AH,00h                   ;set the configuration to video mode
	MOV AL,02h                   ;choose the video mode    (320*200)
	INT 10h    					 ;execute the configuration 
	MOV AH,4Ch 					 ;set the configuration 				
	INT 21h    					 ;execute the configuration	

EXIT_PROGRAM ENDP


;---------------------------MOVE_BALL----------------------;
MOVE_BALL PROC

    MOV AX,BALL_VELOCITY_Y          ; Move the ball vertically
    ADD BALL_CENTER_Y,AX      
    
    MOV AX,BALL_RADIUS            ; Check if the ball has passed the top boundarie    
    ADD AX,07h                       ; Add for window bounds        
    CMP BALL_CENTER_Y,AX            ; If is colliding, reverse the velocity in Y
    JL NEXT_PAGE                 
    
    ;if the ball collides with down boundry 
    MOV AX,WINDOW_HEIGHT                       
    SUB AX,BALL_RADIUS     
    SUB AX,03h
	CMP BALL_CENTER_Y,AX                    ;BALL_Y is compared with the bottom boundary o   
	JL  CONTINUE         
	
	;esle if the ball_y is equal or greater than the boundry the game is over
	GAME_OVER:
       MOV GAME_ACTIVE,00h 
       RET                                                                        
       
	CONTINUE:    	
	CALL CHECK_FOR_KEYBOARD    
    CALL CHECK_FOR_COLLIDING 
    CMP BALL_COLLIDED,1             ;check if the ball collided with one of the platforms
    JE END_PART                    ;if did then we do not change the velocity                   
    CALL CHANGE_VELOCITY         
    END_PART: 
        MOV BALL_COLLIDED,00h
        RET  
    NEXT_PAGE:
        MOV BALL_CENTER_Y,0BCH
        RET
MOVE_BALL ENDP  
;---------------------------CHECK_FOR_KEYBOARD----------------------;
CHECK_FOR_KEYBOARD PROC       
    
    CHECK_KEYBOARD:
    	MOV AH,01h ;check if any key is being pressed
	    INT 16h    ;if nothing is being pressed ZF=1
	    JNZ CHECK_CHARACTER 
	    RET                                 
	CHECK_CHARACTER:
    	MOV AH,00h ;check which key is being pressed
    	INT 16h    ;AL has the ascii code    
	
	    CMP AL,'J'
	    JE MOVE_BALL_LEFT  
	
	    CMP AL,'K'
	    JE MOVE_BALL_RIGHT
	    RET     
	
	    MOVE_BALL_LEFT: 
	       	MOV AX,BALL_VELOCITY_X
	       	SUB BALL_CENTER_X,AX
	       	
	       	MOV AX,BALL_RADIUS   
	       	INC AX
	       	CMP BALL_CENTER_X,AX
	       	JL FIX_BALL_TO_RIGHT
	       	RET       
	       	
	       	FIX_BALL_TO_RIGHT:
	       	    MOV AX,WINDOW_WIDTH
	       	    SUB AX,BALL_RADIUS 
	       	    DEC AX
	       	    MOV BALL_CENTER_X,AX
	        	RET
	       	
    	MOVE_BALL_RIGHT: 
	        MOV AX,BALL_VELOCITY_X
	       	ADD BALL_CENTER_X,AX   ;Add x position of the ball to the right
	       		       	
	       	MOV AX,WINDOW_WIDTH   ;check if it collides with right boundry
	       	SUB AX,BALL_RADIUS    
	       	SUB AX,01h
	       	CMP BALL_CENTER_X,AX
	       	JG FIX_BALL_TO_LEFT
	       	RET	       	       
	       	FIX_BALL_TO_LEFT:
	       	    MOV AX,BALL_RADIUS 
	       	    INC AX
	       	    MOV BALL_CENTER_X,AX 
       RET
CHECK_FOR_KEYBOARD ENDP	    
;---------------------------CHANGE_VELOCITY----------------------;
CHANGE_VELOCITY PROC 
    
    CMP BALL_VELOCITY_Y,00h         ;if the ball velocity is 0 ,we should increase the velocity
    JG  INCREASE_SPEED_Y            ;If the velocity is positive ,the ball is going down, we increase it
    JL  DECREASE_SPEED_Y            ;if the velocity is negative, the ball is going up, we decrease (-15+1)
    ;else if it is zero
    INC BALL_VELOCITY_Y         ;If the velocity is zero the it is at top ,we make velocity=1
    MOV DIRECTION,1             ;the ball is moving down
    RET
    INCREASE_SPEED_Y:
        INC BALL_VELOCITY_Y     ;
        CMP BALL_VELOCITY_Y,10h
        JG SET
        RET   
        SET:
         DEC BALL_VELOCITY_Y
         RET      
    DECREASE_SPEED_Y:
       INC BALL_VELOCITY_Y  
       RET
  RET
CHANGE_VELOCITY ENDP  
;---------------------------CHECK_FOR_COLLIDING----------------------;
CHECK_FOR_COLLIDING PROC 
      
	 CMP DIRECTION,1    ;if the ball is going up collision does not affect
	 JE  CHECK_PLATFORM1_COLLIDING  
	 RET  ;if the direction equals to 0 ,then return
	 
	 ; Check if the ball is colliding with platform1
	 ; If BALL_Y_CENTER-BALL_RADIUS<=PLATFORM1_Y+PLATFROM_HEIGHT
	 ; AND BALL_X_CENTER>=PLATFORM_1_X AND BALL_X_CENTER<=PLATFORM1_X+WIDTH   
	 
     CHECK_PLATFORM1_COLLIDING:  
		    
	       MOV AX,PLATFORM1_X              ;the ball_x>platform_x
		   CMP BALL_CENTER_X,AX
	       JL  CHECK_PLATFORM2_COLLIDING  ;if there's no collision check platform2
	    	
    	   ADD AX,PLATFORM_WIDTH          ;the ball_x<=platform_x+width
		   CMP BALL_CENTER_X,AX
    	   JG  CHECK_PLATFORM2_COLLIDING  ;if there's no collision check platform2
		
		   MOV AX,BALL_CENTER_Y
	       ADD AX,BALL_RADIUS
	       MOV BX,PLATFORM1_Y
	       SUB BX,PLATFORM_HEIGHT
		   CMP AX,BX
		   JL CHECK_PLATFORM2_COLLIDING  ;if there's no collision check platform2   
		   
		   
		   MOV AX,BALL_CENTER_Y          ;maxiumim of the ball should also be more than maximum of the platform
	       SUB AX,BALL_RADIUS
	       MOV BX,PLATFORM1_Y
	       SUB BX,PLATFORM_HEIGHT
		   CMP AX,BX
		   JGE CHECK_PLATFORM2_COLLIDING  ;if there's no collision check platform2   
		   
		   COLLIDED_1:
		     MOV BALL_COLLIDED,1  ;the ball collides with the platform       
		     MOV MOVE_PAGE,1
		     MOV DIRECTION,0     ;the direction changes to up      
		     MOV AX,ORIGINAL_BALL_VELOCITY_Y   
		     MOV BALL_VELOCITY_Y,AX   
		     INC SCORE
		     RET     
		        
	  CHECK_PLATFORM2_COLLIDING:

		    
	       MOV AX,PLATFORM2_X
		   CMP BALL_CENTER_X,AX
	       JL  RETURN  ;if there's no collision go to end part

    	   ADD AX,PLATFORM_WIDTH
		   CMP BALL_CENTER_X,AX
    	   JG  RETURN  ;if there's no collision go to end part  
    	   
    	   MOV AX,BALL_CENTER_Y          ;maxiumim of the ball should also be more than maximum of the platform
	       SUB AX,BALL_RADIUS
	       MOV BX,PLATFORM2_Y
	       SUB BX,PLATFORM_HEIGHT
		   CMP AX,BX
		   JGE RETURN  ;if there's no collision check platform2
		     
		   MOV AX,BALL_CENTER_Y
	       ADD AX,BALL_RADIUS
	       MOV BX,PLATFORM2_Y
	       SUB BX,PLATFORM_HEIGHT
	       CMP AX,BX
	       JL RETURN  ;if there's no collision go to end part 
		   
	       COLLIDED_2: 
	         MOV BALL_COLLIDED,1    
	         MOV DIRECTION,0  ;the direction changes to up 
	        ; MOV NEXT_PAGE,1 ;we should change the 2 platforms randomly as if it is a new page
             MOV AX,ORIGINAL_BALL_VELOCITY_Y   
		     MOV BALL_VELOCITY_Y,AX 
	         INC SCORE 
	  RETURN:       
	    RET              
CHECK_FOR_COLLIDING ENDP
;---------------------------GAME_OVER_MENU----------------------;
GAME_OVER_MENU PROC
    CALL CLEAR_SCREEN
    MOV AH,02h                       ;set cursor position
	MOV BH,00h                       ;set page number
	MOV DH,06h                       ;set row 
	MOV DL,04h						 ;set column
	INT 10h							 
	MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
	LEA DX,TEXT_GAME_OVER           ;give DX a pointer 
	INT 21h
	;waits for any key to press  
	MOV AH,00h
    INT 16h  
  RET	 
GAME_OVER_MENU ENDP
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
        
        CMP P,0h   
        
        JG OUTSIDE_OF_CIRCLE       ;if(p<=0) then the pixel is inside the circle
        MOV AX,P                 ;so the next point is (x,y+1)
        INC AX
        ADD AX,D_Y
        ADD AX,D_Y
        MOV P,AX                 ;P=P+1+2*y
        JMP PRINT   
        OUTSIDE_OF_CIRCLE:          ;if(the point is outside) the next pixel is (x-1,y+1)
            DEC D_X
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
        JMP CIRCLE_LOOP
        END_LOOP :
             RET
DRAW_BALL ENDP       
;--------------------------DRAW_PLATFROM--------------------------;
DRAW_PLATFORM PROC
		;Platform1
		
		MOV CX,PLATFORM1_X 			 ;set the initial column (X)
		MOV DX,PLATFORM1_Y 			 ;set the initial line (Y)
		
		DRAW_PLATFORM1_HORIZONTAL:   
	    	MOV AL,09h 					 ;choose white as color
			CALL DRAW_PIXEL_INIT
			
			INC CX     				 	 ;CX = CX + 1
			MOV AX,CX  
	        SUB AX,PLATFORM1_X       			 ;CX - PLATFORM1_X > PADDLE_WIDTH 
			CMP AX,PLATFORM_WIDTH          
			JNG DRAW_PLATFORM1_HORIZONTAL
			
			MOV CX,PLATFORM1_X 		 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX            	     
			SUB AX,PLATFORM1_Y
			CMP AX,PLATFORM_HEIGHT                 
			JNG DRAW_PLATFORM1_HORIZONTAL          
		
		;Platform2	
		
		MOV CX,PLATFORM2_X 			 ;set the initial column (X)
		MOV DX,PLATFORM2_Y 			 ;set the initial line (Y)
		
	
		DRAW_PLATFORM2_HORIZONTAL:   
	    	MOV AL,09h 					 ;choose white as color
			CALL DRAW_PIXEL_INIT
			
			INC CX     				 	 ;CX = CX + 1
			MOV AX,CX  
	        SUB AX,PLATFORM2_X       			 ;CX - PLATFORM1_X > PADDLE_WIDTH 
			CMP AX,PLATFORM_WIDTH          
			JNG DRAW_PLATFORM2_HORIZONTAL
			
			MOV CX,PLATFORM2_X 		 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX            	     
			SUB AX,PLATFORM2_Y
			CMP AX,PLATFORM_HEIGHT
			JNG DRAW_PLATFORM2_HORIZONTAL
			
		RET
	DRAW_PLATFORM ENDP
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