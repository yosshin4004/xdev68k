#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include "cxx_for_xc.h"


/* スタティックコンストラクタのリスト */
typedef void (*ctor_t)();
extern ctor_t __CTOR_LIST__[];

/* スタティックコンストラクタを実行する */
void execute_static_ctors() {
	/*
		XC の startup は C++ 対応していない。
		スタティックコンストラクタは明示的に実行する必要がある。
		スタティックコンストラクタは __CTOR_LIST__ というラベル名で提供される。
		__CTOR_LIST__[0] には -1 が格納されているので、これを読み飛ばし、
		NULL が出現するまで、コンストラクタのポインタとみなし実行する。
	*/
	for (int i = 1;; i++) {
		ctor_t ctor = __CTOR_LIST__[i];
		if (ctor == NULL) break;
		ctor();
	}
}

/* アプリケーション終了時に実行する関数を登録する */
void __cxa_atexit(void (*p)()) {
	atexit(p);
}

/* リンクエラー回避のため定義が必要 */
void *__dso_handle = 0;

