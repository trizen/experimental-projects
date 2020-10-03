#!/usr/bin/perl

# Filesystem web share.

use 5.016;
use strict;
use warnings;

#use autodie;

use CGI qw/:standard *table -utf8/;
use CGI::Carp qw(fatalsToBrowser);

use autouse 'HTML::Entities'       => qw(encode_entities);
use autouse 'Number::Bytes::Human' => qw(format_bytes);
use autouse 'Digest::MD5'          => qw(md5_hex);
use autouse 'File::Copy'           => qw(copy);
use autouse 'File::Basename'       => qw(basename);
use autouse 'URI::Escape'          => qw(uri_escape);

use List::Util qw(max);
use File::Spec::Functions qw(catfile catdir splitdir);

require URI;
require URI::QueryParam;

state $share_root = "SHARE";               # edit this path
state $root       = $ENV{DOCUMENT_ROOT};

$root // die;

state $DB_DIR = 'db';
state $DB_FILE = catfile($DB_DIR, 'visits.db');

state $img_dir = 'img';
state $folder_icon = catfile($img_dir, qw(folder.png));

my $u = URI->new("", "http");
$u->query($ENV{QUERY_STRING} || "path=$share_root");

mkdir($DB_DIR) if not -d $DB_DIR;
open my $db_h, '>>', $DB_FILE;

sub wrap_text {
    my ($text, $len, $max_len) = @_;

    $max_len = $max_len - ($max_len % 10) + 10;

    $text .= " " x ($max_len - $len) if ($len < $max_len);
    $text =~ s{(?:&#?\w+;|\X){10}\K}{<br />}gs;
    return $text;
}

sub print_tr_td {
    my ($a_href, $name, $size) = @_;

    state $x = 0;
    print q{<td width="90">} . $a_href . br . small(wrap_text(encode_entities($name), length($name), $size)) . "</td>";
    print q{</tr><tr>} if ++$x % 13 == 0;

    # print Tr({-align => 'left'}, [q{<td width="1%">} . $a_href . th({}, small(encode_entities $name))]);
}

sub hash_to_query {
    my ($opts) = @_;
    return join(q{&} => map $_ . q{=} . uri_escape($opts->{$_}), grep defined $opts->{$_}, keys %{$opts});
}

sub make_a_href {
    my ($hash_ref) = @_;

    return a(
        {
         href => "$ENV{SCRIPT_NAME}?" . hash_to_query($hash_ref->{query}),
         exists $hash_ref->{size} ? (class => "popup") : ()
        },
        (exists $hash_ref->{size} ? small((span("Size: " . format_bytes($hash_ref->{size})))) : ()),
        img(
            {
             src    => $hash_ref->{icon},
             alt    => ($hash_ref->{query}{file} ? "file" : "folder"),
             width  => 64,
             height => 64,
            }
           )

    );
}

sub get_thumbnail {
    my ($file) = @_;

    state $home_dir = $ENV{HOME} || $ENV{LOGDIR} || (getpwuid($<))[7] || `echo -n ~`;
    state $srv_thumbs_dir = catdir($root,     'thumbnails');
    state $thumbs_dir     = catdir($home_dir, qw(.thumbnails normal));

    $file =~ s{^\Q$share_root\E}{file://$home_dir};

    my $md5 = md5_hex($file);
    my $thumbnail = catfile($thumbs_dir, "$md5.png");

    if (-e $thumbnail) {
        my $srv_thumb = catfile($srv_thumbs_dir, "$md5.png");
        copy($thumbnail, $srv_thumb) or die $!;
        $srv_thumb =~ s{^\Q$root\E}{};
        return $srv_thumb;
    }
    else {
        return;
    }
}

if (defined(my $path = $u->query_param_delete('path'))) {
    my $fullpath = $path;    #catdir($root, $path);

    if ($path =~ m{/\.\./} or $path =~ m{/\.\.} or not $path =~ m{^\Q$share_root\E(?:/|\z)}) {

        print header, start_html(-style => {'src' => 'styles/style.css'}, -BGCOLOR => 'black'),
          h1("You're not allowed to see this directory!"), end_html;

        print {$db_h} <<"EOT";
<hack> IP="$ENV{REMOTE_ADDR}" AGENT="$ENV{HTTP_USER_AGENT}" FILE="\Q$path\E" PORT="$ENV{REMOTE_PORT}" REFERER="\Q$ENV{HTTP_REFERER}\E" QUERY="$ENV{QUERY_STRING}"
EOT
        close $db_h;
        exit;
    }

    if ($u->query_param_delete('file')) {
        my $name = basename($path);

        print {$db_h} <<"EOT";
<download> IP="$ENV{REMOTE_ADDR}" AGENT="$ENV{HTTP_USER_AGENT}" FILE="\Q$path\E" BASENAME="\Q$name\E" PORT="$ENV{REMOTE_PORT}" REFERER="\Q$ENV{HTTP_REFERER}\E" QUERY="$ENV{QUERY_STRING}"
EOT
        close $db_h;

        sysopen my $fh, $fullpath, 0;

        print header(
                     -type           => 'application/octet-stream',
                     -expires        => '+3d',
                     -Content_length => (-s $fullpath),
                     -attachment     => $name
                    );

        state $size = 1024 * 1024 * 2;    # 2 MB
        while (defined(my $chunk_size = sysread($fh, (my $chunk), $size))) {
            print $chunk;
            last if $chunk_size < $size;
        }
        close $fh;

    }
    else {
        print header,
          start_html(
                     -title  => 'HFSS - Happy file-sharing system',
                     -author => 'Daniel Șuteu',
                     -meta   => {
                               'keywords'  => 'trizen',
                               'copyright' => 'Copyright 2012 Trizen'
                              },
                     -style => {src => 'styles/style.css'},
                     -head  => Link(
                                   {
                                    -rel  => 'shortcut icon',
                                    -type => 'image/x-icon',
                                    -href => 'images/tux.png',
                                   }
                                  ),
                     -BGCOLOR => 'black',
                    );

        print <<'SCRIPT';

<script type="text/javascript">
function gotoDir(path){
    window.location.href=path
}
</script>

SCRIPT

        my $referrer = $ENV{HTTP_REFERER} // '';
        print {$db_h} <<"EOT";
<view> IP="$ENV{REMOTE_ADDR}" AGENT="$ENV{HTTP_USER_AGENT}" FILE="\Q$path\E" PORT="$ENV{REMOTE_PORT}" REFERER="\Q$referrer\E" QUERY="$ENV{QUERY_STRING}"
EOT

        close $db_h;

        my @dirs = grep { defined && /\S/ } splitdir($path);
        $dirs[0] = "/";

        print start_table(
                          {
                           border => "",
                           width  => "1%"
                          }
                         );

        my $name = $share_root;
        print Tr(
            {-align => 'left'},
            map {
                td(
                    {width => "5%"},
                    button(
                           -value   => $_,
                           -onClick => 'gotoDir(src)',
                           -src     => "$ENV{SCRIPT_NAME}?" . hash_to_query({path => $name = catdir($name, $_)}),
                          )
                  )

              } @dirs
        );

        print end_table;

        my $full_img_dir = $img_dir;

        if (-d -r $fullpath) {
            opendir(my $dir_h, $fullpath);

            my @files;
            while (defined(my $file = readdir($dir_h))) {

                next if chr ord $file eq q{.};

                my $fullname = catfile($fullpath, $file);
                my $name     = catfile($path,     $file);

                push @files,
                    -d $fullname ? {dir => 1, name => $name}
                  : (-f _) ? {dir => 0, name => $name, size => (-s _)}
                  :          next;
            }

            my $max_len = max(map { length(basename($_->{name})) } @files);

            if (@files) {

                print q{<table><tr>};

                foreach my $file ((sort { fc($a->{name}) cmp fc($b->{name}) } grep { $_->{dir} } @files),
                                  sort { fc($a->{name}) cmp fc($b->{name}) } grep { !$_->{dir} } @files) {

                    my $name = basename($file->{name});

                    if ($file->{dir}) {
                        my $a_href = make_a_href({icon => $folder_icon, query => {path => $file->{name}}});

                        utf8::decode($name);
                        print_tr_td($a_href, $name, $max_len);
                    }
                    else {
                        my $format = 'file';
                        $format = lc($1) if $file->{name} =~ /\.(\w+)\z/;

                        my $file_icon = get_thumbnail($file->{name}) // (
                                                                         (-e catfile($full_img_dir, "$format.png"))
                                                                         ? catfile($img_dir, "$format.png")
                                                                         : catfile($img_dir, "file.png")
                                                                        );

                        my $a_href =
                          make_a_href(
                                      {
                                       icon  => $file_icon,
                                       query => {path => $file->{name}, file => 1},
                                       size  => $file->{size}
                                      }
                                     );

                        utf8::decode($name);
                        print_tr_td($a_href, $name, $max_len);
                    }
                }
                print "</tr></table>";
            }
            else {
                print h1("Empty directory!");
            }
        }
        else {
            print h1("This directory doesn't exists!");
        }

        print end_html;
    }
}
else {
    print header, start_html, h1("No path specified!"), end_html;
}
