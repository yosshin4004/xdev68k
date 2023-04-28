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

		3) static インスタンスのコンストラクタ＆デストラクタは自動実行されない
			XC の CLIB は、static なインスタンスのコンストラクタ＆デストラクタ
			の実行に対応していません。アプリケーション側で自力でそれらを実行
			する必要があります。

		4) C++ 対応したアセンブラとリンカを利用する必要がある
			static コンストラクタ/デストラクタを利用するには、それらに対応
			したアセンブラとリンカである g2as.x と g2lk.x を利用する必要が
			あります。詳しくは makefile を参照してください。

		5) 68060 はサポートされない
			g2as.x と g2lk.x は残念ながら 68040 までの CPU しかサポートして
			居ません。このため 68060 と C++ の同時利用は現状では不可能です。
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
#include "cxx_for_xc.h"

#ifdef __cplusplus
}
#endif


/* 一般的なクラスの例 */
class Example {
public:
	void hello() {
		printf("Example: hello c++ world.\n");
	}
	Example() {
		printf("Example: ctor.\n");
	}
	~Example() {
		printf("Example: dtor.\n");
	}
};


/* スタティックコンストラクタの例 */
class StaticCtorExample {
public:
	StaticCtorExample() {
		printf("StaticCtorExample: ctor.\n");
	}
	~StaticCtorExample() {
		printf("StaticCtorExample: dtor.\n");
	}
};
static StaticCtorExample s_staticCtorExample;


int main(int argc, char *argv[]){
	/*
		スタティックコンストラクタを実行する。
		スタティックデストラクタはスタティックコンストラクタが自動で
		atexit 関数として登録してくれる。
	*/
	execute_static_ctors();

	Example example;
	example.hello();
	return 0;
}

