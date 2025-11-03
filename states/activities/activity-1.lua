local Gamestate = require 'lib.gamestate'
local json = require 'lib.json'
local session = require 'session'
local activity1 = {}
local Confetti = require 'states.confetti'

local animals = {
    {name = "cachorro", image = "assets/images/cachorro.png", syllables = 3},
    {name = "gato", image = "assets/images/gato.png", syllables = 2},
    {name = "elefante", image = "assets/images/elefante.png", syllables = 4},
    {name = "leão", image = "assets/images/leao.png", syllables = 2},
    {name = "tartaruga", image = "assets/images/tartaruga.png", syllables = 4},
    {name = "macaco", image = "assets/images/macaco.png", syllables = 3},
    {name = "borboleta", image = "assets/images/borboleta.png", syllables = 4},
    {name = "cavalo", image = "assets/images/cavalo.png", syllables = 3},
    {name = "peixe", image = "assets/images/peixe.png", syllables = 2},
    {name = "urso", image = "assets/images/urso.png", syllables = 2}
}

local animalPool = {}
local currentAnimal
local currentImage
local feedback = nil
local buttons = {}
local backBtn = {x = 20, y = 20, w = 100, h = 40}
local fim = false

-- Relatório
local acertos = 0
local erros = 0
local tentativas = 0
local tempoInicio = 0
local tempoFim = 0

local function nextAnimal()
    if #animalPool == 0 then
        fim = true
        currentAnimal = nil
        currentImage = nil
        tempoFim = love.timer.getTime()
        return
    end
    local idx = love.math.random(#animalPool)
    currentAnimal = animalPool[idx]
    table.remove(animalPool, idx)
    feedback = nil
    -- carrega imagem
    if love.filesystem.getInfo(currentAnimal.image) then
        currentImage = love.graphics.newImage(currentAnimal.image)
    else
        currentImage = nil
    end
end

function activity1:enter()
    -- Carrega o background
    if not background then
        background = love.graphics.newImage("/assets/images/fundoatividade1.png")
    end
    -- reinicia pool e estado
    animalPool = {}
    for i, v in ipairs(animals) do
        animalPool[i] = v
    end
    fim = false
    acertos = 0
    erros = 0
    tentativas = 0
    tempoInicio = love.timer.getTime()
    tempoFim = 0
    nextAnimal()
    -- Centraliza botões de sílabas na horizontal
    buttons = {}
    local btnW, btnH = 60, 60
    local totalW = 5 * btnW + 4 * 20 -- 5 botões, 20px de espaço entre eles
    local startX = (love.graphics.getWidth() - totalW) / 2
    local y = 400
    for i = 1, 5 do
        table.insert(buttons, {
            x = startX + (i-1)*(btnW + 20),
            y = y,
            w = btnW,
            h = btnH,
            number = i
        })
    end
    confetti = Confetti.new(300)
end

function activity1:draw()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    -- Adiciona o background
    if background then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(background, 0, 0, 0, screenW / background:getWidth(), screenH / background:getHeight())
    end

    if fim then
        local tempoGasto = math.floor((tempoFim - tempoInicio))
        -- Mensagem de finalização com fonte um pouco menor e espaçamento maior
        love.graphics.setFont(love.graphics.newFont(38))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Parabéns! Você terminou todas as palavras!", 0, screenH/2 - 140, screenW, "center")
        love.graphics.setFont(love.graphics.newFont(22))
        love.graphics.printf(
            "Relatório:\nAcertos: " .. acertos ..
            "\nErros: " .. erros ..
            "\nTentativas: " .. tentativas ..
            "\nTempo gasto: " .. tempoGasto .. " segundos",
            0, screenH/2, screenW, "center"
        )
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.setColor(1, 1, 1)
        return
    end

    -- Desenha imagem do animal centralizada e redimensionada
    if currentImage then
        local iw, ih = currentImage:getWidth(), currentImage:getHeight()
        local maxW, maxH = 250, 250
        local scale = math.min(maxW/iw, maxH/ih, 1)
        local imgX = (screenW - iw*scale)/2
        local imgY = 100
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(currentImage, imgX, imgY, 0, scale, scale)
    else
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Imagem não encontrada!", 0, 120, screenW, "center")
    end

    -- Desenha botões
    for _, btn in ipairs(buttons) do
        -- Botão preenchido branco
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h)
        -- Borda preta
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
        -- Número preto centralizado
        love.graphics.setFont(love.graphics.newFont(22))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(btn.number, btn.x, btn.y + 12, btn.w, "center")
        love.graphics.setColor(1, 1, 1)
    end

    -- Botão Voltar
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.w, backBtn.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Voltar", backBtn.x, backBtn.y + 10, backBtn.w, "center")
    love.graphics.setColor(1, 1, 1)

    -- Mostra feedback
    if feedback == "correct" then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("Acertou! Clique ou pressione espaço para o próximo.", screenW/2 - 180, 350, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1)
    elseif feedback == "wrong" then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("Tente de novo!", screenW/2 - 90, 350, 0, 2, 2)
        love.graphics.setColor(1, 1, 1)
    end

    if confetti then confetti:draw() end
end

function activity1:mousepressed(x, y, button)
    if button == 1 then
        -- Botão voltar
        if x > backBtn.x and x < backBtn.x + backBtn.w and y > backBtn.y and y < backBtn.y + backBtn.h then
            Gamestate.switch(require 'states.list-games')
            return
        end
        if fim then
            self:salvarRelatorio()
            Gamestate.switch(require 'states.list-games')
            return
        end
        if feedback == "correct" then
            nextAnimal()
            return
        end
        -- Botões de sílabas
        for _, btn in ipairs(buttons) do
            if x > btn.x and x < btn.x + btn.w and y > btn.y and y < btn.y + btn.h then
                tentativas = tentativas + 1
                if btn.number == currentAnimal.syllables then
                    feedback = "correct"
                    acertos = acertos + 1
                    confetti:spawn(love.graphics.getWidth()/2, love.graphics.getHeight()/2, 120)
                else
                    feedback = "wrong"
                    erros = erros + 1
                end
            end
        end
    end
end

function activity1:keypressed(key)
    if key == "escape" then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            love.window.setMode(800, 600, {resizable = true})
        else
            Gamestate.switch(require 'states.list-games')
        end
    elseif key == "space" and feedback == "correct" and not fim then
        nextAnimal()
    elseif key == "space" and fim then
        self:salvarRelatorio()
        Gamestate.switch(require 'states.list-games')
    end
end

function activity1:update(dt)
    if confetti then confetti:update(dt) end
end

function activity1:salvarRelatorio()
    local tempoGasto = math.floor((tempoFim - tempoInicio))
    local relatorio = {
        aluno_id = session.aluno and session.aluno.id or nil,
        aluno_nome = session.aluno and session.aluno.nome or nil,
        acertos = acertos,
        erros = erros,
        tentativas = tentativas,
        tempo = tempoGasto,
        data = os.date("%Y-%m-%d %H:%M:%S")
    }

    local relatorios = {}
    if love.filesystem.getInfo("relatorios.json") then
        local conteudo = love.filesystem.read("relatorios.json")
        relatorios = json.decode(conteudo) or {}
    end
    table.insert(relatorios, relatorio)
    local dados = json.encode(relatorios, { indent = true })
    love.filesystem.write("relatorios.json", dados)
end

function Confetti:spawn(x, y, count)
    count = count or 100
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    self.ps:setPosition(x or screenW/2, y or screenH/2) -- centro da tela
    self.ps:setLinearAcceleration(-300, -300, 300, 300) -- espalha para todos os lados
    self.ps:emit(count)
end

return activity1