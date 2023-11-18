#!/usr/bin/perl

# Make the oeis-draft links as local HTML pages.

use 5.036;
use File::Spec::Functions qw(catfile);

my $cache_dir = 'cache';
my $local_dir = 'local';

if (not -d $local_dir) {
    mkdir($local_dir);
}

my %cache;

foreach my $file (glob("$cache_dir/*")) {

    -f $file or next;

    open my $fh, '<:utf8', $file or next;
    chomp(my $url = <$fh>);

    if (exists $cache{$url}) {
        next if ((-M $file) > (-M $cache{$url}));    # skip older cache file
    }

    $cache{$url} = $file;
}

sub read_cache_file ($file) {
    open my $fh, '<:utf8', $file or die "error: $!";

    while (defined(my $line = <$fh>)) {
        chomp($line);
        $line eq '' and last;
    }

    my $html = do {
        local $/;
        <$fh>;
    };

    $html =~ s{<script[ >].*?</script>}{}gs;

    return $html;
}

sub make_local_cache ($id, $url) {
    my $local_file = catfile($local_dir, $id . '.html');

    if (-e $local_file) {
        return $local_file;
    }

    my $cache_file = $cache{$url} // die "can't find $url in cache";
    my $html       = read_cache_file($cache_file);

    open my $fh, '>:utf8', $local_file or die "can't create $local_file: $!";
    print $fh $html;
    close $fh;

    return $local_file;
}

open my $fh,     '<:utf8', 'links.html' or die "error: $!";
open my $out_fh, '>:utf8', 'local.html' or die "error: $!";

while (defined(my $line = <$fh>)) {
    if ($line =~ m{^\s*<li>\s*\[\d+\]\s*<a\s*href=(https://oeis.org/draft/\w+)>https://oeis.org/draft/(\w+)</a>\s*</li>}) {

        my $url = $1;
        my $id  = $2;

        my $local_file = make_local_cache($id, $url);
        $line =~ s{https://oeis.org/draft/\w+}{$local_file};
        print $out_fh $line;
    }
    else {
        print $out_fh $line;
    }
}

close $fh;
close $out_fh;
