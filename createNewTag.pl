#!/usr/bin/perl

  use strict;
  use warnings;
  use Getopt::Long;
  use File::Path qw(remove_tree);
  my %Options;
  my $repository_url = "https://repository.dataone.org/software/cicore/";
  my $tmp_dir = "/tmp";

  die "Must have a /tmp directory for subversion to manipulate" unless (-d $tmp_dir);

  my $ok = GetOptions(\%Options, "version=s");
  die("Specify a new version with --version major.minor") unless ($ok && $Options{version} =~ /\d+\.\d+/);
  my $version=$Options{version};

  my $tag = "D1_SCHEMA_" . $version;
  $tag=~s/\./\_/;
  my $tag_svn_url= $repository_url . "tags/" . $tag;

  my $trunk_url = $repository_url . "trunk/schemas";

  open(SVN_MKDIR, "/usr/bin/svn copy $trunk_url $tag_svn_url -m \"Creating new branch for schema version $version\" |") || die "can't fork: $!";

  $ok = 0; 
  while (<SVN_MKDIR>) 
    {
      $ok = 1 if /^Committed revision/;
      print $;
    } 
  die ("unable to execute svn copy from $trunk_url to $tag_svn_url") unless ($ok);

 
  open(SVN_CO, "/usr/bin/svn checkout $tag_svn_url ${tmp_dir}/${tag} |") || die "can't fork: $!";

  $ok = 0; 
  while (<SVN_CO>) 
    {
#      $ok = 1 if /^Committed revision/;
      print $;
    } 


  chdir "${tmp_dir}/${tag}";
  my @files = glob("*.xsd");
  foreach my $file (@files) 
    {
    my $old = $file;
    my $new = "$file.tmp.$$";

    open(OLD, "< $old")         or die "can't open $old: $!";
    open(NEW, "> $new")         or die "can't open $new: $!";

    # Correct typos, preserving case
    while (<OLD>) 
      {
      s/trunk\/schemas/tags\/${tag}/i;
      (print NEW $_) or die "can't write to $new: $!";
      }

    close(OLD) or die "can't close $old: $!";
    close(NEW) or die "can't close $new: $!";

    rename($new, $old) or die "can't rename $new to $old: $!";
    }
  open(SVN_COMMIT, "/usr/bin/svn commit -m\"changing urls to tag version $version location 'tags/${tag}' \" .  |") || die "can't fork: $!";

  $ok = 0;
  while (<SVN_COMMIT>)
    {
      $ok = 1 if /^Committed revision/;
      print $;
    }
  die ("unable to execute svn commit to $tag_svn_url") unless ($ok);
 
  chdir;

  remove_tree ("${tmp_dir}/${tag}");
  exit 0;

