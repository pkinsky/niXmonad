
what: notes on article series starting with http://lethalman.blogspot.it/2014/07/nix-pill-1-why-you-should-give-it-try.html


Nix pill 1: why you should give it a try
---------------------

. http://lethalman.blogspot.it/2014/07/nix-pill-1-why-you-should-give-it-try.html
. overview of nix immutablity
. points out ability to have multiple versions of everything
. great content for presentation


Nix pill 2: install on your running system
-------------------------

. http://lethalman.blogspot.com/2014/07/nix-pill-2-install-on-your-running.html
. nix has db at /nix/var/nix/db/db.sqlite
.. can browse with `sudo /nix/store/*sqlite*/bin/sqlite3 /nix/var/nix/db/db.sqlite`
.. don't change anything
.. tables: DerivationOutputs  FailedPaths        Refs               ValidPaths       
. a bunch of close examination of the .nixprofile, etc for a nix install (not nixos as here)


Nix pill 3: enter the environment
---------------------------

. http://lethalman.blogspot.it/2014/07/nix-pill-3-enter-environment.html

. start by installing nix-repl
. exploring env

Querying the store:

.. cmd to show direct runtime dependencies of something in the nix store: 
... nix-store -q --references `which nix-repl`
.... /nix/store/gwl3ppqj4i730nhd4f50ncl5jc4n97ks-glibc-2.23
.... /nix/store/c7ipds48nb7sfzhb7vqp26rrllirxwxv-gcc-5.3.0
.... /nix/store/k3h506y7141gqnf0mn38bg4hy900m41b-boehm-gc-7.2f
.... /nix/store/nilqh70fcqcansqllvdmghnjl7c2zmiq-readline-6.3p08
.... /nix/store/y820q4wkhkikqsafs0002n6gampz2zk6-nix-1.11.2

.. cmd to show things depending on something in the nix store:
... nix-store -q --referrers `which nix-repl`
.... /nix/store/4h8dn3mi4i2vlhnb977asykjijrlyizk-system-path
.... /nix/store/9pa7xhcskiihj912imgq1phy3d4v9dp9-system-path
.. makes sense: our env depends on nix-repl, which is part of our env

Closures:

. The closure of a derivation is the list of all dependencies, recursively, down to the bare minimum necessary to use that derivation.

. view deps for something in the nix store: nix-store -qR `which man`
. view deps as recursive tree for something in the nix store: nix-store -q --tree `which man`


Channels:

. where we get packages from
. nix-channel --list: nothing, oddly. Maybe managed by nixos?
. expected:
```
$ nix-channel --list
nixpkgs http://nixos.org/channels/nixpkgs-unstable
```

Nix pill 4: the basics of the language
------------------------------------

. http://lethalman.blogspot.it/2014/07/nix-pill-4-basics-of-language.html

. The Nix language is used to write derivations. The nix-build tool is used to build derivations.

Value Types

. integers, string, path, boolean, null
.. simple arithmetic: +, >=, <
... stuff like div provided by builtins (eg: builtins.div 6 3)
.. equality: ==, !=
. paths:
.. 2/3 interpreted as /home/pkinsky/2/3
.. paths are parsed as long as there's a slash
... ./. == current directory

. Strings/String interpolation
.. "a string"
.. ''a string''
.. "string ${interpolation}"

Lists

. seq of expressions delimited by space
.. eg [1 2 3]

Sets

. Sets are an association between a string key and a Nix expression. Keys can only be strings. When writing sets you can also use identifiers as keys.
. eg
```
nix-repl> s = {foo = "bar"; a-b = "baz"; "123" = "num"; }

nix-repl> s
{ 123 = "num"; a-b = "baz"; foo = "bar"; }



nix-repl> s.123
error: syntax error, unexpected INT, expecting ID or OR_KW or DOLLAR_CURLY or '"', at (string):1:3

nix-repl> s."123"
6

nix-repl> s.a-b
"baz"
```
. (note that 123 requires quotes for use as key or accessor)




. You cannot refer inside a set to elements of the same set:

```
nix-repl> { a = 3; b = a+4; }
error: undefined variable `a' at (string):1:10
```

. To do so, use recursive sets:

```
nix-repl> rec { a= 3; b = a+4; }
{ a = 3; b = 7; }
```

If expression

. Expressions, not statements.

```
nix-repl> a = 3
nix-repl> b = 4
nix-repl> if a > b then "yes" else "no"
"no"
```

. You can't have only the "then" branch, you must specify also the "else" branch, because an expression must have a value in all cases.

Let expression

. This kind of expression is used to define local variables to inner expressions.

```
nix-repl> let a = "foo"; in a
"foo"
```

With Expression

```
nix-repl> longName = { a = 3; b = 4; }
nix-repl> longName.a + longName.b
7
nix-repl> with longName; a + b
7
```

Laziness

```
nix-repl> let a = builtins.div 4 0; b = 6; in b
6

nix-repl> builtins.div 4 0
error: division by zero, at (string):1:1
```



Nix pill 5: functions and imports
--------------------------http://lethalman.blogspot.it/2014/07/nix-pill-5-functions-and-imports.html

. http://lethalman.blogspot.it/2014/07/nix-pill-5-functions-and-imports.html

. nameless, single parameter (haskell stylez)
```
nix-repl> x: x * 2
«lambda»

nix-repl> double = x: x*2

nix-repl> double 2
4
```

. multiparam

```
nix-repl> mul = a: (b: a * b)

nix-repl> mul 3 4
12

```
parens not required, this is also fine:
```
nix-repl> mul = a: b: a * b
```

Arguments Set/Pattern matching
```
nix-repl> mul = s: s.a*s.b
nix-repl> mul { a = 3; b = 4; }
12
nix-repl> mul = { a, b }: a*b
nix-repl> mul { a = 3; b = 4; }
12

```
pattern matching failure cases:
```
nix-repl> mul {a = 1; b = "3"; }
error: value is a string while an integer was expected, at (string):1:12

nix-repl> mul {a = 1; }
error: anonymous function at (string):1:2 called without required argument ‘b’, at (string):1:1

nix-repl> mul {a = 1; b = 3; c = 4;}
error: anonymous function at (string):1:2 called with unexpected argument ‘c’, at (string):1:1
```
fails on missing/extra attr, or attr w/ unexpected type


Default and variadic attributes

. default values:
```
nix-repl> mul = { a, b ? 2 }: a*b
nix-repl> mul { a = 3; }
6
nix-repl> mul { a = 3; b = 4; }
12
```

. variadic attributes:
. Also you can allow passing more attributes (variadic) than the expected ones:
```
nix-repl> mul = { a, b, ... }: a*b
nix-repl> mul { a = 3; b = 4; c = 2; }
```
However, in the function body you cannot access the "c" attribute. The solution is to give a name to the given set with the @-pattern:
```
nix-repl> mul = s@{ a, b, ... }: a*b*s.c
nix-repl> mul { a = 3; b = 4; c = 2; }
24
```

Imports

. The "import" function is built-in and provides a way to parse a .nix file. The natural approach is to define each component in a .nix file, then compose by importing these files.
. simple example:
.. given files:
```
$ cat a.nix
3
$ cat b.nix
4
#cat mul.nix 
a: b: a*b
```
.. can then, from nix-repl, do this:
```
nix-repl> a = import ./a.nix

nix-repl> b = import ./b.nix

nix-repl> mul = import ./mul.nix

nix-repl> mul a b
12
```
. note that the imports need to be assigned to names

. passing info into modules:
```
$ cat test.nix 
{ a, b ? 3, trueMsg ? "yes", falseMsg ? "no" }:
if a > b
  then builtins.trace trueMsg true
  else builtins.trace falseMsg false
```
can then, from nix-repl, do this:
```
nix-repl> import ./test.nix
«lambda»

nix-repl> import ./test.nix {a = 5; trueMsg = "lol jk wut";}
trace: lol jk wut
true
```

. In test.nix we return a function. It accepts a set, with default attributes b, trueMsg and falseMsg.
. builtins.trace is a built-in function that takes two arguments. The first is the message to display, the second is the value to return. It's usually used for debugging purposes.
. Then we import test.nix, and call the function with that set.


Nix pill 6: our first derivation
------------------------

. http://lethalman.blogspot.it/2014/07/nix-pill-6-our-first-derivation.html

. In this post we finally arrived to writing a derivation. Derivations are the building blocks of a Nix system, from a file system view point. The Nix language is used to describe such derivations.
. The derivation built-in function is used to create derivations. A derivation from a Nix language view point is simply a set, with some attributes. Therefore you can pass the derivation around with variables like anything else.

. The derivation function receives a set as first argument. This set requires at least the following three attributes:
.. name: the name of the derivation. In the nix store the format is hash-name, that's the name.
.. system: is the name of the system in which the derivation can be built. For example, x86_64-linux.
.. builder: it is the binary program that builds the derivation.

. current system (for system param)
```
nix-repl> builtins.currentSystem
"x86_64-linux"
```

. building a (fake) example derivation:
```
nix-repl> d = derivation { name = "myname"; builder = "mybuilder"; system = "mysystem"; }

nix-repl> d
«derivation /nix/store/z3hhlxbckx4g3n9sw91nnvlkjvyw754p-myname.drv»
```
. doesn't actually build a derivation, does create a .drv file

Digression about .drv files

. What's that .drv file? It is the specification of how to build the derivation, without all the Nix language fuzz.
. the .drv file created by the above example, pretty printed:
```
Derive(
  [("out", "/nix/store/40s0qmrfb45vlh6610rk29ym318dswdr-myname", "", "")]
, []
, []
, "mysystem"
, "mybuilder"
, []
, [ ("builder", "mybuilder")
  , ("name", "myname")
  , ("out", "/nix/store/40s0qmrfb45vlh6610rk29ym318dswdr-myname")
  , ("system", "mysystem")
  ]
```
. printed here using pp-aterm, which I can't use due to broken dep
.. same file tho, just w/o pretty printing

. drv contents summary:
.. The output paths (they can be multiple ones). By default nix creates one out path called "out".
.. The list of input derivations. It's empty because we are not referring to any other derivation. Otherwise, there would a list of other .drv files.
.. The system and the builder executable (yes, it's a fake one).
.. Then a list of environment variables passed to the builder.

Back to our fake derivation

. Let's build our really fake derivation:
```
nix-repl> :b d
these derivations will be built:
  /nix/store/z3hhlxbckx4g3n9sw91nnvlkjvyw754p-myname.drv
building path(s) ‘/nix/store/40s0qmrfb45vlh6610rk29ym318dswdr-myname’
error: a ‘mysystem’ is required to build ‘/nix/store/z3hhlxbckx4g3n9sw91nnvlkjvyw754p-myname.drv’, but I am a ‘x86_64-linux’
```

. We're doing the build inside nix-repl, but what if we don't want to use nix-repl?
.. You can realise a .drv with:
```
$ nix-store -r /nix/store/z3hhlxbckx4g3n9sw91nnvlkjvyw754p-myname.drv
```
.. You will get the same output as before.


What's in a derivation Set?

. examining sets with builtin functions:

```
nix-repl> d = derivation { name = "myname"; builder = "mybuilder"; system = "mysystem"; }
nix-repl> builtins.isAttrs d
true
nix-repl> builtins.attrNames d
[ "all" "builder" "drvAttrs" "drvPath" "name" "out" "outPath" "outputName" "system" "type" ]
```

. builtins.isAttrs -> true if arg is a set
. builtins.attrNames -> list of attribute names

. let's see where those attr names come from/what they mean

```
nix-repl> d.drvAttrs
{ builder = "mybuilder"; name = "myname"; system = "mysystem"; }
```

. 'builder', 'name', 'system' just come from the passed-in attributes which are accessible via 'drvAttrs' attr

. d.out

```
nix-repl> (d == d.out)
true
```

. 'out' is the derivation itself, seems weird but the reason is that we only have one output from the derivation. We'll see multiple outputs later.

. d.drvPath is the path of the .drv file: /nix/store/z3hhlxbckx4g3n9sw91nnvlkjvyw754p-myname.drv

. Something interesting is the type attribute. It's "derivation". Nix does add a little of magic to sets with type derivation, but not that much. To let you understand, you can create yourself a set with that type, it's a simple set:

```
nix-repl> { type = "derivation"; }
«derivation ???»
```

Referring to other derivations:

. refer to other derivations via output path

```
nix-repl> d.outPath
"/nix/store/40s0qmrfb45vlh6610rk29ym318dswdr-myname"
nix-repl> builtins.toString d
"/nix/store/40s0qmrfb45vlh6610rk29ym318dswdr-myname"
```

. for convenience, the `toString` builtin uses the outPath of a set, if present:

```
nix-repl> builtins.toString { a = "b"; }
error: cannot coerce a set to a string, at (string):1:1

nix-repl> builtins.toString { outPath = "b"; }
"b"
```

. example (ignore the `:l <nixpkgs>` bit for now:

```
nix-repl> d.outPath
"/nix/store/40s0qmrfb45vlh6610rk29ym318dswdr-myname"
nix-repl> builtins.toString d
"/nix/store/40s0qmrfb45vlh6610rk29ym318dswdr-myname"
```

. examining coreutils in the nix store:

```
ls /nix/store/*coreutils*/bin
'['       chown   dd         expand  hostid   ls      nl       pr        rmdir      shred   sum      tr        unlink
base32    chroot  df         expr    id       md5sum  nohup    printenv  runcon     shuf    sync     true      uptime
base64    cksum   dir        factor  install  mkdir   nproc    printf    seq        sleep   tac      truncate  users
basename  comm    dircolors  false   join     mkfifo  numfmt   ptx       sha1sum    sort    tail     tsort     vdir
cat       cp      dirname    fmt     kill     mknod   od       pwd       sha224sum  split   tee      tty       wc
chcon     csplit  du         fold    link     mktemp  paste    readlink  sha256sum  stat    test     uname     who
chgrp     cut     echo       groups  ln       mv      pathchk  realpath  sha384sum  stdbuf  timeout  unexpand  whoami
chmod     date    env        head    logname  nice    pinky    rm        sha512sum  stty    touch    uniq      yes
```

. can use string interpolation to refer to coreutils (string interpolation uses builtins.toString)
.. or to something in coreutils/bin

```
nix-repl> "${coreutils}/bin/true"
"/nix/store/w8vzn0lsahbd9sfh0v30x65qwq6xrpa8-coreutils-8.25/bin/true
```

An almost working derivation:

. In the previous attempt we used a fake builder, "mybuilder" which obviously does not exist. But we can use for example bin/true, which always exits with 0 (success).


```
nix-repl> :l <nixpkgs>
nix-repl> d = derivation { name = "myname"; builder = "${coreutils}/bin/true"; system = builtins.currentSystem; }
nix-repl> :b d
[...]
builder for `/nix/store/d4xczdij7xazjfm5kn4nmphx63mpv676-myname.drv' failed to produce output path `/nix/store/fy5lyr5iysn4ayyxvpnsya8r5y5bwjnl-myname'
```

. Another step forward, it executed the builder (bin/true), but the builder did not create the out path of course, it just exited with 0.
. what's the .drv for this look like?

```
Derive(
  [("out", "/nix/store/fy5lyr5iysn4ayyxvpnsya8r5y5bwjnl-myname", "", "")]
, [("/nix/store/1zcs1y4n27lqs0gw4v038i303pb89rw6-coreutils-8.21.drv", ["out"])]
, []
, "x86_64-linux"
, "/nix/store/8w4cbiy7wqvaqsnsnb3zvabq1cp2zhyz-coreutils-8.21/bin/true"
, []
, [ ("builder", "/nix/store/8w4cbiy7wqvaqsnsnb3zvabq1cp2zhyz-coreutils-8.21/bin/true")
  , ("name", "myname")
  , ("out", "/nix/store/fy5lyr5iysn4ayyxvpnsya8r5y5bwjnl-myname")
  , ("system", "x86_64-linux")
  ]
```

. note that coreutils is now in the dependency list
. note that creating a derivation doesn't build it. For that, `:b myDerivation` is required

quote:

. Instantiate/Evaluation time: 
.. the Nix expression is parsed, interpreted and finally returns a derivation set. During evaluation, you can refer to other derivations because Nix will create .drv files and we will know out paths beforehand. This is achieved with nix-instantiate.
. Realise/Build time: 
.. the .drv from the derivation set is built, first building .drv inputs (build dependencies). This is achieved with nix-store -r.


Nix pill 7: a working derivation

. goal: use bash as builder, run small script that echoes foo to the outPath ($out), build as derivation
. builder.sh:
```
declare -xp
echo foo > $out
```

using bash from nixpkgs:
```
nix-repl> :l <nixpkgs>
Added 3950 variables.
nix-repl> "${bash}"
"/nix/store/ihmkc7z2wqk3bbipfnlh0yjrlfkkgnv6-bash-4.2-p45"
```

. derivation:
```
nix-repl> d = derivation { name = "foo"; builder = "${bash}/bin/bash"; args = [ ./builder.sh ]; system = builtins.currentSystem; }
nix-repl> :b d
[...]
this derivation produced the following outputs:
  out -> /nix/store/vr786m1x8jpyg430csp6p9fdwkw1wz9z-foo
```

as expected, the out path of foo now contains a file with contents 'foo':

```
nix-repl> "${d}"
"/nix/store/vr786m1x8jpyg430csp6p9fdwkw1wz9z-foo

$ cat /nix/store/vr786m1x8jpyg430csp6p9fdwkw1wz9z-foo
foo
```

by running declare in the build script we can see the env vars available during build:

```
declare -x HOME="/homeless-shelter"
declare -x NIX_BUILD_CORES="1"
declare -x NIX_BUILD_TOP="/tmp/nix-build-foo.drv-0"
declare -x NIX_STORE="/nix/store"
declare -x OLDPWD
declare -x PATH="/path-not-set"
declare -x PWD="/tmp/nix-build-foo.drv-0"
declare -x SHLVL="1"
declare -x TEMP="/tmp/nix-build-foo.drv-0"
declare -x TEMPDIR="/tmp/nix-build-foo.drv-0"
declare -x TMP="/tmp/nix-build-foo.drv-0"
declare -x TMPDIR="/tmp/nix-build-foo.drv-0"
declare -x builder="/nix/store/i7hx6w6zy3bv53f2xm1r23ya8qbzn4is-bash-4.3-p42/bin/bash"
declare -x name="foo"
declare -x out="/nix/store/vr786m1x8jpyg430csp6p9fdwkw1wz9z-foo"
declare -x system="x86_64-linux"
```

notes: 
. no $HOME dir (/homeless-shelter) does not exist, ditto $PATH ( /path-not-set )
. $NIX_BUILD_CORES and $NIX_STORE are nix configurations
. $PWD and $TMP clearly shows nix created a temporary build directory.
. Then builder, name, out and system are variables set due to the .drv contents.


by adding args to the derivation we've changed the .drv again:

```
Derive(
  [("out", "/nix/store/w024zci0x1hh1wj6gjq0jagkc1sgrf5r-foo", "", "")]
, [("/nix/store/jdggv3q1sb15140qdx0apvyrps41m4lr-bash-4.2-p45.drv", ["out"])]
, ["/nix/store/5d1i99yd1fy4wkyx85iz5bvh78j2j96r-builder.sh"]
, "x86_64-linux"
, "/nix/store/ihmkc7z2wqk3bbipfnlh0yjrlfkkgnv6-bash-4.2-p45/bin/bash"
, ["/nix/store/5d1i99yd1fy4wkyx85iz5bvh78j2j96r-builder.sh"]
, [ ("builder", "/nix/store/ihmkc7z2wqk3bbipfnlh0yjrlfkkgnv6-bash-4.2-p45/bin/bash")
  , ("name", "foo")
  , ("out", "/nix/store/w024zci0x1hh1wj6gjq0jagkc1sgrf5r-foo")
  , ("system", "x86_64-linux")
  ]
)
```

. note that builder.sh was copied into the nix store to ensure, eg, no changes during build process

Packaging a simple C executable

Start off writing a simple.c file:
```
void main () {
  puts ("Simple!");
}
```
And its simple_builder.sh:
```
export PATH="$coreutils/bin:$gcc/bin"
mkdir $out
gcc -o $out/simple $src
```
Don't spend time understanding where those variables come from. Let's write the derivation and build it:
```
nix-repl> :l <nixpkgs>
nix-repl> simple = derivation { name = "simple"; builder = "${bash}/bin/bash"; args = [ ./simple_builder.sh ]; gcc = gcc; coreutils = coreutils; src = ./simple.c; system = builtins.currentSystem; }
nix-repl> :b simple
[...]

this derivation produced the following outputs:
  out -> /nix/store/9yllya1pqhlby9ngfs6gwy6pbbgq71s9-simple
```

result is runnable:

```
$ /nix/store/9yllya1pqhlby9ngfs6gwy6pbbgq71s9-simple/simple
Simple!
```

notes:
. we added attributes (visible as env vars to builder): gcc, coreutils, src
.. every attribute in the set will be converted to a string and passed as environment variable to the builder

Enough with nix-repl

. Drop out of nix-repl, write a simple.nix file:

```
with (import <nixpkgs> {});
derivation {
  name = "simple";
  builder = "${bash}/bin/bash";
  args = [ ./simple_builder.sh ];
  inherit gcc coreutils;
  src = ./simple.c;
  system = builtins.currentSystem;
}
```

then build using nix-build simple.nix

```
$ nix-build simple.nix
/nix/store/9yllya1pqhlby9ngfs6gwy6pbbgq71s9-simple
$ ./result/simple 
Simple!
```

. nix-build uses nix-instantiate to create a .drv file
. it then uses nix-store -r to realize the .drv file
. then it creates a symlink to the resulting nix store path as result

```
ls -al result
lrwxrwxrwx 1 pkinsky users 50 Jul 21 18:34 result -> /nix/store/9yllya1pqhlby9ngfs6gwy6pbbgq71s9-simple
```

some notes on simple.nix
. Let me underline it: "import <nixpkgs> {}" are two function calls, not one. Read it like "(import <nixpkgs>) {}".
.. The final returned value of that import is a set. To simplify it: it's a set of derivations. Using the "with" expression we drop them into the scope. We basically simulated what :l does in nix-repl, so we can easily access derivations such as bash, gcc and coreutils.
. inherit
.. Doing inherit foo, is the same as doing foo = foo. Doing inherit foo bar, is the same as doing foo = foo; bar = bar. Literally.
This syntax only makes sense inside sets. Don't think it's black magic, it's just a convenience to avoid repeating the same name twice, once for the attribute name, once for the variable in the scope.


Nix pill 8: generic builders
--------------------------


step 1: write a builder that can be used for multiple autotools projects instead of writing a builder.sh for each
(skipped)
main trick is passing in a list of build inputs, which is converted to a string:
``` 
 buildInputs = [ gnutar gzip gnumake gcc binutils coreutils gawk gnused gnugrep ];
```
the sh script then just loops over it and adds each to the path

step 2: create autotools.nix as function which accepts an atribute set then merges it with default attr set

```
pkgs: attrs:
  with pkgs;
  let defaultAttrs = {
    builder = "${bash}/bin/bash";
    args = [ ./builder.sh ];
    baseInputs = [ gnutar gzip gnumake gcc binutils coreutils gawk gnused gnugrep ];
    buildInputs = [];
    system = builtins.currentSystem;
  };
  in
  derivation (defaultAttrs // attrs)
```

. First drop in the scope the magic pkgs attribute set.
. Within a let expression we define an helper variable, defaultAttrs, which serves as a set of common attributes used in derivations.
. Finally we create the derivation with that strange expression, (defaultAttrs // attrs).
.. The // operator merges two sets, adding (or overriding if present in both, with preference to right set) attrs

```
nix-repl> { a = "b"; } // { c = "d"; }
{ a = "b"; c = "d"; }
nix-repl> { a = "b"; } // { a = "c"; }
{ a = "c"; }
```

then call our function (autotools.nix) with:

```
let
  pkgs = import <nixpkgs> {};
  mkDerivation = import ./autotools.nix pkgs;
in mkDerivation {
  name = "hello";
  src = ./hello-2.9.tar.gz;
}
```

Nix gives us the bare metal tools for creating derivations, setting up a build environment and storing the result in the nix store.
Out of this we managed to create a generic builder for autotools projects, and a function mkDerivation that composes by default the common components used in autotools projects instead of repeating them in all the packages we would write.
We are feeling the way a Nix system grows up: it's about creating and composing derivations with the Nix language.

Nix pill 9: automatic runtime dependencies
--------------------------

. http://lethalman.blogspot.it/2014/08/nix-pill-9-automatic-runtime.html

Build dependencies

. Let's start analyzing build dependencies for our GNU hello world package:
. (skipped)

Runtime dependencies

. black magic
.. seems like it shouldn't work, does
.. dump the derivation as NAR (serialization using nix's deterministic archiver), search contents for each build dependency out path
.. if found, then it's a runtime dependency

can add new phase to strip out unused paths
```
find $out -type f -exec patchelf --shrink-rpath '{}' \; -exec strip '{}' \; 2>/dev/null
```
. That is, for each file we run patchelf --shrink-rpath and strip. Note that we used two new commands here, find and patchelf. These two deserve a place in baseInputs of autotools.nix as findutils and patchelf.
. still black magic to me, tbh

. added as new phase to builder by modifying sh script:
. phases:
.. First the environment is set up
.. Unpack phase: we unpack the sources in the current directory (remember, Nix changes dir to a temporary directory first)
.. Change source root to the directory that has been unpacked
.. Configure phase: ./configure
.. Build phase: make
.. Install phase: make install
.. fixup phase: (as above)


Nix pill 10: developing with nix-shell
-----------------------

. http://lethalman.blogspot.it/2014/08/nix-pill-10-developing-with-nix-shell.html
. The nix-shell tool drops us in a shell by setting up the necessary environment variables to hack a derivation. It does not build the derivation, it only serves as a preparation so that we can run the build steps manually.
. eg:
```
$ nix-shell simple.nix
[nix-shell:~/hack_week/nix_tmp]$ make
bash: make: command not found
[nix-shell:~/hack_week/nix_tmp]$ echo $out
/nix/store/9yllya1pqhlby9ngfs6gwy6pbbgq71s9-simple
```

note that our path is empty, even of things like gcc that are declared dependencies. To run gcc, we'd need to do the following: (as in the ssh scripts)

```
[nix-shell:~/hack_week/nix_tmp]$ gcc
bash: gcc: command not found

[nix-shell:~/hack_week/nix_tmp]$ echo $gcc
/nix/store/m0pbxxvs7zz4ixk4sxyq9shwazpd3kwq-gcc-wrapper-5.3.0

[nix-shell:~/hack_week/nix_tmp]$ $gcc/bin/gcc
gcc: fatal error: no input files
compilation terminated.
```


With nix-shell we're able to drop into an isolated environment for developing a project, with the necessary dependencies just like nix-build does, except we can build and debug the project manually, step by step like you would do in any other operating system.
Note that we did never install gcc, make, etc. system-wide. These tools and libraries are available per-build.



Nix pill 11: the garbage collector
--------------------

How do we determine whether a store path is still needed? The same way programming languages with a garbage collector decide whether an object is still alive.

Programming languages with a garbage collector have an important concept in order to keep track of live objects: GC roots. A GC root is an object that is always alive (unless explicitly removed as GC root). All objects recursively referred to by a GC root are live.

In Nix there's this same concept. Instead of being objects, of course, GC roots are store paths. The implementation is very simple and transparent to the user. GC roots are stored under /nix/var/nix/gcroots. If there's a symlink to a store path, then that store path is a GC root.

```
$ls /nix/var/nix/gcroots                                                                                        1 ↵
auto  booted-system  current-system  per-user  tmp
```

Nix allows this directory to have subdirectories: it will simply recurse directories in search of symlinks to store paths.

We have the list of all live store paths, hence the rest of the store paths are dead.


Nix pill 12: the inputs design pattern
------------------------

The single repository pattern

. everything goes in nixpkgs, which is the top level nix expression with absolutely everything
. nix is lazy, so this is safe: stuff is only eval'd when needed

Packaging Graphviz

. graphviz.nix:
. using http://pkgs.fedoraproject.org/repo/pkgs/graphviz/graphviz-2.38.0.tar.gz/5b6a829b2ac94efcd5fa3c223ed6d3ae/graphviz-2.38.0.tar.gz

```
let
  pkgs = import <nixpkgs> {};
  mkDerivation = import ./autotools.nix pkgs;
in mkDerivation {
  name = "graphviz";
  src = ./graphviz-2.38.0.tar.gz;
}
```

. note: fails with c build error, skipping
. this is basically about building a local 2-package version of nixpkgs

Nix pill 13: the callPackage design pattern
-----------------------

. http://lethalman.blogspot.it/2014/09/nix-pill-13-callpackage-design-pattern.html
. note: just skimmed

. build a function callPackage (probably exists in default nixpkgs somewhere)
.. Import the given expression, which in turn returns a function.
.. Determine the name of its arguments.
.. Pass default arguments from the repository set, and let us override those arguments.
. eg:
```
rec {
  lib1 = import package1.nix { inherit input1 input2 ...; };
  program2 = import package1.nix { inherit inputX inputY lib1 ...; };
}
```
becomes
```
{
  lib1 = callPackage package1.nix { };
  program2 = callPackage package2.nix { someoverride = overriddenDerivation; };
}
```

Nix pill 14: the override design pattern
-----------------------


override, eg:
```
mygraphviz = graphviz.override { gd = customgd; };
```

via cool trick

```
{
  makeOverridable = f: origArgs:
    let
      origRes = f origArgs;
    in
      origRes // { override = newArgs: f (origArgs // newArgs); };
}
```


simple usage:

```
nix-repl> :l lib.nix
Added 1 variables.

nix-repl> f = {a,b}: {result = a + b;}

nix-repl> f {a = 3; b =5;}
{ result = 8; }

nix-repl> res = makeOverridable f {a = 3; b = 5;}

nix-repl> res
{ override = «lambda»; result = 8; }

nix-repl> res.override {a = 10;}
{ result = 15; }
```

but then the res isn't overridable, so use instead:

```
rec {
  makeOverridable = f: origArgs:
    let
      origRes = f origArgs;
    in
      origRes // { override = newArgs: makeOverridable f (origArgs // newArgs); };
}
```

now res also has override function:
```
nix-repl> :l lib.nix
Added 1 variables.

nix-repl> f {a = 3; b =5;}
{ result = 8; }

nix-repl> res = makeOverridable f {a = 3; b = 5;}

nix-repl> res
{ override = «lambda»; result = 8; }

nix-repl> res.override {a = 10;}
{ override = «lambda»; result = 15; }
```



