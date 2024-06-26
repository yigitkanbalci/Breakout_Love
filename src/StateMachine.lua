StateMachine = Class{}

function StateMachine:init(states)
    self.empty = {
        render = function() end,
        update = function() end,
        enter = function() end,
        exit = function() end,
    }

    self.states = states or {}
    self.current = self.empty
end

function StateMachine:change(state, params)
    assert(self.states[state])
    self.current:exit()
    self.current = self.states[state]()
    self.current:enter(params)
end

function StateMachine:update(dt)
    self.current:update(dt)
end

function StateMachine:render()
    self.current:render()
end