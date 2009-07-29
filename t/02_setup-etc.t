use Test::Simple 'no_plan';
use strict;
use lib './lib';
require './t/testing.pl';
use Cwd;
use vars qw($_part $cwd);
$cwd = cwd();
use Alister::Base::Hosts ':all';



my $dbh = get_testing_dbh();

ok($dbh, 'got testing dbh');

# can we setup  .. ?
ok( table_reset_hosts($dbh), 'table_reset_hosts()' );


















sub ok_part {
   printf STDERR "\n\n===================\nPART %s %s\n==================\n\n",
      $_part++, "@_";
}


