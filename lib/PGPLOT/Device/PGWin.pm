package PGPLOT::Device::PGWin;

use strict;
use warnings;

use Carp;

our @ISA = qw();

our $VERSION = '0.02';


use PGPLOT::Device;
use PGPLOT qw/ pgask /;

sub new
{
  my ( $class, $opt ) = @_;

  my %opt = ( WinOpts => {},
	      defined $opt ? %$opt : () );

  my $self = {};
  $self->{device} = 
    PGPLOT::Device->new(
			defined $opt{Device}  ? $opt{Device}  : (),
			defined $opt{DevOpts} ? $opt{DevOpts} : (),
		       );
  $self->{not_first} = 0;
  $self->{win} = undef;
  $self->{WinOpts} = $opt{WinOpts};

  bless $self, $class;

  $self;
}

sub device { $_[0]->{device} }

sub next
{
  my $self = shift;

  $self->override( @_ ) if @_;

  # prompt user before displaying second and subsequent plots if
  # a new plot will erase the previous one
  pgask( $self->{device}->ask )
    if $self->{not_first}++;

  if ( $self->{device}->would_change )
  {
    $self->{win}->close if defined $self->{win};
    $self->{win} = 
      PDL::Graphics::PGPLOT::Window->new({ Device => $self->{device}->next,
					   %{$self->{WinOpts}} } );
  }

  $self->{win};
}

sub override
{
  my $self = shift;
  $self->{device}->override( @_ );
}

sub finish
{
  my ( $self ) = @_;
  # make sure that the plot stays up until the user is done with it
  if ( defined $self->{win} )
  {
    pgask(1) if $self->{device}->is_ephemeral;
    $self->{win}->close;
  }
}


__END__

=head1 NAME

PGPLOT::Device::PGWin - convenience class for PDL::Graphics::PGPLOT::Window

=head1 SYNOPSIS

  $pgwin = PGPLOT::Device::PGWin->new( { device => $user_device_spec,
                                         WinOpts => \%opts } );

  $pgwin->override( $override );
  $win = $pgwin->next;
  $win->env( ... );

  $pgwin->finish;


=head1 DESCRIPTION

B<PGPLOT::Device::PGWin> is a convenience class which combines
B<PGPLOT::Device> and B<PDL::Graphics::PGPLOT::Window>.  It provides
the logic to handle interactive devices (as illustrated in the
Examples section of the B<PGPLOT::Device> documentation).

Note that the B<PDL::Graphics::PGPLOT::Window::close> method should
B<never> be called when using this module, as that will surely mess
things up.


=head1 METHODS

=over

=item new

  $pgwin = PGPLOT::Device::PGWin->new( \%opts );

Create a new object.  The possible options are:

=over

=item Device

The device specification.  This is passed directly to
B<PGPLOT::Device::new>, so see it's documentation.

=item DevOpts

A hashref containing options to pass to B<PGPLOT::Device::New>.

=item WinOpts

A hashref containing options to pass to
B<PDL::Graphics::PGPLOT::Windows::new>.  Do not include a C<Device>
option as that will break things.

=back

=item device

  $dev = $pgwin->device

This method returns the underlying B<PGPLOT::Device> object.

=item next

  $win = $pgwin->next(  );
  $win = $pgwin->next( $override );

This method returns the window handle to use for constructing the next
plot.  If the optional argument is specified, it is equivalent to the
following call sequence:

  $pgwin->override( $override );
  $pgwin->next;

=item override

  $pgwin->override( ... );

This is calls the B<override> method of the associated
B<PGPLOT::Device> object.

=item finish

  $pgwin->finish();

Close the associated device.  This must be called to handle prompting
for ephemeral interactive graphic devices before a program finishes
execution.

This is B<not> automatically called upon object destruction as there
seems to be an ordering problem in destructors called during Perl's
cleanup phase such that the underlying
B<PDL::Graphics::PGPLOT::Window> object is destroyed I<before> this
object.

=back

=head1 EXAMPLES

  my $pgwin = PGPLOT::Device::PGWin->new( { Device => $user_spec } );

  eval {

    for my $plot in ( qw/ plot1 plot2 / )
    {
      $pgwin->override( $plot );
      my $win = $pgwin->next();
      $win->env( ... );
      ...
    }
  };
  my $error = $@;
  $pgwin->finish;
  die $error if $error;

=head1 SEE ALSO

PGPLOT, PGPLOT::Devices, PDL, PDL::Graphics::PGPLOT::Window.

=head1 AUTHOR

Diab Jerius, E<lt>djerius@cfa.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by the Smithsonian Astrophysical Observatory.
This software is released under the GNU General Public License.  You
may find a copy at L<http://www.fsf.org/copyleft/gpl.html>


=cut



