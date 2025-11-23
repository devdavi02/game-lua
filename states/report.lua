local Gamestate = require 'lib.gamestate'
local json = require 'lib.json'
local session = require 'session'
local PDF = require 'lib.pdf'

local report = {}
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

-- Pop-up
local showPopup = false
local selectedAluno = nil
local relatorios = {}
local printBtn = {x = 0, y = 0, w = 200, h = 50}

-- Variáveis para o scroll no pop-up
local popupScrollY = 0
local popupMaxScroll = 0
local popupDragging = false
local popupDragStartY = 0
local popupDragStartScroll = 0

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

function report:enter()
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

function report:draw()
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
    love.graphics.printf("Relatórios dos Alunos", 0, 60, screenW, "center")

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

    -- botão voltar
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.w, backBtn.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Voltar", backBtn.x, backBtn.y + 10, backBtn.w, "center")
    love.graphics.setColor(1, 1, 1)

    -- Desenha o pop-up se necessário
    if showPopup then
        self:drawPopup()
    end
end

function report:drawPopup()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    local popupW, popupH = screenW - 100, screenH - 200
    local popupX, popupY = 50, 100

    -- Fundo do pop-up
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", popupX, popupY, popupW, popupH, 12, 12)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", popupX, popupY, popupW, popupH, 12, 12)

    -- Título do pop-up
    love.graphics.setFont(love.graphics.newFont(28))
    love.graphics.printf("Relatórios de " .. selectedAluno.nome, popupX, popupY + 20, popupW, "center")

    -- Lista de relatórios com scroll
    love.graphics.setScissor(popupX, popupY + 70, popupW, popupH - 150) -- Define a área de recorte para o conteúdo
    love.graphics.setFont(love.graphics.newFont(18))
    local y = popupY + 80 - popupScrollY
    for _, relatorio in ipairs(relatorios) do
        -- Exibe a data do relatório
        love.graphics.printf(
            string.format("Data: %s", relatorio.data),
            popupX + 20, y, popupW - 40, "left"
        )
        y = y + 30 -- Espaçamento após a data

        -- Exibe os detalhes do relatório
        love.graphics.printf(
            string.format("Acertos: %d | Erros: %d | Tentativas: %d | Tempo: %d segundos",
                relatorio.acertos, relatorio.erros, relatorio.tentativas, relatorio.tempo),
            popupX + 20, y, popupW - 40, "left"
        )
        y = y + 50 -- Espaçamento maior entre relatórios
    end
    love.graphics.setScissor() -- Remove o recorte

    -- Calcula o scroll máximo
    local contentHeight = y - (popupY + 80)
    popupMaxScroll = math.max(0, contentHeight - (popupH - 150))

    -- Barra de scroll
    if popupMaxScroll > 0 then
        local barW = 10
        local barH = math.max(20, (popupH - 150) * (popupH - 150) / contentHeight) -- Altura proporcional ao conteúdo
        local barX = popupX + popupW - 20
        local barY = popupY + 70 + (popupScrollY / popupMaxScroll) * ((popupH - 150) - barH)

        -- Fundo da barra
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", barX, popupY + 70, barW, popupH - 150, 5, 5)

        -- Barra de scroll ativa
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle("fill", barX, barY, barW, barH, 5, 5)

        -- Salva as dimensões da barra para interação
        self.scrollBar = {x = barX, y = barY, w = barW, h = barH}
    else
        self.scrollBar = nil -- Não há barra de scroll se o conteúdo não exceder o espaço visível
    end

    -- Botão de imprimir
    printBtn.x = popupX + (popupW - printBtn.w) / 2
    printBtn.y = popupY + popupH - 80
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill", printBtn.x, printBtn.y, printBtn.w, printBtn.h, 8, 8)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Imprimir Relatório", printBtn.x, printBtn.y + 15, printBtn.w, "center")
end

function report:mousepressed(x, y, button)
    if button == 1 then
        if showPopup then
            -- Clique no botão de imprimir
            if x > printBtn.x and x < printBtn.x + printBtn.w and y > printBtn.y and y < printBtn.y + printBtn.h then
                self:generateReport(selectedAluno)
                showPopup = false
                return
            end

            -- Clique na barra de scroll
            if self.scrollBar and x > self.scrollBar.x and x < self.scrollBar.x + self.scrollBar.w and
                y > self.scrollBar.y and y < self.scrollBar.y + self.scrollBar.h then
                popupDragging = true
                popupDragStartY = y
                popupDragStartScroll = popupScrollY
                return
            end

            -- Iniciar arraste no pop-up (se clicar dentro da área de relatórios)
            local popupX, popupY = 50, 100
            local popupW, popupH = love.graphics.getWidth() - 100, love.graphics.getHeight() - 200
            if x > popupX and x < popupX + popupW and y > popupY + 70 and y < popupY + popupH - 80 then
                popupDragging = true
                popupDragStartY = y
                popupDragStartScroll = popupScrollY
                return
            end

            -- Fechar o pop-up ao clicar fora
            showPopup = false
            return
        end

        -- verifica clique em aluno
        for _, btn in ipairs(btnAlunos) do
            local drawY = btn.y - scrollY
            if x > btn.x and x < btn.x + btn.w and y > drawY and y < drawY + btn.h then
                -- Carrega os relatórios do aluno
                self:loadRelatorios(btn.aluno)
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

function report:mousemoved(x, y, dx, dy)
    if popupDragging then
        -- Arrastar: move o scroll do pop-up
        if self.scrollBar then
            local popupH = love.graphics.getHeight() - 200
            local barH = self.scrollBar.h
            local barYMin = 100 + 70
            local barYMax = barYMin + (popupH - 150) - barH
            local newBarY = clamp(self.scrollBar.y + dy, barYMin, barYMax)

            -- Atualiza o scroll com base na posição da barra
            popupScrollY = ((newBarY - barYMin) / (barYMax - barYMin)) * popupMaxScroll
            self.scrollBar.y = newBarY
        end
    elseif dragging then
        -- Arrastar: move o scroll da lista de alunos
        scrollY = clamp(dragStartScroll - (y - dragStartY), 0, maxScroll)
    end
end

function report:mousereleased(x, y, button)
    if button == 1 then
        popupDragging = false
        dragging = false
    end
end

function report:wheelmoved(dx, dy)
    if showPopup then
        -- Scroll no pop-up
        popupScrollY = clamp(popupScrollY - dy * scrollSpeed, 0, popupMaxScroll)
    else
        -- Scroll na lista de alunos
        scrollY = clamp(scrollY - dy * scrollSpeed, 0, maxScroll)
    end
end

function report:keypressed(key)
    if key == "escape" then
        Gamestate.switch(require 'states.menu')
    elseif key == "up" then
        scrollY = clamp(scrollY - itemHeight, 0, maxScroll)
    elseif key == "down" then
        scrollY = clamp(scrollY + itemHeight, 0, maxScroll)
    end
end

function report:loadRelatorios(aluno)
    selectedAluno = aluno
    relatorios = {}

    if love.filesystem.getInfo("relatorios.json") then
        local conteudo = love.filesystem.read("relatorios.json")
        local todosRelatorios = json.decode(conteudo) or {}
        for _, relatorio in ipairs(todosRelatorios) do
            if relatorio.aluno_id == aluno.id then
                table.insert(relatorios, relatorio)
            end
        end
    end

    showPopup = true
end

function report:generateReport(aluno)
    local pdf = PDF.new()
    local font = pdf:new_font{name = "Helvetica"}
    local page = pdf:new_page()

    page:begin_text()
    page:set_font(font, 12)
    page:set_text_pos(50, 750)
    page:show("Relatórios do Aluno: " .. aluno.nome)
    page:end_text()

    local y = 720
    for _, relatorio in ipairs(relatorios) do
        page:begin_text()
        page:set_font(font, 10)
        page:set_text_pos(50, y)
        page:show(string.format("Data: %s | Acertos: %d | Erros: %d | Tentativas: %d | Tempo: %d segundos",
            relatorio.data, relatorio.acertos, relatorio.erros, relatorio.tentativas, relatorio.tempo))
        page:end_text()
        y = y - 20
        if y < 50 then
            page:add()
            page = pdf:new_page()
            y = 750
        end
    end

    page:add()
    pdf:write("relatorio_" .. aluno.nome .. ".pdf")
    print("PDF gerado: relatorio_" .. aluno.nome .. ".pdf")
end

return report