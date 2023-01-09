/*
	ヒープサイズを拡張する手順を示します。

	[解説]
		アプリケーション起動時点では少ないヒープメモリしか利用できません。

		stdlib.h で宣言されている allmem() 関数を実行すると、ヒープサイズが
		最大化され、大きなメモリブロックを確保可能になります。

		本サンプルコードを実行すると、例として 12MB 環境では以下のように出力
		されます。ヒープサイズが最大化されていることが確認できます。

			before allmem()
			heap free size = 65280 bytes
			after allmem()
			heap free size = 12073728 bytes
*/
#include <stdlib.h>
#include <stdio.h>


/* 確保可能なヒープ容量の最大値を（力技で）求めます */
size_t get_heap_free_size() {
	size_t size;
	size_t step = 256;
	for (size = step; size < 1024 * 1024 * 1024; size += step) {
		void *p = malloc(size);
		if (p == NULL) {
			return size - step;
		}
		free(p);
	}
	return size;
}

int main(int argc, char *argv[]){
	/* 拡張前のヒープサイズを求める */
	printf("before allmem()\n");
	printf("heap free size = %d bytes\n", (int)get_heap_free_size());

	/* ヒープサイズを拡張 */
	allmem();

	/* 拡張後のヒープサイズを求める */
	printf("after allmem()\n");
	printf("heap free size = %d bytes\n", (int)get_heap_free_size());
}


