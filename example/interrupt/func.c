#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <iocslib.h>
#include <doslib.h>


/* 割り込み設定の保存用バッファ */
static volatile uint8_t s_mfpBackup[0x18] = {};
static volatile uint32_t s_vector118Backup = 0;
static volatile uint32_t s_uspBackup = 0;

/* MFP 操作の待ち時間 */
void waitForMfp() {
	/*
		今となっては出展元が不明ですが、X68000 全盛期当時、
		sr レジスタの書き換えと MFP 操作の間に若干の待ち時間を入れないと、
		X68030 などの高速な CPU 環境で誤動作する恐れがあると言われていました。

		実際に X68030 実機環境でテストできていないため真偽が不明で、
		誤動作は X68000 都市伝説の一つだった可能性も否定できませんが、
		念のため待ち時間を確保する目的で、この関数を実行しています。

		この関数は、何も実行せず return するだけの動作です。
	*/
}

/* 垂直帰線期間割り込み開始 */
void initVsyncInterrupt(void *func) {
	register uint32_t reg_a2 asm ("a2") = (uint32_t)func;

	/*
		最新の gcc 環境では、スーパーバイザーモード⇔ユーザーモードの切り替えに、
		IOCSLIB.L に収録されている B_SUPER() を利用するのは危険です。
		ここでは、スーパーバイザーモード区間にコンパイラの最適化が介入することを
		避けるため、インラインアセンブラを利用します。
	*/
	asm volatile (
		/* MFP のレジスタ番号 */
		"\n"
		"AER		= $003\n"
		"IERA		= $007\n"
		"IERB		= $009\n"
		"ISRA		= $00F\n"
		"ISRB		= $011\n"
		"IMRA		= $013\n"
		"IMRB		= $015\n"
		"\n"

		/* スーパーバイザーモードに入る */
		"	suba.l	a1,a1\n"
		"	iocs	__B_SUPER\n"					/* iocscall.inc で "__B_SUPER: .equ $81" が定義されている */
		"	move.l	d0,_s_uspBackup\n"				/*（もともとスーパーバイザーモードなら d0.l=-1） */

		/* 割り込み off */
		"	ori.w	#$0700,sr\n"
		"	bsr		_waitForMfp\n"

		/* MFP のバックアップを取る */
		"	movea.l	#$e88000,a0\n"					/* a0.l = MFPアドレス */
		"	lea.l	_s_mfpBackup(pc),a1\n"			/* a1.l = MFP保存先アドレス */
		"	move.b	AER(a0),AER(a1)\n"				/*  AER 保存 */
		"	move.b	IERB(a0),IERB(a1)\n"			/* IERB 保存 */
		"	move.b	IMRB(a0),IMRB(a1)\n"			/* IMRB 保存 */
		"	move.l	$118,_s_vector118Backup\n"		/* 変更前の V-disp ベクタ */

		/* V-DISP 割り込み設定 */
		"	move.l	a2,$118\n"						/* V-disp ベクタ書換え */
		"	bclr.b	#4,AER(a0)\n"					/* 帰線期間と同時に割り込む */
		"	bset.b	#6,IMRB(a0)\n"					/* マスクをはがす */
		"	bset.b	#6,IERB(a0)\n"					/* 割り込み許可 */

		/* 割り込み on */
		"	bsr		_waitForMfp\n"
		"	andi.w	#$f8ff,sr\n"

		/* ユーザーモードに復帰 */
		"	move.l	_s_uspBackup(pc),d0\n"
		"	bmi.b	@F\n"							/* スーパーバイザーモードから実行されていたら戻す必要無し */
		"		movea.l	d0,a1\n"
		"		iocs	__B_SUPER\n"				/* iocscall.inc で "__B_SUPER: .equ $81" が定義されている */
		"@@:\n"

	:	/* 出力 */
	:	/* 入力 */	"r"		(reg_a2)				/* in     %0 (入力＆維持) */
	:	/* 破壊 */	"memory",						/* メモリバリアを要求 */
					"d0", "a0", "a1"
	);
}

/* 垂直帰線期間割り込み停止 */
void termVsyncInterrupt() {
	/*
		前述の理由から、インラインアセンブラを利用します。
	*/
	asm volatile (
		/* スーパーバイザーモードに入る */
		"	suba.l	a1,a1\n"
		"	iocs	__B_SUPER\n"					/* iocscall.inc で "__B_SUPER: .equ $81" が定義されている */
		"	move.l	d0,_s_uspBackup\n"				/*（もともとスーパーバイザーモードなら d0.l=-1） */

		/* 割り込み off */
		"	ori.w	#$0700,sr\n"
		"	bsr		_waitForMfp\n"

		/* MFP の設定を復帰 */
		"	movea.l	#$e88000,a0\n"					/* a0.l = MFPアドレス */
		"	lea.l	_s_mfpBackup(pc),a1\n"			/* a1.l = MFPを保存しておいたアドレス */

		"	move.b	AER(a1),d0\n"
		"	andi.b	#%%0101_0000,d0\n"
		"	andi.b	#%%1010_1111,AER(a0)\n"
		"	or.b	d0,AER(a0)\n"					/* AER bit4&6 復帰 */

		"	move.b	IERB(a1),d0\n"
		"	andi.b	#%%0100_0000,d0\n"
		"	andi.b	#%%1011_1111,IERB(a0)\n"
		"	or.b	d0,IERB(a0)\n"					/* IERB bit6 復帰 */

		"	move.b	IMRB(a1),d0\n"
		"	andi.b	#%%0100_0000,d0\n"
		"	andi.b	#%%1011_1111,IMRB(a0)\n"
		"	or.b	d0,IMRB(a0)\n"					/* IMRB bit6 復帰 */

		/* V-DISP 割り込み復帰 */
		"	move.l	_s_vector118Backup(pc),$118\n"

		/* 割り込み on */
		"	bsr		_waitForMfp\n"
		"	andi.w	#$f8ff,sr\n"

		/* ユーザーモードに復帰 */
		"	move.l	_s_uspBackup(pc),d0\n"
		"	bmi.b	@F\n"							/* スーパーバイザーモードから実行されていたら戻す必要無し */
		"		movea.l	d0,a1\n"
		"		iocs	__B_SUPER\n"				/* iocscall.inc で "__B_SUPER: .equ $81" が定義されている */
		"@@:\n"

	:	/* 出力 */
	:	/* 入力 */
	:	/* 破壊 */	"memory",						/* メモリバリアを要求 */
					"d0", "a0", "a1"
	);
}

