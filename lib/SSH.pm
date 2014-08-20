package SSH;
use strict;
use warnings;
use Data::Dumper;
use Time::localtime;
use Exporter qw(import);
use Net::OpenSSH;

our @EXPORT_OK = qw(PullAuthentication OpenSSHPipe Logger);


sub PullAuthentication
{
  #Here we need to be able to retreive credentials for SSH.
  #Maybe obtain with login to site? Using GET/POST HTML FORM
  #For testing purpoes, I will hardcode it in for now...

  my $user = "root";
  my $password = "abc123";

  return ($user, $password);
}

sub OpenSSHPipe
{
  my $host = shift;
  if(VerifyPackages()){
    Logger("Necessary packages appear to be installed...");

    my ($user, $pass) = PullAuthentication();

    Logger("Attempting to open SSH session to $host as $user");

    #Verify input to make sure its valid first!
    my $AuthedHost = CheckInput($host, $user, $pass);

    #Handle incorrect login here???
    #do something .... unless ($AuthedHost);

    #Create new OpenSSH instance pipeline and return the instance.
    my $ssh = Net::OpenSSH->new($AuthedHost);
    $ssh->error and die "Can't SSH to $host: " . $ssh->error;

    return $ssh;
  }
  else{
    #Handle if somehow verify package fails...which shouldn't happen....
    return 0;
  }
}

sub CheckInput
{
  my ($host, $user, $pass) = @_;
  my $AuthedHost = "";
  
  if($user && $user ne ''){
    $AuthedHost .= $user;
  }
  else{
    return 0;
  }

  if($pass && $pass ne ''){
    $AuthedHost .= "\:$pass";
  }
  else{
    return 0;
  }
  
  if($host && $host ne ''){
    $AuthedHost .= "\@$host";
  }
  else{
    return 0;
  }

  return $AuthedHost;
}

sub VerifyPackages
{
  #Lets store the full list of packages into an array
  my @packages = `dpkg --get-selections \| grep -v deinstall`;

  #Now lets make sure the packages we need are installed
  #sshpass - allows us to input password of ssh through commandline as parameter
  if(grep /sshpass/, @packages){
    Logger("Found sshpass package installed");
  }

  return 1;
}

sub Logger
{
  my $content = shift;
  my $time = timestamp();
  my $file = "log.txt";
  if(!-e $file){
    open FILE, '>'.$file or die "$file: $!";
  }
  else{
    open FILE, '>>', $file or die "$file: $!";
  }
    print FILE "\[$time\]: $content\n";
    close FILE;
}

sub timestamp
{
  my $t = localtime;
  return sprintf( "%04d-%02d-%02d_%02d-%02d-%02d",
                    $t->year + 1900, $t->mon + 1, $t->mday,
                    $t->hour, $t->min, $t->sec );
}