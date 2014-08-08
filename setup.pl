dynamic(api/2).

use_module(library(http/thread_httpd)).
use_module(library(http/http_dispatch)).
use_module(library(http/http_parameters)).

[server].

http_handler(/, process_params, []).

server(8000).
