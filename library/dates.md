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

The `date` object implements some useful calendar date predicates.

The `time` object implements some useful time predicates.

Please note that some of the functionality of these objects depends 
on the chosen Prolog support for accessing operating system time and 
date data.


Loading
-------

To load all entities in this group load the `dates_loader.lgt` utility 
file:

	| ?- logtalk_load(library(dates_loader)).
