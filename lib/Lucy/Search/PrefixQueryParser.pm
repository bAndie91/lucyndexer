package Lucy::Search::PrefixQueryParser;
use base qw( Lucy::Search::QueryParser );
use Lucy::Search::PrefixQuery;

sub expand_leaf {
	my ( $self, $leaf_query ) = @_;
	my $text = $leaf_query->get_text;

	if ( $text =~ /\*$/ ) {
		my $field = $leaf_query->get_field;
		if($field)
		{
			return Lucy::Search::PrefixQuery->new(
				field		=> $field,
				query_string => $text,
			);
		}
		else
		{
			my $or_query = Lucy::Search::ORQuery->new;
			for my $field ( @{ $self->get_fields } ) {
				my $prefix_query = Lucy::Search::PrefixQuery->new(
					field		=> $field,
					query_string => $text,
				);
				$or_query->add_child($prefix_query);
			}
			return $or_query;
		}
	}
	else {
		return $self->SUPER::expand_leaf($leaf_query);
	}
}

1;
