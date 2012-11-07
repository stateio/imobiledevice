require 'imobiledevice/c'

module IMobileDevice
  class IFile
    def initialize(afc_client, handle)
      @afc_client = afc_client
      @handle = handle
    end

    def close
      C.afc_file_close(@afc_client, @handle)
    end
    
    def lock(operation)
      C.afc_file_lock(@afc_client, @handle, C::AFC_LOCK_OP[operation])
    end

    def read(length = nil)
      data = ""
      #read length bytes, or loop till the file is done
      if length.nil?
        do_loop = true
        length = 1000
      else
        do_loop = false
      end
      begin
        data_ptr = FFI::MemoryPointer.new :string, 1001
        bytes_read_ptr = FFI::MemoryPointer.new :uint32
        C.afc_file_read(@afc_client, @handle, data_ptr, length, bytes_read_ptr)
        bytes_read = bytes_read_ptr.read_uint32
        data << data_ptr.read_string
      end while do_loop && bytes_read != 0
      data
    end

    def write(data)
      bytes_written_ptr = FFI::MemoryPointer.new :uint32
      C.afc_file_write(@afc_client, @handle, data, data.length, bytes_written_ptr)
      bytes_written = bytes_written_ptr.read_uint32
    end
  end
end
