class SMQueue
  VERSION = '1.0.0'

  attr_accessor :adapter

  def initialize uri = nil
    if uri
      adapter_name, options = *uri.split(/:\/\//, 2)
      adapter_class = adapter_name.dup
      adapter_class[0] = adapter_class[0..0].upcase
      adapter_class += 'Adapter'
      @adapter = SMQueue::Adapter.const_get(adapter_class).new(options)
    end
  end

  def channel *args
    raise "You must select an Adapter before connecting" if !@adapter
    @adapter.channel *args
  end
end
