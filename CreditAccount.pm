package CreditAccount;

use strict;
use warnings;
use REST::Client;
use JSON;

sub credit_account {
    my ($account_cpf, $amount) = @_;
    #URL do Firebase para buscar o ID da conta pelo número da conta
    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json';
    my $client_log = REST::Client->new();
    $client_log->GET($firebase_url);

    if($client_log->responseCode >= 200 && $client_log->responseCode <= 300) {
        my $query_url = "$firebase_url?orderBy=\"CPF\"&equalTo=\"$account_cpf\"";
        #Fazer uma solicitação GET para obter os dados da conta
        my $client_get = REST::Client->new();
        $client_get->GET($query_url);

        #Verificar se a solicitação foi bem-sucedida
        if($client_get->responseCode >= 200 && $client_get->responseCode <= 300) {
            my $response_data = decode_json($client_get->responseContent());

            if(keys %$response_data) {
                if($amount < 0) {
                    return "O valor deve ser positivo.";
                }
                
                my ($account_id) = keys %$response_data;
                my $firebase_credit_url = "https://oxebank-account-default-rtdb.firebaseio.com/accounts/$account_id.json";
                my $client_put = REST::Client->new();
                $client_put->GET($firebase_credit_url);

                if($client_put->responseCode >= 200 && $client_put->responseCode <= 300) {
                    my $balance = decode_json($client_put->responseContent());
                    $balance->{balance} += $amount;
                    $client_put->PUT($firebase_credit_url, encode_json($balance));
                } else {
                    return "Falha ao acessar os dados.";
                }
            } else {
                return "Nenhuma conta encontrada com o CPF fornecido.";
            }
        } else {
            return "Falha ao tentar acessar a conta.";
        }
    } else {
        return "Falha ao tentar acessar o Firebase.";
    }

}

1;