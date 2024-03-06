# Módulo para criar uma conta bancária no Firebase
package OxeBankAccountCreator;

use strict;
use warnings;
use REST::Client;
use JSON;
use Data::UUID;


sub create_account {
    my ($account_data) = @_;

    unless (ref $account_data eq 'HASH') {
        return "Dados de conta inválidos.";
    }

    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json'; # URL do seu banco de dados Firebase

    # Construir a URL para a consulta filtrada pelo CPF fornecido
    my $query_url = "$firebase_url?orderBy=\"CPF\"&equalTo=\"" . $account_data->{CPF} . "\"";
    print $query_url . "\n";
    my $client_get = REST::Client->new();
    $client_get->GET($query_url);

    print $client_get->responseCode() . "\n";

    if ($client_get->responseCode() >= 200 && $client_get->responseCode() <= 300) {
        my $response_data = decode_json($client_get->responseContent());

        if (keys %$response_data) {
            return "Já existe uma conta com este CPF.";
        }
    }

    my $uuid_gen = Data::UUID->new;

    $account_data->{account_number} = $uuid_gen->create_str;
    $account_data->{balance} = 0;
    $account_data->{type} = 'CC';
    
    my $client_put = REST::Client->new;
    $client_put->POST($firebase_url, encode_json($account_data), {'Content-Type' => 'application/json'});

    if ($client_put->responseCode() >= 200 && $client_put->responseCode() <= 300) {
        my $response_data = decode_json($client_put->responseContent());
        print $response_data->{$account_data->{CPF}};
        return "Conta criada com sucesso.";
    } else {
        return "Falha ao criar conta.";
    }
}


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
            
            return $client_delete->responseCode() == 200;

        } else {
            return 0;# Nenhuma conta encontrada com o número fornecido
        }
    } else {
        return 0; # Falha ao acessar o Firebase
    }
}

sub credit_account {
    my ($account_number, $amount) = @_;

    #URL do Firebase para buscar o ID da conta pelo número da conta
    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json';

    #Construir a URL para a consulta filtrada pelo número da conta
    my $query_url = "$firebase_url?orderBy=\"account_number\"&equalTo=\"$account_number\"";

    #Fazer uma solicitação GET para obter os dados da conta
    my $client_get = REST::Client->new();
    $client_get->GET($firebase_url);

    #Verificar se a solicitação foi bem-sucedida
    if($client_get->responseCode() == 200) {
        my $response_data = decode_json($client_get->responseContent());

        if(keys %$response_data) {
            my ($account_id) = keys %$response_data;

            my $firebase_credit_url = "https://oxebank-account-default-rtdb.firebaseio.com/accounts/$account_id.json";

            my $current_balance = $response_data->{balance};

            my $new_balance = $current_balance + $amount;

            my $client_put = REST::Client->new();
            $client_put->PUT($firebase_credit_url, encode_json({balance => $new_balance}));

            if($client_put->responseCode() == 200) {
                return 1;
            } else {
                return 0;
            }
        } else {
            return 0; #Nenhuma conta encontrada com o número fornecido
        }

        
    } else {
        return 0; #Falha ao acessar o Firebase
    }
}

sub debito {

}

1;