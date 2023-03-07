*
* 実行ファイルのエントリポイントになるコード
*
* このファイルを実行ファイルのエントリポイントにするには、このファイルから
* 生成したオブジェクトファイルを、リンクリストの先頭に指定する必要がある。
*

	.cpu 68000
	.include doscall.inc
	.include iocscall.inc

	.text
	.even

	move.l	a4, -(sp)		* プログラムの実行開始アドレス
	move.l	a3, -(sp)		* 環境のアドレス
	move.l	a2, -(sp)		* コマンドラインのアドレス
	move.l	a1, -(sp)		* プログラムの終わり+1 のアドレス
	move.l	a0, -(sp)		* メモリ管理ポインタのアドレス
	jbsr	_asmMain		* アプリケーション main を呼び出す
	add.l	#4*5,sp

	move.w	d0,-(sp)
	dc.w	__EXIT2

