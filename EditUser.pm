package EditUser;

use strict;
use warnings;
use REST::Client;
use JSON;

sub edit_user {
    my ($account_cpf, $field, $value) = @_;

    my @inalteraveis = ("CPF", "balance", "type");
    my %hash_inalteraveis = map {$_ => 1} @inalteraveis;

    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json';
    my $client_log = REST::Client->new();
    $client_log->GET($firebase_url);

    if($client_log->responseCode >= 200 && $client_log->responseCode <= 300) {
        my $query_url = "$firebase_url?orderBy=\"CPF\"&equalTo=\"$account_cpf\"";
        #fazer uma solicitação GET para receber os dados da conta
        my $client_get = REST::Client->new();
        $client_get->GET($query_url);

        if($client_get->responseCode >= 200 && $client_get->responseCode <= 300) {
            my $response_data = decode_json($client_get->responseContent());

            if(keys %$response_data) {

                if(exists $hash_inalteraveis{$field}) {
                    return "Impossivel alterar este campo.";
                }

                my ($account_id) = keys %$response_data;
                my $account_url = "https://oxebank-account-default-rtdb.firebaseio.com/accounts/$account_id.json";
                my $client_put = REST::Client->new();
                $client_put->GET($account_url);

                if($client_put->responseCode >= 200 && $client_put->responseCode <= 300) {
                    my $account_fields = decode_json($client_put->responseContent());
                    $account_fields->{$field} = $value;
                    $client_put->PUT($account_url, encode_json($account_fields));
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
        return "Falha ao tentar acessar o Firebase";
    }
}

1;