#!/usr/bin/perl

# Upload files to server

# See also:
#   https://www.w3schools.com/php/php_file_upload.asp
#   https://www.geeksforgeeks.org/how-to-select-multiple-files-using-html-input-tag/

use utf8;
use 5.018;
use strict;
use autodie;

use CGI qw(:standard -utf8);
use CGI::Carp qw(fatalsToBrowser);

binmode(STDOUT, ':utf8');

print header(-charset => 'UTF-8'),
  start_html(
             -lang  => 'en',
             -title => 'Upload files',
             -base  => 'true',
             -meta  => {
                       'keywords' => 'upload files to server',
                      },
             -style  => [{-src => 'css/main.css'}],
             -script => [],
            );

print h1("Upload files");

print start_form(
                 -method  => 'POST',
                 -enctype => 'multipart/form-data',
                 -action  => 'index.cgi',
                ),

  q{<input type="file" name="uploaded_file" multiple>},

  submit(-name => "Submit!"), end_form;

my $q = CGI->new;

if (param) {

    foreach my $filehandle ($q->multi_param('uploaded_file')) {

        if (!$filehandle && $q->cgi_error) {
            die $q->cgi_error;
        }

        if ($filehandle) {
            my $info = $q->uploadInfo($filehandle);

            my $cd       = $info->{'Content-Disposition'};
            my $filename = 'unknown';

            if ($cd =~ /\bfilename="(.*?)"/s) {
                $filename = $1;
            }

            open(my $out_fh, '>', "files/$filename")
              or die "Can't create file: $!";

            while (read($filehandle, (my $buffer), 1024)) {
                print {$out_fh} $buffer;
            }

            close $out_fh;
        }
        else {
            die "Invalid upload...";
        }
    }

}

print end_html;
