menu = {}

function menu.load(sceneLoader)
    -- value, x, y, hover
    buttons = {
        {"play (40L)", "game", 100, 300, 0},
        {"options", "", 100, 380, 0},
        {"exit", "", 100, 460, 0}
    }
    sceneLoader = sceneLoader
end
    
function menu.draw()
    love.graphics.setBackgroundColor(hexToRGB("#2d333bff"))

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(fontB)
    love.graphics.print("luatris", 100, 120)
    love.graphics.setFont(fontN)
    -- 버튼어디감
    for i, button in ipairs(buttons) do
        love.graphics.print(button[1], button[3]+button[5], button[4])
    end
end

function menu.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    for i, button in ipairs(buttons) do
        if AABB(button[3], button[4], fontN:getWidth(button[1]), fontNHeight, mouseX, mouseY, 1, 1) then
            button[5] = button[5]+(15-button[5])/4*dt
        else
            button[5] = button[5]-button[5]/4*dt
        end
    end
end

function menu.mousepressed(x, y, button)
    for i, button in ipairs(buttons) do
        if AABB(button[3], button[4], fontN:getWidth(button[1]), fontNHeight, x, y, 1, 1) then
            sceneLoader:setScene(button[2])
        end
    end
end

function menu.keypressed(key)
    if key == "space" then
        sceneLoader:setScene("game")
    end
end