# [NormEZ]

Coding-style checker for Epitech students. This program analyzes your C source files for [Epitech coding-style] violations.

*FR:* Moulinette de norme pour les étudiants d'Epitech. Cette norminette cherche des erreurs de [norme Epitech][Epitech coding-style] dans vos fichers de code source C.

<img alt="Epitech logo" src="/artwork/epitech-logo.png" width="304" height="144"/>

## Table of contents

* __[Getting started](#getting-started)__
  * [Requirements](#requirements)
  * [How to use NormEZ?](#how-to-use-normez)
* __[Features](#features)__
* __[To-do](#to-do)__
* __[Bugs](#bugs)__
  * [Known issues](#known-issues)
  * [Report a bug](#report-a-bug)
* __[Getting involved](#getting-involved)__
  * [Share](#share)
  * [Contribute](#contribute)
* __[Author](#author)__

## Getting started

### Requirements

 - [Ruby](https://www.ruby-lang.org/en/)

#### Installing Ruby on Fedora (Epitech's dump 2017)

```
sudo dnf install ruby
```

### How to use NormEZ?

 - Clone the repository:
```
git clone https://github.com/ronanboiteau/NormEZ
```
 - Copy the `NormEZ.rb` executable in your project repository.
 - Run NormEZ:
```
ruby NormEZ.rb
```
 - NormEZ will recursively search for `.c` and `.h` files to analyze in your current directory.

## Features

Here are the [Epitech coding-style] violations checked by NormEZ:<br/>
Lines with too many columns (> 80).<br/>
<img alt="Major infraction" src="/artwork/direction_arrow_red_up.png" width="11" height="12"/> Forbidden files: every regular file that does not match `Makefile`, `*.c` or `*.h` (ex: `*.o`, `*.gch`, `bsq`, ...).<br/>
*[Not exhaustive]* Too broad filenames (ex: `string.c`, `algo.c`, `my_algorithm.c`, ...).<br/>
Missing or corrupted header.<br/>
Missing or corrupted header in `Makefile`.<br/>
Functions that contain more than 20 lines.<br/>
Several semicolon-separated assignments on the same line.<br/>
Forbidden keyword (`goto`).<br/>
*[Not exhaustive]* Forbidden function (`printf()`, `dprintf()`, `atoi()`, `memcpy()`, `scanf()`, `strlen()`, `strdup()`, ...).<br/>
Too many `else if` statements.<br/>
Trailing space(s) and/or tabulation(s) at the end of a line.<br/>
Space(s) in indentation.<br/>
Too many functions in file (> 5).<br/>
Functions with no parameters that don't take void as argument in their declaration.<br/>
Functions with too many arguments (> 4).<br/>
Missing space after keyword.<br/>
Misplaced pointer symbol(s).<br/>
Filenames that don't respect the [snake_case naming convention](https://en.wikipedia.org/wiki/Snake_case).<br/>
Macros used for constants.<br/>
Macros containing multiple assignments.<br/>
Misplaced comments.<br/>
Missing  space after comma.<br/>
Missing space around binary or ternary operator (`=`, `==`, `!=`, `<=`, `>=`, `&&`, `||`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `^=`, `|=`, `|`, `^`, `>>`, `<<`, `>>=`, `<<=`).<br/>
Extra space after unary operators (`!`, `sizeof`, `++`, `--`).<br/>
Condition and assignment on the same line.<br/>
Directory names that don't respect the [snake_case naming convention](https://en.wikipedia.org/wiki/Snake_case).<br/>

## To-do

Here are the [Epitech coding-style] violations ***NOT YET*** checked by NormEZ:
Wrong indentation level in `.c` and `.h` files.<br/>
Wrong indentation level in pre-processor directives.<br/>
Functions must be separated by *one and only one* empty line in `.c` files.<br/>
Extra space between function name and opening parenthesis.<br/>
Misplaced curly brackets.<br/>
Multiple variables declared on the same line.<br/>
Variable not declared at the beginning of function.<br/>
Missing empty line after variable declarations.<br/>
Extra empty lines.<br/>
Typedef not ending with `_t`<br/>
Identifiers that don't respect the [snake_case naming convention](https://en.wikipedia.org/wiki/Snake_case).<br/>
Macros, global constants or enums that don't respect the SNAKE_CASE convention (uppercase [snake_case](https://en.wikipedia.org/wiki/Snake_case)).<br/>
Nested conditonal branchings (depth > 2).<br/>
Function prototypes, typedefs, global variables, macros or static inline functions in `.c` source files.<br/>
Header files not protected against double inclusion<br/>

## Bugs

### Known issues

 - NormEZ doesn't make the difference between strings/comments & code. Examples: a commented forbidden function will be flagged, as well as a commented `;` (multiple assignments on the same line), etc.

### Report a bug

If you found a bug that isn't listed above in as a known issue, feel free to [create a GitHub issue](https://github.com/ronanboiteau/NormEZ/issues).

## Getting involved

### Share

 - Leave NormEZ [a star](https://github.com/ronanboiteau/NormEZ/stargazers)
 - Share the link to this repository with your friends at Epitech

### Contribute

You want to add awesome features to NormEZ? Here's how:
 1. [Fork](https://github.com/ronanboiteau/NormEZ/network/members) NormEZ
 2. Commit & push a new feature to the forked repository
 3. Open a [pull request](https://github.com/ronanboiteau/NormEZ/pulls) so I can merge your work in this repository :)

## Author

* **Ronan Boiteau** ([GitHub](https://github.com/ronanboiteau) / [LinkedIn](https://www.linkedin.com/in/ronanboiteau/))

<!-- Links -->
[Epitech coding-style]: /epitech_c_coding_style.pdf
[NormEZ]: https://github.com/ronanboiteau/NormEZ
