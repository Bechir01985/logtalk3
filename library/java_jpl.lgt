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


:- object(java(_Reference, _ReturnValue),
	implements((forwarding, java_access_protocol))).

	:- info([
		version is 1.1,
		author is 'Paulo Moura and Sergio Castro',
		date is 2018/05/23,
		comment is 'Minimal abstraction of the JPL API for calling Java from Logtalk using familiar message sending syntax and a forward/1 handler to resolve methods.',
		parameters is [
			'Reference' - 'Either a class name or a Java reference to an object',
			'ReturnValue' - 'Value returned by a method call (possibly the Java value void)'
		]
	]).

	:- use_module(jpl, [
		jpl_get/3, jpl_set/3,
		jpl_new/3,
		jpl_call/4
	]).

	get_field(Field, Value) :-
		parameter(1, ClassOrObject),
		jpl_get(ClassOrObject, Field, Value).

	set_field(Field, Value) :-
		parameter(1, ClassOrObject),
		jpl_set(ClassOrObject, Field, Value).

	new(Parameters, Instance) :- 
		parameter(1, Class),
		jpl_new(Class, Parameters, Instance),
		parameter(2, Instance).

	new(Instance) :- 
		new([], Instance).

	invoke(Message) :-
		parameter(1, Reference),
		Message =.. [Functor| Arguments],
		jpl_call(Reference, Functor, Arguments, Output),
		parameter(2, Output).

	invoke(Functor, Arguments) :-
		parameter(1, Reference),
		jpl_call(Reference, Functor, Arguments, Output),
		parameter(2, Output).

	forward(Message) :-
		parameter(1, Reference),
		Message =.. [Functor| Arguments],
		jpl_call(Reference, Functor, Arguments, Output),
		parameter(2, Output).

:- end_object.


:- object(java(Reference),
	extends(java(Reference, _))).

	:- info([
		version is 1.0,
		author is 'Paulo Moura and Sergio Castro',
		date is 2014/03/25,
		comment is 'Minimal abstraction of the JPL API for calling Java from Logtalk using familiar message sending syntax and a forward/1 handler to resolve methods.',
		parameters is [
			'Reference' - 'Either a class name or a Java reference to an object'
		]
	]).

:- end_object.


:- object(java,
	implements(java_utils_protocol)).

	:- info([
		version is 1.5,
		author is 'Paulo Moura',
		date is 2017/10/16,
		comment is 'Abstract interface to JPL API utility predicates.'
	]).

	:- use_module(jpl, [
		jpl_true/1, jpl_false/1, jpl_void/1, jpl_null/1,
		jpl_is_true/1, jpl_is_false/1, jpl_is_void/1, jpl_is_null/1, jpl_is_object/1,
		jpl_is_ref/1,
		jpl_terms_to_array/2, jpl_list_to_array/2, jpl_array_to_list/2,
		jpl_iterator_element/2,
		jpl_call/4
	]).

	:- uses(user, [
		length/2
	]).

	value_reference(true, Reference) :-
		jpl_true(Reference).
	value_reference(false, Reference) :-
		jpl_false(Reference).
	value_reference(void, Reference) :-
		jpl_void(Reference).
	value_reference(null, Reference) :-
		jpl_null(Reference).

	true(Reference) :-
		jpl_true(Reference).

	false(Reference) :-
		jpl_false(Reference).

	void(Reference) :-
		jpl_void(Reference).

	null(Reference) :-
		jpl_null(Reference).

	is_true(Reference) :-
		jpl_is_true(Reference).

	is_false(Reference) :-
		jpl_is_false(Reference).

	is_void(Reference) :-
		jpl_is_void(Reference).

	is_null(Reference) :-
		jpl_is_null(Reference).

	is_object(Reference) :-
		jpl_is_object(Reference).

	terms_to_array(Terms, Array) :-
		jpl_terms_to_array(Terms, Array).

	array_to_terms(Array, Terms, Length) :-
		jpl_call('org.jpl7.Util', termArrayToList, [Array], {Terms}),
		length(Terms, Length).

	array_to_terms(Array, Terms) :-
		jpl_call('org.jpl7.Util', termArrayToList, [Array], {Terms}).

	array_list(Array, List) :-
		(	var(Array) ->
			jpl_list_to_array(List, Array)
		;	jpl_array_to_list(Array, List)
		).

	iterator_element(Iterator, Element) :-
		jpl_iterator_element(Iterator, Element).

	decode_exception(error(java_exception(Exception),_), Cause) :-
		!,
		decode_exception(Exception, Cause).
	decode_exception(java_exception(Exception), Cause) :-
		!,
		decode_exception(Exception, Cause).
	decode_exception(Exception, Cause) :-
		jpl_is_ref(Exception),
		\+ jpl_is_null(Exception),
		jpl_call(Exception, getCause, [], Cause).

	decode_exception(error(java_exception(Exception),_), Cause, StackTrace) :-
		!,
		decode_exception(Exception, Cause, StackTrace).
	decode_exception(java_exception(Exception), Cause, StackTrace) :-
		!,
		decode_exception(Exception, Cause, StackTrace).
	decode_exception(Exception, Cause, StackTrace) :-
		jpl_is_ref(Exception),
		\+ jpl_is_null(Exception),
		jpl_call(Exception, getCause, [], Cause),
		jpl_call(Exception, getStackTrace, [], StackTrace0),
		jpl_array_to_list(StackTrace0, StackTrace1),
		decode_stack_trace_elements(StackTrace1, StackTrace).

	decode_stack_trace_elements([], []).
	decode_stack_trace_elements([Element| Elements], [String| Strings]) :-
		jpl_call(Element, toString, [], String),
		decode_stack_trace_elements(Elements, Strings).

:- end_object.
