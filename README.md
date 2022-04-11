# SimplifiedBankingApi
## O que vou encontrar neste projeto?

Aqui você encontrará uma API para bancos, onde é possível:
 1. Criar novas contas bancárias
 2. Realizar transferência
 3. Realizar saque
 4. Realizar depósito
 5. Endpoint para apagar as informações do banco de dados (para fins de teste)

## Documentações
### Documentação da API

#### Apagar informações do banco de dados (para fins de teste)
- **endpoint**: POST /reset
- **Retorno**: 200 OK

#### Cria uma conta bancária
Para criar uma conta bancária, é necessário que o valor de `destination` não esteja em uso por nenhuma outra conta.

##### Cria uma conta bancária com saldo inicial
- **endpoint**: POST /event {"type":"deposit", "destination":"100", "amount":10}
- **Retorno**: 201 {"destination": {"id":"100", "balance":10}}

##### Cria uma conta bancária sem saldo inicial
- **endpoint**: POST /event {"type":"deposit", "destination":"107"}
- **Retorno**: 201 {"destination": {"id":"107", "balance":0}}

#### Faz um depósito em uma conta existente
- **endpoint**: POST /event {"type":"deposit", "destination":"100", "amount":10}
- **Retorno**: 201 {"destination": {"id":"100", "balance":20}}

#### Busca o saldo de uma conta inexistente
- **endpoint**: GET /balance?account_id=1234
- **Retorno**: 404 0

#### Busca o saldo de uma conta existente
- **endpoint**: GET /balance?account_id=100
- **Retorno**: 200 20

#### Saque de uma conta inexistente
- **endpoint**: POST /event {"type":"withdraw", "origin":"200", "amount":10}
- **Retorno**: 404 0

#### Saque de uma conta existente
- **endpoint**: POST /event {"type":"withdraw", "origin":"100", "amount":5}
- **Retorno**: 201 {"origin": {"id":"100", "balance":15}}

#### Transferência a partir de conta de origem existente
Não é permitido transferir a partir de `origin.id` inexistentes, porém, se o campo `destination.id` for inexistemte, a transferência será executada com sucesso e uma nova conta com o valor de `destination.id` será criada.
- **endpoint**: POST /event {"type":"transfer", "origin":"100", "amount":15, "destination":"300"}
- **Retorno**: 201 {"origin": {"id":"100", "balance":0}, "destination": {"id":"300", "balance":15}}

#### Transferência a partir de conta de origem inexistente
- **endpoint**: POST /event {"type":"transfer", "origin":"200", "amount":15, "destination":"300"}
- **Retorno**: 404 0

### Documentação do código (Documentação dos módulos e funções)

Por ora, ainda não subi a documentação do código em um endereço público. 
Mas enquanto isso, você pode encontrá-la seguindo os seguintes passos
 1. Siga a documentação de setup para fazer o download, intalar o Elixir e Phoenix na sua máquina
 2. Abra o terminal e acesse o diretório do projeto
 3. Rode o comando `mix deps.get`
 4. Rode o comando `mix docs`
 5. Agora a documentação foi criada em formato HTML e está no diretório /simplified-banking-api/doc

### Documentação de setup

Siga os passos a seguir para executar a aplicação localmente:
 1. Instale a versão `1.13.2` do Elixir e a versão `24.0` do Erlang. [`Leia a documentação`](https://elixir-lang.org/install.html).
 2. Abra o seu terminal preferido. Nós vamos precisar para os próximos passos.
 3. Execute o comando `mix local.hex` para instalar o `hex`.
 4. Execute o comando `mix archive.install hex phx_new` para instalar o Phoenix Framework.
 5. Instale a versão `v16.8.0` do Node. [`Leia a documentação`](https://nodejs.org/en/download/).
 6. Instale o Postgres. [`Leia a documentação`](https://wiki.postgresql.org/wiki/Detailed_installation_guides).
 7. Execute o comando `git clone git@github.com:itaayp/simplified-banking-api.git` para fazer um clone do projeto em sua maquina pessoal.
 8. Abra o arquivo `dev.exs` e altere as configurações de `username` e `password` para as configurações do seu banco de dados Postegresql.
 9. Em seu terminal, acesse o diretório do projeto e execute o comando `mix ecto.setup` para criar o banco de dados e executar as migrações.
 10. Use o comando `mix phx.server` para executar a aplicação.
 11. Neste momento, a aplicação está sendo executada na porta 4000. Para acessar os endpoints da API leia a documentação da API.
 12. Divirta-se! :)


## TO-DO's
1. Adicionar CI no projeto
2. Subir a documentação do código em um endereço público
3. Descrever cenários de erro na documentação da API
4. Escrever a documentação da API na ferramenta de documentação do Postman
5. Criar usuários na API, e vincular usuários à contas
6. Autenticar usuários e não permitir que usuários movimentem contas de outras pessoas
7. Garantir que somente usuários admin possam apagar o banco de dados (para fins de teste)
8. Criar um endpoint exclusivo para criar conta, outro para fazer depósito, e transferência
9. Não permitir transferir ou depositar em contas inexistentes
10. Testar a documentação utilizando o doc_test, do ExDoc