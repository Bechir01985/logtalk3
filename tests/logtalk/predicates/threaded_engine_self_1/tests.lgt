%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  This file is part of Logtalk <http://logtalk.org/>
%  Copyright 1998-2016 Paulo Moura <pmoura@logtalk.org>
%  
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%  
%      http://www.apache.org/licenses/LICENSE-2.0
%  
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- object(tests,
	extends(lgtunit)).

	:- info([
		version is 1.0,
		author is 'Paulo Moura',
		date is 2016/05/31,
		comment is 'Unit tests for the threaded_engine_self/1 built-in predicate.'
	]).

	:- threaded.

	succeeds(threaded_engine_fetch_1_01) :-
		threaded_engine_create(none, return, test_engine_1),
		threaded_engine_answer(test_engine_1, Engine),
		Engine == test_engine_1.

	% calls outside the context of an engine fail
	fails(threaded_engine_self_1_02) :-
		threaded_engine_self(_).

	% auxiliary predicates

	return :-
		threaded_engine_self(Engine),
		threaded_engine_return(Engine).

:- end_object.