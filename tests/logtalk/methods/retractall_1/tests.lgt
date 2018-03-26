%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  This file is part of Logtalk <https://logtalk.org/>  
%  Copyright 1998-2018 Paulo Moura <pmoura@logtalk.org>
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


% plain Prolog database for testing calls in the "user" pseudo-object

:- dynamic(bar/1).
bar(1). bar(2).

:- dynamic(baz/1).
baz(1). baz(2).


:- object(tests,
	extends(lgtunit)).

	:- info([
		version is 1.2,
		author is 'Paulo Moura',
		date is 2018/03/24,
		comment is 'Unit tests for the retractall/1 built-in method.'
	]).

	throws(retractall_1_1, error(instantiation_error, logtalk(test_object::retractall(_),_))) :-
		{test_object::retractall(_)}.

	throws(retractall_1_2, error(type_error(callable, 1), logtalk(test_object::retractall(1),_))) :-
		{test_object::retractall(1)}.

	throws(retractall_1_3, error(permission_error(modify, protected_predicate, q/2), logtalk(test_object::retractall(q(_,_)),_))) :-
		{test_object::retractall(q(_,_))}.

	throws(retractall_1_4, error(permission_error(modify, private_predicate, r/3), logtalk(test_object::retractall(r(_,_,_)),_))) :-
		{test_object::retractall(r(_,_,_))}.

	throws(retractall_1_5, error(permission_error(modify, static_predicate, s/4), logtalk(test_object::retractall(s(_,_,_,_)),_))) :-
		{test_object::retractall(s(_,_,_,_))}.

	throws(retractall_1_6, error(existence_error(predicate_declaration, unknown/1), logtalk(test_object::retractall(unknown(_)),_))) :-
		{test_object::retractall(unknown(_))}.

	throws(retractall_1_7, error(instantiation_error, logtalk(_::retractall(foo),_))) :-
		{test_object::ie(_)}.

	throws(retractall_1_8, error(type_error(object_identifier, 1), logtalk(1::retractall(foo),_))) :-
		{test_object::te}.

	succeeds(retractall_1_9) :-
		test_object::retractall(t(3)),
		test_object::t(1),
		t2_head(T2),
		test_object::T2,
		\+ test_object::t(3),
		test_object::retractall(t(_)),
		\+ test_object::t(_).

	succeeds(retractall_1_10) :-
		create_object(Object, [], [public(t/1), dynamic(t/1)], [t(1), (t(2) :-t(1)), (t(3) :-t(1),t(2))]),
		Object::retractall(t(3)),
		Object::t(1),
		t2_head(T2),
		Object::T2,
		\+ Object::t(3),
		Object::retractall(t(_)),
		\+ Object::t(_),
		abolish_object(Object).

	% tests for the "user" pseudo-object

	succeeds(retractall_1_11) :-
		user::retractall(bar(1)),
		{bar(2)}.

	succeeds(retractall_1_12) :-
		bar_clause(Baz),
		user::retractall(Baz),
		\+ {bar(_)}.

	succeeds(retractall_1_13) :-
		% ensure that the unification is not optimized away
		user_object(Object),
		Object::retractall(baz(1)),
		{baz(2)}.

	succeeds(retractall_1_14) :-
		% ensure that the unification is not optimized away
		user_object(Object),
		baz_clause(Baz),
		Object::retractall(Baz),
		\+ {baz(_)}.

	% auxiliary predicates

	t2_head(t(2)).

	bar_clause(bar(2)).

	baz_clause(baz(2)).

	user_object(user).

:- end_object.
