
# $Id: Makefile.PL,v 1.30 2008/03/02 18:19:34 Daddy Exp $

use inc::Module::Install;
use strict;

name('WWW-Ebay');
version_from('lib/WWW/Ebay.pm');
author('Martin Thurn <mthurn@cpan.org>');
abstract('Search and manage eBay auctions');
license('perl');

build_requires('Bit::Vector' => 0);
requires('Bit::Vector');
requires('Carp');
requires('Crypt::SSLeay');
build_requires('Data::Dumper');
requires('Data::Dumper');
build_requires('Date::Manip');
requires('Date::Manip');
requires('File::Glob');
requires('File::Spec');
requires('HTML::Form');
requires('HTML::Parser' => 3);
requires('HTML::TreeBuilder');
requires('HTTP::Cookies');
requires('HTTP::Request::Common');
build_requires('IO::Capture::Stderr');
requires('LWP::Simple');
requires('LWP::UserAgent');
build_requires('Test::Inline');
build_requires('Test::More');
# Tk is only needed for Email::editor()
recommends('Tk' => 800);
requires('URI');
# We need the version that defines _load_env_useragent:
requires('WWW::Search' => 2.525);
# We need the version that has the shipping() method:
requires('WWW::SearchResult' => 2.070);
# We need the version whose parse_enddate() takes a string as arg2:
requires('WWW::Search::Ebay' => 2.181);
# We need the version of WWW::Search::Test that exports its tm_
# functions:
build_requires('WWW::Search::Test' => 2.265);

WriteAll();

my @asNeeded;
foreach my $s (qw( EBAY_USERID EBAY_PASSWORD ))
  {
  push @asNeeded, $s unless ($ENV{$s} ne '');
  } # foreach
if (@asNeeded)
  {
  print STDERR join("\n", '',
                    q{In order to run all the automatic tests for this distribution,},
                    q{you should set the following environment variables:},
                    @asNeeded, '', '');
  } # if

sub MY::postamble
  {
  my $ret = <<'PART0';
coverage :
	cover -delete
	$(MAKE) HARNESS_PERL_SWITCHES=-MDevel::Cover coverage_slave
coverage_slave : test
	cover
PART0
  return $ret;
  } # MY::postamble

# The following block was added for Test::Inline handling.  Derived
# from `perldoc Test::Inline::Tutoral` but modified to work with
# ActivePerl on Win32.
  {
  package MY;
  use File::Spec::Functions;

  sub top_targets
    {
    my $self = shift;
    # Use the default setting for (not) echoing commands during make:
    my $NOECHO = $self->{NOECHO};
    # And, ignore error signals.  This is necessary because pod2test
    # carps if the file contains no test code!
    $NOECHO .= '-';
    # Assume that pod2test was installed into the same place as perl
    # itself:
    my $POD2TEST = '$(INSTALLBIN)/pod2test';
    # But on Windows, it MUST be in the path:
    $POD2TEST = 'pod2test' if $^O =~ m!win32!i;
    my $out = "POD2TEST_EXE = $POD2TEST\n";
    $out .= $self->SUPER::top_targets(@_);
    $out .= "\n\ntestifypods : \n";
    $out .= "\t\$(FULLPERL) -MExtUtils::Command -e rm_f t/embedded-*.t\n";
    # use Data::Dumper; print STDERR " + self is ", Dumper($self);
    my %hsPOD;
    foreach my $pod (keys %{$self->{MAN1PODS}},
                     keys %{$self->{MAN3PODS}},
                     # Win32 has no MANPODS, so we add these:
                     keys %{$self->{PM}},
                    )
      {
      # print STDERR " +   will testifypod $pod\n";
      $hsPOD{$pod}++;
      } # foreach $pod
    foreach my $pod (keys %hsPOD)
      {
      # print STDERR " +   writing code to testifypod $pod\n";
      (my $test = $pod) =~ s/\.(pm|pod)$//;
      $test =~ s|/|-|g;
      $test =~ s/^lib\W//;
      $test =~ s/\W/-/;
      $test = "embedded-$test.t";
      my $sCode = "\$(POD2TEST_EXE) $pod t/$test";
      # print STDERR " +     code to testifypod $pod is ==$sCode==\n";
      $out .= "\t$NOECHO $sCode\n";
      } # foreach
    return $out;
    } # MY::top_targets

  sub test
    {
    my $self = shift;
    my $out = $self->SUPER::test(@_);
    # Insert our target as a prerequisite for the main test goal:
    $out =~ s!^(test :: )(.*)!$1 pure_all testifypods $2!m;
    return $out;
    } # MY::test

  } # end of package MY block

__END__

