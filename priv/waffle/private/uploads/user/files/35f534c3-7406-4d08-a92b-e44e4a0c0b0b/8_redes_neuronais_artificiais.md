Uma **Rede Neuronal Artificial** (RNA) é um sistema computacional de
base conexionista para a resolução de problemas. Uma RNA é concebida com
base num **modelo** simplificado do **sistema nervoso central** dos
seres humanos e é definida por uma estrutura interligada de unidades
computacionais, designadas **neurónios** com capacidade de
**aprendizagem**.

## Estrutura

#### Neurónio

-   **Unidade computacional** de composição do RNA;
-   Identificado pela sua **posição** na rede;
-   Caracterizado pelo **valor do estado**;

#### Axónio

-   **Via de comunicação** entre os neurónios;
-   Pode ligar **qualquer neurónio**, incluindo o próprio;
-   As ligações podem **variar** ao longo do **tempo**;
-   A informação circula em **um só sentido**;

#### Sinapse

-   **Ponto de ligação** entre axónios e neurónios;
-   O **valor da sinapse** determina o **peso** do sinal a entrar no
    neurónio;
-   A **variação no tempo determina a aprendizagem** da RNA;

#### Ativação

-   O valor de ativação é representado por **um único valor**;
-   O valor de ativação **varia com o tempo**;
-   A gama de valores varia com o modelo adotado;

#### Transferência

-   O valor de transferência de um neurónio determina o **valor** que é
    **colocado na saída** (transferido através do axónio);
-   É calculado como uma função do valor de ativação (eventualmente com
    algum efeito de memória);

![Regressão Linear](./images/neuronio.png)

## Organização dos Neurónios

#### Arquitetura Feedforward

Neste tipo de arquiteturas, os neurónios estão, tipicamente, organizadas
em múltiplas camadas (*Multilayer Perception*) ou em uma só camada
(*Perception*) e a informação circula em **um só sentido**.

As redes feedforward utilizam algoritmos de *backpropagation* para
estimar os erros que a rede está a produzir nos pesos das camadas
anteriores, **durante a fase de aprendizagem**.

#### Arquitetura Recorrente

Neste tipo de arquiteturas, os neurónios estão organizados de forma a
permitir **ciclos** na rede, permitindo a **retroalimentação** da
informação quer para neurónios da mesma camada quer para neurónios de
camadas anteriores.

As redes recorrentes distinguem-se das redes feedforward pelo ciclo que
trás as decisões anteriores até ao momento atual. Esta funcionalidade de
memória na rede tem a função de **captar a noção de tempo**.

O input é caracterizado por 2 partes: - Exemplo; - Perceção anterior;

A decisão que a SRN calculou na iteração anterior influenciará a decisão
a tomar na iteração atual. Isto traduz-se num efeito de ""memória" na
rede.

Arquiteturas Recorrentes são ótimas para quaisqueres problemas que
envolvam **sequências temporais**: - Reconhecimento de fala; - Previsão
em mercados financeiros; - Música e vídeo;

## Aprendizagem

O treino de uma RNA corresponde à **aplicação de regras de
aprendizagem**, de forma a fazer **variar os pesos das ligações**
(sinapses).

#### Supervisionada

O treino de RNA's com supervisão consiste em **apresentar exemplos** ao
sistema, **indicando a resposta correta**. O sistema compara a resposta
obtida com a resposta correta e **ajusta os pesos** de forma a
**minimizar o erro**.

#### Não Supervisionada

O treino de RNA's sem supervisão consiste em **apresentar exemplos** ao
sistema, **sem indicar a resposta correta**. O sistema **encontra
padrões** nos exemplos e **ajusta os pesos** de forma a **minimizar o
erro**.
