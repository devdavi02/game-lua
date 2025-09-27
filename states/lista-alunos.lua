local Gamestate = require 'lib.gamestate'
local json = require 'lib.json'
local session = require 'session'

local listaAlunos = {}
local alunos = {}
local backBtn = {x = 20, y = 20, w = 100, h = 40}
local background
local btnAlunos = {}

function listaAlunos:enter()
    if not background then
        background = love.graphics.newImage("/assets/images/background.png")
    end
    -- Carrega alunos do arquivo
    alunos = {}
    btnAlunos = {}
    if love.filesystem.getInfo("alunos.json") then
        local conteudo = love.filesystem.read("alunos.json")
        alunos = json.decode(conteudo) or {}
    end
    -- Cria botões para cada aluno
    local screenW = love.graphics.getWidth()
    for i, aluno in ipairs(alunos) do
        local y = 120 + i * 50
        btnAlunos[i] = {
            x = 100,
            y = y,
            w = screenW - 200,
            h = 40,
            aluno = aluno
        }
    end
end

function listaAlunos:draw()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    if background then
        love.graphics.draw(background, 0, 0, 0, screenW / background:getWidth(), screenH / background:getHeight())
    end

    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("Alunos Cadastrados", 0, 60, screenW, "center")

    love.graphics.setFont(love.graphics.newFont(22))
    for i, btn in ipairs(btnAlunos) do
        love.graphics.setColor(0.8, 0.8, 1)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 8, 8)
        love.graphics.setColor(0,0,0)
        love.graphics.printf(
            btn.aluno.id .. " - " .. btn.aluno.nome .. " (" .. btn.aluno.idade .. " anos)",
            btn.x, btn.y + 8, btn.w, "left"
        )
    end

    -- Botão Voltar
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.w, backBtn.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Voltar", backBtn.x, backBtn.y + 10, backBtn.w, "center")
    love.graphics.setColor(1, 1, 1)
end

function listaAlunos:mousepressed(x, y, button)
    if button == 1 then
        -- Verifica clique em aluno
        for _, btn in ipairs(btnAlunos) do
            if x > btn.x and x < btn.x + btn.w and y > btn.y and y < btn.y + btn.h then
                session.aluno = btn.aluno
                Gamestate.switch(require 'states.list-games')
                return
            end
        end
        -- Botão Voltar
        if x > backBtn.x and x < backBtn.x + backBtn.w and y > backBtn.y and y < backBtn.y + backBtn.h then
            Gamestate.switch(require 'states.menu')
        end
    end
end

function listaAlunos:keypressed(key)
    if key == "escape" then
        Gamestate.switch(require 'states.menu')
    end
end

return listaAlunos