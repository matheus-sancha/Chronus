# Chronus — Manual do Usuário

**Aplicativo de cronoanálise para engenheiros e técnicos de manufatura.**

Prévia interna · Referente à versão Windows · [English version](MANUAL-en.md)

---

## Índice

1. [Para que serve o Chronus](#1-para-que-serve-o-chronus)
2. [Instalação e primeiro uso](#2-instalação-e-primeiro-uso)
3. [Como o aplicativo é organizado](#3-como-o-aplicativo-é-organizado)
4. [Projetos](#4-projetos)
5. [O catálogo de operações](#5-o-catálogo-de-operações)
6. [A tela do estudo](#6-a-tela-do-estudo)
7. [Exemplo prático: um ciclo de suporte](#7-exemplo-prático-um-ciclo-de-suporte)
8. [O relatório](#8-o-relatório)
9. [Como ler a linha do tempo](#9-como-ler-a-linha-do-tempo)
10. [Por que os números não fecham](#10-por-que-os-números-não-fecham)
11. [Estudo por amostragem: várias tomadas](#11-estudo-por-amostragem-várias-tomadas)
12. [O relatório de amostragem](#12-o-relatório-de-amostragem)
13. [Comparando estudos](#13-comparando-estudos)
14. [Notas e fotos](#14-notas-e-fotos)
15. [Exportação](#15-exportação)
16. [Configurações, backup e restauração](#16-configurações-backup-e-restauração)
17. [Ainda não disponível](#17-ainda-não-disponível)
18. [Solução de problemas](#18-solução-de-problemas)

---

## 1. Para que serve o Chronus

O Chronus permite que você fique ao lado da máquina, cronometre uma sequência de operações, classifique cada uma como preparação, agregação de valor ou desperdício, e gere um relatório que se sustenta numa reunião.

Ele foi feito para a forma como a cronoanálise realmente acontece no chão de fábrica:

- **O cronômetro nem sempre está rodando.** Nem todo instante pertence a uma operação. Tempo morto só é contabilizado quando você o atribui explicitamente a alguma coisa.
- **Operações se sobrepõem.** Dois operadores numa montagem, ou a máquina rodando enquanto o operador espera. Para o Chronus, simultaneidade é normal, não é erro.
- **Você corrige durante o processo.** Operações são acrescentadas no meio do estudo, tempos são digitados quando você esquece de apertar o start, e uma medição é descartada e refeita.
- **Uma leitura não é uma medição.** Um processo que se repete é cronometrado várias vezes e tirada a média, com as estatísticas para dizer se você já mediu o suficiente, e com a possibilidade de descartar a tomada em que a linha ficou parada (seção 11).

Tudo fica salvo no computador em que o programa roda. Não há login, não há sincronização e não há servidor.

---

## 2. Instalação e primeiro uso

1. Descompacte a pasta inteira em qualquer lugar, por exemplo `C:\Chronus`. Não há instalador.
2. Execute o `chronus.exe`.
3. Na primeira vez, o Windows pode mostrar **"O Windows protegeu o seu PC"**. Clique em **Mais informações → Executar assim mesmo**. Isso acontece porque o programa ainda não tem assinatura digital.

Mantenha todos os arquivos da pasta juntos — o `chronus.exe` não funciona sozinho.

**Onde ficam os seus dados.** Não é na pasta do programa. Eles ficam em:

```
%APPDATA%\com.matheussancha\chronus
```

Cole esse caminho na barra de endereço do Explorador de Arquivos para abrir. Como os dados ficam fora da pasta do programa, você pode descompactar uma versão nova por cima da antiga sem perder nada.

---

## 3. Como o aplicativo é organizado

```
Projeto
 └─ Estudo
     └─ Tomada  (uma no Estudo de Tempo, várias no Estudo por Amostragem)
         └─ Operações (cronometradas individualmente)

Catálogo — definições de operação reutilizáveis, compartilhadas entre estudos
Modelo   — uma sequência de operações reutilizável
```

- Um **Projeto** agrupa estudos relacionados — normalmente uma célula, uma linha ou uma família de produtos.
- Um **Estudo** é uma investigação de uma sequência. Existem dois tipos, escolhidos na criação e alteráveis depois:
  - **Estudo de Tempo** — medido uma vez. Uma tomada, e abrir o estudo leva direto até ela.
  - **Estudo por Amostragem** — a mesma sequência medida várias vezes, com média, estatísticas e um veredito sobre o tamanho da amostra. Ver seção 11.
- Uma **Tomada** é uma passagem pela sequência. A cronometragem funciona igual nos dois tipos, porque um Estudo de Tempo *é* um estudo com uma única tomada — não há uma segunda forma de usar o cronômetro para aprender.
- Uma **Operação** dentro de um estudo é uma *cópia* tirada do catálogo no momento em que você a adicionou. Editar o catálogo depois **não** altera estudos já realizados. Isso é proposital: um relatório de março não pode mudar sozinho porque alguém revisou um padrão em julho.

### Classificação

Toda operação pertence a uma de três categorias fixas. Os relatórios são consolidados por elas, por isso não são editáveis:

| Categoria | Significado |
|---|---|
| **Preparação** | Setup — dispositivo, offsets de ferramenta, troca |
| **Produtivo** | Agrega valor — o trabalho pelo qual o cliente paga |
| **Improdutivo** | Desperdício — todo o resto |

Operações improdutivas também recebem um **subtipo**, tirado dos sete desperdícios: Espera, Movimentação, Transporte, Superprocessamento, Superprodução, Estoque, Defeitos. Você pode criar subtipos próprios, mas sempre dentro de uma das três categorias acima, para que a consolidação continue funcionando.

### Tempo de referência

Qualquer operação pode ter um **tempo de referência** opcional — um padrão que você já possui. Quando existe, o Chronus reporta:

**Eficiência = tempo de referência ÷ tempo observado**

Igual ou acima de 100 % significa que o padrão foi atingido ou superado.

---

## 4. Projetos

A tela inicial. Crie um projeto com o botão **+** e abra-o para adicionar estudos.

![Tela de Projetos](manual/images/projects-pt.png)

Use o menu da linha para renomear ou excluir. Excluir um projeto exclui junto os estudos dele.

---

## 5. O catálogo de operações

O catálogo é a sua biblioteca reutilizável de definições de operação. Monte-o uma vez e cada estudo novo passa a ser questão de escolher de uma lista, em vez de redigitar tudo.

**Ele não vem vazio numa instalação nova.** O Chronus já chega com uma lista inicial curta, tirada de um ciclo real de mandrilamento, para que um PC novo consiga cronometrar algo sem uma hora de digitação antes. Renomeie, edite ou exclua o que quiser — é conteúdo comum de catálogo, não é fixo. Junto vêm dois subtipos, *Tool Setup/Change* e *Inspection*, porque as operações que precisam deles não estão entre os sete desperdícios.

A lista inicial **não traz tempos de referência**, de propósito: um padrão que ninguém mediu entraria nos cálculos de eficiência e nos alertas de ritmo como se significasse algo. Cadastre os seus tempos reais uma vez, aqui, e todo estudo futuro tira uma cópia deles.

Se você esvaziar o catálogo de propósito, o Chronus não o preenche de novo na versão seguinte — a oferta é feita uma única vez.

![Tela do Catálogo](manual/images/catalog-pt.png)

Cada item tem **nome**, **categoria** (e subtipo, se for improdutivo) e um **tempo de referência** opcional. Os botões no topo filtram por categoria. O botão **+** cria um item; o menu **⋮** de cada linha edita ou exclui.

A segunda linha de cada item mostra `Categoria · tempo de referência`. Um item sem tempo de referência mostra apenas a categoria.

---

## 6. A tela do estudo

Esta é a tela que você opera durante o estudo. É uma lista única — você monta a sequência, cronometra e corrige tudo no mesmo lugar.

![Tela do estudo](manual/images/workspace-pt.png)

| | |
|---|---|
| **1** | **Relatório** — abre a análise deste estudo |
| **2** | **Total** — tempo de relógio, do primeiro start ao último stop |
| **3** | **Conteúdo de trabalho** — a soma das operações; fica maior que o Total sempre que houve sobreposição |
| **4** | **Previsto** — o tempo planejado, somando os tempos de referência. A legenda aparece quando alguma operação não tem referência, porque aí o previsto está subestimado |
| **5** | **Progresso** — quantas operações já têm tempo |
| **6** | **Alça de arraste** — segure e arraste para reordenar a sequência |
| **7** | **Tempo de referência** — o padrão, se a operação tiver um |
| **8** | **Indicador de estado** — a cor é a categoria (âmbar preparação, verde produtivo, vermelho improdutivo); a marca mostra se já foi cronometrada |
| **9** | **Tempo observado** — o que foi realmente medido; âmbar perto do tempo de referência, vermelho depois de passar dele |
| **10** | **Iniciar** — começa a cronometrar esta operação, do zero |
| **11** | **Indicadores de nota e foto** — aparecem quando a linha tem algum dos dois |
| **12** | **Zerar** — descarta o tempo desta operação e volta a zero (pede confirmação) |
| **13** | **Menu da linha** — editar, duplicar, excluir, informar o tempo real, adicionar nota ou foto |
| **14** | **manual** — marca um tempo que foi digitado, e não medido |
| **15** | **Adicionar operação** — escolha do catálogo ou crie na hora |

**Total e Previsto não devem ser subtraídos um do outro.** O Total é um tempo de relógio e o Previsto é uma soma, então os dois só batem quando não houve sobreposição nem intervalos. Compare o **Conteúdo de trabalho** com o **Previsto** — os dois são somas, e aí a comparação vale.

### Controles de cronometragem

Cada operação tem o **seu próprio cronômetro independente**. Não existe um cronômetro mestre único.

- **▶ Iniciar** — começa a cronometrar, do zero.
- **⏸ Pausar** — para o cronômetro mas mantém o tempo já decorrido. Ao retomar, abre um novo trecho. O Chronus também oferece registrar a interrupção como uma operação improdutiva separada, que costuma ser o que você quer.
- **⏹ Parar** — marca a operação como concluída.
- **↺ Zerar** — descarta a medição e volta a linha para zero. Pede confirmação.

Como cada cronômetro é independente, você pode **rodar vários ao mesmo tempo**. Inicie o ciclo da máquina e inicie "operador aguardando" junto — os dois correm, e a sobreposição é medida e reportada.

### Cronometrando pelo teclado

No Windows dá para conduzir um estudo inteiro sem tocar no mouse, o que importa quando você está de pé ao lado da máquina com uma prancheta na mão.

| Tecla | O que faz |
|---|---|
| **Espaço** | **A tecla de volta.** Para a operação que está rodando e inicia a próxima, sem intervalo entre as duas. Se nada estiver rodando, inicia a primeira operação ainda não cronometrada |
| **↑ ↓** | Escolher a linha |
| **Enter** | Iniciar ou pausar a linha escolhida |
| **S** | Parar a linha escolhida |
| **Esc** | Desmarcar a linha escolhida |

**O Espaço é a tecla que vale aprender.** Uma sequência medida em sequência contínua — em que cada operação começa no instante em que a anterior termina — vira uma tecla por operação e não gera nenhum tempo não atribuído. Você não precisa escolher a linha antes: sem nada rodando, o Espaço acha sozinho a primeira operação ainda sem tempo.

**Com duas ou mais operações rodando ao mesmo tempo, o Espaço não faz nada, de propósito.** Qual delas é a "atual" fica realmente ambíguo, e parar o cronômetro do operador errado estragaria a medição. Escolha a linha com **↑ ↓** e aperte **Enter** ou **S**.

Aperte **F1** a qualquer momento para ver essa lista na tela — há também um ícone de teclado na barra superior, porque um atalho que ninguém sabe que existe é o mesmo que não existir.

### Alertas de ritmo

Quando a operação tem um tempo de referência, o Chronus acompanha o cronômetro contra ele.

- O tempo observado (**9**) fica **âmbar** quando se aproxima da referência e **vermelho** depois de passar dela. A cor permanece, então dá para varrer um estudo concluído e achar os estouros de olho.
- Um som de **duas notas subindo** toca quando a operação se aproxima da referência; um de **duas notas descendo** toca quando ela passa.

O aviso vem um décimo do tempo de referência antes do fim, e nunca mais de 30 segundos antes. Uma operação de 40 segundos avisa aos 36; uma de duas horas avisa em 1:59:30. É um aviso de *prepare-se para apertar stop*, não um aviso de atraso de cronograma.

Cada som toca **uma vez**. Pausar e retomar não repete, e sair da tela e voltar também não — só o **↺ Zerar**, que descarta o tempo de qualquer forma, rearma a operação. Operações sem tempo de referência nunca ganham cor e nunca emitem som.

Para desligar os sons, use **Configurações → Alertas sonoros**. As cores continuam funcionando, então mesmo sem som os estouros aparecem.

### Cronometrando mais de uma operação ao mesmo tempo

É para este caso que o Chronus existe. Suponha que a máquina roda por 90 segundos e o operador fica parado durante 50 deles:

1. Aperte **▶** em *Acabamento — cavidade*.
2. Aperte **▶** em *Espera — recuperação do fluido* também. As duas estão rodando.
3. Aperte **⏹** na espera quando o operador voltar a trabalhar.
4. Aperte **⏹** no acabamento quando o ciclo terminar.

Os dois tempos são registrados por inteiro, e os 50 segundos em comum aparecem como **Simultâneo**.

### Digitando um tempo manualmente

Se você esqueceu de apertar o start, ou está transcrevendo um estudo feito no papel, use **Informar tempo real** no menu da linha (**13**).

Um tempo digitado **encobre** a medição em vez de apagá-la — os trechos que você chegou a registrar continuam guardados por baixo. Se você limpar o valor manual, o tempo medido volta. Linhas com tempo digitado recebem a marca **manual** (**14**), e o relatório as desenha hachuradas para que ninguém as confunda com evidência medida.

---

## 7. Exemplo prático: um ciclo de suporte

Todas as imagens deste manual vêm do mesmo estudo, para você poder acompanhar do começo ao fim. É um ciclo de usinagem de suporte numa Haas VF-2, e é propositalmente bagunçado — contém todos os casos complicados que você vai encontrar na prática.

**Preparando**

1. Em **Projetos**, crie *Célula 4 — linha de suportes* e abra.
2. Adicione um estudo com o nome *Célula 4 — suporte A, referência*. O analista já vem preenchido das Configurações.
3. Preencha o cabeçalho: peça, máquina, operador, turno, ordem de produção. Todos opcionais, todos impressos no relatório.
4. Aperte **Adicionar operação** (**15**) sete vezes, escolhendo cada uma do catálogo.

**Executando**

5. **▶** *Carregar bloco no dispositivo*, **⏹** em 42,0 s. A referência é 40,0 s — ficou um pouco acima.
6. **▶** *Desbaste — faceamento*, **⏹** em 1:46,0.
7. **▶** *Acabamento — cavidade*. No meio do corte o operador para para retirar cavaco: **⏸**, e **▶** de novo 20 s depois. Os dois trechos somam 2:08,0.
8. Com a fresa ainda rodando, **▶** *Espera — recuperação do fluido* — o operador está parado esperando a bomba. **⏹** em 50,0 s. **Isso rodou ao mesmo tempo que o acabamento.**
9. Por meio minuto nada acontece — ninguém aperta nada. Esse intervalo vira tempo **não atribuído**.
10. **▶** *Rebarbar arestas*, **⏹** em 50,0 s.
11. *Inspeção — CMM*: o cronômetro nunca foi iniciado. Menu da linha → **Informar tempo real** → `1:30`. Recebe a marca **manual**.
12. *Preparar próxima célula*: nunca cronometrado, digitado como 45,0 s.

**Lendo o resultado**

13. Aperte o botão **Relatório** (**1**). Tudo o que está na seção 8 vem desses doze passos.

---

## 8. O relatório

Somente leitura. A cronometragem acontece na tela do estudo; esta tela apenas apresenta o resultado.

![Tela do relatório](manual/images/report-pt.png)

| | |
|---|---|
| **1** | **Exportar** — PDF ou XLSX (ver seção 15) |
| **2** | **Tempo total** — do primeiro start ao último stop. Aqui **6:30,0** |
| **3** | **Conteúdo de trabalho** — a soma do tempo de todas as operações. Aqui **8:31,0** |
| **4** | **Simultâneo** — tempo com duas ou mais operações rodando juntas. Aqui **30,0 s** |
| **5** | **Não atribuído** — tempo dentro do período que nenhuma operação cobre. Aqui **36,0 s** |
| **6** | **Índice de valor agregado** — parcela produtiva do conteúdo de trabalho. Aqui **82,0 %** |
| **7** | **Eficiência** — Σ referência ÷ Σ observado, nas operações que têm os dois. Aqui **153 %** |
| **8** | **Distribuição por categoria** — preparação / produtivo / improdutivo, por conteúdo de trabalho |
| **9** | **Linha do tempo** — o Gantt em tempo de relógio (ver seção 9) |
| **10** | **Pareto de desperdícios** — tempo de desperdício por subtipo, do maior para o menor |
| **11** | **Operações** — observado, referência, eficiência, notas e contagem de fotos por linha |

Na tabela de operações a eficiência é colorida: verde de 100 % para cima, vermelho abaixo. *Carregar bloco* aparece com **95 %** em vermelho — 42,0 s observados contra um padrão de 40,0 s.

---

## 9. Como ler a linha do tempo

A linha do tempo é um **Gantt em tempo de relógio real**. O eixo horizontal é a hora do dia, não a ordem das operações. As linhas mantêm a ordem planejada para casar com a tabela de operações.

![Detalhe da linha do tempo](manual/images/gantt-pt.png)

| | |
|---|---|
| **1** | **Eixo de relógio** — horas reais. Um estudo sem nenhuma cronometragem ao vivo mantém um eixo relativo `0:00…` |
| **2** | **Vão dentro de uma linha** — a operação foi pausada e retomada |
| **3** | **Duas linhas sobrepostas no tempo** — simultaneidade. A espera do fluido rodou durante o acabamento |
| **4** | **Espaço em branco entre barras** — tempo morto não atribuído, sem nenhuma operação |
| **5** | **Preenchimento sólido** — respaldado por um trecho realmente medido |
| **6** | **Preenchimento hachurado** — reportado mas *não* medido, ou seja, tempo digitado |

A hachura é importante. A largura total de uma barra sempre corresponde ao tempo **reportado** da operação, para que o gráfico nunca discorde da tabela. Mas um tempo digitado maior que o medido se estende além da evidência, e essa extensão é desenhada hachurada. Quando você vir uma sobreposição envolvendo hachura, leia como *não verificada*, não como observada.

A hachura é feita de linhas diagonais em vez de um tom mais claro de propósito — um tom mais claro fica indistinguível do sólido quando o relatório é impresso em preto e branco.

---

## 10. Por que os números não fecham

Esta é de longe a dúvida mais comum, e os números não estão errados.

**O tempo total (6:30,0) é menor que o conteúdo de trabalho (8:31,0).**

O conteúdo de trabalho é a soma simples do tempo de todas as operações. Quando duas operações rodam ao mesmo tempo, essa soma conta o trecho compartilhado duas vezes. O tempo total é o período real no relógio, que conta uma vez só. Portanto:

> O conteúdo de trabalho **conta a sobreposição duas vezes**. O tempo total **nunca**.

Nunca some os tempos das operações para saber "quanto durou o trabalho" — para isso existe o **Tempo total**.

Os dois totais se reconciliam assim:

```
Tempo total = tempo coberto + tempo não atribuído
    6:30,0  =    5:54,0     +      36,0 s
```

- **Simultâneo (30,0 s)** é extraído dos intervalos realmente registrados, e não calculado como `trabalho − total`. Esse atalho só funciona num estudo sem intervalos vazios, e fica negativo assim que os vãos superam a sobreposição.
- **Não atribuído (36,0 s)** é tempo dentro do período que nenhuma operação reivindica. Um valor alto normalmente significa que alguém esqueceu de apertar o start.

**Eficiência de 153 % com uma operação em 95 %.** A eficiência agregada é `Σ referência ÷ Σ observado` entre todas as operações que têm os dois valores — não é a média das porcentagens. Poucas operações bem abaixo do padrão dominam o total.

---

## 11. Estudo por amostragem: várias tomadas

Uma leitura não é uma medição de um processo que se repete. Cronometre o mesmo ciclo cinco vezes e você terá cinco números diferentes — a pergunta é qual é o tempo real, e o quanto você tem certeza disso. Um **Estudo por Amostragem** é a mesma sequência medida várias vezes, com média, e com as estatísticas para dizer se você já mediu o suficiente.

Escolha **Tipo de estudo → Estudo por Amostragem** ao criar o estudo, ou mude depois na tela de edição. Todo o resto funciona exatamente como na seção 6: não há uma segunda forma de usar o cronômetro para aprender.

### A lista de tomadas

Abrir um Estudo por Amostragem mostra as **Tomadas**, não a tela de cronometragem.

Cada linha é uma passagem pela sequência: o número, quando foi cronometrada e quantas operações ela cobriu (*3 de 7 cronometradas*, ou *Nada cronometrado ainda*). **Nova tomada** cria mais uma. Toque em qualquer tomada para abrir nela a tela da seção 6 — sem mudança nenhuma, incluindo o Espaço e os alertas de ritmo.

Um Estudo de Tempo é a mesma coisa com uma tomada só, então ele pula esta tela e abre direto a tela de cronometragem.

**Os números das tomadas nunca são reaproveitados nem renumerados.** *Tomada 4* num arquivo exportado, ou anotada num papel, significa a mesma tomada para sempre. Se você apagar uma tomada, a lista mostra a lacuna em vez de fechá-la silenciosamente.

### Editando a sequência no meio do caminho

Você pode acrescentar, remover e reordenar operações a qualquer momento, inclusive depois de já ter tomadas cronometradas — uma medição ao longo de um turno inteiro certamente vai encontrar uma interrupção que precisa ser registrada, e recusar o registro empurraria esse tempo para *não atribuído*, que é exatamente onde tempo morto atribuível não deve ficar.

- Uma operação acrescentada na tomada 4 simplesmente tem menos leituras que as vizinhas. O relatório mostra o **n de cada operação**, então a cobertura parcial fica visível em vez de ter que ser deduzida.
- **Excluir** uma operação avisa quantas tomadas perdem medições, porque isso remove a evidência daquela linha de todas as tomadas, não só da que você está.
- Uma operação marcada como **não planejada** aparece com as estatísticas dela, mas fica fora do veredito do estudo. Uma interrupção cronometrada uma única vez travaria o estudo em "não adequado" para sempre, por causa de uma linha que não faz parte da sequência padrão.

### Descartando uma leitura ruim, ou uma tomada ruim

A cronoanálise descarta leituras anômalas antes de tirar a média. O Chronus permite fazer isso de forma explícita, e as regras são as mesmas nos dois níveis: **excluir é reversível, tem motivo registrado e nunca é automático.**

- **Uma leitura** — na matriz de leituras do relatório de amostragem (seção 12), **Excluir esta leitura**.
- **Uma tomada inteira** — no menu da linha, na lista de tomadas, **Excluir das estatísticas**. Use quando a tomada em si foi ruim: a linha ficou sem material, o operador estava em treinamento. Aceita um motivo opcional, e a linha ganha a tarja **Excluída**.

> **Excluir não é apagar.** A medição continua no banco de dados, continua no relatório da própria tomada — a tomada realmente levou aquele tempo — e continua na planilha **Segments** de uma exportação. Ela só fica fora da média, do desvio, do CV e do veredito de tamanho da amostra. **Voltar para as estatísticas** desfaz isso quando você quiser.

O relatório sempre informa quantas leituras foram excluídas, para que uma média nunca se apoie discretamente numa amostra menor do que parece.

**O Chronus nunca exclui nada por conta própria.** Não existe regra automática de outlier, porque com amostras desse tamanho a regra dos livros não funciona — um único ponto fora infla o desvio padrão o suficiente para se trazer de volta para dentro do limite, então com cinco tomadas ela normalmente não exclui nada, e quando dispara muda números que você não aprovou. Só você sabe se um ciclo longo foi legítimo.

**Apagar uma tomada** é recusado enquanto ela tiver medições — o aplicativo sugere excluí-la das estatísticas, o que preserva a evidência. Uma tomada vazia é apagada sem discussão, e um estudo mantém sempre pelo menos uma.

**Relatório desta tomada**, no menu da linha, abre o relatório completo da seção 8 só daquela tomada: os cartões de resumo, a linha do tempo, tudo. Uma tomada isolada *é* um estudo de tempo. É assim que você explica um valor fora da curva — o que rodava junto, onde houve pausa — **antes** de decidir excluí-lo, e não depois.

---

## 12. O relatório de amostragem

O botão de relatório na barra superior de um Estudo por Amostragem abre este, em vez do da seção 8. Ele responde a duas perguntas: *qual é o tempo* e *já medi o suficiente*.

Ele é só agregado. Aqui **não há linha do tempo, nem tempo total, nem simultâneo, nem não atribuído** — de propósito. Essas grandezas descrevem uma passagem do cronômetro, e somá-las ou tirar média entre tomadas produz números que não descrevem nada. Elas ficam no relatório de cada tomada (seção 11).

### O veredito

No topo, em palavras:

| O que aparece | O que significa |
|---|---|
| **Adequado — 6 necessárias** | Você já fez tomadas suficientes para a precisão que pediu |
| **Não adequado — faltam 4 tomadas** | Está faltando essa quantidade |
| **Ainda não há tomadas suficientes para julgar** | Alguma operação tem menos de duas leituras, então não há dispersão de onde extrapolar |
| **Nada cronometrado ainda** | Nenhuma operação tem leitura em nenhuma tomada |

Ao lado: os seus critérios (*95% de confiança · ±5%*), quantas tomadas você já fez e — quando está faltando — **Determinado por: _operação_**.

**Essa última linha é o ponto.** As tomadas são feitas pela sequência inteira; não dá para acrescentar tomadas para uma operação só. Então a operação que precisa de mais tomadas decide a resposta do estudo, e nomeá-la transforma o veredito em instrução — *mais quatro tomadas, e a Inspeção é quem precisa delas* — em vez de uma nota.

**Nunca cronometradas: _operações_** aparece separado, porque incompleto não é a mesma coisa que inadequado. Uma operação que ninguém cronometrou ainda é falta de cobertura, não reprovação num teste de precisão.

Os critérios são definidos por estudo, na tela de edição: **Nível de confiança** e **Precisão (± % da média)**. O padrão são os usuais 95% e ±5%.

### Estatísticas por operação

Uma linha por operação:

| Coluna | Significado |
|---|---|
| **n** | Quantas leituras entram na média |
| **Média** | O tempo representativo |
| **Amplitude** | Maior leitura menos a menor |
| **Desvio padrão** | Dispersão das leituras |
| **CV** | Desvio padrão como percentual da média — comparável entre uma operação de 5 segundos e uma de 5 minutos |
| **Necessárias** | Tomadas exigidas pelos seus critérios |

O **CV** é o número a observar. Um CV alto diz que a operação é inconsistente, o que normalmente é mais interessante que a média dela — uma operação inconsistente é uma que você melhora tornando-a repetível, antes de tentar torná-la mais rápida.

Acima da tabela, **Conteúdo de trabalho (tomada média)** e a **Eficiência** agregada descrevem a tomada média como um todo.

### A matriz de leituras

Operações nas linhas, tomadas nas colunas, para você ver os números reais por trás de cada média e identificar o valor estranho a olho.

- Uma leitura excluída aparece riscada e continua visível — é evidência, não erro.
- Uma leitura **digitada** em vez de medida vem marcada, e a quantidade delas é informada junto com as estatísticas. Tempos digitados entram na média: um estudo transcrito do papel não teria estatística nenhuma se não entrassem. Mas um desvio padrão sobre números digitados significa muito pouco, e você só pode saber disso se for avisado.
- Um espaço em branco significa que aquela tomada nunca cronometrou aquela operação. Não é zero — um zero seria uma medição.

Toque numa leitura para excluí-la ou trazê-la de volta.

---

## 13. Comparando estudos

A mudança funcionou? Abra um projeto e aperte **Comparar estudos** na barra superior, marque dois ou mais estudos, e o Chronus os coloca lado a lado.

Os estudos são relacionados **pelas operações de catálogo que têm em comum**. Uma operação criada na hora dentro de um estudo não tem com o que ser relacionada, e é por isso que montar a sequência a partir do catálogo (seção 5) é o que torna uma comparação possível depois.

**Estudos de Tempo e por Amostragem se misturam sem problema.** O Estudo de Tempo entra com a sua leitura única; o de Amostragem entra com a média.

### O que você recebe

Uma **tabela lado a lado** — uma coluna por estudo, do mais antigo para o mais novo, mais uma coluna de **Variação** — e um gráfico de **tendência** por operação ao longo do tempo.

Cada número carrega o que permite julgar se ele é confiável:

| Marca | Significado |
|---|---|
| **n = 6** | Quantas leituras sustentam o número |
| **○** | Leitura única, não é média |
| **x4 na sequência** | O número é o total de quatro ocorrências daquela operação numa tomada |
| *em branco* | Aquele estudo nunca cronometrou esta operação |

**Por que o n aparece em cada célula.** "O cordão de solda melhorou 6% desde março" soa como uma conclusão até você notar que março foi um único aperto de cronômetro. Uma média de seis tomadas e uma leitura só são, de resto, o mesmo número na mesma coluna.

**Por que as ocorrências são somadas, e não tiradas em média.** Um ciclo de mandrilamento que inspeciona depois de cada passe de ferramenta tem quatro inspeções numa tomada. A célula mostra o *conteúdo de inspeção de uma tomada* — as quatro somadas — porque é esse número que muda quando o processo melhora. Tirar a média das ocorrências reportaria **nenhuma mudança** num processo que passou de quatro inspeções para duas, que é exatamente a melhoria que você abriu esta tela para ver. A quantidade é mostrada para que uma operação repetida nunca seja confundida com uma operação lenta.

O nome e o tempo de referência da operação vêm do estudo **mais recente** da comparação: os nomes são copiados por estudo e legitimamente diferem, e "estamos cumprindo o padrão" se refere ao padrão que vale agora.

### O que ficou de fora

Abaixo da tabela, uma contagem explícita: **_n_ operações fora da comparação — sem vínculo com o catálogo**, com os nomes.

Isso é ostensivo de propósito. Uma comparação que omitisse silenciosamente um terço do conteúdo de trabalho seria pior que uma que admite a omissão — e este é o documento com maior chance de ser lido por alguém que não conduziu nenhum dos estudos. Só são listadas as operações que foram efetivamente cronometradas; uma que ninguém cronometrou não contribui de um jeito nem de outro.

Se nada puder ser relacionado, o Chronus diz isso em vez de mostrar uma tabela vazia.

---

## 14. Notas e fotos

Ambas se anexam a uma operação específica, pelo menu da linha (**13**).

- **Notas** — texto livre. Saem na coluna Notas do relatório e do PDF.
- **Fotos** — tire uma com a câmera ou escolha um arquivo existente. Ficam embutidas na exportação em PDF.

Quando a linha passa a ter uma das duas coisas, aparecem pequenos indicadores ao lado do nome (**11**), com a contagem no caso das fotos.

Em celular ou tablet, **Adicionar foto** oferece **Tirar foto** ou **Escolher da galeria**. No Windows abre uma janela de arquivos — o desktop não tem câmera.

As fotos são reduzidas na importação. Elas são documentação, não registro de arquivo, e imagens em resolução cheia deixariam o backup grande demais para enviar por e-mail.

---

## 15. Exportação

Por qualquer tela de relatório. Dois formatos, duas finalidades — o PDF é o que você entrega para alguém, o XLSX é o que você trabalha.

As durações são gravadas como segundos decimais, para se comportarem como números na planilha. Os nomes das abas permanecem em inglês independentemente do idioma do aplicativo, para que fórmulas construídas sobre uma exportação sobrevivam a uma troca de idioma. No Windows, a exportação abre uma janela para salvar o arquivo.

### Um estudo de tempo, ou uma tomada isolada

**PDF.** Cabeçalho do estudo, indicadores, distribuição por categoria, linha do tempo, Pareto de desperdícios, tabela de operações e as fotos anexadas. Layout fixo.

**XLSX:**

| Aba | Conteúdo |
|---|---|
| Summary | Os campos do cabeçalho e os totais |
| Operations | Uma linha por operação: observado, referência, eficiência |
| Segments | **Uma linha por intervalo medido** — a evidência bruta |

A aba **Segments** é a que você usa quando alguém questiona um resultado. Ela contém exatamente os intervalos que a linha do tempo desenha e dos quais o Simultâneo é calculado, então a sobreposição pode ser recalculada de forma independente e conferida contra os registros da máquina. Tempo digitado fica deliberadamente de fora — um número digitado não é uma medição.

### Um estudo por amostragem

**Uma planilha para o estudo inteiro**, com todas as tomadas, uma linha por fato:

| Aba | Conteúdo |
|---|---|
| Summary | Cabeçalho, os seus critérios, o veredito e a operação determinante |
| Statistics | Uma linha por operação — n, média, mínimo, máximo, amplitude, desvio padrão, CV, tomadas necessárias |
| Observations | Uma linha por **tomada × operação** — a leitura, e se ela foi excluída ou digitada |
| Segments | Como acima, com uma coluna **Pass** na frente |

**A aba Observations é o que torna a média conferível.** Filtre por `Excluded = 0`, tire a média da coluna de segundos e você chega ao número que o aplicativo informa. As marcações são gravadas como `1` e `0`, não como palavras, para que a coluna possa ser filtrada e somada. Existe um teste no Chronus que faz exatamente essa conferência, porque a garantia se deterioraria em silêncio sem ele.

Dois detalhes que vale conhecer:

- Uma tomada que nunca cronometrou uma operação **não gera linha nenhuma**. Um zero seria uma medição e um espaço em branco seria uma leitura; a ausência é a única forma honesta de dizer "não foi cronometrado aqui".
- Uma **tomada excluída continua gerando as linhas de Segments**. A exclusão é uma afirmação sobre a média, não sobre se o cronômetro rodou.

A aba **Statistics** também traz o valor de `t` e os graus de liberdade, para você recolocá-los na fórmula de tamanho de amostra à mão e chegar na mesma resposta.

O **PDF** começa pelas seções agregadas e termina com **Tomadas em detalhe** — um apêndice com o resumo e a linha do tempo de cada tomada. Um arquivo para entregar, em vez de onze para um estudo de dez tomadas.

### Uma comparação

Pela tela de comparação (seção 13). Aqui os formatos também se dividem por finalidade:

- **PDF** — a matriz lado a lado, em paisagem, com o `n` e a contagem de ocorrências em cada número.
- **XLSX** — plano, uma linha por operação × estudo, com uma coluna **Occurrences**. As operações que ficaram de fora ganham uma aba **Unmatched** própria, em vez de uma observação no pé da planilha, porque uma observação no pé da planilha é a primeira coisa que se perde num filtro.

O arquivo é nomeado pelo **projeto** e datado de hoje, não por nenhum estudo dele — é uma leitura de vários estudos feita num momento, e datá-lo por um deles atribuiria a coisa errada.

---

## 16. Configurações, backup e restauração

![Tela de configurações](manual/images/settings-pt.png)

- **Idioma** — português, inglês ou espanhol. *Padrão do sistema* segue o Windows.
- **Analista padrão** — preenche automaticamente o campo Analista em estudos novos.
- **Unidade de tempo** — segundos ou minutos decimais.
- **Alertas sonoros** — os avisos de ritmo descritos na seção 6. Ligados por padrão; as cores âmbar/vermelho continuam mesmo com o som desligado.

### Duas redes de proteção, para duas falhas diferentes

Elas não são alternativas — protegem contra coisas diferentes, e só uma delas depende de você lembrar de algo.

| | **Fazer backup** (`.chronus`) | **Cópias automáticas** |
|---|---|---|
| Protege contra | perder a máquina | um defeito ou uma atualização ruim do Chronus |
| Contém | estudos **e fotos** | só os estudos |
| Acontece | quando você aperta o botão | sozinho, uma vez por dia, ao abrir |
| Sai deste PC | sim — é o objetivo | não |

### Fazendo backup

**Fazer backup** grava um único arquivo `.chronus` com todo o seu banco de dados e todas as fotos. Guarde-o em algum lugar que não seja este PC — uma pasta de rede, um pendrive, uma pasta do OneDrive.

Não há sincronização. Se o PC morrer e você não tiver um arquivo `.chronus` em outro lugar, os estudos se perdem — as cópias automáticas ficam no mesmo disco e não salvam desse caso. Num computador compartilhado de chão de fábrica, faça backup ao final de cada estudo.

### Cópias automáticas

O Chronus copia o banco de dados **uma vez por dia, sozinho**, e guarda as três últimas. Sem aviso, sem insistência, e isso nunca atrasa nem impede a abertura do aplicativo. Elas ficam listadas em **Configurações → Dados** com a data de cada uma, e restaurar uma pede confirmação do mesmo jeito que restaurar um backup.

**As fotos não entram, e não são alteradas ao restaurar uma cópia.** Fotos são gravadas uma vez e nunca modificadas, então não correm o risco contra o qual esta proteção existe — e manter três cópias da biblioteca de fotos custaria muito mais disco para proteger algo que nunca esteve em perigo. Na prática: se você voltar para ontem, uma foto adicionada hoje passa a ser um arquivo sem uso no disco, e uma que você apagou hoje aparece como miniatura quebrada. As duas situações são melhores que perder a biblioteca.

### Versão e diagnóstico

Também em **Configurações → Dados**:

- **Versão** — o rótulo da compilação, por exemplo `2026-07-29`. Cite isso ao relatar qualquer coisa; é o que identifica a sua cópia.
- **Salvar diagnóstico** — grava um arquivo de texto com o histórico recente do aplicativo: aberturas, se o banco de dados foi atualizado, se a cópia diária foi feita e os erros que houve. Envie junto com o relato de um problema e a maioria das dúvidas se responde sem adivinhação.
- **Enviar feedback** — anote com as suas palavras o que atrapalhou. Fica salvo localmente e vai junto com o arquivo de diagnóstico; nada é transmitido para lugar nenhum por conta própria.
- **Abrir pasta de dados** — abre `%APPDATA%\com.matheussancha\chronus`, onde ficam o banco de dados, as fotos e as cópias automáticas.

### Restaurando

**Restaurar** lê um arquivo `.chronus` de volta.

> **Restaurar substitui tudo.** Não é uma mesclagem. Todos os projetos, estudos e fotos que estiverem no aplicativo são descartados e substituídos pelo conteúdo do arquivo. Faça backup antes, se os dados atuais importarem.

O arquivo é validado antes de qualquer coisa ser alterada, então um arquivo corrompido ou recusado deixa o aplicativo exatamente como estava. Um backup de uma versão mais nova do Chronus é recusado em vez de lido pela metade; um mais antigo é atualizado automaticamente na importação.

É também assim que se leva dados de uma máquina para outra: faça backup num PC, copie o arquivo, restaure no outro.

---

## 17. Ainda não disponível

Esta é uma prévia interna. Os itens abaixo estão projetados mas ainda não disponíveis:

- **Anexos em vídeo** — fotos funcionam; vídeo não
- **Comparação entre projetos** — comparar estudos funciona dentro de um projeto (seção 13), não entre projetos
- **Faixas de confiança no gráfico de tendência** — a tendência mostra as médias, mas ainda não desenha o intervalo em volta delas, então "isso ficou mesmo mais rápido" continua sendo julgado a olho em vez de respondido
- **Versão para iPhone / iPad**

Tempos, categorias, tomadas, estatísticas, relatórios, comparações e exportações estão completos e podem ser usados com confiança.

---

## 18. Solução de problemas

**"O Windows protegeu o seu PC" ao iniciar.** Esperado — o programa não tem assinatura digital. **Mais informações → Executar assim mesmo**.

**Erro de DLL faltando ao iniciar.** Instale o [Microsoft Visual C++ Redistributable (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe) e tente de novo.

**O aplicativo abre mas não mostra nenhum projeto.** Os dados são por usuário do Windows. Se outra pessoa criou os estudos no login dela, você não vai vê-los — restaure a partir do backup `.chronus` dela.

**O conteúdo de trabalho está maior que o tempo total.** Comportamento correto. Ver seção 10.

**Uma operação mostra tempo mas a linha do tempo a desenha hachurada.** O tempo foi digitado, não medido. Ver seção 9.

**O tempo não atribuído está muito alto.** Alguém esqueceu de apertar o start, ou o estudo teve trechos longos que nunca foram atribuídos a nenhuma operação. Procure vãos largos na linha do tempo.

**Zerei uma operação sem querer.** A medição se perdeu — zerar descarta. Restaure o backup mais recente ou a cópia automática de ontem (seção 16), ou digite o tempo de novo manualmente.

**O Espaço não faz nada.** Ou há duas ou mais operações rodando ao mesmo tempo — escolha a linha e aperte **Enter** ou **S** (seção 6) — ou todas as operações já têm tempo.

**O relatório de amostragem diz "Ainda não há tomadas suficientes para julgar".** Alguma operação tem só uma leitura, e uma leitura não tem dispersão de onde extrapolar. Faça outra tomada.

**O relatório de amostragem não tem linha do tempo.** Correto — uma linha do tempo descreve uma passagem do cronômetro, então ela fica no relatório de cada tomada. Abra uma tomada na lista e use **Relatório desta tomada** (seção 11).

**Falta um estudo na comparação, ou falta uma operação.** Os estudos são relacionados pelas operações de catálogo que têm em comum (seção 13). Uma operação criada na hora dentro de um estudo não tem com o que ser relacionada — ela vai aparecer como *fora da comparação*. Monte as sequências a partir do catálogo para manter as comparações possíveis.

**A comparação mostra um tempo muito maior do que eu medi.** Verifique se há **x_n_ na sequência** embaixo do número: ele é o total daquela quantidade de ocorrências da operação numa tomada, não uma delas.

**Meus estudos desapareceram depois de uma atualização.** Configurações → Dados → **Cópias automáticas**, e restaure a de ontem. Depois use **Salvar diagnóstico** e envie o arquivo — é para essa falha que as cópias existem, e o log diz se o banco de dados foi atualizado na abertura.
