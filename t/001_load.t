# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Hey::heyPass' ); }

my $object = Hey::heyPass->new ();
isa_ok ($object, 'Hey::heyPass');


