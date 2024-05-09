#!/usr/bin/perl

# Author: Trizen
# Date: 03 April 2023
# https://github.com/trizen

# Convert a GDBM database to a Berkeley database, and use JSON for encoding in order to make it portable.

use 5.036;
use DB_File;
use GDBM_File;

no warnings 'once';
use JSON::XS qw(encode_json);
use Storable qw(thaw);

use constant {
    # Compress the values of the content database with Zstandard.
    # When enabled, the content database will be ~3x smaller.
    USE_ZSTD => 1,
};

scalar(@ARGV) == 2 or die "usage: $0 [input.dbm] [output.dbm]";

my $input_file  = $ARGV[0];
my $output_file = $ARGV[1];

if (not -f $input_file) {
    die "Input file <<$input_file>> does not exist!\n";
}

if (-e $output_file) {
    die "Output file <<$output_file>> already exists!\n";
}

tie(my %input, 'GDBM_File', $input_file, &GDBM_READER, 0555)
  or die "Can't access database <<$input_file>>: $!";

tie(my %output, 'DB_File', $output_file, O_CREAT | O_RDWR, 0666, $DB_BTREE)
  or die "Can't create database <<$output_file>>: $!";

if (USE_ZSTD) {
    require IO::Compress::Zstd;
    require IO::Uncompress::UnZstd;
}

sub zstd_encode ($data) {

    IO::Compress::Zstd::zstd(\$data, \my $zstd_data)
      or die "zstd failed: $IO::Compress::Zstd::ZstdError\n";

    return $zstd_data;
}

sub zstd_decode ($zstd_data) {

    IO::Uncompress::UnZstd::unzstd(\$zstd_data, \my $decoded_data)
      or die "unzstd failed: $IO::Uncompress::UnZstd::UnZstdError\n";

    return $decoded_data;
}

sub decode_content_entry ($entry) {

    my $data = $entry;

    if (USE_ZSTD) {
        $data = zstd_decode($data);
    }

    return thaw($data);
}

sub encode_content_entry ($entry) {

    my $data = encode_json($entry);

    if (USE_ZSTD) {
        $data = zstd_encode($data);
    }

    return $data;
}

while (my ($key, $value) = each %input) {
    $output{$key} = encode_content_entry(decode_content_entry($value));
}

untie(%input);
untie(%output);
