/*
	インラインアセンブリコード上で、条件付きアセンブリを利用します。

	[解説]
		HAS の条件付きアセンブリを利用し、ユーザー定義シンボルの値に従い、
		コンソールに表示する文字列を変化させます。
*/

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]){
	/*
		条件付きアセンブリ
	*/
	{
		static const char s_string1[] = "FLAG is 1.\r\n";
		static const char s_string2[] = "FLAG is not 1.\r\n";
		asm volatile (
			"FLAG:=1\n"						/* ユーザー定義シンボル */
			"	.if	FLAG==1\n"
			"		move.l	%0,-(sp)\n"
			"	.else\n"
			"		move.l	%1,-(sp)\n"
			"	.endif\n"
			"	dc.w	__PRINT\n"			/* doscall.inc で "__PRINT equ 0xff09" が定義されている */
			"	addq.l	#4,sp\n"
		:	/* 出力 */
		:	/* 入力 */	"irm" (&s_string1),	/* 引数 %0 */
						"irm" (&s_string2)	/* 引数 %1 */
		:	/* 破壊 */	"d0"				/* doscall は d0 に結果を返すか破壊する */
		);
	}

	return 0;
}
