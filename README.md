# Educatium

> Plataforma de Gestão de Recursos Educativos

## Instalação

A plataforma depende de vários serviços para funcionar corretamente - uma web app feita em Elixir com Phoenix e uma base de dados em PostgreSQL.

Como tal, o grupo decidiu criar um _setup_ com recurso a Docker e Docker Compose.

> [!NOTE]
> Caso pretenda utilizar a autenticação via Google, é necessária a criação de uma aplicação no Google Developers.

### Docker

```bash
cp .env.dev.sample .env.dev # Copiar o ficheiro de configuração (poderá ser necessário alterar localhost para db em DB_HOST)
docker-compose -f docker-compose.dev.yml -f {linux,darwin,windows}.yml up
```

Atenção na escolha do segundo ficheiro, pois o mesmo é dependente do sistema operativo que está a ser utilizado.

É, ainda possível, levantar apenas um container com a base de dados, utilizando a web app em modo local.

```bash
docker-compose -f docker-compose.dev.yml -f {linux,darwin,windows}.yml up db
```

### Local

```bash
cp .env.dev.sample .env.dev # Copiar o ficheiro de configuração
mix setup # Instalar as dependências
mix ecto.create # Cria a base de dados
mix ecto.migrate # Cria as tabelas
mix ecto.seed # Preenche a base de dados com dados de exemplo
mix phx.server # Iniciar a web app
```

## Funcionalidades

### Utilizadores e Níveis de Acesso

- Três níveis de acesso: Administrador, Aluno e Professor
- Todos podem ser produtores e consumidores de recursos educativos
- Não é possível utilizadores sem conta acederem à plataforma, desta forma evita-se _griefing_
- Cada utilizador tem um perfil com informações pessoais e recursos educativos criados e guardados
- É ainda possível alterar todas as informações pessoais, incluindo o email e a password

Estrutura do modelo de um utilizador:

```
User: {
  email: string
  hashed_password: string
  avatar: string
  handle: string
  first_name :string
  last_name: string
  course: string
  university: string
  role: string
  confirmed_at :datetime
  active: boolean
}
```

Daqui depreende-se que um utilizador tem um email, uma password, um avatar, um _handle_, um primeiro nome, um último nome, um curso, uma universidade, um papel, uma data de confirmação e um estado de ativação.

Esta data de confirmação é utilizada para verificar se o utilizador confirmou o seu email.

O estado de ativação é utilizado para verificar se o utilizador está ativo ou não. Inicialmente, para verificar se o mesmo já terminou o seu registo, preenchendo campos como o primeiro nome, o último nome, o curso e a universidade, etc.

#### Screenshots

| ![Profile page](/docs/report/profile.png) |
| :---------------------------------------: |
|     Página de perfil de um utilizador     |

| ![Settings page](/docs/report/settings.png) |
| :-----------------------------------------: |
|    Página de definições de um utilizador    |

|     ![Tab Settings Dev](/docs/report/dev.png)      |
| :------------------------------------------------: |
| Aba 'Dev' da página de definições de um utilizador |

### Feed

- Feed estilo GitHub com os recursos educativos mais recentes e anúncios criados pelos administradores
- Possibilidade de filtrar os recursos educativos por tipo e ordenar por data de inserção e popularidade
- Possibilidade de fazer um _upvote_ ou _downvote_ a um recurso educativo e, ainda, de o comentar
- Possibilidade de guardar, diretamente a partir do feed, um recurso educativo para ver mais tarde
- Visualização em tempo real dos _upvotes_ e _downvotes_ de um recurso educativo, tal como da criação de recursos por outros utilizadores

#### Screenshots

| ![Feed](/docs/report/feed.png) |
| :----------------------------: |
|  Feed principal da aplicação   |

### Recursos Educativos

Estrutura do modelo de um recurso educativo:

```
Resource: {
  title: string
  description: string
  type: string (book | article | notes | code | worksheet ...)
  date: date
  visibility: string (public | private)
  root_directory_id: uuid
  ... # outros relacionamentos
}
```

Daqui depreende-se que um recurso educativo tem um título, uma descrição, um tipo, uma data, uma visibilidade e uma diretoria raiz. Esta diretoria é _uploaded_ pelo utilizador aquando da criação do recurso educativo. Foi criado, também, um mapeamento na base de dados para diretorias e ficheiros de um recurso, de forma que seja possível fazer uma listagem dos mesmos.

Para além da criação simples, através de um formulário, de um recurso, é também possível a criação de múltiplos recursos através do uso de um ficheiro `.json`.

| ![Um recurso](/docs/report/single_resource.png) |
| :---------------------------------------------: |
|           Criação de um único recurso           |

| ![Vários recursos](/docs/report/multiple_resource.png) |
| :----------------------------------------------------: |
|             Criação de múltiplos recursos              |

| ![Página de um recurso](/docs/report/resource.png) |
| :------------------------------------------------: |
|                Página de um recurso                |

### Anúncios

- Anúncios criados pelos administradores, que dão sempre aso a um post

Estrutura do modelo de um anúncio:

```
Announcement: {
  title: string
  body: string
}
```

#### Screenshots

| ![Anúncios](/docs/report/announcement.png) |
| :----------------------------------------: |
|            Página de um anúncio            |

### Admin dashboard

- Página de administração com CRUD sobre entidades da plataforma

#### Screenshots

| ![Admin dashboard](/docs/report/users.png) |
| :----------------------------------------: |
| Página de gestão de utilizadores da plataforma |

| ![Admin dashboard](/docs/report/resources.png) |
| :-------------------------------------------: |
| Página de gestão de recursos educativos da plataforma |

| ![Admin dashboard](/docs/report/announcements.png) |
| :------------------------------------------------: |
| Página de gestão de anúncios da plataforma |

| ![Admin dashboard](/docs/report/posts.png) |
| :----------------------------------------: |
| Página de gestão de posts da plataforma |

| ![Admin dashboard](/docs/report/tags.png) |
| :---------------------------------------: |
| Página de gestão de tags da plataforma |

### API REST

O grupo decidiu criar uma API REST para a plataforma, de forma que seja possível a integração com outras aplicações. Esta API é acessível com recurso a uma chave que pode ser gerada na página de definições de um utilizador.

#### Endpoints

_Headers_ necessários:
```HTTP
Authorization: <token>
```

Este token pode ser obtido a partir das definições do utilizador na página de desenvolvimento.

- `GET /api` - Endpoint mostrar estado da API (não é necessário token)
- `GET /api/test` - Endpoint testar validade token
- `GET /api/myself` - Endpoint ver utilizador associado ao token
- `GET /api/users/:id` - Endpoint ver utilizador com `id`
- `GET /api/resources` - Endpoint listar todos os recursos
- `GET /api/resources/:id` - Endpoint ver informações recurso
- `POST /api/resources/` - Endpoint publicar recurso (enviar recurso com multipart)
- `GET /api/tags` - Endpoint listar todas as tags
- `GET /api/tags/:id` - Endpoint ver informações de uma tag
- `GET /api/announcements` - Endpoint listar todos os anúncios
- `GET /api/announcements/:id` - Endpoint ver informações de um anúncio

##### Endpoints para Administrador

Todos estes endpoints só estão disponíveis caso o utilizador associado ao _token_ seja um administrador.

- `GET /api/users` - Endpoint listar todos os utilizadores
- `POST /api/tags` - Endpoint criar uma tag
- `PUT /api/tags/:id` - Endpoint editar uma tag
- `DELETE /api/tags/:id` - Endpoint apagar uma tag
- `POST /api/announcements` - Endpoint criar um anúncio
- `PUT /api/announcements/:id` - Endpoint editar um anúncio
- `DELETE /api/announcements/:id` - Endpoint apagar um anúncio

### Exportar

- Exportar todos os dados relativos à plataforma para um ficheiro `.json`, acessível apenas por administradores

### Tradução

- Tradução de toda a plataforma para português, onde consoante o idioma do utilizador, a plataforma é traduzida para português ou inglês
