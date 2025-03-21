# minitar.lua

`minitar.lua` is a minimal tar implementation in Lua, based on [LuaX](https://github.com/CDSoft/luax).

## Description

`minitar.lua` is a lightweight and portable utility that allows you to create, extract, and test tar archives.
It supports multiple compression formats (gzip, lzip, xz) and offers path manipulation features during archiving or extraction.

## Installation

### Prerequisites

- [LuaX](https://github.com/CDSoft/luax) and [Bang](https://github.com/CDSoft/bang) must be installed on your system
- To use compression features, the corresponding tools must be available:
  - `gzip` for gzip compression
  - `xz` for xz compression

`lzip` is provided by LuaX.
No external dependency is required for the lzip compression.

### Installation

Download the sources, compile and install `minitar`:

```bash
$ git clone https://github.com/CDSoft/minitar.lua
$ cd minitar.lua
$ bang && ninja install
```

## Usage

### General syntax

```
minitar [-h] [-v] [-c] [-x] [-t] [-f archive] [--strip path]
        [--add path] [-C path] [<file>] ... [--gzip [level]]
        [--lzip [level]] [--xz [level]]
```

### Arguments

| Argument      | Description                                   |
|---------------|-----------------------------------------------|
| `<file>`      | List of files to archive, extract or test     |

### Main options

| Option            | Description                                   |
|-------------------|-----------------------------------------------|
| `-h`, `--help`    | Display help and exit                         |
| `-v`              | Verbose mode (displays detailed information)  |
| `-c`              | Create archive                                |
| `-x`              | Extract archive                               |
| `-t`              | Test archive (list its contents)              |
| `-f archive`      | Specify archive filename                      |

### Path manipulation options

| Option            | Description                                           |
|-------------------|-------------------------------------------------------|
| `--strip path`    | Remove path components during archiving or extraction |
| `--add path`      | Add path components during archiving or extraction    |
| `-C path`         | Change directory before archiving or extracting       |

### Compression options

| Option            | Description                                       |
|-------------------|---------------------------------------------------|
| `--gzip [level]`  | Compress with gzip (optional compression level)   |
| `--lzip [level]`  | Compress with lzip (optional compression level)   |
| `--xz [level]`    | Compress with xz (optional compression level)     |

The compression format can be deduced from the output filename.
These options are necessary to change the default compression level (`6`)
or to compress a stream to the standard output (`stdout`).

## Usage examples

### Creating an archive

Create a simple tar archive:
```bash
minitar -c -f archive.tar file1 file2 folder1
```

Create a tar archive compressed with gzip:
```bash
minitar -c -f archive.tar.gz file1 file2 folder1 --gzip
```

Create a tar archive compressed with xz (compression level 9):
```bash
minitar -c -f archive.tar.xz file1 file2 folder1 --xz 9
```

Create an archive after changing directory:
```bash
minitar -c -f archive.tar -C /path/to/folder file1 file2
```

### Extracting an archive

Extract a tar archive:
```bash
minitar -x -f archive.tar
```

Extract a compressed tar archive (format is automatically detected):
```bash
minitar -x -f archive.tar.gz
```

Extract an archive to a specific directory:
```bash
minitar -x -f archive.tar -C /path/to/destination
```

Extract an archive removing the first two directory levels:
```bash
minitar -x -f archive.tar --strip 2
```

### Listing archive contents

Display the contents of a tar archive:
```bash
minitar -t -f archive.tar
```

Display the contents of a compressed tar archive:
```bash
minitar -t -f archive.tar.xz
```

## Path manipulation

### --strip option

The `--strip` option allows you to remove path components during archiving or extraction.

Example: If a file in the archive has the path `dir1/dir2/dir3/file.txt`, then:
- `--strip 1` will result in `dir2/dir3/file.txt`
- `--strip 2` will result in `dir3/file.txt`
- `--strip 3` will result in `file.txt`

### --add option

The `--add` option allows you to add a prefix to paths during archiving or extraction.

Example: If a file has the path `file.txt`, then:
- `--add prefix` will result in `prefix/file.txt`

## Supported compression formats

`minitar.lua` supports several compression formats:

- **gzip**: Standard compression format, good balance between compression ratio and speed
- **lzip**: Compression format offering better compression than gzip
- **xz**: Modern compression format offering excellent compression ratio

The compression format is automatically detected during extraction based on the file extension:
- `.tar.gz` or `.tgz` for gzip
- `.tar.lz` or `.tlz` for lzip
- `.tar.xz` or `.txz` for xz

## License

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
