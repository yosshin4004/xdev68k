	.cpu 68000
	.text
	.align	2
	.globl	_my_strlcpy


*------------------------------------------------------------------------------
*	strlcpy 互換関数
*
*	入力
*		d0.l = 文字列コピー先のメモリ領域のサイズ
*		a0.l = 文字列コピー元
*		a1.l = 文字列コピー先
*
*	出力
*		d0.l = コピー先に作成を試みた文字列の長さ（終端 \0 を除く） 
*			d0.l >= 元の d0.l なら、文字列コピー先のメモり領域が
*			不足していたことを示す。
*
*	破壊
*		d0 d1 d2
*		a0 a1
*------------------------------------------------------------------------------
_my_strlcpy:
							* d0.l = siz
							* a0.l = src
							* a1.l = dst

	move.l	a0,d1					* d1.l = src

	jbeq	_?L7
	add.l	d1,d0

_?L3:
	move.l	a0,d2
	addq.l	#1,a0
	cmp.l	a0,d0
	jbne	_?L5

	clr.b	(a1)
	move.l	d2,a0
	jbra	_?L7
_?L5:
	move.b	-1(a0),d2
	move.b	d2,(a1)+
	jbne	_?L3
_?L4:
	move.l	a0,d0
	sub.l	d1,d0
	subq.l	#1,d0
	rts

_?L7:
	tst.b	(a0)+
	jbne	_?L7
	jbra	_?L4
