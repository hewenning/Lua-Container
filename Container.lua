local Container  = {}

local print = print
local assert = assert
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort


--[[ 去重元素集合 ]] --

local Set = {}
Set.__index = Set

function Set.new()
    local o = {}
    setmetatable(o, Set)
    o.tab = {}
    return o
end

function Set:insert(val)
    if self:contain(val) then
        return
    end
    self.tab[val] = true
end

function Set:delete(val)
    self.tab[val] = nil
end

function Set:contain(val)
    return self.tab[val] and true or false
end

function Set:size()
    local count = 0
    for _, v in pairs(self.tab) do
        count = count + 1
    end
    return count
end

function Set:clear()
    self.tab = {}
end

function Set:dispose()
    self:clear()
    setmetatable(self, nil)
    self = nil
end

--[[
    测试用例：
    local set =  Container.Set.new() 
    set:insert(1)
    set:insert(1)
    set:insert(2)
    set:contain(1)
    set:delete(1)
    print(set:contain(1))
    print(set:contain(2))
    set:dispose()
]]
Container.Set = Set


-- [[ 棧 ]] --

local Stack = {}
Stack.__index = Stack

function Stack.new()
    local o = {}
    o.data = {}
    o.bottom = 1
    o.top = 1
    setmetatable(o, Stack)
    return o
end

function Stack:isEmpty()
    return self.bottom == self.top
end

function Stack:push(item)
    self.data[self.top] = item
    self.top = self.top + 1
end

function Stack:pop()
    if self:isEmpty() then
        return nil
    end
    local index = self.top - 1
    local o = self.data[index]
    self.data[index] = nil
    self.top = index
    return o
end

function Stack:peek()
    if self:isEmpty() then
        return nil
    end
    return self.data[self.top - 1]
end

function Stack:clear()
    self.data = {}
    self.top = 1
    self.bottom = 1
end

function Stack:dispose()
    self:clear()
    setmetatable(self, nil)
    self = nil
end

function Stack:size()
    return self.top - self.bottom
end

--[[
    测试用例：
    local stack =  Container.Stack.new() 
    stack:push(3)
    stack:clear()
    stack:push(2)
    stack:push(1)
    stack:push(5)
    print(stack:pop())
    print(stack:pop())
    print(stack:pop())
    stack:dispose()
    stack = nil
    dump(stack)
]]
Container.Stack = Stack


-- [[ 队列 ]] -- 

local Queue = {}
Queue.__index = Queue

function Queue.new()
    local o = {}
    o.data = {}
    o.first = 1
    o.last = 1
    setmetatable(o, Queue)
    return o
end

function Queue:clear()
    self.data = {}
    self.first = 1
    self.last = 1
end

function Queue:dispose()
    self:clear()
    setmetatable(self, nil)
    self = nil
end

function Queue:isEmpty()
    return self.first == self.last
end

function Queue:front()
    if self:isEmpty() then
        return nil
    end
    return self.data[self.first]
end

function Queue:back()
    if self:isEmpty() then
        return nil
    end
    return self.data[self.last-1]
end

function Queue:push(item)
    self.data[self.last] = item
    self.last = self.last + 1
end

function Queue:pop()
    if self:isEmpty() then
        return nil
    end
    local index = self.first
    local o = self.data[index]
    self.data[index] = nil
    self.first = index + 1
    return o
end

function Queue:size()
    return self.last - self.first
end


--[[
    测试用例：
    local queue =  Container.Queue.new() 
    queue:push(3)
    queue:clear()
    queue:push(2)
    queue:push(1)
    queue:push(5)
    print(queue:pop())
    print(queue:pop())
    print(queue:pop())
    queue:dispose()
    queue = nil
    dump(queue)
]]
Container.Queue = Queue


--[[ 堆，默认最大堆, 最小堆需要调用setLess ]]-- 

local Heap = {}
Heap.__index = Heap

function Heap.new(isLess)
    local o = {}
    o.heap = {}
    setmetatable(o, Heap)
    return o
end

function Heap:setLess()
    if not self:isEmpty() then
        assert(false, "Please call clear function before setLess.")
    end
    self.isLess = true
end

function Heap:clear()
    self.heap = {}
    self.isLess = nil
end

function Heap:dispose()
    self:clear()
    setmetatable(self, nil)
    self = nil
end

function Heap:getIndex(val)
    for i, v in ipairs(self.heap) do
        if v == val then
            return i
        end
    end
    return nil
end

function Heap:getMax()
    if self:isEmpty() then
        return nil
    end
    return self.heap[1]
end

function Heap:isEmpty()
    return #self.heap == 0
end

function Heap:size()
    return #self.heap
end

function Heap:insert(val)
    table_insert(self.heap, val)
    self:filterUp(self:size())
end

function Heap:delete(val)
    if self:isEmpty() then
        assert(false, "Heap is empty!")
    end
    local index = self:getIndex(val)
    if not index then
        print("Not found "..val)
        return
    end
    self.heap[index] = self.heap[#self.heap]
    self.heap[#self.heap] = nil
    self:filterDown(index, #self.heap)
end

function Heap:swap(t, i, j)
    local temp = t[i]
    t[i] = t[j]
    t[j] = temp
end

function Heap:getTop()
    if self:isEmpty() then
        return nil
    end
    return self.heap[1]
end

function Heap:filterUp(start)
    local current = start
    local parent = math.floor(current / 2)
    local heap = self.heap
    while current>1 do
        if (parent == 0)  then
            break
        end
        local cb = function ()
            self:swap(heap, current, parent)
            current = parent
            parent = math.floor(parent / 2)
        end
        if self.isLess then
            if (heap[parent] <= heap[current]) then
                break
            else
                cb()
            end
        else
            if (heap[parent] >= heap[current]) then
                break
            else
                cb()
            end
        end
    end
    self.heap = heap
end

function Heap:filterDown(start, finish)
    local current = start
    local left = 2 * current
    local heap = self.heap
    while left <= finish do
        if left < finish then
            if self.isLess then
                if (heap[left] > heap[left+1]) then
                    left = left + 1                    
                end
            else
                if (heap[left] < heap[left+1]) then
                    left = left + 1                    
                end
            end
        end
        local cb = function ()
            self:swap(heap, current, left)
            current = left
            left = 2 * left
        end
        if self.isLess then
            if (heap[current] <= heap[left]) then
                break
            else
                cb()
            end
        else
            if (heap[current] >= heap[left]) then
                break
            else
                cb()
            end
        end
    end
    self.heap = heap
end

--[[
    测试用例
    local heap = Container.Heap.new() 
    heap:setLess()
    heap:insert(20)
    heap:insert(1)
    heap:insert(5)
    heap:insert(90)
    heap:insert(70)
    heap:insert(80)
    heap:insert(81)
    dump(heap.heap)
    heap:delete(1)
    dump(heap.heap)
    heap:delete(5)
    dump(heap.heap)
    heap:delete(11)
    heap:dispose()
]]
Container.Heap = Heap


-- [[ 优先队列,默认是最大的在前 ]] --

local Priority_Queue = {}
Priority_Queue.__index = Priority_Queue

function Priority_Queue.new()
    -- if not operator then
    --     assert(false, "Please input operator.")
    -- end
    -- if type(operator) ~= "string" then
    --     assert(false, "Operator must be string.")
    -- end
    local o = {}
    o.heap = Heap.new()
    setmetatable(o, Priority_Queue)
    return o
end

function Priority_Queue:setLess()
    self.heap:setLess()
end

function Priority_Queue:clear()
    self.heap:clear()
end

function Priority_Queue:dispose()
    self:clear()
    self.heap:dispose()
    self.heap = nil
    setmetatable(self, nil)
    self = nil
end

function Priority_Queue:isEmpty()
    return self.heap:isEmpty()
end

function Priority_Queue:push(item)
    self.heap:insert(item)
end

function Priority_Queue:pop()
    if self:isEmpty() then
        return nil
    end
    local o = self.heap:getTop()
    self.heap:delete(self.heap:getTop())
    return o
end

function Priority_Queue:size()
    return self.heap:size()
end

--[[
    测试用例：
    local pri_queue =  Container.Priority_Queue.new() 
    pri_queue:push(3)
    pri_queue:clear()
    -- pri_queue:setLess()    
    pri_queue:push(2)
    pri_queue:push(1)
    pri_queue:push(5)
    print(pri_queue:pop())
    print(pri_queue:pop())
    print(pri_queue:pop())
    pri_queue:dispose()
]]
Container.Priority_Queue = Priority_Queue


--[[ 链表 ]] --

local List = {}
List.__index = List

function List.new(t)
    local o = {}
    o.type = t
    setmetatable(o, List)
    return o
end

function List:dispose()
    self:clear()
    setmetatable(self, nil)
    self = nil
end

function List:begin()
    return self[1]
end

function List:final()
    return self[#self]
end

function List:push_back(item)
    table_insert(self, item)
end

function List:foreach(func)
    if (func == nil or type(func) ~= "function") then
        print("func is invalid!")
        return
    end
    local count = self:size()
    for i = 1, count do
        func(self[i])
    end
end

function List:indexOf(item)
    local count = self:size()
    for i=1, count do
        if self[i] == item then
            return i
        end
    end
    return 0
end

function List:lastIndexOf(item)
    local count = self:size()
    for i = count, 1, -1 do
        if self[i] == item then
            return i
        end
    end
    return 0
end

function List:insert(index, item)
    table_insert(self, index, item)
end

function List:delete(item)
    local index = self:lastIndexOf(item)
    if (index > 0) then
        table_remove(self, index)
    end
end

function List:deleteByIndex(index)
    table_remove(self, index)
end

function List:getType()
    return self.type
end

function List:isEmpty()
    return #self==0
end

function List:contain(item)
    local count = self:size()
    for i = 1, count do
        if self[i] == item then
            return true
        end
    end
    return false
end

function List:clear()
    local count = self:size()
    for i = count, 1, -1 do
        table_remove(self[i])
    end
end

function List:size()
    return #self
end

function List:sort(func)
    if (func ~= nil and type(func) ~= 'function') then
        print('func is invalid')
        return
    end
    if func == nil then
        table_sort(self)
    else
        table_sort(self, func)
    end
end

function List:find(func)
    if (func == nil or type(func) ~= 'function') then
        print('func is invalid!')
        return
    end
    local count = self:size()
    for i = 1, count do
        if func(self[i]) then 
            return self[i] 
        end
    end
    return nil
end

--[[
    测试用例：
    local list =  Container.List.new() 
    list:push_back(1)
    list:push_back(2)
    list:push_back(3)
    print(list:begin())
    print(list:final())
    list:sort(function (a, b)
        return a > b
    end)
    list:foreach(function (item)
        print(item)
    end)
    list:dispose()
]]
Container.List = List


--[[ 二叉排序树 ]] --

local BSTree = {}
BSTree.__index = BSTree

function BSTree.new()
    local o = {}
    setmetatable(o, BSTree)
    return o
end

function BSTree:clear()
    self.root = nil
end

function BSTree:dispose()
    self:clear()
    setmetatable(self, nil)
    self = nil
end

function BSTree:recursionInsert(node, val, isInternal)
    if not isInternal then
        assert(false, "Please use insert instead of recursionInsert.")
    end
    if not node then
        node = {val = val}
        return node;
    end
    if (val < node.val) then
        node.left = self:recursionInsert(node.left, val, true);
        node.left.parent = node;
    elseif (val >= node.val) then
        node.right = self:recursionInsert(node.right, val, true);
        node.right.parent = node;
    end
    return node;
end
        
-- 外部调用的接口 --
function BSTree:insert(val)
    if not self.root then
        self.root = self:recursionInsert(self.root, val, true)
    else
        self:recursionInsert(self.root, val, true)
    end
end

function BSTree:delete(val)
    local delNode = self.root
    while delNode do
        if (delNode.val == val) then
            break
        end
        if (val < delNode.val) then
            delNode = delNode.left
        elseif (val > delNode.val) then
            delNode = delNode.right
        end
    end
    if not delNode then
        print("Not found "..val)
        return 
    end
    -- 无左子树，也无右子树 -- 
    if (not delNode.left) and (not delNode.right) then
        local parent = delNode.parent
        if not parent then
            self.root = nil
        else
            if parent.left == delNode then
                parent.left = nil
            else
                parent.right = nil
            end
        end
    elseif delNode.left and (not delNode.right) then
        local parent = delNode.parent
        local child = delNode.left
        if not parent then
            self.root = child
            self.root.parent = nil
        else
            if parent.left == delNode then
                parent.left = child
            else
                parent.right = child
            end
            child.parent = parent
        end
    elseif (not delNode.left) and delNode.right then
        local parent = delNode.parent
        local child = delNode.right
        if not parent then
            self.root = child
            self.root.parent = nil
        else
            if parent.left == delNode then
                parent.left = child
            else
                parent.right = child
            end
            child.parent = parent
        end
    elseif delNode.left and delNode.right then
        -- 找到后继节点 -- 
        local successorNode  = self:findMin(delNode.right)
        delNode.val = successorNode.val
        if (not successorNode.left) and (not successorNode.right) then
            if (successorNode.parent.left == successorNode) then
                successorNode.parent.left = nil
            else
                successorNode.parent.right = nil
            end
        else
            local successorChild = successorNode.left and successorNode.left or successorNode.right
            local parent = successorNode.parent
            if parent.left == successorNode then
                parent.left = successorChild
            else
                parent.right = successorChild
            end
            successorChild.parent = parent
        end
    end
end

function BSTree:findMin(node)
    local curNode = node
    while curNode.left do
        curNode = curNode.left
    end
    return curNode
end

--[[
    测试用例：
    local bs = Container.BSTree.new()
    bs:insert(10)
    bs:insert(1)
    bs:insert(5)
    bs:insert(4)
    bs:insert(11)
    bs:insert(15)
    bs:delete(10)
    bs:delete(4)
    bs:delete(20)
    bs:dispose()
]]
Container.BSTree = BSTree

--[[ 二叉树的遍历 ]] -- 
-- 层序遍历 --
local function levelOrderTraversal(root, func)
    if (not func) or type(func) ~= "function" then
        assert(false, "func is invalid!")
        return
    end
    local queue = Queue.new()
    queue:push(root)
    while (queue:size() > 0) do
        local currNode = queue:pop()
        if currNode.left then
            queue:push(currNode.left)
        end
        if currNode.right then
            queue:push(currNode.right)
        end
        func(currNode.val)
    end
    queue:dispose()
end

--[[
    测试用例：
    Container.levelOrderTraversal(bs.root, function (val)
        print(val)
    end)
]]
Container.levelOrderTraversal = levelOrderTraversal

-- 先序遍历 --
local function preOrderTraversal(node, func)
    if (not func) or type(func) ~= "function" then
        assert(false, "func is invalid!")
        return
    end
    if node then
        preOrderTraversal(node.left, func)      
        func(node.val)
        preOrderTraversal(node.right, func)        
    end
end

--[[
    测试用例：
    Container.preOrderTraversal(bs.root, function (val)
        print(val)
    end)
]]
Container.preOrderTraversal = preOrderTraversal

-- 中序遍历 --
local function inOrderTraversal(node, func)
    if (not func) or type(func) ~= "function" then
        assert(false, "func is invalid!")
        return
    end
    if node then
        func(node.val)
        inOrderTraversal(node.left, func)      
        inOrderTraversal(node.right, func)        
    end
end

--[[
    测试用例：
    Container.inOrderTraversal(bs.root, function (val)
        print(val)
    end)
]]
Container.inOrderTraversal = inOrderTraversal

-- 后续遍历 --
local function postOrderTraversal(node, func)
    if (not func) or type(func) ~= "function" then
        assert(false, "func is invalid!")
        return
    end
    if node then
        postOrderTraversal(node.left, func)      
        postOrderTraversal(node.right, func)        
        func(node.val)
    end
end

--[[
    测试用例：
    Container.postOrderTraversal(bs.root, function (val)
        print(val)
    end)
]]
Container.postOrderTraversal = postOrderTraversal

--[[ 深度优先和广度优先 ]] --

--[[
    测试用例：
    local nodes = {
        [1] = {2, 7, 8},
        [2] = {1, 3, 6},
        [3] = {2, 4, 5},
        [4] = {3},
        [5] = {3},
        [6] = {2},
        [7] = {1},
        [8] = {1, 9, 12},
        [9] = {8, 10, 11},
        [10] = {9},
        [11] = {9},
        [12] = {8}
    }
]]
-- 深度优先 --
local function DFS(start, map, func)
    local function reCurStep(node, used)
        used[node] = true
        local t= func and func(node)
        for _, n in ipairs(map[node]) do
            if not used[n] then
                reCurStep(n, used)
            end
        end
    end
    reCurStep(start, {})
end
--[[
    测试用例：
    local visited = {};
    Container.DFS(1, maps, function (pos)
        table.insert(visited, pos)
    end)
    print(table.concat(visited, ", "))
]]
Container.DFS = DFS

-- 广度优先
local function BFS(start, map, func)
    local used = {}
    local nextPos = function(pos)
        local next = {}
        for _, p in ipairs(map[pos]) do
            local t = (not used[p]) and table_insert(next, p)
        end
        return next
    end
    local queue = Queue.new()
    queue:push(start)
    while (not queue:isEmpty()) do
        local next = {}
        local pos = queue:pop()
        table_insert(used, pos)
        local t = func and func(pos)
        for _, p in ipairs(nextPos(pos)) do
            table_insert(next, p)
        end
        for i, v in ipairs(next) do
            queue:push(v)
        end
    end
    queue:dispose()
end

--[[
    测试用例：
    local visited = {};
    Container.BFS(1, maps, function (pos)
        table.insert(visited, pos)
    end)
    print(table.concat(visited, ", "))
]]
Container.BFS = BFS


--[[ A*算法 ]] -- 

local AStar = {}
AStar.__index = AStar
function AStar.new()
    local o = {}
    setmetatable(o, AStar)
    return o
end

-- 二维数组，0可行走格子，1有障碍 -- 
function AStar:init(mapData)
    self._mapData = mapData   
    self._map = {}
    self._lPath = {}
    self.mapRow = #mapData
    self.mapCol = #mapData[1]
    for i = 1, #mapData do
        self._map[i] = {}
        for j = 1, #mapData[1]  do
            self._map[i][j] = {
                _row = i,
                _col = j,
                _parent = nil,
                _f = 0,-- 节点总开销
                _g = 0,-- 累计开销
                _h = 0,-- 启发因子
            }
        end
    end
end

-- 外部调用 --
function AStar:getSearchPath(from, to)
    self:runAStar(from, to)
    return self._lPath
end

function AStar:checkCanPass(row, col)
    if not self._mapData[col] then
        return false
    end
    return self._mapData[col][row] == 0
end

local Direction = {
    RIGHT = 1,
    RIGHT_DOWN = 2,
    DOWN = 3,
    LEFT_DOWN = 4,
    LEFT = 5,
    LEFT_UP = 6,
    UP = 7,
    RIGHT_UP = 8,
}
function AStar:getNeighbor(curPos, dir)    
    if dir == Direction.RIGHT then
        return {x = curPos.x + 1, y = curPos.y}
    elseif dir == Direction.RIGHT_DOWN then
        return {x = curPos.x + 1, y = curPos.y - 1}
    elseif dir == Direction.DOWN then
        return {x = curPos.x, y = curPos.y - 1}
    elseif dir == Direction.LEFT_DOWN then
        return {x = curPos.x - 1, y = curPos.y - 1}
    elseif dir == Direction.LEFT then
        return {x = curPos.x - 1, y = curPos.y}
    elseif dir == Direction.LEFT_UP then
        return {x = curPos.x - 1, y = curPos.y + 1}
    elseif dir == Direction.UP then
        return {x = curPos.x, y = curPos.y + 1}
    elseif dir == Direction.RIGHT_UP then
        return {x = curPos.x + 1, y = curPos.y + 1}
    end
end

function AStar:runAStar(from,to)
    local ret = self:main(from, to)
    if ret then
        self:collectRoute(from, to)
        return true
    end
    return false
end
 
function AStar:collectRoute(from, to)
    self._lPath = {}
    local mapNode = self._map[to.y][to.x]
    table_insert(self._lPath, {x = mapNode._row, y = mapNode._col})
    while mapNode._col ~= from.x or mapNode._row ~= from.y do
        mapNode = mapNode._parent
        table_insert(self._lPath, 1, {x = mapNode._row, y = mapNode._col})
    end
end
 
function AStar:main(fromPos, toPos)

    local openList = List.new()
    local closeList = List.new()

    local targetNode = self._map[toPos.y][toPos.x]
    local fromNode = self._map[fromPos.y][fromPos.x]

    local f, g, h;
    fromNode._g = 0
    -- 曼哈顿距离 -- 
    fromNode._h = math.abs(fromPos.x - toPos.x) +  math.abs(fromPos.y - toPos.y)
    fromNode._f = fromNode._h
    openList:push_back(fromNode)

    while openList:size() > 0 do
        local mapNode = openList:begin()  
        openList:delete(openList:begin()) 
        if mapNode._row == toPos.x and mapNode._col == toPos.y then
            return true
        end
        closeList:push_back(mapNode)
        local parentPos = {x = mapNode._col, y = mapNode._row}    
        for i = 1, 8 do
            local neighborPos = self:getNeighbor(parentPos, i)
            if neighborPos.x > 0 and neighborPos.x <= self.mapCol and neighborPos.y > 0 and neighborPos.y <= self.mapRow then     
                local neighborNode = self._map[neighborPos.y][neighborPos.x]
                if self:checkCanPass(neighborPos.y,neighborPos.x) and (not closeList:contain(neighborNode)) and 
                    (not openList:contain(openList, neighborNode)) then
                    if i % 2 == 0 then
                        g = neighborNode._g + 1
                    else
                        g = neighborNode._g + 1.4
                    end
                    h = math.abs(neighborPos.x -toPos.x) + math.abs(neighborPos.y - toPos.y)
                    f = g + h
                    neighborNode._parent = mapNode
                    neighborNode._f = f
                    neighborNode._g = g
                    neighborNode._h = h
                    openList:push_back(neighborNode)
                end
            end
        end
        openList:sort(function (a, b)
            return a._f < b._f
        end)
    end
    openList:dispose()
    closeList:dispose()
    return false
end

function AStar:clear()
    self._mapData = nil   
    self._map = nil
    self._lPath = nil
    self.mapRow = nil
    self.mapCol = nil
end

function AStar:dispose()
    self:clear()
    setmetatable(self, nil)
    self = nil
end

--[[
    测试用例
    local mapData = {
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 1, 1, 0, 0, 0, 0},
        {0, 0, 1, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 1, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0},
    }
    local from = {x=1, y=1}
    local to = {x=8, y=3}
    local astar =  Container.AStar.new() 
    astar:init(mapData)
    local lPath = astar:getSearchPath(from, to)
    dump(lPath)
    astar:dispose()
]]
Container.AStar = AStar


--[[
    NOTICE:对于性能要求更高的地方
    动态：JPS算法:http://grastien.net/ban/articles/hg-aaai11.pdf
    静态：JPS+GB:https://github.com/SteveRabin/JPSPlusWithGoalBounding
    在路径不是很多并且静态的情况下可以直接硬编码，需要的时候直接取
]]

return Container
