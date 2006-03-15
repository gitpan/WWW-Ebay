use ExtUtils::testlib;

use Test::More no_plan;

BEGIN { use_ok('WWW::Ebay::Session') };

use strict;

my $sUser = $ENV{'EBAY_USERID'};
diag("Trying to sign in as $sUser, with password from env.var EBAY_PASSWORD...");
my $oSession = new WWW::Ebay::Session($sUser, $ENV{'EBAY_PASSWORD'});
ok(ref($oSession));
my $s = $oSession->signin;
isnt($s, 'FAILED', 'sign-in');
diag("Fetching $sUser\'s watchlist...");
my @aoListings = $oSession->watchlist_auctions('Pages/watchlist.html');
my $iAnyError = $oSession->any_error;
diag($oSession->error);
SKIP:
  {
  skip sprintf("because %s has no auctions in watchlist", $oSession->{_user}), 1 if (@aoListings == 0);
  ok(! $iAnyError);
  diag(sprintf(q{The following auctions were found on %s's ebay watchlist:}, $oSession->{_user}));
 LISTING:
  foreach my $oListing (@aoListings)
    {
    diag($oListing->title);
    # like($oListing->question_count, qr{\A\d+\Z}, 'question_count is an integer');
    # like($oListing->watcher_count, qr{\A\d+\Z}, 'watcher_count is an integer');
    like($oListing->bid_count, qr{\A\d+\Z}, 'bid_count is an integer');
    isnt($oListing->end_date, '', 'end_date is not empty');
    # like($oListing->bid_amount, qr{\A\d+\Z}, 'bid_amount is an integer');
    isnt($oListing->seller, '', 'seller is not empty');
    if ($oListing->bid_count)
      {
      isnt($oListing->bidder, '', 'bidder is not empty');
      } # if
    } # foreach LISTING
  } # end of SKIP block

exit 0;

__END__

