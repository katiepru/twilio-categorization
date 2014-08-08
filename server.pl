api(twilio, asdf).
api(twilio, foo).
api(sendgrid, bar).

api_app(Api, Out) :- api(Api, Out).
get_apps_api(Api, Out) :- findall(O, api_app(Api, O), Out).

insert_app(App, []).
insert_app(App, [H | Rest]) :- downcase_atom(H, Api), asserta(api(Api, App)), insert_app(App, Rest).

send_message(From, To, Body, Ret) :-
    string_concat('curl -X POST \'https://api.twilio.com/2010-04-01/Accounts/KEY/Messages.json\' --data-urlencode \'To=', To, A),
    string_concat(A, '\' --data-urlencode \'From=', B),
    string_concat(B, From, C),
    string_concat(C, '\' --data-urlencode \'Body=', D),
    string_concat(D, Body, E),
    string_concat(E, '\' -u KEY', F),
    shell(F, Ret).

server(Port) :- http_server(http_dispatch, [port(Port)]).

process_message(get, Text, From) :-
    downcase_atom(Text, Api),
    get_apps_api(Api, Out),
    atom_string(Api, ApiS),
    atomic_list_concat(Out, '\n', Apps),
    string_concat('Apps using ', ApiS, Head1),
    string_concat(Head1, '\n',  Head),
    string_concat(Head, Apps, Body),
    send_message('+18482072891', From, Body, _).

process_message(submit, Text, From) :-
    shell('echo "processing submit"', _),
    sub_string(Text, Before, _, After, ': '),
    sub_string(Text, 0, Before, _, Name),
    Start is Before + 2,
    sub_string(Text, Start, After, _, ApisS),
    atomic_list_concat(ApiL, ', ', ApisS),
    atom_string(App, Name),
    insert_app(App, ApiL).

process_request(From, Body) :-
    shell('echo "processing req"', _),
    atom_string(Body, BodyS),
    sub_string(BodyS, Before, _, After, '\n'),
    sub_string(BodyS, 0, Before, _, Type),
    Start is Before + 1,
    sub_string(BodyS, Start, After, _,  Text),
    downcase_atom(Type, Ftype),
    process_message(Ftype, Text, From).

process_params(Request) :- shell('echo gotreq 1>&2', _), http_parameters(Request, ['From'(From, []), 'Body'(Body, [])]), process_request(From, Body).

/* vim set filetype=prolog */
