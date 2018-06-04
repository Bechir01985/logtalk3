________________________________________________________________________

This file is part of Logtalk <https://logtalk.org/>  
Copyright 1998-2018 Paulo Moura <pmoura@logtalk.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
________________________________________________________________________


About
-----

This library provides random number generators.


Loading
-------

To load all entities in this library load the `random_loader.lgt` utility
file:

	| ?- logtalk_load(library(random_loader)).


Usage
-----

The `random` object implements portable random number generator and
supports multiple random number generators, using different seeds,
by defining derived objects. For example:

	:- object(my_random_generator_1,
		extends(ramdom)).
	
		:- intialization(::reset_seed).

	:- end_object.

The `fast_random` object also implements a portable random number
generator but does not support deriving multiple random number
generators.

The `random` and `fast_random` objects manage the random number
generator seed using internal dynamic state. Care must be taken
when using these objects from multi-threaded applications as there
is not portable solution to protect seed updates from signals and
prevent inconsistent state when threads are canceled.

The `backend_random` object uses the native backend Prolog compiler
random number generator for the basic random/1, get_seed/1, and
set_seed/1 predicates and a portable implementation for all the
remaining predicates. This makes the object stateless, which can
allow reliable use from multiple threads. Consult the backend
Prolog compiler documentation for details on its random number
generator properties.
