#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use File::Find qw(find);

my %lookup = (
              sf => '#!/usr/bin/ruby',
              pl => '#!/usr/bin/perl',
             );

my $ext_re = qr/\.(pl|sf)\z/;

my @files;

find(
    {
     no_chdir => 1,
     wanted   => sub {
         if (/$ext_re/) {
             my $ext = $1;
             open my $fh, '<', $_ or die "$_: $!";
             chomp(my $line = <$fh>);
             if ($line ne $lookup{$ext}) {
                 push @files, [$_, $lookup{$ext}];
             }
             close $fh;
         }
     }
    },
    glob('*')
    );

foreach my $entry (@files) {

    my ($file, $ext) = @$entry;

    say "Modifying: $file\n";

    open my $fh, '<', $file or die "$file: $!";
    my $content = do {
        local $/;
        <$fh>;
    };
    close $fh;

    open my $out_fh, '>', $file or die "$file: $!";
    print $out_fh "$ext\n$content";
    close $out_fh;
}
