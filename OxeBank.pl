use LWP::UserAgent;
use JSON;

# Função para verificar se o CPF já está em uso
sub check_cpf_unique {
    my ($cpf) = @_;

    my $ua = LWP::UserAgent->new;
    my $url = "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyBocj6xExspwLluuqwOrCWt0912X7M_kPs";
=begin
    my $data = {
        email => $cpf . '@hotmail.com',  # Usando o CPF como email para verificar
    };
=cut
    my $req = HTTP::Request->new(POST => $url);
    $req->header('Content-Type' => 'application/json');
    $req->content(encode_json($cpf));

    my $res = $ua->request($req);

    if ($res->is_success) {
        my $response = decode_json($res->content);
        return scalar(@{$response->{'users'}}) == 0;  # Retorna verdadeiro se nenhum usuário for encontrado
    } else {
        print "Failed to check CPF uniqueness: " . $res->status_line . "\n";
        return 0;
    }
}

# Função para criar uma nova conta
sub create_account {
    my ($account_data) = @_;

    my $ua = LWP::UserAgent->new;
    my $url = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBocj6xExspwLluuqwOrCWt0912X7M_kPs';

    $account_data->{returnSecureToken} = 'true';

    my $req = HTTP::Request->new(POST => $url);
    $req->header('Content-Type' => 'application/json');
    $req->content(encode_json($account_data));

    my $res = $ua->request($req);

    if ($res->is_success) {
        print "User created successfully.\n";
    } else {
        print "Failed to create user: " . $res->status_line . "\n";
    }
}

# Dados da conta
my $account_data = {
    CPF => '12345678900',
    email => 'victorgomessmc@hotmail.com',
    password => 'joaogomes',
    displayName => 'John Doe'
};

# Verificar se o CPF é único antes de criar a conta
if (check_cpf_unique($account_data->{'CPF'})) {
    create_account($account_data);
} else {
    print "CPF already exists.\n";
}
