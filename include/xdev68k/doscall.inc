*-----------------------------------------------------------------------------
* このファイルは、Project C Library の LIBC 1.1.32A (libc32b.tgz)
* に含まれていた doscall.mac を複製し、拡張子を inc にリネームしたものです。
*
* SHARP の XC コンパイラに含まれる doscall.mac の定義は、DOSLIB.L に含まれる
* シンボルと衝突するため、様々な問題を引き起こします。
* Project C Library 版に含まれる doscall.mac は、この問題を回避するため、
* doscall 番号の定義に __ で開始するシンボルを利用しています。
* 
* xdev68k では安全のため Project C Library 版の doscall.mac を利用します。
* また、ファイル名の混同を避けるため、拡張子を inc にリネームしています。
*
*
* オリジナルファイルは以下の URL から入手可能です。
* http://retropc.net/x68000/software/develop/lib/libc1132a/
* このファイルのライセンスはオリジナルと同様 public domain とします。
* 以下、オリジナルファイルをそのまま収録いたします。
*-----------------------------------------------------------------------------

* -*-Fundamental-*-
*
* PROJECT C Library, X68000 PROGRAMMING INTERFACE DEFINITION
* --------------------------------------------------------------------
* This file is written by the Project C Library Group,  and completely
* in public domain. You can freely use, copy, modify, and redistribute
* the whole contents, without this notice.
* --------------------------------------------------------------------
* $Id: doscall.mac,v 1.5 1993/10/06 16:43:41 mura Exp $
*

		.nlist

__EXIT		equ		$ff00
__GETCHAR	equ		$ff01
__PUTCHAR	equ		$ff02
__COMINP	equ		$ff03
__COMOUT	equ		$ff04
__PRNOUT	equ		$ff05
__INPOUT	equ		$ff06
__INKEY		equ		$ff07
__GETC		equ		$ff08
__PRINT		equ		$ff09
__GETS		equ		$ff0a
__KEYSNS	equ		$ff0b
__KFLUSH	equ		$ff0c
__FFLUSH	equ		$ff0d
__CHGDRV	equ		$ff0e
__CHDRV		equ		$ff0e
__DRVCTRL	equ		$ff0f
__CONSNS	equ		$ff10
__PRNSNS	equ		$ff11
__CINSNS	equ		$ff12
__COUTSNS	equ		$ff13
__FATCHK	equ		$ff17
__HENDSP	equ		$ff18
__CURDRV	equ		$ff19
__GETSS		equ		$ff1a
__FGETC		equ		$ff1b
__FGETS		equ		$ff1c
__FPUTC		equ		$ff1d
__FPUTS		equ		$ff1e
__ALLCLOSE	equ		$ff1f
__SUPER		equ		$ff20
__FNCKEY	equ		$ff21
__KNJCTRL	equ		$ff22
__CONCTRL	equ		$ff23
__KEYCTRL	equ		$ff24
__INTVCS	equ		$ff25
__PSPSET	equ		$ff26
__GETTIM2	equ		$ff27
__SETTIM2	equ		$ff28
__NAMESTS	equ		$ff29
__GETDATE	equ		$ff2a
__SETDATE	equ		$ff2b
__GETTIME	equ		$ff2c
__SETTIME	equ		$ff2d
__VERIFY	equ		$ff2e
__DUP0		equ		$ff2f
__VERNUM	equ		$ff30
__KEEPPR	equ		$ff31
__GETDPB	equ		$ff32
__BREAKCK	equ		$ff33
__DRVXCHG	equ		$ff34
__INTVCG	equ		$ff35
__DSKFRE	equ		$ff36
__NAMECK	equ		$ff37
__MKDIR		equ		$ff39
__RMDIR		equ		$ff3a
__CHDIR		equ		$ff3b
__CREATE	equ		$ff3c
__OPEN		equ		$ff3d
__CLOSE		equ		$ff3e
__READ		equ		$ff3f
__WRITE		equ		$ff40
__DELETE	equ		$ff41
__SEEK		equ		$ff42
__CHMOD		equ		$ff43
__IOCTRL	equ		$ff44
__DUP		equ		$ff45
__DUP2		equ		$ff46
__CURDIR	equ		$ff47
__MALLOC	equ		$ff48
__MFREE		equ		$ff49
__SETBLOCK	equ		$ff4a
__EXEC		equ		$ff4b
__EXIT2		equ		$ff4c
__WAIT		equ		$ff4d
__FILES		equ		$ff4e
__NFILES	equ		$ff4f

.ifdef		__HUMAN_V2__

__SETPDB	equ		$ff50
__GETPDB	equ		$ff51
__SETENV	equ		$ff52
__GETENV	equ		$ff53
__VERIFYG	equ		$ff54
__COMMON	equ		$ff55
__RENAME	equ		$ff56
__FILEDATE	equ		$ff57
__MALLOC2	equ		$ff58
__MAKETMP	equ		$ff5a
__NEWFILE	equ		$ff5b
__LOCK		equ		$ff5c
__ASSIGN	equ		$ff5f
__GETFCB	equ		$ff7c
__S_MALLOC	equ		$ff7d
__S_MFREE	equ		$ff7e
__S_PROCESS	equ		$ff7f

.else

__SETPDB	equ		$ff80
__GETPDB	equ		$ff81
__SETENV	equ		$ff82
__GETENV	equ		$ff83
__VERIFYG	equ		$ff84
__COMMON	equ		$ff85
__RENAME	equ		$ff86
__FILEDATE	equ		$ff87
__MALLOC2	equ		$ff88
__MAKETMP	equ		$ff8a
__NEWFILE	equ		$ff8b
__LOCK		equ		$ff8c
__ASSIGN	equ		$ff8f
__GETFCB	equ		$ffac
__S_MALLOC	equ		$ffad
__S_MFREE	equ		$ffae
__S_PROCESS	equ		$ffaf

.endif

__RETSHELL	equ		$fff0
__CTLABORT	equ		$fff1
__ERRABORT	equ		$fff2
__DISKRED	equ		$fff3
__DISKWRT	equ		$fff4
__INDOSFLG	equ		$fff5
__SUPER_JSR	equ		$fff6
__MEMCPY	equ		$fff7
__OPEN_PR	equ		$fff8
__KILL_PR	equ		$fff9
__GET_PR	equ		$fffa
__SUSPEND_PR	equ		$fffb
__SLEEP_PR	equ		$fffc
__SEND_PR	equ		$fffd
__TIME_PR	equ		$fffe
__CHANGE_PR	equ		$ffff

DOS		macro		callname
		dc.w		callname
		endm

		.list
