# CORRECTIONS.md

**Repositório:** cz-patsum  
**URL:** https://github.com/ncez-cz/cz-patsum  
**Branch base analisada:** master (commit 4248395233bca2d019e4f10e7195132440d7b742)  
**Fork alvo:** https://github.com/admeduardovieira/cz-patsum  
**Data:** 2026-11-08  
**Agente:** Kilo (REA 6.7.0), identidade Git admeduardovieira / admeduardovieira@users.noreply.github.com  

---

## Correções propostas e status

| ID | Título | Severidade | Status | Localização | Risco | PR sugerido |
|----|--------|------------|--------|-------------|-------|-------------|
| REA-001 | Fixar versões de dependência (`current` → específicas) | P2 | Proposta (não implementada ainda nesta auditoria) | `sushi-config.yaml:33-37` | Baixo | `fix/rea-001-pin-dependencies` |
| REA-002 | Adicionar CI/CD e testes automatizados | P3 | Proposta (não implementada) | Repositório raiz | Médio | `ci/rea-002-add-sushi-ci` |
| REA-003 | Remover ou preencher `package-lock.json` vazio | P3 | Proposta (não implementada) | `package-lock.json` | Baixo | `chore/rea-003-clean-package-lock` |
| REA-004 | Revisar slicing `open` → `closed` em seções críticas | P2 | Proposta (não implementada) | `input/fsh/profiles/CzComposition.fsh` | Médio | `fix/rea-004-strict-section-slicing` |
| REA-005 | Avaliar ativação de slices comentados | P3 | Hipótese (não implementada) | `input/fsh/profiles/CzComposition.fsh` | Médio | `fix/rea-005-activate-section-slices` |

---

## Detalhes por correção

### REA-001 — Fixar versões de dependência

**Problema:** `sushi-config.yaml` declara dependências com versão `current`, sujeitando o build a mudanças upstream não controladas.

**Evidência:**
```yaml
dependencies:
  hl7.fhir.uv.ips: current
  hl7.fhir.us.mcode: current
  ncez.cz.fhir.core: current
  ncez.cz.fhir.lab: current
```

**Causa-raiz:** versões não pinnadas na configuração do SUSHI.

**Correção proposta:** substituir `current` por versões estáveis específicas (ex: `1.1.0`) após verificar as versões disponíveis nos repositórios upstream. Manter comentário justificando a escolha.

**Arquivos envolvidos:** `sushi-config.yaml`

**Teste de validação:** validar YAML com parser (ex: Python `yaml.safe_load`) e confirmar que não há mais o valor `current` nas dependências.

**Risco:** baixo.

**Benefício:** builds reproduzíveis e previsíveis.

**Prioridade:** imediata.

---

### REA-002 — Adicionar CI/CD e testes automatizados

**Problema:** ausência de `.github/workflows` e de testes de validação de FSH/IG.

**Evidência:** clone do repositório não contém diretório `.github` nem arquivos de teste.

**Causa-raiz:** o IG não dispõe de pipeline de integração contínua.

**Correção proposta:** adicionar workflow GitHub Actions que instale SUSHI e valide a geração do IG a partir dos FSH.

**Arquivos envolvidos:** `.github/workflows/ci.yml` (novo).

**Teste de validação:** executar workflow em fork/branch e confirmar conclusão com sucesso.

**Risco:** médio (requer SUSHI no runner do CI).

**Benefício:** detecção precoce de regressões em perfis FSH.

**Prioridade:** média.

---

### REA-003 — Remover ou preencher `package-lock.json` vazio

**Problema:** `package-lock.json` contém apenas `"name": "cz-patsum"` e `"packages": {}`, sem função.

**Evidência:** conteúdo do arquivo (cabeçalho vazio de pacotes).

**Causa-raiz:** lockfile gerado sem `package.json` nem dependências instaladas.

**Correção proposta:** remover o arquivo vazio ou adicionar `package.json` com dependências de build se for o intuito.

**Arquivos envolvidos:** `package-lock.json` (remoção) e, opcionalmente, `package.json` (novo).

**Teste de validação:** confirmar que o build/lint não depende do `package-lock.json` vazio.

**Risco:** baixo.

**Benefício:** repositório limpo, sem confusão para contribuidores.

**Prioridade:** imediata.

---

### REA-004 — Revisar slicing `open` → `closed` em seções críticas

**Problema:** regras de slicing de seções definidas como `#open` permitem recursos inadequados.

**Evidência:** `CzComposition.fsh:57` (`section ^slicing.rules = #open`) e `knownIssues.md` item 3.

**Causa-raiz:** decisão de design por flexibilidade, às custas da validação automática.

**Correção proposta:** avaliar seções críticas (medicações, alergias, problemas) e alterar slicing para `#closed` onde a segurança clínica exija, documentando a trade-off.

**Arquivos envolvidos:** `input/fsh/profiles/CzComposition.fsh`.

**Teste de validação:** gerar IG com SUSHI e validar instâncias de exemplo contra os perfis.

**Risco:** médio (altera comportamento de validação de perfis clínicos).

**Benefício:** validação mais estrita e segura de instâncias.

**Prioridade:** média.

---

### REA-005 — Avaliar ativação de slices comentados

**Problema:** slices de entrada de seção (medicações, alergias, problemas, procedimentos, etc.) estão comentados em `CzComposition.fsh`.

**Evidência:** linhas comentadas (~93-101, 110-118, 126-133 e outras).

**Causa-raiz:** slices planejados mas não ativados.

**Correção proposta:** avaliar ativação gradual dos slices comentados com testes de instância.

**Arquivos envolvidos:** `input/fsh/profiles/CzComposition.fsh`.

**Teste de validação:** gerar IG e validar instâncias com e without slices ativos.

**Risco:** médio (depende de testes de instância).

**Benefício:** tipagem mais forte nas entradas de seção.

**Prioridade:** baixa.

---

## Problemas não corrigidos e riscos remanescentes

- Todos os problemas acima estão em status "Proposta" ou "Hipótese" nesta etapa de auditoria (Fase 1 concluída). Nenhuma alteração foi aplicada ao código-fonte ainda.
- Riscos remanescentes: dependências `current` ainda não fixadas; ausência de CI/CD; slicing aberto ainda ativo; slices comentados ainda desativados.
- Nenhuma vulnerabilidade de segurança confirmada pela análise estática.

---

## Registros de relatório

- Base PT: `REVERSE_ENGINEERING_REPORT.md` e `CORRECTIONS.md` (este arquivo).
- Traduções: `REVERSE_ENGINEERING_REPORT.en.md`, `REVERSE_ENGINEERING_REPORT.uk.md`, `CORRECTIONS.en.md`, `CORRECTIONS.uk.md`.
- Todos na raiz do clone de trabalho / área de auditoria, ao lado dos relatórios-base em português.

**Nota de tradução (uk):** Tradução técnica assistida automaticamente; recomenda-se revisão por falante nativo antes de uso como referência normativa. Não houve revisão por nativo obtida.
