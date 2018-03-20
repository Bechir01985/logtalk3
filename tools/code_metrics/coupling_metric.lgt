%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This file is part of Logtalk <https://logtalk.org/>
%  Copyright 2017 Ebrahim Azarisooreh <ebrahim.azarisooreh@gmail.com> and
%  Paulo Moura <pmoura@logtalk.org>
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


:- object(coupling_metric,
	imports((code_metrics_utilities, code_metric))).

	:- info([
		version is 0.8,
		author is 'Ebrahim Azarisooreh and Paulo Moura',
		date is 2018/03/20,
		comment is 'Analyzes entity efferent coupling.',
		remarks is [
			'Calls and Updates' - 'Any calls or dynamic updates to predicates in external objects or categories increments the coupling score.',
			'Ancestors' - 'Any direct inheritance relations to the entity in question will also increment the score. Duplicate entity couplings will not be scored multiple times.',
			'Interpretation' - 'Generally speaking, lower scores are better.'
		]
	]).

	:- uses(list, [member/2]).

	entity_score(Entity, Score) :-
		^^current_entity(Entity),
		^^entity_kind(Entity, Kind),
		(	Kind == protocol ->
			efferent_coupling_score_protocol(Entity, 0, Score, [])
		;	efferent_coupling_score(Kind, Entity, 0, Score, [])
		).

	efferent_coupling_score_protocol(Protocol, Score0, Score, LoggedEntities) :-
		(	unvisited_ancestor(protocol, Protocol, Ancestor, LoggedEntities)
		->	Score1 is Score0 + 1,
			efferent_coupling_score_protocol(Protocol, Score1, Score, [Ancestor|LoggedEntities])
		;	Score0 = Score
		).

	% measure the coupling scores for objects and categories
	efferent_coupling_score(Kind, Entity, Score0, Score, LoggedEntities) :-
		(	unvisited_ancestor(Kind, Entity, Ancestor, LoggedEntities)
		->	Score1 is Score0 + 1,
			efferent_coupling_score(Kind, Entity, Score1, Score, [Ancestor| LoggedEntities])
		;	unvisited_call(Entity, Entity2, LoggedEntities)
		->	Score1 is Score0 + 1,
			efferent_coupling_score(Kind, Entity, Score1, Score, [Entity2| LoggedEntities])
		;	Score0 = Score
		).

	% Increment the score if there are any direct ancestors
	unvisited_ancestor(EntityKind, Entity, Ancestor, LoggedEntities) :-
		^^ancestor(EntityKind, Entity, _, Ancestor),
		\+ member(Ancestor, LoggedEntities).

	% score any calls external to the entity being measured
	unvisited_call(Entity, Entity2, LoggedEntities) :-
		external_call(Entity, Entity2, _Caller, _Predicate),
		\+ member(Entity2, LoggedEntities),
		!.

	external_call(Entity, Entity2, Caller, Predicate) :-
		^^entity_calls(Entity, Caller, Predicate),
		external_call_(Predicate, Entity, Entity2).

	external_call(Entity, Entity2, Caller, Predicate) :-
		^^entity_updates(Entity, Caller, Predicate),
		external_call_(Predicate, Entity, Entity2).

	external_call_(Obj::_Name/_Arity, Entity, Obj) :-
		Entity \== Obj.

	external_call_(':'(Module,_Name/_Arity), _, Module).

	entity_score(_Entity, Score) -->
		['Efferent coupling score: ~w'-[Score], nl].

:- end_object.
