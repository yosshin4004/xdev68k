/*
	DOS コールライブラリに相当するものを自力で作成する。
	このサンプルコードで必要最小限のもののみ実装している。
*/

#include <stdbool.h>
#include <stdint.h>
#include "dos_call.h"


void dosPrint(const char *string){
	asm volatile (
		"	move.l	%0,-(sp)\n"
		"	dc.w	__PRINT\n"			/* doscall.inc で "__PRINT: .equ $ff09" が定義されている */
		"	addq.l	#4,sp\n"
	:	/* 出力 */
	:	/* 入力 */	"r" (string)		/* 引数 %0 */
	:	/* 破壊 */	"memory",			/* メモリバリアを要求 */
					"d0"
	);
}

int32_t dosSetBlock(void *memptr, uint32_t newlen){
	register int reg_d0 asm ("d0");
	asm volatile (
		"	move.l	%1,-(sp)\n"
		"	move.l	%2,-(sp)\n"
		"	dc.w	__SETBLOCK\n"		/* doscall.inc で "__SETBLOCK: .equ $ff4a" が定義されている */
		"	addq.l	#8,sp\n"
	:	/* 出力 */	"=d" (reg_d0)		/* 戻り値 %0 */
	:	/* 入力 */	"r" (newlen),		/* 引数 %1 */
					"r" (memptr)		/* 引数 %2 */
	:	/* 破壊 */
	);
	return reg_d0;
}

