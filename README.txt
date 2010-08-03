= strict

* www.raeez.com/strict

== DESCRIPTION:

Strict implements a traditional static type-system over dynamic ruby objects. Strict is designed to help debug simple type errors.

== FEATURES/PROBLEMS:

Implements a Static typesystem over Object
Support for ruby Primitives (strict subsets, weak subsets etc.)
Support for user-defined types

== SYNOPSIS:

def add_nums(a, b)
  enforce!(:numeric, a)
  enforce!(:numeric, b)
  return a + b
end

def launch_rocket(params)
  enforce_map!({
    :destination => [:moon, :mars, :saturn, :jupiter, :iss],
    :rocket_type => [:appollo, :space_x],
    :fuel_litres => :numeric,
    :mission_id => :string}, params)
  ... #launch the rocket
end

== REQUIREMENTS:

none

== INSTALL:

sudo gem install strict

== DEVELOPERS:

After checking out the source, run:

  $ rake strict

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(The MIT License)

Copyright (c) 2010 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
