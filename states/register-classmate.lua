local Gamestate = require 'lib.gamestate'
local json = require 'lib.json'

local cadastroAluno = {}

local campos = {
    {label = "Nome", valor = "", foco = true},
    {label = "Idade", valor = "", foco = false}
}
local campoSelecionado = 1
local mensagem = ""
local backBtn = {x = 20, y = 20, w = 100, h = 40}
local salvarBtn = {x = 0, y = 0, w = 160, h = 50}
local arquivo = "alunos.json"
local background

function cadastroAluno:enter()
    if not background then
        background = love.graphics.newImage("/assets/images/background.png")
    end
    
    -- Centraliza botão salvar
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    salvarBtn.x = (screenW - salvarBtn.w) / 2
    salvarBtn.y = screenH - 100
    mensagem = ""
    for i, campo in ipairs(campos) do
        campo.valor = ""
        campo.foco = (i == 1)
    end
    campoSelecionado = 1
end

function cadastroAluno:draw()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    if background then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(background, 0, 0, 0, screenW / background:getWidth(), screenH / background:getHeight())
    end
    
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Cadastro de Aluno", 0, 60, screenW, "center")

    love.graphics.setFont(love.graphics.newFont(22))
    for i, campo in ipairs(campos) do
        local y = 170 + (i-1)*70
        love.graphics.setColor(0,0,0)
        love.graphics.print(campo.label .. ":", 120, y)
        if campo.foco then
            love.graphics.setColor(0.2, 0.6, 1)
            love.graphics.rectangle("line", 300, y-5, 350, 40, 8, 8)
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.rectangle("line", 300, y-5, 350, 40, 8, 8)
        end
        love.graphics.setColor(0,0,0)
        love.graphics.print(campo.valor, 310, y)
    end

    -- Botão Salvar
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", salvarBtn.x, salvarBtn.y, salvarBtn.w, salvarBtn.h, 10, 10)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Salvar", salvarBtn.x, salvarBtn.y + 12, salvarBtn.w, "center")

    -- Botão Voltar
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.w, backBtn.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Voltar", backBtn.x, backBtn.y + 10, backBtn.w, "center")
    love.graphics.setColor(1, 1, 1)

    -- Mensagem
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.setColor(0,0,0)
    love.graphics.printf(mensagem, 0, salvarBtn.y + 60, screenW, "center")
    love.graphics.setColor(1,1,1)
end

function cadastroAluno:textinput(t)
    local campo = campos[campoSelecionado]
    campo.valor = campo.valor .. t
end

function cadastroAluno:keypressed(key)
    if key == "tab" then
        campos[campoSelecionado].foco = false
        campoSelecionado = campoSelecionado % #campos + 1
        campos[campoSelecionado].foco = true
    elseif key == "return" or key == "kpenter" then
        self:salvarAluno()
    elseif key == "backspace" then
        local campo = campos[campoSelecionado]
        campo.valor = campo.valor:sub(1, -2)
    elseif key == "escape" then
        Gamestate.switch(require 'states.menu')
    end
end

function cadastroAluno:mousepressed(x, y, button)
    if button == 1 then
        -- Botão Voltar
        if x > backBtn.x and x < backBtn.x + backBtn.w and y > backBtn.y and y < backBtn.y + backBtn.h then
            Gamestate.switch(require 'states.menu')
            return
        end
        -- Botão Salvar
        if x > salvarBtn.x and x < salvarBtn.x + salvarBtn.w and y > salvarBtn.y and y < salvarBtn.y + salvarBtn.h then
            self:salvarAluno()
            return
        end
        -- Seleciona campo pelo clique
        for i, campo in ipairs(campos) do
            local yCampo = 170 + (i-1)*70
            if x > 300 and x < 650 and y > yCampo-5 and y < yCampo+35 then
                campos[campoSelecionado].foco = false
                campoSelecionado = i
                campo.foco = true
            end
        end
    end
end

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function cadastroAluno:salvarAluno()
    -- Validação simples (pode ser expandida)
    for _, campo in ipairs(campos) do
        if trim(campo.valor) == "" then
            mensagem = "Preencha todos os campos!"
            return
        end
    end

    local novoNome = trim(campos[1].valor):lower()

    -- Carrega alunos existentes
    local alunos = {}
    if love.filesystem.getInfo(arquivo) then
        local conteudo = love.filesystem.read(arquivo)
        alunos = json.decode(conteudo) or {}
    end

    -- Verifica se já existe aluno com mesmo nome (case-insensitive)
    for _, a in ipairs(alunos) do
        if a.nome and trim(tostring(a.nome)):lower() == novoNome then
            mensagem = "Nome já cadastrado!"
            return
        end
    end

    -- Gera novo id (incremental)
    local novoId = 1
    if #alunos > 0 then
        for _, aluno in ipairs(alunos) do
            if aluno.id and aluno.id >= novoId then
                novoId = aluno.id + 1
            end
        end
    end

    -- Cria novo objeto aluno
    local novoAluno = {
        id = novoId,
        nome = trim(campos[1].valor),
        idade = trim(campos[2].valor)
    }
    table.insert(alunos, novoAluno)

    -- Salva no arquivo
    local dados = json.encode(alunos, { indent = true })
    love.filesystem.write(arquivo, dados)
    if love.filesystem.getInfo(arquivo) then
        -- cadastro ok: limpa campos e volta ao menu
        mensagem = "Aluno cadastrado com sucesso!"
        for i, campo in ipairs(campos) do
            campo.valor = ""
        end
        campos[1].foco = true
        campoSelecionado = 1
        Gamestate.switch(require 'states.menu')
    else
        mensagem = "Erro ao criar o arquivo de alunos!"
    end
end

print(love.filesystem.getSaveDirectory())

return cadastroAluno