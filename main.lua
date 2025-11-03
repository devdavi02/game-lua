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
    if Gamestate.keypressed then Gamestate.keypressed(key) end
end

-- encaminha eventos de mouse e roda do mouse para o gamestate
function love.mousepressed(x, y, button)
    if Gamestate.mousepressed then Gamestate.mousepressed(x, y, button) end
end

function love.mousereleased(x, y, button)
    if Gamestate.mousereleased then Gamestate.mousereleased(x, y, button) end
end

function love.mousemoved(x, y, dx, dy)
    if Gamestate.mousemoved then Gamestate.mousemoved(x, y, dx, dy) end
end

function love.wheelmoved(dx, dy)
    if Gamestate.wheelmoved then Gamestate.wheelmoved(dx, dy) end
end

function love.textinput(t)
    if Gamestate.textinput then Gamestate.textinput(t) end
end
