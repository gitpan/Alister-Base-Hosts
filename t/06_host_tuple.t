use Test::Simple 'no_plan';
use strict;
use lib './lib';
require './t/testing.pl';
use Cwd;
use vars qw($_part $cwd);
$cwd = cwd();
use Alister::Base::Hosts ':all';

$Alister::Base::Hosts::DEBUG = 1;


my $dbh = get_testing_dbh();

ok($dbh, 'got testing dbh');

# can we setup  .. ?
ok( table_reset_hosts($dbh), 'table_reset_hosts()' );


ok ! resolve_argument_to_host($dbh, 'bogusone'), '_resolve_arg_to_host()';
ok ! resolve_argument_to_host($dbh, 'bogusone2'), '_resolve_arg_to_host()';




ok( my($i, $s) = host_add($dbh, 'tryme'), 'host_add()');


ok_part('doit');

ok validate_host_tuple( $dbh, 'tryme', $s ), 'validate_host_tuple()';
ok ! validate_host_tuple( $dbh, 'tryme', '12341234123412341234123412341234' ), 'validate_host_tuple()';
ok ! validate_host_tuple( $dbh, 'tryme.bogus', $s ), 'validate_host_tuple()';
ok validate_host_tuple( $dbh, 'tryme', $s ), 'validate_host_tuple()';













sub ok_part {
   printf STDERR "\n\n%s\nPART %s %s\n%s\n\n",
      '='x80, $_part++, "@_", '- 'x30;
}


