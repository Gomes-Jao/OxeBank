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
    my $client_get = REST::Client->new();
    $client_get->GET($query_url);

    if ($client_get->responseCode() >= 200 && $client_get->responseCode() <= 300) {
        my $response_data = decode_json($client_get->responseContent());

        if (keys %$response_data) {
            return "Ja existe uma conta com este CPF.";
        }
    }

    my $uuid_gen = Data::UUID->new;

    $account_data->{account_number} = $uuid_gen->create_str;
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

sub debit_account {
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
                my $client_remove = REST::Client->new();
                $client_remove->GET($firebase_credit_url);

                if($client_remove->responseCode >= 200 && $client_remove->responseCode <= 300) {
                    my $balance = decode_json($client_remove->responseContent());
                    if($balance->{balance} >= $amount) {
                        $balance->{balance} -= $amount;
                        $client_remove->PUT($firebase_credit_url, encode_json($balance));
                    } else {
                        return "Nao foi possivel retirar a quantia pois a conta nao possui saldo suficiente.";
                    }
                    
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