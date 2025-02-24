--[[
This file is part of minitar.lua.

minitar.lua is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

minitar.lua is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with minitar.lua.  If not, see <https://www.gnu.org/licenses/>.

For further information about minitar.lua you can visit
https://github.com/cdsoft/minitar.lua
--]]

var "builddir" ".build"

var "minitar" "$builddir/minitar"

----------------------------------------------------------------------------------------------------
-- Compilation
----------------------------------------------------------------------------------------------------

build.luax.native "$minitar" "minitar.lua"

----------------------------------------------------------------------------------------------------
-- Tests
----------------------------------------------------------------------------------------------------

section "Test data generation"

var "input" "$builddir/input"
var "date"  "222201011111.00"

rule "sh" { command = "./$in $args > $out" }

local input = build "$builddir/step_0-generate_input" { "sh", "gen_test.sh", args="$input $date" }

section "Archive creation"

rule "create" {
    command = "$minitar -cf $out $args",
    implicit_in = {
        "$minitar",
        input,
    },
}

rule "test" {
    command = "$minitar -tf $in $args > $out",
}

rule "tartest" {
    command = "tar -tvf $in $args > $out",
}

rule "extract" {
    command = "mkdir -p $out.dir && $minitar -xvf $in $args -C $out.dir > $out",
}

----------------------------------------------------------------------------------------------------
-- Strip path in the archive, lzip compression
----------------------------------------------------------------------------------------------------

build "$builddir/step_1-creation.tar"     { "create",   args="$input --strip 1" }
build "$builddir/step_1-creation.test"    { "test",    "$builddir/step_1-creation.tar" }
build "$builddir/step_1-creation.tartest" { "tartest", "$builddir/step_1-creation.tar" }
build "$builddir/step_1-creation.extract" { "extract", "$builddir/step_1-creation.tar" }

build "$builddir/step_2-creation.tar.lz"  { "create",   args="$input --strip 1" }
build "$builddir/step_2-creation.test"    { "test",    "$builddir/step_2-creation.tar.lz" }
build "$builddir/step_2-creation.tartest" { "tartest", "$builddir/step_2-creation.tar.lz" }
build "$builddir/step_2-creation.extract" { "extract", "$builddir/step_2-creation.tar.lz" }

build "$builddir/step_3-creation.tar.lz"  { "create",   args=". -C $input" }
build "$builddir/step_3-creation.test"    { "test",    "$builddir/step_3-creation.tar.lz" }
build "$builddir/step_3-creation.tartest" { "tartest", "$builddir/step_3-creation.tar.lz" }
build "$builddir/step_3-creation.extract" { "extract", "$builddir/step_3-creation.tar.lz" }

build "$builddir/step_4-creation.tar.lz"  { "create",   args="$input --strip 2" }
build "$builddir/step_4-creation.test"    { "test",    "$builddir/step_4-creation.tar.lz" }
build "$builddir/step_4-creation.tartest" { "tartest", "$builddir/step_4-creation.tar.lz" }
build "$builddir/step_4-creation.extract" { "extract", "$builddir/step_4-creation.tar.lz" }

----------------------------------------------------------------------------------------------------
-- Strip path and add a component in the archive, lzip compression
----------------------------------------------------------------------------------------------------

build "$builddir/step_5-creation.tar.lz"  { "create",   args="$input --strip 1 --add /foo/bar/" }
build "$builddir/step_5-creation.test"    { "test",    "$builddir/step_5-creation.tar.lz" }
build "$builddir/step_5-creation.tartest" { "tartest", "$builddir/step_5-creation.tar.lz" }
build "$builddir/step_5-creation.extract" { "extract", "$builddir/step_5-creation.tar.lz" }

build "$builddir/step_6-creation.tar.lz"  { "create",   args=". -C $input --add /foo/bar/" }
build "$builddir/step_6-creation.test"    { "test",    "$builddir/step_6-creation.tar.lz" }
build "$builddir/step_6-creation.tartest" { "tartest", "$builddir/step_6-creation.tar.lz" }
build "$builddir/step_6-creation.extract" { "extract", "$builddir/step_6-creation.tar.lz" }

build "$builddir/step_7-creation.tar.lz"  { "create",   args="$input --strip 2 --add /foo/bar/" }
build "$builddir/step_7-creation.test"    { "test",    "$builddir/step_7-creation.tar.lz" }
build "$builddir/step_7-creation.tartest" { "tartest", "$builddir/step_7-creation.tar.lz" }
build "$builddir/step_7-creation.extract" { "extract", "$builddir/step_7-creation.tar.lz" }

----------------------------------------------------------------------------------------------------
-- Gzip compression
----------------------------------------------------------------------------------------------------

build "$builddir/step_8-creation.tar.gz"  { "create",   args="$input --strip 1" }
build "$builddir/step_8-creation.test"    { "test",    "$builddir/step_8-creation.tar.gz" }
build "$builddir/step_8-creation.tartest" { "tartest", "$builddir/step_8-creation.tar.gz" }
build "$builddir/step_8-creation.extract" { "extract", "$builddir/step_8-creation.tar.gz" }

----------------------------------------------------------------------------------------------------
-- xz compression
----------------------------------------------------------------------------------------------------

build "$builddir/step_9-creation.tar.xz"  { "create",   args="$input --strip 1" }
build "$builddir/step_9-creation.test"    { "test",    "$builddir/step_9-creation.tar.xz" }
build "$builddir/step_9-creation.tartest" { "tartest", "$builddir/step_9-creation.tar.xz" }
build "$builddir/step_9-creation.extract" { "extract", "$builddir/step_9-creation.tar.xz" }

----------------------------------------------------------------------------------------------------
-- Smallest tar archives (empty)
----------------------------------------------------------------------------------------------------

build "$builddir/step_10-creation.tar"     { "create",   args="$input/empty --strip 1" }
build "$builddir/step_10-creation.test"    { "test",    "$builddir/step_10-creation.tar" }
build "$builddir/step_10-creation.tartest" { "tartest", "$builddir/step_10-creation.tar" }
build "$builddir/step_10-creation.extract" { "extract", "$builddir/step_10-creation.tar" }

build "$builddir/step_11-creation.tar"     { "create",   args="$input/empty --strip 2" }
build "$builddir/step_11-creation.test"    { "test",    "$builddir/step_11-creation.tar" }
build "$builddir/step_11-creation.tartest" { "tartest", "$builddir/step_11-creation.tar" }
build "$builddir/step_11-creation.extract" { "extract", "$builddir/step_11-creation.tar" }

build "$builddir/step_12-creation.tar"     { "create",   args="$input/empty --strip 3" }
build "$builddir/step_12-creation.test"    { "test",    "$builddir/step_12-creation.tar" }
build "$builddir/step_12-creation.tartest" { "tartest", "$builddir/step_12-creation.tar" }
build "$builddir/step_12-creation.extract" { "extract", "$builddir/step_12-creation.tar" }
