/*
	2 バイト目が 0x5c の Shift-JIS コード文字をコンソールに出力します。

	[解説]
		2 バイト目が 0x5c の Shift-JIS コード文字は、0x5c がエスケープ
		シーケンスの開始と誤認識されるため、m68k-elf-gcc のデフォルト
		設定では正しくコンパイルできません。

		本サンプルコードでは、m68k-elf-gcc のコンパイルオプションに
			-finput-charset=cp932 -fexec-charset=cp932
		を指定することで、この問題が回避できることを示します。

		なお、旧 X68K gcc では、ソースコードが Shift-JIS でエンコード
		されていることを前提とした動作になっているため、このような対処は
		不要でした。
*/

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]){
	printf("0x5c文字テスト（ここから）\n");
	printf("	―ソЫⅨ噂浬欺圭構蚕十申曾箪貼能表暴予禄兔喀媾彌拿杤歃濬畚秉綵臀藹觸軆鐔饅鷭\n");
	printf("	IBM拡張文字（X68K では表示されない）: 纊犾\n");
	printf("	NEC定義のIBM拡張文字（X68K では表示されない）: 偆砡\n");
	printf("0x5c文字テスト（ここまで）\n");
	return 0;
}

