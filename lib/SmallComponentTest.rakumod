use Cro::HTTP::Router;
use Red::Model;
unit class SmallComponentTest;

sub add-component-route(Red::Model:U $component) is export {
	my $component-name = $component.^name.lc;
	get    -> Str $ where { $_ eq $component-name }, $id {
		with $component.^load: $id {
			content 'text/html', .Str
		}
	}
	delete -> Str $ where { $_ eq $component-name }, $id {
		with $component.^load: $id {
			.^delete;
			content 'text/html', ""
		}
	}
	post   -> Str $ where { $_ eq $component-name } {
		request-body -> $values {
			my %values := $values.pairs.Map;
			with $component.^create: |%values {
				redirect "/$component-name/{ .id }", :see-other
			}
		}
	}
	get    -> Str $ where { $_ eq $component-name }, $id, Str $method where { $component.^can: $method } {
		with $component.^load: $id {
			."$method"();
		}
		redirect "/$component-name/{ $id }", :see-other
	}
}

=begin pod

=head1 NAME

SmallComponentTest - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use SmallComponentTest;

=end code

=head1 DESCRIPTION

SmallComponentTest is ...

=head1 AUTHOR

Fernando Corrêa de Oliveira <fernando.correa@humanstate.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
