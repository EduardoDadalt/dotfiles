## Idioma

- Responda sempre ao usuário em português brasileiro (PT-BR).
- Preserve no código o idioma, o estilo e as convenções já adotados pelo projeto,
  inclusive em identificadores, comentários, documentação e mensagens. Não
  traduza esses elementos apenas para adequá-los ao idioma da resposta.

## Gerenciamento de dependências

- Antes de adicionar, remover ou atualizar dependências, identifique qual
  gerenciador de pacotes o projeto já usa, verificando arquivos de lock,
  manifestos, campos como `packageManager`, configurações de workspace e a
  documentação do repositório. Continue usando o mesmo gerenciador; não introduza
  outro sem solicitação explícita.
- Priorize sempre a CLI oficial do ecossistema para alterar dependências e seus
  manifestos, por exemplo `flutter pub add`, `dart pub add`, `pnpm add`,
  `npm install` ou `bun add`, em vez de editar manualmente arquivos como
  `pubspec.yaml` ou `package.json` quando a operação for suportada pela CLI.
- Nunca edite arquivos de lock manualmente. Gere ou atualize `pubspec.lock`,
  `pnpm-lock.yaml`, `package-lock.json`, `bun.lock` e arquivos equivalentes
  somente por meio do gerenciador de pacotes correspondente.

## Instalação de ferramentas

- Se a resolução do problema exigir uma ferramenta que não esteja instalada, ou
  se uma ferramenta adicional puder ajudar, identifique primeiro o sistema
  operacional da máquina e recomende ao usuário a forma de instalação adequada
  para que o trabalho possa continuar.
- Após recomendar a instalação, peça ao usuário que avise quando ela estiver
  concluída, encerre o turno e aguarde sua resposta. Não continue executando
  comandos, fazendo alterações ou buscando alternativas enquanto aguarda, mesmo
  que a ferramenta seja opcional.
- Retome o trabalho somente quando o usuário confirmar a instalação ou orientar
  explicitamente outro caminho. Silêncio ou tempo decorrido não autorizam a
  retomada. Se ele confirmar a instalação, verifique se a ferramenta está
  disponível antes de usá-la.

## Criação de projetos

- Ao iniciar um projeto, priorize o comando oficial de criação ou scaffolding do
  framework/ecossistema, como `flutter create`, `pnpm create` ou
  `pnpm dlx create-...`, em vez de criar manualmente a estrutura, os manifestos e
  os arquivos de configuração quando houver uma CLI apropriada.
- Para novos projetos JavaScript ou TypeScript, use `pnpm` como gerenciador de
  pacotes padrão quando o usuário, o template ou o ambiente não especificarem
  outro. Ao executar um gerador, selecione também `pnpm` nas opções ou flags
  disponíveis para evitar a criação de lockfiles de outro gerenciador.

## Gerenciamento de skills

- Nunca crie, edite, mova, renomeie ou exclua um arquivo de uma skill sem antes
  pedir e receber autorização explícita do usuário para a modificação.

## Autenticação do GitHub

- Em ambientes com sandbox, não conclua que a credencial do GitHub CLI está
  inválida com base apenas em `gh auth status` executado dentro do sandbox. Repita
  a verificação fora do sandbox antes de solicitar uma nova autenticação e execute
  fora dele as operações do `gh` que dependam dessa credencial.

## Revisões de código

- Ao apresentar bugs, defeitos, achados ou comentários de uma revisão de código,
  numere cada item sequencialmente a partir de 1, para que o usuário possa se
  referir a eles pelo número. Preserve a mesma numeração ao retomar ou discutir
  a mesma revisão.
