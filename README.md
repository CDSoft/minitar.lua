# minitar.lua

`minitar.lua` is a minimal tar implementation in Lua ([LuaX](https://github.com/CDSoft/luax)).

The documentation is currently minimal too...

# Usage

```
$ minitar.lua -h
Usage: minitar [-h] [-v] [-c] [-x] [-t] [-f archive] [--strip path]
       [--add path] [-C path] [<file>] ... [--gzip [level]]
       [--lzip [level]] [--xz [level]]

Minimal tar archiver for LuaX

Arguments:
   file                  Archive members

Options:
   -h, --help            Show this help message and exit.
   -v                    Verbose output
   -c                    Create archive
   -x                    Extract archive
   -t                    Test archive
   -f archive            Archive file name
   --strip path          Strip path components
   --add path            Add path components
   --gzip [level]        Compress with gzip
   --lzip [level]        Compress with lzip
   --xz [level]          Compress with xz
   -C path               Change directory before archiving or extracting
```

# License

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
