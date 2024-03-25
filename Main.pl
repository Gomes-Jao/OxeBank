use lib './';
use CreditAccount;
use DebitAccount;
use DeleteAccount;
use CreateAccount;
use CheckBalance;
use EditUser;
use JSON;
use utf8;
use Encode;

my $uuid_gen = Data::UUID->new;
my $account_id = $uuid_gen->create_str;


my $account_data = {
    CPF => '12644684484',
    owner => 'João Silva',
    email => 'victorgomessmc@hotmail.com',
    senha => 'senhateste1'
};


my $account_cpf = "12644684484";#$account_data->{CPF};
my $amount = 741;

#CreateAccount::create_account($account_data);
#DeleteAccount::delete_account($account_cpf);
#CreditAccount::credit_account($account_cpf, $amount);
#DebitAccount::debit_account($account_cpf, $amount);
#CheckBalance::check_balance($account_cpf);
print EditUser::edit_user($account_cpf, "type", "Sumario");