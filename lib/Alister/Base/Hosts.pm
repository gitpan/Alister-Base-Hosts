package Alister::Base::Hosts;
use strict;
use vars qw($VERSION @EXPORT_OK %EXPORT_TAGS @ISA $TABLE_NAME $SQL_LAYOUT);
use Exporter;
use LEOCHARRE::Debug;
use Carp;
$VERSION = sprintf "%d.%02d", q$Revision: 1.2 $ =~ /(\d+)/g;
@ISA = qw/Exporter/;
@EXPORT_OK = qw(
validate_argument_id 
validate_argument_host_name
validate_argument_host_idstring
generate_host_idstring
table_create_hosts
table_reset_hosts
resolve_argument_to_host
host_add
host_delete
host_name_change
host_idstring_change
validate_host_tuple
);
%EXPORT_TAGS = ( all => \@EXPORT_OK );
$TABLE_NAME = 'hosts';
$SQL_LAYOUT ="CREATE TABLE $TABLE_NAME (
   id int(20) AUTO_INCREMENT PRIMARY KEY,   
   name varchar(32) UNIQUE NOT NULL,
   idstring varchar(32) UNIQUE NOT NULL
);";




sub table_create_hosts { _dbh_do_sql_layout( $_[0], $SQL_LAYOUT ) }
sub table_reset_hosts { $_[0]->do("DROP TABLE IF EXISTS $TABLE_NAME"); table_create_hosts($_[0]) }

sub validate_argument_id { ( $_[0] and $_[0]=~/^\d+$/) ? $_[0] : undef } # because can't be '0' for an id
sub validate_argument_host_name { ($_[0] and $_[0]=~/^[0-9a-zA-Z\.]{1,32}$/ ) ? $_[0] : undef }
sub validate_argument_host_idstring { ($_[0] and $_[0]=~/^\d{32}$/ ) ? $_[0] : undef }

sub generate_host_idstring { my $v ; $v.= int rand 10 for 0 .. 31 ; $v } # rand 10 will not include 10, up to 9



# host_register
# compare this to Alister::Base::Sums::sum_add(), it will attempt to brute force add
# and if it fails, we return what it would have if it succeeded
sub host_add {
   my( $id, $dbh, $host_name, $idstring ) = ( undef, @_);

   validate_argument_host_name($host_name)
      or warn("Bad host name: '$host_name'")
      and return;
   
   # gen an idstring for this hostname ...
   $idstring ||= generate_host_idstring();


   my $sth = $dbh->prepare("INSERT INTO $TABLE_NAME (name, idstring) values (?,?)");
   debug(" sth made / ");
   my $result = $sth->execute($host_name, $idstring);
   debug("executed");

  (!defined $result )# then already in.. likely   
      and warn("Cannot add host '$host_name', '$idstring' already exists?" . $dbh->errstr)
      and return;

  ($result eq '0E0')
      and confess("could not register host:'$host_name', '$idstring' ".$dbh->errstr);

   $id = $dbh->last_insert_id( undef, undef, $TABLE_NAME, undef )
         or confess("can't get last insert id for '$TABLE_NAME' table");

   debug("last insert id $id.");
   $sth->finish;   
   return ($id, $idstring);
}



sub host_delete {
   my( $dbh, $arg ) = @_;
   $arg or confess("Missing arguments");

   my($id,$name,$idstring) = resolve_argument_to_host($dbh, $arg)
      or warn("Cannot resolve argument '$arg' to a host, no matching id, idstring, or host name")
      and return;
   
   debug("Deleting host $id, $name, $idstring, via argument '$arg'");

   my $sth = $dbh->prepare("DELETE FROM $TABLE_NAME WHERE id=?");
   my $result = $sth->execute($id);
   $sth->finish;
   if ((! defined $result) or ($result eq '0E0')){
      warn("Did not delete host arg '$arg', id '$id', error?".$dbh->errstr);
      return;
   }

   1;
}



sub host_name_change {
   my($dbh, $arg, $newname)= @_;
   ($arg and $newname ) or confess("Missing arguments");

   validate_argument_host_name($newname)
      or warn("bad host name '$newname'")
      and return;

   my($id,$name,$idstring) = resolve_argument_to_host($dbh, $arg)
      or warn("Cannot resolve argument '$arg' to a host, no matching id, idstring, or host name")
      and return;

   debug("Renaming host $id, $name, $idstring, via argument '$arg'");
   ( $newname eq $name ) and warn("New name and old name are the same.") and return;

   my $sth = $dbh->prepare("UPDATE $TABLE_NAME SET name = ? WHERE id = ?");
   my $result = $sth->execute( $newname , $id );
   if ((! defined $result) or ($result eq '0E0')){
      warn("Failed, arg '$arg', id '$id', error?".$dbh->errstr);
      return;
   }
   $id;
}

sub host_idstring_change {
   my($dbh, $arg, $newstring)= @_;
   ($arg and $newstring ) or confess("Missing arguments");

   validate_argument_host_idstring($newstring)
      or warn("bad idstring '$newstring'")
      and return;

   my($id,$name,$idstring) = resolve_argument_to_host($dbh, $arg)
      or warn("Cannot resolve argument '$arg' to a host, no matching id, idstring, or host name")
      and return;

   debug("Changing idstring host $id, $name, $idstring, via argument '$arg'");
   ( $idstring eq $newstring ) 
      and warn("New name and old name are the same.") 
      and return;


   my $sth = $dbh->prepare("UPDATE $TABLE_NAME SET name = ? WHERE id = ?");
   my $result = $sth->execute( $newstring , $id );
   if ((! defined $result) or ($result eq '0E0')){
      warn("Failed, arg '$arg', id '$id', error?".$dbh->errstr);
      return;
   }
   $id;
}





# resolve arg to host 
sub resolve_argument_to_host { # MASTER
   my $dbh = shift;

   my $arg = $_[0] or confess('missing arg');

   my($id,$name,$idstring,
      $sql, $sth);

   if (validate_argument_host_idstring($arg)){ # MUST HAPPEN FIRST!
      # BECAUSE validate_argument_id() and  validate_argument_host_name() prove true on idstrings!!!
      debug("arg '$arg' looks like idstring");
      $sql= "SELECT * FROM $TABLE_NAME WHERE idstring=? LIMIT 1";
   }
   elsif (validate_argument_id($arg)){
      debug("arg '$arg' looks like id");
      $sql= "SELECT * FROM $TABLE_NAME WHERE id=? LIMIT 1";
   }
   elsif (validate_argument_host_name($arg)){
      debug("arg '$arg' looks like host name");
      $sql= "SELECT * FROM $TABLE_NAME WHERE name=? LIMIT 1";
   }
   else {
      warn("Dont know what arg '$arg' is supposed to be, doesnt look like id, idstring, or host name");
      return;
   }

   debug("preparing sql: '$sql'\narg: '$arg'");

   $sth = $dbh->prepare($sql);

   my $result = $sth->execute($arg);   
   if ($result eq '0E0'){ # would mean no results
      warn("Not such host.");
      $sth->finish;
      return;
   }

   my $row;
   unless( $row = $sth->fetch ){
         $sth->finish;
         warn("No such host [b].");
         return;
   }
   $sth->finish;

   ($id, $name, $idstring) = @{$row};

   unless( $id and $name and $idstring) {         
         warn("No such host [c].");
         return;      
   }
   
   wantarray ? ($id, $name, $idstring) : [$id, $name, $idstring];
}







#sub _verify_hostname_hostidstring_combo {
sub validate_host_tuple {
   my ($dbh, $host_name, $idstring) = @_;
   $host_name or confess("missing host name arg");
   $idstring or confess("missing idstring arg");
   validate_argument_host_idstring($idstring)
      or warn("Argument '$idstring' not a valid idstring")
      and return;
   validate_argument_host_name($host_name)
      or warn("Argument '$host_name' not valid host name")
      and return;

   debug("looking up id for host name/idstring tupe: '$host_name/$idstring' in alister server database");

   _dbh_fetch_one( 
      $dbh, 
      "SELECT id FROM $TABLE_NAME WHERE idstring = ? AND name = ? LIMIT 1",
      $idstring, 
      $host_name 
   );  
}









# helper subs... 

sub _dbh_do_sql_layout {
   my ($dbh, $layout) = @_;

   $layout =~s/\t+| {2,}/ /g;
   
   for my $sql ( split( /\;/, $layout) ){
      $sql=~/\w/ or next;
      debug("layout [$sql]\n");
      debug('-');
      $dbh->do($sql) 
         or die($dbh->errstr);
   }
   debug("Done.");
   #$self->dbh->commit; should commit at script level instead
   1;
}

sub _dbh_fetch_one {
   my $dbh = shift;
   my $statement = shift;
   my @args = @_;
   
   my $sth     = $dbh->prepare($statement);
   my $result  = $sth->execute(@args); # dies if error
   
   if ($result eq '0E0'){ # would mean no results
      $sth->finish;
      return;
   }
   my $val = $sth->fetch->[0];
   $sth->finish;
   $val;
}



1;
# see lib/Alister/Base/Hosts.pod

