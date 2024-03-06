use lib './';  # Importa o módulo
use OxeBankAccountCreator;

use Data::UUID;

my $uuid_gen = Data::UUID->new;
my $account_id = $uuid_gen->create_str;

my $account_data = {
    #id => $account_id,  # Atribuir o UUID como ID da conta
    CPF => '12345678',
    #account_number => '123456789',
    #balance => 1000,
    owner => 'João Silva',
};
my $account_number = "123456789";

create($account_data);
#delete($account_number);

sub create {
    my($account_data) = @_;
    OxeBankAccountCreator::create_account($account_data);
}

=begin
sub delete {
    my($account_number) = @_;
    if (OxeBankAccountCreator::delete_account($account_number)) {
        print "Conta deletada com sucesso!\n";
    } else {
        print "Falha ao deletar a conta!\n";
    }
}
=cut