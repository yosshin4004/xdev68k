/*
	アセンブラで直接記述した関数を、C 関数の呼出し規約を利用せず、インライン
	アセンブラから直接コールする方法をまとめます。

	[解説]
		C 関数の呼出し規約は、以下の理由からオーバーヘッドが大きいです。

			1) 引数を常にスタック経由で受け渡ししなければならない
			2) 常にレジスタ d0-d2/a0-a2 が破壊レジスタとして扱われる
			3) 常にメモリバリアが張られる

		インラインアセンブラを利用して直接関数コールすることで、このオーバー
		ヘッドを回避できる場合があります。
*/

#include <stdlib.h>
#include <stdio.h>


/*
	strlcpy は、文字列コピーを行う関数である。

		宣言
			size_t strlcpy(char *dst, const char *src, size_t siz);

		引数
			siz = 文字列コピー先のメモリ領域のサイズ
			src = 文字列コピー元
			dst = 文字列コピー先

		戻り値
			コピー先に作成を試みた文字列の長さ（終端 \0 を除く）。
			戻り値 >= siz なら、文字列コピー先のメモり領域が不足
			していたことを示す。

	my_strlcpy は、strlcpy 互換関数のアセンブリコード実装である。
	入力、出力、破壊レジスタは以下のとおりである。

		入力
			d0.l = siz
			a0.l = src
			a1.l = dst

		出力
			d0.l = 戻り値

		破壊
			d0 d1 d2
			a0 a1
*/


#define FORCE_INLINE __attribute__((__always_inline__)) inline
static FORCE_INLINE size_t my_strlcpy(char *dst, const char *src, size_t siz) {
	/*
		my_strlcpy は入出力を固定のレジスタで行うので、
		この受け渡し用に register 属性をつけた変数が必要。
	*/
	register       size_t reg_d0 asm ("d0") = siz;
	register const char * reg_a0 asm ("a0") = src;
	register       char * reg_a1 asm ("a1") = dst;

	/*
		asm 構文では、入出力リスト、破壊リスト、メモリバリア等を指定する。
		入出力リストは Constranits、破壊リストは Clobbers と呼ばれる。

		まず、入出力リストと破壊リストの指定を行う。
		ここでは話を単純にするため、asm 構文の入出力レジスタを、以下の 3 つ
		のカテゴリに分けて考える。

			1) out
				・アセンブラコード内で書き込み専用
				・出力リストに記述
				・Constranits : "=r"

			2) in out
				・アセンブラコード内で読み書き
				・出力リストに記述
				・Constranits : "+r"

			3) in
				・アセンブラコード内で読み取り専用
				・入力リストに記述
				・Constranits : "r"

		my_strlcpy の d0 a0 a1 は、入力かつ更新または破壊されるレジスタなので
		(2) の in out レジスタに分類する。d0 a0 a1 のうち d0 の出力のみが利用
		され、a0 a1 は破棄されていると考える。

		破壊リストに記述するレジスタは、入出力レジスタとして出現せず、破壊だけ
		されるものに限る。my_strlcpy では、d1 d2 が該当する。

		a0 a1 を破壊リストに記述すると、Constranits と Clobbers が衝突している
		というコンパイルエラーになる。前述のとおり、a0 a1 は破壊レジスタでは
		なく in out レジスタと見なすことで、この問題を回避することができる。

		次に、メモリバリアの指定を行う。
		引数 a0.l が指す領域から、レジスタ上などにキャッシュされたデータが
		あり書き戻しが必要な場合、書き戻しは my_strlcpy 実行前に完了する必要が
		ある。また、引数 a1.l が指す領域は my_strlcpy 呼出しによって書き換え
		られるので、呼出し前にこの領域からレジスタ等にキャッシュしたデータは、
		再読み込みが必要になる。
		このような対処が必要であることをコンパイラに伝えるには、破壊リストに
		"memory" を指定してメモリバリアを要求する必要がある。

		少し余談になるが、仮に my_strlcpy が与えられたメモリ領域を read only
		のみでアクセスし一切書き換えない動作だとしても、my_strlcpy 実行前に
		それらのメモリ領域へのデータ書き込みが確実に完了していることを保証する
		ため、メモリバリアを要求する必要がある。read only にも関わらず、破壊
		リストに "memory" を指定するのは直感に反するかもしれないが、指定を怠る
		と正常に動作しないコードが生成されてしまう。

		メモリバリアの指定は大きなオーバーヘッドを伴うので、必要ないケースでは
		省略することが望ましい。もし仮に、関数内でメモリアクセスを行っていても
		それらが関数呼び出し元から見えない領域（その関数内の static 変数など）
		に対してのみ行われる場合は、メモリバリアは不要である。
	*/
	asm volatile (
			"	jbsr	_my_strlcpy\n"
	:	/* 出力 */	"+r"	(reg_d0),	/* in out %0 (入力＆戻り値) */
					"+r"	(reg_a0),	/* in out %1 (入力＆破壊) */
					"+r"	(reg_a1)	/* in out %2 (入力＆破壊) */
	:	/* 入力 */
	:	/* 破壊 */	"memory",			/* メモリバリアを要求 */
					"d1", "d2"
	);
	return reg_d0;
}


int main(int argc, char *argv[]){

	char dst[256];
	char src[] = "test string";

	int siz = sizeof(dst);
	int ret = my_strlcpy(dst, src, siz);
	printf(
		"dst = %s\n"
		"siz = %d\n"
		"ret = %d\n"
		"%s",
		dst,
		siz,
		ret,
		(ret >= siz)? "buffer shortage": "succeeded"
	);

	return 0;
}
