/*
	インラインアセンブリコードを利用し、浮動小数演算命令を実行します。

	[解説]
		インラインアセンブリを使い、FPU の数学関数を実行します。
		関数呼出しオーバーヘッドなく数学関数を実行できます。

		asm 構文で fp レジスタを入出力指定する場合 "f" を使います。

	[!!!!! 注意 !!!!!]
		本コードを実行するには、FPU を搭載した X68030 環境が必要です。
		それ以外の環境で実行すると、起動できないかクラッシュします。
		また CPU を換装している場合も注意が必要です。後発の 68040 以降の
		CPU では FPU が CPU 内蔵となりましたが、一部の浮動小数点演算命令が
		サポートされていないため、-m68881 を指定して生成したコードや
		FPU の数学関数利用したコードは動作する保証がありません。
*/

#include <stdlib.h>
#include <stdio.h>

float fpu_acosf(float x)
{
	float value;
    asm volatile (
    	"facos.x %1,%0"
    :	/* 出力 */	"=f"	(value)
    :	/* 入力 */	"f"		(x)
    );
    return value;
}

double fpu_acos(double x)
{
	double value;
    asm volatile (
    	"facos.x %1,%0"
    :	/* 出力 */	"=f"	(value)
    :	/* 入力 */	"f"		(x)
    );
    return value;
}

int main(int argc, char *argv[]){
	printf(
		"fpu_acosf(-1.0f) = %.10f (expected value = 3.141592653...)\n",
		fpu_acosf(-1.0f)
	);
	printf(
		"fpu_acos(-1.0) = %.10f (expected value = 3.141592653...)\n",
		fpu_acos(-1.0)
	);
	return 0;
}
