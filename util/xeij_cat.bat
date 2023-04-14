@rem #------------------------------------------------------------------------------
@rem #
@rem #	xeij_cat.bat
@rem #
@rem #	JP:
@rem #		XEiJ 上で実行されている X68K の stdin に指定の文字列を送信します。
@rem #
@rem #	EN:
@rem #		Sends the specified file to stdin on X68K running on XEiJ.
@rem #
@rem #------------------------------------------------------------------------------
@rem #
@rem #	Copyright (C) 2022 Yosshin(@yosshin4004)
@rem #
@rem #	Licensed under the Apache License, Version 2.0 (the "License");
@rem #	you may not use this file except in compliance with the License.
@rem #	You may obtain a copy of the License at
@rem #
@rem #	    http://www.apache.org/licenses/LICENSE-2.0
@rem #
@rem #	Unless required by applicable law or agreed to in writing, software
@rem #	distributed under the License is distributed on an "AS IS" BASIS,
@rem #	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem #	See the License for the specific language governing permissions and
@rem #	limitations under the License.
@rem #
@rem #------------------------------------------------------------------------------

@rem #
@rem # msys などの環境では XEiJ の名前付きパイプに直接アクセスできないが、
@rem # cmd.exe を起動して本バッチを経由することでこの問題を回避できる。
@rem #
@rem # usage:
@rem #	xeij_cat.bat <filename>
@rem #

@type %* > \\.\pipe\XEiJPaste

