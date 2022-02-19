# xdev68k


# 解説

xdev68k は、SHARP X68K シリーズ対応のクロス開発環境です。
最新の gcc を用いて X68K 対応の実行ファイルが作成可能です。
ホスト環境は、msys2+mingw、cygwin、WSL 等々の、exe ファイルが実行可能な Unix 互換環境が利用可能です。
（推奨環境は msys2+mingw です。それ以外の環境は十分なテストが行われていません。）

xdev68k は、
クロス開発環境をダウンロード＆ビルド＆インストールするスクリプトと、
補助ツールで構成されています。

xdev68k は、
旧プロジェクトである x68k_gcc_has_converter（ https://github.com/yosshin4004/x68k_gcc_has_converter ）から発展したものです。
旧プロジェクトは終了し、本プロジェクトに統合されました。


# 環境構築手順

1. Unix 互換環境のインストールと環境構築（作業時間 : 1 時間程度）  
msys2+mingw、cygwin、WSL 等々の、exe ファイルが実行可能な Unix 互換環境を用意します。
推奨環境は msys2+mingw です。
msys2 のインストーラは https://www.msys2.org/ から入手可能です。
gcc や perl 等、基本的な開発ツールをインストールしておきます。
msys2 の場合は以下のように実行します。
	```bash
	pacman -S base-devel
	pacman -S mingw-w64-i686-toolchain
	pacman -S mingw-w64-x86_64-toolchain
	```

2. xdev68k を取得（作業時間 : 1 分程度）  
本リポジトリを clone します。
以降、ディレクトリ xdev68k に clone された前提で説明を進めます。

3. クロスコンパイラ作成（作業時間 : 数時間）  
十分なディスク容量（10GB 程度）があることを確認した上で、
ホスト環境の bash コンソール上でディレクトリ xdev68k に移動し、以下のコマンドを実行します。
	```bash
	build_m68k-toolchain.sh
	```
	xdev68k/m68k-toolchain 以下に、Motorola 680x0 シリーズ対応のクロスコンパイラである m68k-elf-gcc が構築されます。
	以下のメッセージがコンソールに出力されれば完了です。
	```
	The building process is completed successfully.
	```

4. ユーティリティのインストール（作業時間 : 5 分程度）  
ホスト環境の bash コンソール上で、先ほどと同じディレクトリ（xdev68k）から以下のコマンドを実行します。
	```bash
	install_xdev68k-utils.sh
	```
	クロスコンパイル環境で必要になるユーティリティの実行ファイル、ヘッダおよびライブラリがインストールされます。
	以下のメッセージがコンソールに出力されれば完了です。
	```
	The installation process is completed successfully.
	Please set the current directory path to environment variable XDEV68K_DIR.
	```



5. 環境変数設定（作業時間 : 1 分程度）  
環境変数 XDEV68K_DIR に、ディレクトリ xdev68k のフルパスを設定します。
msys2 の場合、C:/msys64/home/ユーザー名/.bashrc に次のように記述しておくと良いでしょう。
	```bash
	export XDEV68K_DIR=ディレクトリxdev68kのフルパス
	```

# ファイル構成

正しく環境構築が完了した状態のディレクトリ構造は以下のようになります。
```
xdev68k/
│
├ archive/
│	│	ダウンロードした外部ツールのアーカイブファイル
│	├ readme.txt
│	│		原作者、入手元の情報、利用規約をまとめたテキスト
│	└  *.zip *.lzh
│			原本のアーカイブファイル
├ build_gcc/
│		クロスコンパイラのソースコードとビルドにより生成された中間ファイル群
│		このディレクトリ以下には 18 万近いファイルが存在する。削除しても問題ない。
├ example/
│		クロス開発サンプルコード
├ include/
│	│	ヘッダファイル
│	└ xc/
│			SHARP C Compiler PRO-68K ver2.1 のヘッダファイル
│			Copyright 1990,91,92 SHARP/Hudson
├ m68k-toolchain/
│		クロスコンパイラのビルド結果
├ run68/
│		X68K コマンドラインエミュレータ run68 Version 0.09
│		originally programmed by Ｙｏｋｋｏさん、maintained by masamic さん Chack’n さん
├ lib/
│	│	ライブラリファイル
│	├ xc/
│	│		SHARP C Compiler PRO-68K ver2.1 のライブラリファイル
│	│		Copyright 1990,91,92 SHARP/Hudson
│	└ m68k_elf/
│		│
│		├ license/
│		│		libgcc のライセンス情報とソースコードパッケージ
│		└ m68000/ m68020/ m68040/ m68060/ 
│				各種 CPU 構成ごとの libgcc.a
├ util/
│	│
│	└ x68k_gas2has.pl
│			GAS to HAS コンバータ
│			Copyright (C) 2022 Yosshin
├ x68k_bin/
│	│	X68K のコマンドラインユーティリティ
│	├ AR.X
│	│		X68k Archiver v1.00
│	│		Copyright 1987 SHARP/Hudson
│	├ HAS060.X
│	│		High-speed Assembler 68060 対応版 version 3.09+89
│	│		原作者:Y.Nakamura さん、作者:M.Kamada さん
│	└ hlk.r
│			HLK evolution version 3.01+14
│			原作者:SALT さん、作者:立花えり子さん
├ build_m68k-toolchain.sh
│		クロスコンパイラのビルドスクリプト
├ build_x68k-libgcc.sh
│		libgcc のビルドスクリプト
└ install_xdev68k-utils.sh
		環境構築スクリプト
```

# Hello World サンプルの実行

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


# コンパイル～実行ファイル生成までの詳細

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
	HAS="${XDEV68K_DIR}/run68/run68.exe ${XDEV68K_DIR}/x68k_bin/HAS060.X"
	${HAS} -e -u -w0 -I${XDEV68K_DIR}/include/xc -o main.o main.s
	```
	カレントディレクトリにオブジェクトファイル main.o が生成されます。

4. リンク  
main.o を X68K 対応リンカ hlk.r でリンクします。
リンカの実行は、X68K コマンドラインエミュレータ run68 で行います。
本リポジトリに含まれている libgcc.a をリンクする必要があります。
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
	HLK="${XDEV68K_DIR}/run68/run68.exe ${XDEV68K_DIR}/x68k_bin/hlk.r"
	${HLK} -Llk_tmp/ -o MAIN.X -i lk_list.txt
	```
	カレントディレクトリに実行ファイル MAIN.X が生成されます。


# GAS 形式 → HAS 形式変換例

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

# libgcc.a の種類と用途

ディレクトリ xdev68k/lib/m68k_elf 以下には、
gcc のランタイムライブラリである libgcc.a が置かれています。
m68k-elf-gcc で生成したコードには、これを必ずリンクする必要があります。

>:warning:
>必ず xdev68k/lib/m68k_elf 以下の libgcc.a を利用してください。
>xdev68k/m68k-toolchain 以下の libgcc.a は X68K のオブジェクトファイルとリンクできません。
>従来の X68K 移植版 gcc に含まれた libgcc.a もリンク可能ですが、互換性が無いため動作保証はありません。

libgcc.a は複数種類あり、アプリケーションのビルド設定に合致するものを選択して利用します。

* xdev68k/lib/m68k_elf/m68000/libgcc.a  
	MC68000 の命令セットで構成されています。
	全世代の X680x0 で動作可能な実行ファイルを作成する場合にリンクします。
	FPU 非搭載 X68030 環境も、こちらをリンクしてください。

* xdev68k/lib/m68k_elf/m68020/libgcc.a  
	MC68020 の命令セット + FPU の MC68881 命令セットで構成されています。
	FPU 搭載 X68030 で動作可能な実行ファイルを作成する場合にリンクします。
	FPU 非搭載 X68030 では動作しないのでご注意ください。
	また、MC68040 以降の内蔵 FPU には存在しない浮動小数演算命令（FMOVECR 等々）を含む可能性があるため、
	MC68040 / MC68060 等の環境では動作保証がないことにご注意ください。

* xdev68k/lib/m68k_elf/m68040/libgcc.a  
	MC68040 の命令セットで構成されています。
	68040 アクセラレータを搭載した X680x0 で動作可能な実行ファイルを作成する場合にリンクします。

* xdev68k/lib/m68k_elf/m68060/libgcc.a  
	MC68060 の命令セットで構成されています。
	68060 アクセラレータを搭載した X680x0 で動作可能な実行ファイルを作成する場合にリンクします。


# libgcc.a のリビルド手順

libgcc.a はビルド済みの状態で本リポジトリの xdev68k/lib 以下に含まれており、
ユーザーの手でビルドする必要はありませんが、
もし何らかの事情でリビルドする必要がある場合は、ホスト環境の bash コンソール上でディレクトリ xdev68k に移動し、
以下を実行します。
```bash
build_x68k-libgcc.sh -m68000 -m68020 -m68040 -m68060  
```
ビルドに成功すると、コンソールに以下のように出力されます。
```bash
The building process is completed successfully.
```
ディレクトリ build_libgcc/ 以下は中間ファイルです。
ビルド完了後は削除しても問題ありません。


# 従来のコンパイラとの互換性問題

従来の X68K 対応コンパイラと最新の m68k-elf-gcc の間には互換性問題があります。

## 1. ABI が一致しない
ABI とは Application Binary Interface の略で、
データ型のメモリ上での配置や関数コール時の引数や戻り値の受け渡しルールを定義したものです。
従来の X68K 対応コンパイラと最新の m68k-elf-gcc の間では ABI が一致しません。
そのため、古いコンパイラで作成されたバイナリを再コンパイルせずリンクする場合に問題になります。

* 破壊レジスタの違い（回避可能）  
	```
	従来の X68K 対応コンパイラ : d0-d2/a0-a2/fp0-fp1  
	m68k-elf-gcc               : d0-d2/a0-a2/fp0-fp1  
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

* long long 型（回避不能）  
	64 bit 整数型である long long 型のバイナリ表現が、
	従来の X68K 対応コンパイラと m68k-elf-gcc とで異なります。
	```
	従来の X68K 対応コンパイラ : 下位 32bit、上位 32bit の順に格納（つまりビッグエンディアン配置でない）  
	m68k-elf-gcc               : 上位 32bit、下位 32bit の順に格納（厳密にビッグエンディアン配置）  
	```
	現状ではこの問題の回避策はありません。
	（幸い、過去のソフトウェア資産上に long long 型が出現することは少なく、問題に発展することは稀。
	少なくとも、SHARP C Compiler PRO-68K のヘッダには出現しない。）

* long double 型（回避不能）  
	拡張倍精度浮動小数型である long double 型のバイナリ表現が、
	従来の X68K 対応コンパイラと m68k-elf-gcc とで異なります。
	```
	従来の X68K 対応コンパイラ : long double ＝ 8 bytes 型（double 型互換）  
	m68k-elf-gcc               : long double ＝ 12 bytes 型  
	```
	現状ではこの問題の回避策はありません。
	（幸い、過去のソフトウェア資産上に long double 型が出現することは少なく、問題に発展することは稀。
	少なくとも、SHARP C Compiler PRO-68K のヘッダには出現しない。）

## 2. NaN Inf 互換性問題
最新の m68k-elf-gcc では、NaN や Inf のバイナリ表現は一般的なコンパイラ上での扱いと同様です。
一方 X68K の古いソフトウェア資産上では、NaN や Inf 等を扱うコードが、フルスペックの実装になってない場合があります。
これが原因で、最新の m68k-elf-gcc が出力した NaN や Inf 等が、古いソフトウェア資産上で正しく機能しない場合があります。

この問題の再現例を示します。
まず、
従来の X68K 対応コンパイラ（古い X68K 移植版 gcc）で NaN Inf を発生させ、
これらを SHARP C Compiler PRO-68K（XC）の CLIB.L に含まれる printf 関数で出力した結果を示します。
```
Inf (1.0f/0.0f を計算させて生成)
	バイナリ表現      : 0x7FFFFFFF
	printf による出力 : #NAN.000000
NaN (0.0f/0.0f を計算させて生成)
	バイナリ表現      : 0x7FFFFFFF
	printf による出力 : #NAN.000000 
```
次に、
最新の m68k-elf-gcc 上で NaN Inf を発生させ、
これらを先ほどと同様に SHARP C Compiler PRO-68K（XC）の CLIB.L に含まれる printf 関数で出力した結果を示します。
```
Inf (1.0f/0.0f を計算させて生成)
	バイナリ表現      : 0x7F800000（IEEE754 の Inf としては正しい）
	printf による出力 : 340282366920940000000000000000000000000.000000（正しくない）
NaN (0.0f/0.0f を計算させて生成)
	バイナリ表現      : 0xFFFFFFFF（IEEE754 の NaN としては正しい）
	printf による出力 : -680564693277060000000000000000000000000.000000（正しくない）
```
後者では NaN Inf が正しく表示されていません。


## 3. LIBC シンボル衝突問題
X68K には ANSI-C 対応の基本ライブラリである LIBC（作者:Project LIBC Group）が存在しました。

LIBC には、
その当時の X68K 対応 gcc 付属の ligbcc に含まれていなかった一部の数学関数（___cmpdf2）が収録されていました。
これが、最新の m68k-elf-gcc 対応 libgcc では libgcc 側に収録されているため、
リンク時にシンボルが衝突します。


# 推奨される利用スタイル

以上を踏まえて、m68k-elf-gcc の推奨される利用スタイルをまとめます。

1. build_m68k-toolchain.sh で自力ビルドした m68k-elf-gcc を利用する。
2. m68k-elf-gcc 側に -fcall-used-d2 -fcall-used-a2 を指定する。
3. 本リポジトリに含まれている libgcc.a を利用する。
4. 過去の資産を再コンパイルせず利用する場合は、long long 型、long double 型 を含まないものに限る。
5. NaN や Inf を古いコードに入力する場合、正しく処理されない可能性を考慮する。


# その他の制限事項

現状多くの制限があります。

* c++ には対応していません  
	現状では未テストです。
	c++ 対応のランタイムライブラリが未整備のため、実行ファイルが生成できません。

* GAS 形式アセンブラコードは gcc が出力する書式のみに対応  
	x68k_gas2has.pl が認識できるのは、GAS 形式アセンブラコードの記述方法のうち、gcc が出力する可能性のある書式のみです。

* inline asm 内に記述可能なアセンブラコードの制限  
	x68k_gas2has.pl はマクロ制御命令（HAS の macro local endm exitm rept irp irpc など）の全ての仕様に対応していません。
	特殊記号（HAS の '&' '!' , '<'～'>' , '%' など）が出現するとパースエラーになります。


# 絶賛テスト中

現在、様々な条件での動作テストを行っています。
修正が頻繁に行われています。
当面の間、修正に伴い予告なく互換ブレイクが発生することも予想されますがご了承ください。

環境構築時のエラーや、
アセンブラソース変換中のエラーなど、
何かしらの問題に遭遇した場合は、
エラーを起こした該当行の情報等を添えてご報告いただけますと助かります。
（全ての問題を対処している時間的余裕は無いかもしれませんが。）


# 謝辞

xdev68k のクロス開発環境は、
無償公開されたシャープのソフトウェア、
Free Software Foundation の成果物、
および X68K ユーザーの方々が作成されたフリーソフトウェアの上に成り立っています。
それらのソフトウェアを作成公開して下さっている企業、組織、および有志の方々に感謝いたします。


# ライセンス

* x68k_gas2has.pl / build_m68k-toolchain.sh / build_x68k-libgcc.sh / install_xdev68k-utils.sh  
Apache License Version 2.0 が適用されます。

* libgcc.a  
GNU GENERAL PUBLIC LICENSE Version 3 と、GCC RUNTIME LIBRARY EXCEPTION Version 3.1 が適用されます。
（libgcc.a をバイナリ単体で配布するときは GPL 適用になるため、ソースコードまたはその入手手段を開示する必要がある。
libgcc.a をアプリケーションにリンクして利用する場合は、アプリケーションに GPL は伝搬しないし、ソース開示などの義務は生じない。）

* install_xdev68k-utils.sh によりダウンロードまたはインストールされたファイル群  
それぞれにライセンスと配布規定が存在します。
詳細は xdev68k/archive/readme.txt を参照してください。


