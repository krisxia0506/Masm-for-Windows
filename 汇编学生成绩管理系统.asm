;ѧ���ɼ�����ϵͳ��ʵ���������������������ܣ�ʹ��ð������
;����������ԡ��ո񡱽���
;��Ŀʱ�䣺2021.11.27
;����С���Ա���ļ���������ΰ����ΰ������������������ƼҶ�
students STRUCT			 ;����ṹ��
	ID DB 9 DUP(?)  	 
	NAME1 DB 3 DUP(?)	 
	GRADE DB ?			 
students ENDS   ;�ṹ�干13���ֽ�
 
DATAS SEGMENT
	N = 4			;�����С����
    MEMBER students N DUP(<>)  ;����ṹ������
    MENU DB 13,10
    	DB '~~~~~~~~~~~~~~~~~MENU~~~~~~~~~~~~~~~~~~',13,10
    	DB '|         1.INPUT                     |',13,10
    	DB '|         2.OUTPUT(RANK)              |',13,10
    	DB '|         0.QUIT                      |',13,10
    	DB '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',13,10
    	DB 'PLEASE INPUT YOUR CHOICE:$'
    WARNING DB '	INPUT ERROR!!!$'
    SHURUTIP db 13,10, "Each item ends with a space","$"
   	NEXT db 13,10,13, 10,"Press any key to return to the menu",13,10,"$"
    HINT1 DB 13,10,'ID(9)		NAME(3)		GRADE(0-100)',13,10,'$'
    HINT2 DB 13,10,'ID(9)		NAME(3)		GRADE(0-100)	RANK',13,10,'$'
DATAS ENDS

;�ַ�����궨��
SHUCHU MACRO X
	MOV AH,2
	MOV DL,X 
	INT 21H
ENDM
 
;�ַ�������궨��
S_SHUCHU MACRO Y
	LEA DX,Y
	MOV AH,9
	INT 21H
ENDM
 
;���ַ�����궨��
SHURU MACRO
	MOV AH,1
	INT 21H
ENDM
 
;�ַ����
CHECK MACRO X
	.IF X>'9' || X<'0' && X!=' '
		SHUCHU 13
		SHUCHU 10
		S_SHUCHU WARNING	
		S_SHUCHU NEXT		;��ʾ�������
		SHURU					;����ʾ��ʾ����ֱֹ����������������������˵�
		CALL MAIN				;�������˵�
	.ENDIF
ENDM
 
;�ɼ�����궨��
GR_SHUCHU MACRO X
	MOV AL,X        ;���ճɼ���AL
	MOV AH,0		;AX��λ��0
	MOV CL,10		;�������Ȼ�����ȡ��������
	MOV DH,0		;ѹջǰ��λ��0
	.WHILE AL != 0  ;����̲�Ϊ0���������10
		DIV CL
		MOV DL,AH	;��������DL
		ADD DL,30H  ;ת��ΪASCII�뷽�����
		PUSH DX		;������ջ
		INC DH
	MOV AH,0		;��λ��������0
	.ENDW
	;ѭ�����ȡ�������������ҵ��󣬴Ӹ�λ����ʼȡ����һֱ�����λֹͣȡ��
	.IF DH == 0				;�ж�����ɼ��Ƿ�Ϊ0����Ϊ0ֱ�����
		SHUCHU 30H
	.ELSE					;���򵯳�ջ����Ӧ�������
			MOV CL,DH
		.WHILE CL
			POP DX;��ջ�ڵ��������հ�λʮλ��λ��˳���ջ�����
			SHUCHU DL
			DEC CL
		.ENDW
	.ENDIF			;�ɼ��������
ENDM
 
;����������
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS
START:
    MOV AX,DATAS
    MOV DS,AX
MAIN PROC FAR    
	.WHILE 1	;��ѭ��
	CALL SHOW   ;���ò˵�
	CALL CHOICE ;ѡ����
	.ENDW		
MAIN ENDP 
EXIT:    
	MOV AH,4CH
    INT 21H
	;���������ν�β		MAIN	
 
;�ɼ������ӳ���
GR_SHURU PROC
 	MOV CX,0
 	MOV DL,10
	.WHILE CX<=100
		SHURU			;���̽���һ���ַ�
		CHECK AL			;���������Ƿ�Ϊ����
	.IF AL == ' '
		MOV [BX+DI],CL		;�������ո���ɼ����ս������������Ӧ���浥Ԫ�����ṹ��GRADE��Ԫ
		RET
	.ELSE
		SUB AL,30H		;����ASCII��ת��Ϊ����
		CBW				;AL��չΪAX����λ��0
		XCHG CX,AX		;������ֵ
		MUL DL			;AL��10����AX��
		ADD CX,AX		;��������ӣ��õ��µ���ֵ������cl��
	.ENDIF
	.ENDW
	S_SHUCHU WARNING		;�ɼ����벻�ϸ��������
	RET
GR_SHURU ENDP
    
;�˵���ʾ�ӳ���
SHOW PROC 
	MOV AX,3  ;����
    INT 10H
    S_SHUCHU MENU
    RET
SHOW ENDP
;�˵�ѡ���ӳ���
CHOICE PROC NEAR
	SHURU		;���ú�����һ���ַ�
	.IF AL==31H		 ;�������빦��
		CALL INPUT
	.ELSEIF AL ==32H	;����������ܣ�������
		CALL RANK		;�������򣬶����ݰ��ɼ����������ɸߵ���
		CALL OUTPUT
	.ELSEIF AL==30H 	;�˳�����	
		JMP EXIT
	.ELSE
		S_SHUCHU WARNING		;���������ʾ
	.ENDIF
	S_SHUCHU NEXT
	SHURU	;����һ���ַ���������ͣ��ǰ���棬�������ˢ�²˵�
	RET
CHOICE ENDP
 
;�����ӳ���
INPUT PROC NEAR
	S_SHUCHU SHURUTIP
	S_SHUCHU HINT1
	
	LEA BX,MEMBER		;�ṹ���ʼ��ָ�룬�ж�λ
	MOV SI,0				;ͳ�����������
	
	.WHILE SI<N				;NΪ�������������뼸��
		MOV CX,9			;ѭ����ѧ�Ź�����9���ֽڿռ�
		MOV DI,0			;���ָ�룬���ڶ�λ��Ӧ�Ľṹ���ڵ�Ԫ�أ��ж�λ
	LPI:
		SHURU
		CHECK AL		;��������ַ��Ƿ�Ϊ����
		.IF AL == ' '
			JMP XHI			;������ո���������һ������
		.ELSE
			MOV [BX+DI],AL 	;��ѧ��������뵽��Ӧ��λ�ã����9λ
			INC DI
		.ENDIF
		LOOP LPI
	XHI:
		SHUCHU '	'
		PUSH BX    ;������
		MOV AH,2
		MOV BH,0
		MOV DX,SI
		MOV DH,9
		ADD DH,DL
		MOV DL,16
		INT 10H   ;ʹ��������name
		POP BX
		
		MOV CX,3		;�������룬��������4���ַ�
		MOV DI,9		;�ṹ�嶨���NAME��λ�ö�λ
	LPI1:
		SHURU
		.IF AL == ' '	
			JMP XMI		;����ո��ʾ������һ��
		.ELSE
			MOV [BX+DI],AL  ;��Ӧλ�ô�����Ӧ�ַ����������4λ
			INC DI
		.ENDIF
		LOOP LPI1
	XMI:
		SHUCHU '	'
		SHUCHU '	'
		MOV DI,12		;��λ��GRADE���򣬳ɼ�����
		CALL GR_SHURU		;�����ӳ��򣬳ɼ�����
		
		ADD BX,TYPE students	;������һ�У����ṹ�����ֵ���һ�У�������Ӧ�Ľṹ���С
		INC SI				;����ͳ������һ��
		SHUCHU 13
		SHUCHU 10
	.ENDW	
	RET
INPUT ENDP
 
 
;����ӳ���
OUTPUT PROC NEAR	;�ò��ֿɲ��������ӳ�������ַ����Ӧ���ݣ�����������
	S_SHUCHU HINT2
	
	LEA BX,MEMBER
	MOV SI,0
	
	.WHILE SI<N
		MOV CX,9
		MOV DI,0
	LPO:
		MOV DL,[BX+DI]
		SHUCHU DL
		INC DI
		LOOP LPO
		
		SHUCHU '	'
		MOV CX,3
	LPO1:
		MOV DL,[BX+DI]
		SHUCHU DL
		INC DI
		LOOP LPO1
		
		SHUCHU '	'
		SHUCHU '	'
		MOV DL,[BX+DI]
		GR_SHUCHU DL
		
		ADD BX,TYPE students
		INC SI
		
		SHUCHU '	'
		SHUCHU '	'
		MOV DX,SI		;��ȡ��ǰ������
		GR_SHUCHU DL	;������ת��Ϊ��Ӧ��ASCII��,�����Ӧ������
		
		SHUCHU 13
		SHUCHU 10
	.ENDW
	RET	
OUTPUT ENDP
 
;��������
RANK PROC NEAR
	MOV CX,N-1			;�ܵ����ݸ�����һ����ѭ������
LP1:				;ð������
	PUSH CX				;��ѭ������������ѹջ
	LEA BX,MEMBER	;�ص��ṹ��ĵ�һ��
	LP2:
		MOV DI,12
		MOV DL,[BX+DI]		;ȡ���ĵ�һ��ֵ�������ĺ�һλֵ�Ƚϣ���Ӧ���ṹ��ΪGRADE����
		MOV DH,[BX+DI+13]	;ȡ���ĵڶ���ֵ������ǰһλ�Ƚϣ�ͬ��
			.IF DL<DH		;���ǰһ��С�ں�һ���ɼ�����������ݽ���
			MOV DI,0
				.WHILE DI<13				;�ṹ��ʵ�ʳ���Ϊ13
					XCHG AL,[BX+DI]
					XCHG [BX+DI+13],AL		;���ݽ���
					XCHG [BX+DI],AL
					INC DI
				.ENDW
			.ENDIF
		ADD BX,TYPE students	;�����ڶ���λ�����һ�����ݱȽ�
	LOOP LP2
	POP CX
LOOP LP1
	RET
RANK ENDP
;����
 
CODES ENDS
    END START













