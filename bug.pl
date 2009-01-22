use WWW::Search;

$boo = "AIRRACE SHAFT LIGHT";

my $oSearch = new WWW::Search('Ebay::Completed');
my $sQuery = WWW::Search::escape_query($boo);

$oSearch->native_query($sQuery, { _sacat => 307 } );
$oSearch->login($ENV{EBAY_USERID}, $ENV{EBAY_PASSWORD});

while (my $oResult = $oSearch->next_result()) {
        print $oResult->description, "\n";
}

print("END OF RESULTS!!\n\n");

