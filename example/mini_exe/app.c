/*
	ファイルサイズが小さな実行ファイルを作成します。

	[解説]
		C/C++ で作成された実行ファイルは通常、main 関数から処理が開始します。
		実行ファイル内部では、main 関数呼び出し前に様々な初期化が行われて
		います。この初期化手続き部のコードサイズは数キロバイトあり、実行ファ
		イル肥大の原因になっています。

		実行ファイル肥大を避けるには、main 関数を利用せず、自前で用意した
		エントリポイントからプログラムが開始するよう実装する必要があります。
		ただし副作用として、C 標準関数の大部分が利用不能になるので、多くの
		基本的な処理を自前で実装する必要が生じます。

		本サンプルコードでは、minicrt.s をエントリポイントに設定しています。
		minicrt.s をエントリポイントにするため、minicrt.o をリンクリストの
		先頭に指定する必要があります。詳しくは makefile を参照してください。

		本サンプルコードは以下の順序で実行されます。

			1) minicrt.s からプログラムの実行が開始する。
			2) minicrt.s から asmMain() 関数を実行する。
			3) asmMain() 関数でコマンドライン引数を解析する。
			4) コマンドライン引数解析結果を与えて main() 関数を実行する。
*/

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include "dos_call.h"
#include "app.h"


int main(int argc, char *argv[]) {
	/* 引数を TTY 出力 */
	for (int i=0; i<argc; i++) {
		dosPrint(argv[i]);
		dosPrint("\r\n");
	}

	return EXIT_SUCCESS;
}

