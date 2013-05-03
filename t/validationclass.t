=pod

=encoding utf-8

=head1 PURPOSE

Check type constraints L<Validation::Class::Simple> objects can be used
as type constraints.

=head1 DEPENDENCIES

Test is skipped if Validation::Class 7.900000 is not available.

=head1 CAVEATS

As of Perl 5.17.x, the Object::Accessor module is being de-cored, so will
issue deprecation warnings. These can safely be ignored for the purposes
of this test case. Object::Accessor from CPAN does not have these warnings.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use lib qw( ./lib ./t/lib ../inc ./inc );

use Test::More;
use Test::Requires { "Validation::Class" => "7.900000" };
use Test::TypeTiny;

use Types::TypeTiny qw( to_TypeTiny );
use Validation::Class::Simple;

my $type = to_TypeTiny "Validation::Class::Simple"->new(
	fields => {
		name  => { required => 1, pattern => qr{^\w+(\s\w+)*$}, filters => [qw/trim/] },
		email => { required => 1 },
		pass  => { required => 1 },
		pass2 => { required => 1, matches => 'pass' },
	},
);

isa_ok($type, "Type::Tiny", 'can create a child type constraint from Validation::Class::Simple');

should_fail('Hello', $type);
should_fail({}, $type);
should_fail({ name => 'Toby', email => 'tobyink@cpan.org', pass => 'foo', pass2 => 'bar' }, $type);
should_pass({ name => 'Toby', email => 'tobyink@cpan.org', pass => 'foo', pass2 => 'foo' }, $type);
should_fail({ name => 'Toby ', email => 'tobyink@cpan.org', pass => 'foo', pass2 => 'foo' }, $type);

my $msg = $type->get_message({ name => 'Toby', email => 'tobyink@cpan.org', pass => 'foo', pass2 => 'bar' });
like($msg, qr{pass2 does not match pass}, 'correct error message (A)');

my $msg2 = $type->get_message({ name => 'Toby ', email => 'tobyink@cpan.org', pass => 'foo', pass2 => 'foo' });
like($msg2, qr{name is not formatted properly}, 'correct error message (B)');

ok($type->has_coercion, 'the type has a coercion');

is_deeply(
	$type->coerce(
		{ name => 'Toby ', email => 'tobyink@cpan.org', pass => 'foo', pass2 => 'foo', monkey => 'nuts' },
	),
	{ name => 'Toby', email => 'tobyink@cpan.org', pass => 'foo', pass2 => 'foo' },
	"... which works",
);

done_testing;
