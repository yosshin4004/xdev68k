*-----------------------------------------------------------------------------
* このファイルは、Project C Library の LIBC 1.1.32A (libc32b.tgz)
* に含まれていた iocscall.mac を複製し、拡張子を inc にリネームしたものです。
*
* SHARP の XC コンパイラに含まれる iocscall.mac の定義は、IOCSLIB.L に含まれる
* シンボルと衝突するため、様々な問題を引き起こします。
* Project C Library 版に含まれる iocscall.mac は、この問題を回避するため、
* iocscall 番号の定義に __ で開始するシンボルを利用しています。
* 
* xdev68k では安全のため Project C Library 版の iocscall.mac を利用します。
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
* $Id: iocscall.mac,v 1.5 1993/10/06 16:44:09 mura Exp $
*

		.nlist

__B_KEYINP	equ		$00
__B_KEYSNS	equ		$01
__B_SFTSNS	equ		$02
__BITSNS	equ		$04
__SKEYSET	equ		$05
__TVCTRL	equ		$0c
__LEDMOD	equ		$0d
__TGUSEMD	equ		$0e
__DEFCHR	equ		$0f
__CRTMOD	equ		$10
__CONTRAST	equ		$11
__HSVTORGB	equ		$12
__TPALET	equ		$13
__TPALET2	equ		$14
__TCOLOR	equ		$15
__FNTADR	equ		$16
__VRAMGET	equ		$17
__VRAMPUT	equ		$18
__FNTGET	equ		$19
__TEXTGET	equ		$1a
__TEXTPUT	equ		$1b
__CLIPPUT	equ		$1c
__SCROLL	equ		$1d
__B_CURON	equ		$1e
__B_CUROFF	equ		$1f
__B_PUTC	equ		$20
__B_PRINT	equ		$21
__B_COLOR	equ		$22
__B_LOCATE	equ		$23
__B_DOWN_S	equ		$24
__B_UP_S	equ		$25
__B_UP		equ		$26
__B_DOWN	equ		$27
__B_RIGHT	equ		$28
__B_LEFT	equ		$29
__B_CLR_ST	equ		$2a
__B_ERA_ST	equ		$2b
__B_INS		equ		$2c
__B_DEL		equ		$2d
__B_CONSOL	equ		$2e
__B_PUTMES	equ		$2f
__SET232C	equ		$30
__LOF232C	equ		$31
__INP232C	equ		$32
__ISNS232C	equ		$33
__OSNS232C	equ		$34
__OUT232C	equ		$35
__JOYGET	equ		$3b
__INIT_PRN	equ		$3c
__SNSPRN	equ		$3d
__OUTLPT	equ		$3e
__OUTPRN	equ		$3f
__B_SEEK	equ		$40
__B_VERIFY	equ		$41
__B_READDI	equ		$42
__B_DSKINI	equ		$43
__B_DRVSNS	equ		$44
__B_WRITE	equ		$45
__B_READ	equ		$46
__B_RECALI	equ		$47
__B_ASSIGN	equ		$48
__B_WRITED	equ		$49
__B_READID	equ		$4a
__B_BADFMT	equ		$4b
__B_READDL	equ		$4c
__B_FORMAT	equ		$4d
__B_DRVCHK	equ		$4e
__B_EJECT	equ		$4f
__DATEBCD	equ		$50
__DATESET	equ		$51
__TIMEBCD	equ		$52
__TIMESET	equ		$53
__DATEGET	equ		$54
__DATEBIN	equ		$55
__TIMEGET	equ		$56
__TIMEBIN	equ		$57
__DATECNV	equ		$58
__TIMECNV	equ		$59
__DATEASC	equ		$5a
__TIMEASC	equ		$5b
__DAYASC	equ		$5c
__ALARMMOD	equ		$5d
__ALARMSET	equ		$5e
__ALARMGET	equ		$5f
__ADPCMOUT	equ		$60
__ADPCMINP	equ		$61
__ADPCMAOT	equ		$62
__ADPCMAIN	equ		$63
__ADPCMLOT	equ		$64
__ADPCMLIN	equ		$65
__ADPCMSNS	equ		$66
__ADPCMMOD	equ		$67
__OPMSET	equ		$68
__OPMSNS	equ		$69
__OPMINTST	equ		$6a
__TIMERDST	equ		$6b
__VDISPST	equ		$6c
__CRTCRAS	equ		$6d
__HSYNCST	equ		$6e
__PRNINTST	equ		$6f
__MS_INIT	equ		$70
__MS_CURON	equ		$71
__MS_CUROF	equ		$72
__MS_STAT	equ		$73
__MS_GETDT	equ		$74
__MS_CURGT	equ		$75
__MS_CURST	equ		$76
__MS_LIMIT	equ		$77
__MS_OFFTM	equ		$78
__MS_ONTM	equ		$79
__MS_PATST	equ		$7a
__MS_SEL	equ		$7b
__MS_SEL2	equ		$7c
__SKEY_MOD	equ		$7d
__DENSNS	equ		$7e
__ONTIME	equ		$7f
__B_INTVCS	equ		$80
__B_SUPER	equ		$81
__B_BPEEK	equ		$82
__B_WPEEK	equ		$83
__B_LPEEK	equ		$84
__B_MEMSTR	equ		$85
__B_BPOKE	equ		$86
__B_WPOKE	equ		$87
__B_LPOKE	equ		$88
__B_MEMSET	equ		$89
__DMAMOVE	equ		$8a
__DMAMOV_A	equ		$8b
__DMAMOV_L	equ		$8c
__DMAMODE	equ		$8d
__BOOTINF	equ		$8e
__ROMVER	equ		$8f
__G_CLR_ON	equ		$90
__GPALET	equ		$94
__SFTJIS	equ		$a0
__JISSFT	equ		$a1
__AKCONV	equ		$a2
__RMACNV	equ		$a3
__DAKJOB	equ		$a4
__HANJOB	equ		$a5
__B_CONMOD	equ		$ad	* enhanced by iocs.x
__OS_CURON	equ		$ae
__OS_CUROF	equ		$af
__DRAWMODE	equ		$b0	* enhanced by iocs.x
__APAGE		equ		$b1
__VPAGE		equ		$b2
__HOME		equ		$b3
__WINDOW	equ		$b4
__WIPE		equ		$b5
__PSET		equ		$b6
__POINT		equ		$b7
__LINE		equ		$b8
__BOX		equ		$b9
__FILL		equ		$ba
__CIRCLE	equ		$bb
__PAINT		equ		$bc
__SYMBOL	equ		$bd
__GETGRM	equ		$be
__PUTGRM	equ		$bf
__SP_INIT	equ		$c0
__SP_ON		equ		$c1
__SP_OFF	equ		$c2
__SP_CGCLR	equ		$c3
__SP_DEFCG	equ		$c4
__SP_GTPCG	equ		$c5
__SP_REGST	equ		$c6
__SP_REGGT	equ		$c7
__BGSCRLST	equ		$c8
__BGSCRLGT	equ		$c9
__BGCTRLST	equ		$ca
__BGCTRLGT	equ		$cb
__BGTEXTCL	equ		$cc
__BGTEXTST	equ		$cd
__BGTEXTGT	equ		$ce
__SPALET	equ		$cf
__TXXLINE	equ		$d3
__TXYLINE	equ		$d4
__TXLINE	equ		$d5	* enhanced by iocs.x
__TXBOX		equ		$d6
__TXFILL	equ		$d7
__TXREV		equ		$d8
__TXRASCPY	equ		$df
__OPMDRV	equ		$f0	* enhanced by opmdrv.sys
__RSDRV		equ		$f1	* enhanced by rsdrv.sys
__A_JOY		equ		$f2	* enhanced by ajoy.x
__ABORTRST	equ		$fd
__IPLERR	equ		$fe
__ABORTJOB	equ		$ff

__S_RESET	equ		$00
__S_SELECT	equ		$01
__S_CMDOUT	equ		$03
__S_DATAIN	equ		$04
__S_DATAOUT	equ		$05
__S_STSIN	equ		$06
__S_MSGIN	equ		$07
__S_MSGOUT	equ		$08
__S_PHASE	equ		$09
__S_DATAIN_P	equ		$0B	* undefined
__S_DATAOUT_P	equ		$0C	* undefined
__S_INQUIRY	equ		$20
__S_READ	equ		$21
__S_WRITE	equ		$22
__S_FORMAT	equ		$23
__S_TESTUNIT	equ		$24
__S_READCAP	equ		$25
__S_READEXT	equ		$26
__S_WRITEEXT	equ		$27
__S_VERIFY	equ		$28	* undefined
__S_MODESENSE	equ		$29	* undefined
__S_MODESELECT	equ		$2A	* undefined
__S_REZEROUNIT	equ		$2B
__S_REQUEST	equ		$2C
__S_SEEK	equ		$2D
__S_STARTSTOP	equ		$2F
__S_REASSIGN	equ		$31
__S_PAMEDIUM	equ		$32

SCSI		macro		func
		moveq.l		#$f5,d0
		moveq.l		#func,d1
		trap		#15
		endm

IOCS		macro		number
		moveq.l		#number,d0
		trap		#15
		endm

		.list
