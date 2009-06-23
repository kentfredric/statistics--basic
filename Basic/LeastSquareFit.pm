
package Statistics::Basic::LeastSquareFit;

use strict;
use warnings;
use Carp;

use base 'Statistics::Basic::_TwoVectorBase';

use overload
    '""' => sub {
        my ($alpha,$beta) = map{$Statistics::Basic::fmt->format_number($_, $ENV{IPRES})} $_[0]->query;
        "LSF( alpha: $alpha, beta: $beta )";
    },
    '0+' => sub { croak "the result of LSF may not be used as a number" },
    fallback => 1; # tries to do what it would have done if this wasn't present.

1;

# new {{{
sub new {
    my $this = shift;
    my $v1   = eval { Statistics::Basic::Vector->new( shift ) }; croak $@ if $@;
    my $v2   = eval { Statistics::Basic::Vector->new( shift ) }; croak $@ if $@;

    $this = bless {}, $this;

    my $c = $v1->get_linked_computer( LSF => $v2 );
    return $c if $c;

    $this->{_vectors} = [ $v1, $v2 ];

    $this->{vrx} = eval { Statistics::Basic::Variance->new($v1)        }; croak $@ if $@;
    $this->{vry} = eval { Statistics::Basic::Variance->new($v2)        }; croak $@ if $@;
    $this->{mnx} = eval { Statistics::Basic::Mean->new($v1)            }; croak $@ if $@;
    $this->{mny} = eval { Statistics::Basic::Mean->new($v2)            }; croak $@ if $@;
    $this->{cov} = eval { Statistics::Basic::Covariance->new($v1, $v2) }; croak $@ if $@;

    $v1->set_linked_computer( LSF => $this, $v2 );
    $v2->set_linked_computer( LSF => $this, $v1 );

    return $this;
}
# }}}
# _recalc {{{
sub _recalc {
    my $this  = shift;

    delete $this->{recalc_needed};
    delete $this->{alpha};
    delete $this->{beta};

    unless( $this->{vrx}->query ) {
        unless( defined $this->{vrx}->query ) {
            warn "[recalc " . ref($this) . "] undef variance...\n" if $ENV{DEBUG};

        } else {
            warn "[recalc " . ref($this) . "] narrowly avoided division by zero.  Something is probably wrong.\n" if $ENV{DEBUG};
        }

        return;
    }

    $this->{beta}  = ($this->{cov}->query / $this->{vrx}->query);
    $this->{alpha} = ($this->{mny}->query - ($this->{beta} * $this->{mnx}->query));

    warn "[recalc " . ref($this) . "] (alpha: $this->{alpha}, beta: $this->{beta})\n" if $ENV{DEBUG};
}
# }}}
# query {{{
sub query {
    my $this = shift;

    $this->_recalc if $this->{recalc_needed};

    warn "[query " . ref($this) . " ($this->{alpha}, $this->{beta})]\n" if $ENV{DEBUG};

    return (wantarray ? ($this->{alpha}, $this->{beta}) : [$this->{alpha}, $this->{beta}] );
}
# }}}

# query_vector1 {{{
sub query_vector1 {
    my $this = shift;

    return $this->{cov}->query_vector1;
}
# }}}
# query_vector2 {{{
sub query_vector2 {
    my $this = shift;

    return $this->{cov}->query_vector2;
}
# }}}
# query_mean1 {{{
sub query_mean1 {
    my $this = shift;

    return $this->{mnx};
}
# }}}
# query_mean2 {{{
sub query_mean2 {
    my $this = shift;

    return $this->{mny};
}
# }}}
# query_variance1 {{{
sub query_variance1 {
    my $this = shift;

    return $this->{vrx};
}
# }}}
# query_variance2 {{{
sub query_variance2 {
    my $this = shift;

    return $this->{vry};
}
# }}}
# query_covariance {{{
sub query_covariance {
    my $this = shift;

    return $this->{cov};
}
# }}}

# y_given_x {{{
sub y_given_x {
    my $this = shift;
    my ($alpha, $beta) = $this->query;
    my $x = shift;

    return ($beta*$x + $alpha);
}
# }}}
# x_given_y {{{
sub x_given_y {
    my $this = shift;
    my ($alpha, $beta) = $this->query;
    my $y = shift;

    my $x = eval { ( ($y-$alpha)/$beta ) }; croak $@ if $@;
    return $x;
}
# }}}
