require "scripts.mino"

clearFxImg = love.graphics.newImage("data/clearFx.png")

board = {}
function board:set()
    self.grid = {}
    for y=1, 23 do
        self.grid[y] = {}
        for x=1, 10 do
            self.grid[y][x] = 0
        end
    end
    self.next = {}
    self.hold = nil
    self.canHold = true
    self.topOut = false
    self.height = #self.grid
    self.targetLines = 40
    self.laneFx = {{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}}
    self.clearFx = 0
    -- self.clearFxImg = clearFxImg
    self:updateNext()
end

function board:checkHeight()
    self.height = #self.grid
    for y, row in ipairs(self.grid) do
        local fullLine = true
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                if y < self.height then
                    self.height = y
                    break
                end
            end
        end
    end
end

function board:updateNext()
    if #self.next <= 7 then
        local shuffled = shuffle(minoNames)
        for i, name in ipairs(shuffled) do
            table.insert(self.next, name)
        end
    end
end

function board:swapHold(minoName)
    local temp = self.hold
    self.hold = minoName
    self.canHold = false
    return temp
end

function board:place(mino)
    for y, row in ipairs(mino.shape) do 
        for x, dot in ipairs(row) do
            if dot ~= 0 then 
                if y+mino.y <= 1 then
                    self.topOut = true
                end
                if y+mino.y < 1 then
                    return false
                else
                    self.grid[y+mino.y][x+mino.x] = mino.name
                end
            end
        end
    end
    local clearCount = self:checkLineClear()
    self:checkHeight()
    self:updateNext()
    self.canHold = true
end

function board:checkLineClear()
    local clearCount = 0
    for y, row in ipairs(self.grid) do
        local fullLine = true
        for x, dot in ipairs(row) do
            if dot == 0 then
                fullLine = false
                break
            end
        end
        if fullLine then
            table.remove(self.grid, y)
            local line = {}
            for x=1, 10 do
                line[x] = 0
            end 
            table.insert(self.grid, 1, line)
            clearCount = clearCount+1
        end
    end
    self.targetLines = self.targetLines-clearCount
    if clearCount == 0 then
        for y, row in ipairs(currentMino.shape) do
            for x, dot in ipairs(row) do
                if dot ~= 0 then
                    if self.laneFx[currentMino.x+x][1] ~= 1 then
                        self.laneFx[currentMino.x+x][1] = 1
                        if self.laneFx[currentMino.x+x][2] > currentMino.y+y then 
                            self.laneFx[currentMino.x+x][2] = currentMino.y+y
                        end
                    end
                end
            end
        end
    else
        self.clearFx = 1
    end
    return clearCount
end

function board:checkBlockOut(nextShape)
    for y, row in ipairs(nextShape) do 
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                if board.grid[y][x+math.floor(10/2-#nextShape/2)] ~= 0 then
                    self.topOut = true
                    return true
                end
            end
        end
    end
    -- self.topOut = false
    return false
end

function board:getNext()
    local next = table.remove(self.next, 1) 
    self:checkBlockOut((minoShapes[next]))
    return next
end

function board:update(dt)
    for i=1, #self.laneFx do
        if self.laneFx[i][1] > 0 then
            self.laneFx[i][1] = self.laneFx[i][1]-dt/10
        else
            self.laneFx[i][2] = #self.grid
        end
    end
    
    if self.clearFx > 0 then
        self.clearFx = self.clearFx-dt/20
    end
            
    if self.topOut then
        self:set()
    end
end