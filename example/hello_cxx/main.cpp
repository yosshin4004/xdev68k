/*
	C++ を利用した最も基本的なサンプルコードです。

	[解説]
		クラスを定義し、コンストラクタ、デストラクタ、およびユーザー定義
		メソッドから、コンソールに printf で文字列を出力します。

	[!!!!! 注意 !!!!!]
		現状 xdev68k 上での C++ 利用は制約がとても多いです。

		1) C++ 標準ヘッダの多くが include に失敗する
			C++ 標準ヘッダの多くが include した時点でコンパイルエラーと
			なります。この問題を解決するには、glibc 相当の環境を xdev68k
			に移植する必要がありますが、未着手となっています。
			このため std::cout は利用できず、このサンプルコードでは代替
			手段として printf を利用しています。

		2) 例外や RTTI が扱えない
			例外や RTTI を利用すると、未サポートの GAS ディレクティブが出力
			されるため、アセンブルに失敗します。例外および RTTI を無効化
			するには、m68k-elf-g++ のコンパイルオプションに
				-fno-rtti -fno-exceptions
			を指定する必要があります。詳しくは makefile を参照してください。
*/

/*
	XC のヘッダは c++ を想定していないので extern "C" はアプリケーション側で
	行う必要があります。
*/
#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <stdio.h>

#ifdef __cplusplus
}
#endif


class Example {
public:
	void hello() {
		printf("hello c++ world.\n");
	}
	Example() {
		printf("ctor.\n");
	}
	~Example() {
		printf("dtor.\n");
	}
};


int main(int argc, char *argv[]){
	Example example;
	example.hello();
	return 0;
}

