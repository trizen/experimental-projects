#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use File::Spec;
use lib File::Spec->curdir();

use Image::Magick;
use Image::Size;
use List::Util qw(sum);

use File::Find qw(find);

my %check;
find {
    wanted => sub {
        -f or return;
        my $hash = get_image_hash($_);
        if (defined $hash) {
            #push @{$check{$hash}}, {size => [imgsize($_)], image => $_};
            $check{$hash} = {size => [imgsize($_)], image => $_};
        }
    },
    no_chdir => 1,
     } => 'Alphabet';

my $image = 'short.png';
my ($image_width,$image_height) = imgsize($image);

    my $p = new Image::Magick;
    my $error = $p->Read(filename => $image);
    $error && do { die $error; };

#foreach my $i (0..$image_width){
#    foreach my $j (0..$image_height){

sub get_hash_of_square{
   # my($width, $height, $letter_hash) = @_;

 foreach my $j(11..44){
        foreach my $i(6..28){

            say "$j -> $i";

foreach my $hash_key (keys %check){

   # say $hash_key;

    my $data = $check{$hash_key};
            my($w, $h) = @{$data->{size}};
#            say $w;

            my $max_w = $w; #*3 + 1;
            my $max_h = $h; # *3 + 1;

           # --$max_w while($max_w>$image_width);
           # --$max_h while($max_h>$image_height);


#while($max_h-- > 10 and $max_w-- > 4){
     my @colors;
        my $avg;

  foreach my $x($j..$j+$max_h){
                foreach my $y($i..$i+$max_w){

                    #say "~~ $x -> $y";
                   # sleep 1;


                   # print "$x -> $y\n";

        push @colors, [$p->GetPixel(x => $x, y => $y)];

            # Average of the most prominent and least prominent colors:
            #my $value = (max(@{$colors[-1]}) + min(@{$colors[-1]})) / 2;

            # Average of the colors
            my $value = sum(@{$colors[-1]}) / 3;
            $avg += $value;
        }
    }
    $avg /= $max_w * $max_h;
   # print "$opt{x} -> $opt{y} --", $opt{width}*$opt{height},$/;

    my $i    = 0;
    my $hash = q{};
    foreach my $color (@colors) {
        vec($hash, $i++, 1) = sum(@{$color}) / 3 < $avg ? 1 : 0;    # set the bits
    }

    $hash = scalar unpack("H*", $hash);
    #say "NEW: ", $hash;
    #say $hash;

    if(cmp_diff($hash, $hash_key) <=12){
        say "Matched!\n";
        say $data->{image};
        return 1;
    }

#}

}

   # if(verify_hash($hash)){
       # return 1;
   # }


                }
            }

            return;
}

get_hash_of_square();

=cut
foreach my $hash_key (keys %check){

            my $data = $check{$hash_key};
            my($w, $h) = @{$data->{size}};
#            say $w;

            my $max_w = $w*3 + 1;
            my $max_h = $h*3 + 1;

            --$max_w while($max_w>$image_width);
            --$max_h while($max_h>$image_height);

            while($max_h-- > 10 and $max_w-- > 4){
                #my $hash =
                get_hash_of_square($max_h, $max_w, $hash_key) && do{
                        print $data->{image}, "\n";
                        last;
                };
                #die "$max_h -> $max_w\n";
            }
            #my $ratio = $w/$h;



            #my $hash = get_hash_of_square($i * $ratio);

            #say $ratio;

        }
#    }
#}
=cut

#use Data::Dump qw(pp);
#pp \%check;


#my ($vert, $horiz) = (0,0);
#my $max_size = 30;

=cut
    #until($vert > $image_width or $horiz > $image_height){
    while(1){

  $vert+= 20;
        $horiz+=20;

#    last if $vert > $image_width && $horiz > $image_height;

   foreach my $i(10..$max_size){
            foreach my $j(10..$max_size){
                my $hash = get_hash_of_square(x=>$vert, y=>$horiz, height => $i+$vert, width=> $j+$horiz);
                print $hash,$/;
                verify_hash($hash);
}
}

if($vert > $image_width and $horiz < $image_height){
    $vert = $image_height-$max_size;
    $horiz += $max_size;
}elsif($horiz > $image_height and $vert < $image_width){
    $horiz = $image_height - $max_size;
    $vert += $max_size;
}elsif($horiz >= $image_height and $vert >= $image_width){
    last;
}else{
    $vert += $max_size;
    $horiz += $max_size;
  }
}
=cut

#foreach my $i(0..

sub cmp_diff {
    my ($s1, $s2) = @_;
    scalar grep { $_ > 0 } unpack('C*', '' . $s1 ^ '' . $s2);
}

sub verify_hash{
    my($hash) = @_;
   foreach my $key (keys %check) {
       if((my $diff = cmp_diff($hash,$key)) <= 5){
            say "$hash <=> $key == $diff\nFound image: $check{$key}\n";
       }
       #else{
       #    say $diff;
       #}
   }
}


=cut
sub get_hash_of_square{
    my(%opt) = @_;

    my($x, $y) = ($opt{x}, $opt{y});
    #print "X: $x\nY: $y\n\n";

   # print "$opt{height} - $opt{width}\n";
    #my($h, $w) = ($x+$height, $y+$width);

    my @colors;
    my $avg = 0;
    for (; $opt{y} <= $opt{height} ; $opt{y}++) {
        for (; $opt{x} <= $opt{width} ; $opt{x}++) {
            push @colors, [$p->GetPixel(x => $opt{x}, y => $opt{y})];

            # Average of the most prominent and least prominent colors:
            #my $value = (max(@{$colors[-1]}) + min(@{$colors[-1]})) / 2;

            # Average of the colors
            my $value = sum(@{$colors[-1]}) / 3;
            $avg += $value;
        }
    }
    $avg /= $x * $y;
   # print "$opt{x} -> $opt{y} --", $opt{width}*$opt{height},$/;

    my $i    = 0;
    my $hash = q{};
    foreach my $color (@colors) {
        vec($hash, $i++, 1) = sum(@{$color}) / 3 < $avg ? 1 : 0;    # set the bits
    }

    return scalar unpack("H*", $hash);
}
=cut



sub get_image_hash {
    my ($image) = @_;

    return unless -f $image;

    my $p = new Image::Magick;
    my $error = $p->Read(filename => $image);
    $error && do { warn $error; return };

    my ($width, $height) = imgsize($image); #(8, 8);

    $error = $p->Resize(width => $width, height => $height);
    $error && do { warn $error; return };

    my @colors;
    my $avg = 0;
    for (my $y = 0 ; $y < $height ; $y++) {
        for (my $x = 0 ; $x < $width ; $x++) {
            push @colors, [$p->GetPixel(x => $x, y => $y)];

            # Average of the most prominent and least prominent colors:
            #my $value = (max(@{$colors[-1]}) + min(@{$colors[-1]})) / 2;

            # Average of the colors
            my $value = sum(@{$colors[-1]}) / 3;
            $avg += $value;
        }
    }
    $avg /= $width * $height;

    my $i    = 0;
    my $hash = q{};
    foreach my $color (@colors) {
        vec($hash, $i++, 1) = sum(@{$color}) / 3 < $avg ? 1 : 0;    # set the bits
    }

    return scalar unpack("H*", $hash);
}
