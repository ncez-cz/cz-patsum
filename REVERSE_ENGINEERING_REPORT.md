# REVERSE_ENGINEERING_REPORT.md

**Repositório:** cz-patsum  
**URL:** https://github.com/ncez-cz/cz-patsum  
**Branch base analisada:** master (commit 4248395233bca2d019e4f10e7195132440d7b742)  
**Fork alvo:** https://github.com/admeduardovieira/cz-patsum  
**Data da auditoria:** 2026-11-08  
**Ambiente:** Windows, PowerShell 5.1, Git 2.49.0, Python 3.12.14  
**Agente:** Kilo (REA 6.7.0), identidade Git admeduardovieira / admeduardovieira@users.noreply.github.com  

---

## A. Diagnóstico geral

### Arquitetura identificada
cz-patsum é um Implementation Guide (IG) FHIR R4 para o Pacientský souhrn (Patient Summary) tcheco (CZ PS), desenvolvido pelo Národní centrum elektronického zdravotnictví (NCEZ). O projeto é construído com **SUSHI/FSH** (FHIR Shorthand) e publicado com o IG Publisher. Não é uma aplicação executável: não há código-fonte de aplicação, backend, frontend, API ou serviço.

Estrutura de diretórios:
- `input/fsh/profiles/*.fsh` — 26 perfis FHIR (ex: CZ_CompositionPS, CZ_BundlePatientSummary, CZ_ConditionPS, CZ_MedicationRequestPS, observações de gravidez/álcool/tabaco/resultados).
- `input/fsh/invariants/*.fsh` — 5 invariantes FHIR (ips-1, ips-2, bdl-ips-1, hasComponentifValueStringEmpty, hasMemberOrComponent).
- `input/fsh/aliases.fsh` — aliases de valuesets/codesystems (LOINC, SNOMED, MKn-10, UV-IPS etc.).
- `input/pagecontent/*.md` e `*.xml` — páginas de documentação do IG (index, principles, design, profiles, knownIssues, etc.).
- `input/images/PS-composition.png`, `input/includes/img.html` — assets visuais.
- `sushi-config.yaml` — configuração do SUSHI (id, canonical, dependências, menu, releaseLabel).
- `ig.ini` — configuração do IG Publisher (aponta para recurso gerado `fsh-generated/resources/...`).
- `package-lock.json` — lockfile vazio (apenas `name`, sem pacotes).
- `.gitignore` — ignora `fsh-generated`, `input-cache`, `output`, `temp`, `template`.

### Tecnologias e dependências
- FHIR R4 (4.0.1)
- SUSHI (FSH)
- HL7 UV-IPS (International Patient Summary) como base (perfis, valuesets, extensões)
- Dependências do IG: `hl7.fhir.uv.ips: current`, `hl7.fhir.us.mcode: current`, `ncez.cz.fhir.core: current`, `ncez.cz.fhir.lab: current` (todas com versão `current`, não fixadas).
- releaseLabel: `ci-build` (grafia correta, não `releaselabel`).

### Estado de manutenção
Último commit na base analisada: `4248395` ("Update of the specification", 07/03/2023, autor kruzikh). O histórico mostra conversão dos perfis IPS para o Patient Summary tcheco, com versões de rascunho compilado e um revert. Não há atividade recente visível na branch master além da análise feita. Não há issues/PRs públicos verificados neste snapshot.

### Mecanismos de testes existentes
Nenhum teste automatizado foi encontrado no repositório:
- Ausência de pasta `test/`, `__tests__/`, ou arquivos de teste.
- Ausência de `.github/workflows` (sem CI/CD).
- Ausência de `package.json` (somente `package-lock.json` vazio).
- Não é possível executar `sushi` (não instalado) para compilar/validar os FSH.

### Limitações da investigação
- SUSHI não está instalado no ambiente; impossível compilar os arquivos `.fsh` ou gerar o IG para validação funcional.
- pandas/scipy/litellm/Maven/R não instalados; testes numéricos não executados.
- Não foram acessados issues/PRs do GitHub além do clone (escopo limitado ao conteúdo do repositório clonado).
- Nenhum teste intrusivo ou ofensivo foi realizado contra serviços de terceiros.

---

## B. Problemas encontrados

| ID | Título | Severidade | Status | Localização |
|----|--------|------------|--------|-------------|
| REA-001 | Dependências de pacote não fixadas (versão `current`) | P2 | CONFIRMADO | `sushi-config.yaml:33-37` |
| REA-002 | Ausência de CI/CD e testes automatizados | P3 | CONFIRMADO | Repositório raiz (ausência de `.github/workflows` e testes) |
| REA-003 | `package-lock.json` vazio/inútil | P3 | CONFIRMADO | `package-lock.json` (apenas `name`, sem pacotes) |
| REA-004 | Slicing de seções em modo `open` reduz validação automática de instâncias | P2 | CONFIRMADO | `input/fsh/profiles/CzComposition.fsh` (seções) e `knownIssues.md` item 3 |
| REA-005 | Slices de entrada de seção comentados (não implementados) | P3 | HIPÓTESE | `input/fsh/profiles/CzComposition.fsh` (linhas comentadas ~93-101, 110-118, etc.) |

### Detalhes

**REA-001 — Dependências não fixadas (CONFIRMADO)**
- Problema: `sushi-config.yaml` declara todas as dependências com versão `current` (`hl7.fhir.uv.ips: current`, `hl7.fhir.us.mcode: current`, `ncez.cz.fhir.core: current`, `ncez.cz.fhir.lab: current`).
- Evidência: `sushi-config.yaml:33-37`.
- Causa-raiz: opção de configuração que não pinna versões específicas, sujeitando o build a alterações upstream não controladas.
- Impacto: builds não reproduzíveis; risco de quebra por mudança retroativa incompatível em dependências (cadeia de suprimentos).
- Correção proposta: substituir `current` por versões específicas estáveis (ou manter `current` apenas se intencional, documentando a decisão).

**REA-002 — Ausência de CI/CD e testes automatizados (CONFIRMADO)**
- Problema: não há workflows de GitHub Actions, nem testes de validação de FSH/IG, nem testes de serialização.
- Evidência: ausência de diretório `.github/workflows` e ausência de arquivos de teste no clone.
- Causa-raiz: o IG não dispõe de pipeline de integração contínua.
- Impacto: alterações em perfis FSH não são validadas automaticamente; regressões passam despercebidas.
- Correção proposta: adicionar workflow de CI que rode `sushi` (quando disponível) e valide o IG gerado.

**REA-003 — `package-lock.json` vazio/inútil (CONFIRMADO)**
- Problema: `package-lock.json` contém apenas `"name": "cz-patsum"` e `"packages": {}`, sem dependências declaradas.
- Evidência: conteúdo do arquivo (apenas cabeçalho, sem pacotes).
- Causa-raiz: lockfile gerado sem `package.json` correspondente ou dependências instaladas.
- Impacto: arquivo sem função; pode confundir contribuidores.
- Correção proposta: remover o arquivo vazio ou adicionar `package.json` com dependências de build (ex: fhirtypes, sushi) se for o intuito.

**REA-004 — Slicing de seções em modo `open` (CONFIRMADO, já documentado)**
- Problema: todas as regras de slicing das seções da composição são definidas como `open` (ex: `section ^slicing.rules = #open`), permitindo inclusão de recursos inadequados.
- Evidência: `CzComposition.fsh:57` (`section ^slicing.rules = #open`) e `knownIssues.md` item 3 ("All of the slicing rules defined for the section entries have been specified in this version as open...").
- Causa-raiz: decisão de design por flexibilidade, às custas da validação automática.
- Impacto: instâncias podem conter recursos inadequados sem serem rejeitadas validadoras.
- Correção proposta: revisar slices críticos e considerar `closed` onde a segurança clínica exija, mantendo documentação da trade-off.

**REA-005 — Slices de entrada de seção comentados (HIPÓTESE)**
- Problema: diversos slices de entrada de seção (medication, allergies, problems, procedures, etc.) estão comentados em `CzComposition.fsh`.
- Evidência: linhas comentadas (~93-101, 110-118, 126-133, etc.).
- Causa-raiz: slices planejados mas não ativados.
- Impacto: falta de tipagem forte nas entradas de seção; validação menos estrita.
- Correção proposta: avaliar ativação gradual dos slices comentados com testes de instância.

---

## C. Problemas recorrentes

Os problemas abaixo já são reconhecidos pelos mantenedores (documentados em `input/pagecontent/knownIssues.md`) e ainda persistem na versão analisada:

1. **Falta de representação das atividades de sumarização** (quem fez, o quê, resultado, quando/onde) — incluiu "Nature of the IPS" de EN 17269/ISO 27269. Futuro: uso do recurso Provenance.
2. **Especificidade dos perfis a melhorar** — nem todas as regras podem ser validadas automaticamente por falta de representação nos perfis.
3. **Slicing aberto** — reduz capacidade de validação automática de instâncias; permite recursos inadequados.
4. **Vocabulários mais restritos necessários** — bindings atuais são preferenciais/extensíveis em vários casos; falta de vocabulários globalmente reconhecidos e livremente usáveis (ex: medicações).
5. **Sinergia com International Patient Access IG** e adoção de Provenance (desenvolvimento futuro).

Fonte: `input/pagecontent/knownIssues.md` (Itens 1-5 e Future Development).

---

## D. Erros não documentados

Erros identificados pela auditoria que não constam em `knownIssues.md` nem em documentação do projeto:

- **REA-001**: dependências com versão `current` não fixadas.
- **REA-002**: ausência de CI/CD e testes.
- **REA-003**: `package-lock.json` vazio.
- **REA-005**: slices comentados não ativados.

---

## E. Performance

Não há código executável nem operações de runtime a medir. O projeto é um IG estático gerado por SUSHI. Oportunidades de performance dizem respeito ao tempo de geração do IG (build do SUSHI), não ao runtime:

- Dependências `current` podem causar downloads repetidos de pacotes não fixados (recomendação: fixar versões para builds reproduzíveis e mais rápidos via cache).
- Sem medição inicial possível (SUSHI não instalado).

Não foram declarados ganhos percentuais sem benchmark reproduzível.

---

## F. Melhorias técnicas

| Área | Melhoria | Justificativa |
|------|----------|---------------|
| Cadeia de suprimentos | Fixar versões das dependências em `sushi-config.yaml` | Builds reproduzíveis; evita quebras por mudanças upstream |
| Qualidade | Adicionar CI/CD (GitHub Actions) com validação SUSHI/IG | Detecção precoce de regressões em perfis FSH |
| Qualidade | Remover ou preencher `package-lock.json` vazio | Evitar confusão para contribuidores |
| Robustez | Revisar slicing `open` para `closed` em seções críticas | Validação mais estrita de instâncias clínicas |
| Testabilidade | Adicionar exemplos de instâncias e testes de validação | Cobertura de comportamentos importantes |
| Documentação | Atualizar `knownIssues.md` com status dos itens (corrigido/pendente) | Rastreabilidade de problemas conhecidos |

---

## G. Plano de execução

Correções independentes, podendo ser PRs separados:

1. **REA-001** (P2, imediata): fixar versões de dependência em `sushi-config.yaml`. Baixo risco, teste reproduzível (verificar que o YAML permanece válido e versões específicas são usadas).
2. **REA-003** (P3, imediata): remover `package-lock.json` vazio ou adicionar `package.json` correspondente. Baixo risco.
3. **REA-002** (P3, média): adicionar workflow de CI. Médio risco (requer SUSHI instalado no runner).
4. **REA-004** (P2, média): revisar slicing `open` para `closed` onde justificado. Médio risco (altera comportamento de validação de perfis).
5. **REA-005** (P3, baixa): avaliar ativação de slices comentados. Médio risco (depende de testes de instância).

Ordem recomendada: REA-001 → REA-003 → REA-002 → REA-004 → REA-005.

---

## H. Resultado esperado

- Builds do IG reproduzíveis e livres de surpresas por versão de dependência (REA-001).
- Repositório limpo, sem arquivos vestigiais (REA-003).
- Detecção automática de regressões via CI (REA-002).
- Validação de instâncias mais estrita e segura clinicamente (REA-004).
- Contribuições de baixo risco, com testes e evidências, adequadas a PRs pequenos e revisáveis para os mantenedores originais.

---

## Perguntas finais obrigatórias

1. **Quais bugs críticos foram comprovados?** Nenhum bug crítico (P0/P1) comprovado. O projeto é um IG estático sem código executável; não há falhas funcionais críticas identificadas.
2. **Quais problemas repetitivos os desenvolvedores ainda não resolveram?** Slicing aberto (knownIssues #3), especificidade dos perfis (#2), falta de representação de atividades de sumarização (#1), vocabulários mais restritos (#4) — todos documentados em `knownIssues.md` e ainda presentes.
3. **Quais erros importantes não estavam documentados?** Dependências `current` não fixadas (REA-001), ausência de CI/CD e testes (REA-002), `package-lock.json` vazio (REA-003), slices comentados não ativados (REA-005).
4. **Quais oportunidades de performance foram encontradas?** Fixar versões de dependência para builds do SUSHI mais rápidos e reproduzíveis (cache de pacotes). Sem medição inicial possível.
5. **Quais melhorias de segurança e confiabilidade são justificáveis?** Fixar dependências (cadeia de suprimentos), CI/CD para detecção de regressões, slicing mais estrito para validação de instâncias clínicas.
6. **Quais correções podem ser feitas rapidamente?** REA-001 (fixar versões no YAML) e REA-003 (remover/preencher package-lock.json).
7. **Quais são as três contribuições com maior potencial de valor técnico?** (1) Fixar versões de dependência (reprodutibilidade), (2) Adicionar CI/CD com validação SUSHI (detecção de regressões), (3) Revisar slicing `open` → `closed` em seções críticas (segurança clínica da validação).
8. **Quais correções devem ser evitadas por falta de evidência?** Alterar perfis clínicos (obrigações cardinalidade, bindings) sem dados de instância reais ou validação SUSHI; ativar slices comentados sem teste de instância.
9. **Quais modificações você recomenda implementar primeiro?** REA-001 e REA-003 (pequenas, baixo risco, teste reproduzível, sem escopo alheio).

---

## Análise de malware e ameaças (estática)

Executada em todos os arquivos do repositório (FSH, YAML, INI, MD, XML, PNG, HTML, JSON, .gitignore).

**Resultado: Nenhum indicador identificado pela análise estática realizada.**

- Não há scripts executáveis (.ps1, .sh, .bat, .cmd, .js, .ts, .py), nem binários (.exe, .dll) fora do diretório `.git` (amostras de hooks padrão do Git, não parte do projeto).
- Não há `.github/workflows` (nenhuma Action customizada ou suspeita).
- URLs/domínios presentes são aliases FHIR legítimos (hl7.org, loinc.org, snomed.org, ncez.mzcr.cz, mkn10.uzis.cz, etc.).
- Não há chaves, credenciais, tokens ou strings de conexão embutidas.
- Não há ofuscação, empacotamento, persistência, execução de processos, escrita/remoção de arquivos, coleta/exfiltração de dados ou modificação de configuração suspeita.
- `package-lock.json` está vazio (sem pacotes, sem risco de supply-chain via npm).

**Limitação:** análise estática apenas; não foram executados amostras. Não se afirma que o projeto está livre de malware.

---

**Nota:** Este relatório é a versão base em português. Versões sincronizadas em inglês (`.en.md`) e ucraniano (`.uk.md`) acompanham este documento, preservando IDs REA-*, severidades P0–P3, caminhos, comandos, URLs e trechos de código inalterados.
