# NormEZ

Coding-style checker for Epitech students.

## Requirements

 - [Ruby](https://www.ruby-lang.org/en/)

### Installing Ruby on Fedora (Epitech's dump 2017)

```
sudo dnf install ruby
```

## How to use NormEZ?

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

Here are the Epitech coding-style rules checked by NormEZ:
 - Lines with too many columns (> 80)
 - Forbidden files: every regular file that does not match `Makefile`, `*.c` or `*.h` (ex: `*.o`, `*.gch`, `bsq`, ...)
 - Too broad filenames (ex: `string.c`, `algo.c`, `my_algorithm.c`, ...)

## Author

* **Ronan Boiteau** ([GitHub](https://github.com/ronanboiteau) / [LinkedIn](https://www.linkedin.com/in/ronanboiteau/))
