package Lucy::Search::PrefixCompiler;
use base qw( Lucy::Search::Compiler );
use Lucy::Search::PrefixMatcher;

sub make_matcher {
    my ( $self, %args ) = @_;
    my $seg_reader = $args{reader};

    # Retrieve low-level components LexiconReader and PostingListReader.
    my $lex_reader = $seg_reader->obtain("Lucy::Index::LexiconReader");
    my $plist_reader = $seg_reader->obtain("Lucy::Index::PostingListReader");

    # Acquire a Lexicon and seek it to our query string.
    my $substring = $self->get_parent->get_query_string;
    $substring =~ s/\*$//;
    my $field = $self->get_parent->get_field;
    my $lexicon = $lex_reader->lexicon( field => $field );
    return unless $lexicon;
    $lexicon->seek($substring);

    # Accumulate PostingLists for each matching term.
    my @posting_lists;
    while ( defined( my $term = $lexicon->get_term ) ) {
        last unless $term =~ /^\Q$substring/;
        my $posting_list = $plist_reader->posting_list(
            field => $field,
            term  => $term,
        );
        if ($posting_list) {
            push @posting_lists, $posting_list;
        }
        last unless $lexicon->next;
    }
    return unless @posting_lists;

    return Lucy::Search::PrefixMatcher->new( posting_lists => \@posting_lists );
}

1;
