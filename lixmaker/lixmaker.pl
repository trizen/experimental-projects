#!/usr/bin/perl
#
# Copyright (C) 2011 Trizen <trizenx@gmail.com>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Experimental install maker.

use Cwd;
use MIME::Base64;
use Gtk2 ('-init');

my $cwd     = getcwd();
my $gui     = 'Gtk2::Builder'->new;
my $appname = 'lixmaker';
my $version = '0.0.1';

if (-e "$appname.glade") {
    $share_path     = '';
    $interface_file = "$appname.glade";
}
else {
    $share_path     = "/usr/share/$appname/";
    $interface_file = "$share_path$appname.glade";
}

$gui->add_from_file($interface_file);
$gui->connect_signals(undef);

my $mainw = $gui->get_object('window1');
$mainw->set_title("$appname $version");
$gui->get_object('entry3')->set_text($cwd);

my $x_glade_interface = join('', <DATA>);
'Gtk2'->main;

sub filechooser {
    $win = $gui->get_object('filechooserdialog1');
    $win->show;
}

sub about {
    $win = $gui->get_object('aboutdialog1');
    $win->set_logo('Gtk2::Gdk::Pixbuf'->new_from_file("$share_path$appname.png"));
    $win->show;
}

sub hide {
    $win->hide;
}

sub exit {
    exit;
}

sub get_filename {
    my $filename = $win->get_filename;
    $gui->get_object('entry1')->set_text($filename);
    if ($gui->get_object('appname')->get_text eq 'Application Name') {
        $gui->get_object('appname')->set_text($1) if $filename =~ m[([^/]+)$];
    }
    &hide;
}

sub create_installer {
    $tarball = $gui->get_object('entry1')->get_text;
    &error($!) unless -r -f $tarball;
    my $outname = $gui->get_object('appname')->get_text . '-' . $gui->get_object('appver')->get_text;
    &error('No output path specified!')
      unless $output_path = $gui->get_object('entry3')->get_text;
    &error($!) unless -d -w $output_path;
    my $output_name = "$output_path/$outname";
    my $n           = 1;

    if (-e "$output_name.lix") {
        $final_name = "$output_name ($n).lix";
        while (-e $final_name) {
            $n += 1;
            $final_name = "$output_name ($n).lix";
        }
    }
    $output_name = $final_name if $final_name;
    print $output_name . "\n";
    $output_name .= '.lix' unless $output_name =~ /\.lix$/;
    my $textview = $gui->get_object('textview1');

    my $description =
      $textview->get_buffer->get_text($textview->get_buffer->get_start_iter, $textview->get_buffer->get_end_iter, 1);
    my $appname = $gui->get_object('appname')->get_text;

    $appname     =~ s[/][ ]g;
    $appname     =~ s/~/\\~/g;
    $outname     =~ s/~/\\~/g;
    $description =~ s/~/\\~/g;

    my $untar_line = $gui->get_object('untar_line')->get_text;
    my $tmp_file   = '/tmp/__temporary_file__.tmp';
    $untar_line =~ s/\$APPNAME/$tmp_file/g;
    &error(q['untar_line' must contain the '$APPNAME' variable!])
      unless $untar_line =~ /$tmp_file/;
    $untar_line = quotemeta $untar_line;
    &error($!) unless open IN, $tarball;
    &error($!) unless open OUT, '>', $output_name;
    print OUT "#!/usr/bin/perl\n";
    print OUT "use MIME::Base64;
sub make_tar {
    open FILE, '>', '${tmp_file}' or &dialog('Unable to continue',\$!);
    while(<DATA>){
        print FILE &decode_base64(\$_);
    }
    close FILE;
}
";

    if ($gui->get_object('cli')->get_active) {
        print OUT "print q~* Application name: '${outname}'\n~;\n";
        print OUT "print q~* Description\n> $description\n~;" if $description;
        print OUT qq[
if (\$ENV{'USER'} eq 'root'){
    print "* Press <ENTER> to continue or insert 'q' to exit...\\n> ";
    chomp(my \$stdin = <STDIN>);
    exit if \$stdin =~ /^(?:q|quit|exit)\$/;
    &make_tar;
    system('${untar_line}');
}else{
    if(-e '/usr/bin/sudo'){
        &make_tar;
        system('sudo ${untar_line}');
    }else{
        &make_tar;
        system('su -c ${untar_line}');
    }
}
];
    }
    elsif (not $gui->get_object('silent')->get_active) {
        print OUT "\$interface = qq[$x_glade_interface];
\nuse Gtk2 ('-init');
\$gui = 'Gtk2::Builder'->new;
\$gui->add_from_string(\$interface);
\$gui->connect_signals(undef);
\$mainw = \$gui->get_object('window1');
\$mainw->set_title(q~'${outname}' installer - Created with lixmaker~);
\$gui->get_object('title')->set_label(q~$outname~);
\$gui->get_object('description')->set_label(q~$description~);
'Gtk2'->main;
\nsub install {
    if(\$ENV{'USER'} eq 'root'){
        &make_tar;
        system(\"${untar_line}\");
    }else{
        if(not -e '/usr/bin/gksu' or not -e '/usr/local/bin/gksu'){
            &dialog('Error', 'Please install the \\'gksu\\' application to continue...');
        }
        &make_tar;
        system('gksu ${untar_line}');
    }
    &dialog('Congratulations!',q~'${appname}' was successfully installed.~);
}
sub dialog{
    \$gui->get_object('label1')->set_text(\$_[0]);
    \$gui->get_object('label2')->set_text(\$_[1]);
    \$win = \$gui->get_object('dialog1');
    \$win->show;
}
sub exit{
    unlink '${tmp_file}' if -e '${tmp_file}';
    exit;
}
";
    }
    elsif ($gui->get_object('silent')->get_active) {
        print OUT "
if (\$ENV{'USER'} eq 'root'){
    &make_tar;
    system(\"${untar_line}\");
}else{
    if(-e '/usr/bin/gksu'){
        &make_tar;
        system('gksu ${untar_line}');
    }
    elsif(-e '/usr/bin/sudo'){
        &make_tar;
        system('sudo ${untar_line}');
    }else{
        &make_tar;
        system('su -c ${untar_line}');
    }
}
unlink '${tmp_file}' if -e '${tmp_file}';
";
    }
    print OUT "__DATA__\n";
    while (defined($_ = <IN>)) {
        print OUT &MIME::Base64::encode($_);
    }
    close OUT;
    $ok_text = "$outname was successfully created to\n$output_name";
    chmod 0755, $output_name;
    &ok($ok_text) if -e $output_name;
}

sub error {
    $gui->get_object('label7')->set_text($_[0]);
    $win = $gui->get_object('dialog1');
    $win->show;
    die;
}

sub ok {
    $gui->get_object('label9')->set_text($_[0]);
    $win = $gui->get_object('dialog2');
    $win->show;
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <requires lib="gtk+" version="2.16"/>
  <!-- interface-naming-policy project-wide -->
  <object class="GtkDialog" id="dialog1">
    <property name="can_focus">False</property>
    <property name="border_width">5</property>
    <property name="window_position">center-on-parent</property>
    <property name="type_hint">dialog</property>
    <property name="transient_for">window1</property>
    <signal name="close" handler="exit" swapped="no"/>
    <child internal-child="vbox">
      <object class="GtkVBox" id="dialog-vbox1">
        <property name="visible">True</property>
        <property name="can_focus">False</property>
        <property name="spacing">2</property>
        <child internal-child="action_area">
          <object class="GtkHButtonBox" id="dialog-action_area1">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="layout_style">end</property>
            <child>
              <object class="GtkButton" id="button4">
                <property name="label">gtk-ok</property>
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="receives_default">True</property>
                <property name="use_action_appearance">False</property>
                <property name="use_stock">True</property>
                <signal name="clicked" handler="exit" swapped="no"/>
              </object>
              <packing>
                <property name="expand">False</property>
                <property name="fill">False</property>
                <property name="position">0</property>
              </packing>
            </child>
            <child>
              <object class="GtkButton" id="button3">
                <property name="label">gtk-close</property>
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="receives_default">True</property>
                <property name="use_action_appearance">False</property>
                <property name="use_stock">True</property>
                <signal name="clicked" handler="exit" swapped="no"/>
              </object>
              <packing>
                <property name="expand">False</property>
                <property name="fill">False</property>
                <property name="position">1</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">True</property>
            <property name="pack_type">end</property>
            <property name="position">0</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="label1">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Congratulations!</property>
            <attributes>
              <attribute name="scale" value="1.7"/>
            </attributes>
          </object>
          <packing>
            <property name="expand">True</property>
            <property name="fill">True</property>
            <property name="position">1</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="label2">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">label</property>
          </object>
          <packing>
            <property name="expand">True</property>
            <property name="fill">True</property>
            <property name="position">2</property>
          </packing>
        </child>
      </object>
    </child>
    <action-widgets>
      <action-widget response="0">button4</action-widget>
      <action-widget response="0">button3</action-widget>
    </action-widgets>
  </object>
  <object class="GtkImage" id="image2">
    <property name="visible">True</property>
    <property name="can_focus">False</property>
    <property name="icon_name">package-x-generic</property>
  </object>
  <object class="GtkWindow" id="window1">
    <property name="visible">True</property>
    <property name="can_focus">False</property>
    <property name="icon_name">package-x-generic</property>
    <signal name="destroy" handler="exit" swapped="no"/>
    <child>
      <object class="GtkVBox" id="vbox1">
        <property name="visible">True</property>
        <property name="can_focus">False</property>
        <child>
          <object class="GtkHBox" id="hbox1">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <child>
              <object class="GtkVBox" id="vbox2">
                <property name="visible">True</property>
                <property name="can_focus">False</property>
                <child>
                  <object class="GtkLabel" id="title">
                    <property name="visible">True</property>
                    <property name="can_focus">False</property>
                    <property name="label" translatable="yes">label</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                      <attribute name="scale" value="1.5"/>
                    </attributes>
                  </object>
                  <packing>
                    <property name="expand">False</property>
                    <property name="fill">False</property>
                    <property name="position">0</property>
                  </packing>
                </child>
                <child>
                  <object class="GtkLabel" id="description">
                    <property name="visible">True</property>
                    <property name="can_focus">False</property>
                    <property name="label" translatable="yes">label</property>
                  </object>
                  <packing>
                    <property name="expand">True</property>
                    <property name="fill">True</property>
                    <property name="position">1</property>
                  </packing>
                </child>
              </object>
              <packing>
                <property name="expand">True</property>
                <property name="fill">True</property>
                <property name="position">0</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="expand">True</property>
            <property name="fill">True</property>
            <property name="position">0</property>
          </packing>
        </child>
        <child>
          <object class="GtkHBox" id="hbox2">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <child>
              <object class="GtkButton" id="button1">
                <property name="label" translatable="yes">Install</property>
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="receives_default">True</property>
                <property name="use_action_appearance">False</property>
                <property name="image">image2</property>
                <signal name="clicked" handler="install" swapped="no"/>
              </object>
              <packing>
                <property name="expand">True</property>
                <property name="fill">True</property>
                <property name="position">0</property>
              </packing>
            </child>
            <child>
              <object class="GtkButton" id="button2">
                <property name="label">gtk-close</property>
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="receives_default">True</property>
                <property name="use_action_appearance">False</property>
                <property name="use_stock">True</property>
                <signal name="clicked" handler="exit" swapped="no"/>
              </object>
              <packing>
                <property name="expand">True</property>
                <property name="fill">True</property>
                <property name="position">1</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">False</property>
            <property name="position">1</property>
          </packing>
        </child>
      </object>
    </child>
  </object>
</interface>
