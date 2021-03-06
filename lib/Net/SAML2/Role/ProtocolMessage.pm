package Net::SAML2::Role::ProtocolMessage;
use Moose::Role;
use MooseX::Types::Moose qw/ Str /;
use MooseX::Types::URI qw/ Uri /;
use DateTime::Format::XSD;
use Crypt::OpenSSL::Random;
use XML::Generator;

=head1 NAME

Net::SAML2::Role::ProtocolMessage - common behaviour for Protocol messages

=head1 DESCRIPTION

Provides default ID and timestamp arguments for Protocol classes.

Provides a status-URI lookup method for the statuses used by this
implementation.

=cut

has 'id'            => (isa => Str, is => 'ro', required => 1);
has 'issue_instant' => (isa => Str, is => 'ro', required => 1);
has 'issuer'        => (isa => Uri, is => 'rw', required => 1, coerce => 1);
has 'issuer_namequalifier' => (isa => Str, is => 'rw', required => 0);
has 'issuer_format' => (isa => Str, is => 'rw', required => 0);
has 'destination'   => (isa => Uri, is => 'rw', required => 0, coerce => 1);

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $class = shift;      
    my %args = @_;

    # random ID for this message
    $args{id} ||= unpack 'H*', Crypt::OpenSSL::Random::random_pseudo_bytes(16);

    # IssueInstant in UTC
    my $dt = DateTime->now( time_zone => 'UTC' );
    $args{issue_instant} ||= $dt->strftime('%FT%TZ');
        
    return \%args;
};

=head1 CONSTRUCTOR ARGUMENTS

=item B<issuer>

URI of issuer

=item B<issuer_namequalifier>

NameQualifier attribute for Issuer

=item B<issuer_format>

Format attribute for Issuer

=item B<destination>

URI of Destination

=head1 METHODS

=head2 status_uri( $status )

Provides a mapping from short names for statuses to the full status URIs.

Legal short names for B<$status> are:

=over

=item C<success>

=item C<requester>

=item C<responder>

=back

=cut

sub status_uri {
    my ($self, $status) = @_;

    my $statuses = {
        success   => 'urn:oasis:names:tc:SAML:2.0:status:Success',
        requester => 'urn:oasis:names:tc:SAML:2.0:status:Requester',
        responder => 'urn:oasis:names:tc:SAML:2.0:status:Responder',
        partial   => 'urn:oasis:names:tc:SAML:2.0:status:PartialLogout',
    };

    if (exists $statuses->{$status}) {
        return $statuses->{$status};
    }

    return;
}

1;
