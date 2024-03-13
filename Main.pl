use lib './';  # Importa o módulo
use OxeBankAccountCreator;

use Data::UUID;

my $uuid_gen = Data::UUID->new;
my $account_id = $uuid_gen->create_str;

my $account_data = {
    #id => $account_id,  # Atribuir o UUID como ID da conta
    CPF => '12644684484',
    #account_number => '123456789',
    #balance => 1000,
    owner => 'João Silva',
};
my $account_number = "123";
my $account_cpf = "12643684484";#$account_data->{CPF};

#print($account_cpf);

#create($account_data);
#credit($account_cpf, 1230.27);
#debit($account_cpf, 1230);
#delete_account($account_cpf);
#check($account_cpf);

sub create {
    my($account_data) = @_;
    OxeBankAccountCreator::create_account($account_data);
}

sub delete_account {
    my ($account_cpf) = @_;
    OxeBankAccountCreator::delete_account($account_cpf);
}

sub credit {
    my($account_cpf, $amount) = @_;
    OxeBankAccountCreator::credit_account($account_cpf, $amount);
}

sub debit {
    my($account_cpf, $amount) = @_;
    OxeBankAccountCreator::debit_account($account_cpf, $amount);
}

sub check {
    my($account_cpf) = @_;
    print OxeBankAccountCreator::check_balance($account_cpf);
}