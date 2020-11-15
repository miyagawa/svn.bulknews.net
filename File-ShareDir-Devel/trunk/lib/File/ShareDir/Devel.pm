package File::ShareDir::Devel;

use strict;
our $VERSION = '0.01';

use Carp;
use Cwd ();
use File::ShareDir ();
use File::Spec;
use FindBin;

our %Dir;
our %Fallbacks;

sub import {
    my $class = shift;

    for my $module (@_) {
        my $dist    = _dist($module);
        $Dir{$dist} = _find_base();
    }

    for my $func ( qw( dist_dir module_dir dist_file module_file ) ) {
        unless ($Fallbacks{$func}) {
            no strict 'refs';
            no warnings 'redefine';
            my $symbol = "File::ShareDir::$func";
            $Fallbacks{$func} = \&$symbol;
            *$symbol = \&$func;
        }
    }
}

sub _fallback {
    my($func, @args) = @_;
    $Fallbacks{$func}->(@args);
}

sub _dist {
    my $module = shift;
    my @module = split /::/, $module;
    join '-', @module;
}

sub _find_base {
    my $cwd = Cwd::cwd;
    my $bin = $FindBin::Bin;

    for my $dir ($cwd, $bin, File::Spec->updir($cwd), File::Spec->updir($bin)) {
        my $share = File::Spec->catfile($dir, "share");
        if (-d $share) {
            return $share;
        }
    }
}

sub dist_dir {
    my($dist) = @_;
    return $Dir{$dist} if exists $Dir{$dist};
    _fallback('dist_dir', @_);
}

sub dist_file {
    my($dist, $file) = @_;
    if (exists $Dir{$dist}) {
        return File::Spec->catfile($Dir{$dist}, $file);
    }
    _fallback('dist_file', @_);
}

sub module_dir {
    my($module) = @_;

    my $inc  = Class::Inspector->loaded_filename($module);
    my @dirs = File::Spec->splitdir($inc);
    my @mods = split /::/, ($module. ".pm");

    for my $part (reverse @mods) {
        last unless $dirs[-1] eq $part;
        pop @dirs;
    }

    pop @dirs if $dirs[-1] eq 'lib';
    pop @dirs if $dirs[-1] eq 'blib';

    my $share = File::Spec->catfile(@dirs, "share");
    if (-d $share) {
        return $share;
    }

    _fallback('module_dir', @_);
}

sub module_file {
    my($module, $file) = @_;
    my $dir = module_dir($module);
    return File::Spec->catfile($dir, $file);
}

1;
__END__

=for stopwords svn

=head1 NAME

File::ShareDir::Devel - Development mode to work with File::ShareDir and Module::Install::Share

=head1 SYNOPSIS

  # in command-line scripts or .t files
  use File::ShareDir::Devel 'Your-Module';

  # in another pirce of code
  use File::ShareDir ':ALL';

  # Where are distribution-level shared data files kept
  $dir = dist_dir('Your-Module');

  # Where are module-level shared data files kept
  $dir = module_dir('Your::Module');

  # Find a specific file in our dist/module shared dir
  $file = dist_file(  'Your-Module',  'file/name.txt');
  $file = module_file('Your::Module', 'file/name.txt');

=head1 DESCRIPTION

File::ShareDir::Devel is a fake wrapper around File::ShareDir to allow
reading files from I<share> directory before you actually install
shared files to I<auto> directory.

=head1 RATIONALE

Module::Install::Share requires you to put shared files in I<share>
directory, but File::ShareDir doesn't recognize the I<share> directory
as a shared files source. You need to run C<make install> to read
them, which goes to chicken-and-egg problem when you need them in
tests (.t files) or running the command line tool from svn checkout.

=head1 EXAMPLE

Imagine you're in the following directory structure:

  /home/
    miyagawa/
      Your-Module/ <= Current directory
        lib/
          Your/
            Module.pm
        share/
          file/
            name.txt
        t/
          foo.t

In I<t/foo.t>, you need to declare your module name in I<use> line, so
File::ShareDir::Devel knows which module's shared directory to
override.

  use File::ShareDir::Devel 'Your-Module';

  # now $file is '/home/miyagawa/Your-Module/share/file/name.txt'
  # because File::ShareDir knows that Your-Module/share is the share dir
  $file = dist_file(  'Your-Module',  'file/name.txt');

  # Ditto, but by traversing $INC{"Your/Module.pm"}
  $file = module_file( 'Your::Module', 'file/name.txt');

Shared root directory for dist_* is scanned using L<Cwd> and
L<FindBin>, but if you'd like to specify the base directory, do this.

  use File::ShareDir::Devel 'Your-Module';
  $File::ShareDir::Devel::Dir{"Your-Module"} = "/path/to/Your-Module";

Shared root directory for module_* is scanned using %INC and upping
the directory to 2 levels, so either loading I<lib/Your/Module.pm> or
I<blib/lib/Your/Module.pm> would work.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<File::ShareDir>, L<Module::Install::Share>

=cut
