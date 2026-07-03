# SkyObJect Manual

SkyObJect, or SOJ, is the SkyOS script language. It is intentionally small and
shell-like. Scripts are stored as RAM files such as `/home/demo.soj` and
`/home/script.soj`.

Run a script:

```text
soj /home/demo.soj
run /home/script.soj
```

From `/home`, relative names work:

```text
cd /home
soj demo.soj
```

## Syntax

Statements are separated by semicolons or newlines:

```soj
echo hello; echo world
```

Comments start with `#`:

```soj
# this is a comment
```

## Commands

Print text:

```soj
echo hello SkyOS
print hello
```

Variables:

```soj
set name SkyOS
echo booting $name
print $name
```

Input:

```soj
input name
echo hello $name
```

Conditionals:

```soj
if $name == SkyOS then echo ok
if $name == SkyOS then goto done
if $name != SkyOS then echo other
```

Labels and jumps:

```soj
label loop
echo looping
goto loop
```

Integer update helpers:

```soj
set n 0
inc n
dec n
```

Run SkyOS shell commands:

```soj
exec version
exec sysinfo
exec ip addr
```

Exit:

```soj
exit
```

## Turing Completeness

SOJ has mutable state, equality and inequality branching, and unbounded control
flow through `goto`. This is enough to express loops and state machines. SOJ can
also execute the built-in `bf` command, so a SOJ script can run Brainfuck
programs as a compact Turing-complete sublanguage:

```soj
exec bf +++++[>++++++++<-]>+.
```

Example counter loop:

```soj
set n 0
label loop
echo tick $n
inc n
if $n == 3 then goto done
goto loop
label done
echo finished
```

Current implementation has one active variable slot. Setting a new variable
replaces the previous variable name/value. For native SOJ code this supports
counter-style loops; for full tape-machine style computation, call `bf` from
SOJ with `exec`.

## Built-In Demo

Run:

```text
soj /home/demo.soj
```

The demo prints a variable, runs a counter loop, and executes `version`.

## Recommended Style

Use one statement per line while editing:

```soj
set n 0
label loop
echo $n
inc n
if $n == 10 then goto done
goto loop
label done
```

For command-like automation, prefer `exec`:

```soj
exec clear
exec sysinfo
exec netctl
```
