#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use SSH qw(OpenSSHPipe);
use OpenStack::Nova qw(get_instances start_server stop_server);
#VerifyAuthentication();

my $host = "192.168.1.194";
my $ssh = SSH::OpenSSHPipe($host);

OpenStack::Nova::get_instances($ssh);


exit;