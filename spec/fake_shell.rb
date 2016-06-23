# Provides a fake shell to inject into objects when testing
class FakeShell
  attr_accessor :debug, :quiet, :command_history, :path, :host

  # Store parameters used to initialize the shell
  def initialize(path, host)
    @command_history = []
    @path = path
    @host = host
  end

  # Log all commands
  def run(commands)
    commands = [*commands]
    @command_history += commands
  end

  # Return last command executed, just for convenience
  def last_command
    @command_history.last
  end
end
