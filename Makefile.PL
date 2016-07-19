#! perl

use strict;
use warnings;
use inc::Module::Install;

name 'PGPLOT-Device';
license 'gpl3';
auto_license( holder => 'Smithsonian Astrophysical Observatory' );
all_from 'lib/PGPLOT/Device.pm';

readme_from;
readme_from '', { format => 'md' };;

author_tests( 'xt' );

tests_recursive;

cpanfile;

WriteAll;
