/*
	インラインアセンブリコード上で、マクロ関数を利用します。

	[解説]
		マクロ関数を利用する例を示します。

		HAS のマクロには、様々な高度な記述テクニックが存在しますが、
		x68k_gas2has.pl はそれらの多くを認識することができません。
		この制限により、インラインアセンブリコード上で利用可能な
		マクロ構文は、このサンプルコードで示す程度の単純なものに
		限られます。
*/

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]){
	/*
		.macro
	*/
	{
		static int resultA = 0;
		asm volatile (
			/*
				マクロ定義行は、インデント無しで行頭から開始しなければならない。
				inline asm コードはインデントされた状態で挿入されるため、
				inline asm ブロック内の最初の行はマクロ定義行になれない。
				最初の行を破棄するため、空の改行を行う。
			*/
			"\n"

			/*
				以降はマクロ定義行になれる。
			*/
			"MY_ADD_L	.macro	reg1,reg2,reg3\n"
			"	move.l	reg1,reg3\n"
			"	add.l	reg2,reg3\n"
			"	.endm\n"
			"\n"
			"	move.l		#1,d1\n"
			"	move.l		#2,d2\n"
			"	MY_ADD_L	d1,d2,d0\n"
			"	move.l		d0,%0\n"

		:	/* 出力 */	"=irm"	(resultA)
		:	/* 入力 */
		:	/* 破壊 */	"d0","d1","d2"
		);

		printf("result = %d (expected = 3)\n", resultA);
	}

	/*
		.rept
	*/
	{
		static char s_string[] = ".rept test";
		asm volatile (
			"\n"
			"	.rept	3\n"
			"	move.l	%0,-(sp)\n"
			"	jbsr	_puts\n"			/* 外部シンボルを参照する時は _ を付ける */
			"	addq.l	#4,sp\n"
			"	.endm\n"

		:	/* 出力 */
		:	/* 入力 */	"irm" (&s_string)	/* 引数 %0 */
		:	/* 破壊 */	"d0", "d1", "d2", "a0", "a1", "a2"	/* C 関数は d0-d2/a0-a2 を破壊する */
		);
	}

	/*
		.irp
	*/
	{
		asm volatile (
			"\n"
			"	.irp	arg,string0,string1,string2\n"
			"	move.l	#arg,-(sp)\n"
			"	jbsr	_puts\n"			/* 外部シンボルを参照する時は _ を付ける */
			"	addq.l	#4,sp\n"
			"	.endm\n"

			"			.data\n"
			"string0:	.dc.b $30,0	\n"
			"string1:	.dc.b $31,0	\n"
			"string2:	.dc.b $32,0	\n"

			"			.text\n"

		:	/* 出力 */
		:	/* 入力 */
		:	/* 破壊 */	"d0", "d1", "d2", "a0", "a1", "a2"	/* C 関数は d0-d2/a0-a2 を破壊する */
		);
	}

	return 0;
}
