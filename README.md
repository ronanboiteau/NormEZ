[<img alt="NormEZ logo" src="/artwork/normez-logo.png" width="400px"/>](https://github.com/ronanboiteau/NormEZ)

Coding-style checker for Epitech students. This program analyzes your C source files for [Epitech coding-style] violations.

*FR: Moulinette de norme pour les étudiants d'Epitech. Cette norminette cherche des erreurs de [norme Epitech][Epitech coding-style] dans vos fichers de code source C.*

## Table of contents

* __[Getting started](#getting-started)__
  * [Requirements](#requirements)
  * [How to use NormEZ?](#how-to-use-normez)
    * [Manual installation](#manual-installation)
    * [Arch Linux](#arch-linux)
* __[Options](#options)__
* __[Features](#features)__
* __[To-do](#to-do)__
* __[Bugs](#bugs)__
  * [Known issues](#known-issues)
  * [Report a bug](#report-a-bug)
* __[Getting involved](#getting-involved)__
  * [Share](#share)
  * [Contribute](#contribute)
  * [Contributors](#contributors)

## Getting started

### Requirements

 - [Ruby](https://www.ruby-lang.org/en/)

#### Installing Ruby on Fedora (Epitech's dump 2017)

```
sudo dnf install ruby
```

### How to use NormEZ?

#### Manual installation

 1. Clone the repository:
```
git clone https://github.com/ronanboiteau/NormEZ
```
 2. Copy the `NormEZ.rb` executable in your project repository.
 3. Run NormEZ:
```
ruby NormEZ.rb
```
 4. NormEZ will recursively search for `.c` and `.h` files to analyze in your current directory.

#### Arch Linux

[AUR package](https://aur.archlinux.org/packages/normez/) maintained by [Florian Glorioz](https://github.com/Hapique).

 1. Install NormEZ:
```
yaourt -S normez
```
 2. Run NormEZ with the following command:
```
normez
```

## Options

 - `-u` or `--no-update`: don't check for NormEZ updates
 - `-f` or `--ignore-files`: ignore forbidden files
 - `-m` or `--ignore-functions`: ignore forbidden functions
 - `-i` or `--ignore-all`: ignore forbidden files & forbidden functions (same as `-fm`)
 - `-c` or `--colorless`: disable all styling on output

## Features

Here are the [Epitech coding-style] violations checked by NormEZ.

<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> = major infraction<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> = minor infraction<br/>

<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Lines with too many columns (> 80).<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Forbidden files: every regular file that does not match `Makefile`, `*.c` or `*.h` (ex: `*.o`, `*.gch`, `bsq`, ...) & that is not mentioned in a [`.gitignore`](https://git-scm.com/docs/gitignore) file located in your current working directory.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> *[Not exhaustive]* Too broad filenames (ex: `string.c`, `algo.c`, `my_algorithm.c`, ...).<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Missing or corrupted header in sources files (`.c`), headers (`.h`) & `Makefile`s.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Functions that contain more than 20 lines.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Several semicolon-separated assignments on the same line.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> *[Not exhaustive]* Forbidden functions (`printf()`, `dprintf()`, `atoi()`, `memcpy()`, `scanf()`, `strlen()`...).<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Trailing space(s) and/or tabulation(s) at the end of a line.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Filenames that don't respect the [snake_case] naming convention.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Condition and assignment on the same line.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Directory names that don't respect the [snake_case] naming convention.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Too many functions in file (> 5).<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Functions with no parameters that don't take void as argument in their declaration.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Functions with too many arguments (> 4).<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Space(s) in indentation.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Missing space after keyword.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Misplaced pointer symbol(s).<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Macros used for constants.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Macros containing multiple assignments.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Too many `else if` statements.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Misplaced comments.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Missing space after comma.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Missing space around binary or ternary operator (`=`, `==`, `!=`, `<=`, `>=`, `&&`, `||`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `^=`, `|=`, `|`, `^`, `>>`, `<<`, `>>=`, `<<=`).<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Extra space after unary operators (`!`, `sizeof`, `++`, `--`).<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Forbidden keyword (`goto`).<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Functions must be separated by *one and only one* empty line in `.c` files.<br/>

## To-do

Here are the [Epitech coding-style] violations ***NOT YET*** checked by NormEZ.

<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> = major infraction<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> = minor infraction<br/>

<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Typedef not ending with `_t`.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Identifiers that don't respect the [snake_case] naming convention.<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Macros, global constants or enums that don't respect the SNAKE_CASE convention (uppercase [snake_case]).<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="12" height="12"/> Function prototypes, typedefs, global variables, macros or static inline functions in `.c` source files.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Single-letter identifiers shouldn't be named `l` (lowercase `L`) or `o` to avoid confusions.</br>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Nested conditonal branchings (depth > 2).<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Header files not protected against double inclusion<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Wrong indentation level in `.c` and `.h` files.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Wrong indentation level in pre-processor directives.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Extra space between function name and opening parenthesis.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Misplaced curly brackets.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Multiple variables declared on the same line.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Variable not declared at the beginning of function.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Missing empty line after variable declarations.<br/>
<img alt="Minor infraction" src="/artwork/direction_arrow_green_down.png" width="12" height="12"/> Extra empty lines in function.<br/>

## Bugs

### Known issues

 - NormEZ doesn't make the difference between strings/comments & code. Examples: a commented forbidden function will be flagged, as well as a commented `;` (multiple assignments on the same line), etc.
 - The check for functions containing more than 20 lines doesn't work yet with the new coding style v3.1. [See related issue.](https://github.com/ronanboiteau/NormEZ/issues/20)

### Report a bug

If you found a bug that isn't listed above in as a known issue, feel free to [create a GitHub issue](https://github.com/ronanboiteau/NormEZ/issues).

## Getting involved

### Share

 - Enjoying NormEZ? Leave it [a star](https://github.com/ronanboiteau/NormEZ/stargazers) to show your support :)
 - And share the link to this repository with your friends at Epitech!

### Contribute

You want to add awesome features to NormEZ? Here's how:
 1. [Fork](https://github.com/ronanboiteau/NormEZ/network/members) NormEZ
 2. Commit & push a new feature to the forked repository
 3. Open a [pull request](https://github.com/ronanboiteau/NormEZ/pulls) so I can merge your work in this repository :)

### Contributors

[Here](https://github.com/ronanboiteau/NormEZ/graphs/contributors) is the list of NormEZ's contributors. Thanks to everyone who helped developing this project!

<!-- Links -->
[Epitech coding-style]: /epitech_c_coding_style.pdf
[snake_case]: https://en.wikipedia.org/wiki/Snake_case
