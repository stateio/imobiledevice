require 'imobiledevice/c'
require 'imobiledevice/ifile'

module IMobileDevice
  class NoAFCClient < IOError; end
  class NoDevice < IOError; end
  class LockdowndError < IOError; end
  class AFCError < IOError; end
  
  class IDevice
    attr_accessor :udid
    def initialize(udid = nil)
      #We use the first device we detect if UDID isn't specified
      if udid.nil?
        list = IMobileDevice.device_list
        if list.empty?
          raise NoDevice, "No iDevice is connected"
        end
        udid = list.first
      end
      @udid = udid
      #Create a new IDevice structure
      device_ptr = FFI::MemoryPointer.new :pointer
      C.idevice_new(device_ptr, @udid)
      @device = device_ptr.read_pointer
      # @device = C::IDevice.new device_ptr.read_pointer
    end

    def access_app(appid)
      self.start_afc_for_app(appid)
    end
    
    def set_debug_level(level)
      C.idevice_set_debug_level(level)
    end
    
    def start_service(service_name)
      # Starts the named service on the iDevice
      # Returns port it's started on 
      ptr = FFI::MemoryPointer.new :pointer
      C.lockdownd_client_new_with_handshake(@device, ptr ,"foo")
      client_ptr = ptr.read_pointer
      
      port = FFI::MemoryPointer.new :uint16
      error = C.lockdownd_start_service(client_ptr, service_name, port)
      if error.nonzero?
        raise LockdowndError, "Lockdownd raised error: #{C::LOCKDOWN_ERRORS[error]}"
      end
      C.lockdownd_client_free(client_ptr)
      
      port.read_uint16
      
    end

    def start_afc
      #Starts the AFC service used for accessing the iDevice's filesystem
      port = self.start_service 'com.apple.afc'

      ptr = FFI::MemoryPointer.new :pointer
      C.afc_client_new(@device, port, ptr)
      @afc_client = ptr.read_pointer
    end

    def start_afc_for_app(appid, command = "VendContainer")
      self.start_house_arrest

      C.house_arrest_send_command(@house_arrest_client, command, appid)

      ptr = FFI::MemoryPointer.new :pointer
      C.house_arrest_get_result(@house_arrest_client, ptr)
      
      ptr2 = FFI::MemoryPointer.new :pointer
      C.afc_client_new_from_house_arrest_client(@house_arrest_client, ptr2)
      @afc_client = ptr2.read_pointer
    end
                                                

    def start_instproxy
      port = self.start_service 'com.apple.mobile.installation_proxy'

      ptr = FFI::MemoryPointer.new :pointer
      C.instproxy_client_new(@device, port, ptr)
      @instproxy_client = ptr.read_pointer
    end

    def start_house_arrest
      port = self.start_service 'com.apple.mobile.house_arrest'
      
      ptr = FFI::MemoryPointer.new :pointer
      C.house_arrest_client_new(@device, port, ptr)
      @house_arrest_client = ptr.read_pointer
    end
    
    def ls(dir)
      #dumps directory contents
      if @afc_client.nil?
        raise NoAFCClient
      end
      list = FFI::MemoryPointer.new :pointer
      C.afc_read_directory(@afc_client, dir, list)
      list.read_pointer.read_unbound_array_of_string
    end

    def open(path, mode)
      if C::AFC_FILE_MODE[mode].nil?
        raise "No such mode"
      end
      if @afc_client.nil?
        raise NoAFCClient
      end
      
      ptr = FFI::MemoryPointer.new :uint64
      C.afc_file_open(@afc_client, path, C::AFC_FILE_MODE[mode], ptr)
      IFile.new(@afc_client, ptr.read_uint64)
    end

    def file_info(path)
      if @afc_client.nil?
        raise NoAFCClient 
      end
      ptr = FFI::MemoryPointer.new :pointer
      C.afc_get_file_info(@afc_client, path, ptr)
      ptr.read_pointer.read_unbound_array_of_string
    end
  end
end
