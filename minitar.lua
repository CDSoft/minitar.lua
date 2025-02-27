#!/usr/bin/env luax
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

local F = require "F"
local fs = require "fs"
local sh = require "sh"
local term = require "term"
local tar = require "tar"
local lzip = require "lzip"

local args = (function()
    local xforms = {}
    local parser = require "argparse"() : name "minitar" : description "Minimal tar archiver for LuaX"
    parser : flag "-v" : target "verbose" : description "Verbose output"
    parser : flag "-c" : target "create" : description "Create archive"
    parser : flag "-x" : target "extract" : description "Extract archive"
    parser : flag "-t" : target "test" : description "Test archive"
    parser : option "-f" : target "archive" : argname "archive" : description "Archive file name"
    parser : option "--strip" : argname "path" : description "Strip path components"
        : action(function(_, _, path, _) xforms[#xforms+1] = tar.strip(tonumber(path) or path) end)
    parser : option "--add" : argname "path" : description "Add path components"
        : action(function(_, _, path, _) xforms[#xforms+1] = tar.add(path) end)
    parser : option "--gzip" : argname "level" : args "?" : description "Compress with gzip"
    parser : option "--lzip" : argname "level" : args "?" : description "Compress with lzip"
    parser : option "--xz" : argname "level" : args "?" : description "Compress with xz"
    parser : option "-C" : argname "path" : target "newpath" : description "Change directory before archiving or extracting"
    parser : argument "file" : args "*" : description "Archive members"
    return F.merge {
        parser:parse(arg),
        {
            xform = #xforms==1 and xforms[1] or #xforms>1 and tar.chain(xforms) or nil,
        },
    }
end)()

local actions = F{args.create and "-c", args.extract and "-x", args.test and "-t"}:filter(F.id)
if #actions == 0 then F.error_without_stack_trace("-c, -x or -t missing") end
if #actions > 1 then F.error_without_stack_trace(actions:str(", ", " and ").." are exclusive") end

local formats = F{args.gzip and "--gzip", args.lzip and "--lzip", args.xz and "-xz-"}:filter(F.id)
if #formats > 1 then F.error_without_stack_trace(formats:str(", ", " and ").." are exclusive") end

if args.verbose and args.create and (not args.archive or args.archive=="-") then
    F.error_without_stack_trace("can not write verbose messages to stdout")
end

if args.create and (not args.archive or args.archive=="-") and term.isatty(io.stdout) then
    F.error_without_stack_trace("can not write to the console")
end

local function mode(m, t)
    return F.str {
        t=="directory" and "d" or t=="link" and "l" or "-",
        m&fs.uR~=0 and "r" or "-", m&fs.uW~=0 and "w" or "-", m&fs.uX~=0 and "x" or "-",
        m&fs.gR~=0 and "r" or "-", m&fs.gW~=0 and "w" or "-", m&fs.gX~=0 and "x" or "-",
        m&fs.oR~=0 and "r" or "-", m&fs.oW~=0 and "w" or "-", m&fs.oX~=0 and "x" or "-",
    }
end

local function mtime(t)
    return os.date("%Y-%m-%d %H:%M", t)
end

local function safe(f, ...)
    local res, err = f(...)
    if not res then F.error(err) end
    return res
end

local function dump_file(file)
    local link = ""
    if file.link then link = string.format("-> %s", file.link) end
    print(string.format("%s %10d %s %s%s", mode(file.mode, file.type), file.size, mtime(file.mtime), file.name, link))
end

local function dump(archive)
    local files
    if type(archive) == "string" then
        files = safe(tar.untar, archive)
    elseif type(archive) == "table" then
        files = archive
    end
    for _, file in ipairs(files) do
        dump_file(file)
    end
end

local function gzip(s, level)
    local input_name = (args.archive or "stdin"):basename():splitext()
    local output_name = input_name..".gz"
    return fs.with_tmpdir(function(tmp)
        local input = tmp/input_name
        local output = tmp/output_name
        assert(fs.write_bin(input, s))
        assert(sh.run("gzip --to-stdout", "-"..level, input, ">", output))
        return assert(fs.read_bin(output))
    end)
end

local function gunzip(s)
    local input_name = (args.archive or "stdin"):basename()
    local output_name = input_name:splitext()
    return fs.with_tmpdir(function(tmp)
        local input = tmp/input_name
        local output = tmp/output_name
        assert(fs.write_bin(input, s))
        assert(sh.run("gunzip --to-stdout", input, ">", output))
        return assert(fs.read_bin(output))
    end)
end

local function xz(s, level)
    local input_name = (args.archive or "stdin"):basename():splitext()
    local output_name = input_name..".xz"
    return fs.with_tmpdir(function(tmp)
        local input = tmp/input_name
        local output = tmp/output_name
        assert(fs.write_bin(input, s))
        assert(sh.run("xz --to-stdout", "-"..level, input, ">", output))
        return assert(fs.read_bin(output))
    end)
end

local function unxz(s)
    local input_name = (args.archive or "stdin"):basename()
    local output_name = input_name:splitext()
    return fs.with_tmpdir(function(tmp)
        local input = tmp/input_name
        local output = tmp/output_name
        assert(fs.write_bin(input, s))
        assert(sh.run("unxz --to-stdout", input, ">", output))
        return assert(fs.read_bin(output))
    end)
end

local function get_compressor()
    local z, uz = F.id, F.id
    local level
    if args.gzip then z, uz, level = gzip,      gunzip,      tonumber(args.gzip[1]) end
    if args.lzip then z, uz, level = lzip.lzip, lzip.unlzip, tonumber(args.lzip[1]) end
    if args.xz   then z, uz, level = xz,        unxz,        tonumber(args.xz[1])   end
    if args.archive then
        local ext = args.archive:ext()
        if ext == ".gz" then z, uz = gzip,      gunzip      end
        if ext == ".lz" then z, uz = lzip.lzip, lzip.unlzip end
        if ext == ".xz" then z, uz = xz,        unxz        end
    end
    return z, uz, level or 6
end

local function compress(archive)
    local z, _, level = get_compressor()
    return safe(z, archive, level)
end

local function decompress(archive)
    local _, uz, _ = get_compressor()
    return safe(uz, archive)
end

local function with_dir(path, f, ...)
    if not path then return f(...) end
    local old = fs.getcwd()
    safe(fs.chdir, path)
    local ret = f(...)
    safe(fs.chdir, old)
    return ret
end

local function create()
    local archive = with_dir(args.newpath, safe, tar.tar, args.file, args.xform)
    if args.verbose then dump(archive) end
    archive = compress(archive)
    if not args.archive or args.archive == "-" then
        io.write(archive)
    else
        safe(fs.write_bin, args.archive, archive)
    end
end

local function read_archive()
    local archive
    if not args.archive or args.archive == "-" then
        archive = safe(io.read, "a")
    else
        archive = safe(fs.read_bin, args.archive)
    end
    archive = decompress(archive)
    return archive
end

local function extract()
    local archive = read_archive()
    local files = safe(tar.untar, archive, args.xform)
    with_dir(args.newpath, function()
        local touches = {}
        for _, file in ipairs(files) do
            if args.verbose then dump_file(file) end
            if file.type == "directory" then
                safe(fs.mkdirs, file.name)
                touches[#touches+1] = {fs.touch, file.name, file.mtime}
                touches[#touches+1] = {fs.chmod, file.name, file.mode}
            elseif file.type == "file" then
                fs.remove(file.name)
                safe(fs.mkdirs, file.name:dirname())
                safe(fs.write_bin, file.name, file.content)
                safe(fs.touch, file.name, file.mtime)
                safe(fs.chmod, file.name, file.mode)
            elseif file.type == "link" then
                fs.remove(file.name)
                safe(fs.mkdirs, file.name:dirname())
                safe(fs.symlink, file.link, file.name)
                safe(fs.ltouch, file.name, file.mtime)
                safe(fs.chmod, file.name, file.mode)
            end
        end
        for i = 1, #touches do
            safe(table.unpack(touches[i]))
        end
    end)
end

local function test()
    local archive = read_archive()
    dump(archive)
end

if args.create then create() end
if args.extract then extract() end
if args.test then test() end
