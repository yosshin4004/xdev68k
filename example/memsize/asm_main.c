/*
	フリーメモリサイズを求めるコマンドを作成します。

	[解説]
		本サンプルコードは、x68k_bin/ 以下に収録されている MEMSIZE.X コマンド
		のソースコードです。

		実行ファイルサイズを小さくするため、main 関数を利用していません。
		詳しくは、サンプルコード "mini_exe" を参照して下さい。
*/

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include "dos_call.h"
#include "asm_main.h"


void printDec(uint32_t x) {
	#define NUM_DIGITS	(10)
	static const uint32_t s_decDigits[] = {
		1000000000,
		100000000,
		10000000,
		1000000,
		100000,
		10000,
		1000,
		100,
		10,
		1,
	};

	char decAsString[NUM_DIGITS + 1];
	decAsString[0] = '0';
	decAsString[1] = '0';
	decAsString[2] = '0';
	decAsString[3] = '0';
	decAsString[4] = '0';
	decAsString[5] = '0';
	decAsString[6] = '0';
	decAsString[7] = '0';
	decAsString[8] = '0';
	decAsString[9] = '0';
	decAsString[10] = 0;

	int pos = 0;
	while (x != 0) {
		if (x < s_decDigits[pos]) {
			pos++;
			continue;
		}
		x -= s_decDigits[pos];
		decAsString[pos]++;
	}
	for (pos = 0; pos < NUM_DIGITS - 1; pos++) {
		if (decAsString[pos] != '0') break;
	}
	dosPrint(&decAsString[pos]);
}

int asmMain(void *a0, void *a1, void *a2, void *a3, void *a4) {
	/*
		SETBLOCK は、このプロセスで利用するメモリサイズを指定する doscall 
		である。この doscall は、確保可能以上のメモリサイズが指定されると、
		エラーとして、実際に確保可能なメモリサイズ + 0x81000000 を返す。
		これを利用し、フリーメモリサイズを求めることが可能である。

		引数 a0 には、プロセス起動時のメモリ管理ポインタのアドレスが格納
		されている。a0+16 は、このプロセスに与えられたメモリブロックを
		指すポインタになる。詳しくは、X68000 環境ハンドブック p.92 で解説
		されている。
	*/
	void *memblock = (void *)((intptr_t)a0 + 16);
	uint32_t availableSizeInBytes = 0x7FFFFFFF;
	int32_t ret1 = dosSetBlock(memblock, availableSizeInBytes);
	if (ret1 < 0) {
		availableSizeInBytes = ret1 - 0x81000000;
	}
	printDec(availableSizeInBytes);

	return EXIT_SUCCESS;
}


