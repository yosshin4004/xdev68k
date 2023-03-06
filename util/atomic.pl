#!/usr/bin/perl
#------------------------------------------------------------------------------
#
#	atomic.pl
#
#	JP:
#		指定のコマンドラインをシングルスレッド実行する。
#
#	EN:
#		Executes the specified command line by single-thread.
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2022 Yosshin(@yosshin4004)
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#	    http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#
#------------------------------------------------------------------------------

# コーディングを厳格化
use strict;

# 使用するモジュール
use IO::File;
use FindBin;
use Fcntl ':flock';

# コマンドライン
my $command_line = join(' ', @ARGV);

# lock ファイルを open して排他ロック 
my $fh_lock_txt = IO::File->new("$FindBin::Bin/atomic.lock", "r");
flock($fh_lock_txt, LOCK_EX);

# コマンドライン実行
my $exit_code = system($command_line);

# ロック解除
$fh_lock_txt->close();

# 終了コードを返して終了
exit $exit_code;
