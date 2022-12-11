/*
	割り込み処理を C 関数で記述します。

	[解説]
		割り込み関数を C 関数で記述する場合は、関数宣言時に
			__attribute__((interrupt))
		を指定します。

		このように宣言された関数は、全レジスタを保存し、関数を rte 命令で終了
		するような動作になります。

	[!!!!! 注意 !!!!!]
		古い X68000 gcc 環境（ver1.42、2.95 など）では、関数終了時に IRTE() の
		ようなマクロを実行しましたが、その必要はなくなりました。
*/
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <doslib.h>
#include "func.h"


/* 垂直帰線期間割り込み回数をカウントする変数 */
volatile int g_count = 0;


/* 垂直帰線期間割り込みで実行される関数 */
void __attribute__((interrupt)) vsyncInterrupt(void) {
	g_count++;
}


int main(int argc, char *argv[]){
	/* 垂直帰線期間割り込み開始 */
	initVsyncInterrupt(vsyncInterrupt);

	/* 現在のカウンタ値を取得 */
	int current = g_count;

	/* 何かキーが押されるまで繰り返す */
	while (INPOUT(0xFF) == 0) {
		printf("vsync count = %d\n", current);

		/* 垂直帰線期間割り込みにより g_count が更新されるのを待つ */
		while (current == g_count) {}

		/* 現在のカウンタ値を取得しなおす */
		current = g_count;
	}

	/* 垂直帰線期間割り込み停止 */
	termVsyncInterrupt();

	return 0;
}

