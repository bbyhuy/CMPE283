#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use SSH qw(OpenSSHPipe);
use OpenStack::Nova qw(get_instances start_server stop_server);
#VerifyAuthentication();

my $host = "192.168.76.1";
my $ssh = SSH::OpenSSHPipe($host);

my $instances = OpenStack::Nova::get_instances($ssh);
#OpenStack::Nova::start_server($ssh, $instances, "MY-SECOND-VM");
OpenStack::Nova::stop_server($ssh, $instances, "MY-SECOND-VM");


exit;