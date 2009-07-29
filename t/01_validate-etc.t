use Test::Simple 'no_plan';
use strict;
use lib './lib';
use Cwd;
use vars qw($_part $cwd);
$cwd = cwd();
use Alister::Base::Hosts ':all';

ok_part("validate..");
ok validate_argument_id(1), 'validate_argument_id()';
ok ! validate_argument_id(0), 'validate_argument_id()';
ok ! validate_argument_id('sdf'), 'validate_argument_id()';
ok validate_argument_id(99), 'validate_argument_id()';

ok validate_argument_host_name('moonshine.dyercpa.internal'),  'validate_argument_host_name()';
ok validate_argument_host_name('moonshine.dyercpa.internal'),  'validate_argument_host_name()';
ok validate_argument_host_name('hilljack.dyercpa.internal'),  'validate_argument_host_name()';
ok validate_argument_host_name('nicotine'),  'validate_argument_host_name()';
ok validate_argument_host_name('wingnut.dyercpa.internal'),  'validate_argument_host_name()';
ok ! validate_argument_host_name('this has spaces'),  'validate_argument_host_name()';
ok ! validate_argument_host_name(''),  'validate_argument_host_name()';



for ( 0 .. 10 ){
   my $string;
   ok( $string = generate_host_idstring(),'generate_host_idstring()' );
   ok( validate_argument_host_idstring($string),'validate_argument_host_idstring()'); 
}

ok( ! validate_argument_host_idstring('this has spaces'),'validate_argument_host_idstring()'); 
ok( ! validate_argument_host_idstring('-funnychars'),'validate_argument_host_idstring()'); 
















sub ok_part {
   printf STDERR "\n\n===================\nPART %s %s\n==================\n\n",
      $_part++, "@_";
}


