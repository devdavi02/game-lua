local Gamestate = require 'lib.gamestate'
local json = require 'lib.json'

-- Carregue os diferentes estados
local menu = require 'states.menu'

function love.load()
    -- Defina a resolução da janela
    love.window.setMode(800, 600, { resizable = true })

    -- Inicialize o estado do Menu
    Gamestate.switch(menu)
end

function love.update(dt)
    -- Atualiza o estado atual
    Gamestate.update(dt)
end

function love.draw()
    -- Desenha o estado atual
    Gamestate.draw()
end

function love.keypressed(key)
    -- Passa o evento para o estado atual
    Gamestate.keypressed(key)
end

-- Adicione outros callbacks do LÖVE conforme necessário (ex: love.mousepressed)
function love.mousepressed(x, y, button)
    Gamestate.mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    if Gamestate.mousemoved then
        Gamestate.mousemoved(x, y, dx, dy)
    end
end

function love.textinput(t)
    if Gamestate.textinput then
        Gamestate.textinput(t)
    end
end
