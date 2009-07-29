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


ok_part('basic add test');


ok host_add($dbh, 'some.crazy.name'), 'host_add()';
ok ! host_add($dbh, 'some.c razy.name'), 'host_add()';
my ( $a, $b ) = host_add($dbh, 'some.superduper.name');
ok( $a and $b );


ok_part('more involved tests..');



for my $name ( qw/
moonshine.dyercpa.internal
hilljack.dyercpa.internal
wingnut.dyercpa.internal
allegoree
/){

   printf STDERR "\n%s\n# $name\n\n",'- 'x30;

   my($id, $idstring );

   ok( (($id, $idstring) = host_add($dbh, $name)), 'host_name_add()');
   ok validate_argument_id($id);
   ok validate_argument_host_idstring($idstring);

   warn("# id $id, idstring $idstring\n");


   # should be able tofetch all ways
   for my $arg ( $id, $idstring, $name ){
      warn("#   - resolve_argument_to_host() via argument '$arg'\n");
      my($rid, $rname, $ridstring )= resolve_argument_to_host($dbh, $arg);

      ok( $rid and $rname and $ridstring ) or warn("$rid, $rname, $ridstring");
      
      ok $rid == $id;
      ok $rname eq $name;
      ok $ridstring eq $idstring;
      warn("\n");
   }




   warn("\n\n");
   

}
















sub ok_part {
   printf STDERR "\n\n%s\nPART %s %s\n%s\n\n",
      '='x80, $_part++, "@_", '- 'x30;
}


