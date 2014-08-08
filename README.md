# Painel Social

...

## Introdução

TODO

## Dependências

* Ruby >= 2.0.0
* Rails >= 4.1
* Redis
* Um servidor *multi-thread* ([puma](https://github.com/puma/puma), [rainbows](http://rainbows.rubyforge.org/))


## Primeiros passos

1. Clone o projeto:
    
    ```
    $ git clone https://github.com/labhackercd/painel-social.git
    ```

2. Execute o bundle:
    
    ```
    $ bundle install
    ```

3. Configure o arquivo `secrets.yml` com suas credenciais do twitter:
    
    ```
    TODO
    ```
    
    * Veja a seção [Configuração][] para informações sobre este arquivo

4. Inicie o servidor Redis:
    
    ```
    $ redis-server
    ```

5. Execute a aplicação:
    
    ```
    $ rails s
    ```

6. Acesse [http://localhost:3000/dashing/dashboards](http://localhost:3000/dashing/dashboards) e divirta-se!


## Configuração

TODO


## Criação e inicialização do banco de dados

TODO


## Testes

TODO


## Serviços

TODO
