# -*- cperl -*-

# $Id: completed.t,v 1.4 2009/01/10 14:42:58 Martin Exp $

# use LWP::Debug qw( + -conns );

use Bit::Vector;
use Data::Dumper;
use Date::Manip;
use ExtUtils::testlib;
use Test::More no_plan;

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
  goto TEST_NOW;

  # This test returns no results (but we should not get an HTTP error):
  diag("sending zero-page query...");
  $iDebug = 0;
  tm_run_test('normal', $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
  diag("sending multi-page query...");
  $iDebug = 0;
  $iDump = 0;
  tm_run_test('normal', 'lego', 101, undef, $iDebug, $iDump);

  diag("sending one-page query...");
  $iDebug = 0;
  $iDump = 0;
  $WWW::Search::Test::sSaveOnError = q{completed-failed.html};
  tm_run_test('normal', 'ahsoka keychain', 1, 99, $iDebug, $iDump);
  # Now get the results and inspect them:
  my @ao = $WWW::Search::Test::oSearch->results();
  cmp_ok(0, '<', scalar(@ao), 'got some results');
  # We perform this many tests on each result object:
  my $iTests = 7;
  my $iAnyFailed = my $iResult = 0;
  my ($iVall, %hash);
  foreach my $oResult (@ao)
    {
    $iResult++;
    my $oV = new Bit::Vector($iTests);
    $oV->Fill;
    $iVall = $oV->to_Dec;
    # Create a vector of which tests passed:
    $oV->Bit_Off(1) unless like($oResult->url,
                                qr{\Ahttp://cgi\d*\.ebay\.com},
                                'result URL is really from ebay.com');
    $oV->Bit_Off(2) unless cmp_ok($oResult->title, 'ne', '',
                                  'result Title is not empty');
    $oV->Bit_Off(3) unless cmp_ok(ParseDate($oResult->end_date) || '',
                                  'ne', '',
                                  'end_date is really a date');
    $oV->Bit_Off(4) unless like($oResult->description,
                                qr{Item #\d+;},
                                'result item number is ok');
    $oV->Bit_Off(5) unless like($oResult->description,
                                qr{\s((\d+|no)\s+bids?|Buy-It-Now);},
                                'result bidcount is ok');
    $oV->Bit_Off(6) unless like($oResult->bid_count, qr{\A\d+\Z},
                                'bid_count is a number');
    $oV->Bit_Off(0) unless like($oResult->description,
                                qr{\d+\.\d+(\Z|\s\()},
                                'result amount looks ok');
    my $iV = $oV->to_Dec;
    if ($iV < $iVall)
      {
      $hash{$iV} = $oResult;
      $iAnyFailed++;
      } # if
    } # foreach
  if ($iAnyFailed)
    {
    diag(" Here are results that exemplify the failures:");
    while (my ($sKey, $sVal) = each %hash)
      {
      diag(Dumper($sVal));
      } # while
    } # if any failures
 TEST_NOW:
  # An additional test for user reports that 1) query gets cut off at
  # space and 2) query restriction by category does not work.
  $WWW::Search::Test::oSearch->reset_search;
  $WWW::Search::Test::oSearch->native_query('Ahsoka+Tano',
                                              {
                                               _sacat => 18991,
                                               # search_debug => 1,
                                              }
                                   );
  my @aoResult = $WWW::Search::Test::oSearch->results;
  cmp_ok(scalar(@aoResult), '<', 99);
  } # SKIP

exit 0;

__END__

