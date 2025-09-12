local Gamestate = require 'lib.gamestate'

local config = {}

local fullscreen = love.window.getFullscreen()
local selected = 1
local options = {
    {label = "Tela Cheia", action = "toggle_fullscreen"},
    {label = "Voltar", action = "back"}
}

function config:draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("Menu de Opções", 0, 80, w, "center")

    love.graphics.setFont(love.graphics.newFont(24))
    for i, opt in ipairs(options) do
        local text = opt.label
        if opt.action == "toggle_fullscreen" then
            text = text .. ": " .. (fullscreen and "Ativado" or "Desativado")
        end
        if i == selected then
            love.graphics.setColor(0.2, 0.6, 1)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(text, 0, 180 + (i-1)*60, w, "center")
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("ESC para voltar", 0, h-40, w, "center")
end

function config:keypressed(key)
    if key == "up" then
        selected = selected - 1
        if selected < 1 then selected = #options end
    elseif key == "down" then
        selected = selected + 1
        if selected > #options then selected = 1 end
    elseif key == "return" or key == "kpenter" then
        config:activate(selected)
    elseif key == "escape" then
        Gamestate.switch(require 'states.menu')
    end
end

function config:mousemoved(x, y, dx, dy)
    local w = love.graphics.getWidth()
    local optH = 40
    for i, opt in ipairs(options) do
        local bx, by = w/2 - 200, 180 + (i-1)*60
        if x >= bx and x <= bx+400 and y >= by and y <= by+optH then
            selected = i
        end
    end
end

function config:mousepressed(x, y, button)
    if button == 1 then
        local w = love.graphics.getWidth()
        local optH = 40
        for i, opt in ipairs(options) do
            local bx, by = w/2 - 200, 180 + (i-1)*60
            if x >= bx and x <= bx+400 and y >= by and y <= by+optH then
                config:activate(i)
            end
        end
    end
end

function config:activate(idx)
    if options[idx].action == "toggle_fullscreen" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
    elseif options[idx].action == "back" then
        Gamestate.switch(require 'states.menu')
    end
end

return config