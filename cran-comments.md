## Test environments

- local OS X install (R 3.6.1)
- ubuntu 14.05 (on travis-ci with older and release)
- winbuilder (older, release and devel)
- rhub::check_for_cran()

## R CMD check results

There were no ERROR, WARNING or NOTE. 

## Reverse dependencies

I could not test with package nlmixr as I am not able to install it. 

There is 1 error with pacakge export because of deprecation of `ph_with_flextable_at`. 
I have warned and also proposed a patch (https://github.com/tomwenseleers/export/pull/20) 
on 23 Nov 2019 but it has not been reviewed yet.
