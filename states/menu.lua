local Gamestate = require 'lib.gamestate'
local config = require 'states.config'
local cadastroAluno = require 'states.register-classmate'
local listaAlunos = require 'states.list-classmate'
local deleteClassmate = require 'states.delete-classmate'
local report = require 'states.report'

local menu = {}

local buttons = {
    {label = "Cadastrar Aluno", y = 0, hovered = false},
    {label = "Deletar Aluno", y = 0, hovered = false},
    {label = "Entrar no Perfil de Aluno", y = 0, hovered = false},
    {label = "Relatórios", y = 0, hovered = false},
    {label = "Opções", y = 0, hovered = false}
}
local selected = 1
local title = "Nome Provisório"
local dev_name = "Desenvolvedor: Seu Nome"

local background

function menu:enter()
    if not background then
        background = love.graphics.newImage("/assets/images/background.png")
    end

    -- Centraliza os botões verticalmente
    local screenH = love.graphics.getHeight()
    local btnHeight = 50
    local spacing = 20
    local totalHeight = #buttons * btnHeight + (#buttons - 1) * spacing
    local startY = (screenH - totalHeight) / 2
    for i, btn in ipairs(buttons) do
        btn.y = startY + (i - 1) * (btnHeight + spacing)
    end
end

function menu:draw()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    -- Desenha a imagem de fundo
    if background then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(background, 0, 0, 0, screenW / background:getWidth(), screenH / background:getHeight())
    end

    -- Título centralizado
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.printf(title, 0, 80, screenW, "center")

    -- Botões centralizados
    love.graphics.setFont(love.graphics.newFont(28))
    local btnW, btnH = 420, 50 -- Aumenta a largura do botão
    for i, btn in ipairs(buttons) do
        local x = (screenW - btnW) / 2
        local y = btn.y
        -- Destaque se selecionado ou hover
        if i == selected or btn.hovered then
            love.graphics.setColor(0.2, 0.6, 1)
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        love.graphics.rectangle("fill", x, y, btnW, btnH, 10, 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(btn.label, x, y + 10, btnW, "center")
        love.graphics.setColor(1, 1, 1)
    end

    -- Nome do desenvolvedor no canto inferior esquerdo
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(dev_name, 10, screenH - 30)
end

function menu:keypressed(key)
    if key == "up" then
        selected = selected - 1
        if selected < 1 then selected = #buttons end
    elseif key == "down" then
        selected = selected + 1
        if selected > #buttons then selected = 1 end
    elseif key == "return" or key == "kpenter" then
        menu:activate(selected)
    end
end

function menu:mousemoved(x, y, dx, dy)
    local screenW = love.graphics.getWidth()
    local btnW, btnH = 420, 50 -- Mesma largura dos botões
    for i, btn in ipairs(buttons) do
        local bx = (screenW - btnW) / 2
        local by = btn.y
        if x >= bx and x <= bx + btnW and y >= by and y <= by + btnH then
            btn.hovered = true
            selected = i
        else
            btn.hovered = false
        end
    end
end

function menu:mousepressed(x, y, button)
    if button == 1 then
        for i, btn in ipairs(buttons) do
            if btn.hovered then
                menu:activate(i)
                break
            end
        end
    end
end

function menu:activate(idx)
    if idx == 1 then
        Gamestate.switch(cadastroAluno)
    elseif idx == 2 then
        Gamestate.switch(deleteClassmate)
    elseif idx == 3 then
        Gamestate.switch(listaAlunos)
    elseif idx == 4 then
        Gamestate.switch(report)
    elseif idx == 5 then
        Gamestate.switch(config)
    end
end

return menu