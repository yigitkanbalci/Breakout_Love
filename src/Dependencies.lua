--Import library files
push = require 'lib/push'
Class = require 'lib/class'

--Import source files
require 'src/Constants'
require 'src/StateMachine'
require 'src/Util'
require 'src/Paddle'
require 'src/Ball'

-- Import States
require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/PlayState'