#! /usr/bin/env perl

use Test::More;
use Test::Warnings;
use Test::TempDir::Tiny 'tempdir';
use Path::Class;
use Log::Any::Adapter;
use warnings;
use strict;

Log::Any::Adapter->set( 'Carp', log_level => 'warn' );

use_ok('InfluxDB::Writer::RememberingFileTailer');

my $tmp = tempdir();
my $fn = file( $tmp, 'multiline.stats' );
open my $fh, '>', $fn or die "Failed to create $fn: $!";
print $fh
    qq(measurement,tag=something msg="This is\na multiline string" value=42 1456864132676268000);
close $fh;

sub InfluxDB::Writer::RememberingFileTailer::send {

    # don't send anything in this test
    return 1;
}

my $rft = InfluxDB::Writer::RememberingFileTailer->new(
    dir         => $tmp,
    influx_host => 'localhost',
    influx_db   => __PACKAGE__,
    flush_size  => 10000
);

ok($rft->slurp_and_send("$fn"), 'slurp_and_send returns OK');

# Test::Warnings will check for: "Skipping probably broken line ..."

done_testing;
