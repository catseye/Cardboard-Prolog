Cardboard Prolog
================

This is a tiny inference engine (~120 lines of purely functional R5RS
Scheme) I wrote a while back, when I was refreshing myself on how a
Prolog interpreter works.  I found several descriptions and examples
of Prolog interpreters online, but none were quite what I wanted.

Cardboard Prolog lacks all the amenties the Prolog language proper, and
it uses Scheme literals instead of Prolog syntax, but it does do the thing
that's at the core of Prolog execution: deduction based on Horn clauses.

There are no comments, but there is a suite of tests.  You can run the
tests with (for example) Chicken Scheme, by running

    csi -b test-cardboard-prolog.scm

I'll also try to briefly describe what's going on here.

### Overview of the Design and Implementation

A term in Cardboard Prolog is represented by a Scheme list, where atoms
are symbols and variables are vectors of length 1 or 2.  The first
entry of a variable vector is a symbol giving the variable name, and the
second entry is an index which is used to disambiguate different instances
of a variable.

`ground?` and `variable?` are predicates on terms.

`rename-term` takes a term and returns a new term which is the same as
the input term except that all variables are given new indexes.  The
purpose is to obtain a "fresh" version of the term with no bound variables.

`collect-vars` takes a term and returns a list of all variables found
in it.

`match-var` and `unify` are mutually-recursive functions which implement
unification.  `unify` takes two patterns (terms which may contain
variables) and returns a list of bindings if the each pattern matches
the other, or `#f` if they cannot be matched.  Such a list of bindings
is called an "environment" (abbreviated `env`) in this code.  Each binding
is a two-element list of a variable, and the subterm that it matched with,
which may itself be a variable, or contain variables.

Note that, for simplicitly, the unification algorithm here does not perform
an occurs check.  For the sake of correctness, it should perform one, but
since it's very easy to implement and doesn't really add explanatory value
to the exposition,  I left it out.  You can undertake adding one as an
exercise, if you like.

`expand` takes a term and an environment and returns a new term which
is the same as the input term except that all variables are replaced
with the terms that they are bound to in the environment.  `subst` is a
helper function used by `expand`.

During the search process, a variable like `#(X)` will be instantiated
to a variable like `#(X 2)` (where 2 indicates the depth of the search),
and it is `#(X 2)` that will match a term, but this information is
usually irrelevant to the user, for whom the report that `#(X)` matched
would be more meaningful.  `collapse-env` (with its helper functions
`expand-env` and `expand-binding`) and `restrict-to-vars` are used clean
up the output of the engine, and make its results more presentable to
the user in this way.

`search` implements the core inference process.  It is given a database
(a list of facts and rules, where a fact is simply a rule with no
premises), and a list of goals.  It keeps track of the current
environment (list of bindings) and the current search depth.

`search` tries to `unify` each rule in the database with the first goal
of the current list of goals, under the current environment.  If this
succeeds, it takes the unifying environment (which we now call a
"unifier"), `expand`s the consequent of the rule and the remaining goals
using the unifier, joins these together to obtain a new list of goals,
and recursively calls itself with the new list of goals and the new
environment, to continue to the search.  If there are no more goals in
the list to satisfy, the search was a success and the final unifying
environment is returned.

But note that `search` might actually return to itself, because it
calls itself recursively.  So it returns a list of unifying environments,
and collects these lists to ultimately return all of the successful searches
in the database.

A real Prolog interpreter would do this piecemeal, asking the user if they
want it to search for the next answer after each answer is found.  For
simplicitly, Cardboard Prolog always returns all the answers, and
if there are infinitely many answers, this will simply not terminate.

(This design choice was for simplicitly, but it would certainly be
an interesting exercise to rewrite it to work in the fashion of Prolog.
Many of the descriptions I found online did describe how Prolog
interpreters accomplish this, but none of them phrased it in terms of
continuations, which is probably how you'd want to do it in Scheme.)

Finally, `match-all` is a driver function for `search`, and the main
interface to the inference engine.  It takes a database and a list of
goals, and returns a list of comprehensible answers.
