local activity1 = {}

-- Dados do jogo
local animals = {
    {name = "cachorro", image = "assets/images/cachorro.png", syllables = 3},
    {name = "gato", image = "assets/images/gato.png", syllables = 2},
    {name = "elefante", image = "assets/images/elefante.png", syllables = 4}
}

local currentAnimal
local feedback = nil -- "correct" ou "wrong"
local buttons = {}

function activity1.load()
    -- escolhe um animal aleatório
    currentAnimal = animals[love.math.random(#animals)]

    -- cria botões de sílabas (1 até 5, por exemplo)
    buttons = {}
    for i = 1, 5 do
        table.insert(buttons, {
            x = 100 + (i-1)*80,
            y = 400,
            w = 60,
            h = 60,
            number = i
        })
    end
end

function activity1.draw()
    -- Desenha imagem do animal
    local img = love.graphics.newImage(currentAnimal.image)
    love.graphics.draw(img, 200, 100, 0, 0.5, 0.5)

    -- Desenha botões
    for _, btn in ipairs(buttons) do
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
        love.graphics.printf(btn.number, btn.x, btn.y + 20, btn.w, "center")
    end

    -- Mostra feedback
    if feedback == "correct" then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("✔ Acertou!", 250, 350, 0, 2, 2)
        love.graphics.setColor(1, 1, 1)
    elseif feedback == "wrong" then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("✘ Tente de novo!", 220, 350, 0, 2, 2)
        love.graphics.setColor(1, 1, 1)
    end
end

function activity1.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if x > btn.x and x < btn.x + btn.w and y > btn.y and y < btn.y + btn.h then
                if btn.number == currentAnimal.syllables then
                    feedback = "correct"
                else
                    feedback = "wrong"
                end
            end
        end
    end
end

return activity1
