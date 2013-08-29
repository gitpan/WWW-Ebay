
# $rcs = ' $Id: Ebay.pm,v 1.33 2013/08/20 22:35:13 Martin Exp $ ' ;

=head1 NAME

WWW::Ebay - Search and manage eBay auctions

=head1 DESCRIPTION

This is an empty module.  It only exists so that CPAN users can say
"install WWW::Ebay" (and CPANPLUS users can say "i WWW::Ebay") and
they'll get what they expect.  Well, actually I'm not sure what they
expect, but they'll get something reasonable.

It is also used to control the version number of the distribution.

=head1 SEE ALSO

L<WWW::Ebay::Customer|WWW::Ebay::Customer>,
L<WWW::Ebay::Listing|WWW::Ebay::Listing>,
L<WWW::Ebay::Search|WWW::Ebay::Search>,
L<WWW::Ebay::Session>,
L<WWW::Ebay::Status>,
L<WWW::Search::Ebay>,
L<WWW::Search::Ebay::Completed>
L<WWW::Search::Ebay::Completed::Category>

=head1 AUTHOR

Martin 'Kingpin' Thurn, C<mthurn at cpan.org>, L<http://tinyurl.com/nn67z>.

=head1 LICENSE

This software is released under the same license as Perl itself.

=cut

package WWW::Ebay;

use strict;
use warnings;

require 5.005;

our
$VERSION = '0.096';

1;

__END__

