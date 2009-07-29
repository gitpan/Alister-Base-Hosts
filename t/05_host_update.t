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
     

      my $newname;
      ( $newname.= (qw/dog cat bird tree /)[int rand 4] ) for (0 .. 4);
      warn("# newname: $newname\n");
      my $hid;
      ok( $hid = host_name_change($dbh, $arg, $newname), 'host_name_change()' );

      # if it worked.. then we can resolve 
      my($arid, $arname, $aridstring )= resolve_argument_to_host($dbh, $newname);
      
      ok( ($arid and $arname and $aridstring), "can resolve afterwards");

      #host_idstring_change()


      #that should fail:
      ok( ! host_name_change($dbh, $arg, 'bad new name'), 'host_name_change()' );
      ok( ! host_name_change($dbh, 'bogus arg', 'ok.new.name'), 'host_name_change()' );
      ok( ! eval{ host_name_change($dbh, 'ok.new.name') }, 'host_name_change()' );

      ok( ! host_name_change($dbh, 'i.am.valid.but.no', 'ok.new.name.again'), 'host_name_change() one we know does not exist' );

      # now do idstring!!

      my $newstring = generate_host_idstring(); 
      ok( host_idstring_change($dbh, $arg, $newstring), 'host_idstring_change()' );
      my($brid, $brname, $bridstring )= resolve_argument_to_host($dbh, $newstring);
      ok (($brid and $brname and $bridstring) );

      ok( $brid == $hid );





      warn "# good.. ended.. \n";

   }




   warn("\n\n");
   

}

my($bid, $bidstring, $bid2, $bidstring2 );
ok( (($bid, $bidstring) = host_add($dbh, 'basic.control.name')), 'host_name_add()');
# if we try to change one to existing name.. should nor work
ok( (($bid2, $bidstring2) = host_add($dbh, 'basic.control.name2')), 'host_name_add()');

ok( ! host_name_change($dbh, 'basic.control.name', 'basic.control.name2'), 'host_name_change() should fail if we change to existing name' );


ok( host_name_change($dbh, 'basic.control.name', 'basic.control.namehaha'), 'host_name_change()' );









sub ok_part {
   printf STDERR "\n\n%s\nPART %s %s\n%s\n\n",
      '='x80, $_part++, "@_", '- 'x30;
}


