# -*- cperl -*-

use strict;
use warnings;

# $Id: completed.t,v 1.9 2013/08/21 01:13:39 Martin Exp $

# use LWP::Debug qw( + -conns );

use blib;
use Bit::Vector;
use Data::Dumper;
use Date::Manip;
use ExtUtils::testlib;
use Test::More 'no_plan';

use constant DEBUG_ONE => 0;

use WWW::Search::Test;
BEGIN
  {
  use_ok('WWW::Search::Ebay::Completed');
  }

my $iDebug = 0;
my $iDump = 0;

$iDebug = 0;
tm_new_engine('Ebay::Completed');
SKIP:
  {
  # See if ebay userid is in environment variable:
  my $sUserID = $ENV{EBAY_USERID} || '';
  my $sPassword = $ENV{EBAY_PASSWORD} || '';
  if (($sUserID eq '') || ($sPassword eq ''))
    {
    diag("In order to test this module, set environment variables EBAY_USERID and EBAY_PASSWORD.");
    if (0)
      {
      print <<'PROMPT';
Type an eBay userid and password to be used for testing.
(You can set environment variables EBAY_USERID and EBAY_PASSWORD
 to avoid this prompt next time.)
eBay userid: 
PROMPT
      # Read one line from STDIN:
      local $/ = "\n";
      $sUserID = <STDIN>;
      chomp $sUserID;
      # Don't ask for password if they didn't enter a userid:
      if ($sUserID ne '')
        {
        print "password: ";
        $sPassword = <STDIN>;
        chomp $sPassword;
        } # if
      } # if
    } # if
  skip "eBay userid/password not supplied", 11 if (($sUserID   eq '') ||
                                                   ($sPassword eq ''));
  diag("log in as $sUserID...");
  ok($WWW::Search::Test::oSearch->login($sUserID, $sPassword), 'logged in');
  DEBUG_ONE && goto TEST_ONE;

  # This test returns no results (but we should not get an HTTP error):
  diag("sending zero-page query...");
  $iDebug = 0;
  tm_run_test('normal', $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
  diag("sending multi-page query...");
  $iDebug = 0;
  $iDump = 0;
  tm_run_test('normal', 'lego', 101, undef, $iDebug, $iDump);

 TEST_ONE:
  diag("sending one-page query...");
  $iDebug = 0;
  $iDump = 0;
  $WWW::Search::Test::sSaveOnError = q{completed-failed.html};
  my $sQuery = q{ahsoka keychain};
  $sQuery = q{playboy october 1977};
  tm_run_test('normal', $sQuery, 1, 99, $iDebug, $iDump);
  # Now get the results and inspect them:
  my @ao = $WWW::Search::Test::oSearch->results();
  cmp_ok(0, '<', scalar(@ao), 'got some results');
  my @ara = (
             ['url', 'like', qr{\Ahttp://(cgi|www)\d*\.ebay\.com}i, 'URL is really from ebay.com'],
             ['title', 'ne', 'q{}', 'Title is not empty'],
             ['end_date', 'date', 'end_date is really a date'],
             ['description', 'like', qr{Item #\d+;}, 'description contains item #'],
             ['description', 'like', qr{\d+\.\d+(\Z|\s\()}, 'description contains result amount'],
             ['description', 'like', qr{\b(\d+|no)\s+bids?|Buy-It-Now}, # }, # Emacs bug
              'result bidcount is ok'],
             ['bid_count', 'like', qr{\A\d+\z}, 'bid_count is a number'],
            );
  WWW::Search::Test::test_most_results(\@ara, 0.95);
  DEBUG_ONE && goto ALL_DONE;

  diag("sending one-page query against a particular category...");
  # An additional test for the following problems reported by users:
  # 1) query gets cut off at space and 2) query restriction by
  # category does not work.
  $WWW::Search::Test::oSearch->reset_search;
  $WWW::Search::Test::oSearch->native_query('Asoka+Tano',
                                              {
                                               _sacat => 18991,
                                               # search_debug => 1,
                                              }
                                   );
  my @aoResult = $WWW::Search::Test::oSearch->results;
  my $iResults = scalar(@aoResult);
  cmp_ok(0, '<', $iResults, 'got some results');
  cmp_ok($iResults, '<', 99, 'did not get too many results');
  } # SKIP

ALL_DONE:
pass('all done');
exit 0;

__END__

