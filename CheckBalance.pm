package CheckBalance;

use strict;
use warnings;
use REST::Client;
use JSON;

sub check_balance{
    my ($account_cpf) = @_;
    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json';
    my $client_log = REST::Client->new();
    $client_log->GET($firebase_url);

    if($client_log->responseCode >= 200 && $client_log->responseCode <= 300) {
        my $query_url = "$firebase_url?orderBy=\"CPF\"&equalTo=\"$account_cpf\"";
        my $client_check = REST::Client->new();
        $client_log->GET($query_url);

        if($client_log->responseCode >= 200 && $client_log->responseCode <= 300) {
            my $response_data = decode_json($client_log->responseContent);

            if(keys %$response_data) {
                my ($account_id) = keys %$response_data;
                my $firebase_check_url = "https://oxebank-account-default-rtdb.firebaseio.com/accounts/$account_id.json";
                my $client_check = REST::Client->new();
                $client_check->GET($firebase_check_url);

                if($client_check->responseCode >= 200 && $client_check->responseCode <= 300) {
                    my $balance = decode_json($client_check->responseContent);
                    return $balance->{balance};
                }
            } else {
                return "Nenhuma conta encontrada com o CPF fornecido.";
            }
        } else {
            return "Falha ao tentar acessar a conta.";
        }
    } else {
        return "Falha ao tentar acessar o Firebase";
    }
}

1;