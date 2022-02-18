xdev68k に含まれるソフトウェア、および利用させて頂いているソフトウェアの
出典元とライセンス情報をまとめます。


・binutils

	オリジナルアーカイブファイル
		build_gcc/download/binutils-2.35.tar.bz2

	xdev68k 上のインストール先
		xdev68k/m68k-toolchain/

	原作者
		Free Software Foundation, Inc.

	入手元
		https://ftp.gnu.org/gnu/binutils/

	利用規約
		GNU GENERAL PUBLIC LICENSE が適用されます。
		ライセンス原文は、オリジナルアーカイブファイルに含まれています。


・gcc

	オリジナルアーカイブファイル
		build_gcc/download/gcc-10.2.0.tar.gz

	xdev68k 上のインストール先
		xdev68k/m68k-toolchain/

	原作者
		Free Software Foundation, Inc.

	入手元
		https://gcc.gnu.org/pub/gcc/releases/

	利用規約
		GNU GENERAL PUBLIC LICENSE が適用されます。
		ライセンス原文は、オリジナルアーカイブファイルに含まれています。


・libgcc

	オリジナルアーカイブファイル
		build_gcc/download/gcc-10.2.0.tar.gz
			gcc のフルパッケージ
		xdev68k/archive/libgcc_src.tar.gz
			gcc のフルパッケージから、libgcc.a が依存するソースファイルだけを
			抜粋したもの。

	xdev68k 上のインストール先
		xdev68k/lib/m68k_elf/

	原作者
		Free Software Foundation, Inc.

	入手元
		https://gcc.gnu.org/pub/gcc/releases/

	利用規約
		GNU GENERAL PUBLIC LICENSE と GCC RUNTIME LIBRARY EXCEPTION が適用
		されます。ライセンス原文は、xdev68k/license/libgcc/ 以下にあります。
		（libgcc.a をバイナリ単体で配布するときは GPL 適用になるため、ソース
		コードまたはその入手手段を開示する必要がある。libgcc.a をアプリケー
		ションにリンクして利用する場合は、アプリケーションに GPL は伝搬
		しないし、ソース開示などの義務も生じない。）


・newlib

	オリジナルアーカイブファイル
		build_gcc/download/newlib-3.3.0.tar.gz

	xdev68k 上のインストール先
		xdev68k/m68k-toolchain/

	原作者
		オリジナルアーカイブファイルの COPYING.NEWLIB を参照してください。

	入手元
		ftp://sourceware.org/pub/newlib/

	利用規約
		オリジナルアーカイブファイルの COPYING.NEWLIB を参照してください。


・run68 Version 0.09a

	オリジナルアーカイブファイル
		xdev68k/archive/
			run68bin-009a-20090920.zip
			run68-code-r68-trunk.zip（ソースコード）

	xdev68k 上のインストール先
		xdev68k/run68/
			run68bin-009a-20090920.zip から取得した run68.exe が置かれて
			います。

	原作者
		originally programmed by Ｙｏｋｋｏ さん

	作者
		maintained by masamic さん, Chack'n さん

	入手元
		Run68 Support Pages（消失）
			http://pws.prserv.net/run68/
		Run68 Support Pages からリンクされていた公式配布 URL
			https://sourceforge.net/projects/run68/

	利用規約
		GNU GENERAL PUBLIC LICENSE が適用されます。
		ライセンス原文は、オリジナルアーカイブファイルに含まれています。


・C Compiler PRO-68K ver2.1（XC）

	オリジナルアーカイブファイル
		xdev68k/archive/
			XC2101.LZH
			XC2102.LZH

	xdev68k 上のインストール先
		xdev68k/include/xc/
			XC2102.LZH に含まれる INCLUDE/ 以下のファイルを取得し、小文字
			ファイル名化と、ファイル末尾の EOF 除去を行いました。
		xdev68k/lib/xc/
			XC2102.LZH に含まれる LIB/ 以下のファイルをコピーしました。
		xdev68k/x68k_bin
			XC2101.LZH に含まれる AR.X をコピーしました。

	提供元
		シャープ株式会社

	入手元
		公式配布元サイトは存在しません。
		以下の URL から転載されたアーカイブが入手可能です。
		http://retropc.net/x68000/software/sharp/xc21/

	利用規約
		xdev68k/license/FSHARP/許諾条件.txt に従ってください。


・無償公開された XC システムディスク 2 の修正パッチ

	オリジナルアーカイブファイル
		xdev68k/archive/
			XC2102A.LZH

	xdev68k 上のインストール先
		xdev68k/include/xc/
			XC2101A.LZH に含まれる INCLUDE/ 以下のファイルを取得し、小文字
			ファイル名化と、ファイル末尾の EOF 除去を行いました。

	作者
		M.Kamada さん

	入手元
		以下の URL からアーカイブが入手可能です。
		http://retropc.net/x68000/software/sharp/xc21/xc2102a/

	利用規約
		xdev68k/license/FSHARP/許諾条件.txt に従ってください。


・High-speed Assembler 68060 対応版 version 3.09+89

	オリジナルアーカイブファイル
		xdev68k/archive/
			HAS06089.LZH

	xdev68k 上のインストール先
		xdev68k/x68k_bin
			HAS06089.LZH から取り出した HAS060.X をコピーしています。

	原作者
		Y.Nakamura さん

	作者
		M.Kamada さん

	入手元
		以下の URL からアーカイブが入手可能です。
		http://retropc.net/x68000/software/develop/as/has060/

	利用規約
		HAS06089.LZH に含まれる README.DOC に従ってください。


・HLK evolution version 3.01+14

	オリジナルアーカイブファイル
		xdev68k/archive/
			HLKEV14.ZIP

	xdev68k 上のインストール先
		xdev68k/x68k_bin
			HLKEV14.ZIP から取り出した hlk.r をコピーしています。

	原作者
		SALT さん

	作者
		立花えり子さん

	入手元
		公式配布元サイトは存在しません。
		以下の URL から転載されたアーカイブが入手可能です。
		http://retropc.net/x68000/software/develop/lk/hlkev/

	利用規約
		HLKEV14.ZIP に含まれる hlkev.doc に従ってください。


・上記以外

	作者
		Yosshin

	入手元
		https://github.com/yosshin4004

	利用規約
		Apache License, Version 2.0 が適用されます。
		ライセンスの原文は、
			xdev68k/license/xdev68k/LICENSE
		です。



