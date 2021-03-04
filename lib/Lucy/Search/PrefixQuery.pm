package Lucy::Search::PrefixQuery;
use base qw( Lucy::Search::Query );
use Carp;
use Scalar::Util qw( blessed );
use Lucy::Search::PrefixCompiler;

# Inside-out member vars and hand-rolled accessors.
my %query_string;
my %field;
sub get_query_string { my $self = shift; return $query_string{$$self} }
sub get_field        { my $self = shift; return $field{$$self} }

sub new {
    my ( $class, %args ) = @_;
    my $query_string = delete $args{query_string};
    my $field        = delete $args{field};
    my $self         = $class->SUPER::new(%args);
    confess("'query_string' param is required")
        unless defined $query_string;
    confess("Invalid query_string: '$query_string'")
        unless $query_string =~ /\*\s*$/;
    confess("'field' param is required")
        unless defined $field;
    $query_string{$$self} = $query_string;
    $field{$$self}        = $field;
#    $self = bless($self, $class);
#    $self->{term} = $query_string;
#    $self->{field} = $field;
    return $self;
}

sub DESTROY {
    my $self = shift;
    delete $query_string{$$self};
    delete $field{$$self};
    $self->SUPER::DESTROY;
}

sub equals {
    my ( $self, $other ) = @_;
    return 0 unless blessed($other);
    return 0 unless $other->isa("Lucy::Search::PrefixQuery");
    return 0 unless $field{$$self} eq $field{$$other};
    return 0 unless $query_string{$$self} eq $query_string{$$other};
#    return 0 unless $self->{field} eq $other->{field};
#    return 0 unless $self->{query_string} eq $other->{query_string};
    return 1;
}

sub make_compiler {
    my ( $self, %args ) = @_;
    my $subordinate = delete $args{subordinate};
    my $compiler = Lucy::Search::PrefixCompiler->new( %args, parent => $self );
    $compiler->normalize unless $subordinate;
    return $compiler;
}

sub dump {
    my ( $self, %args ) = @_;
    my $dump = $self->SUPER::dump(%args);
    $dump->{term} = $query_string{$$self};
    $dump->{field} = $field{$$self};
    return $dump;
}

1;
