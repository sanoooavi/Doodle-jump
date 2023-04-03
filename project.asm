
.MODEL SMALL
.STACK 64  

.DATA            
   ;MAIN MENU
   TEXT_MAINMENU_TITLE DB 'DOODLE JUMP MAIN MENU','$'
   TEXT_MAINMENU_PLAY  DB 'PRESS S TO PLAY THE GAME','$'  
   TEXT_MAINMENU_EXIT  DB 'PRESS E TO EXIT THE GAME','$'
   TEXT_GAME_OVER DB 'GAME OVER','$'  
   TEXT_PLAYER_SCORE DB  '0',' ',' ','$'
   
   
   
   MOVE_PAGE DB 0  
   CREATE_NEW_PLATFORM DB 0
   BALL_COLLIDED DB 0
   GAME_ACTIVE DB 1                     ;is the game active?      
  
   ;Window features        
   WINDOW_WIDTH DW 140h                 ;the width of the window (320 pixels)  16   8
   WINDOW_HEIGHT DW 0C8h               ;the height of the window (200 pixels)  10   5
   
   
   ;Ball features
   ;Ball starts at y=188 and goes up    
   BALL_CENTER_X DW 0A0h                ;current X position (column) of the ball
   BALL_CENTER_Y DW 0B9h                 ;current Y position (line) of the ball     
   BALL_RADIUS DW 08h    
   ORIGINAL_BALL_VELOCITY_Y DW 0FFF0h         ;original velocity is -16              V collision=-15
   BALL_VELOCITY_X DW 0Ah               ;X (horizontal) velocity of the ball
   BALL_VELOCITY_Y DW 0FFF0h               ;Y (vertical) velocity of the ball       ;V0=-17
   BALL_DIRECTION DB 0 ;0 means it is going up ,at first the direction is 0   
  
   ;Drawing ball features 
   D_X DW ?
   D_Y DW 0   
   P DW 0

 
   ;PLATFORMS MAIN FEATURES   
   PLATFORM_WIDTH DW 50
   PLATFORM_HEIGHT DW 5    
   
   ;PLATFORM1 FEATURES
   PLATFORM1_X DW 20H     ;x=random
   PLATFORM1_Y DW 0B4H    ;y=180
     
   ;the second platform should be upper
   PLATFORM2_X DW 64H   ;x=random     ;The platforms can start between 0 to 250
   PLATFORM2_Y DW 1EH  ;y=30
   
   ;BROKEN PLATFORM FEATURES
   SHOW_BROKEN_PLATFORM DB 1    
   
   ;PLATFORM_BROKEN_SUBS_X DW 50H     ;x=random
   ;PLATFORM_BROKEN_SUBS_Y DW 0FFE7h    ;y=125   
   
   PLATFORM_BROKEN_X DW 50H     ;x=random
   PLATFORM_BROKEN_Y DW 78h    ;y=120  
   
   PLATFORM_NEW_X DW ?   ;x=random     
   PLATFORM_NEW_Y DW 0FF88h  ;
   SCORE DB 0h
   TIME_AUX DB 0 

   BUG_WIDTH DW 04h              ;default bug width
   
   BUG_X DW 20h                  ;current X position (column) of the bug 
   BUG_Y DW 19h                ;current Y position (line) of the bug
   
   BUG_VOLACITY_X DW 06h
   BUG_VOLACITY_Y DW 00h

   BUG_MOVE DW 0


   HIT_BUG DB 0
      
   

   
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
		JE  CHECK_TIME    
		MOV TIME_AUX,DL 

		CMP CREATE_NEW_PLATFORM,1
		JE  USE_RANDOM            
		JMP CHECK_MOVING 

		
		USE_RANDOM: 


					 MOV CREATE_NEW_PLATFORM,0
					 ;OldRange = (OldMax - OldMin)  
					 ;NewRange = (NewMax - NewMin)  
					 ;NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin  
					 ;new new platform's x should be in range of [0,250]
					 ;old range=9 ,new range=250 ,new_val=x*(250/9=25)
					 MOV AH,00h
					 MOV AL,DL
					 MOV BL,0Ah
					 DIV BL   ;AH has the reaminder   
					 MOV AL,AH
					 MOV BL,1Bh ;BL=27
					 MUL BL   ;AX has the reult (between 0 to 250)     
					 MOV PLATFORM_NEW_X,AX
					 MOV PLATFORM_NEW_Y,0FF88h ;not in the page
		        
		CHECK_MOVING:  
             CMP MOVE_PAGE,1     ;check for moving
             JNE PRINTING_PLAY
	    	
	    	MOVEMENT:
              
		        CALL MOVE_PLATFORM2_DOWN 
                
		    
		PRINTING_PLAY:       
          CALL CLEAR_SCREEN                      
          CALL MOVE_BALL
          CALL DRAW_BALL
          CALL DRAW_PLATFORM  
          CALL DRAW_SCORE
          MOV BUG_VOLACITY_Y, 00h
		  CALL BUG_MOVING

		  CALL DRAW_BUG
           
          CMP GAME_ACTIVE,00h
          JE SHOW_GAME_OVER              
          JMP CHECK_TIME      
        
        SHOW_GAME_OVER:
         CALL GAME_OVER_MENU  
       
		               
            
  RET       
MAIN ENDP   
;---------------------------MOVE_PLATFORM2_DOWN----------------------;

MOVE_PLATFORM2_DOWN PROC      
    CMP PLATFORM2_Y,0B4h ;y of the first platform
    JE STOP_MOVING
    ADD PLATFORM2_Y,0Ah 
    ADD PLATFORM1_Y,0Ah 
    ADD PLATFORM_NEW_Y,0Ah  

    ;BROKEN PLATFORM MOVING   
    ADD PLATFORM_BROKEN_Y,0Dh   ;Add 13 to the y  
    CMP PLATFORM_BROKEN_Y,0B9h  ;Y=185
    JE CHANGE_FROM_UP  
    RET
    CHANGE_FROM_UP: 
       MOV SHOW_BROKEN_PLATFORM,1 
       MOV PLATFORM_BROKEN_Y,0FFF6h     ;y=-10      
       MOV AH,2Ch                   ;get the system time
	   INT 21h    					 ;CH = hour CL = minute DH = second DL = 1/100 seconds     
       MOV AH,00h
	   MOV AL,DL  
	   MOV BL,03h
	   MUL BL   
	   CMP AX,0FAh ;250
	   JB  CNV      
	   MAKE_LESS_BOUNDRY:
		    SUB AX,25h    
	   CNV:    
	   MOV PLATFORM_BROKEN_X,AX  
     
    RET  

    
    STOP_MOVING: 
        MOV MOVE_PAGE,0h  
        ;swap  platform1 values to the old platform2
        MOV AX,PLATFORM2_X
        MOV PLATFORM1_X,AX     
        MOV PLATFORM1_Y,0B4h ;Change platform1 features to the second one  
        ;reset new platform features
        MOV PLATFORM_NEW_Y,0FF88h
        ;change platform2 values to the new random platform
        MOV AX,PLATFORM_NEW_X 
        MOV PLATFORM2_X,AX   
        MOV PLATFORM2_Y,1Eh 
		
			
       
 
    RET
MOVE_PLATFORM2_DOWN ENDP



;---------------------------START_GAME----------------------;
START_GAME PROC               
    
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
	
   
   WAIT_FOR_KEY_MENU:    
	;waits for any key to press  
	MOV AH,00h
    INT 16h    
    
    CMP AL,'s'
    JE GO_TO_GAME    
    CMP AL,'e'   
    JE CALLING_EXIT
     
	JMP WAIT_FOR_KEY_MENU 
	CALLING_EXIT:
    	 CALL EXIT_PROGRAM
    GO_TO_GAME:
        RET
START_GAME ENDP


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
	
	    CMP AL,'j'
	    JE MOVE_BALL_LEFT  
	
	    CMP AL,'k'
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

;---------------------------CHECK_FOR_COLLIDING----------------------;
CHECK_FOR_COLLIDING PROC 
    ; check for bug colliding

    CHECK_BUG_COLLIDING: 
        ; LEFT
        MOV AX,BUG_X
        MOV BX, BALL_CENTER_X
        ADD BX, BALL_RADIUS
        CMP BX, AX
        JL COLIDING_CONTINUE

        ; RIGHT
        MOV AX,BUG_X
        ADD AX, BUG_WIDTH
        MOV BX, BALL_CENTER_X
        SUB BX, BALL_RADIUS
        CMP BX, AX
        JG COLIDING_CONTINUE

        ; TOP
        MOV AX,BUG_Y
        MOV BX, BALL_CENTER_Y
        ADD BX, BALL_RADIUS
        CMP BX, AX
        JL COLIDING_CONTINUE

        ; BOTTOM
        MOV AX,BUG_Y
        ADD AX, BUG_WIDTH
        MOV BX, BALL_CENTER_Y
        SUB BX, BALL_RADIUS
        CMP BX, AX
        JG COLIDING_CONTINUE

        ; HITTED
        MOV HIT_BUG, 1

        MOV GAME_ACTIVE,00h 
        RET

     COLIDING_CONTINUE:

      
	 CMP BALL_DIRECTION,1    ;if the ball is going up collision does not affect
	 JE  CHECK_PLATFORM_BROKEN_COLLIDING  
	 RET  ;if the direction equals to 0 ,then return
	 
	 ; Check if the ball is colliding with platform1
	 ; If BALL_Y_CENTER-BALL_RADIUS<=PLATFORM1_Y+PLATFROM_HEIGHT
	 ; AND BALL_X_CENTER>=PLATFORM_1_X AND BALL_X_CENTER<=PLATFORM1_X+WIDTH 
	 
	 
	   
	 CMP SHOW_BROKEN_PLATFORM,0
	 JE CHECK_PLATFORM1_COLLIDING

	 CHECK_PLATFORM_BROKEN_COLLIDING:  
	       MOV AX,PLATFORM_BROKEN_X              ;the ball_x>platform_x
		   CMP BALL_CENTER_X,AX
	       JL  CHECK_PLATFORM1_COLLIDING  ;if there's no collision check platform2
	    	
    	   ADD AX,PLATFORM_WIDTH          ;the ball_x<=platform_x+width
		   CMP BALL_CENTER_X,AX
    	   JG  CHECK_PLATFORM1_COLLIDING  ;if there's no collision check platform2
		
		   MOV AX,BALL_CENTER_Y
	       ADD AX,BALL_RADIUS
	       MOV BX,PLATFORM_BROKEN_Y
	       SUB BX,PLATFORM_HEIGHT
		   CMP AX,BX
		   JL CHECK_PLATFORM1_COLLIDING  ;if there's no collision check platform2   
		   
		   
		   MOV AX,BALL_CENTER_Y          ;maxiumim of the ball should also be more than maximum of the platform
	       SUB AX,BALL_RADIUS
	       MOV BX,PLATFORM_BROKEN_Y
	       SUB BX,PLATFORM_HEIGHT
		   CMP AX,BX
		   JGE CHECK_PLATFORM1_COLLIDING  ;if there's no collision check platform2   
		   
		   COLLIDED_BROKEN:
		        MOV SHOW_BROKEN_PLATFORM,0
               
	 
     CHECK_PLATFORM1_COLLIDING: ;random x 
		    
	       MOV AX,PLATFORM1_X              ;the ball_x>platform_x
		   CMP BALL_CENTER_X,AX
	       JL  RETURN  ;if there's no collision check platform2
	    	
    	   ADD AX,PLATFORM_WIDTH          ;the ball_x<=platform_x+width
		   CMP BALL_CENTER_X,AX
    	   JG  RETURN  ;if there's no collision check platform2
		
		   MOV AX,BALL_CENTER_Y
	       ADD AX,BALL_RADIUS
	       MOV BX,PLATFORM1_Y
	       SUB BX,PLATFORM_HEIGHT
		   CMP AX,BX
		   JL RETURN  ;if there's no collision check platform2   
		   
		   
		   MOV AX,BALL_CENTER_Y          ;maxiumim of the ball should also be more than maximum of the platform
	       SUB AX,BALL_RADIUS
	       MOV BX,PLATFORM1_Y
	       SUB BX,PLATFORM_HEIGHT
		   CMP AX,BX
		   JGE RETURN  ;if there's no collision check platform2   
		   
		   COLLIDED_1:
		     MOV BALL_COLLIDED,1  ;the ball collides with the platform       
		     MOV MOVE_PAGE,1         ;the upper platform should come down
		     MOV BALL_DIRECTION,0     ;the direction changes to up   
		     MOV CREATE_NEW_PLATFORM,1 ;create a new random platform 
		     MOV AX,ORIGINAL_BALL_VELOCITY_Y   
		     MOV BALL_VELOCITY_Y,AX  
		     ADD SCORE,1      
			 ;random 
		     CALL UPDATE_TEXT_SCORE

	  RETURN:       
	         RET              
CHECK_FOR_COLLIDING ENDP   
;---------------------------UPDATE_TEXT_SCORE----------------------; 
; as we assume the maximum score is 99 so we do not need a stack
UPDATE_TEXT_SCORE  PROC 
        XOR AX,AX
		MOV AL,SCORE  
		MOV BL,0Ah    
	    XOR DX,DX
	    MOV CX,0  
	    MOV SI ,OFFSET TEXT_PLAYER_SCORE  
    label1:
        ;operand=BL=10 and a byte so AL=AX/operan
        ;AH=remainder           
         DIV BL       
         MOV DL,AH       
         PUSH DX  ;DX is the las digit 
         INC CX
         CMP AL,0      ; if ax is zero
         MOV AH,0      
         JNE label1
         MOV BX,0
         JMP print1
    print1: 
        CMP CX,0
        JE bye  
        DEC CX    
        POP DX
        ADD DX,30h       ;add 48 so that it represents the ASCII value of digit     
		MOV [SI+BX],DL 
		INC BX  
        JMP print1     
        bye:      
	    	RET 
UPDATE_TEXT_SCORE ENDP
;---------------------------CHANGE_VELOCITY----------------------;
CHANGE_VELOCITY PROC 
    
    CMP BALL_VELOCITY_Y,00h         ;if the ball velocity is 0 ,we should increase the velocity
    JG  INCREASE_SPEED_Y            ;If the velocity is positive ,the ball is going down, we increase it
    JL  DECREASE_SPEED_Y            ;if the velocity is negative, the ball is going up, we decrease (-15+1)
    ;else if it is zero
    INC BALL_VELOCITY_Y         ;If the velocity is zero the it is at top ,we make velocity=1
    MOV BALL_DIRECTION,1             ;the ball is moving down

    ; BUG MOVING
    MOV BUG_MOVE, 1
    MOV BUG_X, 20H
    MOV BUG_Y, 19H

    RET
    INCREASE_SPEED_Y:
        INC BALL_VELOCITY_Y     ;
        CMP BALL_VELOCITY_Y,0Fh  ;15
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
		
		
		CMP SHOW_BROKEN_PLATFORM,0
		JE  RANDOM_PLATFORM   
		
		;BROKEN PLATFORM
		MOV CX,PLATFORM_BROKEN_X 			 ;set the initial column (X)
		MOV DX,PLATFORM_BROKEN_Y 			 ;set the initial line (Y)     
		
		DRAW_PLATFORM_BROKEN_HORIZONTAL:   
	    	MOV AL,0Ch 					 ;choose white as color
			CALL DRAW_PIXEL_INIT
			
			INC CX     				 	 ;CX = CX + 1
			MOV AX,CX  
	        SUB AX,PLATFORM_BROKEN_X       			 ;CX - PLATFORM1_X > PADDLE_WIDTH 
			CMP AX,PLATFORM_WIDTH          
			JNG DRAW_PLATFORM_BROKEN_HORIZONTAL
			
			MOV CX,PLATFORM_BROKEN_X 		 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX            	     
			SUB AX,PLATFORM_BROKEN_Y
			CMP AX,PLATFORM_HEIGHT
			JNG DRAW_PLATFORM_BROKEN_HORIZONTAL
			
		
		;new Random platform      
		RANDOM_PLATFORM:
		
	    	MOV CX,PLATFORM_NEW_X 			 ;set the initial column (X)
		    MOV DX,PLATFORM_NEW_Y 			 ;set the initial line (Y)     
		    CMP DX,0
	    	JGE DRAW_PLATFORM_NEW_HORIZONTAL
		    RET
	    	DRAW_PLATFORM_NEW_HORIZONTAL:   
	        	MOV AL,09h 					 ;choose white as color
			    CALL DRAW_PIXEL_INIT
			
			    INC CX     				 	 ;CX = CX + 1
			    MOV AX,CX  
	            SUB AX,PLATFORM_NEW_X       			 ;CX - PLATFORM1_X > PADDLE_WIDTH 
			    CMP AX,PLATFORM_WIDTH          
			    JNG DRAW_PLATFORM_NEW_HORIZONTAL
			
			    MOV CX,PLATFORM_NEW_X 		 ;the CX register goes back to the initial column
		    	INC DX       				 ;we advance one line
			
			    MOV AX,DX            	     
			    SUB AX,PLATFORM_NEW_Y
			    CMP AX,PLATFORM_HEIGHT
			    JNG DRAW_PLATFORM_NEW_HORIZONTAL  
			
			
	    	
	
			
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
;-----------------------------DRAW_BUG----------------------------------;
DRAW_BUG PROC NEAR

	MOV CX,BUG_X;set the initial column (X)
	MOV DX,BUG_Y;set the initial line (Y)	  
				
	DRAW_BUG_HORIZONTAL:
		MOV AH,0Ch;set the configuration to writing a pixel
		MOV AL,0Ah;choose green as color
		MOV BH,00h;set the page number
		INT 10h   ;execute the configuration
					
		INC CX    ;CX = CX + 1
		MOV AX,CX          ;CX - BUG_X > BUG_WIDTH 
		SUB AX,BUG_X
		CMP AX,BUG_WIDTH
		JNG DRAW_BUG_HORIZONTAL
					
		MOV CX,BUG_X ;the CX register goes back to the initial column      
		INC DX        ;we advanced one line 
				   
		MOV AX,DX     ;DX - BUG_Y > PADDLE_HEIGHT 
		SUB AX,BUG_Y
		CMP AX,BUG_WIDTH
		JNG DRAW_BUG_HORIZONTAL
	RET
DRAW_BUG ENDP
	
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
;---------------------------DRAW_SCORE----------------------;
DRAW_SCORE PROC
    MOV AH,02h                       ;set cursor position
	MOV BH,00h                       ;set page number
	MOV DH,01h                       ;y row
	MOV DL,0EBh						 ;x col
	INT 10h
								 
	MOV AH,09h                         ;WRITE STRING TO STANDARD OUTPUT
	MOV DX,OFFSET TEXT_PLAYER_SCORE           ;give DX a pointer 
	INT 21h
	  
  RET	 
DRAW_SCORE ENDP 
;---------------------------GAME_OVER_MENU----------------------;
GAME_OVER_MENU PROC
    CALL CLEAR_SCREEN
    MOV AH,02h                       ;set cursor position
	MOV BH,00h                       ;set page number
	MOV DH,0Ah                       ;y
	MOV DL,0Fh						 ;x
	INT 10h							 
	MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
	LEA DX,TEXT_GAME_OVER           ;give DX a pointer 
	INT 21h
	;waits for any key to press  
	MOV AH,00h
    INT 16h  
  RET	 
GAME_OVER_MENU ENDP    

;---------------------------EXIT-PROGRAM----------------------;
EXIT_PROGRAM PROC
 	MOV AH,00h                   ;set the configuration to video mode
	MOV AL,02h                   ;choose the video mode    (320*200)
	INT 10h    					 ;execute the configuration 
	MOV AH,4Ch 					 ;set the configuration 				
	INT 21h    					 ;execute the configuration	

EXIT_PROGRAM ENDP
;-------------------------BUG MOVING ---------------------;

BUG_MOVING PROC
    BUG_IS_MOVING:
        CMP BUG_MOVE, 1
    JNE RETURN_MOING      
 	    MOV AX, BUG_VOLACITY_X         
        ADD BUG_X, AX
        MOV AX, BUG_VOLACITY_Y
        ADD BUG_Y, AX 

    RETURN_MOING:
        RET
BUG_MOVING ENDP

END MAIN




