module ActionHelper

  def self.included klass
    klass.extend ClassMethods
  end
  
  def action_helper *helper_modules
    helper_modules.each {|helper| response.template.extend helper }
  end
  
  private

  def render_for_file *args
    extend_if_necessary
    super
  end
  
  def extend_if_necessary
    action_module = self.class.action_helper_for(action_name)
    unless action_module == :no_action_helper
      response.template.extend action_module
    end
  end
  
  module ClassMethods
    def helper *args
      options = args.last.is_a?(Hash) ? args.pop : nil
      if options
        [options[:only]].flatten.each do |action|
          master_action_helper = forced_action_helper_for(action.to_s)
          args.each do |helper|
            master_action_helper.module_eval { include helper }
          end
        end
      else
        super
      end
    end
    
    def action_helpers
      @master_action_helpers ||= {}
    end
    
    def action_helper_for action_name
      action_helpers[action_name] ||= build_action_helper_for action_name
    end
    
    def forced_action_helper_for action_name
      if action_helper_for(action_name) == :no_action_helper
        action_helpers[action_name] = Module.new
      else
        action_helper_for(action_name)
      end
    end
    
    def build_action_helper_for action_name
      controller_part = self.name.sub(/Controller$/, '')
      action_part = action_name.camelize
      "#{controller_part}#{action_part}Helper".constantize
    rescue NameError
      :no_action_helper
    end
  end
end