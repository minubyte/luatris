require "game"

function love.load()
    game.load()
end

function love.draw()
    game.draw()
end

function love.update(dt)
    game.update(dt)
end

function love.keypressed(key)
    game.keypressed(key) 
end