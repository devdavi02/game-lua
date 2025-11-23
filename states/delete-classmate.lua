local Gamestate = require 'lib.gamestate'
local json = require 'lib.json'

local deleteClassmate = {}
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

-- Pop-up de confirmação
local showPopup = false
local selectedAluno = nil

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

function deleteClassmate:enter()
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

function deleteClassmate:draw()
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
    love.graphics.printf("Deletar Aluno", 0, 60, screenW, "center")

    -- lista (aplica scroll)
    love.graphics.setFont(love.graphics.newFont(22))
    for i, btn in ipairs(btnAlunos) do
        local drawY = btn.y - scrollY
        -- só desenha se visível (pequena otimização)
        if drawY + btn.h >= 0 and drawY <= screenH then
            love.graphics.setColor(1, 0.4, 0.4) -- cor vermelha para indicar exclusão
            love.graphics.rectangle("fill", btn.x, drawY, btn.w, btn.h, 8, 8)
            love.graphics.setColor(0,0,0)
            love.graphics.printf(
                btn.aluno.id .. " - " .. btn.aluno.nome .. " (" .. btn.aluno.idade .. " anos)",
                btn.x + 12, drawY + 12, btn.w - 24, "left"
            )
        end
    end

    -- botão voltar
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.w, backBtn.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Voltar", backBtn.x, backBtn.y + 10, backBtn.w, "center")
    love.graphics.setColor(1, 1, 1)

    -- Desenha o pop-up de confirmação, se necessário
    if showPopup then
        self:drawPopup()
    end
end

function deleteClassmate:drawPopup()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    local popupW, popupH = 400, 200
    local popupX, popupY = (screenW - popupW) / 2, (screenH - popupH) / 2

    -- Fundo do pop-up
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", popupX, popupY, popupW, popupH, 12, 12)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", popupX, popupY, popupW, popupH, 12, 12)

    -- Texto do pop-up
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf(
        "Tem certeza que deseja excluir o aluno " .. selectedAluno.nome .. " e seus relatórios?",
        popupX + 20, popupY + 40, popupW - 40, "center"
    )

    -- Botão "Sim"
    local btnYes = {x = popupX + 50, y = popupY + 120, w = 120, h = 40}
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", btnYes.x, btnYes.y, btnYes.w, btnYes.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Sim", btnYes.x, btnYes.y + 10, btnYes.w, "center")

    -- Botão "Não"
    local btnNo = {x = popupX + 230, y = popupY + 120, w = 120, h = 40}
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", btnNo.x, btnNo.y, btnNo.w, btnNo.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Não", btnNo.x, btnNo.y + 10, btnNo.w, "center")

    -- Salva as dimensões dos botões para interação
    self.popupButtons = {yes = btnYes, no = btnNo}
end

function deleteClassmate:mousepressed(x, y, button)
    if button == 1 then
        if showPopup then
            -- Verifica clique nos botões do pop-up
            if x > self.popupButtons.yes.x and x < self.popupButtons.yes.x + self.popupButtons.yes.w and
               y > self.popupButtons.yes.y and y < self.popupButtons.yes.y + self.popupButtons.yes.h then
                self:deleteAluno(selectedAluno.id) -- Confirma exclusão
                showPopup = false
                return
            end

            if x > self.popupButtons.no.x and x < self.popupButtons.no.x + self.popupButtons.no.w and
               y > self.popupButtons.no.y and y < self.popupButtons.no.y + self.popupButtons.no.h then
                showPopup = false -- Cancela exclusão
                return
            end
        else
            -- Verifica clique em aluno (ajusta pelo scroll)
            for i, btn in ipairs(btnAlunos) do
                local drawY = btn.y - scrollY
                if x > btn.x and x < btn.x + btn.w and y > drawY and y < drawY + btn.h then
                    selectedAluno = btn.aluno -- Define o aluno selecionado
                    showPopup = true -- Mostra o pop-up
                    return
                end
            end
            -- botão voltar
            if x > backBtn.x and x < backBtn.x + backBtn.w and y > backBtn.y and y < backBtn.y + backBtn.h then
                Gamestate.switch(require 'states.menu')
                return
            end
        end
    end
end

function deleteClassmate:mousereleased(x, y, button)
    if button == 1 then
        dragging = false
    end
end

function deleteClassmate:mousemoved(x, y, dx, dy)
    if dragging then
        -- arrastar: move scroll
        scrollY = clamp(dragStartScroll - (y - dragStartY), 0, maxScroll)
    end
end

function deleteClassmate:wheelmoved(dx, dy)
    -- dy > 0 = up, dy < 0 = down
    scrollY = clamp(scrollY - dy * scrollSpeed, 0, maxScroll)
end

function deleteClassmate:keypressed(key)
    if key == "escape" then
        Gamestate.switch(require 'states.menu')
    elseif key == "up" then
        scrollY = clamp(scrollY - itemHeight, 0, maxScroll)
    elseif key == "down" then
        scrollY = clamp(scrollY + itemHeight, 0, maxScroll)
    end
end

function deleteClassmate:deleteAluno(alunoId)
    -- Remove o aluno do arquivo alunos.json
    if love.filesystem.getInfo("alunos.json") then
        local conteudo = love.filesystem.read("alunos.json")
        local todosAlunos = json.decode(conteudo) or {}
        for i = #todosAlunos, 1, -1 do
            if todosAlunos[i].id == alunoId then
                table.remove(todosAlunos, i)
            end
        end
        love.filesystem.write("alunos.json", json.encode(todosAlunos, {indent = true}))
    end

    -- Remove os relatórios do aluno do arquivo relatorios.json
    if love.filesystem.getInfo("relatorios.json") then
        local conteudo = love.filesystem.read("relatorios.json")
        local todosRelatorios = json.decode(conteudo) or {}
        for i = #todosRelatorios, 1, -1 do
            if todosRelatorios[i].aluno_id == alunoId then
                table.remove(todosRelatorios, i)
            end
        end
        love.filesystem.write("relatorios.json", json.encode(todosRelatorios, {indent = true}))
    end

    -- Atualiza a lista de alunos
    self:enter()
end

return deleteClassmate