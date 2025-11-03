# 💖 Guia de Instalação e Primeiros Passos com LÖVE (Love2D)

LÖVE é um framework gratuito e de código-aberto que permite criar jogos 2D usando a linguagem de programação Lua. Este guia fornece instruções de instalação e execução para ambientes Windows e Linux.

---

## ✨ Introdução: O que é necessário para rodar um jogo LÖVE?

Para que qualquer jogo feito em LÖVE funcione, você só precisa de **duas coisas**:

1.  **O Framework LÖVE Instalado:** O LÖVE (também conhecido como Love2D) funciona como o "motor" ou "executor" do jogo. Ele interpreta os scripts Lua do seu projeto e os transforma em um jogo rodável. **A instalação do LÖVE é o pré-requisito principal.**
2.  **O Código do Jogo:** Um projeto LÖVE consiste em uma pasta (ou um arquivo `.love` compactado) que **deve obrigatoriamente** conter um arquivo chamado **`main.lua`** na sua raiz.

Se o jogo for distribuído como um arquivo `.love`, basta ter o LÖVE instalado e dar um duplo clique nele.

---

## 💻 1. Instalação do LÖVE

O LÖVE Framework já inclui a linguagem Lua, portanto, não é necessário instalar a Lua separadamente.

### 🪟 Windows

A instalação é feita através de um instalador executável:

1.  **Download:** Acesse o site oficial do LÖVE ([love2d.org](https://love2d.org/)).
2.  **Versão:** Baixe o **installer** para a versão `64-bit` (recomendado) ou `32-bit`.
3.  **Execução:** Execute o arquivo `.exe` e siga as instruções.
4.  **PATH:** O instalador deve adicionar o comando `love` ao seu PATH do sistema, permitindo que você o execute diretamente do terminal.

**Teste Rápido:**
Abra o **Prompt de Comando** (ou PowerShell) e execute:
```bash
love
