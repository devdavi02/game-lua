local Gamestate = require 'lib.gamestate'
local activity1 = require 'states.activities.activity-1'
local activity1Instr = require 'states.activity-1-instruction'
local session = require 'session'

local listGames = {}

local games = {
    {label = "Jogo 1", hovered = false},
    {label = "Jogo 2", hovered = false}
}
local selected = 1
local dev_name = "Desenvolvedor: Seu Nome"
local backHovered = false

local background

function listGames:enter()
    -- Carregue a imagem de fundo (faça isso só uma vez)
    if not background then
        background = love.graphics.newImage("/assets/images/background.png")
    end
end

function listGames:draw()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    -- Desenha a imagem de fundo
    if background then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(background, 0, 0, 0, screenW / background:getWidth(), screenH / background:getHeight())
    end

    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("Escolha um Jogo", 0, 60, screenW, "center")

    -- Desenha os botões dos jogos centralizados verticalmente
    love.graphics.setFont(love.graphics.newFont(24))
    local btnW, btnH = 300, 50
    local spacing = 20
    local totalHeight = #games * btnH + (#games - 1) * spacing
    local startY = (screenH - totalHeight) / 2

    for i, game in ipairs(games) do
        local x = (screenW - btnW) / 2
        local y = startY + (i - 1) * (btnH + spacing)
        if i == selected or game.hovered then
            love.graphics.setColor(0.2, 0.6, 1)
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        love.graphics.rectangle("fill", x, y, btnW, btnH, 10, 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(game.label, x, y + 12, btnW, "center")
        love.graphics.setColor(1, 1, 1)
    end

    -- Botão Voltar na lateral esquerda
    local backBtnW, backBtnH = 120, 40
    local backBtnX, backBtnY = 30, screenH / 2 - backBtnH / 2
    if backHovered then
        love.graphics.setColor(0.2, 0.6, 1)
    else
        love.graphics.setColor(0.7, 0.7, 0.7)
    end
    love.graphics.rectangle("fill", backBtnX, backBtnY, backBtnW, backBtnH, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Voltar", backBtnX, backBtnY + 10, backBtnW, "center")
    love.graphics.setColor(1, 1, 1)

    -- Nome do desenvolvedor no canto inferior esquerdo
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(dev_name, 10, screenH - 30)
end

function listGames:keypressed(key)
    if key == "up" then
        selected = selected - 1
        if selected < 1 then selected = #games end
    elseif key == "down" then
        selected = selected + 1
        if selected > #games then selected = 1 end
    elseif key == "return" or key == "kpenter" then
        if selected == 1 then
            Gamestate.switch(activity1Instr) -- redireciona para activity-1-instruction
        end
        -- Adicione lógica para outros jogos se desejar
    elseif key == "escape" then
        Gamestate.switch(require 'states.menu')
    end
end

function listGames:mousemoved(x, y, dx, dy)
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    local btnW, btnH = 300, 50
    local spacing = 20
    local totalHeight = #games * btnH + (#games - 1) * spacing
    local startY = (screenH - totalHeight) / 2

    -- Hover nos botões de jogos
    for i, game in ipairs(games) do
        local bx = (screenW - btnW) / 2
        local by = startY + (i - 1) * (btnH + spacing)
        if x >= bx and x <= bx + btnW and y >= by and y <= by + btnH then
            game.hovered = true
            selected = i
        else
            game.hovered = false
        end
    end

    -- Hover no botão Voltar
    local backBtnW, backBtnH = 120, 40
    local backBtnX, backBtnY = 30, screenH / 2 - backBtnH / 2
    if x >= backBtnX and x <= backBtnX + backBtnW and y >= backBtnY and y <= backBtnY + backBtnH then
        backHovered = true
    else
        backHovered = false
    end
end

function listGames:mousepressed(x, y, button)
    if button == 1 then
        local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
        local btnW, btnH = 300, 50
        local spacing = 20
        local totalHeight = #games * btnH + (#games - 1) * spacing
        local startY = (screenH - totalHeight) / 2

        -- Clique nos botões de jogos
        for i, game in ipairs(games) do
            local bx = (screenW - btnW) / 2
            local by = startY + (i - 1) * (btnH + spacing)
            if x >= bx and x <= bx + btnW and y >= by and y <= by + btnH then
                if i == 1 then
                    Gamestate.switch(activity1Instr) -- redireciona para activity-1-instruction
                end
                -- Adicione lógica para outros jogos se desejar
                return
            end
        end

        -- Clique no botão Voltar
        local backBtnW, backBtnH = 120, 40
        local backBtnX, backBtnY = 30, screenH / 2 - backBtnH / 2
        if x >= backBtnX and x <= backBtnX + backBtnW and y >= backBtnY and y <= backBtnY + backBtnH then
            Gamestate.switch(require 'states.menu')
        end
    end
end

print("Aluno logado:", session.aluno and session.aluno.nome)

return listGames