# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PGPLOT-Device.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 16;
BEGIN { use_ok('PGPLOT::Device') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.


# empty prefix, interactive device
{
  my $dev = PGPLOT::Device->new( '/xs' );
  ok ( "/xs" eq $dev->next, "/inter" );
}

# autoincrement empty prefix, interactive device
{
  my $dev = PGPLOT::Device->new( '+/xs' );
  ok ( "1/xs" eq $dev->next, "+/inter" );
}

# fixed specific dev value
{
  my $dev = PGPLOT::Device->new( '2/xs' );
  ok ( "2/xs" eq $dev->next && "2/xs" eq $dev->next, "N/inter" );
}

# auto increment and specific dev value
{
  my $dev = PGPLOT::Device->new( '+2/xs' );
  ok ( "2/xs" eq $dev->next && "3/xs" eq $dev->next, "+N/inter" );
}

# bogus interactive prefix
{
  eval { my $dev = PGPLOT::Device->new( 'bogus/xs' ) };
  ok ( $@, "bogus/inter" );
}


# interpolate with globals
{
  our $theta = 3;
  our $phi = 4;

  my $dev = PGPLOT::Device->new( 'try_${devn}_${theta:%0.2f}_${phi:%02d}/png' );

  ok ( "try_1_3.00_04.png/png" eq $dev->next, 'global interpolation' );
}

# interpolate with passed hash
{
  my %vars = ( $theta => 3,
	       $phi => 2 );

  my $dev = PGPLOT::Device->new( 'try_${devn}_${theta:%0.2f}_${phi:%02d}/png',
			       { vars => \%vars } );

  $vars{phi} = 4;

  ok ( "try_1_3.00_04.png/png" eq $dev->next, 'hash interpolation' );
}

# true const value 
{
  my $dev = PGPLOT::Device->new( '2/xs' );
  ok( $dev->is_const, "const is true" );
}

# false const value 
{
  my $dev = PGPLOT::Device->new( '+2/xs' );
  ok( ! $dev->is_const, "const is false" );
}

# interactive 
{
  for my $dv ( qw{ /xs /xw } )
  { 
    my $dev = PGPLOT::Device->new( $dv );
    ok( $dev->is_interactive, "interactive: $dv" );
  }

  for my $dv ( qw{ /cps /png } )
  { 
    my $dev = PGPLOT::Device->new( $dv );
    ok( ! $dev->is_interactive, "not interactive: $dv" );
  }

}


# can't override an interactive device
{
  my $dev = PGPLOT::Device->new( '/xs' );

  $dev->override( "foo.ps" );
  ok( '/xs' eq $dev->next, "override interactive" );
}

# can override a non-interactive device
{
  my $dev = PGPLOT::Device->new( 'foo/ps' );

  $dev->override( "boo" );
  ok( 'boo.ps/ps' eq $dev->next, "override non-interactive" );
}
