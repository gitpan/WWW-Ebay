
# $Id: Completed.pm,v 1.29 2008/10/22 03:10:30 Martin Exp $

=head1 NAME

WWW::Search::Ebay::Completed - backend for searching completed auctions on www.ebay.com

=head1 SYNOPSIS

  use WWW::Search;
  my $oSearch = new WWW::Search('Ebay::Completed');
  my $sQuery = WWW::Search::escape_query("Yakface");
  $oSearch->native_query($sQuery);
  $oSearch->login('ebay_username', 'ebay_password');
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

The search is done against completed auctions only.

The query is applied to TITLES only.

See the NOTES section of L<WWW::Search::Ebay> for a description of the results.

=head1 METHODS

=cut

#####################################################################

package WWW::Search::Ebay::Completed;

use strict;
use warnings;

use Carp;
use Date::Manip;
# We need the version that was fixed to be able to parse completed
# item search results:
use WWW::Search::Ebay 2.217;
use WWW::Ebay::Session;
use base 'WWW::Search::Ebay';

our
$VERSION = do { my @r = (q$Revision: 1.29 $ =~ /\d+/g); sprintf "%d."."%03d" x $#r, @r };

my $MAINTAINER = 'Martin Thurn <mthurn@cpan.org>';

use constant DEBUG_FUNC => 0;

sub _native_setup_search
  {
  my ($self, $native_query, $rhOptsArg) = @_;
  $rhOptsArg ||= {};
  unless (ref($rhOptsArg) eq 'HASH')
    {
    carp " --- second argument to _native_setup_search should be hashref, not arrayref";
    return undef;
    } # unless
  # As of Summer 2008:
  # http://completed.shop.ebay.com/items/_W0QQLHQ5fCompleteZ1?_nkw=keychain+ahsoka&_sacat=0&_fromfsb=&_trksid=m270.l1313&_odkw=lego+ahsoka&_osacat=0
  $self->{'search_host'} = 'http://completed.shop.ebay.com';
  $self->{search_path} = q{/items/_W0QQLHQ5fCompleteZ1};
  $self->{_options} = {
                       _nkw => $native_query,
                       # __sacat => 0,
                       # __fromfsb => '',
                       # __trksid => 'm270.l1313',
                       # __odkw => $native_query,
                       # __osacat => 0,
                      };
  return $self->SUPER::_native_setup_search($native_query, $rhOptsArg);
  } # _native_setup_search

=head2 login

Takes two string arguments,
the eBay userid and the eBay password.
(See WWW::Search for more information.)

=cut

sub login
  {
  my $self = shift;
  my ($sUserID, $sPassword) = @_;
  if (ref $self->{__ebay__session__})
    {
    DEBUG_FUNC && print STDERR " +   login() was already called.\n";
    return 1;
    } # if
  DEBUG_FUNC && print STDERR " + Ebay::Completed::login($sUserID)\n";
  # Make sure we keep the cookie(s) from ebay.com:
  my $oJar = new HTTP::Cookies;
  $self->cookie_jar($oJar);
  my $oES = new WWW::Ebay::Session($sUserID, $sPassword);
  return undef unless ref($oES);
  $oES->cookie_jar($oJar);
  $oES->user_agent;
  # Save our Ebay::Session object for later use, but give it a rare
  # name so that nobody mucks with it:
  $self->{__ebay__session__} = $oES;
  return 1;
  } # login

=head2 http_request

This method does the heavy-lifting of fetching encrypted pages from ebay.com.
(See WWW::Search for more information.)

=cut

sub http_request
  {
  my $self = shift;
  # Make sure we replicate the arguments of WWW::Search::http_request:
  my ($method, $sURL) = @_;
  DEBUG_FUNC && print STDERR " + Ebay::Completed::http_request($method,$sURL)\n";
  my $oES = $self->{__ebay__session__};
  unless (ref $oES)
    {
    carp " --- http_request() was called before login()?";
    return undef;
    } # unless
  $oES->fetch_any_ebay_page($sURL, 'wsec-page');
  return $oES->response;
  } # http_request

sub _preprocess_results_page
  {
  my $self = shift;
  my $sPage = shift;
  # For debugging:
  print STDERR $sPage;
  exit 88;
  } # preprocess_results_page

sub _columns
  {
  my $self = shift;
  # This is for basic USA eBay:
  return qw( paypal bids price shipping enddate );
  } # _columns

sub _title_element_specs
  {
  return (
          '_tag' => 'td',
          'class' => 'ebUpper ebcTtl',
         );
  } # _title_element_specs


=head2 _parse_enddate

Defines how to parse the auction ending date from the HTML.
(See WWW::Search::Ebay for more information.)

=cut

sub _parse_enddate
  {
  my $self = shift;
  my $oTDdate = shift;
  my $hit = shift;
  if (! ref $oTDdate)
    {
    return 0;
    }
  my $s = $oTDdate->as_text;
  print STDERR " DDD   TDdate ===$s===\n" if 1 < $self->{_debug};
  # I don't know why there are sometimes weird characters in there:
  $s =~ s!&Acirc;!!g;
  $s =~ s!Â!!g;
  # Convert nbsp to regular space:
  $s =~ s!\240!\040!g;
  my $date = &ParseDate($s);
  print STDERR " DDD     date ===$date===\n" if 1 < $self->{_debug};
  my $sDate = $self->_format_date($date);
  $hit->end_date($sDate);
  return 1;
  } # _parse_enddate

1;

=head1 SEE ALSO

To make new back-ends, see L<WWW::Search>.

=head1 CAVEATS

=head1 BUGS

Please tell the author if you find any!

=head1 AUTHOR

Thanks to Troy Arnold <C<troy at zenux.net>> for figuring out how to do this search.

Maintained by Martin Thurn, C<mthurn@cpan.org>, L<http://www.sandcrawler.com/SWB/cpan-modules.html>.

=head1 LEGALESE

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=cut

__END__

This is the HTML for one result, as of 2006-02-18:

<tr class="ebHlOdd ebUpper">
<td rowspan="2" class="ebLeft"> </td>
<td class="ebcPic" rowspan="2"><a href="http://cgi.ebay.com/Star-Wars-POTJ-Shmi-Skywalker-MOC_W0QQitemZ6036472221QQcategoryZ50269QQrdZ1QQcmdZViewIte"m><img height="20" width="20" border="0" title="Listing has pictures" alt="Listing has pictures" src="http://pics.ebaystatic.com/aw/pics/icon/iconPic_20x20.gif"></img></a></td>
<td class="ebUpper ebcTtl" colspan="5"><h3 class="ens fontnormal"><a href="http://cgi.ebay.com/Star-Wars-POTJ-Shmi-Skywalker-MOC_W0QQitemZ6036472221QQcategoryZ50269QQrdZ1QQcmdZViewItem">Star Wars POTJ - Shmi Skywalker - MOC!!</a></h3><span class="icons"><img border="0" src="http://pics.ebaystatic.com/aw/pics/s.gif" id="sr_giftIcon_0"></img> </span></td>
<td class="ebcAct" rowspan="2"><ul class="navigation"><li><span><a href="http://search.ebay.com/search/search.dll?GetResult&amp;query=Star+Wars+POTJ++-++Shmi+Skywalker++-++MOC%21%21&amp;sibeleafcat=50269&amp;sim=y">View similar active items</a></span></li><li><span><a href="http://cgi5.ebay.com/ws2/eBayISAPI.dll?SellLikeItem&amp;Item=6036472221">List an item like this</a></span></li></ul></td>
<td rowspan="2" class="ebRight"> </td></tr>
<tr class="ebHlOdd ebLower">
<td class="ebLower"> </td>
<td class="ebLower ebcBid">1</td>
<td class="ebLower ebcPr"><span class="ebSold">$0.99</span><br /></td>
<td class="ebLower ebcShpNew"><span class="shpTxt">$4.00</span></td>
<td class="ebLower ebcTim">Feb-17 21:23</td></tr>
