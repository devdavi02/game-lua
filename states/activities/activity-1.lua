local Gamestate = require 'lib.gamestate'
local json = require 'lib.json'
local session = require 'session'
local activity1 = {}
local Confetti = require 'states.confetti'

-- Adicionei campo 'sound' em cada animal (coloque seus arquivos de áudio em assets/sounds/)
local animals = {
    {name = "cachorro", image = "assets/images/cachorro.png", sound = "assets/sounds/cachorro.ogg", syllables = 3},
    {name = "gato", image = "assets/images/gato.png", sound = "assets/sounds/gato.ogg", syllables = 2},
    {name = "elefante", image = "assets/images/elefante.png", sound = "assets/sounds/elefante.ogg", syllables = 4},
    {name = "leão", image = "assets/images/leao.png", sound = "assets/sounds/leao.ogg", syllables = 2},
    {name = "tartaruga", image = "assets/images/tartaruga.png", sound = "assets/sounds/tartaruga.ogg", syllables = 4},
    {name = "macaco", image = "assets/images/macaco.png", sound = "assets/sounds/macaco.ogg", syllables = 3},
    {name = "borboleta", image = "assets/images/borboleta.png", sound = "assets/sounds/borboleta.ogg", syllables = 4},
    {name = "cavalo", image = "assets/images/cavalo.png", sound = "assets/sounds/cavalo.ogg", syllables = 3},
    {name = "peixe", image = "assets/images/peixe.png", sound = "assets/sounds/peixe.ogg", syllables = 2},
    {name = "urso", image = "assets/images/urso.png", sound = "assets/sounds/urso.ogg", syllables = 2}
}

local animalPool = {}
local currentAnimal
local currentImage
local currentSound -- source atual
local feedback = nil
local buttons = {}
local playBtn = {x = 0, y = 0, w = 60, h = 60} -- botão de play (posição atualizada em draw)
local fim = false
local isPlaying = false

-- Relatório
local acertos = 0
local erros = 0
local tentativas = 0
local tempoInicio = 0
local tempoFim = 0

local function loadCurrentAssets()
    -- carrega imagem
    if currentAnimal and currentAnimal.image and love.filesystem.getInfo(currentAnimal.image) then
        currentImage = love.graphics.newImage(currentAnimal.image)
    else
        currentImage = nil
    end
    -- carrega som (parando som anterior)
    if currentSound then
        pcall(function() currentSound:stop() end)
        currentSound = nil
    end
    if currentAnimal and currentAnimal.sound and love.filesystem.getInfo(currentAnimal.sound) then
        currentSound = love.audio.newSource(currentAnimal.sound, "static")
    else
        currentSound = nil
    end

    -- reseta estado do botão play
    isPlaying = false
end

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
    loadCurrentAssets()
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

        -- Caixa de destaque atrás do título e relatório
        local boxW = math.min(800, screenW - 80)
        local boxH = 220
        local boxX = (screenW - boxW) / 2
        local boxY = screenH/2 - 160
        love.graphics.setColor(1,1,1,0.95) -- fundo branco semitransparente
        love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 12, 12)
        love.graphics.setColor(0,0,0) -- borda preta
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 12, 12)

        -- Texto sobre a caixa
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Parabéns! Você terminou todas as palavras!", boxX, boxY + 16, boxW, "center")
        love.graphics.setFont(love.graphics.newFont(22))
        love.graphics.printf(
            "Relatório:\nAcertos: " .. acertos ..
            "\nErros: " .. erros ..
            "\nTentativas: " .. tentativas ..
            "\nTempo gasto: " .. tempoGasto .. " segundos",
            boxX + 20, boxY + 80, boxW - 40, "left"
        )

        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.setColor(1, 1, 1)
        return
    end

    -- Desenha imagem do animal centralizada e redimensionada
    local imgX, imgY, imgWscaled, imgHscaled = 0,0,0,0
    if currentImage then
        local iw, ih = currentImage:getWidth(), currentImage:getHeight()
        local maxW, maxH = 250, 250
        local scale = math.min(maxW/iw, maxH/ih, 1)
        imgWscaled = iw * scale
        imgHscaled = ih * scale
        imgX = (screenW - imgWscaled)/2 - 120 -- ajustei para dar espaço ao lado esquerdo para o botão (altere se desejar)
        imgY = 100
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(currentImage, imgX, imgY, 0, scale, scale)
    else
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Imagem não encontrada!", 0, 120, screenW, "center")
    end

    -- Desenha botão Play ao lado direito da imagem
    local playX, playY = 0, 0
    playBtn.w, playBtn.h = 60, 60
    if imgWscaled > 0 then
        playX = imgX + imgWscaled + 20
        playY = imgY + (imgHscaled - playBtn.h)/2
    else
        playX = screenW/2 + 150
        playY = 200
    end
    playBtn.x, playBtn.y = playX, playY

    -- desenha botão
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", playBtn.x, playBtn.y, playBtn.w, playBtn.h, 8, 8)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", playBtn.x, playBtn.y, playBtn.w, playBtn.h, 8, 8)

    -- desenha ícone de "play" ou "pause"
    love.graphics.setColor(0,0,0)
    if isPlaying then
        -- pause icon (duas barras)
        local pad = playBtn.w * 0.18
        local barW = playBtn.w * 0.18
        local barH = playBtn.h * 0.56
        local bx = playBtn.x + (playBtn.w - (2*barW + pad)) / 2
        local by = playBtn.y + (playBtn.h - barH) / 2
        love.graphics.rectangle("fill", bx, by, barW, barH, 3, 3)
        love.graphics.rectangle("fill", bx + barW + pad, by, barW, barH, 3, 3)
    else
        -- play triangle
        local px = playBtn.x + playBtn.w*0.35
        local py = playBtn.y + playBtn.h*0.25
        local pw = playBtn.w*0.4
        local ph = playBtn.h*0.5
        love.graphics.polygon("fill", px, py, px, py+ph, px+pw, py+ph/2)
    end
    love.graphics.setColor(1,1,1)

    -- Desenha botões de sílabas
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

    -- Retângulo de destaque atrás do feedback (se houver)
    if feedback then
        local fbW, fbH = math.min(600, screenW - 120), 64
        local fbX = (screenW - fbW) / 2
        local fbY = 340
        love.graphics.setColor(1,1,1,0.95)
        love.graphics.rectangle("fill", fbX, fbY, fbW, fbH, 10, 10)
        love.graphics.setColor(0,0,0)
        love.graphics.setLineWidth(1.5)
        love.graphics.rectangle("line", fbX, fbY, fbW, fbH, 10, 10)

        if feedback == "correct" then
            love.graphics.setColor(0,1,0)
            love.graphics.print("Acertou! Clique ou pressione espaço para o próximo.", fbX + 16, fbY + 12, 0, 1.2, 1.2)
        elseif feedback == "wrong" then
            love.graphics.setColor(1,0,0)
            love.graphics.print("Tente de novo!", fbX + 16, fbY + 14, 0, 1.4, 1.4)
        end
        love.graphics.setColor(1,1,1)
    end

    if confetti then confetti:draw() end
end

function activity1:mousepressed(x, y, button)
    if button == 1 then
        -- clique no play?
        if x > playBtn.x and x < playBtn.x + playBtn.w and y > playBtn.y and y < playBtn.y + playBtn.h then
            if currentSound then
                pcall(function()
                    if currentSound:isPlaying() then
                        currentSound:pause()
                        isPlaying = false
                    else
                        -- se estava pausado ou parado, tocar (reinicia para o começo)
                        currentSound:stop()
                        currentSound:play()
                        isPlaying = true
                    end
                end)
            end
            return
        end

        -- Removed back button click handling (per request)

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
    -- atualiza estado do play (quando som terminar, atualiza isPlaying)
    if currentSound then
        isPlaying = currentSound:isPlaying()
    else
        isPlaying = false
    end
    -- ...existing code...
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