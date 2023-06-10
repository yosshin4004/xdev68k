/*
	マルチスレッド処理を行います。

	[解説]
		Human68k の「バックグラウンド処理」を利用し、複数のスレッドを並列実行
		します。

		X68K の CPU はシングルコアなので、複数のスレッドを同時に実行することは
		できませんが、CPU の実行位置を時分割で各スレッドに切り替えることにより、
		疑似的な並列実行が可能です。

	[!!!!! 注意 !!!!!]
		Human68k のバックグラウンド処理を利用するには、CONFIG.SYS に以下の記述
		が必要です。

			PROCESS = <プログラム数> <レベル> <タイムスライス値>

			・<プログラム数>
				並列に実行するプログラム数。
				2～32の範囲で指定。

			・<レベル>
				プログラムの実行間隔を決める値。
				2～255の範囲で指定。

			・<タイムスライス値>
				各プログラムの実行時間。
				1～100msの範囲で指定。

			[例] PROCESS = 10 2 10

		XC の printf() 関数は再入ブロックの仕組みを持たないので、複数スレッド
		からログ出力すると、表示が乱れます。この問題の対処方法はありません。
*/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <doslib.h>


/* スレッドのスタック */
static uint8_t s_usp[1024*16] = {0};
static uint8_t s_ssp[1024*16] = {0};

/* スレッドの終了フラグ */
static volatile int s_has_finished = 0;

/* バックグラウンドスレッド関数 */
static void thread() {
	/* スレッドから printf */
	int loop_count_max = 200;
	for (int loop_count = 0; loop_count < loop_count_max; loop_count++) {
		printf("thread: loop_count %d/%d\n", loop_count+1, loop_count_max);
	}

	/* スレッドの終了 */
	printf("thread: KILL_PR()\n");
	s_has_finished = 1;
	KILL_PR();

	/* ここには到達しない */
	printf("thread: unreachable.\n");
}


int main(int argc, char *argv[]){
	/* バックグラウンドスレッドの作成 */
	int thread_id = OPEN_PR(
		/* const char *name */		"my_thread",						/* スレッドの名前（15 文字以内）*/
		/* int counter */			2,									/* タスクの実行間隔の制御パラメータ（2～255）*/
		/* int usp */				(uint32_t)&s_usp[sizeof(s_usp)],	/* タスク起動時の usp の初期値 */
		/* int ssp */				(uint32_t)&s_ssp[sizeof(s_ssp)],	/* タスク起動時の ssp の初期値 */
		/* int sr */				(uint32_t)0,						/* タスク起動時の sr の初期値 */
		/* int pc */				(uint32_t)thread,					/* タスク起動時の pc の初期値 */
		/* struct PRCCTRL *buff */	NULL,								/* タスク間通信のための領域情報（省略）*/
		/* long sleep_time */		1									/* 起動時待ち時間（1 が最短）*/
	);

	/* バックグラウンドスレッドの作成に失敗したら終了 */
	if (thread_id < 0) {
		printf("ERROR : thread_id = %d\n", thread_id);
		return EXIT_FAILURE;
	}

	/* メインスレッドから printf */
	int loop_count_max = 200;
	for (int loop_count = 0; loop_count < loop_count_max; loop_count++) {
		printf("main: loop_count %d/%d\n", loop_count+1, loop_count_max);
	}

	/* バックグラウンドスレッドの終了待ち */
	/*
		厳密にはこの方法で検出できるのは KILL_PR() 実行直前のタイミングであり、
		KILL_PR() 実行完了は検出できない。
	*/
	while (s_has_finished == 0) {
		/* CPU 資源節約のため処理権を解放する */
		CHANGE_PR();
	}

	printf("main: exit.\n");
	return EXIT_SUCCESS;
}


