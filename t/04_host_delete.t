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

ok_part('more involved tests..');

for my $name ( qw/
moonshine.dyercpa.internal
allegoree
moonshine.dyercpa.internalisima
moonshine
moonshine.unique
/){

   printf STDERR "\n%s\n# $name\n\n",'- 'x30;

   my($id, $idstring );

   ok( (($id, $idstring) = host_add($dbh, $name)), 'host_name_add()');
   validate_argument_id($id) or die;
   validate_argument_host_idstring($idstring) or die;



   # should be able tofetch all ways
   my @args = ( $id, $idstring, $name );

   # choose arg ar random
   for my $arg ( $args[int rand scalar @args] ){

      warn("\n# resolve_argument_to_host() via argument '$arg'\n");
      my($rid, $rname, $ridstring )= resolve_argument_to_host($dbh, $arg);

      ok( ($rid and $rname and $ridstring ), 'resolved it..' ) 
         or warn("$rid, $rname, $ridstring");
      
      ok( ($rid == $id ) and ( $rname eq $name ) and ( $ridstring eq $idstring ) ) or die('NOT AS EXPECTED');
     
      ok(  host_delete( $dbh, $arg ), 'host_delete()' );

      ok(( ! resolve_argument_to_host($dbh, $arg) ),'calling resolve_argument_to_host() second time now fails, beacuse it was deleted');
      
      # if you want it to work next iteration.. must recreate..
      ok(  host_add($dbh, $name) );
      warn "# good.. ended.. \n";

   }




   warn("\n\n");
   

}
















sub ok_part {
   printf STDERR "\n\n%s\nPART %s %s\n%s\n\n",
      '='x80, $_part++, "@_", '- 'x30;
}


