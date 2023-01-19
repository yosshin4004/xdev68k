/*
	インラインアセンブラコードを利用し、整数乗算除算命令を生成します。

	[解説]
		gcc は、整数の乗算除算をビルトイン関数で実行するコードを生成します。
		ビルトイン関数による整数の乗算除算は、32bit vs 32bit で行われるため、
		オーバーヘッドが大きいです。

		この問題を回避するには、インラインアセンブラコードを利用し、CPU が
		本来持っている整数乗算除算命令を直接生成するようにします。
*/

#include <stdlib.h>
#include <stdio.h>

unsigned int mulu(unsigned short a, unsigned short b) {
	/* コンパイラによる reordering を許可 */
	unsigned int ret;
	/*
		mulu a,b は、疑似コードで示すと、b = b * a となる。
		つまり、a と b を受け取り、b を結果で上書きするような動作である。
		従って、入力リストには a b の二つの引数を書く必要がある。
		出力リストには結果受け取り用の変数 ret を指定する。
		ret と b が同一のレジスタを共有している旨を gcc に教える必要がある。
	*/
	asm (
		"	mulu %1,%0\n"
	:	/* 出力 */	"=d"	(ret)	/* out %0 (戻り値) */
	:	/* 入力 */	"d"		(a),	/* in  %1 (入力) */
					"0"		(b)		/* in  %2 (入力) = %0 と同じレジスタに割り当て */
	);
	return ret;
}
int muls(short a, short b) {
	/* コンパイラによる reordering を許可 */
	unsigned int ret;
	asm (
		"	muls %1,%0\n"
	:	/* 出力 */	"=d"	(ret)	/* out %0 (戻り値) */
	:	/* 入力 */	"d"		(a),	/* in  %1 (入力) */
					"0"		(b)		/* in  %2 (入力) = %0 と同じレジスタに割り当て */
	);
	return ret;
}
unsigned short divu(unsigned short a, unsigned int b) {
	/* コンパイラによる reordering を許可 */
	unsigned short ret;
	asm (
		"	divu %1,%0\n"
	:	/* 出力 */	"=d"	(ret)	/* out %0 (戻り値) */
	:	/* 入力 */	"d"		(a),	/* in  %1 (入力) */
					"0"		(b)		/* in  %2 (入力) = %0 と同じレジスタに割り当て */
	);
	return ret;
}
short divs(short a, int b) {
	/* コンパイラによる reordering を許可 */
	unsigned short ret;
	asm (
		"	divs %1,%0\n"
	:	/* 出力 */	"=d"	(ret)	/* out %0 (戻り値) */
	:	/* 入力 */	"d"		(a),	/* in  %1 (入力) */
					"0"		(b)		/* in  %2 (入力) = %0 と同じレジスタに割り当て */
	);
	return ret;
}


int main(int argc, char *argv[]){
	printf(
		"mulu(0x2000, 0x3000) = 0x%8X (expected value = 0x6000000)\n",
		mulu(0x2000, 0x3000)
	);
	printf(
		"muls(-0x2000, -0x3000) = 0x%8X (expected value = 0x6000000)\n",
		muls(-0x2000, -0x3000)
	);
	printf(
		"divu(0x2000, 0x6000000) = 0x%8X (expected value = 0x3000)\n",
		divu(0x2000, 0x6000000)
	);
	printf(
		"divs(-0x2000, -0x6000000) = 0x%8X (expected value = 0x3000)\n",
		divs(-0x2000, -0x6000000)
	);
	return 0;
}
