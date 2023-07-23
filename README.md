# xdev68k


## 解説

xdev68k は、SHARP X680x0 シリーズ対応のクロスコンパイル環境です。
最新の gcc を用いて X68K 対応の実行ファイルが作成可能です。
ホスト環境は、msys+mingw、cygwin、linux、WSL 等々の Unix 互換環境が利用可能です（mac も恐らく利用可能ですが未検証）。

xdev68k は、
旧プロジェクトである x68k_gcc_has_converter（ https://github.com/yosshin4004/x68k_gcc_has_converter ）から発展したものです。
旧プロジェクトは終了し、本プロジェクトに統合されました。


## 環境構築手順

1. Unix 互換環境のインストールと環境構築（作業時間 : 10 分程度）  
	msys+mingw、cygwin、linux、WSL 等々の Unix 互換環境を用意します。
	ここでは、推奨環境である msys+mingw を利用する場合のインストール手順のみを示します。

	msys のインストーラは https://www.msys2.org/ から入手可能です。
	インストールが終わったら、msys のコンソール上で以下を実行し、gcc や perl 等、環境構築に必要なツールをインストールします。
	```bash
	pacman -S base-devel
	pacman -S mingw-w64-i686-toolchain
	pacman -S mingw-w64-x86_64-toolchain
	pacman -S autoconf-wrapper
	pacman -S msys/autoconf
	pacman -S msys/automake-wrapper
	pacman -S unzip
	pacman -S cmake
	pacman -S libiconv
	pacman -S git
	```
	msys の perl は初期状態ではロケールが正しく設定されておらず、perl 起動の度に以下のように警告されます。
	```bash
	perl: warning: Setting locale failed.
	perl: warning: Please check that your locale settings:
	```
	これを解消するため、C:/msys64/home/ユーザー名/.bashrc に以下のような指定を追加しておきます。

	```bash
	# perl の locale 警告対策
	export LC_ALL="C"
	export LC_CTYPE="C"
	export LANG="en_US.UTF-8"
	```
	msys の bash コンソールは、スタートメニューの「MSYS2 MinGW 64bit」のショートカットから起動します。
	ここから起動しないと、ネイティブのコンパイラ環境にパスが通った状態にならず、クロスコンパイラ構築に失敗するのでご注意下さい。

	![screen_shot_gfx](https://user-images.githubusercontent.com/11882108/154822283-4b208ca4-8a69-4b34-a160-5b7845cbaa2a.png)

2. xdev68k を取得（作業時間 : 1 分程度）  
	本リポジトリを clone します。
	```bash
	git clone https://github.com/yosshin4004/xdev68k.git
	```
	以降、ディレクトリ xdev68k に clone された前提で説明を進めます。

3. クロスコンパイラ作成（作業時間 : 環境によっては数時間）  
	十分なディスク容量（10GB 程度）があることを確認した上で、
	ホスト環境の bash コンソール上で先ほど clone したディレクトリ xdev68k に移動し、以下のコマンドを実行します。
	```bash
	bash ./build_m68k-toolchain.sh
	```
	xdev68k/m68k-toolchain 以下に、Motorola 680x0 シリーズ対応のクロスコンパイラである m68k-elf-gcc が構築されます。
	以下のメッセージがコンソールに出力されれば完了です。
	```
	The building process is completed successfully.
	```

4. ユーティリティのインストール（作業時間 : 数分程度）  
	ここの操作では、以下のファイルが自動でダウンロードまたはインストールされます。
	対象ファイルの詳細については、以下の URL でご確認頂けます。

	* SHARP C Compiler PRO-68K ver2.1 システムディスク 1 & 2  
	http://retropc.net/x68000/software/sharp/xc21/
	（ファイル名 XC2101.LZH, XC2102_02.LZH）  
	* HAS060.X  
	http://retropc.net/x68000/software/develop/as/has060/
	（ファイル名 HAS06089.LZH）
	* HLK v3.01  
	http://retropc.net/x68000/software/develop/lk/hlk/
	（ファイル名 HLK301B.LZH）
	* g2as g2lk (Charlie 版 GCC の一部)
	http://retropc.net/x68000/software/develop/c/gcc2/
	（ファイル名 G3_20.LZH）
	* X68K コマンドラインエミュレータ run68  
	https://github.com/GOROman/run68mac

	ホスト環境の bash コンソール上で、先ほどと同じディレクトリ（xdev68k）から以下のコマンドを実行します。
	```bash
	bash ./install_xdev68k-utils.sh
	```
	クロスコンパイル環境で必要になるユーティリティの実行ファイル、ヘッダおよびライブラリがインストールされます。
	以下のメッセージがコンソールに出力されれば完了です。
	```
	The installation process is completed successfully.
	Please set the current directory path to environment variable XDEV68K_DIR.
	```

5. 環境変数設定（作業時間 : 1 分程度）  
	環境変数 XDEV68K_DIR に、ディレクトリ xdev68k のフルパスを設定します。
	msys の場合、C:/msys64/home/ユーザー名/.bashrc に次のように記述しておくと良いでしょう。
	```bash
	export XDEV68K_DIR=ディレクトリxdev68kのフルパス
	```
	フルパスは、C: 等のドライブ名から始まる windows スタイルではなく、
	/c 等から始まる unix スタイルで指定してください。

## ファイル構成

正しく環境構築が完了した状態のディレクトリ構造は以下のようになります。
```
xdev68k/
│
├ archive/
│	│	利用させて頂いたソフトウェアのアーカイブファイル
│	├ readme.txt
│	│		原作者、入手元の情報、利用規約をまとめたテキスト
│	├ libgcc_src.tar.gz
│	│		libgcc のソースコード
│	├ libstdc++_src.tar.gz
│	│		libstdc++ のソースコード
│	├ *.zip *.lzh
│	│		原本のアーカイブファイル
│	└ download/
│			ダウンロードしたソフトウェアのアーカイブファイル
├ build_gcc/
│		クロスコンパイラのソースコードとビルドにより生成された中間ファイル群
│		このディレクトリ以下には 18 万近いファイルが存在する。削除しても問題ない。
├ example/
│		サンプルコード
├ include/
│	│	ヘッダファイル
│	├ xc/
│	│		SHARP C Compiler PRO-68K ver2.1 のヘッダファイル
│	└ xdev68k/
│			xdev68k 環境で追加されたヘッダファイル等
├ m68k-toolchain/
│		クロスコンパイラのビルド結果
│		このディレクトリ以下には 1700 程度のファイルが存在する。削除してはいけない。
├ run68/
│	│	X68K コマンドラインエミュレータ run68
│	├ run68.exe
│	│		run68 実行ファイル
│	└ run68.ini
│			run68 設定ファイル
├ lib/
│	│	ライブラリファイル
│	├ xc/
│	│		SHARP C Compiler PRO-68K ver2.1 のライブラリファイル
│	└ m68k_elf/
│		│
│		├ m68000/ m68020/ m68040/ m68060/ 
│		│	└ *.a
│		│			各種 CPU 構成ごとのライブラリファイル
│		└ *.a		
│				CPU の種類を問わないライブラリファイル
├ util/
│	│
│	├ atomic.lock
│	│		atomic.pl で利用するロックファイル
│	├ atomic.pl
│	│		指定のコマンドラインをシングルスレッド実行するスクリプト
│	├ db_pop_states.txt
│	│		割り込み処理のステート復活を行うデバッガコマンド
│	├ db_push_states.txt
│	│		割り込み処理のステート退避を行うデバッガコマンド
│	├ xeij_*.bat
│	│		XEiJ 制御用バッチファイル
│	├ xeij_remote_debug.sh
│	│		XEiJ 上で指定ファイルをデバッグ実行するスクリプト
│	└ x68k_gas2has.pl
│			GAS to HAS コンバータ
├ x68k_bin/
│	│	X68K のコマンドラインユーティリティ
│	├ AR.X
│	│		X68k Archiver v1.00
│	├ DB.X
│	│		X68k Debugger v2.00
│	├ g2as.x
│	│		X68k High-speed Assembler v3.08 modified for GCC
│	├ g2lk.x
│	│		X68k SILK Hi-Speed Linker v2.29 modified for GCC
│	├ HAS060.X
│	│		High-speed Assembler 68060 対応版 version 3.09+89
│	├ hlk301.x
│	│		HLK v3.01
│	└ MEMSIZE.X
│			フリーメモリサイズをコンソール出力する（run68 の動作テスト用）
├ build_m68k-toolchain.sh
│		クロスコンパイラのビルドスクリプト
├ build_x68k-libgcc.sh
│		libgcc のビルドスクリプト
├ build_x68k-libstdc++.sh
│		libstdc++ のビルドスクリプト
└ install_xdev68k-utils.sh
		ユーティリティのインストールスクリプト
```

## Hello World サンプルの実行

環境構築が完了したら、
テストを兼ねて基本サンプルをビルド＆実行してみましょう。
ホスト環境の bash コンソール上でディレクトリ xdev68k に移動し、以下を実行します。  
```bash
cd example/hello
make
```
カレントディレクトリに MAIN.X というファイルが生成されます。これが X68K の実行ファイルです。
MAIN.X を、X68K 実機またはエミュレータ環境にコピーして実行します（makefile で自動化されていないので手動で行います）。
X68K のコンソールに以下のように出力されれば成功です。
```bash
hello world.
```


## コンパイル～実行ファイル生成までの詳細

先ほどの Hello World サンプルのソースファイル main.c を例に、
コンパイルから実行ファイル生成までの流れを解説します。
ビルド作業は、ホスト環境の bash コンソール上で行います。

1. コンパイル  
	main.c をクロスコンパイラ m68k-elf-gcc でコンパイルします。
	```bash
	# main.c をコンパイルする。
	# -I${XDEV68K_DIR}/include/xc : include パスの指定
	# -Os : サイズ優先最適化
	# -fcall-used-d2 -fcall-used-a2 : X68K と ABI を一致させるため d2 a2 を破壊可能レジスタに指定
	# -Wno-builtin-declaration-mismatch : 警告の抑制
	${XDEV68K_DIR}/m68k-toolchain/bin/m68k-elf-gcc main.c -I${XDEV68K_DIR}/include/xc -S -Os -m68000 -fcall-used-d2 -fcall-used-a2 -Wno-builtin-declaration-mismatch -o main.m68k-gas.s
	```
	カレントディレクトリにソースファイル main.m68k-gas.s が生成されます。

2. アセンブラソースを変換  
	main.m68k-gas.s は、GAS 形式と呼ばれる書式で記述されています。
	x68k_gas2has.pl を用いて、X68K で利用可能な HAS 形式に変換します。
	```bash
	# HAS.X がアセンブル可能な書式に変換する。
	# -cpu オプション : 対象とする CPU の種類
	# -inc オプション : ソース冒頭で include するファイル
	perl ${XDEV68K_DIR}/util/x68k_gas2has.pl -i main.m68k-gas.s -o main.s -cpu 68000 -inc doscall.mac,iocscall.mac
	```
	カレントディレクトリに、HAS 形式のソースファイル main.s が生成されます。

3. アセンブル  
	main.s を X68K 対応アセンブラ HAS060.X でアセンブルします。
	アセンブラの実行は、X68K コマンドラインエミュレータ run68 で行います。
	```bash
	# main.s をアセンブルする。
	# -u : 未定義シンボルを外部参照にする 
	# -e : 外部参照オフセットをロングワードにする 
	# -w0 : 警告の抑制
	# -I${XDEV68K_DIR}/include/xc : include パスの指定
	HAS="${XDEV68K_DIR}/run68/run68 ${XDEV68K_DIR}/x68k_bin/HAS060.X"
	${HAS} -e -u -w0 -I${XDEV68K_DIR}/include/xc -o main.o main.s
	```
	カレントディレクトリにオブジェクトファイル main.o が生成されます。

4. リンク  
	main.o を X68K 対応リンカ hlk301.x でリンクします。
	リンカの実行は、X68K コマンドラインエミュレータ run68 で行います。
	本リポジトリに含まれているランタイムライブラリをリンクする必要があります。
	```bash
	# main.o をリンクする。
	# HLK に長いパス文字を与えることは難しいので、
	# 回避策としてリンク対象ファイルを lk_tmp 以下にコピーし、
	# 短い相対パスを用いてリンクを実行させる。
	rm -rf lk_tmp
	mkdir -p lk_tmp
	cp main.o lk_tmp/
	cp ${XDEV68K_DIR}/lib/xc/CLIB.L lk_tmp/
	cp ${XDEV68K_DIR}/lib/xc/FLOATFNC.L lk_tmp/
	cp ${XDEV68K_DIR}/lib/m68k_elf/m68000/libgcc.a lk_tmp/
	ls lk_tmp/ > lk_list.txt
	HLK="${XDEV68K_DIR}/run68/run68 ${XDEV68K_DIR}/x68k_bin/hlk301.x"
	${HLK} -Llk_tmp/ -o MAIN.X -i lk_list.txt
	```
	カレントディレクトリに実行ファイル MAIN.X が生成されます。


## GAS 形式 → HAS 形式変換例

ディレクトリ xdev68k/util 以下に置かれている x68k_gas2has.pl は、
アセンブラソースの GAS 形式 → HAS 形式変換を行うコンバータです。
x68k_gas2has.pl が生成するソースコードは以下に示すように、
左側が HAS 形式、右側が元になった GAS 形式となります。
```
* NO_APP
RUNS_HUMAN_VERSION      equ     3
        .cpu 68000
* X68 GCC Develop
                                                        *#NO_APP
        .file   "adler32.c"                             *       .file   "adler32.c"
        .text                                           *       .text
        .globl ___umodsi3                               *       .globl  __umodsi3
        .globl ___modsi3                                *       .globl  __modsi3
        .globl ___mulsi3                                *       .globl  __mulsi3
        .align  2                                       *       .align  2
                                                        *       .type   adler32_combine_, @function
_adler32_combine_:                                      *adler32_combine_:
        movem.l d3/d4/d5/d6/d7/a3,-(sp)                 *       movem.l #7952,-(%sp)
        move.l 28(sp),d3                                *       move.l 28(%sp),%d3
        move.l 32(sp),d6                                *       move.l 32(%sp),%d6
        move.l 36(sp),d0                                *       move.l 36(%sp),%d0
        jbmi _?L6                                       *       jmi .L6
        lea ___umodsi3,a3                               *       lea __umodsi3,%a3
        move.l #65521,-(sp)                             *       move.l #65521,-(%sp)
        move.l d0,-(sp)                                 *       move.l %d0,-(%sp)
        jbsr (a3)                                       *       jsr (%a3)
        addq.l #8,sp                                    *       addq.l #8,%sp
        move.l d0,d5                                    *       move.l %d0,%d5
        move.l d3,d7                                    *       move.l %d3,%d7
        and.l #65535,d7                                 *       and.l #65535,%d7
        move.l d7,-(sp)                                 *       move.l %d7,-(%sp)
        move.l d0,-(sp)                                 *       move.l %d0,-(%sp)
```

GAS 形式では、MIT syntax と呼ばれる記法（右）が利用されることがあります。
HAS.X 形式（左）では Motorola syntax に変換されます。
```
                                    * .type __mulsi3,function
 .globl ___mulsi3                   * .globl __mulsi3
___mulsi3:                          *__mulsi3:
 move.w 4(sp),d0                    * movew %sp@(4), %d0
 mulu.w 10(sp),d0                   * muluw %sp@(10), %d0
 move.w 6(sp),d1                    * movew %sp@(6), %d1
 mulu.w 8(sp),d1                    * muluw %sp@(8), %d1
                                    *
 add.w d1,d0                        * addw %d1, %d0
                                    *
                                    *
                                    *
 swap d0                            * swap %d0
 clr.w d0                           * clrw %d0
 move.w 6(sp),d1                    * movew %sp@(6), %d1
 mulu.w 10(sp),d1                   * muluw %sp@(10), %d1
 add.l d1,d0                        * addl %d1, %d0
                                    *
 rts                                * rts
```

## ランタイムライブラリの種類と用途

ディレクトリ xdev68k/lib/m68k_elf 以下には、
gcc のランタイムライブラリが置かれています。
C言語ベースのプロジェクトには libgcc.a を、
C++ベースのプロジェクトには libgcc.a と libstdc++.a をリンクする必要があります。

>:warning:
>必ず xdev68k/lib/m68k_elf 以下のランタイムライブラリを利用してください。
>xdev68k/m68k-toolchain 以下にも同名ファイルが存在しますが、これらは X68K のオブジェクトファイルとはリンクできません。
>従来の X68K 移植版 gcc に含まれたランタイムライブラリもリンク可能ですが、互換性が無いため動作保証はありません。

ランタイムライブラリは複数種類あり、アプリケーションのビルド設定に合致するものを選択して利用します。

* xdev68k/lib/m68k_elf/m68000/*.a  
	MC68000 の命令セットで構成されています。
	全世代の X680x0 で動作可能な実行ファイルを作成する場合にリンクします。
	FPU 非搭載 X68030 環境も、こちらをリンクしてください。

* xdev68k/lib/m68k_elf/m68020/*.a  
	MC68020 の命令セット + FPU の MC68881 命令セットで構成されています。
	FPU 搭載 X68030 で動作可能な実行ファイルを作成する場合にリンクします。
	FPU 非搭載 X68030 では動作しないのでご注意ください。
	また、MC68040 以降の内蔵 FPU には存在しない浮動小数演算命令（FMOVECR 等々）を含む可能性があるため、
	MC68040 / MC68060 等の環境では動作保証がないことにご注意ください。

* xdev68k/lib/m68k_elf/m68040/*.a  
	MC68040 の命令セットで構成されています。
	68040 アクセラレータを搭載した X680x0 で動作可能な実行ファイルを作成する場合にリンクします。

* xdev68k/lib/m68k_elf/m68060/*.a  
	MC68060 の命令セットで構成されています。
	68060 アクセラレータを搭載した X680x0 で動作可能な実行ファイルを作成する場合にリンクします。


## ランタイムライブラリのリビルド手順

ランタイムライブラリはビルド済みの状態で本リポジトリの xdev68k/lib 以下に含まれており、
ユーザーの手でビルドする必要はありません。
もし何らかの事情でリビルドする必要がある場合は、ホスト環境の bash コンソール上でディレクトリ xdev68k に移動し、
以下を実行します。
```bash
./build_x68k-libgcc.sh -m68000 -m68020 -m68040 -m68060  
./build_x68k-libstdc++.sh -m68000 -m68020 -m68040 -m68060  
```
ビルドに成功すると、コンソールに以下のように出力されます。
```bash
The building process is completed successfully.
```
ディレクトリ build_libgcc/ および build_libstdc++/ は中間ファイルです。
ビルド完了後は削除していただいても問題ありません。


## 従来の X68K 対応コンパイラとの互換性問題

従来の X68K 対応コンパイラ（SHARP C Compiler PRO-68K や gcc 真里子版）と最新の m68k-elf-gcc の間には互換性問題があります。  
※gcc2 Charlie版、gcc2.95.2 等との互換性については検証しきれていません。

### 1. ABI が一致しない
ABI とは Application Binary Interface の略で、
データ型のメモリ上での配置や関数コール時の引数や戻り値の受け渡しルールを定義したものです。
従来の X68K 対応コンパイラと最新の m68k-elf-gcc の間では ABI が一致しません。
そのため、古いコンパイラで作成されたバイナリを再コンパイルせずリンクする場合に問題になります。

* 破壊レジスタの違い（回避可能）  
	従来の X68K 対応コンパイラと最新の m68k-elf-gcc の間で、関数呼び出し時の破壊レジスタが異なります。
	```
	SHARP C Compiler PRO-68K、gcc 真里子版 : d0-d2/a0-a2/fp0-fp1  
	m68k-elf-gcc                           : d0-d1/a0-a1/fp0-fp1  
	```
	この問題は、m68k-elf-gcc 側にコンパイルオプション -fcall-used-d2 -fcall-used-a2 を指定することで解消されます。

* 戻り値を格納するレジスタの違い（回避可能）  
	X68K の ABI は、MC680x0 の慣例に従い、関数の戻り値は d0 レジスタに格納するルールになっていました。
	一方、最新の gcc では、configure によっては戻り値を a0 レジスタにも格納します。
	これは、malloc() のようにポインタを返すことが明らかな関数の場合、
	アドレスレジスタに戻り値を返せばオーバーヘッドを回避できる、という考え方に基づくものです。
	しかし実際には、安全性と互換性のため a0 d0 双方に同一の値を返すという運用になっており、
	逆にオーバーヘッド発生源になっています。
	そして、結果を a0 レジスタから読むコードが生成されることにより、過去のソフトウェア資産が再利用できなくなっています。
	
	この問題を避けるには、
	関数の戻り値を d0 レジスタのみに格納する configure でビルドされた gcc を利用する必要があります。
	「環境構築手順」で示したとおり、
	build_m68k-toolchain.sh を利用していれば問題ありませんが、
	バイナリ配布されているビルド済み gcc
	（例えば Linux のディストリビューターが提供している m68k-linux-gnu-gcc のようなもの）
	を利用する場合は注意が必要です。

* long long 型のエンディアンの違い（回避不能）  
	64 bit 整数型である long long 型のバイナリ表現が、
	従来の X68K 対応コンパイラと m68k-elf-gcc とで異なります。
	```
	SHARP C Compiler PRO-68K、gcc 真里子版 : 下位 32bit、上位 32bit の順に格納（つまりビッグエンディアン配置でない）  
	m68k-elf-gcc                           : 上位 32bit、下位 32bit の順に格納（厳密にビッグエンディアン配置）  
	```
	現状ではこの問題の回避策はありません。
	（幸い、過去のソフトウェア資産上に long long 型が出現することは少なく、問題に発展することは稀。
	少なくとも、SHARP C Compiler PRO-68K のヘッダには出現しない。）

* long double 型のビット幅の違い（回避不能）  
	拡張倍精度浮動小数型である long double 型のバイナリ表現が、
	従来の X68K 対応コンパイラと m68k-elf-gcc とで異なります。
	```
	SHARP C Compiler PRO-68K、gcc 真里子版 : long double ＝ 8 bytes 型（double 型互換）  
	m68k-elf-gcc                           : long double ＝ 12 bytes 型  
	※gcc2 Charlie版 も 12 bytes 型とのことです。  
	```
	現状ではこの問題の回避策はありません。
	（幸い、過去のソフトウェア資産上に long double 型が出現することは少なく、問題に発展することは稀。
	少なくとも、SHARP C Compiler PRO-68K のヘッダには出現しない。）

### 2. NaN Inf 値をキャストする時の挙動が異なる

最新の m68k-elf-gcc では、
コプロセッサを搭載していない環境向けの IEEE754 実装は、
NaN や Inf の取り扱いを端折っており、
IEEE754 の仕様に完全に準拠していません。

この問題に遭遇する典型的な例は float → double 変換で、
NaN や Inf の float 値を double に変換すると、不正な有限値になってしまいます。
この変換を行っているのは、libgcc のソース fpgnulib.c に含まれる __extendsfdf2 という関数です。
NaN や Inf の float → double 変換は、
コンパイル時に解決される時はコンパイラ内部の IEEE754 仕様に合致した方法で処理されるため正しい結果になり、
実行時に解決される時は __extendsfdf2 で処理されるため間違った結果になります。
コンパイル時に解決されるかどうかは、
gcc の気持ち次第（inline 指定された関数を実際に inline するか否かなど）で変化するため、
結果を確実に予測することは不可能です。

printf フォーマットで引数をスタックに詰む時、コンパイラは float を double 値に変換します。
そのため float 値を printf で確認したいケースでこの問題によく遭遇します。
実例として、最新の m68k-elf-gcc 上で NaN Inf を発生させ、printf 関数で出力した結果を示します。
```
Inf (1.0f/0.0f を計算させて生成)
	バイナリ表現      : 0x7F800000（IEEE754 の Inf としては正しい）
	printf による出力 : 340282366920940000000000000000000000000.000000（正しくない）
NaN (0.0f/0.0f を計算させて生成)
	バイナリ表現      : 0xFFFFFFFF（IEEE754 の NaN としては正しい）
	printf による出力 : -680564693277060000000000000000000000000.000000（正しくない）
```

従来の X68K 対応コンパイラ（SHARP C Compiler PRO-68K、gcc 真里子版）ではこのような問題は起きませんでした。
同様のコードを gcc 真里子版 でコンパイルし実行した結果を示します。

```
Inf (1.0f/0.0f を計算させて生成)
	バイナリ表現      : 0x7FFFFFFF
	printf による出力 : #NAN.000000（正しい）
NaN (0.0f/0.0f を計算させて生成)
	バイナリ表現      : 0x7FFFFFFF
	printf による出力 : #NAN.000000 （正しい）
```

## C/C++ 標準ヘッダの競合問題
include 指定されたヘッダファイルは、
コンパイラに -I オプションで指定した検索パス上で見つかればそのファイルが include され、
見つからない場合は、m68k-toolchain 上に存在するファイルが include されます。
例として、xdev68k/example/ のサンプルコードのように、-I オプションで SHARP C Compiler PRO-68K (XC) のパスを指定した場合、
次のような動作となります。
```C
※良い例
#include <stdbool.h>    // XC には含まれないので m68k-toolchain 側が読まれる
#include <stdint.h>     // XC には含まれないので m68k-toolchain 側が読まれる
#include <stdlib.h>     // XC 側が読まれる
#include <stdio.h>      // XC 側が読まれる
```
この動作は、新しい世代の C 標準ヘッダファイルを部分的に取り込む場合には便利です。
しかし一方で、これが原因で、
古いソフトウェア資産に由来する C/C++ 標準ヘッダファイルと、
m68k-toolchain 上に存在する新しい世代の C/C++ 標準ヘッダファイルとの間で混同や競合が発生し、
問題となる場合があります。
```C
※悪い例
#include <iostream> // XC には含まれないので m68k-toolchain 側が読まれる。
                    // iostream が include するヘッダが一部 XC 側から読まれる（混同）。
                    // その結果、大量のコンパイルエラーが出力される。
```
この問題を回避するには、
m68k-elf-gcc の世代と流儀にあった C 標準ヘッダおよびライブラリ（最新の glibc、BSD lib または newlib のようなもの）が必要です。
現状ではそれらは未整備であり、この問題の回避策はありません。



## 推奨される利用スタイル

以上をまとめると、m68k-elf-gcc の推奨される利用スタイルは以下のようになります。

1. build_m68k-toolchain.sh で自力ビルドした m68k-elf-gcc を利用する。
2. m68k-elf-gcc 側に -fcall-used-d2 -fcall-used-a2 を指定する。
3. 過去の資産を再コンパイルせず利用する場合は、long long 型、long double 型 を含まないものに限定する。
4. NaN や Inf を別の型にキャストするときは、正しく処理されない可能性を考慮する。
5. C/C++ 標準ヘッダファイルの利用は、古い世代のヘッダと新しい世代のヘッダで競合が起きないものに限定する。


## SHARP C Compiler PRO-68K 以外のライブラリ環境を利用する

install_xdev68k-utils.sh は、
ライブラリ環境として SHARP C Compiler PRO-68K をインストールしますが、
これは xdev68k のデフォルトのライブラリ環境に過ぎず、
ユーザー側で任意のものに差し替え可能です。
ライブラリ環境の差し替えは、
コンパイラに与えるヘッダ検索パスと、
リンク時のライブラリファイル指定を変更するだけで可能です。
xdev68k/example/ のサンプルコードを例に説明すると、makefile 上などで以下のようにします。
```bash
# ヘッダ検索パス
INCLUDE_FLAGS = （ここに -I に続けて差し替え先のヘッダ検索パスを書く）

(中略)

# リンク対象のライブラリファイル
LIBS =\
	（ここに差し替え先のライブラリ群を書く） \
	${XDEV68K_DIR}/lib/m68k_elf/m68000/libgcc.a \
	${XDEV68K_DIR}/lib/m68k_elf/m68000/libstdc++.a \
```


## xdev68k によるコンパイル速度について

### 1. ホスト環境によるコンパイル速度の違い
xdev68k によるコンパイル速度は、ホストとなる Unix 互換環境の種類によって異なります。
各環境のコンパイル速度を比較すると、おおむね以下のような傾向になります。
```bash
linuxネイティブ >>> WSL(linuxパス上) > msys == cygwin >> WSL(windowsパス上) 
※mac上でのコンパイル速度は未評価です
```

### 2. 並列コンパイルによる高速化
xdev68k によるコンパイル時間は、make の並列実行によって劇的に短縮されます。
並列実行は、単に make コマンドに -j オプションで並列度を指定するだけ可能です。
例えば物理 8 コアあるホスト環境では、以下のように実行すると良いでしょう。
```bash
# CPU 8 コアで並列コンパイル
# 一般に 物理コア数+1 を指定するのが最速とされているが、
# コンパイル中 PC がモッサリ動作になるのを避けるため、
# ここでは 物理コア数 をそのまま利用している。
# お好みに合わせて適宜調整すること。 
make -j8
```
make コマンドのオプションは、環境変数 MAKEFLAGS に指定しておけば、毎回コマンドライン引数として与える必要はありません。
またホスト環境の物理コア数は、Unix 互換環境なら /proc/cpuinfo から採取可能です。
従って、bashrc（msys の場合、C:/msys64/home/ユーザー名/.bashrc）に以下のような記述を入れておくことで、make の並列度を自動設定可能です。
```bash
# 実行環境の物理コア数から make の並列度を決定する
export MAKEFLAGS=-j$(($(grep cpu.cores /proc/cpuinfo | sort -u | sed 's/[^0-9]//g')))
```

ここで一点注意事項があります。
X68K コマンドラインエミュレータである run68 は、並列実行すると正しく動作しない場合があります。
xdev68k/example/ のサンプルコードでは、この問題を回避するため次のようにしています。
```bash
ATOMIC = perl ${XDEV68K_DIR}/util/atomic.pl
RUN68 = $(ATOMIC) ${XDEV68K_DIR}/run68/run68
HAS = $(RUN68) ${XDEV68K_DIR}/x68k_bin/HAS060.X
HLK = $(RUN68) ${XDEV68K_DIR}/x68k_bin/hlk301.x
```
上記の \$(ATOMIC) は、指定のコマンドラインをシングルスレッド実行する簡易スクリプトです。
HAS や HLK などの X68K コマンドは、必ず $(ATOMIC) を経由した run68 上で実行するようにします。
\$(ATOMIC) を経由することで、残念ながら X68K コマンドだけは並列コンパイルによる高速化の恩恵を受け取ることはできなくなります。
しかし依然として並列コンパイルによる高速化の効果は劇的であり、十分に利用する価値があります。


## XEiJ と連携したデバッグ実行

XEiJ https://stdkmd.net/xeij/ は、M.Kamada さんが作成されているオープンソースの X680x0 エミュレータです。
Java 言語ベースなので様々なプラットフォーム上で実行可能です。
XEiJ はホストマシンの任意のディレクトリを Human68k の起動ドライブにできます。
windows 環境の場合、専用の名前付きパイプを利用することで、
エミュレーション中の X68K に任意のコマンドを実行させることができます。
XEiJ を利用したデバッグは、一般的なクロス開発環境におけるリモート実行を模したような動作となります。
「ターミナルウィンドウ」と呼ばれる機能を利用することで、
デバッグ用の printf ログ等を X68K のメイン画面ではなく、独立したウィンドウ上に出力可能です。

>:warning:
>XEiJ との連携は、現在のところ msys 以外では利用できません。

### デバッグの様子

サンプルコード xdev68k/example/run_xeij 実行中のスクリーンショットです。
左上がデバッグ対象のプログラムの画面、
左下がターミナルウィンドウになります。
画面右側は、実行中のプログラムの解析情報を表示するウィンドウ群です。

![debug_with_xeij](https://user-images.githubusercontent.com/11882108/230971524-56ba9039-d11c-4903-8738-68f743fbabe2.png)


### 環境設定

xdev68k でビルドした結果を XEiJ でデバッグ実行するには、以下のように環境設定を行う必要があります。

1. XEiJ（0.23.04.10以降）のインストール  
	公式サイトから XEiJ のアーカイブをダウンロードし展開します。  
	https://stdkmd.net/xeij/#download  
	XEiJ の環境設定は公式サイトをご参照ください。  
	https://stdkmd.net/xeij/environment.htm  


2. Human68k 起動ドライブの作成  
	X68000 LIBRARY http://retropc.net/x68000/ から
	「Human68k version 3.02 のシステムディスク（HUMAN302.LZH）」http://retropc.net/x68000/software/sharp/human302/
	をダウンロードし展開します。
	展開先のディレクトリ名は何でも良いですが、ここでは説明上 xeij_boot とします。
	```
	xeij_boot/ （以下、HUMAN302.LZH を展開して得られたファイル群）
	├ ASK/
	├ BASIC2/
	├ BIN/
	中略
	├ AUTOECEC.BAT
	以下略
	```
	環境変数 XEIJ_BOOT_DIR にディレクトリ xeij_boot のフルパスを設定します。
	フルパスは、C: 等のドライブ名から始まる windows スタイルではなく、
	/c 等から始まる unix スタイルで指定してください。
	msys の場合、.bashrc で以下のように実行しておきます。
	```bash
	export XEIJ_BOOT_DIR=ディレクトリxeij_bootのフルパス
	```

	続いて、Human68k のファイル名文字数制限（8+3 文字）を緩和するため、
	TwentyOne.x を組み込みます。
	X68000 LIBRARY http://retropc.net/x68000/software/disk/filename/twentyone/ から
	tw136c14.lzh をダウンロードし、ディレクトリ xeij_boot 以下に展開し、
	xeij_boot/CONFIG.SYS に以下のような一行を追加します。
	```
	DEVICE = \tw136c14\TwentyOne.x +TPS
	```
	XEiJ 上の X68K を再起動すると、ファイル名の制限が 18+3 文字に拡張されます。


3. ディレクトリ xdev68k を Human68k 起動ドライブ以下に配置する  
	X68K から xdev68k 関連ファイルが見えるようにするため、
	ディレクトリ xdev68k をディレクトリ xeij_boot 以下に配置する必要があります。
	```
	xeij_boot/ 
	├ xdev68k/ （← ここに配置した）
	├ ASK/
	├ BASIC2/
	├ BIN/
	中略
	├ AUTOECEC.BAT
	以下略
	```

4. XEiJ を起動する  
	ディレクトリ xeij_boot を Human68k の起動ドライブとみなして XEiJ を起動するには、
	ホストマシンのコマンドラインから以下のように実行します。
	```
	java -jar XEiJ.jar -boot=xeij_boot
	```

	XEiJ が起動したら、XEiJ のメインウィンドウ上で 「設定」→「ターミナル」 を選択し、ターミナルウィンドウを開いておきます。
	このウィンドウは、デバッグ用のログ出力ウィンドウ等に使えます。
	他にもデバッグに役立つウィンドウが沢山用意されていますので、開いておきます。


5. XEiJ の設定  
	make コマンドから XEiJ を制御可能にするため、XEiJ の貼り付けパイプ機能を有効化します。

	![xeij_settings](https://user-images.githubusercontent.com/11882108/231141913-1ba22a68-295d-4057-8f52-93811865ef07.png)


6. xdev68k 上でビルド＆デバッグ実行＆中断  
	テストを兼ねて xdev68k のサンプルコードをデバッグ実行します。
	XEiJ を起動し、X68K 側がコマンドラインの入力待ち状態になっていることを確認した上で、
	msys などのコンソール上でサンプルコード xdev68k/example/run_xeij のディレクトリに移動し、
	以下のコマンドを実行します。
	```
	make run_xeij
	```
	ここまでの環境構築がうまく行っていれば、XEiJ 上でサンプルコードが実行されます。
	デバッグを中断するには、ホスト環境（msys など）のコンソール上で Enter キーを押します。
	中断すると、その時点のレジスタの情報、プログラムカウンタ、
	およびプログラムカウンタが指す位置のプログラムコードがターミナルウィンドウ上に出力されます。


### makefile 記述

XEiJ によるデバッグ実行は、makefile に次のような記述を追加することで可能になります。
```
run_xeij : 実行ファイル名
	bash ${XDEV68K_DIR}/util/xeij_remote_debug.sh 実行ファイル名 引数
```
詳しい処理内容はここでは解説しませんので、
xdev68k/util/xeij_remote_debug.sh
の実装をご参照ください。


### 注意点

デバッグ中のプログラムの中断は、
ソフトウェア的に interrupt スイッチ入力を発生させることで強制的に行われます。
このため、割り込み処理を利用したプログラムのような場合、
割り込み停止されないままプログラムが終了されることになり、
その後のシステムの動作が不安定になります。

ゲームで良く使われる VSYNC 割り込み と ラスタ割込み については、
xdev68k 側（xdev68k/util/xeij_remote_debug.sh）でデバッグ開始時と終了時にステートが退避・復活されるので、
上記のような問題は発生しません。


## トラブルシューティング

xdev68k 利用者が遭遇しやすい問題と、その解決方法をまとめます。

* 大きなメモリ領域の malloc に失敗する  
	XC を利用する場合、デフォルト状態では確保可能メモリサイズは 64K バイトまでです。
	これをハードウェア上確保可能な最大サイズに拡張するには、allmem() を実行する必要があります。
	詳しくは example/heap_size をご参照ください。

* 古い世代のコードをコンパイルすると IRTE() が未定義というエラーになる  
	現在の gcc では割り込み関数の記述方法が変わりました。
	詳しくは example/interrupt をご参照ください。

* スーパーバイザモードから復帰するときにエラーが発生する  
	現在の gcc では、スタック一括補正などの最適化が積極的に行われるようになった都合、
	ユーザーモード ⇔ スーパーバイザモード 切り替え時にスタックポインタの整合性が取れなくなる場合があります。
	回避方法など、詳しくは example/b_super をご参照ください。


## 制限事項

現状 xdev68k には多くの制限があります。

* 標準 C ライブラリが未整備  
	xdev68k がデフォルトライブラリ環境としてインストールする SHARP C Compiler PRO-68K ver2.1 は 1990 年頃のものであり、
	ここに含まれる標準 C ライブラリは、現行の C 標準仕様や流儀からかなり乖離したものとなっています。
	この問題を解消するには、
	最新の glibc、BSD lib または newlib のようなものを移植する必要があります。

* IDE 環境との連携機能は未整備  
	xdev68k を、visual studio や Eclipse のような IDE 環境と連携させる仕組みは未整備です。

* C++ の対応は限定的  
	SHARP C Compiler PRO-68K ver2.1 を利用する場合、
	デフォルトコンストラクタ/デストラクタは startup ルーチンで自動実行されないので、
	アプリケーションが自力で行う必要があります。
	例外や RTTI を利用した C++ コードをコンパイルすると、
	x68k_gas2has.pl が未サポートな GAS ディレクティブが出力されるため、アセンブルに失敗します。
	例外および RTTI を無効化するには、以下のコンパイルオプションを指定する必要があります。
	```bash
	-fno-rtti
	-fno-exceptions
	```

* GAS 形式アセンブラコードは gcc が出力する書式のみに対応  
	x68k_gas2has.pl が認識できるのは、GAS 形式アセンブラコードの記述方法のうち、gcc が出力する可能性のある書式のみです。

* inline asm 内に記述可能なアセンブラコードの制限  
	x68k_gas2has.pl はマクロ制御命令（HAS の macro local endm exitm rept irp irpc など）の全ての仕様に対応していません。
	特殊記号（HAS の '&' '!' , '<'～'>' , '%' など）が出現するとパースエラーになります。

* デバッグ情報の出力に未対応  
	デバッグ情報の GAS 形式 → HAS 形式変換が未対応です。
	この制約により、生成された実行ファイルは、デバッガ上でのソースコード閲覧に対応できません。


## 絶賛テスト中

現在、様々な条件での動作テストを行っています。
修正が頻繁に行われています。
当面の間、修正に伴い予告なく互換ブレイクが発生することも予想されますがご了承ください。

ツールチェインの更新頻度は低いですが、
ユーティリティやサンプルコードは頻繁に更新されています。
何か問題に遭遇した時は、
最新版を取得してユーティリティの再インストール（install_xdev68k-utils.sh を実行）で解消する場合があります。
ユーティリティの再インストールだけであれば、数分程度の作業で完了しますので、定期的に実行することをおすすめします。

環境構築時のエラーや、
アセンブラソース変換中のエラーなど、
何かしらの問題に遭遇した場合は、
発生状況や再現コードなどの情報を添えてご報告いただけますと助かります。
（全ての問題を対処している時間的余裕は無いかもしれませんが。）


## 謝辞

xdev68k は、
無償公開されたシャープのソフトウェア、
Free Software Foundation の gcc をはじめとするツールチェイン、
および X68K ユーザーの方々が作成されたソフトウェア資産を利用しています。
それらのソフトウェアを作成公開して下さっている企業、組織、および有志の方々に感謝いたします。

また、xdev68k で利用させていただいた X68K 関連ソフトウェア資産の多くは、
X68000 LIBRARY http://retropc.net/x68000/ からダウンロードさせて頂いています。
HAS060 や XEiJ の作者でもあり、アーカイブを保守されている X68000 LIBRARY の管理者 M.Kamada さんに感謝いたします。

install_xdev68k-utils.sh の *.lhz アーカイブ展開処理で、
LHa for UNIX with Autoconf https://github.com/jca02266/lha/ 
を利用させて頂いています。
LHa for UNIX 原作者の Tsugio Okamoto 氏、
LHa for UNIX with Autoconf 作成者 Koji Arai 氏に感謝いたします。


## ライセンス

* libgcc.a および libstdc++.a  
GNU GENERAL PUBLIC LICENSE Version 3 と、GCC RUNTIME LIBRARY EXCEPTION Version 3.1 が適用されます。
（アーカイブファイルをバイナリ単体で配布するときは GPL 適用になるため、ソースコードまたはその入手手段を開示する必要がある。
アーカイブファイルをアプリケーションにリンクして利用する場合は、アプリケーションに GPL は伝搬しないし、ソース開示などの義務は生じない。）

* install_xdev68k-utils.sh によりダウンロードまたはインストールされたファイル群  
それぞれにライセンスと配布規定が存在します。
詳細は xdev68k/license/readme.txt を参照してください。

* 上記以外  
Apache License Version 2.0 が適用されます。
（MIT ライセンス相当の制約の緩いライセンスであり、
かつパテント・トロール的な第三者による特許取得を抑止することで、
オープンソース利用者が想定外のリスクに晒されることを防止する機能を持つ優れたライセンス。）


