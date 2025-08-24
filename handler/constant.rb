def process_node_Constant(node, msg)
  constantValue = node[:C]

  node[:wires].each do |nextNodeId|
    msg = { id: nextNodeId, payload: constantValue }
    MessageQueue << msg
  end
end
