package Lucy::Search::PrefixMatcher;
use base qw( Lucy::Search::Matcher );

# Inside-out member vars.
my %doc_ids;
my %tick;

sub new {
    my ( $class, %args ) = @_;
    my $posting_lists = delete $args{posting_lists};
    my $self          = $class->SUPER::new(%args);

    # Cheesy but simple way of interleaving PostingList doc sets.
    my %all_doc_ids;
    for my $posting_list (@$posting_lists) {
        while ( my $doc_id = $posting_list->next ) {
            $all_doc_ids{$doc_id} = undef;
        }
    }
    my @doc_ids = sort { $a <=> $b } keys %all_doc_ids;
    $doc_ids{$$self} = \@doc_ids;

    # Track our position within the array of doc ids.
    $tick{$$self} = -1;

    return $self;
}

sub DESTROY {
    my $self = shift;
    delete $doc_ids{$$self};
    delete $tick{$$self};
    $self->SUPER::DESTROY;
}

sub next {
    my $self    = shift;
    my $doc_ids = $doc_ids{$$self};
    my $tick    = ++$tick{$$self};
    return 0 if $tick >= scalar @$doc_ids;
    return $doc_ids->[$tick];
}

sub get_doc_id {
    my $self    = shift;
    my $tick    = $tick{$$self};
    my $doc_ids = $doc_ids{$$self};
    return $tick < scalar @$doc_ids ? $doc_ids->[$tick] : 0;
}

sub score { 1.0 }

1;
