/*
	インラインアセンブリコードを利用し、浮動小数演算命令を実行します。

	[解説]
		インラインアセンブリを使い、FPU の数学関数を実行します。
		関数呼出し等のオーバーヘッドを受けず、高速に数学関数を実行できます。

		asm 構文の Constranits に fp レジスタを指定する場合は "f" を使います。

	[!!!!! 注意 !!!!!]
		本コードを実行するには、FPU を搭載した X68030 環境が必要です。それ以外
		の環境で実行すると、起動できないかクラッシュします。
		また CPU を換装している場合も注意が必要です。後発の 68040 以降の CPU 
		では FPU が CPU 内蔵となりましたが、一部の浮動小数点演算命令がサポート
		されていないため、コンパイルオプションに -m68881 を指定して生成した
		コードは動作する保証がありません。68040 以降対応のコードを生成する場合
		は -m68881 は指定せず、-m68040 や -m68060 などの CPU の種類を指定する
		オプションのみを指定します。
*/

#include <stdlib.h>
#include <stdio.h>

float fpu_acosf(float x)
{
	float value;
	/*
		ここで実行するコードは、内部にステートを一切持たないので、実行順序を
		どのように入れ替えても結果は変化しない。このようなコードはコンパイラに
		reordering させることで、より良いコードが得られる場合がある。
		asm 構文に volatile を指定しないことで reordering を許可する。
	*/
	asm (
		"facos.x %1,%0"
	:	/* 出力 */	"=f"	(value)
	:	/* 入力 */	"f"		(x)
	);
	return value;
}

double fpu_acos(double x)
{
	double value;
	/* コンパイラによる reordering を許可する（詳細は前述）*/
	asm (
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
