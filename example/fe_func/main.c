/*
	FE ファンクションを利用した浮動小数演算を実行します。

	[解説]
		このサンプルコードでは、FE ファンクションと呼ばれる機能を利用して
		浮動小数演算を行う例を示します。

		FE ファンクションは、FLOAT2.X FLOAT3.X FLOAT4.X などの浮動小数点演算
		パッケージを組み込むことで利用可能になる浮動小数点演算機能です。
		FE ファンクションは、0xFE から始まる 16 ビットの未定義命令をユーザー
		プログラムに実行させることで、浮動小数点演算パッケージ内のコードに分岐し、
		演算を実行します。
		仕組み上、大きなオーバーヘッドが避けられませんが、実行環境に搭載されて
		いる FPU のスペックなどに依存しない互換性の高いプログラムが作成可能です。

	[!!!!! 注意 !!!!!]
		本コードを実行するには、事前に浮動小数点演算パッケージを組み込んでおく
		必要があります。
*/

#include <stdlib.h>
#include <stdio.h>

static inline float my_fadd(float a, float b) {
	register float reg_d0 asm ("d0") = a;
	register float reg_d1 asm ("d1") = b;
	asm volatile (
			/*
				FE call 0xfe5b (__FADD) は、
				d0.l を被加算数として受け取る。
				d1.l を加算数として受け取る。
				d0/d1 に結果を返す。
			*/
			".dc.w	0xfe5b\n"
	:	/* 出力 */	"+r" (reg_d0),	/* in out %0 */
					"+r" (reg_d1)	/* in out %1 */
	:	/* 入力 */
	:	/* 破壊 */
	);
	return reg_d0;
}

float a = 1.0;
float b = 2.0;
int main(int argc, char *argv[]){
	float c = my_fadd(a, b);
	printf("%f + %f = %f\n", a, b, c);
	return 0;
}

