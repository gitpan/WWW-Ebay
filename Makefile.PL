
# $Id: Makefile.PL,v 1.36 2010-02-14 21:48:38 Martin Exp $

use inc::Module::Install;
use strict;

all_from('lib/WWW/Ebay.pm');

test_requires('Bit::Vector' => 0);
requires('Bit::Vector');
requires('Carp');
requires('Crypt::SSLeay');
test_requires('Data::Dumper');
requires('Data::Dumper');
test_requires('Date::Manip');
requires('Date::Manip');
requires('File::Glob');
requires('File::Spec');
requires('HTML::Form');
requires('HTML::Parser' => 3);
requires('HTML::TreeBuilder');
requires('HTTP::Cookies');
requires('HTTP::Request::Common');
test_requires('IO::Capture::Stderr');
requires('LWP::Simple');
requires('LWP::UserAgent');
test_requires('Test::More');
# Tk is only needed for Email::editor()
recommends('Tk' => 800);
requires('URI');
# We need the version that defines _load_env_useragent:
requires('WWW::Search' => 2.525);
# We need the version that has the shipping() method:
requires('WWW::SearchResult' => 2.070);
# We need the version that was fixed to look for "Free Shipping":
requires('WWW::Search::Ebay' => 2.247);
# We need the version that exports its tm_ functions:
test_requires('WWW::Search::Test' => 2.265);

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
	- cover -delete
	$(MAKE) HARNESS_PERL_SWITCHES=-MDevel::Cover test
	cover
PART0
  return $ret;
  } # MY::postamble

__END__

