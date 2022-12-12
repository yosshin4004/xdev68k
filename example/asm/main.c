/*
	インラインアセンブラコードを利用し、コンソールに文字列を表示します。

	[解説]
		インラインアセンブラコードから二通りの方法でコンソールに文字列を表示
		します。

		一つ目の方法では、C 標準関数を利用します。
		インラインアセンブラコードから C 関数を実行するには、引数を push した
		のちに関数名に _ を付けたラベルを jsr または bsr 命令で呼び出す必要が
		あります。

		二つ目の方法では、X68K の doscall を利用します。
		doscall は、0xFF から始まる 16 ビットの未定義命令を CPU に実行させる
		ことで、OS が提供しているファンクション・コールを呼出します。

		doscall を利用するには、doscall.mac（SHARP Compiler PRO-68K	ver2.1 に
		収録されている）を、アセンブラソースコードの冒頭で include する必要が
		あります。x68k_gas2has.pl に引数 -inc を指定することで、この include 
		を行うディレクティブを生成することができます。


		インラインアセンブラコードは、次のような asm 構文で記述します。

			asm volatile (
				"アセンブラコード"
			:	出力リスト
			:	入力リスト
			:	破壊リスト
			);

		volatile は、コンパイラの最適化による命令の並べ替えを抑止するための
		指定です。これは、必要なければ省略することができます。
		入出力リストには、アセンブラコードの引数や戻り値の受け渡し方法を記述
		します。これは Constranits と呼ばれます。
		破壊リストには、アセンブラコード内で破壊されるレジスタを列挙します。
		これは Clobbers と呼ばれます。

		Constranits や Clobbers の記述ルールについては、gcc の公式ドキュメント
		をご参照くたさい。
		https://gcc.gnu.org/onlinedocs/gcc/Using-Assembly-Language-with-C.html#Using-Assembly-Language-with-C
*/

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]){
	/* C 標準関数の puts を使ったコンソール文字列出力 */
	{
		static char s_string[] = "hello world. (by puts())";
		asm volatile (
			"	move.l	%0,-(sp)\n"
			"	jbsr	_puts\n"			/* 外部シンボルを参照する時は _ を付ける */
			"	addq.l	#4,sp\n"
		:	/* 出力 */
		:	/* 入力 */	"irm" (&s_string)	/* 引数 %0 */
		:	/* 破壊 */	"d0", "d1", "d2", "a0", "a1", "a2"	/* C 関数は d0-d2/a0-a2 を破壊する */
		);
	}

	/* doscall を使ったコンソール文字列出力 */
	{
		static char s_string[] = "hello world. (by doscall)\r\n";
		asm volatile (
			"	move.l	%0,-(sp)\n"
			"	dc.w	__PRINT\n"			/* doscall.inc で "__PRINT equ 0xff09" が定義されている */
			"	addq.l	#4,sp\n"
		:	/* 出力 */
		:	/* 入力 */	"irm" (&s_string)	/* 引数 %0 */
		:	/* 破壊 */	"d0"				/* doscall は d0 に結果を返すか破壊する */
		);
	}

	return 0;
}
