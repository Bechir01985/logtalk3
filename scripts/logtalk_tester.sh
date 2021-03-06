#!/usr/bin/env bash

#############################################################################
## 
##   Unit testing automation script
##   Last updated on December 3, 2018
## 
##   This file is part of Logtalk <https://logtalk.org/>  
##   Copyright 1998-2019 Paulo Moura <pmoura@logtalk.org>
##   
##   Licensed under the Apache License, Version 2.0 (the "License");
##   you may not use this file except in compliance with the License.
##   You may obtain a copy of the License at
##   
##       http://www.apache.org/licenses/LICENSE-2.0
##   
##   Unless required by applicable law or agreed to in writing, software
##   distributed under the License is distributed on an "AS IS" BASIS,
##   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##   See the License for the specific language governing permissions and
##   limitations under the License.
## 
#############################################################################

# loosely based on a unit test automation script contributed by Parker Jones

print_version() {
	echo "$(basename "$0") 0.33"
	exit 0
}

operating_system=$(uname -s)

if [ "${operating_system:0:10}" == "MINGW32_NT" ] || [ "${operating_system:0:10}" == "MINGW64_NT" ] ; then
	# assume that we're running on Windows using the Git for Windows bash shell
	extension='.sh'
elif [ "$LOGTALKHOME" != "" ] && [ "$LOGTALKUSER" != "" ] && [ "$LOGTALKHOME" == "$LOGTALKUSER" ] ; then
	# assume that we're running Logtalk without using the installer scripts
	extension='.sh'
else
	extension=''
fi

# first, make sure that we don't peak Windows own timeout command, which is not usable for this purpose
if [[ "$(command -v timeout)" == *"System32"* ]] || [[ "$(command -v timeout)" == *"system32"* ]] ; then
	timeout_command=""
# second, look for GNU coreutils package timeout command
elif [ -x "$(command -v timeout)" ] && [[ "$(timeout --version)" == *"GNU coreutils"* ]] ; then
	timeout_command="timeout -k 1"
elif [ -x "$(command -v gtimeout)" ] && [[ "$(gtimeout --version)" == *"GNU coreutils"* ]] ; then
	timeout_command="gtimeout -k 1"
else
	timeout_command=""
fi

# testing goals

versions_goal="logtalk_load(library(tester_versions)),halt"
versions_goal_dot="logtalk_load(library(tester_versions)),halt."

tester_optimal_goal="set_logtalk_flag(optimize,on),logtalk_load(tester),halt"
tester_optimal_goal_dot="set_logtalk_flag(optimize,on),logtalk_load(tester),halt."

tester_normal_goal="logtalk_load(tester),halt"
tester_normal_goal_dot="logtalk_load(tester),halt."

tester_debug_goal="set_logtalk_flag(debug,on),logtalk_load(tester),halt"
tester_debug_goal_dot="set_logtalk_flag(debug,on),logtalk_load(tester),halt."

format_default_goal="true"
format_tap_goal="logtalk_load(lgtunit(tap_report))"
format_xunit_goal="logtalk_load(lgtunit(xunit_report))"

coverage_default_goal="true"
coverage_xml_goal="logtalk_load(lgtunit(coverage_report))"

# default argument values

base="$PWD"
level=""
results="$base/logtalk_tester_logs"
backend=swi
prolog='SWI-Prolog'
logtalk=swilgt$extension
logtalk_call="$logtalk -g"
mode='normal'
format='default'
coverage='none'
format_goal=$format_default_goal
coverage_goal=$coverage_default_goal
flag_goal="true"
initialization_goal="true"
# disable timeouts to maintain backward compatibility
timeout=0
prefix="$HOME/"

# use GNU sed if available instead of BSD sed
if gsed --version >/dev/null 2>&1 ; then
	sed="gsed"
else
	sed="sed"
fi

run_tests() {
	unit=$(dirname "$1")
	unit_short=${unit#$prefix}
	cd "$unit" || exit 1
	echo '*******************************************************************************'
	echo "***** Testing $unit_short"
	if [ -f tester.sh ] ; then
		if [ $# -eq 0 ] ; then
			source tester.sh -p $backend
		else
			source tester.sh "$@"
		fi
		source_exit=$?
		if [ "$source_exit" -gt 0 ] ; then
			echo "*****         source tester.sh returned code $source_exit"
			echo '*******************************************************************************'
			exit 9
		fi
	fi
	name=${unit////__}
	if [ $mode == 'optimal' ] || [ $mode == 'all' ] ; then
		run_test "$name" "$initialization_goal,$format_goal,$coverage_goal,$flag_goal,$tester_optimal_goal"
		tests_exit=$?
		grep -a 'tests:' "$results/$name.results" | $sed 's/%/***** (opt)  /'
	elif [ $mode == 'normal' ] || [ $mode == 'all' ] ; then
		run_test "$name" "$initialization_goal,$format_goal,$coverage_goal,$flag_goal,$tester_normal_goal"
		tests_exit=$?
		grep -a 'tests:' "$results/$name.results" | $sed 's/%/*****        /'
	elif [ $mode == 'debug' ] || [ $mode == 'all' ] ; then
		run_test "$name" "$initialization_goal,$format_goal,$coverage_goal,$flag_goal,$tester_debug_goal"
		tests_exit=$?
		grep -a 'tests:' "$results/$name.results" | $sed 's/%/***** (debug)/'
	fi
	if [ $tests_exit -eq 0 ] ; then
		grep -a 'out of' "$results/$name.results" | grep -a 'clause coverage' | $sed 's/%/*****        /'
		grep -a 'no code coverage information collected' "$results/$name.results" | $sed 's/%/*****        /'
		grep -a '(not applicable)' "$results/$name.results" | $sed 's/(/*****         (/'
	elif [ $tests_exit -eq 124 ] ; then
		echo "*****         timeout"
		echo "LOGTALK_TIMEOUT" >> "$results/$name.errors"
	else
		echo "*****         crash"
		echo "LOGTALK_CRASH" >> "$results/$name.errors"
	fi
	if [ $coverage == 'xml' ] ; then
		if [ -d "$LOGTALKUSER" ] ; then
			cp "$LOGTALKUSER/tools/lgtunit/coverage_report.dtd" . || true
			cp "$LOGTALKUSER/tools/lgtunit/coverage_report.xsl" . || true
		elif [ -d "$LOGTALKHOME" ] ; then
			cp "$LOGTALKHOME/tools/lgtunit/coverage_report.dtd" . || true
			cp "$LOGTALKHOME/tools/lgtunit/coverage_report.xsl" . || true
		fi
	fi
	return 0
}

run_test() {
	name="$1"
	goal="$2"
	if [ ${#args[@]} -eq 0 ] ; then
		if [ "$timeout_command" != "" ] && [ $timeout -ne 0 ] ; then
			$timeout_command $timeout $logtalk_call "$goal" < /dev/null > "$results/$name.results" 2> "$results/$name.errors"
		else
			$logtalk_call "$goal" < /dev/null > "$results/$name.results" 2> "$results/$name.errors"
		fi
	else
		if [ "$timeout_command" != "" ] && [ $timeout -ne 0 ] ; then
			$timeout_command $timeout $logtalk_call "$goal" -- "${args[@]}" < /dev/null > "$results/$name.results" 2> "$results/$name.errors"
		else
			$logtalk_call "$goal" -- "${args[@]}" < /dev/null > "$results/$name.results" 2> "$results/$name.errors"
		fi
	fi
	exit=$?
	if [ $exit -eq 0 ] && ! grep -q "(not applicable)" "$results/$name.results" && ! grep -q "tests:" "$results/$name.results" && ! grep -q "tests skipped" "$results/$name.results"; then
		echo "LOGTALK_BROKEN" >> "$results/$name.errors"
	fi
	return $exit
}

usage_help()
{
	echo 
	echo "This script automates running unit tests found in the current directory"
	echo "and recursively in its sub-directories by scanning for \"tester.logtalk\""
	echo "and \"tester.lgt\" source files. In case of failed unit tests or test set"
	echo "errors, this script returns a non-zero exit code."
	echo
	echo "Usage:"
	echo "  $(basename "$0") [-p prolog] [-m mode] [-f format] [-d results] [-t timeout] [-s prefix] [-c report] [-l level] [-- arguments]"
	echo "  $(basename "$0") -v"
	echo "  $(basename "$0") -h"
	echo
	echo "Optional arguments:"
	echo "  -v print version of $(basename "$0")"
	echo "  -p backend Prolog compiler (default is $backend)"
	echo "     (valid values are b, cx, eclipse, gnu, ji, lean, qp, sicstus, swi, swipack, xsb, xsbmt, and yap)"
	echo "  -m compilation mode (default is $mode)"
	echo "     (valid values are optimal, normal, debug, and all)"
	echo "  -f format for writing the test results (default is $format)"
	echo "     (valid values are default, tap, and xunit)"
	echo "  -d directory to store the test logs (default is ./logtalk_tester_logs)"
	echo "  -t timeout in seconds for running each test set (default is $timeout; i.e. disabled)"
	echo "  -s suppress path prefix (default is $prefix)"
	echo "  -c code coverage report (default is $coverage)"
	echo "     (valid values are none and xml)"
	echo "  -l directory depth level to look for test sets (default is to recurse into all sub-directories)"
	echo "     (level 1 means current directory only)"
	echo "  -g initialization goal (default is $initialization_goal)"
	echo "  -- arguments to be passed to the integration script used to run the tests (no default)"
	echo "  -h help"
	echo
}

while getopts "vp:m:f:d:t:s:c:l:g:h" option
do
	case $option in
		v) print_version;;
		p) p_arg="$OPTARG";;
		m) m_arg="$OPTARG";;
		f) f_arg="$OPTARG";;
		d) d_arg="$OPTARG";;
		t) t_arg="$OPTARG";;
		s) s_arg="$OPTARG";;
		c) c_arg="$OPTARG";;
		l) l_arg="$OPTARG";;
		g) g_arg="$OPTARG";;
		h) usage_help; exit;;
		*) usage_help; exit;;
	esac
done

shift $((OPTIND - 1))
args=("$@")

if [ "$p_arg" == "b" ] ; then
	backend=b
	prolog='B-Prolog'
	logtalk=bplgt$extension
	logtalk_call="$logtalk -g"
elif [ "$p_arg" == "cx" ] ; then
	backend=cx
	prolog='CxProlog'
	logtalk=cxlgt$extension
	logtalk_call="$logtalk --goal"
elif [ "$p_arg" == "eclipse" ] ; then
	backend=eclipse
	prolog='ECLiPSe'
	logtalk=eclipselgt$extension
	logtalk_call="$logtalk -e"
elif [ "$p_arg" == "gnu" ] ; then
	backend=gnu
	prolog='GNU Prolog'
	logtalk=gplgt$extension
	logtalk_call="$logtalk --query-goal"
elif [ "$p_arg" == "ji" ] ; then
	backend=ji
	prolog='JIProlog'
	logtalk=jiplgt$extension
	logtalk_call="$logtalk -n -g"
elif [ "$p_arg" == "lean" ] ; then
	backend=lean
	prolog='Lean Prolog'
	logtalk=lplgt$extension
	logtalk_call="$logtalk"
elif [ "$p_arg" == "qp" ] ; then
	backend=qp
	prolog='Qu-Prolog'
	logtalk=qplgt$extension
	logtalk_call="$logtalk -g"
	versions_goal=$versions_goal_dot
	tester_optimal_goal=$tester_optimal_goal_dot
	tester_normal_goal=$tester_normal_goal_dot
	tester_debug_goal=$tester_debug_goal_dot
elif [ "$p_arg" == "sicstus" ] ; then
	backend=sicstus
	prolog='SICStus Prolog'
	logtalk=sicstuslgt$extension
	logtalk_call="$logtalk --goal"
	versions_goal=$versions_goal_dot
	tester_optimal_goal=$tester_optimal_goal_dot
	tester_normal_goal=$tester_normal_goal_dot
	tester_debug_goal=$tester_debug_goal_dot
elif [ "$p_arg" == "swi" ] ; then
	backend=swi
	prolog='SWI-Prolog'
	logtalk=swilgt$extension
	logtalk_call="$logtalk -g"
elif [ "$p_arg" == "swipack" ] ; then
	backend=swipack
	prolog='SWI-Prolog'
	logtalk=swipl
	logtalk_call="$logtalk -g"
elif [ "$p_arg" == "xsb" ] ; then
	backend=xsb
	prolog='XSB'
	logtalk=xsblgt$extension
	logtalk_call="$logtalk -e"
	versions_goal=$versions_goal_dot
	tester_optimal_goal=$tester_optimal_goal_dot
	tester_normal_goal=$tester_normal_goal_dot
	tester_debug_goal=$tester_debug_goal_dot
elif [ "$p_arg" == "xsbmt" ] ; then
	backend=xsbmt
	prolog='XSB-MT'
	logtalk=xsbmtlgt$extension
	logtalk_call="$logtalk -e"
	versions_goal=$versions_goal_dot
	tester_optimal_goal=$tester_optimal_goal_dot
	tester_normal_goal=$tester_normal_goal_dot
	tester_debug_goal=$tester_debug_goal_dot
elif [ "$p_arg" == "yap" ] ; then
	backend=yap
	prolog='YAP'
	logtalk=yaplgt$extension
	logtalk_call="$logtalk -g"
elif [ "$p_arg" != "" ] ; then
	echo "Error! Unsupported backend Prolog compiler: $p_arg" >&2
	usage_help
	exit 1
elif [ ! "$(command -v $logtalk)" ] ; then
	echo "Error! $logtalk integration script for $prolog not found." >&2
	echo "       Check that its directory is in your execution path." >&2
	exit 1
fi

if [ "$m_arg" == "optimal" ] ; then
	mode='optimal'
elif [ "$m_arg" == "normal" ] ; then
	mode='normal'
elif [ "$m_arg" == "debug" ] ; then
	mode='debug'
elif [ "$m_arg" == "all" ] ; then
	mode='all'
elif [ "$m_arg" != "" ] ; then
	echo "Error! Unknow compilation mode: $m_arg" >&2
	usage_help
	exit 1
fi

if [ "$f_arg" == "default" ] ; then
	format='default'
	format_goal=$format_default_goal
elif [ "$f_arg" == "tap" ] ; then
	format='tap'
	format_goal=$format_tap_goal
elif [ "$f_arg" == "xunit" ] ; then
	format='xunit'
	format_goal=$format_xunit_goal
elif [ "$f_arg" != "" ] ; then
	echo "Error! Unknow format: $f_arg" >&2
	usage_help
	exit 1
fi

if [ "$c_arg" == "none" ] ; then
	coverage='none'
	coverage_goal=$coverage_default_goal
elif [ "$c_arg" == "xml" ] ; then
	coverage='xml'
	coverage_goal=$coverage_xml_goal
elif [ "$c_arg" != "" ] ; then
	echo "Error! Unknow coverage report: $c_arg" >&2
	usage_help
	exit 1
fi

if [ "$p_arg" == "swipack" ] ; then
	versions_goal="use_module(library(logtalk)),$versions_goal"
	format_goal="use_module(library(logtalk)),$format_goal"
fi

if [ "$d_arg" != "" ] ; then
	results="$d_arg"
fi

if [ "$t_arg" != "" ] ; then
	timeout="$t_arg"
fi

if [ "$s_arg" != "" ] ; then
	prefix="$s_arg"
fi

if [ "$l_arg" != "" ] ; then
	if [[ "$l_arg" =~ ^[1-9][0-9]*$ ]] ; then
		level="-maxdepth $l_arg"
	else
		echo "Error! Level must be an integer equal or greater than 1: $l_arg" >&2
		usage_help
		exit 1
	fi
fi

if [ "$g_arg" != "" ] ; then
	initialization_goal="$g_arg"
fi

if [ "$timeout_command" == "" ] ; then
	echo "Warning! Timeout support not available. The timeout option will be ignored." >&2
fi

if [[ "$prefix" != "" && ("$format" != "default" || "$coverage" != "none") ]] ; then
	flag_goal="set_logtalk_flag(suppress_path_prefix,'$prefix')"
else
	flag_goal="true"
fi

mkdir -p "$results"
rm -f "$results"/*.results
rm -f "$results"/*.errors
rm -f "$results"/errors.all
rm -f "$results"/tester_versions.txt

start_date=$(eval date \"+%Y-%m-%d %H:%M:%S\")

echo '*******************************************************************************'
echo "***** Batch testing started @ $start_date"
$logtalk_call $versions_goal > "$results"/tester_versions.txt 2> /dev/null
grep -a "Logtalk version:" "$results"/tester_versions.txt
grep -a "Prolog version:" "$results"/tester_versions.txt | $sed "s/Prolog/$prolog/"

testsets=0
output="$(find "$base" $level -name "tester.lgt" -or -name "tester.logtalk" | LC_ALL=C sort)"
while read -r file && [ "$file" != "" ]; do
	((testsets++))
	run_tests "$file"
done <<< "$output"

cd "$results" || exit 1
testsetskipped=$(cat -- *.results | grep -c 'tests skipped')
timeouts=$(cat -- *.errors | grep -c 'LOGTALK_TIMEOUT')
crashes=$(cat -- *.errors | grep -c 'LOGTALK_CRASH')
broken=$(cat -- *.errors | grep -c 'LOGTALK_BROKEN')
testsetruns=$((testsets-timeouts-crashes-broken))
skipped=$(cat -- *.results | grep -c ': skipped')
passed=$(cat -- *.results | grep -c ': success')
failed=$(cat -- *.results | grep -c ': failure')
total=$((skipped+passed+failed))

echo "*******************************************************************************"
echo "***** Compilation errors/warnings and failed unit tests"
echo "***** (compilation errors/warnings might be expected depending on the test)"
echo "*******************************************************************************"
grep -s -a -A2 'syntax_error' -- *.results | $sed 's/.results//' | tee errors.all
grep -s -a -A2 'syntax_error' -- *.errors | $sed 's/.errors//' | tee -a errors.all
grep -s -a -h '!     ' -- *.errors | $sed 's/.errors//' | tee -a errors.all
grep -s -a -h '!     ' -- *.results | $sed 's/.results//' | tee -a errors.all
grep -s -a -h -F '*     ' -- *.errors | $sed 's/.errors//' | tee -a errors.all
grep -s -a -h -F '*     ' -- *.results | $sed 's/.results//' | tee -a errors.all
echo "*******************************************************************************"
echo "***** Skipped"
echo "*******************************************************************************"
grep -s -a 'tests skipped' -- *.results | $sed 's/% tests skipped//' | $sed 's/.results://' | $sed 's|__|/|g' | $sed "s|^$prefix||"
echo "*******************************************************************************"
echo "***** Broken"
echo "*******************************************************************************"
grep -s -a 'LOGTALK_BROKEN' -- *.errors | $sed 's/LOGTALK_BROKEN//' | $sed 's/.errors://' | $sed 's|__|/|g' | $sed "s|^$prefix||"
echo "*******************************************************************************"
echo "***** Timeouts"
echo "*******************************************************************************"
grep -s -a 'LOGTALK_TIMEOUT' -- *.errors | $sed 's/LOGTALK_TIMEOUT//' | $sed 's/.errors://' | $sed 's|__|/|g' | $sed "s|^$prefix||"
echo "*******************************************************************************"
echo "***** Crashes"
echo "*******************************************************************************"
grep -s -a 'LOGTALK_CRASH' -- *.errors | $sed 's/LOGTALK_CRASH//' | $sed 's/.errors://' | $sed 's|__|/|g' | $sed "s|^$prefix||"
echo "*******************************************************************************"
echo "***** Skipped tests"
echo "*******************************************************************************"
grep -s -a ': skipped' -- *.results | $sed 's/: skipped//' | $sed 's/.results:% / - /' | $sed 's|__|/|g' | $sed "s|^$prefix||" | $sed "s|^% ||"
echo "*******************************************************************************"
echo "***** Failed tests"
echo "*******************************************************************************"
grep -s -a ': failure' -- *.results | $sed 's/: failure//' | $sed 's/.results:!     / - /' | $sed 's|__|/|g' | $sed "s|^$prefix||" | $sed "s|^!     ||"
echo "*******************************************************************************"
echo "***** $testsets test sets: $testsetruns completed, $testsetskipped skipped, $broken broken, $timeouts timeouts, $crashes crashes"
echo "***** $total tests: $skipped skipped, $passed passed, $failed failed"
echo "*******************************************************************************"

end_date=$(eval date \"+%Y-%m-%d %H:%M:%S\")

echo "***** Batch testing ended @ $end_date"
echo '*******************************************************************************'

if [ "$crashes" -gt 0 ] ; then
	exit 7
elif [ "$broken" -gt 0 ] ; then
	exit 5
elif [ "$timeouts" -gt 0 ] ; then
	exit 3
elif [ "$failed" -gt 0 ] ; then
	exit 1
else
	exit 0
fi
