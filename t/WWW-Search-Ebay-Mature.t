# -*- cperl -*-

use ExtUtils::testlib;
use Test::More no_plan;

BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test') };
BEGIN { use_ok('WWW::Ebay::Session') };
BEGIN { use_ok('WWW::Search::Ebay::Mature') };

my $iDebug = 0;
my $iDump = 0;

&tm_new_engine('Ebay::Mature');
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
  skip "eBay userid/password not supplied", 4 if (($sUserID   eq '') ||
                                                  ($sPassword eq ''));
  ok($WWW::Search::Test::oSearch->login($sUserID, $sPassword));
  # goto TEST_NOW;

  # This test returns no results (but we should not get an HTTP error):
  $iDebug = 0;
  $iDump = 0;
  &tm_run_test('normal', $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
 TEST_NOW:
  $iDebug = 0;
  $iDump = 0;
  &tm_run_test('normal', 'Kobe Tai', 1, undef, $iDebug, $iDump);
  } # SKIP

exit 0;

__END__

