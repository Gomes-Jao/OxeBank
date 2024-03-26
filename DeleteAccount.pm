package DeleteAccount;

use strict;
use warnings;
use REST::Client;
use JSON;

sub delete_account {
    my ($account_cpf) = @_;

    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json'; # URL do seu banco de dados Firebase

    # Construir a URL para a consulta filtrada pelo cpf fornecido
    my $query_url = "$firebase_url?orderBy=\"CPF\"&equalTo=\"$account_cpf\"";
    
    my $client = REST::Client->new();
    $client->GET($query_url);

    if ($client->responseCode() >= 200 && $client->responseCode() <= 300) {
        my $response_data = decode_json($client->responseContent());

        # Verificar se há dados retornados
        if (keys %$response_data) {
            # Pegar o ID da primeira (e única) conta encontrada
            my ($account_id) = keys %$response_data;

            # Construir a URL para excluir a conta
            my $firebase_delete_url = "https://oxebank-account-default-rtdb.firebaseio.com/accounts/$account_id.json"; # URL para excluir a conta
            my $client_delete = REST::Client->new();
            
            $client_delete->DELETE($firebase_delete_url);
            
            if($client_delete->responseCode == 200) {
                return "Conta deletada com sucesso!\n";
            } else {
                return "Nao foi possivel deletar a conta\n";
            }

        } else {
            return "Nenhuma conta foi encontrada com o CPF: $account_cpf\n";
        }
    } else {
        return "Falha ao acessar o Firebase";
    }
}

1;