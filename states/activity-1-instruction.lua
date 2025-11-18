local Gamestate = require 'lib.gamestate'

local instructions = {}

local backBtn = {x = 20, y = 20, w = 100, h = 40}
local continueBtn = {x = 0, y = 0, w = 220, h = 56}
local background

local lines = {
    "Como jogar:",
    "- Observe a imagem do animal.",
    "- Clique no botão de play para ouvir o som do nome do animal.",
    "- Selecione o número de sílabas correspondentes.",
    "- Ao acertar, avance para o próximo animal.",
    "Pressione Iniciar para começar."
}

local function drawTextOutline(text, x, y, font, color, outlineColor)
    font = font or love.graphics.getFont()
    love.graphics.setFont(font)
    outlineColor = outlineColor or {0,0,0,1}
    color = color or {1,1,1,1}
    love.graphics.setColor(outlineColor)
    for dx = -1,1 do
        for dy = -1,1 do
            if dx ~= 0 or dy ~= 0 then
                love.graphics.print(text, x + dx, y + dy)
            end
        end
    end
    love.graphics.setColor(color)
    love.graphics.print(text, x, y)
end

function instructions:enter()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    continueBtn.x = (screenW - continueBtn.w) / 2
    continueBtn.y = screenH - 140

    if not background and love.filesystem.getInfo("/assets/images/fundoatividade1.png") then
        background = love.graphics.newImage("/assets/images/fundoatividade1.png")
    end
end

function instructions:draw()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

    if background then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(background, 0, 0, 0, screenW / background:getWidth(), screenH / background:getHeight())
    else
        love.graphics.clear(1,1,1)
    end

    love.graphics.setFont(love.graphics.newFont(34))
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Instruções", 0, 60, screenW, "center")

    love.graphics.setFont(love.graphics.newFont(20))
    local startY = 140
    for i, line in ipairs(lines) do
        local y = startY + (i-1) * 28
        drawTextOutline(line, 80, y, love.graphics.getFont(), {1,1,1,1}, {0,0,0,1})
    end

    -- botão Iniciar
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill", continueBtn.x, continueBtn.y, continueBtn.w, continueBtn.h, 10, 10)
    love.graphics.setColor(0,0,0)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Iniciar", continueBtn.x, continueBtn.y + 14, continueBtn.w, "center")

    -- botão Voltar
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.w, backBtn.h, 8, 8)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Voltar", backBtn.x, backBtn.y + 10, backBtn.w, "center")

    love.graphics.setColor(1,1,1)
end

function instructions:mousepressed(x, y, button)
    if button ~= 1 then return end

    -- Iniciar -> activity-1
    if x >= continueBtn.x and x <= continueBtn.x + continueBtn.w and y >= continueBtn.y and y <= continueBtn.y + continueBtn.h then
        Gamestate.switch(require 'states.activities.activity-1')
        return
    end

    -- Voltar -> list-games
    if x >= backBtn.x and x <= backBtn.x + backBtn.w and y >= backBtn.y and y <= backBtn.y + backBtn.h then
        Gamestate.switch(require 'states.list-games')
        return
    end
end

function instructions:keypressed(key)
    if key == "escape" then
        Gamestate.switch(require 'states.list-games')
    elseif key == "return" or key == "kpenter" then
        Gamestate.switch(require 'states.activities.activity-1')
    end
end

return instructions