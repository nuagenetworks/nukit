module Encumber
  class GUI

    def value_is_equal(xpath, value)

      if value == '""'
        value = ""
      end

      result = command 'valueIsEqual', id_for_element(xpath), value
      raise "Value #{value} not found" if result["result"] != "OK"
    end

    def is_control_focused(xpath)
      result = command "isControlFocused", id_for_element(xpath)
      raise "Could not find control for element #{xpath}" if result['result'] == "__CUKE_ERROR__"
      raise "Control #{xpath} is not focused" if result['result'] == "NOT FOCUSED"
      return result['result'].to_s
    end

  end
end