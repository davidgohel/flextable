## Test environments

- local OS X install (R 3.4.2)
- ubuntu 12.04 (on travis-ci with older and release)
- with package rhub and the following platforms:
  * macos-elcapitan-release
  * macos-mavericks-oldrel
  * debian-gcc-devel
  * debian-gcc-patched
  * debian-gcc-release
- winbuilder (older, release and devel)

## R CMD check results

There were no ERROR, WARNING or NOTE. 

## Reverse dependencies

There were 1 ERROR, 2 WARNINGs and no NOTE. These are not related to package 
flextable but to missing pandoc-citeproc on my system.

Checked huxtable: 1 error  | 1 warning  | 0 notes
Checked jtools  : 1 error  | 1 warning  | 0 notes
