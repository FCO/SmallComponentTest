#!/usr/bin/env raku

use lib "lib";
use Red;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use SmallComponentTest;

model Todo {
	has UInt $.id                         is serial;
	has Bool $.done  handles <Bool> is rw is column = False;
	has Str  $.value                      is column;

	method toggle {
		$!done = $.not;
		$.^save
	}

	method Str {
		qq:to/END/;
			<tr>
				<td>
					<input
						type="checkbox"
						{"checked" if $!done}
						hx-get="/todo/$!id/toggle"
						hx-target="closest tr"
						hx-swap="outerHTML"
					>
				</td>
				<td>
					{
						$!done
						?? "<del>{ $!value }</del>"
						!! $!value
					}
				</td>
				<td>
					<button
						hx-delete="/todo/$!id"
						hx-confirm="Are you sure?"
						hx-target="closest tr"
						hx-swap="delete"
					>
						-
					</button>
				</td>
			</tr>
		END
	}
}

class TodoList {
	method Str {
		qq:to/END/;
			<table>
				{ Todo.^all.join: "\n" }
			</table>
			<form
				hx-post="/todo"
				hx-target="table"
				hx-swap="beforeend"
				hx-on::after-request="this.reset()"
			>
				<input name="value">
				<button type=submit>+</button>
			</form>
		END
	}
}

my $routes = route {
	red-defaults "SQLite";
	Todo.^create-table;
	get  -> {
		content 'text/html', qq:to/END/;
		<html>
			<head>
				<script src="https://unpkg.com/htmx.org@2.0.3" integrity="sha384-0895/pl2MU10Hqc6jd4RvrthNlDiE9U1tWmX7WRESftEDRosgxNsQG/Ze9YMRzHq" crossorigin="anonymous"></script>
			</head>
			<body>
				{ TodoList.Str }
			</body>
		</html>
		END
	}
	add-component-route(Todo)
}
my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => "0.0.0.0",
    port => 3000,
    application => $routes,
);
$http.start;
say "Listening at http://0.0.0.0:3000";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
