package OpenStack::Nova;
use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw( get_instances
                     start_server
                     stop_server   
                   );

use FindBin qw($Bin);
use lib "$Bin/lib";

use SSH qw(OpenSSHPipe);
use Data::Dumper;
use Storable qw (dclone);

=begin GHOSTCOMMENT

  The purpse of this module to to be able to wrap basic OpenStack NOVA client
  command line commands through the use of SSH. This allows a very perlish way
  of controlling openstack nova instances without the use of too many external 
  requirements other than the Net::OpenSSH libs, which have also been wrapped
  for ease of use for OpenStack interaction purposes...

=end GHOSTCOMMENT
=cut

sub ExecuteCommand
{
  my $ssh = shift;
  my $command = shift;
  #check for ssh pipeline, if it doesn't exist,
  #attempt to see if Environment vars are available to open one!
  #will add code for this later....
  #for now make sure to open pipe before calling this function!

  #make sure we source keystonerc_admin with the command
  my $sourcedcmd = "source /root/keystonerc_admin && $command";

  #capture ssh output and store to data array and return it.
  my @data = $ssh->capture($sourcedcmd);
  return(\@data);
}

sub get_instances
{
  my $ssh = shift;
  #executes nova list command
  my $output = ExecuteCommand($ssh, "nova list");
  my $instances = [];

  foreach my $index (0 .. $#$output)
  {
    if($output->[$index] =~ m/net\d+/)
    {
      my @metadata = split /\|/, $output->[$index];

      foreach my $rindex (reverse 0 .. $#metadata)
      {
        if($metadata[$rindex] !~ m/[A-Za-z0-9]/)
        {
          splice ( @metadata, $rindex, 1 );
        }
      }
      my ($subnet, $floatip);
      if($metadata[5] =~ m/\=([^,]+),\s+([^\s]+)/)
      {
        $subnet = $1;
        $floatip = $2;
      }

      @metadata = map {join(' ', split(' '))} @metadata;

      my $metahash = {
                        'ID'      => $metadata[0],
                        'Name'    => $metadata[1],
                        'Status'  => $metadata[2],
                        'Task'    => $metadata[3],
                        'Power'   => $metadata[4],
                        'Subnet'  => $subnet,
                        'FloatIP' => $floatip,
                     };
      push (@$instances, dclone($metahash));
    }
  }
  print Dumper $instances;
  return $instances;
}

sub start_server
{
  my $ssh = shift;
  my $instances = shift;
  my $server = shift;

  if($ssh && $instances && $server)
  {
    foreach (@$instances)
    {
      if($_->{Name} eq $server)
      {
        last;
      }
    }
  }

  #executes nova start command
  my $output = ExecuteCommand($ssh, "nova start $server");
  
}

sub stop_server
{
  my $ssh = shift;
  my $instances = shift;
  my $server = shift;

  if($ssh && $instances && $server)
  {
    foreach (@$instances)
    {
      if($_->{Name} eq $server)
      {
        last;
      }
    }
  }

  #executes nova stop command
  my $output = ExecuteCommand($ssh, "nova stop $server");
  
}









