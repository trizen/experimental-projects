#!/usr/bin/perl

# Filesystem web share, using Fast CGI.

use utf8;
use 5.020;
use strict;
use warnings;

use autodie;

use CGI::Fast;
use CGI qw/:standard *table -utf8/;

#use CGI::Carp qw(fatalsToBrowser);

use Encode qw(decode_utf8 encode_utf8);
use HTML::Entities qw(encode_entities);
use Number::Bytes::Human qw(format_bytes);
use Digest::MD5 qw(md5_hex);
use File::Copy qw(copy);
use File::Basename qw(basename dirname);
use URI::Escape qw(uri_escape_utf8);

use File::MimeInfo;
use File::MimeInfo::Magic;

use List::Util qw(max);
use File::Spec::Functions qw(catfile catdir splitdir);

#~ require URI;
#~ require URI::QueryParam;

state $share_root = "SHARE";    # edit this path

state $DB_DIR  = 'db';
state $DB_FILE = catfile($DB_DIR, 'visits.db');

state $img_dir     = 'img';
state $folder_icon = catfile($img_dir, qw(folder.png));

#my $u = URI->new("", "http");
#$u->query($ENV{QUERY_STRING} || "path=$share_root");

mkdir($DB_DIR) if not -d $DB_DIR;

sub wrap_text {
    my ($text, $len, $max_len) = @_;

    my $width = 11;

    $max_len = $max_len - ($max_len % $width) + $width;

    $text .= " " x ($max_len - $len) if ($len < $max_len);
    $text =~ s{(?:&#?\w+;|\X){$width}\K}{<br />}gs;
    return $text;
}

sub make_td {
    my ($a_href, $name, $size) = @_;

    # Display as a grid
    q{<td width="90">} . $a_href . br . small(wrap_text(encode_entities($name), length($name), $size)) . "</td>";

    # Display as a list
    #Tr({-align => 'left'}, [q{<td width="1%">} . $a_href . th({}, small(encode_entities $name))]);
}

sub hash_to_query {
    my ($opts) = @_;
    return join(q{&} => map $_ . q{=} . uri_escape_utf8($opts->{$_}), grep defined $opts->{$_}, keys %{$opts});
}

sub make_a_href {
    my ($hash_ref) = @_;

    return
      a(
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

    my $root = $ENV{DOCUMENT_ROOT};

    #state $home_dir = $ENV{HOME} || $ENV{LOGDIR} || (getpwuid($<))[7] || `echo -n ~`;
    state $srv_thumbs_dir = catdir($root, qw(filesystem thumbnails));

    my $home_dir = dirname($root);
    state $thumbs_dir = catdir($home_dir, qw(.cache thumbnails normal));

    $file =~ s{^\Q$share_root\E}{file://$home_dir};

    my $md5       = md5_hex(encode_utf8($file));
    my $thumbnail = catfile($thumbs_dir, "$md5.png");

    if (-e $thumbnail) {
        my $srv_thumb = catfile($srv_thumbs_dir, "$md5.png");
        copy($thumbnail, $srv_thumb) or die $!;
        $srv_thumb =~ s{^\Q$root\E}{};
        return $srv_thumb;
    }

    return undef;
}

sub check_icon {
    my ($type) = @_;

    my $path = catfile($img_dir, "$type.png");

    if (-e $path) {
        return $path;
    }

    return undef;
}

sub find_file_icon {
    my ($file) = @_;

    state %alias;
    state %icons;

    # Determine mimetype using file extension only (faster)
    my $mime_type = File::MimeInfo::globs($file) // 'unknown';

    # Determine mimetype using file extension or the first 10 bytes inside the file
    #my $mime_type = File::MimeInfo::mimetype($file) // 'unknown';

    # Determine mimetype using file extension + magic (best) (slow)
    #my $mime_type = File::MimeInfo::Magic::mimetype($file) // 'unknown';

    $mime_type =~ tr|/|-|;
    $mime_type = $alias{$mime_type} if exists $alias{$mime_type};

    {
        my $type = $mime_type;
        while (1) {
            if ($icons{$type} ||= check_icon($type)) {
                $alias{$mime_type} = $type;
                $mime_type = $type;
                last;
            }
            $type =~ s{.*\K[[:punct:]]\w++$}{} || last;
        }
    }

    if (!$icons{$mime_type}) {
        my $type = $mime_type;
        while (1) {
            $type =~ s{^application-x-\K.*?-}{} || last;
            $icons{$type} ||= check_icon($type);
            $icons{$type} && do { $alias{$mime_type} = $type; $mime_type = $type; last };
        }
    }

    if (!$icons{$mime_type}) {
        $alias{$mime_type} = 'unknown';
        return check_icon($alias{$mime_type});
    }

    return $icons{$mime_type};
}

while (my $c = CGI::Fast->new) {

    my $path     = $c->param('path') // $share_root;
    my $fullpath = $path;                              #catdir($root, $path);

    if ($path =~ m{/\.\./} or $path =~ m{/\.\.} or not $path =~ m{^\Q$share_root\E(?:/|\z)}) {

        print header(
                   -charset                  => 'UTF-8',
                   'Referrer-Policy'         => 'no-referrer',
                   'X-Frame-Options'         => 'DENY',
                   'X-Xss-Protection'        => '1; mode=block',
                   'X-Content-Type-Options'  => 'nosniff',
                   'Content-Security-Policy' =>
                     q{default-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self'; img-src 'self' data:;},
                    ),
          start_html(
                     -style => {'src' => 'styles/style.css'},
                     -meta  => {
                               'viewport' => 'width=device-width, initial-scale=1.0',
                              },
                     -BGCOLOR => 'black'
                    ),
          h1("You're not allowed to see this directory!"), end_html;

        open my $db_h, '>>', $DB_FILE;
        print {$db_h} <<"EOT";
<hack> IP="$ENV{REMOTE_ADDR}" AGENT="$ENV{HTTP_USER_AGENT}" FILE="\Q$path\E" PORT="$ENV{REMOTE_PORT}" REFERER="\Q$ENV{HTTP_REFERER}\E" QUERY="$ENV{QUERY_STRING}"
EOT
        close $db_h;
        exit;
    }

    if ($c->param('file')) {
        my $name = basename($path);

        open my $db_h, '>>', $DB_FILE;
        print {$db_h} <<"EOT";
<download> IP="$ENV{REMOTE_ADDR}" AGENT="$ENV{HTTP_USER_AGENT}" FILE="\Q$path\E" BASENAME="\Q$name\E" PORT="$ENV{REMOTE_PORT}" REFERER="\Q$ENV{HTTP_REFERER}\E" QUERY="$ENV{QUERY_STRING}"
EOT
        close $db_h;

        sysopen my $fh, $fullpath, 0;

        print header(

            #-type           => 'application/octet-stream',
            -type           => scalar File::MimeInfo::Magic::mimetype($fullpath),
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
        next;
    }

    print header(
                 -charset                  => 'UTF-8',
                 'Referrer-Policy'         => 'no-referrer',
                 'X-Frame-Options'         => 'DENY',
                 'X-Xss-Protection'        => '1; mode=block',
                 'X-Content-Type-Options'  => 'nosniff',
                 'Content-Security-Policy' =>
                   q{default-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self'; img-src 'self' data:;},
                ),
      start_html(
                 -title => 'HFSS - Happy file-sharing system',
                 -meta  => {
                           'keywords' => 'filesystem',
                           'viewport' => 'width=device-width, initial-scale=1.0',
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

    my $referrer = $ENV{HTTP_REFERER} // '';

    open my $db_h, '>>', $DB_FILE;
    print {$db_h} <<"EOT";
<view> IP="$ENV{REMOTE_ADDR}" AGENT="$ENV{HTTP_USER_AGENT}" FILE="\Q$path\E" PORT="$ENV{REMOTE_PORT}" REFERER="\Q$referrer\E" QUERY="$ENV{QUERY_STRING}"
EOT

    close $db_h;

    my @dirs = grep { defined($_) && /\S/ } splitdir($path);
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
                a(
                   {
                    href => $ENV{SCRIPT_NAME} . '?' . hash_to_query({path => $name = catdir($name, $_)}),
                   },
                   button(
                          -value => $_,
                         )
                 )
              )
          } @dirs
    );

    print end_table;

    if (-d -r $fullpath) {
        opendir(my $dir_h, $fullpath);

        my @files;
        while (defined(my $file = readdir($dir_h))) {

            $file = decode_utf8($file);

            next if chr ord $file eq q{.};

            my $fullname = catfile($fullpath, $file);
            my $name     = catfile($path,     $file);

            push @files,
                (-d $fullname) ? {dir => 1, name => $name}
              : (-f _)         ? {dir => 0, name => $name, size => (-s _)}
              :                  next;
        }

        my $max_len = max(map { length(basename($_->{name})) } @files);

        if (@files) {

            print q{<table><tr>};

            my @entries;

            foreach my $file ((sort { fc($a->{name}) cmp fc($b->{name}) } grep { $_->{dir} } @files),
                              sort { fc($a->{name}) cmp fc($b->{name}) } grep { !$_->{dir} } @files) {

                my $name = basename($file->{name});

                if ($file->{dir}) {
                    my $a_href = make_a_href({icon => $folder_icon, query => {path => $file->{name}}});
                    push @entries, make_td($a_href, $name, $max_len);
                }
                else {
                    my $format = 'file';
                    $format = lc($1) if $file->{name} =~ /\.(\w+)\z/;

                    my $file_icon = find_file_icon($file->{name});

                    if (not -e $file_icon) {
                        $file_icon = catfile($img_dir, "$format.png");
                    }

                    if (not -e $file_icon) {
                        $file_icon = catfile($img_dir, "file.png");
                    }

                    my $a_href =
                      make_a_href(
                                  {
                                   icon  => $file_icon,
                                   query => {path => $file->{name}, file => 1},
                                   size  => $file->{size}
                                  }
                                 );

                    push @entries, make_td($a_href, $name, $max_len);
                }
            }

            my $count = 0;
            foreach my $entry (@entries) {
                print $entry;
                print q{</tr><tr>} if ++$count % 12 == 0;
            }

            print "</tr></table>";
        }
        else {
            print h1("Empty directory!");
        }
    }
    else {
        print h1("This directory doesn't exist!");
    }

    print end_html;
}
