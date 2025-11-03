-- local Confetti = require 'states.confetti'

local confetti
local Confetti = {}
Confetti.__index = Confetti

function Confetti.new(maxParticles)
    local self = setmetatable({}, Confetti)
    maxParticles = maxParticles or 500

    -- cria uma imagem pequena branca para as partículas
    local imageData = love.image.newImageData(4,4)
    imageData:mapPixel(function(x,y,r,g,b,a) return 1,1,1,1 end)
    local img = love.graphics.newImage(imageData)

    self.ps = love.graphics.newParticleSystem(img, maxParticles)
    self.ps:setParticleLifetime(1.2, 3)      -- vida das partículas
    self.ps:setSpeed(100, 450)               -- velocidade inicial
    self.ps:setLinearAcceleration(-100, -400, 100, 400) -- aceleração (spread)
    self.ps:setSpread(math.pi * 2)               -- espalhamento em radianos
    self.ps:setSizes(1, 0.6, 0.4)            -- tamanho ao longo da vida
    self.ps:setSpin(0, 8)                    -- rotação
    self.ps:setSpinVariation(1)
    self.ps:setEmissionRate(0)               -- emitiremos manualmente com :emit()
    -- cores (RGBA). Valores em LÖVE 11+ vão de 0..1, usamos 0..1 aqui
    self.ps:setColors(
        1,0.2,0.2,1,   -- vermelho
        1,0.6,0.2,1,   -- laranja
        1,1,0.2,1,     -- amarelo
        0.2,1,0.3,1,   -- verde
        0.2,0.6,1,1,   -- azul
        0.7,0.2,1,1    -- roxo
    )

    return self
end

function Confetti:spawn(x, y, count)
    count = count or 100
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    self.ps:setPosition(x or screenW/2, y or screenH/2) -- centro da tela
    self.ps:setLinearAcceleration(-300, -300, 300, 300) -- espalha para todos os lados
    self.ps:emit(count)
end

function Confetti:update(dt)
    self.ps:update(dt)
end

function Confetti:draw()
    love.graphics.draw(self.ps)
end

return Confetti