use lib './';  # Importa o módulo
use OxeBankAccountCreator;

use Data::UUID;

my $uuid_gen = Data::UUID->new;
my $account_id = $uuid_gen->create_str;

my $account_data = {
    id => $account_id,  # Atribuir o UUID como ID da conta
    account_number => '123456789',
    balance => 1000,
    owner => 'João Silva',
};

#if (OxeBankAccountCreator::create_account($account_data)) {
#    print "Conta bancária criada com sucesso!\n";
#} else {
#    print "Falha ao criar a conta bancária!\n";
#}

my $numero_conta = "123456789";

if (OxeBankAccountCreator::delete_account($numero_conta)) {
    print "Conta deletada com sucesso!\n";
} else {
    print "Falha ao deletar a conta!\n";
}