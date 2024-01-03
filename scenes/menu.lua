menu = {}

function menu.load(sceneLoader)
    -- text, value, x, y, hoverAnim, hovering
    buttons = {
        {"play (40L)", "game", 100, 320, 0, false},
        {"options", "", 100, 380, 0, false},
        {"exit", "", 100, 440, 0, false}
    }
    sceneLoader = sceneLoader
end
    
function menu.draw()
    love.graphics.setBackgroundColor(hexToRGB("#2d333bff"))

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(fontB)
    love.graphics.print("luatris", 100, 180)
    love.graphics.setFont(fontN)
    
    for i, button in ipairs(buttons) do
        if button[6] then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 0.6)
        end
        love.graphics.print(button[1], button[3]+button[5], button[4])
    end
end

function menu.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    for i, button in ipairs(buttons) do
        if AABB(button[3], button[4], fontN:getWidth(button[1]), fontNHeight, mouseX, mouseY, 1, 1) then
            button[5] = button[5]+(15-button[5])/4*dt
            button[6] = true
        else
            button[5] = button[5]-button[5]/4*dt
            button[6] = false
        end
    end
end

function menu.mousepressed(x, y, button)
    for i, button in ipairs(buttons) do
        if button[6] then
            sceneLoader:setScene(button[2])
        end
    end
end

function menu.keypressed(key)
    if key == "space" then
        sceneLoader:setScene("game")
    end
end