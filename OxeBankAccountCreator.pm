# Módulo para criar uma conta bancária no Firebase
package OxeBankAccountCreator;

use strict;
use warnings;
use REST::Client;
use JSON;

sub create_account {
    my ($account_data) = @_;

    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json'; # URL do seu banco de dados Firebase

    my $client = REST::Client->new();
    $client->POST($firebase_url, encode_json($account_data), {'Content-Type' => 'application/json'});

    if ($client->responseCode() == 200) {
        return 1; # Sucesso
    } else {
        return 0; # Falha
    }
}

1;

use strict;
use warnings;
use REST::Client;

sub delete_account {
    my ($numero_conta) = @_;

    my $firebase_url = 'https://oxebank-account-default-rtdb.firebaseio.com/accounts.json'; # URL do seu banco de dados Firebase

    my $client = REST::Client->new();
    $client->GET($firebase_url);

    if ($client->responseCode() == 200) {
        my $response_data = decode_json($client->responseContent());
        foreach my $account_id (keys %$response_data) {
            my $account_data = $response_data->{$account_id};
            if ($account_data->{'account_number'} eq $numero_conta) {
                $firebase_url = "https://oxebank-account-default-rtdb.firebaseio.com/accounts/$account_id.json"; # Substitua pelo URL do seu banco de dados Firebase

                my $client = REST::Client->new();
                $client->DELETE($firebase_url);

                if ($client->responseCode() == 200) {
                    return 1; # Sucesso
                } else {
                    return 0; # Falha
                }
            }
        }
    }
}

1;
