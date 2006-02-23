
# $Id: Mature.pm,v 1.9 2006/02/23 02:22:56 Daddy Exp $

=head1 NAME

WWW::Search::Ebay::Mature - backend for searching eBay auctions only in the "Mature Audiences" categories

=head1 SYNOPSIS

  use WWW::Search;
  my $oSearch = new WWW::Search('Ebay::Mature');
  my $sQuery = WWW::Search::escape_query("best of Kobe Tai");
  $oSearch->native_query($sQuery);
  $oSearch->login('ebay_userid', 'password');
  while (my $oResult = $oSearch->next_result())
    { print $oResult->url, "\n"; }

=head1 DESCRIPTION

This class is a Ebay specialization of L<WWW::Search>.
It handles making and interpreting Ebay searches
F<http://www.ebay.com>.

This class exports no public interface; all interaction should
be done through L<WWW::Search> objects.

=head1 NOTES

You MUST call the login() method with your eBay username and password
before trying to fetch any results.

The search is done against CURRENT running auctions only.

The query is applied to TITLES only.

See the NOTES section of L<WWW::Search::Ebay> for a description of the results.

=head1 WARNING

This module will automatically ACCEPT the Ebay Terms of Use for Mature
Auction Categories.  If you have any prurient qualms or privacy
concerns, do not use this module!

=head1 SEE ALSO

To make new back-ends, see L<WWW::Search>.

=head1 CAVEATS

=head1 BUGS

Please tell the author if you find any!

=head1 AUTHOR

C<WWW::Search::Ebay::Mature> was written by Martin Thurn
<C<mthurn@cpan.org>>.

C<WWW::Search::Ebay::Mature> is maintained by Martin Thurn
<C<mthurn@cpan.org>.

=head1 LEGALESE

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=cut

#####################################################################

package WWW::Search::Ebay::Mature;

use Carp;
use HTTP::Cookies;
use WWW::Ebay::Session;
use WWW::Search::Ebay;

use strict qw( vars );
use vars qw( @ISA $VERSION $MAINTAINER );

use constant DEBUG_FUNC => 0;
@ISA = qw( WWW::Search::Ebay );

$VERSION = sprintf("%d.%02d", q$Revision: 1.9 $ =~ /(\d+)\.(\d+)/o);
$MAINTAINER = 'Martin Thurn <mthurn@cpan.org>';

sub login
  {
  my $self = shift;
  my ($sUserID, $sPassword) = @_;
  DEBUG_FUNC && print STDERR " + Ebay::Mature::login($sUserID)\n";
  if (ref $self->{__ebay__session__})
    {
    DEBUG_FUNC && print STDERR " +   already called.\n";
    return 1;
    } # if
  # Make sure we keep the cookie(s) from ebay.com:
  my $oJar = new HTTP::Cookies;
  $self->cookie_jar($oJar);
  my $oES = new WWW::Ebay::Session($sUserID, $sPassword);
  return undef unless ref($oES);
  $oES->cookie_jar($oJar);
  $oES->user_agent;
  # Fetch the toplevel mature categories browsing page (just so we
  # sign-in, accept mature disclaimer, and get a cookie):
  my $sURL = 'http://listings.ebay.com/aw/plistings/list/category319/index.html';
  my $sPage = $oES->fetch_any_ebay_page($sURL, 'mature-login');
  # Save our Ebay::Session object for later use, but give it a rare
  # name so that nobody mucks with it:
  $self->{__ebay__session__} = $oES;
  return 1;
  } # login

# private
sub native_setup_search
  {
  my ($self, $native_query, $rhOptsArg) = @_;
  DEBUG_FUNC && print STDERR " + Ebay::Mature::native_setup_search()\n";
  $rhOptsArg ||= [];
  # $rhOptsArg->{'MfcISAPICommand'} = 'GetResult';
  $rhOptsArg->{'categoryid'} = '';
  # $rhOptsArg->{'ht'} = 1;
  $rhOptsArg->{'category1'} = 319;
  # $rhOptsArg->{'search1'} = 'Search';
  $rhOptsArg->{'adult'} = 'y';
  # $rhOptsArg->{'BasicSearch'} = '';
  return $self->SUPER::native_setup_search($native_query, $rhOptsArg);
  } # native_setup_search


sub http_request
  {
  my $self = shift;
  # Make sure we replicate the arguments of WWW::Search::http_request:
  my ($method, $sURL) = @_;
  DEBUG_FUNC && print STDERR " + Ebay::Mature::http_request($method,$sURL)\n";
  my $oES = $self->{__ebay__session__};
  unless (ref $oES)
    {
    carp " --- http_request() was called before login()";
    return undef;
    } # unless
  $oES->fetch_any_ebay_page($sURL, 'wsem-page');
  return $oES->response;
  } # http_request


sub preprocess_results_page_OFF
  {
  my $self = shift;
  my $sPage = shift;
  print STDERR " + page contents from ebay.com ==========$sPage==========\n";
  exit 88;
  return $sPage;
  } # preprocess_results_page

1;

__END__

Browsing the "Mature" category starts at:
http://listings.ebay.com/aw/plistings/list/category319/index.html

Search results:
http://search.ebay.com/search/search.dll?MfcISAPICommand=GetResult&query=best+of+kobe+tai&ht=1&adult=y&category1=319&SortProperty=MetaEndSort

http://search.ebay.com/search/search.dll?cgiurl=http%3A%2F%2Fcgi.ebay.com%2Fws%2F&MfcISAPICommand=GetResult&query=best+of+kobe+tai&categoryid=&ht=1&adult=y&category1=319&SortProperty=MetaEndSort&BasicSearch=&from=R2&catref=C3

