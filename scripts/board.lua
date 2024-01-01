require "scripts.mino"

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
    self.blockOut = false
    self:updateNext()
end

function board:updateNext()
    if #self.next <= 5 then
        local shuffled = shuffle(minoNames)
        for i=1, 7 do
            table.insert(board.next, shuffled[i])
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
                if y+mino.y < 1 then
                    return false
                else
                    board.grid[y+mino.y][x+mino.x] = mino.name
                end
            end
        end
    end
    self:checkLineClear()
    self:updateNext()
    self.canHold = true
    return true
end

function board:checkLineClear()
    for y, row in ipairs(board.grid) do
        local fullLine = true
        for x, dot in ipairs(row) do
            if dot == 0 then
                fullLine = false
                break
            end
        end
        if fullLine then
            table.remove(board.grid, y)
            local line = {}
            for x=1, 10 do
                line[x] = 0
            end 
            table.insert(board.grid, 1, line)
        end
    end
end

function board:checkBlockOut(nextShape)
    for y, row in ipairs(nextShape) do 
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                if board.grid[y][x+math.floor(10/2-#nextShape/2)] ~= 0 then
                    self.blockOut = true
                    return true
                end
            end
        end
    end
    self.blockOut = false
    return false
end

function board:getNext()
    local next = table.remove(board.next, 1) 
    self:checkBlockOut((minoShapes[next]))
    return next
end