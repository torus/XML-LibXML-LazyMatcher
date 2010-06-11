#-*- perl -*-

use strict;
use warnings;
use Test::More tests => 8;

use XML::LibXML;

use_ok ("XML::LibXML::LazyMatcher");

{
    my $matcher;
    {
	my $dom = XML::LibXML->load_xml (string => "<root><c1><c2>content</c2></c1></root>");
	ok ($dom, "dom");

	{
	    package XML::LibXML::LazyMatcher;
	    $matcher = M (root =>
			  C (M (c1 =>
				C (M (c2 =>
				      sub {
					  $_[0]->textContent eq "content";
				      })))));
	}
	ok ($matcher->($dom->documentElement), "matcher");
    }

    {
	my $dom = XML::LibXML->load_xml (string => "<root><c1><c3>content</c3></c1></root>");
	ok (! $matcher->($dom->documentElement), "failure");
    }

    {
	my $dom = XML::LibXML->load_xml (string => "<root><c1><c3>different content</c3></c1></root>");
	ok (! $matcher->($dom->documentElement), "failure");
    }
}

{
    my $dom = XML::LibXML->load_xml (string => "<root><c1><c2>hello</c2><c3>world</c3></c1></root>");
    my $matcher;
    my ($c2content, $c3content);
    {
	package XML::LibXML::LazyMatcher;
	$matcher = M (root =>
		      C (M (c1 =>
			    C (M (c2 =>
				  sub {
				      $c2content = $_[0]->textContent;
				      return 1;
				  }),
			       M (c3 =>
				  sub {
				      $c3content = $_[0]->textContent;
				      return 1;
				  })))));
    }
    ok ($matcher->($dom->documentElement), "children");
    ok ($c2content eq "hello", "content");
    ok ($c3content eq "world", "content");
}
