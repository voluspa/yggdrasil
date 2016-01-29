defprotocol Yggdrasil.Command do
  def execute(cmd, ctxt)
end

