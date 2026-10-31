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

/* デストラクタと、その呼び出し対象のオブジェクトを組で保存する、単方向リストコンテナ */
typedef struct destructor_entry {
	void (*func)(void *);
	void *object;
	struct destructor_entry *next;
} destructor_entry_t;
static destructor_entry_t *s_destructors = NULL;

/* 単方向リストの先頭から、デストラクタ実行要求を1要素取り出し、実行する */
static void pop_and_execute_static_dtor(void) {
	destructor_entry_t *entry = s_destructors;
	void (*func)(void *) = entry->func;
	void *object = entry->object;
	s_destructors = entry->next;
	free(entry);
	func(object);
}

/* デストラクタ要求を単方向リストに積む */
static void push_static_dtor(destructor_entry_t *entry, void (*func)(void *), void *object) {
	entry->func = func;
	entry->object = object;
	entry->next = s_destructors;
	s_destructors = entry;
}

/* アプリケーション終了時に実行する関数を登録する */
/*
	コンパイラはデストラクタのある static オブジェクトを初期化するとき、
	デストラクタとオブジェクトへのポインタを __cxa_atexit() に渡して登録する。
*/
int __cxa_atexit(void (*func)(void *), void *object, void *dso) {
	/* このサンプルは動的ライブラリのアンロードには対応しない */
	(void)dso;

	/* 単方向リストの要素を確保 */
	destructor_entry_t *entry = malloc(sizeof(*entry));
	if (entry == NULL) return -1;

	/* 個々の static オブジェクトのデストラクタ起動を atexit で登録する */
	if (atexit(pop_and_execute_static_dtor) != 0) {
		free(entry);
		return -1;
	}

	/* 単方向リストに積む */
	push_static_dtor(entry, func, object);

	/* 正常終了 */
	return 0;
}

void *__dso_handle = 0;

