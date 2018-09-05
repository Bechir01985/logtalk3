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


:- object(obj(_Dict_)).

	:- info([
		version is 2.0,
		author is 'Paulo Moura',
		date is 2018/09/03,
		comment is 'Simple object for testing passing a dict as the object parameter.'
	]).

	:- public(sum/1).
	sum(Sum) :-
		Sum is _Dict_.m + _Dict_.n.

	:- public(product/1).
	product(Product) :-
		Product is _Dict_.m * _Dict_.n.

	:- public(double/0).
	double :-
		M2 is _Dict_.m * 2,
		b_set_dict(m, _Dict_, M2),
		N2 is _Dict_.n * 2,
		b_set_dict(n, _Dict_, N2).

:- end_object.