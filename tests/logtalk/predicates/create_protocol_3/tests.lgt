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


:- object(tests,
	extends(lgtunit)).

	:- info([
		version is 1.4,
		author is 'Paulo Moura',
		date is 2018/03/27,
		comment is 'Unit tests for the create_protocol/3 built-in predicate.'
	]).

	throws(create_protocol_3_01, error(instantiation_error, logtalk(create_protocol(_, _, _), _))) :-
		% delay the error to runtime
		{create_protocol(_, _, _)}.

	throws(create_protocol_3_02, error(type_error(protocol_identifier, 1), logtalk(create_protocol(1, [], []), _))) :-
		% delay the error to runtime
		{create_protocol(1, [], [])}.

	throws(create_protocol_3_03, error(permission_error(modify, protocol, monitoring), logtalk(create_protocol(monitoring, [], []), _))) :-
		% delay the error to runtime
		{create_protocol(monitoring, [], [])}.

	throws(create_protocol_3_04, error(permission_error(modify, object, logtalk), logtalk(create_protocol(logtalk, [], []), _))) :-
		% delay the error to runtime
		{create_protocol(logtalk, [], [])}.

	throws(create_protocol_3_05, error(type_error(list, atom), logtalk(create_protocol(_, atom, []), _))) :-
		% delay the error to runtime
		{create_protocol(_, atom, [])}.

	throws(create_protocol_3_06, error(type_error(list, atom), logtalk(create_protocol(_, [], atom), _))) :-
		% delay the error to runtime
		{create_protocol(_, [], atom)}.

	throws(create_protocol_3_07, error(permission_error(modify, dynamic_predicate, foo/1), logtalk(create_protocol(_, [], [dynamic(foo/1), synchronized(foo/1)]), _))) :-
		% delay the error to runtime
		{create_protocol(_, [], [dynamic(foo/1), synchronized(foo/1)])}.

	throws(create_protocol_3_08, error(permission_error(modify, synchronized_predicate, foo/1), logtalk(create_protocol(_, [], [synchronized(foo/1), dynamic(foo/1)]), _))) :-
		% delay the error to runtime
		{create_protocol(_, [], [synchronized(foo/1), dynamic(foo/1)])}.

	throws(create_protocol_3_09, error(permission_error(repeat, entity_relation, extends/1), logtalk(create_protocol(_, [extends(protocol1), extends(protocol2)], []), _))) :-
		% delay the error to runtime
		{create_protocol(_, [extends(protocol1), extends(protocol2)], [])}.

	throws(create_protocol_3_10, error(permission_error(extend, self, _), logtalk(create_protocol(Protocol, [extends(Protocol)], []), _))) :-
		% delay the error to runtime
		{create_protocol(Protocol, [extends(Protocol)], [])}.

	throws(create_protocol_3_11, error(type_error(protocol, Object), logtalk(create_protocol(Protocol, [extends(Object)], []), _))) :-
		create_object(Object, [], [], []),
		% delay the error to runtime
		{create_protocol(Protocol, [extends(Object)], [])}.

	throws(create_protocol_3_12, error(type_error(protocol, Category), logtalk(create_protocol(Protocol, [extends(Category)], []), _))) :-
		create_category(Category, [], [], []),
		% delay the error to runtime
		{create_protocol(Protocol, [extends(Category)], [])}.

:- end_object.
