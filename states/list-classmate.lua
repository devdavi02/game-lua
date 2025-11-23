local Gamestate = require 'lib.gamestate'
local json = require 'lib.json'
local session = require 'session'

local listaAlunos = {}
local alunos = {}
local backBtn = {x = 20, y = 20, w = 100, h = 40}
local background

-- itens / layout
local btnAlunos = {}
local itemHeight = 50
local paddingTop = 120
local paddingBottom = 40
local itemSpacing = 8

-- scroll
local scrollY = 0
local maxScroll = 0
local scrollSpeed = 40 -- pixels per wheel tick
local dragging = false
local dragStartY = 0
local dragStartScroll = 0

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

function listaAlunos:enter()
    if not background then
        if love.filesystem.getInfo("/assets/images/background.png") then
            background = love.graphics.newImage("/assets/images/background.png")
        end
    end

    -- carrega alunos
    alunos = {}
    btnAlunos = {}
    scrollY = 0
    dragging = false

    if love.filesystem.getInfo("alunos.json") then
        local conteudo = love.filesystem.read("alunos.json")
        alunos = json.decode(conteudo) or {}
    end

    local screenW = love.graphics.getWidth()
    -- cria botões para cada aluno (posição base, desenhamos subtraindo scrollY)
    for i, aluno in ipairs(alunos) do
        local y = paddingTop + (i-1) * (itemHeight + itemSpacing)
        btnAlunos[i] = {
            x = 100,
            y = y,
            w = screenW - 200,
            h = itemHeight,
            aluno = aluno
        }
    end

    -- calcula altura total do conteúdo e max scroll
    local contentHeight = paddingTop + #alunos * (itemHeight + itemSpacing) - itemSpacing + paddingBottom
    local screenH = love.graphics.getHeight()
    maxScroll = math.max(0, contentHeight - screenH)
end

function listaAlunos:draw()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

    -- background
    if background then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(background, 0, 0, 0, screenW / background:getWidth(), screenH / background:getHeight())
    else
        love.graphics.clear(1,1,1)
    end

    -- título
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Alunos Cadastrados", 0, 60, screenW, "center")

    -- lista (aplica scroll)
    love.graphics.setFont(love.graphics.newFont(22))
    for i, btn in ipairs(btnAlunos) do
        local drawY = btn.y - scrollY
        -- só desenha se visível (pequena otimização)
        if drawY + btn.h >= 0 and drawY <= screenH then
            love.graphics.setColor(0.8, 0.8, 1)
            love.graphics.rectangle("fill", btn.x, drawY, btn.w, btn.h, 8, 8)
            love.graphics.setColor(0,0,0)
            love.graphics.printf(
                btn.aluno.id .. " - " .. btn.aluno.nome .. " (" .. btn.aluno.idade .. " anos)",
                btn.x + 12, drawY + 12, btn.w - 24, "left"
            )
        end
    end

    -- scrollbar (se necessário)
    if maxScroll > 0 then
        local barW = 12
        local barX = screenW - 20
        local barH = clamp((screenH / (paddingTop + #alunos * (itemHeight + itemSpacing) + paddingBottom)) * screenH, 20, screenH)
        local barY = (scrollY / maxScroll) * (screenH - barH)
        love.graphics.setColor(0.85, 0.85, 0.85, 0.9)
        love.graphics.rectangle("fill", barX, 0, barW, screenH, 6, 6)
        love.graphics.setColor(0.4, 0.4, 0.4, 0.95)
        love.graphics.rectangle("fill", barX + 1, barY, barW - 2, barH, 6, 6)
    end

    -- botão voltar
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.w, backBtn.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Voltar", backBtn.x, backBtn.y + 10, backBtn.w, "center")
    love.graphics.setColor(1, 1, 1)
end

function listaAlunos:mousepressed(x, y, button)
    if button == 1 then
        -- verifica clique em aluno (ajusta pelo scroll)
        for _, btn in ipairs(btnAlunos) do
            local drawY = btn.y - scrollY
            if x > btn.x and x < btn.x + btn.w and y > drawY and y < drawY + btn.h then
                session.aluno = btn.aluno
                Gamestate.switch(require 'states.list-games')
                return
            end
        end
        -- botão voltar
        if x > backBtn.x and x < backBtn.x + backBtn.w and y > backBtn.y and y < backBtn.y + backBtn.h then
            Gamestate.switch(require 'states.menu')
            return
        end

        -- iniciar arraste (se clicar dentro da área da lista)
        if x > 80 and x < love.graphics.getWidth() - 80 and y > 100 and y < love.graphics.getHeight() then
            dragging = true
            dragStartY = y
            dragStartScroll = scrollY
        end
    end
end

function listaAlunos:mousereleased(x, y, button)
    if button == 1 then
        dragging = false
    end
end

function listaAlunos:mousemoved(x, y, dx, dy)
    if dragging then
        -- arrastar: move scroll
        scrollY = clamp(dragStartScroll - (y - dragStartY), 0, maxScroll)
    end
end

function listaAlunos:wheelmoved(dx, dy)
    -- dy > 0 = up, dy < 0 = down
    scrollY = clamp(scrollY - dy * scrollSpeed, 0, maxScroll)
end

function listaAlunos:keypressed(key)
    if key == "escape" then
        Gamestate.switch(require 'states.menu')
    elseif key == "up" then
        scrollY = clamp(scrollY - itemHeight, 0, maxScroll)
    elseif key == "down" then
        scrollY = clamp(scrollY + itemHeight, 0, maxScroll)
    end
end

return listaAlunos