#!/usr/bin/perl

  use strict;
  use warnings;
  use Getopt::Long;
  my @files = glob("*.xsd");
  my %Options;
  my $ok = GetOptions(\%Options, "version=s");

  die("Specify a new version with --version major.minor") unless ($ok && $Options{version} =~ /\d+\.\d+/);
  my $version=$Options{version};
  my $tag_location=$version;
  $tag_location=~s/\./\_/;

  foreach my $file (@files) 
    {
    my $old = $file;
    my $new = "$file.tmp.$$";

    open(OLD, "< $old")         or die "can't open $old: $!";
    open(NEW, "> $new")         or die "can't open $new: $!";

    # Correct typos, preserving case
    while (<OLD>) 
      {
      s/(http\:\/\/dataone\.org.+?)\d+\.\d+/${1}${version}/i;
      s/(?<!xml\s)(version\=)\"\d+\.\d+\"/${1}\"${version}\"/i;
      (print NEW $_) or die "can't write to $new: $!";
      }

    close(OLD) or die "can't close $old: $!";
    close(NEW) or die "can't close $new: $!";

    rename($new, $old) or die "can't rename $new to $old: $!";
    }

  exit 0;

