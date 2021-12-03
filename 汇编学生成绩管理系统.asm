;学生成绩管理系统，实现输出和排序输出两个功能，使用冒泡排序，
;各项输入均以“空格”结束
;项目时间：2021.11.27
;合作小组成员：夏佳怡、张庆伟、王伟、赵启凯、李佳瑶、闫家栋
students STRUCT			 ;定义结构体
	ID DB 9 DUP(?)  	 
	NAME1 DB 3 DUP(?)	 
	GRADE DB ?			 
students ENDS   ;结构体共13个字节
 
DATAS SEGMENT
	N = 4			;数组大小定义
    MEMBER students N DUP(<>)  ;定义结构体数组
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

;字符输出宏定义
SHUCHU MACRO X
	MOV AH,2
	MOV DL,X 
	INT 21H
ENDM
 
;字符串输出宏定义
S_SHUCHU MACRO Y
	LEA DX,Y
	MOV AH,9
	INT 21H
ENDM
 
;单字符输入宏定义
SHURU MACRO
	MOV AH,1
	INT 21H
ENDM
 
;字符检测
CHECK MACRO X
	.IF X>'9' || X<'0' && X!=' '
		SHUCHU 13
		SHUCHU 10
		S_SHUCHU WARNING	
		S_SHUCHU NEXT		;提示输入错误
		SHURU					;让提示显示，阻止直接清屏，按任意键返回主菜单
		CALL MAIN				;跳回主菜单
	.ENDIF
ENDM
 
;成绩输出宏定义
GR_SHUCHU MACRO X
	MOV AL,X        ;接收成绩给AL
	MOV AH,0		;AX高位清0
	MOV CL,10		;除数，等会用来取余数和商
	MOV DH,0		;压栈前高位置0
	.WHILE AL != 0  ;如果商不为0，则继续除10
		DIV CL
		MOV DL,AH	;余数置于DL
		ADD DL,30H  ;转换为ASCII码方便输出
		PUSH DX		;余数入栈
		INC DH
	MOV AH,0		;高位即余数清0
	.ENDW
	;循环完成取数操作，即从右到左，从个位数开始取数，一直到最高位停止取数
	.IF DH == 0				;判断输入成绩是否为0，若为0直接输出
		SHUCHU 30H
	.ELSE					;否则弹出栈中相应内容输出
			MOV CL,DH
		.WHILE CL
			POP DX;把栈内的余数按照百位十位个位的顺序出栈并输出
			SHUCHU DL
			DEC CL
		.ENDW
	.ENDIF			;成绩输出结束
ENDM
 
;主程序代码段
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS
START:
    MOV AX,DATAS
    MOV DS,AX
MAIN PROC FAR    
	.WHILE 1	;死循环
	CALL SHOW   ;调用菜单
	CALL CHOICE ;选择功能
	.ENDW		
MAIN ENDP 
EXIT:    
	MOV AH,4CH
    INT 21H
	;主程序代码段结尾		MAIN	
 
;成绩输入子程序
GR_SHURU PROC
 	MOV CX,0
 	MOV DL,10
	.WHILE CX<=100
		SHURU			;键盘接收一个字符
		CHECK AL			;检测输入的是否为数字
	.IF AL == ' '
		MOV [BX+DI],CL		;如果输入空格，则成绩接收结束，并存入对应储存单元，即结构体GRADE单元
		RET
	.ELSE
		SUB AL,30H		;进行ASCII码转换为数字
		CBW				;AL扩展为AX，高位清0
		XCHG CX,AX		;交换数值
		MUL DL			;AL×10放入AX中
		ADD CX,AX		;将数字相加，得到新的数值，放入cl中
	.ENDIF
	.ENDW
	S_SHUCHU WARNING		;成绩输入不合格输出警告
	RET
GR_SHURU ENDP
    
;菜单显示子程序
SHOW PROC 
	MOV AX,3  ;清屏
    INT 10H
    S_SHUCHU MENU
    RET
SHOW ENDP
;菜单选项子程序
CHOICE PROC NEAR
	SHURU		;调用宏输入一个字符
	.IF AL==31H		 ;调用输入功能
		CALL INPUT
	.ELSEIF AL ==32H	;调用输出功能，且排序
		CALL RANK		;调用排序，对数据按成绩进行排序，由高到低
		CALL OUTPUT
	.ELSEIF AL==30H 	;退出程序	
		JMP EXIT
	.ELSE
		S_SHUCHU WARNING		;输出警告提示
	.ENDIF
	S_SHUCHU NEXT
	SHURU	;接收一个字符，用于暂停当前界面，按任意键刷新菜单
	RET
CHOICE ENDP
 
;输入子程序
INPUT PROC NEAR
	S_SHUCHU SHURUTIP
	S_SHUCHU HINT1
	
	LEA BX,MEMBER		;结构体初始化指针，行定位
	MOV SI,0				;统计输入的行数
	
	.WHILE SI<N				;N为行数，控制输入几行
		MOV CX,9			;循环，学号共定义9个字节空间
		MOV DI,0			;相对指针，用于定位对应的结构体内的元素，列定位
	LPI:
		SHURU
		CHECK AL		;检测输入字符是否为数字
		.IF AL == ' '
			JMP XHI			;若输入空格，则跳到下一项输入
		.ELSE
			MOV [BX+DI],AL 	;将学号逐个输入到对应的位置，最大9位
			INC DI
		.ENDIF
		LOOP LPI
	XHI:
		SHUCHU '	'
		PUSH BX    ;光标对齐
		MOV AH,2
		MOV BH,0
		MOV DX,SI
		MOV DH,9
		ADD DH,DL
		MOV DL,16
		INT 10H   ;使光标对齐在name
		POP BX
		
		MOV CX,3		;姓名输入，最大可输入4个字符
		MOV DI,9		;结构体定义的NAME段位置定位
	LPI1:
		SHURU
		.IF AL == ' '	
			JMP XMI		;输入空格表示输入下一项
		.ELSE
			MOV [BX+DI],AL  ;对应位置存入相应字符，最多输入4位
			INC DI
		.ENDIF
		LOOP LPI1
	XMI:
		SHUCHU '	'
		SHUCHU '	'
		MOV DI,12		;定位到GRADE区域，成绩输入
		CALL GR_SHURU		;调用子程序，成绩输入
		
		ADD BX,TYPE students	;跳到下一行，即结构体数字的下一行，加上相应的结构体大小
		INC SI				;行数统计自增一次
		SHUCHU 13
		SHUCHU 10
	.ENDW	
	RET
INPUT ENDP
 
 
;输出子程序
OUTPUT PROC NEAR	;该部分可参照输入子程序，理解地址所对应数据，方便理解代码
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
		MOV DX,SI		;获取当前的行数
		GR_SHUCHU DL	;将行数转换为对应的ASCII码,输出对应的行数
		
		SHUCHU 13
		SHUCHU 10
	.ENDW
	RET	
OUTPUT ENDP
 
;降序排序
RANK PROC NEAR
	MOV CX,N-1			;总的数据个数减一，即循环次数
LP1:				;冒泡排序法
	PUSH CX				;外循环次数保护，压栈
	LEA BX,MEMBER	;回到结构体的第一行
	LP2:
		MOV DI,12
		MOV DL,[BX+DI]		;取到的第一个值，与它的后一位值比较，对应到结构体为GRADE部分
		MOV DH,[BX+DI+13]	;取到的第二个值，与其前一位比较，同上
			.IF DL<DH		;如果前一个小于后一个成绩，则进行数据交换
			MOV DI,0
				.WHILE DI<13				;结构体实际长度为13
					XCHG AL,[BX+DI]
					XCHG [BX+DI+13],AL		;数据交换
					XCHG [BX+DI],AL
					INC DI
				.ENDW
			.ENDIF
		ADD BX,TYPE students	;跳到第二个位置与后一段数据比较
	LOOP LP2
	POP CX
LOOP LP1
	RET
RANK ENDP
;结束
 
CODES ENDS
    END START













