package XML::LibXML::LazyMatcher;

use warnings;
use strict;

use XML::LibXML;

=head1 NAME

XML::LibXML::LazyMatcher - A simple XML matcher with lazy evaluation.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

use_ok ("XML::LibXML::LazyMatcher");

    my $dom = XML::LibXML->load_xml (string => "<root><c1><c2>content</c2></c1></root>");

    use XML::LibXML::LazyMatcher;
    {
        package XML::LibXML::LazyMatcher;
        my $matcher = M (root => C (M (c1 => M (c2 => sub {$_[0]->textContent eq "content"}))));
        my $valid = $matcher->($dom);
    }

=head1 EXPORT

None.

=head1 SUBROUTINES/METHODS

=head2 M (tagname => [sub_matcher, ...])

Returns a matcher function.  This returned function takes an
XML::LibXML::Node object as an argument and test the tag name.  Then,
applies the node to the all C<sub_matcher>s.  If all C<sub_matcher>s
return true value then returns 1.  Otherwise returns 0.

=cut

sub M {
    my $tagname = shift;
    my @matchers = @_;

    sub {
	my $elem = shift;

	# warn "matching $tagname", $elem->nodeName;

	return 0 unless ($elem->nodeName eq $tagname);

	# warn "eating $tagname";

	for my $m (@matchers) {
	    if (ref ($m) eq "CODE") {
		return 0 unless ($m->($elem)); # failure
	    } else {
		die "invalid matcher";
	    }
	}

	return 1;
    };
}

=head2 C (sub_matcher, ...)

Creates matcher function which tests all children.

=cut

sub C {
    my $alternate = sub {
	my @children = @_;

	sub {
	    my $elem = shift;

	    for my $m (@children) {
		return 1 if ($m->($elem));
	    }
	    return 0;
	}
    };

    my @children = @_;

    sub {
	my $parent = shift;

	my $m = $alternate->(@children);
	for (my $c = $parent->firstChild; $c; $c = $c->nextSibling) {
	    return 0 unless $m->($c);
	}

	return 1;
    }
}

=head1 AUTHOR

Toru Hisai, C<< <toru at torus.jp> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xml-libxml-lazymatcher at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-LibXML-LazyMatcher>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XML::LibXML::LazyMatcher


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XML-LibXML-LazyMatcher>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XML-LibXML-LazyMatcher>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/XML-LibXML-LazyMatcher>

=item * Search CPAN

L<http://search.cpan.org/dist/XML-LibXML-LazyMatcher/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Toru Hisai.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of XML::LibXML::LazyMatcher
