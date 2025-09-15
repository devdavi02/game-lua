local Gamestate = require 'lib.gamestate'
local activity1 = {}

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

local function nextAnimal()
    if #animalPool == 0 then
        fim = true
        currentAnimal = nil
        currentImage = nil
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
    -- reinicia pool e estado
    animalPool = {}
    for i, v in ipairs(animals) do
        animalPool[i] = v
    end
    fim = false
    nextAnimal()
    -- cria botões de sílabas (1 até 5)
    buttons = {}
    for i = 1, 5 do
        table.insert(buttons, {
            x = 100 + (i-1)*80,
            y = 400,
            w = 60,
            h = 60,
            number = i
        })
    end
end

function activity1:draw()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

    if fim then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Parabéns! Você terminou todas as palavras!", 0, screenH/2, screenW, "center")
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

    -- Nome do animal (opcional)
    -- love.graphics.setColor(0,0,0)
    -- love.graphics.printf(currentAnimal.name, 0, 80, screenW, "center")

    -- Desenha botões
    love.graphics.setColor(1, 1, 1)
    for _, btn in ipairs(buttons) do
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
        love.graphics.printf(btn.number, btn.x, btn.y + 20, btn.w, "center")
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
end

function activity1:mousepressed(x, y, button)
    if button == 1 then
        -- Botão voltar
        if x > backBtn.x and x < backBtn.x + backBtn.w and y > backBtn.y and y < backBtn.y + backBtn.h then
            Gamestate.switch(require 'states.list-games')
            return
        end
        if fim then
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
                if btn.number == currentAnimal.syllables then
                    feedback = "correct"
                else
                    feedback = "wrong"
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
    end
end

return activity1