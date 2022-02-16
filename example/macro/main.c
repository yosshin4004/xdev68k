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
		マクロ
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

	return 0;
}
