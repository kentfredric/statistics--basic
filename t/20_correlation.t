
use strict;
use Test;
use Statistics::Basic::Correlation;

plan tests => 5;

my  $corr = new Statistics::Basic::Correlation([1 .. 10], [1 .. 10]);

ok( $corr->query == 1.0 );

    $corr->insert( 11, 7 );
ok( $corr->query == ( (129/20) / (sqrt(609/100) * sqrt(165/20))));

    $corr->set_vector( [11 .. 13], [11 .. 13] );
ok( $corr->query == 1.0 );

    $corr->ginsert( 13, 12 );
ok( $corr->query == ( (1/2) / (sqrt(11/16) * sqrt(1/2)) ));

my  $j = new Statistics::Basic::Correlation;
    $j->set_vector( [11 .. 13], [11 .. 13] );
ok( $j->query == 1.0 );
