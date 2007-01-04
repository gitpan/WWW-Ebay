
# $Id: Completed.pm,v 1.21 2007/01/04 00:59:49 Daddy Exp $

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

#####################################################################

package WWW::Search::Ebay::Completed;

use Carp;
use Date::Manip;
# We need the version that was modified to be able to parse completed
# auction search results:
use WWW::Search::Ebay 2.180;
use WWW::Ebay::Session;
@ISA = qw( WWW::Search::Ebay );

use strict;

use vars qw( $MAINTAINER $VERSION );
$MAINTAINER = 'Martin Thurn <mthurn@cpan.org>';
$VERSION = do { my @r = (q$Revision: 1.21 $ =~ /\d+/g); sprintf "%d."."%03d" x $#r, @r };

use constant DEBUG_FUNC => 0;

# private
sub native_setup_search
  {
  my ($self, $native_query, $rhOptsArg) = @_;
  $rhOptsArg ||= {};
  unless (ref($rhOptsArg) eq 'HASH')
    {
    carp " --- second argument to native_setup_search should be hashref, not arrayref";
    return undef;
    } # unless
  $self->{'search_host'} = 'http://search-completed.ebay.com';
  $rhOptsArg->{'soitemstatus'} = 2;
  return $self->SUPER::native_setup_search($native_query, $rhOptsArg);
  } # native_setup_search

sub login
  {
  my $self = shift;
  my ($sUserID, $sPassword) = @_;
  DEBUG_FUNC && print STDERR " + Ebay::Completed::login($sUserID)\n";
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
  # Save our Ebay::Session object for later use, but give it a rare
  # name so that nobody mucks with it:
  $self->{__ebay__session__} = $oES;
  return 1;
  } # login

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

sub preprocess_results_page_OFF
  {
  my $self = shift;
  my $sPage = shift;
  # For debugging:
  print STDERR $sPage;
  exit 88;
  } # preprocess_results_page

sub _title_td_specs
  {
  return (
          '_tag' => 'td',
          'class' => 'ebUpper ebcTtl',
         );
  } # _title_td_specs

sub columns
  {
  my $self = shift;
  # This is for basic USA eBay:
  return qw( bids price shipping enddate );
  } # columns

sub parse_enddate
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
  # Convert nbsp to regular space:
  $s =~ s!\240!\040!g;
  my $date = &ParseDate($s);
  print STDERR " DDD     date ===$date===\n" if 1 < $self->{_debug};
  my $sDate = $self->_format_date($date);
  $hit->end_date($sDate);
  return 1;
  } # parse_enddate

1;

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
