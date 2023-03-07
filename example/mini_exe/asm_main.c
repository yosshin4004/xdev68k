/*
	main 関数の引数 argc argv に相当するものを自力で作成する。
*/

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include "dos_call.h"
#include "asm_main.h"
#include "app.h"


#define NUM_MAX_ARGS					(256)
#define MAX_COMMAND_LINE_SIZE_IN_BYTES	(0x100)


/* 引数のコピーを作成するバッファ */
static char s_cmdLineCopy[MAX_COMMAND_LINE_SIZE_IN_BYTES];
static char *(s_argv[NUM_MAX_ARGS]);

int asmMain(void *a0, void *a1, void *a2, void *a3, void *a4) {
	int argc = 0;

	/*
		このプロセスで利用可能なメモリを拡張する。
		doscall の SETBLOCK にメモリ確保エラーを意図的に起こさせ、
		エラーコードから、確保可能な最大サイズを取得し、リトライする。
	*/
	{
		void *memblock = (void *)((intptr_t)a0 + 16);
		int32_t ret1 = dosSetBlock(memblock, 0x7FFFFFFF);
		if (ret1 < 0) {
			uint32_t availableSizeInBytes = ret1 - 0x81000000;
			int32_t ret2 = dosSetBlock(memblock, 0x100000);
			if (ret2 < 0) {
				return EXIT_FAILURE;
			}
		}
	}

	/*
		コマンドライン文字列を取得。
		先頭 1 バイトは文字列長を示す。
	*/
	const char *cmdLine = (const char *)((intptr_t)a2 + 1);

	/*
		argv[0] には実行中のコマンド名が入る。
		実行ファイルのファイル名は、プロセス管理ポインタ + 0x00c4 の位置にある。
	*/
	s_argv[argc] = (char *)((intptr_t)a0 + 0x00c4);
	argc++;

	/* ステート */
	typedef enum {
		State_Separator = 0,
		State_Arg
	} State;
	State state = State_Separator;

	/* 引数のコピーを作成しながら argc と argv も作成する */
	for (int i = 0; i < sizeof(s_cmdLineCopy); i++) {
		char byte = cmdLine[i];

		/* 1 文字コピー */
		s_cmdLineCopy[i] = byte;

		/* コマンドライン終点を見つけたら正常終了 */
		if (byte == '\0') {
			break;
		}

		/* セパレータなら文字列終点に置換 */
		if (byte <= ' ') {
			byte = '\0';
			s_cmdLineCopy[i] = '\0';
		}

		/* 現在のステートで分岐 */
		switch (state) {
			case State_Separator: {
				/* セパレータの最中に有効な文字が出現したら arg の開始位置とみなす。*/
				if (byte != '\0') {
					/* arg 最大数を越えるなら異常終了 */
					if (argc >= NUM_MAX_ARGS) {
						return EXIT_FAILURE;
					}

					/* argv 登録 */
					s_argv[argc] = &s_cmdLineCopy[i];
					argc++;

					/* ステート変更 */
					state = State_Arg;
				}
			} break;

			case State_Arg: {
				/* 引数の最中にセパレータが出現したらステートの変更 */
				if (byte == '\0') {
					state = State_Separator;
				}
			} break;
		}
	}

	/* 文字列終点を確実に生成 */
	s_cmdLineCopy[sizeof(s_cmdLineCopy) - 1] = '\0';

	/* アプリケーション本体を実行 */
	uint16_t ret = 0;
	ret = appMain(argc, s_argv);
	return ret;
}


