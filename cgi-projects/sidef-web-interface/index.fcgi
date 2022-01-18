#!/usr/bin/perl

# Execute Sidef script inside the browser.

use utf8;
use 5.020;
use strict;

#use autodie;
#use warnings;

use experimental qw(signatures);

use CGI::Fast;
use CGI qw/:standard -utf8/;

#use CGI::Carp qw(fatalsToBrowser);

use File::Slurp qw(read_file);
use URI::Escape qw(uri_escape);
use Encode qw(decode_utf8);

use Capture::Tiny qw(capture);
use File::Basename qw(basename);
use File::Spec::Functions qw(catdir catfile);

# Path where Sidef exists (when not installed)
#use lib qw(/home/user/Sidef/lib);

# Limit the size of Sidef scripts to 500KB
$CGI::POST_MAX = 1024 * 500;

# Load Sidef
use Sidef;

binmode(STDOUT, ':utf8');

my $db_dir      = 'db';
my $scripts_dir = 'scripts/';
my $scripts_db  = catfile($db_dir, 'scripts.db');

if (not -d $db_dir) {
    mkdir $db_dir;
}

local $ENV{SIDEF_INC} = $scripts_dir;

require GDBM_File;
tie my %scripts, 'GDBM_File', $scripts_db, &GDBM_File::GDBM_WRCREAT, 0640;

sub create_submenu ($name, $files) {
    print <<"CODE";
        <li>
           <a class="dropdown-toggle"href="#"><i class="icon-cog"></i>$name</a>
                <ul class="dropdown-menu" data-role="dropdown">
                @{[map {qq{<li><a href="#" onclick="execute_script('$_->{script}')">$_->{name}</a></li>}} @{$files}]}
                </ul>
        </li>
CODE
}

sub add_scripts (@dirs) {
    while (defined(my $dir = shift @dirs)) {
        my @files;
        opendir(my $dir_h, $dir);
        while (defined(my $file = readdir($dir_h))) {
            next if $file =~ /^\.\.?\z/;
            my $abs_file = catfile($dir, $file);
            if ($file =~ /\.sf\z/ and -f $abs_file) {
                push @files,
                  {
                    script => (exists($scripts{$abs_file}) && ((-M $abs_file) > (-M $scripts_db)))
                    ? $scripts{$abs_file}
                    : ($scripts{$abs_file} = quotemeta(uri_escape(scalar read_file($abs_file)))),
                    name => decode_utf8($file =~ s/\.sf\z//r =~ s/^.{1,22}\K(.*)/$1 ? '...' : ''/er)
                  };
            }
            elsif (-d $abs_file) {
                push @dirs, catdir($dir, $file);
            }
        }
        closedir $dir_h;
        @files || next;
        create_submenu(ucfirst basename($dir), [sort { fc($a->{name}) cmp fc($b->{name}) } @files]);
    }
}

sub parse {
    my ($code) = @_;

    @Sidef::NAMESPACES = ();
    %Sidef::INCLUDED   = ();

    my $errors = '';

    local $SIG{__WARN__} = sub {
        $errors .= join("\n", @_);
    };

    local $SIG{__DIE__} = sub {
        $errors .= join("\n", @_);
    };

    my $parser = Sidef::Parser->new(file_name   => '-',
                                    script_name => '-',);

    my $struct = eval { $parser->parse_script(code => \$code) };

    ($struct, $errors);
}

sub execute {
    my ($struct) = @_;

    state $count = 0;

    my $environment_name = 'Sidef::Runtime' . CORE::abs(++$count);
    my $deparser = Sidef::Deparse::Perl->new(namespaces       => [@Sidef::NAMESPACES],
                                             environment_name => $environment_name,);

    my $errors = '';

    local $SIG{__WARN__} = sub {
        $errors .= join("\n", @_);
    };

    local $SIG{__DIE__} = sub {
        $errors .= join("\n", @_);
    };

    local $Sidef::DEPARSER = $deparser;
    my $code = "package $environment_name {" . $deparser->deparse($struct) . "}";

    my ($stdout, $stderr) = capture {
        alarm 5;
        eval($code);
        alarm 0;
    };

    ($stdout, $errors . $stderr);
}

while (my $c = CGI::Fast->new) {

    print header(
                 -charset                 => 'UTF-8',
                 'Referrer-Policy'        => 'no-referrer',
                 'X-Frame-Options'        => 'DENY',
                 'X-Xss-Protection'       => '1; mode=block',
                 'X-Content-Type-Options' => 'nosniff',
                ),
      start_html(
        -lang  => 'en',
        -title => 'Sidef Programming Language',
        -base  => 'true',
        -class => 'metro',
        -meta  => {
                  'keywords' => 'sidef programming language web interface',
                  'viewport' => 'width=device-width, initial-scale=1.0',
                 },
        -style => [{-src => 'css/main.css'},
                   {-src => 'css/metro-bootstrap.min.css'},
                   {-src => 'css/metro-bootstrap-responsive.min.css'},
                   {-src => 'css/iconFont.min.css'},
                  ],
        -script => [
            {-src => 'js/jquery-2.1.3.min.js'},

            #{-src => 'js/jquery.mousewheel.js'},
            {-src => 'js/jquery.widget.min.js'},

            #{-src => 'js/jquery.autosize.min.js'},
            {-src => 'min/metro.min.js'},
            {-src => 'js/metro-dropdown.js'},
            {-src => 'js/tabby.js'},
            {-src => 'js/main.js'},
                   ],
                );

    print <<"CODE";
<div class="main_content">
<div id="sidebar">
<nav class="sidebar dark">
    <ul>
    <li class="active"><a href="$ENV{SCRIPT_NAME}"><i class="icon-home"></i>Dashboard</a></li>
CODE

    add_scripts($scripts_dir);

    print <<'CODE';
    </ul>
</nav>
</div>
CODE

    print q{<div id="content">};
    print a({-href => $ENV{SCRIPT_NAME}}, h1("Sidef"));

    print start_form(
                     -method          => 'POST',
                     -action          => $ENV{SCRIPT_NAME},
                     'accept-charset' => "UTF-8"
                    ),
      textarea(
               -name    => 'code',
               -id      => 'code',
               -default => 'Write your code here...',
               -rows    => 20,
               -columns => 100,
               -onfocus => 'clearContents(this);',
              ),
      br, submit(-name => "Run!"), end_form;

    if (defined(my $code = $c->param('code'))) {

        # Replace any newline characters with "\n"
        $code =~ s/\R/\n/g;

        if ($ENV{REMOTE_ADDR} ne '::1') {
            my $code_file = catfile($db_dir, $ENV{REMOTE_ADDR} . "-" . scalar(localtime) . '.sf');
            open my $fh, '>:utf8', $code_file;
            print $fh $code;
            close $fh;
        }

        my ($struct, $errors) = parse($code);

        if ($errors ne '') {
            chomp($errors);
            print pre($errors);
            print hr;
            $errors = '';
        }

        if (ref($struct) eq 'HASH') {
            my ($output, $errors) = execute($struct);

            if ($errors ne "") {
                chomp($errors);
                print pre($errors);
                print hr;
            }

            if (defined $output and $output ne '') {
                print pre($output);
            }
        }
    }

    print '</div></div>';
    print end_html;
}
