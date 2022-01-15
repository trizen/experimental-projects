#!/usr/bin/perl

# Convert the JSON encoded values to Storable values.

# Usage:
#   perl zstd_db.pl [old.db] [new.db]

use 5.014;
use strict;
use warnings;

use JSON::XS qw(decode_json);
use IO::Compress::Zstd qw(zstd);
use IO::Uncompress::UnZstd qw(unzstd);
use Storable qw(freeze);

my $old_db = $ARGV[0];
my $new_db = $ARGV[1] // 'new-with-storable.db';

if (not defined($old_db) or not -f $old_db) {
    die "usage: $0 [old db] [new db]\n";
}

if (not defined($new_db) or -e $new_db) {
    die "File <<$new_db>> already exists!\n";
}

use GDBM_File;

tie(my %OLD_DB, 'GDBM_File', $old_db, &GDBM_READER, 0777)
  or die "Can't access database <<$old_db>>: $!";

tie(my %NEW_DB, 'GDBM_File', $new_db, &GDBM_WRCREAT, 0777)
  or die "Can't create database <<$new_db>>: $!";

while (my ($key, $value) = each %OLD_DB) {
    if (defined($value)) {

        unzstd(\$value, \my $json_data)
          or die "unzstd failed: $IO::Uncompress::UnZstd::UnZstdError\n";

        my $serialized = freeze(eval { decode_json($json_data) } // next);

        zstd(\$serialized, \my $zstd_data)
          or die "zstd failed: $IO::Compress::Zstd::ZstdError\n";

        $NEW_DB{$key} = $zstd_data;
    }
}

untie(%OLD_DB);
untie(%NEW_DB);
