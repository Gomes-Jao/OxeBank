package CreateAccount;

use strict;
use warnings;
use REST::Client;
use JSON;

sub create_account {
    my ($account_data) = @_;

    unless (ref $account_data eq 'HASH') {
        return "Dados de conta inválidos.";
    }

    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json'; # URL do seu banco de dados Firebase

    # Construir a URL para a consulta filtrada pelo CPF fornecido
    my $query_url = "$firebase_url?orderBy=\"CPF\"&equalTo=\"" . $account_data->{CPF} . "\"";
    my $client_get = REST::Client->new();
    $client_get->GET($query_url);

    if ($client_get->responseCode() >= 200 && $client_get->responseCode() <= 300) {
        my $response_data = decode_json($client_get->responseContent());

        if (keys %$response_data) {
            return "Ja existe uma conta com este CPF.";
        }
    }
    #my $uuid_gen = Data::UUID->new;
    #$account_data->{account_number} = $uuid_gen->create_str;
    $account_data->{balance} = 0;
    $account_data->{type} = 'CC';
    
    my $client_put = REST::Client->new;
    $client_put->POST($firebase_url, encode_json($account_data), {'Content-Type' => 'application/json'});

    if ($client_put->responseCode() >= 200 && $client_put->responseCode() <= 300) {
        return "Conta criada com sucesso.";
    } else {
        return "Falha ao criar conta.";
    }
}

1;