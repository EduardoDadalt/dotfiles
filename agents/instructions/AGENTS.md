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

## CNPJ alfanumérico

- O CNPJ agora é alfanumérico (IN RFB nº 2.229/2024, com novas inscrições a
  partir de julho de 2026). Ele continua com 14 caracteres: os 12 primeiros
  podem ser letras maiúsculas de `A` a `Z` ou dígitos, e os 2 últimos, os
  dígitos verificadores, continuam numéricos. Os CNPJs só com números já
  emitidos continuam válidos, e o CPF continua apenas numérico.
- Ao normalizar ou remover a máscara de um CNPJ, retire só a pontuação
  (`.`, `/` e `-`) e preserve as letras, convertendo-as para maiúsculas. Nunca
  use `\D`, `[^0-9]` ou equivalentes para isso, nem trate o CNPJ como número
  (`int`, `BigInt`, colunas numéricas).
- Máscaras, filtros de busca, validações e campos de entrada de CNPJ devem
  aceitar letras. Para diferenciar CPF de CNPJ, use a quantidade de caracteres
  sem pontuação (11 ou 14), não a presença exclusiva de dígitos.
- No cálculo dos dígitos verificadores, cada caractere vale o seu código ASCII
  menos 48 (`0`–`9` valem 0–9 e `A`–`Z` valem 17–42); os pesos e o módulo 11
  são os mesmos do CNPJ numérico.

## Revisões de código

- Ao apresentar bugs, defeitos, achados ou comentários de uma revisão de código,
  numere cada item sequencialmente a partir de 1, para que o usuário possa se
  referir a eles pelo número. Preserve a mesma numeração ao retomar ou discutir
  a mesma revisão.
- Quando a revisão também aplicar correções (por exemplo, `code-review --fix`),
  apresente uma única lista numerada, em que cada item reúne o achado e o
  resultado. Não repita os achados numa segunda lista ou seção (como "O que
  aconteceu com cada item"). Logo após o número, indique o que aconteceu com o
  item: `(Corrigido)`, `(Não corrigido)` ou `(Sem alteração necessária)`; em
  seguida, descreva o achado com o arquivo, a linha e o cenário de falha e, no
  mesmo item, diga o que foi alterado ou, para os itens não corrigidos ou sem
  alteração, explique brevemente o motivo. Por exemplo:

  ```md
  1. (Corrigido) `caminho/arquivo.dart:107`: descrição do defeito.

     Cenário de falha: entrada ou estado → resultado incorreto.

     Correção: o que foi alterado.
  ```
