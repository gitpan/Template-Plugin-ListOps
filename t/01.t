###########################################
# Test data

$data = {
         'A'  => [ qw(A A C B) ],
         'U'  => [ 'A',undef,'Z' ],
        };

$test = "01";
###########################################

use Template;
use IO::File;

$runtests=shift(@ARGV);
if ( -f "t/test.pl" ) {
  require "t/test.pl";
} elsif ( -f "test.pl" ) {
  require "test.pl";
} else {
  die "ERROR: cannot find test.pl\n";
}

test($test,$data,$runtests);

